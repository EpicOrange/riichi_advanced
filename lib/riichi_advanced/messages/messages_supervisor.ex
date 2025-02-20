defmodule RiichiAdvanced.MessagesSupervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, opts)
  end

  def init(opts) do
    socket_id = Keyword.get(opts, :socket_id)
    children = [
      {RiichiAdvanced.ExitMonitor, name: RiichiAdvanced.Utils.via_registry("exit_monitor_messages", socket_id)},
      {RiichiAdvanced.MessagesState, name: RiichiAdvanced.Utils.via_registry("messages_state", socket_id), socket_id: socket_id}
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
