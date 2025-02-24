defmodule RiichiAdvanced.GameSupervisor do
  alias RiichiAdvanced.Utils, as: Utils
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, opts)
  end

  def init(opts) do
    supervisor = Keyword.get(opts, :supervisor, self())
    room_code = Keyword.get(opts, :room_code)
    ruleset = Keyword.get(opts, :ruleset)
    mods = Keyword.get(opts, :mods, [])
    config = Keyword.get(opts, :config, nil)
    private = Keyword.get(opts, :private, true)
    reserved_seats = Keyword.get(opts, :reserved_seats, %{})
    init_actions = Keyword.get(opts, :init_actions, [])
    children = [
      {Mutex, name: Utils.via_registry("mutex", ruleset, room_code)},
      {RiichiAdvanced.AISupervisor, name: Utils.via_registry("ai_supervisor", ruleset, room_code)},
      {RiichiAdvanced.Debouncers, name: Utils.via_registry("debouncers", ruleset, room_code)},
      {RiichiAdvanced.ExitMonitor, name: Utils.via_registry("exit_monitor", ruleset, room_code)},
      {ExSMT.Solver, name: Utils.via_registry("smt_solver", ruleset, room_code), room_code: room_code, ruleset: ruleset},
      {RiichiAdvanced.GameState, name: Utils.via_registry("game_state", ruleset, room_code), supervisor: supervisor, room_code: room_code, ruleset: ruleset, mods: mods, config: config, private: private, reserved_seats: reserved_seats, init_actions: init_actions}
    ]
    Supervisor.init(children, strategy: :one_for_all)
  end
end
