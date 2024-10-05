defmodule RiichiAdvanced.RoomSupervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, opts)
  end

  def init(opts) do
    session_id = Keyword.get(opts, :session_id)
    ruleset = Keyword.get(opts, :ruleset)
    children = [
      {RiichiAdvanced.ExitMonitor, name: {:via, Registry, {:game_registry, Utils.to_registry_name("exit_monitor_room", ruleset, session_id)}}},
      {RiichiAdvanced.RoomState, name: {:via, Registry, {:game_registry, Utils.to_registry_name("room_state", ruleset, session_id)}}, session_id: session_id, ruleset: ruleset}
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
