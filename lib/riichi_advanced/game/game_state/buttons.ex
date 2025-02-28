
defmodule RiichiAdvanced.GameState.Buttons do
  alias RiichiAdvanced.GameState.Actions, as: Actions
  alias RiichiAdvanced.GameState.Choice, as: Choice
  alias RiichiAdvanced.GameState.Conditions, as: Conditions
  alias RiichiAdvanced.GameState.Debug, as: Debug
  alias RiichiAdvanced.GameState.Player, as: Player
  alias RiichiAdvanced.GameState.Saki, as: Saki
  alias RiichiAdvanced.GameState.Log, as: Log
  alias RiichiAdvanced.Riichi, as: Riichi
  alias RiichiAdvanced.Utils, as: Utils
  import RiichiAdvanced.GameState

  def to_buttons(state, button_choices) do
    buttons = Map.keys(button_choices) |> Enum.sort()
    unskippable_button_exists = Enum.any?(buttons, fn button_name -> Map.has_key?(state.rules["buttons"][button_name], "unskippable") and state.rules["buttons"][button_name]["unskippable"] end)
    if not Enum.empty?(buttons) and not unskippable_button_exists do buttons ++ ["skip"] else buttons end
  end

  def make_button_choices(state, seat, button_name, button) do
    actions = button["actions"]
    # IO.puts("It's #{state.turn}'s turn, player #{seat} (choice: #{inspect(choice)}) gets to run actions #{inspect(actions)}")
    # check if a call action exists, if it's a call and multiple call choices are available
    choice_actions = Actions.extract_actions(actions, ["call", "self_call", "upgrade_call", "flower", "draft_saki_card", "mark", "choose_yaku"])
    cond do
      Enum.any?(choice_actions, fn [action | _opts] -> action in ["call", "self_call", "upgrade_call", "flower", "draft_saki_card"] end) ->
        # call button choices logic
        # if there is a call action, check if there are multiple call choices
        is_call = Enum.any?(choice_actions, fn [action | _opts] -> action == "call" end)
        is_upgrade = Enum.any?(choice_actions, fn [action | _opts] -> action == "upgrade_call" end)
        is_flower = Enum.any?(choice_actions, fn [action | _opts] -> action == "flower" end)
        is_saki_card = Enum.any?(choice_actions, fn [action | _opts] -> action == "draft_saki_card" end)
        hand = Utils.add_attr(state.players[seat].hand, ["_hand"])
        draw = Utils.add_attr(state.players[seat].draw, ["_hand"])
        tile_behavior = state.players[seat].tile_behavior
        {state, call_choices} = cond do
          is_upgrade ->
            call_choices = state.players[seat].calls
            |> Enum.filter(fn {name, _call} -> name == state.rules["buttons"][button_name]["upgrades"] end)
            |> Enum.map(fn {_name, call} -> Enum.map(call, &Utils.add_attr(&1, ["_hand", "_called"])) end)
            |> Enum.map(fn call_tiles ->
                 Riichi.make_calls(state.rules["buttons"][button_name]["call"], call_tiles, tile_behavior, hand ++ draw)
               end)
            |> Enum.flat_map(&Enum.map(&1, fn {called_tile, call_choice} -> %{Utils.strip_attrs(called_tile) => call_choice} end))
            |> Enum.reduce(%{}, fn call_choices, acc -> Map.merge(call_choices, acc, fn _k, l, r -> Enum.uniq_by(l ++ r, &Utils.strip_attrs(&1)) end) end)
            {state, call_choices}
          is_flower ->
            flowers = Enum.flat_map(choice_actions, fn [action | opts] -> if action == "flower" do opts else [] end end) |> Enum.map(&Utils.to_tile/1)
            flowers_in_hand = Enum.filter(state.players[seat].hand ++ state.players[seat].draw, fn tile -> Utils.has_matching_tile?([tile], flowers) end)
            |> Enum.uniq_by(&Utils.strip_attrs(&1))
            call_choices = %{nil => Enum.map(flowers_in_hand, fn tile -> [tile] end)}
            {state, call_choices}
          is_saki_card ->
            # TODO use Enum.drop_while instead to get num
            [num] = Enum.flat_map(choice_actions, fn [action | opts] -> if action == "draft_saki_card" do [Enum.at(opts, 0, 4)] else [] end end)
            {state, cards} = Saki.draw_saki_cards(state, num)
            state = if Enum.empty?(cards) do
              show_error(state, "WARNING: not enough sakicards in the deck to play sakicards!")
            else state end
            call_choices = %{"saki" => Enum.map(cards, fn card -> [card] end)}
            {state, call_choices}
          true ->
            callable_tiles = if is_call do Enum.take(state.players[state.turn].pond, -1) else [] end
            call_choices = Riichi.make_calls(state.rules["buttons"][button_name]["call"], hand ++ draw, tile_behavior, callable_tiles)
            |> Enum.map(fn {called_tile, call_choice} -> %{Utils.strip_attrs(called_tile) => call_choice} end)
            |> Enum.reduce(%{}, fn call_choices, acc -> Map.merge(call_choices, acc, fn _k, l, r -> Enum.uniq_by(l ++ r, &Utils.strip_attrs(&1)) end) end)
            {state, call_choices}
        end
        # filter call_choices
        call_choices = if Map.has_key?(state.rules["buttons"][button_name], "call_conditions") do
          conditions = state.rules["buttons"][button_name]["call_conditions"]
          call_source = if is_call do :discards else :draw end # TODO better way to check call_source
          for {called_tile, choices} <- call_choices do
            # TODO maybe put call_source in choice? we need to define what call_source really is
            {called_tile, Enum.filter(choices, fn call_choice -> Conditions.check_cnf_condition(state, conditions, %{seat: seat, call_source: call_source, choice: %Choice{ name: button_name, chosen_called_tile: called_tile, chosen_call_choice: call_choice }}) end)}
          end
        else call_choices end
        |> Map.new()
        state = Log.add_call_choices(state, seat, button_name, call_choices)
        {state, {:call, call_choices}}
      Enum.any?(choice_actions, fn [action | _opts] -> action == "mark" end) ->
        [_ | opts] = Enum.filter(choice_actions, fn [action | _opts] -> action == "mark" end) |> Enum.at(0)
        mark_spec = Enum.at(opts, 0, []) |> Enum.map(fn [target, needed, restrictions] -> {target, needed, restrictions} end)
        {state, {:mark, mark_spec, Enum.at(opts, 1, []), Enum.at(opts, 2, [])}}
      Enum.any?(choice_actions, fn [action | _opts] -> action == "choose_yaku" end) ->
        {state, :declare_yaku}
      true -> {state, nil}
    end
  end

  def recalculate_buttons(state, interrupt_level \\ 100) do
    if state.game_active and Map.has_key?(state.rules, "buttons") do
      t = System.os_time(:millisecond)
      # IO.puts("Regenerating buttons...")
      # IO.inspect(Process.info(self(), :current_stacktrace))
      buttons_before = Map.new(state.players, fn {seat, player} -> {seat, player.buttons} end)
      # IO.puts("Buttons before:")
      # IO.inspect(buttons_before)
      {state, new_button_choices} = for seat <- state.available_seats, reduce: {state, []} do
        {state, new_button_choices} ->
          if Actions.performing_intermediate_action?(state, seat) do
            # don't regenerate buttons if the player already made a choice that hasn't been adjudicated yet
            {state, new_button_choices}
          else
            button_choices = state.rules["buttons"]
            |> Enum.filter(fn {name, button} ->
              calls_spec = Map.get(button, "call", [])
              upgrades = Map.get(button, "upgrades", [])

              if Debug.debug_buttons() do
                IO.puts("recalculate_buttons: at #{inspect(System.os_time(:millisecond) - t)} ms, checking #{name} for #{seat}")
              end
              Map.get(button, "interrupt_level", 100) >= interrupt_level and 
                if name in Map.get(Debug.debug_specific_buttons(), seat, []) do
                  case Enum.find(button["show_when"], &not Conditions.check_cnf_condition(state, [&1], %{seat: seat, call_name: name, calls_spec: calls_spec, upgrade_name: upgrades})) do
                    nil -> true
                    condition ->
                      IO.puts("Button #{name} for player #{seat}: failed condition #{inspect(condition)}")
                      false
                  end
                else
                  Conditions.check_cnf_condition(state, button["show_when"], %{seat: seat, call_name: name, calls_spec: calls_spec, upgrade_name: upgrades})
                end
            end)
            {state, button_choices} = for {name, button} <- button_choices, reduce: {state, []} do
              {state, button_choices} ->
                {state, spec} = make_button_choices(state, seat, name, button)
                case spec do
                  {:call, choices} -> 
                    empty_choices = choices |> Map.values() |> Enum.concat() |> Enum.empty?()
                    if empty_choices do
                      {state, button_choices}
                    else
                      {state, [{name, spec} | button_choices]}
                    end
                  _ -> {state, [{name, spec} | button_choices]}
                end
            end
            button_choices = Map.new(button_choices)
            {state, [{seat, button_choices} | new_button_choices]}
          end
      end

      if Debug.debug_buttons() do
        elapsed_time = System.os_time(:millisecond) - t
        if elapsed_time > 10 do
          IO.puts("recalculate_buttons: #{inspect(elapsed_time)} ms")
        end
      end
      
      # keep existing buttons whose interrupt level is strictly below our interrupt level
      new_button_choices = for {seat, button_choices} <- new_button_choices, into: %{} do
        button_choices = state.players[seat].button_choices
        |> Enum.filter(fn {name, _spec} -> (get_in(state.rules["buttons"][name]["interrupt_level"]) || 100) < interrupt_level end)
        |> Map.new()
        |> Map.merge(button_choices)
        {seat, button_choices}
      end
      
      # IO.puts("Buttons after:")
      # IO.inspect(buttons)
      buttons = Map.new(new_button_choices, fn {seat, button_choices} -> {seat, to_buttons(state, button_choices)} end)
      state = update_all_players(state, fn seat, player ->
        if Map.has_key?(buttons, seat) do
          %Player{ player | buttons: buttons[seat], button_choices: new_button_choices[seat] }
        else player end
      end)

      # play button notify sound if buttons changed
      if not Enum.empty?(buttons) and buttons != buttons_before do
        for {seat, button_choices} <- new_button_choices do
          if not Enum.empty?(button_choices) do
            play_sound(state, "/audio/pop.mp3", seat)
          end
        end
      end

      # run auto buttons every time we recalculate buttons
      state = trigger_auto_buttons(state)

      state
    else state end
  end

  def press_button(state, seat, button_name) do
    if Enum.member?(state.players[seat].buttons, button_name) do
      # IO.puts("#{seat} pressed button #{button_name}")
      # hide all buttons, but keep button choices in case they undo
      state = update_player(state, seat, fn player -> %Player{ player | buttons: [] } end)
      actions = if button_name == "skip" do [] else state.rules["buttons"][button_name]["actions"] end
      state = Actions.submit_actions(state, seat, button_name, actions)
      state = broadcast_state_change(state) # show possible call buttons
      state
    else
      IO.puts("#{seat} tried to press nonexistent button #{button_name}")
      state
    end
  end

  def press_call_button(state, seat, call_choice \\ nil, called_tile \\ nil, saki_card \\ nil) do
    if state.players[seat].choice != nil do
      button_name = state.players[seat].choice.name
      if Map.has_key?(state.players[seat].button_choices, button_name) do
        # IO.puts("#{seat} pressed call button for button #{button_name}")
        state = update_player(state, seat, fn player -> %Player{ player | call_buttons: %{} } end)
        actions = state.rules["buttons"][button_name]["actions"]
        state = Actions.submit_actions(state, seat, button_name, actions, call_choice, called_tile, saki_card)
        state = broadcast_state_change(state)
        state
      else
        IO.puts("#{seat} tried to press call button for nonexistent button #{button_name}")
        state
      end
    else state end
  end

  # returns true if no button choices remain
  # if any of the pressed buttons takes precedence over all buttons available to a given seat,
  # then that seat is not considered to have button choices
  def no_buttons_remaining?(state) do
    if Map.has_key?(state.rules, "buttons") do
      Enum.all?(state.players, fn {seat, player} ->
        superceded_buttons = Actions.get_all_superceded_buttons(state, seat)
        Enum.all?(player.buttons, fn name -> name in superceded_buttons end)
      end)
    else true end
  end

  def trigger_auto_button(state, seat, auto_button_name, enabled) do
    # we must apply this after _some_ delay
    # this is because it's possible to call this during Actions.run_actions
    # which is called by adjudicate_actions
    # and submitting actions during adjudicate_actions will reenter adjudicate_actions
    # which causes deadlock due to its mutex
    if enabled do
      :timer.apply_after(100, GenServer, :cast, [self(), {:trigger_auto_button, seat, auto_button_name}])
      state
    else state end
  end

  # trigger auto buttons actions for players
  def trigger_auto_buttons(state, seats \\ nil) do
    for seat <- (if seats == nil do state.available_seats else seats end),
        {auto_button_name, _desc, enabled} <- state.players[seat].auto_buttons,
        reduce: state do
      state -> trigger_auto_button(state, seat, auto_button_name, enabled)
    end
  end

end
