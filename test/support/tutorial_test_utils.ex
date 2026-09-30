defmodule RiichiAdvanced.TutorialTestUtils do
  alias RiichiAdvanced.GameState.Debug
  alias RiichiAdvanced.GameState.Log
  alias RiichiAdvanced.LogControlState, as: LogControl
  alias RiichiAdvanced.TestUtils
  alias RiichiAdvancedWeb.GameLive.Tutorial
  import ExUnit.Assertions

  def test_tutorial_sequence(ruleset, sequence_name, seat) do
    # load the tutorial
    sequence = Tutorial.setup_tutorial(sequence_name).sequence
    # initialize a test GameState
    session_id = "test_player"
    mods = Map.get(sequence, "mods", [])
    excluded_mods = Map.get(sequence, "removed_mods", [])
    config = Map.get(sequence, "config", []) |> Map.put("ai_speed", 256) |> Jason.encode!()
    init_actions = [
      ["initialize_tutorial"],
      ["init_player", session_id, Atom.to_string(seat)],
      ["set_log_seeking_mode", true],
      ["initialize_game"]
    ]
    test_state = TestUtils.initialize_test_state(ruleset, mods, excluded_mods, config, init_actions)
    GenServer.cast(test_state.game_state_pid, :sort_hands)

    # run all the events
    scenes = Map.get(sequence, "scenes", %{}) 
    run_sequence_events(test_state, seat, Map.get(scenes, "start", []))
  end

  def run_sequence_events(test_state, seat, events) do
    seat_str = Atom.to_string(seat)
    seat_index = Log.to_seat(seat)
    test_state = for [action_type | opts] = action <- events, action_type == "force_event", reduce: test_state do
      test_state -> 
        if Debug.debug_tutorial() do
          IO.inspect(action, label: "action")
        end
        # wait until the game is ready to receive the forced event
        events = Enum.at(opts, 0, [])
        events = if not is_list(Enum.at(events, 0)) do [events] else events end
        GenServer.call(test_state.game_state_pid, {:force_event, events, false})
        mock_event = case Enum.at(events, 0) do
          ["play_tile", ^seat_str, ix] ->
            log_event = %{"type" => "discard", "ix" => ix, "player" => seat_index}
            fn -> LogControl.send_discard(test_state, true, log_event) end
          ["press_button", ^seat_str, button_name] ->
            buttons = List.duplicate(nil, 4) |> List.replace_at(seat_index, %{"button" => button_name})
            log_event = %{"type" => "buttons_pressed", "buttons" => buttons}
            fn -> LogControl.send_button_press(test_state, true, log_event, true) end
          ["mark", ^seat_str, mark_seat, ix, source] ->
            log_event = %{
              "type" => "mark",
              "player" => seat_index,
              "seat" => mark_seat |> String.to_existing_atom() |> Log.to_seat(),
              "source" => source,
              "ix" => ix
            }
            fn -> LogControl.send_mark(test_state, true, log_event) end
          ["unmark", ^seat_str, mark_seat, ix, source] ->
            log_event = %{
              "type" => "unmark",
              "player" => seat_index,
              "seat" => mark_seat |> String.to_existing_atom() |> Log.to_seat(),
              "source" => source,
              "ix" => ix
            }
            fn -> LogControl.send_unmark(test_state, true, log_event) end
          ["confirm_mark", ^seat_str] ->
            log_event = %{
              "type" => "confirm_mark",
              "player" => seat_index,
            }
            fn -> LogControl.send_confirm_mark(test_state, true, log_event) end
          event -> fn ->
            if Enum.at(event, 1) == seat_str do
              IO.puts("tutorial_test_utils.ex: Unknown tutorial test event #{inspect(event)}")
            end
            test_state
          end
        end
        test_state = repeatedly_mock_event(test_state, mock_event)
        test_state
    end
    # wait for the final event to resolve
    GenServer.call(test_state.game_state_pid, {:force_event, [], false})

    # see the results
    state = GenServer.call(test_state.game_state_pid, :get_state, 300000)
    test_state = Map.put(test_state, :game_state, state)

    if state.winners == %{} do
      LogControl.print_game_state(test_state)
    end
    GenServer.cast(test_state.game_state_pid, :terminate_game)
    refute state.winners == %{}
    if Debug.debug_tutorial() do
      IO.inspect(state.winners)
    end
  end

  def repeatedly_mock_event(test_state, callback, retries \\ 0)
  def repeatedly_mock_event(test_state, _callback, retries) when retries > 50 do
    IO.puts("Warning: tutorial test_state for ruleset #{test_state.ruleset} took more than 5 seconds to run, aborting")
    test_state
  end
  def repeatedly_mock_event(test_state, callback, retries) do
    if rem(retries, 5) == 0 do
      GenServer.call(test_state.game_state_pid, {:put_log_loading_mode, false}) # let ai act
      GenServer.cast(test_state.game_state_pid, :notify_ai)
    end
    forced_events = GenServer.call(test_state.game_state_pid, :get_forced_events)
    if Debug.debug_tutorial() do
      IO.inspect(forced_events, label: "forced_events")
    end
    if Enum.empty?(forced_events) do
      GenServer.call(test_state.game_state_pid, {:put_log_loading_mode, true}) # stop letting ai act
      test_state
    else
      Process.sleep(100)
      callback.()
      repeatedly_mock_event(test_state, callback, retries + 1)
    end
  end

end
