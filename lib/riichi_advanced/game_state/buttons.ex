
defmodule RiichiAdvanced.GameState.Buttons do
  alias RiichiAdvanced.GameState.Actions, as: Actions
  alias RiichiAdvanced.GameState.Saki, as: Saki
  # alias RiichiAdvanced.GameState.Log, as: Log
  import RiichiAdvanced.GameState

  def make_button_choices(state, seat, button_name, button) do
    actions = button["actions"]
    # IO.puts("It's #{state.turn}'s turn, player #{seat} (choice: #{choice}) gets to run actions #{inspect(actions)}")
    # check if a call action exists, if it's a call and multiple call choices are available
    call_actions = ["call", "self_call", "upgrade_call", "flower", "draft_saki_card"]
    mark_actions = [
      "swap_hand_tile_with_same_suit_discard",
      "swap_hand_tile_with_last_discard",
      "place_4_tiles_at_end_of_live_wall",
      "set_aside_discard_matching_called_tile",
      "pon_discarded_red_dragon",
      "draw_and_place_2_tiles_at_end_of_dead_wall",
      "set_aside_own_discard",
      "swap_tile_with_aside",
      "charleston_left",
      "charleston_across",
      "charleston_right"
    ]
    cond do
      Enum.any?(actions, fn [action | _opts] -> action in call_actions end) ->
        # call button choices logic
        # if there is a call action, check if there are multiple call choices
        is_call = Enum.any?(actions, fn [action | _opts] -> action == "call" end)
        is_upgrade = Enum.any?(actions, fn [action | _opts] -> action == "upgrade_call" end)
        is_flower = Enum.any?(actions, fn [action | _opts] -> action == "flower" end)
        is_saki_card = Enum.any?(actions, fn [action | _opts] -> action == "draft_saki_card" end)
        ordering = state.players[seat].tile_ordering
        ordering_r = state.players[seat].tile_ordering_r
        tile_aliases = state.players[seat].tile_aliases
        tile_mappings = state.players[seat].tile_mappings
        {state, call_choices} = cond do
          is_upgrade ->
            call_choices = state.players[seat].calls
              |> Enum.filter(fn {name, _call} -> name == state.rules["buttons"][button_name]["upgrades"] end)
              |> Enum.map(fn {_name, call} -> Enum.map(call, fn {tile, _sideways} -> tile end) end)
              |> Enum.map(fn call_tiles ->
                 Riichi.make_calls(state.rules["buttons"][button_name]["call"], call_tiles, ordering, ordering_r, state.players[seat].hand ++ state.players[seat].draw, tile_aliases, tile_mappings)
              end)
              |> Enum.reduce(%{}, fn call_choices, acc -> Map.merge(call_choices, acc, fn _k, l, r -> l ++ r end) end)
            {state, call_choices}
          is_flower ->
            flowers = Enum.flat_map(actions, fn [action | opts] -> if action == "flower" do opts else [] end end) |> Enum.map(&Utils.to_tile/1)
            flowers_in_hand = Enum.filter(state.players[seat].hand ++ state.players[seat].draw, fn tile -> tile in flowers end)
            call_choices = %{nil => Enum.map(flowers_in_hand, fn tile -> [tile] end)}
            {state, call_choices}
          is_saki_card ->
            # TODO use Enum.drop_while instead to get num
            [num] = Enum.flat_map(actions, fn [action | opts] -> if action == "draft_saki_card" do [Enum.at(opts, 0, 4)] else [] end end)
            {state, cards} = Saki.draw_saki_cards(state, num)
            call_choices = %{"saki" => Enum.map(cards, fn card -> [card] end)}
            {state, call_choices}
          true ->
            callable_tiles = if is_call do Enum.take(state.players[state.turn].pond, -1) else [] end
            call_choices = Riichi.make_calls(state.rules["buttons"][button_name]["call"], state.players[seat].hand ++ state.players[seat].draw, ordering, ordering_r, callable_tiles, tile_aliases, tile_mappings)
            {state, call_choices}
        end
        # filter call_choices
        call_choices = if Map.has_key?(state.rules["buttons"][button_name], "call_conditions") do
          conditions = state.rules["buttons"][button_name]["call_conditions"]
          for {called_tile, choices} <- call_choices do
            {called_tile, Enum.filter(choices, fn call_choice -> check_cnf_condition(state, conditions, %{seat: seat, call_name: button_name, called_tile: called_tile, call_choice: call_choice}) end)}
          end |> Map.new()
        else call_choices end
        {:call, call_choices}
      Enum.any?(actions, fn [action | _opts] -> action in mark_actions end) ->
        mark_spec = cond do
          Enum.any?(actions, fn [action | _opts] -> action == "swap_hand_tile_with_same_suit_discard" end)      -> [{"hand", 1, ["match_suit"]}, {"discard", 1, ["match_suit"]}]
          Enum.any?(actions, fn [action | _opts] -> action == "swap_hand_tile_with_last_discard" end)           -> [{"hand", 1, []}]
          Enum.any?(actions, fn [action | _opts] -> action == "place_4_tiles_at_end_of_live_wall" end)          -> [{"hand", 4, []}]
          Enum.any?(actions, fn [action | _opts] -> action == "set_aside_discard_matching_called_tile" end)     -> [{"discard", 1, ["match_called_tile"]}]
          Enum.any?(actions, fn [action | _opts] -> action == "pon_discarded_red_dragon" end)                   -> [{"discard", 1, ["7z"]}]
          Enum.any?(actions, fn [action | _opts] -> action == "draw_and_place_2_tiles_at_end_of_dead_wall" end) -> [{"hand", 2, []}]
          Enum.any?(actions, fn [action | _opts] -> action == "set_aside_own_discard" end)                      -> [{"discard", 1, ["self"]}]
          Enum.any?(actions, fn [action | _opts] -> action == "swap_tile_with_aside" end)                       -> [{"hand", 1, []}]
          Enum.any?(actions, fn [action | _opts] -> action in ["charleston_left", "charleston_across", "charleston_right"] end) -> [{"hand", 3, []}]
        end
        {:mark, mark_spec}
      true -> nil
    end
  end

  def recalculate_buttons(state) do
    if state.game_active && Map.has_key?(state.rules, "buttons") do
      # IO.puts("Regenerating buttons...")
      # IO.inspect(Process.info(self(), :current_stacktrace))
      new_button_choices = Map.new(state.players, fn {seat, _player} ->
        if Actions.performing_intermediate_action?(state, seat) do
          # don't regenerate buttons if we're performing an intermediate action
          {seat, %{}}
        else
          button_choices = state.rules["buttons"]
            |> Enum.filter(fn {name, button} ->
                 calls_spec = if Map.has_key?(button, "call") do button["call"] else [] end
                 upgrades = if Map.has_key?(button, "upgrades") do button["upgrades"] else [] end
                 check_cnf_condition(state, button["show_when"], %{seat: seat, call_name: name, calls_spec: calls_spec, upgrade_name: upgrades})
               end)
            |> Map.new(fn {name, button} -> {name, make_button_choices(state, seat, name, button)} end)
          {seat, button_choices}
        end
      end)
      
      # play button notify sound
      for {seat, button_choices} <- new_button_choices do
        if not Enum.empty?(button_choices) do
          play_sound(state, "/audio/pop.mp3", seat)
        end
      end

      buttons = for {seat, button_choices} <- new_button_choices do
        buttons = Map.keys(button_choices)
        unskippable_button_exists = Enum.any?(buttons, fn button_name -> Map.has_key?(state.rules["buttons"][button_name], "unskippable") && state.rules["buttons"][button_name]["unskippable"] end)
        {seat, if not Enum.empty?(buttons) && not unskippable_button_exists do buttons ++ ["skip"] else buttons end}
      end |> Map.new()
      # IO.puts("Updating buttons after action #{action}: #{inspect(new_button_choices)}")
      update_all_players(state, fn seat, player -> %Player{ player | buttons: buttons[seat], button_choices: new_button_choices[seat] } end)
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
    Enum.all?(state.players, fn {seat, player} ->
      superceded_buttons = Actions.get_all_superceded_buttons(state, seat)
      Enum.all?(player.buttons, fn name -> name in superceded_buttons end)
    end)
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
