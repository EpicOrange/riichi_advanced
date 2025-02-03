defmodule RiichiAdvanced.GameSupervisor do
  alias RiichiAdvanced.Utils, as: Utils
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, opts)
  end

  def init(opts) do
    room_code = Keyword.get(opts, :room_code)
    ruleset = Keyword.get(opts, :ruleset)
    mods = Keyword.get(opts, :mods, [])
    config = Keyword.get(opts, :config, nil)
    reserved_seats = Keyword.get(opts, :reserved_seats, %{})
    children = [
      {Mutex, name: {:via, Registry, {:game_registry, Utils.to_registry_name("mutex", ruleset, room_code)}}},
      {RiichiAdvanced.AISupervisor, name: {:via, Registry, {:game_registry, Utils.to_registry_name("ai_supervisor", ruleset, room_code)}}},
      {RiichiAdvanced.Debouncers, name: {:via, Registry, {:game_registry, Utils.to_registry_name("debouncers", ruleset, room_code)}}},
      {RiichiAdvanced.ExitMonitor, name: {:via, Registry, {:game_registry, Utils.to_registry_name("exit_monitor", ruleset, room_code)}}},
      {ExSMT.Solver, name: {:via, Registry, {:game_registry, Utils.to_registry_name("smt_solver", ruleset, room_code)}}, room_code: room_code, ruleset: ruleset},
      {RiichiAdvanced.GameState, name: {:via, Registry, {:game_registry, Utils.to_registry_name("game_state", ruleset, room_code)}}, room_code: room_code, ruleset: ruleset, mods: mods, config: config, reserved_seats: reserved_seats}
    ]
    Supervisor.init(children, strategy: :one_for_all)
  end
end
