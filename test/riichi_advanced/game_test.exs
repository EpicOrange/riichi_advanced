defmodule RiichiAdvanced.GameTest do
  use ExUnit.Case, async: true
  # import ExUnit.CaptureIO

  setup do
    session_id = Ecto.UUID.generate()
    ruleset = "riichi"
    mods = []
    config = nil
    game_spec = {RiichiAdvanced.GameSupervisor, session_id: session_id, ruleset: ruleset, mods: mods, config: config, name: {:via, Registry, {:game_registry, Utils.to_registry_name("game", ruleset, session_id)}}}
    {:ok, _pid} = DynamicSupervisor.start_child(RiichiAdvanced.GameSessionSupervisor, game_spec)
    [{game, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("game", ruleset, session_id))
    [{game_state, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("game_state", ruleset, session_id))

    # suppress all IO from game_state
    {:ok, io} = StringIO.open("")
    Process.group_leader(game_state, io)

    # # add a player
    # socket = %{
    #   id: "testplayer",
    #   root_pid: nil,
    #   assigns: %{
    #     nickname: nil
    #   }
    # }
    # # {state, seat, spectator} = GenServer.call(game_state, {:new_player, socket})
    # capture_io(fn ->
    #   _ = GenServer.call(game_state, {:new_player, socket})
    # end)

    # activate game
    GenServer.cast(game_state, {:initialize_game, nil})

    {:ok, %{session_id: session_id, ruleset: ruleset, game: game, game_state: game_state}}
  end

  # we only add tests for bugs that come up repeatedly

  test "no double discarding", %{session_id: _session_id, ruleset: _ruleset, game: _game, game_state: game_state} do
    state = GenServer.call(game_state, :get_state)
    assert state.turn == :east
    GenServer.cast(game_state, {:play_tile, :east, 1})
    skip_buttons(game_state)
    GenServer.cast(game_state, {:play_tile, :east, 0})
    skip_buttons(game_state)

    state = GenServer.call(game_state, :get_state)
    assert state.turn == :south
    GenServer.cast(game_state, {:play_tile, :south, 1})
    skip_buttons(game_state)
    GenServer.cast(game_state, {:play_tile, :south, 0})
    skip_buttons(game_state)

    state = GenServer.call(game_state, :get_state)
    assert state.turn == :west
    GenServer.cast(game_state, {:play_tile, :west, 1})
    skip_buttons(game_state)
    GenServer.cast(game_state, {:play_tile, :west, 0})
    skip_buttons(game_state)

    state = GenServer.call(game_state, :get_state)
    assert state.turn == :north
    GenServer.cast(game_state, {:play_tile, :north, 1})
    skip_buttons(game_state)
    GenServer.cast(game_state, {:play_tile, :north, 0})
    skip_buttons(game_state)

    # need to wait for east's 100ms debounce
    Process.sleep(150)

    state = GenServer.call(game_state, :get_state)
    assert state.turn == :east
    GenServer.cast(game_state, {:play_tile, :east, 1})
    skip_buttons(game_state)
    GenServer.cast(game_state, {:play_tile, :east, 0})
    skip_buttons(game_state)

    state = GenServer.call(game_state, :get_state)
    assert state.turn == :south
    assert length(state.players.east.pond) == 2
    assert length(state.players.south.pond) == 1
    assert length(state.players.west.pond) == 1
    assert length(state.players.north.pond) == 1
  end

  def skip_buttons(game_state) do
    GenServer.cast(game_state, {:press_button, :east, "skip"})
    GenServer.cast(game_state, {:press_button, :south, "skip"})
    GenServer.cast(game_state, {:press_button, :west, "skip"})
    GenServer.cast(game_state, {:press_button, :north, "skip"})
  end

end
