defmodule RiichiAdvanced.GameSupervisorTest do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.Utils, as: Utils

  setup do
    session_id = Ecto.UUID.generate()
    ruleset = "riichi"
    mods = []
    config = nil
    game_spec = {RiichiAdvanced.GameSupervisor, session_id: session_id, ruleset: ruleset, mods: mods, config: config, name: {:via, Registry, {:game_registry, Utils.to_registry_name("game", ruleset, session_id)}}}
    {:ok, _pid} = DynamicSupervisor.start_child(RiichiAdvanced.GameSessionSupervisor, game_spec)
    {:ok, %{session_id: session_id, ruleset: ruleset}}
  end

  test "ensure GameSupervisor starts correctly", %{session_id: session_id, ruleset: ruleset} do
    [{pid, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("game", ruleset, session_id))
    assert Process.alive?(pid)
  end

  test "can't start a duplicate session_id GameSupervisor", %{session_id: session_id, ruleset: ruleset} do
    game_spec = {RiichiAdvanced.GameSupervisor, session_id: session_id, ruleset: ruleset, mods: [], config: nil, name: {:via, Registry, {:game_registry, Utils.to_registry_name("game", ruleset, session_id)}}}
    {:error, {:already_started, _pid}} = DynamicSupervisor.start_child(RiichiAdvanced.GameSessionSupervisor, game_spec)
  end

end
