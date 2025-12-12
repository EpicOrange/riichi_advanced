defmodule RiichiAdvanced.TestUtils do
  alias RiichiAdvanced.GameState.American, as: American
  alias RiichiAdvanced.GameState.Rules, as: Rules
  alias RiichiAdvanced.GameState.TileBehavior, as: TileBehavior
  alias RiichiAdvanced.Match, as: Match
  alias RiichiAdvanced.ModLoader, as: ModLoader
  alias RiichiAdvanced.LogControlState, as: LogControl
  alias RiichiAdvanced.Utils, as: Utils
  import ExUnit.Assertions

  @suppress_io true
  # @suppress_io false

  def initialize_test_state(ruleset, mods, config \\ nil) do
    room_code = Ecto.UUID.generate()
    args = [room_code: room_code, ruleset: ruleset, mods: mods, config: config, name: Utils.via_registry("game", ruleset, room_code)]
    game_spec = Supervisor.child_spec(%{
      id: {RiichiAdvanced.GameSupervisor, ruleset, room_code},
      start: {RiichiAdvanced.GameSupervisor, :start_link, [args]}
    }, restart: :temporary)
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
    GenServer.cast(test_state.game_state_pid, :terminate_game)

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

    case expected_winners do
      :no_winners -> 
        assert Enum.empty?(state.winner_seats)
        win_buttons = Enum.all?(state.players, fn {seat, player} ->
          {seat, Enum.filter(["ron", "chankan", "tsumo", "flower_win"], & &1 in player.buttons)}
        end)
        expected_win_buttons = Enum.all?(state.players, fn {seat, _player} -> {seat, []} end)
        assert win_buttons == expected_win_buttons
      :no_buttons ->
        buttons = Map.new(state.players, fn {seat, player} -> {seat, player.buttons} end)
        # RiichiAdvanced.LogControlState.print_game_state(%{game_state: state})
        assert Enum.all?(buttons, fn {_seat, buttons} -> Enum.empty?(buttons) end)
      _ ->
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

  def get_rules!(ruleset, mods) do
    assert {:ok, rules_ref} = ModLoader.get_ruleset_json(ruleset)
    |> ModLoader.strip_comments()
    |> ModLoader.apply_mods(mods, ruleset)
    |> Rules.load_rules(ruleset)
    rules_ref
  end

  def interpret_hand(hand) when is_list(hand), do: Enum.map(hand, &Utils.to_tile/1)
  def interpret_hand(hand) when is_binary(hand) do
    case String.split(hand, " ", trim: true) do
      [hand_spec] -> for [_, nums, suit] <- Regex.scan(~r/(\d+)([a-zA-Z])/, hand_spec), num <- String.graphemes(nums), do: "#{num}#{suit}"
      hand -> hand
    end
    |> interpret_hand()
  end
  defp interpret_call(call) do
    with [call_name, call] <- String.split(call, ":", trim: true) do
      {call_name, interpret_hand(call)}
    end
  end
  defp interpret_calls(calls) when is_list(calls), do: Enum.map(calls, &interpret_call/1)
  defp interpret_calls(calls) when is_binary(calls), do: interpret_calls(String.split(calls, " ", trim: true))
  defp test_generic(ruleset, mods, test_spec) do
    hand = interpret_hand(Keyword.get(test_spec, :hand, []))
    {hand, winning_tile} = Enum.split(hand, -1)
    rules_ref = get_rules!(ruleset, mods)
    wall = Rules.get(rules_ref, "wall", [])
    unused = wall -- hand
    non_furiten_tile = if winning_tile == :"1z" do :"2z" else :"1z" end
    starting_draws = Enum.take(unused, 3) ++ [non_furiten_tile] ++ Enum.take(unused, 2) ++ [winning_tile, winning_tile]
    config = """
    {
      "starting_hand": {
        "east": [],
        "south": [],
        "west": [],
        "north": #{Jason.encode!(hand)}
      },
      "starting_draws": #{Jason.encode!(starting_draws)}
    }
    """
    events = Keyword.get(test_spec, :pre_events, []) ++ [
      %{"type" => "discard", "tile" => Enum.at(starting_draws, 0), "player" => 0, "tsumogiri" => true},
        %{"type" => "discard", "tile" => Enum.at(starting_draws, 1), "player" => 1, "tsumogiri" => true},
        %{"type" => "discard", "tile" => Enum.at(starting_draws, 2), "player" => 2, "tsumogiri" => true},
        %{"type" => "discard", "tile" => Enum.at(starting_draws, 3), "player" => 3, "tsumogiri" => true},
        %{"type" => "discard", "tile" => Enum.at(starting_draws, 4), "player" => 0, "tsumogiri" => true},
        %{"type" => "discard", "tile" => Enum.at(starting_draws, 5), "player" => 1, "tsumogiri" => true},
        %{"type" => "discard", "tile" => Enum.at(starting_draws, 6), "player" => 2, "tsumogiri" => true},
    ] ++ Keyword.get(test_spec, :post_events, [])
    outcome = Keyword.get(test_spec, :outcome, :no_winners)
    test_yaku_advanced(ruleset, mods, config, events, outcome)
  end

  # usage:
  # TestUtils.test_win(ruleset, mods,
  #   hand: ["2m", "2m", "2p", "2p", "2p", "2p", "2s", "2s", "2s", "2s", "7z", "7z", "7z", "7z"],
  #   win_button: "ron",
  #   yaku: [],
  #   yaku2: []
  # )
  def test_win(ruleset, mods, test_spec) do
    win_button = Keyword.get(test_spec, :win_button, "ron")
    outcome = %{
      north: %{
        yaku: Keyword.get(test_spec, :yaku, []),
        yaku2: Keyword.get(test_spec, :yaku2, [])
      }
    }
    post_events = [
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => win_button}]}
    ]
    test_spec = Keyword.put(test_spec, :outcome, outcome)
    test_spec = Keyword.put(test_spec, :post_events, post_events)
    test_generic(ruleset, mods, test_spec)
  end

  # usage:
  # TestUtils.test_no_win(ruleset, mods,
  #   hand: ["2m", "2m", "2p", "2p", "2p", "2p", "2s", "2s", "2s", "2s", "7z", "7z", "7z", "2z"],
  # )
  def test_no_win(ruleset, mods, test_spec) do
    test_spec = Keyword.put(test_spec, :outcome, :no_winners)
    test_generic(ruleset, mods, test_spec)
  end

  defp match_hand(rules_ref, match_definition_name, hand, calls, tile_aliases) do
    hand = interpret_hand(hand)
    calls = interpret_calls(calls)
    {am_win_definitions, win_definitions} = Enum.split_with(Rules.get(rules_ref, match_definition_name <> "_definition"), &is_binary/1)
    translated_win_definitions = Rules.translate_sets_in_match_definitions(win_definitions, Rules.get(rules_ref, "set_definitions"))
    translated_am_win_definitions = American.translate_american_match_definitions(am_win_definitions)
    win_definitions = translated_win_definitions ++ translated_am_win_definitions
    tile_behavior = %TileBehavior{ aliases: tile_aliases, tile_freqs: Enum.frequencies(Rules.get(rules_ref, "wall")) }
    Match.match_hand(hand, calls, win_definitions, tile_behavior)
  end
  def assert_winning_hand(rules_ref, match_definition_name, hand, calls \\ [], tile_aliases \\ %{}) do
    assert match_hand(rules_ref, match_definition_name, hand, calls, tile_aliases), "Not a winning hand: #{to_string(hand)} #{to_string(calls)}"
  end
  def refute_winning_hand(rules_ref, match_definition_name, hand, calls \\ [], tile_aliases \\ %{}) do
    refute match_hand(rules_ref, match_definition_name, hand, calls, tile_aliases), "Shouldn't be a winning hand: #{to_string(hand)} #{to_string(calls)}"
  end
end
