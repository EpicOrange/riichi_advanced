defmodule RiichiAdvanced.GameTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

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

    # add a player
    socket = %{
      id: "testplayer",
      root_pid: nil,
      assigns: %{
        nickname: nil
      }
    }
    # {state, seat, spectator} = GenServer.call(game_state, {:new_player, socket})
    capture_io(fn ->
      _ = GenServer.call(game_state, {:new_player, socket})
    end)

    {:ok, %{session_id: session_id, ruleset: ruleset, game: game, game_state: game_state}}
  end

  test "todo", %{session_id: _session_id, ruleset: _ruleset, game: _game, game_state: _game_state} do
    :ok
  end

end
