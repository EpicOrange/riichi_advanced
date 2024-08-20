defmodule RiichiAdvanced.GameSupervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, opts)
  end

  def init(opts) do
    session_id = Keyword.get(opts, :session_id)
    ruleset = Keyword.get(opts, :ruleset)
    ruleset_json = Keyword.get(opts, :ruleset_json)
    children = [
      {Mutex, name: {:via, Registry, {:game_registry, "mutex-" <> session_id}}},
      {RiichiAdvanced.AISupervisor, name: {:via, Registry, {:game_registry, "ai_supervisor-" <> session_id}}},
      {RiichiAdvanced.Debouncers, name: {:via, Registry, {:game_registry, "debouncers-" <> session_id}}},
      {RiichiAdvanced.ExitMonitor, name: {:via, Registry, {:game_registry, "exit_monitor-" <> session_id}}},
      {RiichiAdvanced.GameState, name: {:via, Registry, {:game_registry, "game_state-" <> session_id}}, session_id: session_id, ruleset: ruleset, ruleset_json: ruleset_json}
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
