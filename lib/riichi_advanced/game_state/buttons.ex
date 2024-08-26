
defmodule RiichiAdvanced.GameState.Buttons do
  alias RiichiAdvanced.GameState.Actions, as: Actions
  import RiichiAdvanced.GameState

  def recalculate_buttons(state) do
    if state.game_active && Map.has_key?(state.rules, "buttons") do
      # IO.puts("Regenerating buttons...")
      # IO.inspect(Process.info(self(), :current_stacktrace))
      new_buttons = Map.new(state.players, fn {seat, _player} ->
        if Actions.performing_intermediate_action?(state, seat) do
          # don't regenerate buttons if we're performing an intermediate action
          {seat, []}
        else
          buttons = state.rules["buttons"]
            |> Enum.filter(fn {name, button} ->
                 calls_spec = if Map.has_key?(button, "call") do button["call"] else [] end
                 call_wraps = if Map.has_key?(button, "call") do if Map.has_key?(button, "call_wraps") do button["call_wraps"] else false end else [] end
                 upgrades = if Map.has_key?(button, "upgrades") do button["upgrades"] else [] end
                 check_cnf_condition(state, button["show_when"], %{seat: seat, call_name: name, calls_spec: calls_spec, upgrade_name: upgrades, call_wraps: call_wraps})
               end)
            |> Enum.map(fn {name, _button} -> name end)
          unskippable_button_exists = Enum.any?(buttons, fn button_name -> Map.has_key?(state.rules["buttons"][button_name], "unskippable") && state.rules["buttons"][button_name]["unskippable"] end)
          {seat, if not Enum.empty?(buttons) && not unskippable_button_exists do buttons ++ ["skip"] else buttons end}
        end
      end)
      # IO.puts("Updating buttons after action #{action}: #{inspect(new_buttons)}")
      update_all_players(state, fn seat, player -> %Player{ player | buttons: new_buttons[seat] } end)
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
    superceded_choices = Actions.get_superceded_choices(state)
    Enum.all?(state.players, fn {_seat, player} ->
      Enum.all?(player.buttons, fn name -> Enum.member?(superceded_choices, name) end)
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
