defmodule RiichiAdvanced.LogSupervisor do
  alias RiichiAdvanced.Utils, as: Utils
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, opts)
  end

  def init(opts) do
    room_code = Keyword.get(opts, :room_code)
    ruleset = Keyword.get(opts, :ruleset)
    mods = Keyword.get(opts, :mods, [])
    children = [
      {RiichiAdvanced.GameSupervisor, name: {:via, Registry, {:game_registry, Utils.to_registry_name("game", ruleset, room_code)}}, room_code: room_code, ruleset: ruleset, mods: mods},
      Supervisor.child_spec({RiichiAdvanced.GameSupervisor, name: {:via, Registry, {:game_registry, Utils.to_registry_name("game", ruleset, room_code <> "_walker")}}, room_code: room_code <> "_walker", ruleset: ruleset, mods: mods}, id: RiichiAdvanced.GameSupervisor.Walker),
      {RiichiAdvanced.LogWalker, name: {:via, Registry, {:game_registry, Utils.to_registry_name("log_walker", ruleset, room_code)}}, room_code: room_code, ruleset: ruleset},
      {RiichiAdvanced.LogControlState, name: {:via, Registry, {:game_registry, Utils.to_registry_name("log_control_state", ruleset, room_code)}}, room_code: room_code, ruleset: ruleset},
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
