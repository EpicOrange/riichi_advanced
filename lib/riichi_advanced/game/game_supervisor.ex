defmodule RiichiAdvanced.GameSupervisor do
  alias RiichiAdvanced.Utils, as: Utils
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, opts)
  end

  def init(opts) do
    session_id = Keyword.get(opts, :session_id)
    ruleset = Keyword.get(opts, :ruleset)
    mods = Keyword.get(opts, :mods, [])
    config = Keyword.get(opts, :config, nil)
    children = [
      {Mutex, name: {:via, Registry, {:game_registry, Utils.to_registry_name("mutex", ruleset, session_id)}}},
      {RiichiAdvanced.AISupervisor, name: {:via, Registry, {:game_registry, Utils.to_registry_name("ai_supervisor", ruleset, session_id)}}},
      {RiichiAdvanced.Debouncers, name: {:via, Registry, {:game_registry, Utils.to_registry_name("debouncers", ruleset, session_id)}}},
      {RiichiAdvanced.ExitMonitor, name: {:via, Registry, {:game_registry, Utils.to_registry_name("exit_monitor", ruleset, session_id)}}},
      {ExSMT.Solver, name: {:via, Registry, {:game_registry, Utils.to_registry_name("smt_solver", ruleset, session_id)}}, session_id: session_id, ruleset: ruleset},
      {RiichiAdvanced.GameState, name: {:via, Registry, {:game_registry, Utils.to_registry_name("game_state", ruleset, session_id)}}, session_id: session_id, ruleset: ruleset, mods: mods, config: config}
    ]
    Supervisor.init(children, strategy: :one_for_all)
  end
end
