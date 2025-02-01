defmodule RiichiAdvanced.LogSupervisor do
  alias RiichiAdvanced.Utils, as: Utils
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, opts)
  end

  def init(opts) do
    session_id = Keyword.get(opts, :session_id)
    ruleset = Keyword.get(opts, :ruleset)
    mods = Keyword.get(opts, :mods, [])
    children = [
      {RiichiAdvanced.GameSupervisor, name: {:via, Registry, {:game_registry, Utils.to_registry_name("game", ruleset, session_id)}}, session_id: session_id, ruleset: ruleset, mods: mods},
      Supervisor.child_spec({RiichiAdvanced.GameSupervisor, name: {:via, Registry, {:game_registry, Utils.to_registry_name("game", ruleset, session_id <> "_walker")}}, session_id: session_id <> "_walker", ruleset: ruleset, mods: mods}, id: RiichiAdvanced.GameSupervisor.Walker),
      {RiichiAdvanced.LogWalker, name: {:via, Registry, {:game_registry, Utils.to_registry_name("log_walker", ruleset, session_id)}}, session_id: session_id, ruleset: ruleset},
      {RiichiAdvanced.LogControlState, name: {:via, Registry, {:game_registry, Utils.to_registry_name("log_control_state", ruleset, session_id)}}, session_id: session_id, ruleset: ruleset},
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
