defmodule RiichiAdvanced.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    LoggerBackends.add(LoggerFileBackend)
    children = [
      {Registry, keys: :unique, name: :game_registry},
      {RiichiAdvanced.Cache, []},
      {RiichiAdvanced.Cache.Memo, []},
      Supervisor.child_spec({RiichiAdvanced.SessionSupervisor, name: RiichiAdvanced.GameSessionSupervisor}, id: :game_session_supervisor),
      Supervisor.child_spec({RiichiAdvanced.SessionSupervisor, name: RiichiAdvanced.LobbySessionSupervisor}, id: :lobby_session_supervisor),
      Supervisor.child_spec({RiichiAdvanced.SessionSupervisor, name: RiichiAdvanced.RoomSessionSupervisor}, id: :room_session_supervisor),
      Supervisor.child_spec({RiichiAdvanced.SessionSupervisor, name: RiichiAdvanced.MessagesSessionSupervisor}, id: :messages_session_supervisor),
      {DNSCluster, query: Application.get_env(:riichi_advanced, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: RiichiAdvanced.PubSub},
      # storage for plug-attack
      {PlugAttack.Storage.Ets, name: RiichiAdvancedWeb.PlugAttack.Storage, clean_period: 60_000},
      # Start to serve requests, typically the last entry
      RiichiAdvancedWeb.Endpoint,
      RiichiAdvanced.Admin
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RiichiAdvanced.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RiichiAdvancedWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
