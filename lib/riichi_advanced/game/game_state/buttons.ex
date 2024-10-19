
defmodule RiichiAdvanced.GameState.Buttons do
  alias RiichiAdvanced.GameState.Actions, as: Actions
  alias RiichiAdvanced.GameState.Saki, as: Saki
  alias RiichiAdvanced.GameState.Log, as: Log
  import RiichiAdvanced.GameState

  def to_buttons(state, button_choices) do
    buttons = Map.keys(button_choices) |> Enum.sort()
    unskippable_button_exists = Enum.any?(buttons, fn button_name -> Map.has_key?(state.rules["buttons"][button_name], "unskippable") && state.rules["buttons"][button_name]["unskippable"] end)
    if not Enum.empty?(buttons) && not unskippable_button_exists do buttons ++ ["skip"] else buttons end
  end

  def extract_choice_actions([]), do: []
  def extract_choice_actions([action | actions]) do
    choice_actions = case action do
      [action_name | _opts] when action_name in ["call", "self_call", "upgrade_call", "flower", "draft_saki_card", "mark"] -> [action]
      ["when", _condition, subactions] -> extract_choice_actions(subactions)
      ["unless", _condition, subactions] -> extract_choice_actions(subactions)
      ["ite", _condition, subactions1, subactions2] -> extract_choice_actions(subactions1) ++ extract_choice_actions(subactions2)
      _ -> []
    end
    choice_actions ++ extract_choice_actions(actions)
  end

  def make_button_choices(state, seat, button_name, button) do
    actions = button["actions"]
    # IO.puts("It's #{state.turn}'s turn, player #{seat} (choice: #{choice}) gets to run actions #{inspect(actions)}")
    # check if a call action exists, if it's a call and multiple call choices are available
    choice_actions = extract_choice_actions(actions)
    cond do
      Enum.any?(choice_actions, fn [action | _opts] -> action in ["call", "self_call", "upgrade_call", "flower", "draft_saki_card"] end) ->
        # call button choices logic
        # if there is a call action, check if there are multiple call choices
        is_call = Enum.any?(choice_actions, fn [action | _opts] -> action == "call" end)
        is_upgrade = Enum.any?(choice_actions, fn [action | _opts] -> action == "upgrade_call" end)
        is_flower = Enum.any?(choice_actions, fn [action | _opts] -> action == "flower" end)
        is_saki_card = Enum.any?(choice_actions, fn [action | _opts] -> action == "draft_saki_card" end)
        hand = Utils.add_attr(state.players[seat].hand, ["hand"])
        draw = Utils.add_attr(state.players[seat].draw, ["hand"])
        ordering = state.players[seat].tile_ordering
        ordering_r = state.players[seat].tile_ordering_r
        tile_aliases = state.players[seat].tile_aliases
        tile_mappings = state.players[seat].tile_mappings
        {state, call_choices} = cond do
          is_upgrade ->
            call_choices = state.players[seat].calls
              |> Enum.filter(fn {name, _call} -> name == state.rules["buttons"][button_name]["upgrades"] end)
              |> Enum.map(fn {_name, call} -> Enum.map(call, fn {tile, _sideways} -> Utils.add_attr(tile, ["hand", "called"]) end) end)
              |> Enum.map(fn call_tiles ->
                   Riichi.make_calls(state.rules["buttons"][button_name]["call"], call_tiles, ordering, ordering_r, hand ++ draw, tile_aliases, tile_mappings)
                 end)
              |> Enum.reduce(%{}, fn call_choices, acc -> Map.merge(call_choices, acc, fn _k, l, r -> l ++ r end) end)
            {state, call_choices}
          is_flower ->
            flowers = Enum.flat_map(choice_actions, fn [action | opts] -> if action == "flower" do opts else [] end end) |> Enum.map(&Utils.to_tile/1)
            flowers_in_hand = Enum.filter(state.players[seat].hand ++ state.players[seat].draw, fn tile -> tile in flowers end)
            call_choices = %{nil => Enum.map(flowers_in_hand, fn tile -> [tile] end)}
            {state, call_choices}
          is_saki_card ->
            # TODO use Enum.drop_while instead to get num
            [num] = Enum.flat_map(choice_actions, fn [action | opts] -> if action == "draft_saki_card" do [Enum.at(opts, 0, 4)] else [] end end)
            {state, cards} = Saki.draw_saki_cards(state, num)
            call_choices = %{"saki" => Enum.map(cards, fn card -> [card] end)}
            {state, call_choices}
          true ->
            callable_tiles = if is_call do Enum.take(state.players[state.turn].pond, -1) else [] end
            call_choices = Riichi.make_calls(state.rules["buttons"][button_name]["call"], hand ++ draw, ordering, ordering_r, callable_tiles, tile_aliases, tile_mappings)
            {state, call_choices}
        end
        # filter call_choices
        call_choices = if Map.has_key?(state.rules["buttons"][button_name], "call_conditions") do
          conditions = state.rules["buttons"][button_name]["call_conditions"]
          for {called_tile, choices} <- call_choices do
            {called_tile, Enum.filter(choices, fn call_choice -> check_cnf_condition(state, conditions, %{seat: seat, call_name: button_name, called_tile: called_tile, call_choice: call_choice}) end)}
          end |> Map.new()
        else call_choices end
        {state, {:call, call_choices}}
      Enum.any?(choice_actions, fn [action | _opts] -> action == "mark" end) ->
        [_ | opts] = Enum.filter(choice_actions, fn [action | _opts] -> action == "mark" end) |> Enum.at(0)
        mark_spec = Enum.at(opts, 0, []) |> Enum.map(fn [target, needed, restrictions] -> {target, needed, restrictions} end)
        {state, {:mark, mark_spec, Enum.at(opts, 1, [])}}
      true -> {state, nil}
    end
  end

  def recalculate_buttons(state, interrupt_level \\ 100) do
    if state.game_active && Map.has_key?(state.rules, "buttons") do
      # IO.puts("Regenerating buttons...")
      # IO.inspect(Process.info(self(), :current_stacktrace))
      {state, new_button_choices} = for {seat, _player} <- state.players, reduce: {state, []} do
        {state, new_button_choices} ->
          if Actions.performing_intermediate_action?(state, seat) do
            # don't regenerate buttons if we're performing an intermediate action
            {state, [{seat, %{}} | new_button_choices]}
          else
            button_choices = state.rules["buttons"]
            |> Enum.filter(fn {name, button} ->
                 calls_spec = Map.get(button, "call", [])
                 upgrades = Map.get(button, "upgrades", [])
                 Map.get(button, "interrupt_level", 100) >= interrupt_level && check_cnf_condition(state, button["show_when"], %{seat: seat, call_name: name, calls_spec: calls_spec, upgrade_name: upgrades})
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
      new_button_choices = Map.new(new_button_choices)
      
      # play button notify sound
      for {seat, button_choices} <- new_button_choices do
        if not Enum.empty?(button_choices) do
          play_sound(state, "/audio/pop.mp3", seat)
        end
      end

      buttons = Map.new(new_button_choices, fn {seat, button_choices} -> {seat, to_buttons(state, button_choices)} end)
      # IO.puts("Updating buttons after action #{action}: #{inspect(new_button_choices)}")
      state = update_all_players(state, fn seat, player -> %Player{ player | buttons: Enum.uniq(player.buttons ++ buttons[seat]), button_choices: Map.merge(player.button_choices, new_button_choices[seat]) } end)
      state = Log.add_buttons(state)
      state
    else state end
  end

  def press_button(state, seat, button_name) do
    if Enum.member?(state.players[seat].buttons, button_name) do
      # hide all buttons
      state = update_player(state, seat, fn player -> %Player{ player | buttons: [] } end)
      actions = if button_name == "skip" do [] else state.rules["buttons"][button_name]["actions"] end
      state = Actions.submit_actions(state, seat, button_name, actions)
      state = broadcast_state_change(state)
      state
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
  def trigger_auto_buttons(state, seats \\ [:east, :south, :west, :north]) do
    for seat <- seats,
        not is_pid(Map.get(state, seat)),
        {auto_button_name, enabled} <- state.players[seat].auto_buttons,
        reduce: state do
      state -> trigger_auto_button(state, seat, auto_button_name, enabled)
    end
  end

end
