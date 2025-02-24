defmodule RiichiAdvanced.TestUtils do
  alias RiichiAdvanced.GameState.Conditions, as: Conditions
  alias RiichiAdvanced.GameState.Scoring, as: Scoring
  alias RiichiAdvanced.LogControlState, as: LogControl
  alias RiichiAdvanced.Utils, as: Utils
  import ExUnit.Assertions

  @suppress_io true
  @default_riichi_mods [
    "kan",
    %{name: "honba", config: %{"value" => 100}},
    %{name: "yaku/riichi", config: %{"bet" => 1000, "drawless" => false}},
    %{name: "nagashi", config: %{"is" => "Mangan"}},
    %{name: "tobi", config: %{"below" => 0}},
    %{
     name: "uma",
     config: %{"_1st" => 10, "_2nd" => 5, "_3rd" => -5, "_4th" => -10}
    },
    "agarirenchan",
    "tenpairenchan",
    "kuikae_nashi",
    "double_wind_4_fu",
    "pao",
    "kokushi_chankan",
    "suufon_renda",
    "suucha_riichi",
    "suukaikan",
    "kyuushu_kyuuhai",
    %{name: "dora", config: %{"start_indicators" => 1}},
    "ura",
    "kandora",
    "yaku/ippatsu",
    %{name: "yaku/renhou", config: %{"is" => "Yakuman"}},
    "show_waits",
    %{name: "min_han", config: %{"min" => 1}},
    %{name: "aka", config: %{"man" => 1, "pin" => 1, "sou" => 1}}
  ]

  def default_riichi_mods, do: @default_riichi_mods

  def initialize_test_state(ruleset, mods, config \\ nil) do
    room_code = Ecto.UUID.generate()
    game_spec = {RiichiAdvanced.GameSupervisor, room_code: room_code, ruleset: ruleset, mods: mods, config: config, name: Utils.via_registry("game", ruleset, room_code)}
    {:ok, game} = DynamicSupervisor.start_child(RiichiAdvanced.GameSessionSupervisor, game_spec)
    [{game_state, _}] = Utils.registry_lookup("game_state", ruleset, room_code)

    # suppress all IO from game_state
    if @suppress_io do
      {:ok, io} = StringIO.open("")
      Process.group_leader(game_state, io)
    end

    # activate game
    GenServer.call(game_state, {:put_log_loading_mode, true})
    GenServer.call(game_state, {:put_log_seeking_mode, true})
    GenServer.cast(game_state, {:initialize_game, nil})
    %LogControl.LogControl{
      ruleset: ruleset,
      room_code: room_code,
      supervisor: game,
      game_state_pid: game_state,
    }
  end

  def generate_winner(ruleset, mods, config, test_spec) do
    test_state = initialize_test_state(ruleset, mods, config)
    state = GenServer.call(test_state.game_state_pid, :get_state)

    seat = Map.get(test_spec, :seat, :east)
    hand = test_spec.hand
    draw = test_spec.draw
    calls = Map.get(test_spec, :calls, [])
    state = put_in(state.players[seat].hand, hand)
    state = put_in(state.players[seat].draw, draw)
    state = put_in(state.players[seat].calls, calls)
    state = put_in(state.kyoku, Map.get(test_spec, :round, 0))
    state = put_in(state.honba, Map.get(test_spec, :honba, 0))
    state = put_in(state.players[seat].status, Map.get(test_spec, :status, state.players[seat].status) |> MapSet.new())
    state = for condition <- Map.get(test_spec, :conditions, []), reduce: state do
      state -> case condition do
        "make_discards_exist" ->
          state = RiichiAdvanced.GameState.update_action(state, seat, :discard, %{tile: :"1x"}) 
          update_in(state.players[seat].status, &MapSet.delete(&1, "discards_empty"))
        "no_draws_remaining"  -> Map.put(state, :wall_index, length(state.wall))
        _ ->
          GenServer.cast(self(), {:show_error, "Unknown test condition #{inspect(condition)}"})
          state
      end
    end

    Scoring.calculate_winner_details(state, seat, [test_spec.winning_tile], test_spec.win_source)
  end
    
  def test_yaku(ruleset, mods, test_spec) do
    test_state = initialize_test_state(ruleset, mods)
    state = GenServer.call(test_state.game_state_pid, :get_state)
    yaku_list_names = Map.get(test_spec, :yaku_lists, Conditions.get_yaku_lists(state))

    seat = Map.get(test_spec, :seat, :east)
    hand = test_spec.hand
    calls = Map.get(test_spec, :calls, [])
    state = put_in(state.players[seat].hand, hand)
    state = put_in(state.players[seat].calls, calls)
    state = put_in(state.kyoku, Map.get(test_spec, :round, 0))
    state = put_in(state.honba, Map.get(test_spec, :honba, 0))
    state = put_in(state.players[seat].status, Map.get(test_spec, :status, state.players[seat].status) |> MapSet.new())
    state = for condition <- Map.get(test_spec, :conditions, []), reduce: state do
      state -> case condition do
        "make_discards_exist" ->
          state = RiichiAdvanced.GameState.update_action(state, seat, :discard, %{tile: :"1x"}) 
          update_in(state.players[seat].status, &MapSet.delete(&1, "discards_empty"))
        "no_draws_remaining"  -> Map.put(state, :wall_index, length(state.wall))
        _ ->
          GenServer.cast(self(), {:show_error, "Unknown test condition #{inspect(condition)}"})
          state
      end
    end
    {yaku, fu, _winning_tile} = Scoring.get_best_yaku_from_lists(state, yaku_list_names, seat, [test_spec.winning_tile], test_spec.win_source)

    assert MapSet.new(yaku) == MapSet.new(test_spec.expected_yaku)
    assert fu == Map.get(test_spec, :expected_minipoints, fu)
  end

  def verify_events(events) do
    for {event, i} <- Enum.with_index(events) do
      Map.put(event, "index", i)
    end
  end

  def test_yaku_advanced(ruleset, mods, config, events, expected_winners \\ %{}, expected_state \\ %{}) do
    test_state = initialize_test_state(ruleset, mods, config)
    GenServer.cast(test_state.game_state_pid, :sort_hands)

    test_state = for event <- verify_events(events), reduce: test_state do
      test_state -> case event["type"] do
        "discard"         -> LogControl.send_discard(test_state, true, event)
        "buttons_pressed" -> LogControl.send_button_press(test_state, true, event)
        "mark"            -> LogControl.send_mark(test_state, true, event)
        _                 -> test_state
      end
    end

    state = GenServer.call(test_state.game_state_pid, :get_state)

    for {seat, expected_winner} <- expected_winners do
      assert seat in state.winner_seats
      winner = state.winners[seat]
      if Map.has_key?(expected_winner, :yaku) do
        assert MapSet.new(winner.yaku) == MapSet.new(expected_winner.yaku)
      end
      if Map.has_key?(expected_winner, :yaku2) do
        assert MapSet.new(winner.yaku2) == MapSet.new(expected_winner.yaku2)
      end
      for {key, value} <- expected_winner, key not in [:yaku, :yaku2] do
        assert Map.get(winner, key) == value
      end
    end

    if Map.has_key?(expected_state, :delta_scores) do
      delta_scores = for seat <- [:east, :south, :west, :north], seat in state.available_seats do
        Map.get(state.delta_scores, seat, 0)
      end
      assert delta_scores == expected_state.delta_scores
    end
  end

end
