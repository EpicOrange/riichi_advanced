defmodule RiichiAdvanced.LogSupervisor do
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
    init_actions = Keyword.get(opts, :init_actions, [])
    log_id = Keyword.get(opts, :log_id, "")
    children = [
      {RiichiAdvanced.GameSupervisor, name: {:via, Registry, {:game_registry, Utils.to_registry_name("game", ruleset, room_code)}}, supervisor: self(), room_code: room_code, ruleset: ruleset, mods: mods, config: config, init_actions: init_actions},
      Supervisor.child_spec({RiichiAdvanced.GameSupervisor, name: {:via, Registry, {:game_registry, Utils.to_registry_name("game", ruleset, room_code <> "_walker")}}, supervisor: self(), room_code: room_code <> "_walker", ruleset: ruleset, mods: mods}, id: RiichiAdvanced.GameSupervisor.Walker),
      {RiichiAdvanced.LogWalker, name: {:via, Registry, {:game_registry, Utils.to_registry_name("log_walker", ruleset, room_code)}}, room_code: room_code, ruleset: ruleset},
      {RiichiAdvanced.LogControlState, name: {:via, Registry, {:game_registry, Utils.to_registry_name("log_control_state", ruleset, room_code)}}, room_code: room_code, ruleset: ruleset, log_id: log_id},
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
