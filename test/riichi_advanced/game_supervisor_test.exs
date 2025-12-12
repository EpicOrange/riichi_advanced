defmodule RiichiAdvanced.GameSupervisorTest do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.Utils, as: Utils

  setup do
    room_code = Ecto.UUID.generate()
    ruleset = "riichi"
    mods = []
    config = nil
    game_spec = {RiichiAdvanced.GameSupervisor, room_code: room_code, ruleset: ruleset, mods: mods, config: config, name: Utils.via_registry("game", ruleset, room_code), restart: :temporary}
    {:ok, _pid} = DynamicSupervisor.start_child(RiichiAdvanced.GameSessionSupervisor, game_spec)
    {:ok, %{room_code: room_code, ruleset: ruleset}}
  end

  test "ensure GameSupervisor starts correctly", %{room_code: room_code, ruleset: ruleset} do
    [{pid, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("game", ruleset, room_code))
    assert Process.alive?(pid)
  end

  test "can't start a duplicate room_code GameSupervisor", %{room_code: room_code, ruleset: ruleset} do
    game_spec = {RiichiAdvanced.GameSupervisor, room_code: room_code, ruleset: ruleset, mods: [], config: nil, name: Utils.via_registry("game", ruleset, room_code), restart: :temporary}
    {:error, {:already_started, _pid}} = DynamicSupervisor.start_child(RiichiAdvanced.GameSessionSupervisor, game_spec)
  end

end
