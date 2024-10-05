defmodule RiichiAdvanced.LobbySupervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, opts)
  end

  def init(opts) do
    ruleset = Keyword.get(opts, :ruleset)
    children = [
      {RiichiAdvanced.ExitMonitor, name: {:via, Registry, {:game_registry, Utils.to_registry_name("exit_monitor_lobby", ruleset, "")}}},
      {RiichiAdvanced.LobbyState, name: {:via, Registry, {:game_registry, Utils.to_registry_name("lobby_state", ruleset, "")}}, ruleset: ruleset}
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
