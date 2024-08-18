defmodule RiichiAdvanced.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      RiichiAdvancedWeb.Telemetry,
      RiichiAdvanced.Repo,
      {Registry, keys: :unique, name: :game_registry},
      RiichiAdvanced.ETSCache,
      {RiichiAdvanced.GameSessionSupervisor, name: RiichiAdvanced.GameSessionSupervisor},
      {DNSCluster, query: Application.get_env(:riichi_advanced, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: RiichiAdvanced.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: RiichiAdvanced.Finch},
      # Start a worker by calling: RiichiAdvanced.Worker.start_link(arg)
      # {RiichiAdvanced.Worker, arg},
      # Start to serve requests, typically the last entry
      RiichiAdvancedWeb.Endpoint
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
