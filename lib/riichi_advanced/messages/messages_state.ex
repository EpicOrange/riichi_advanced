defmodule RiichiAdvanced.MessagesState do
  use GenServer

  defmodule Messages do
    defstruct [
      # params
      session_id: nil,
      # pids
      supervisor: nil,
      exit_monitor: nil,

      # state
      messages: [],
      disconnected: true
    ]
  end

  def start_link(init_data) do
    IO.puts("Supervisor PID is #{inspect(self())}")
    GenServer.start_link(
      __MODULE__,
      %Messages{session_id: Keyword.get(init_data, :session_id)},
      name: Keyword.get(init_data, :name))
  end

  def init(state) do
    # lookup pids of the other processes we'll be using
    [{supervisor, _}] = RiichiAdvanced.Utils.registry_lookup("messages", state.session_id)
    [{exit_monitor, _}] = RiichiAdvanced.Utils.registry_lookup("exit_monitor_messages", state.session_id)

    state = %Messages{
      session_id: state.session_id,
      supervisor: supervisor,
      exit_monitor: exit_monitor,
      disconnected: false
    }

    {:ok, state}
  end

  def broadcast_state_change(state) do
    RiichiAdvancedWeb.Endpoint.broadcast("messages:" <> state.session_id, "messages_updated", %{"state" => state})
    state
  end

  def handle_call({:new_player, pid, session_id}, _from, state) do
    GenServer.call(state.exit_monitor, {:new_player, pid, session_id})
    IO.puts("Retrieving messages for #{session_id}")
    state = broadcast_state_change(state)
    state = Map.put(state, :disconnected, false)
    {:reply, [state], state}
  end

  def handle_call({:delete_player, session_id}, _from, state) do
    state = Map.put(state, :disconnected, true)
    :timer.apply_after(15000, GenServer, :cast, [self(), :terminate_if_disconnected])
    IO.puts("#{session_id} disconnected, dropping messages in 15 seconds unless reconnected")
    {:reply, :ok, state}
  end

  def handle_cast({:add_message, message}, state) do
    # IO.puts("Player #{state.session_id} got message #{inspect(message)}")
    state = Map.update!(state, :messages, fn messages -> messages ++ [message] end)
    state = broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast({:add_messages, msgs}, state) do
    # IO.puts("Player #{state.session_id} got messages #{inspect(msgs)}")
    state = Map.update!(state, :messages, fn messages -> messages ++ msgs end)
    state = broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast(:poll_messages, state) do
    state = broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast(:terminate_if_disconnected, state) do
    if state.disconnected do
      DynamicSupervisor.terminate_child(RiichiAdvanced.MessagesSessionSupervisor, state.supervisor)
      IO.puts("Messages dropped for #{state.session_id}")
    else
      IO.puts("Not dropping messages for #{state.session_id}")
    end
    {:noreply, state}
  end

  def link_player_socket(pid, session_id) do
    # try to initialize a messages state for this socket if it doesn't exist already
    if pid != nil do
      # start a new messages process, if it doesn't exist already
      messages_spec = {RiichiAdvanced.MessagesSupervisor, session_id: session_id, name: RiichiAdvanced.Utils.via_registry("messages", session_id)}
      messages_state = case DynamicSupervisor.start_child(RiichiAdvanced.MessagesSessionSupervisor, messages_spec) do
        {:ok, _pid} ->
          IO.puts("Starting messages for socket #{session_id}")
          [{messages_state, _}] = RiichiAdvanced.Utils.registry_lookup("messages_state", session_id)
          messages_state
        {:error, {:shutdown, error}} ->
          IO.puts("Error when starting messages for socket #{session_id}")
          IO.inspect(error)
          nil
        {:error, {:already_started, _pid}} ->
          IO.puts("Already started messages for socket #{session_id}")
          [{messages_state, _}] = RiichiAdvanced.Utils.registry_lookup("messages_state", session_id)
          messages_state
      end
      # init a new player and get the current state
      [state] = GenServer.call(messages_state, {:new_player, pid, session_id})
      %{
        messages_state: messages_state,
        state: state
      }
    else %{} end
  end
end
