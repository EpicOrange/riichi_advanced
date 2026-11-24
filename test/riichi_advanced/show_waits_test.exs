defmodule RiichiAdvanced.ShowWaitsTest do
  use ExUnit.Case, async: true

  alias RiichiAdvanced.{GameState, GameSupervisor, LogControlState, RoomState, Utils}
  alias RiichiAdvanced.GameState.Rules
  alias RiichiAdvanced.ModLoader.ModState

  for ruleset <- ["riichi", "sanma"] do
    test "#{ruleset} counts a river tile and a matching newly revealed kan indicator" do
      ruleset = unquote(ruleset)
      {initial, next, rig_index} = if ruleset == "riichi", do: {-6, -8, 6}, else: {-10, -12, 10}
      dead_wall = List.replace_at(~w(5s 7s 6p 7p 4z 2p 3p 5p 4s 6z 1s), rig_index, "9p")
      other_hand = ~w(1m 9m 1p 4p 8p 1s 3s 6s 8s 9s 2z 3z 5z)

      hands = %{
        "east" => ~w(7z 7z 7z 4s 5s 6s 2p 3p 4p 7p 8p 6z 6z),
        "south" => ~w(2s 2s 2s 4p 8p 1s 3s 6s 8s 9s 2z 3z 5z),
        "west" => other_hand
      }

      hands = if ruleset == "riichi", do: Map.put(hands, "north", other_hand), else: hands

      config =
        Jason.encode!(%{
          "starting_hand" => hands,
          "starting_draws" => ~w(9p 2s),
          "starting_dead_wall" => dead_wall
        })

      game = start_default_game(ruleset, config)
      state = GenServer.call(game, :get_state)

      GenServer.cast(game, {:play_tile, :east, length(state.players.east.hand)})
      state = GenServer.call(game, :get_state)
      LogControlState.skip_buttons(%{game_state_pid: game, game_state: state}, state.turn)

      state = GenServer.call(game, :get_state)
      assert state.revealed_tiles == [initial]
      assert Utils.strip_attrs(state.players.east.pond) == [:"9p"]
      assert unseen_nines(state) == 3
      assert "ankan" in state.players.south.buttons

      GenServer.cast(game, {:press_button, :south, "ankan"})

      if GenServer.call(game, :get_state).players.south.call_buttons != %{} do
        GenServer.cast(game, {:press_first_call_button, :south, "ankan"})
      end

      state = GenServer.call(game, :get_state)
      assert state.revealed_tiles == [initial, next]
      assert List.last(GameState.get_revealed_tiles(state)) == :"9p"
      assert unseen_nines(state) == 2
    end
  end

  defp start_default_game(ruleset, config) do
    base = ModState.load_ruleset(ruleset) |> ModState.extract_json() |> Jason.decode!()
    {mods, _} = Rules.parse_available_mods(base["available_mods"], base["default_mods"])
    room = Ecto.UUID.generate()

    start_supervised!(
      {GameSupervisor,
       room_code: room,
       ruleset: ruleset,
       mods: RoomState.get_enabled_mods(%{mods: mods}),
       config: config,
       init_actions: [
         ["set_log_loading_mode", true],
         ["set_log_seeking_mode", true],
         ["initialize_game"]
       ],
       name: Utils.via_registry("game", ruleset, room)}
    )

    [{game, _}] = Utils.registry_lookup("game_state", ruleset, room)
    game
  end

  defp unseen_nines(state) do
    Enum.find_value(GameState.get_visible_waits(state, :east, nil), fn {wait, count, _} ->
      if Utils.strip_attrs(wait) == :"9p", do: count
    end)
  end
end
