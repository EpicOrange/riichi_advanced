defmodule RiichiAdvanced.RoomSupervisor do
  alias RiichiAdvanced.Utils, as: Utils
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, opts)
  end

  def init(opts) do
    room_code = Keyword.get(opts, :room_code)
    ruleset = Keyword.get(opts, :ruleset)
    children = [
      {RiichiAdvanced.ExitMonitor, name: {:via, Registry, {:game_registry, Utils.to_registry_name("exit_monitor_room", ruleset, room_code)}}},
      {RiichiAdvanced.RoomState, name: {:via, Registry, {:game_registry, Utils.to_registry_name("room_state", ruleset, room_code)}}, room_code: room_code, ruleset: ruleset}
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
