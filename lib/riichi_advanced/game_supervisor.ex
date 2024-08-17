defmodule RiichiAdvanced.GameSupervisor do
  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      {Registry, keys: :unique, name: RiichiAdvanced.Registry},
      {Mutex, name: {:via, Registry, {RiichiAdvanced.Registry, :mutex}}},
      {RiichiAdvanced.AISupervisor, name: {:via, Registry, {RiichiAdvanced.Registry, :ai_supervisor}}},
      {RiichiAdvanced.Debouncers, name: {:via, Registry, {RiichiAdvanced.Registry, :debouncers}}},
      {RiichiAdvanced.ExitMonitor, name: {:via, Registry, {RiichiAdvanced.Registry, :exit_monitor}}},
      {RiichiAdvanced.GameState, name: {:via, Registry, {RiichiAdvanced.Registry, :game_state}}},
      RiichiAdvanced.ETSCache,
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
