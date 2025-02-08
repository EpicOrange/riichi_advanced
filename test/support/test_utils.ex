defmodule RiichiAdvanced.TestUtils do
  alias RiichiAdvanced.GameState.Conditions, as: Conditions
  alias RiichiAdvanced.GameState.Scoring, as: Scoring
  alias RiichiAdvanced.Utils, as: Utils
  import ExUnit.Assertions

  def initialize_game_state(ruleset, mods, config \\ nil) do
    room_code = Ecto.UUID.generate()
    game_spec = {RiichiAdvanced.GameSupervisor, room_code: room_code, ruleset: ruleset, mods: mods, config: config, name: {:via, Registry, {:game_registry, Utils.to_registry_name("game", ruleset, room_code)}}}
    {:ok, _pid} = DynamicSupervisor.start_child(RiichiAdvanced.GameSessionSupervisor, game_spec)
    [{game_state, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("game_state", ruleset, room_code))

    # suppress all IO from game_state
    {:ok, io} = StringIO.open("")
    Process.group_leader(game_state, io)

    # activate game
    GenServer.call(game_state, {:put_log_loading_mode, true})
    GenServer.call(game_state, {:put_log_seeking_mode, true})
    GenServer.cast(game_state, {:initialize_game, nil})
    GenServer.call(game_state, :get_state)
  end

  def test_yaku(ruleset, mods, test_spec) do
    state = initialize_game_state(ruleset, mods)
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

end
