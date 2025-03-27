defmodule RiichiAdvanced.TestUtils do
  alias RiichiAdvanced.LogControlState, as: LogControl
  alias RiichiAdvanced.Utils, as: Utils
  import ExUnit.Assertions

  @suppress_io true
  # @suppress_io false
  @default_riichi_mods [
    "riichi_kan",
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
    {:ok, _game} = DynamicSupervisor.start_child(RiichiAdvanced.GameSessionSupervisor, game_spec)
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
      game_state_pid: game_state,
    }
  end

  def verify_events(events) do
    for {event, i} <- Enum.with_index(events) do
      Map.put(event, "index", i)
    end
  end

  defmacro assert_list(actual, expected) do
    quote do
      assert inspect(unquote(actual), charlists: :as_lists) == inspect(unquote(expected), charlists: :as_lists)
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

    # debug
    # IO.inspect(state.players.east.hand)

    check_winner = fn seat, expected_winner ->
      winner = state.winners[seat]
      expected_winner
      |> Enum.map(fn {k, v} ->
          {expected, actual} = {v, Map.get(winner, k)}
          if k in [:yaku, :yaku2] do
            {k, MapSet.new(expected), MapSet.new(actual)}
          else
            {k, expected, actual}
          end
        end)
      |> Enum.reduce([], fn {k, expected, actual}, acc ->
        if expected == actual do acc else
          [{k, actual, expected} | acc]
        end
      end)
    end

    if expected_winners != :no_winners do
      for {seat, expected_winner} <- expected_winners do
        assert seat in state.winner_seats
        errs = Enum.map(List.wrap(expected_winner), &check_winner.(seat, &1))
        if [] not in errs do
          for tuples <- errs, {k, actual, expected} <- tuples do
            IO.puts("#{k}:\n\n    #{inspect(actual)}\n\nexpected #{k}:\n\n    #{inspect(expected)}")
          end
          assert false
        end
      end
    else
      assert Enum.empty?(state.winner_seats)
      win_buttons = Enum.all?(state.players, fn {seat, player} ->
        {seat, Enum.filter(["ron", "chankan", "tsumo"], & &1 in player.buttons)}
      end)
      expected_win_buttons = Enum.all?(state.players, fn {seat, _player} -> {seat, []} end)
      assert win_buttons == expected_win_buttons
    end

    if Map.has_key?(expected_state, :delta_scores) do
      delta_scores = for seat <- [:east, :south, :west, :north], seat in state.available_seats do
        Map.get(state.delta_scores, seat, 0)
      end
      assert_list(delta_scores, expected_state.delta_scores)
    end

    if Map.has_key?(expected_state, :shuugi) do
      shuugi = for seat <- [:east, :south, :west, :north], seat in state.available_seats do
        Map.get(state.players[seat].counters, "shuugi", 0)
      end
      assert_list(shuugi, expected_state.shuugi)
    end

    if Map.has_key?(expected_state, :scores) do
      cond do
        is_map(expected_state.scores) ->
          {scores, expected_scores} = for seat <- [:east, :south, :west, :north], seat in state.available_seats do
            score = state.players[seat].score
            {score, Map.get(expected_state.scores, seat, score)}
          end
          |> Enum.unzip()
          assert_list(scores, expected_scores)
        is_list(expected_state.scores) ->
          scores = for seat <- [:east, :south, :west, :north], seat in state.available_seats do
            state.players[seat].score
          end
          assert_list(scores, expected_state.scores)
        true ->
          IO.inspect("Invalid score spec #{inspect(expected_state.scores)}")
      end
    end
  end

end
