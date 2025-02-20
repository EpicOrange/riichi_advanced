defmodule RiichiAdvanced.LobbySupervisor do
  alias RiichiAdvanced.Utils, as: Utils
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, opts)
  end

  def init(opts) do
    ruleset = Keyword.get(opts, :ruleset)
    children = [
      {RiichiAdvanced.ExitMonitor, name: Utils.via_registry("exit_monitor_lobby", ruleset, "")},
      {RiichiAdvanced.LobbyState, name: Utils.via_registry("lobby_state", ruleset, ""), ruleset: ruleset}
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
