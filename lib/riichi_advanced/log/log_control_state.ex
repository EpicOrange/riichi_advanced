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
  alias RiichiAdvanced.GameState.Debug, as: Debug
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
      if Debug.debug_log() && Enum.find_index(hand, &Utils.same_tile(&1, tile)) == nil do
        # debug
        IO.inspect({hand, draw, tile, discard_event})
        IO.inspect({:east, state.game_state.players.east.hand})
        IO.inspect({:south, state.game_state.players.south.hand})
        IO.inspect({:west, state.game_state.players.west.hand})
        IO.inspect({:north, state.game_state.players.north.hand})
        IO.inspect({:east, state.game_state.players.east.pond})
        IO.inspect({:south, state.game_state.players.south.pond})
        IO.inspect({:west, state.game_state.players.west.pond})
        IO.inspect({:north, state.game_state.players.north.pond})
      end
      Enum.find_index(hand, &Utils.same_tile(&1, tile))
    else
      if Debug.debug_log() && Enum.find_index(draw, &Utils.same_tile(&1, tile)) == nil do
        # debug
        IO.inspect({hand, draw, tile, discard_event})
        IO.inspect({:east, state.game_state.players.east.hand})
        IO.inspect({:south, state.game_state.players.south.hand})
        IO.inspect({:west, state.game_state.players.west.hand})
        IO.inspect({:north, state.game_state.players.north.hand})
        IO.inspect({:east, state.game_state.players.east.pond})
        IO.inspect({:south, state.game_state.players.south.pond})
        IO.inspect({:west, state.game_state.players.west.pond})
        IO.inspect({:north, state.game_state.players.north.pond})
      end
      length(hand) + Enum.find_index(draw, &Utils.same_tile(&1, tile))
    end
    prev_mode = GenServer.call(state.game_state_pid, {:put_log_loading_mode, skip_anim})

    GenServer.cast(state.game_state_pid, {:play_tile, seat, ix})
    # for all possible calls attached to this event
    # have players press skip on them if they weren't actually called
    call = if Map.has_key?(discard_event, "call") do [discard_event["call"]] else [] end
    possible_calls = Map.get(discard_event, "possible_calls", []) -- call
    call_seats = Enum.map(call, &Log.from_seat(&1["player"]))
    possible_call_seats = Enum.map(possible_calls, &Log.from_seat(&1["player"])) |> Enum.uniq()
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
    prev_mode = GenServer.call(state.game_state_pid, {:put_log_loading_mode, skip_anim})

    for {button_data, seat_num} <- Enum.with_index(button_press_event["buttons"]) do
      seat = Log.from_seat(seat_num)
      button = button_data["button"]
      GenServer.cast(state.game_state_pid, {:press_button, seat, button})
    end
    # after all buttons have been adjudicated,
    # may have to press call choice button or saki card
    for {button_data, seat_num} <- Enum.with_index(button_press_event["buttons"]) do
      seat = Log.from_seat(seat_num)
      case button_data do
        %{"call_choice" => call_choice, "called_tile" => called_tile} ->
          call_choice = Enum.map(call_choice, &Utils.to_tile/1)
          called_tile = Utils.to_tile(called_tile)
          GenServer.cast(state.game_state_pid, {:press_call_button, seat, call_choice, called_tile})
        %{"choice" => choice} ->
          GenServer.cast(state.game_state_pid, {:press_saki_card, seat, choice})
        _ -> :ok
      end
    end

    state = Map.put(state, :game_state, GenServer.call(state.game_state_pid, :get_state))
    GenServer.cast(state.game_state_pid, :sort_hands)
    GenServer.call(state.game_state_pid, {:put_log_loading_mode, prev_mode})
    state
  end

  def send_mark(state, skip_anim, mark_event) do
    seat = Log.from_seat(mark_event["player"])
    marking = mark_event["marking"]
    state = Map.put(state, :game_state, GenServer.call(state.game_state_pid, :get_state))
    prev_mode = GenServer.call(state.game_state_pid, {:put_log_loading_mode, skip_anim})

    GenServer.cast(state.game_state_pid, {:put_marking, seat, marking})

    state = Map.put(state, :game_state, GenServer.call(state.game_state_pid, :get_state))
    GenServer.cast(state.game_state_pid, :sort_hands)
    GenServer.call(state.game_state_pid, {:put_log_loading_mode, prev_mode})
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

  def handle_call({:send_mark, skip_anim, mark_event}, _from, state) do
    state = send_mark(state, skip_anim, mark_event)
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
