defmodule LogWalker do
  defstruct [
    # params
    ruleset: nil,
    session_id: nil,
    # pids
    supervisor: nil,
    game_state_pid: nil,
    # state variables
    game_states: %{}, # kyoku_index => event_index => game state after the event happens, or at start
    game_state: %Game{},
  ]
  use Accessible
end

defmodule RiichiAdvanced.LogWalker do
  alias RiichiAdvanced.LogControlState, as: LogControl
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
    IO.puts("Log walker PID is #{inspect(self())}")

    # lookup pids of the other processes we'll be using
    [{supervisor, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("log", state.ruleset, state.session_id))
    [{game_state, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("game_state", state.ruleset, state.session_id <> "_walker"))
    GenServer.call(game_state, {:put_log_loading_mode, true})
    GenServer.call(game_state, {:put_log_seeking_mode, true})

    state = Map.merge(state, %LogWalker{
      ruleset: state.ruleset,
      session_id: state.session_id,
      supervisor: supervisor,
      game_state_pid: game_state,
    })
    {:ok, state}
  end


  def handle_call({:get_state, kyoku_index, event_index}, _from, state) do
    {:reply, Map.get(state.game_states, kyoku_index, state.game_states[0])[event_index], state}
  end

  def handle_cast({:walk_kyoku, kyoku_index, kyoku_log}, state) do
    # initialize this kyoku
    GenServer.cast(state.game_state_pid, {:initialize_game, kyoku_log})
    GenServer.cast(state.game_state_pid, :sort_hands)
    state = Map.put(state, :game_state, GenServer.call(state.game_state_pid, :get_state))
    state = put_in(state.game_states[kyoku_index], %{-1 => state.game_state})
    IO.puts("Walking kyoku #{kyoku_index}")
    state = for event <- kyoku_log["events"], reduce: state do
      state ->
        state = case event["type"] do
          "discard"         -> LogControl.send_discard(state, true, event)
          "buttons_pressed" -> LogControl.send_button_press(state, true, event)
          "mark"            -> LogControl.send_mark(state, true, event)
          _                 -> state
        end
        state = put_in(state.game_states[kyoku_index][event["index"]], state.game_state)
        state
    end
    {:noreply, state}
  end
end
