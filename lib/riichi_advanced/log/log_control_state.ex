defmodule LogControl do
  defstruct [
    # params
    ruleset: nil,
    session_id: nil,
    # pids
    supervisor: nil,
    game_state_pid: nil,
    log_walker_pid: nil,
    # state variables
    game_states: %{},
    game_state: nil,
    log: nil,
  ]
  use Accessible
end

defmodule RiichiAdvanced.LogControlState do
  alias RiichiAdvanced.GameState.Log, as: Log
  use GenServer

  def start_link(init_data) do
    IO.puts("Log supervisor PID is #{inspect(self())}")
    GenServer.start_link(
      __MODULE__,
      %{
        session_id: Keyword.get(init_data, :session_id),
        ruleset: Keyword.get(init_data, :ruleset),
      },
      name: Keyword.get(init_data, :name))
  end

  def init(state) do
    IO.puts("Log control state PID is #{inspect(self())}")

    # lookup pids of the other processes we'll be using
    [{supervisor, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("game", state.ruleset, state.session_id))
    [{game_state, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("game_state", state.ruleset, state.session_id))
    [{log_walker, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("log_walker", state.ruleset, state.session_id))

    state = Map.merge(state, %LogControl{
      ruleset: state.ruleset,
      session_id: state.session_id,
      supervisor: supervisor,
      game_state_pid: game_state,
      log_walker_pid: log_walker,
      game_state: %Game{},
    })

    {:ok, state}
  end

  def get_latest_state(state) do
    state.game_state
  end

  def send_discard(state, skip_anim, discard_event) do
    state = Map.put(state, :game_state, GenServer.call(state.game_state_pid, :get_state))
    seat = Log.from_seat(discard_event["player"])
    hand = state.game_state.players[seat].hand
    draw = state.game_state.players[seat].draw
    tile = discard_event["tile"] |> Utils.to_tile()
    # figure out what index was discarded
    ix = if not discard_event["tsumogiri"] do
      Enum.find_index(hand, &Utils.same_tile(&1, tile))
    else
      length(hand) + Enum.find_index(draw, &Utils.same_tile(&1, tile))
    end
    prev_mode = GenServer.call(state.game_state_pid, {:put_log_loading_mode, skip_anim})
    GenServer.cast(state.game_state_pid, {:play_tile, seat, ix})
    # for all possible calls attached to this event
    # have players press skip on them if they weren't actually called
    call = if Map.has_key?(discard_event, "call") do [discard_event["call"]] else [] end
    possible_calls = Map.get(discard_event, "possible_calls", []) -- call
    call_seats = Enum.map(call, &Log.from_seat(&1["player"]))
    possible_call_seats = Enum.map(possible_calls, &Log.from_seat(&1["player"]))
    for seat <- possible_call_seats -- call_seats do
      GenServer.cast(state.game_state_pid, {:press_button, seat, "skip"})
    end
    GenServer.call(state.game_state_pid, {:put_log_loading_mode, prev_mode})
    GenServer.cast(state.game_state_pid, :sort_hands)
    state = Map.put(state, :game_state, GenServer.call(state.game_state_pid, :get_state))
    state
  end

  def send_button_press(state, skip_anim, button_press_event) do
    state = Map.put(state, :game_state, GenServer.call(state.game_state_pid, :get_state))
    seat = Log.from_seat(button_press_event["player"])
    name = button_press_event["name"]
    prev_mode = GenServer.call(state.game_state_pid, {:put_log_loading_mode, skip_anim})
    GenServer.cast(state.game_state_pid, {:press_button, seat, name})
    GenServer.call(state.game_state_pid, {:put_log_loading_mode, prev_mode})
    GenServer.cast(state.game_state_pid, :sort_hands)
    state = Map.put(state, :game_state, GenServer.call(state.game_state_pid, :get_state))
    state
  end

  def handle_call({:send_discard, skip_anim, discard_event}, _from, state) do
    state = send_discard(state, skip_anim, discard_event)
    {:reply, state.game_state, state}
  end

  def handle_call({:send_button_press, skip_anim, button_press_event}, _from, state) do
    state = send_button_press(state, skip_anim, button_press_event)
    {:reply, state.game_state, state}
  end

  def handle_call(:get_game_state, _from, state) do
    {:reply, state.game_state, state}
  end

  # debug only
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end



  def handle_cast({:put_log, log}, state) do
    state = Map.put(state, :log, log)
    {:noreply, state}
  end

  def handle_cast({:seek, kyoku_index, event_index}, state) do
    saved_state = GenServer.call(state.log_walker_pid, {:get_state, kyoku_index, event_index})
    state = Map.put(state, :game_state, GenServer.call(state.game_state_pid, {:put_state, saved_state}))
    {:noreply, state}
  end

  def handle_cast({:start_walk, kyoku_index, gas}, state) do
    state = Map.put(state, :game_state, GenServer.call(state.game_state_pid, :get_state))
    kyoku_log = state.log["kyokus"] |> Enum.at(kyoku_index, nil)
    if kyoku_log != nil and gas > 0 do
      GenServer.cast(state.log_walker_pid, {:walk_kyoku, kyoku_index, kyoku_log})
      GenServer.cast(self(), {:start_walk, kyoku_index + 1, gas - 1})
      {:noreply, state}
    else
      {:noreply, state}
    end
  end

end