defmodule RiichiAdvanced.MessagesState do
  use GenServer

  defmodule Messages do
    defstruct [
      # params
      socket_id: nil,
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
      %Messages{socket_id: Keyword.get(init_data, :socket_id)},
      name: Keyword.get(init_data, :name))
  end

  def init(state) do
    # lookup pids of the other processes we'll be using
    [{supervisor, _}] = RiichiAdvanced.Utils.registry_lookup("messages", state.socket_id)
    [{exit_monitor, _}] = RiichiAdvanced.Utils.registry_lookup("exit_monitor_messages", state.socket_id)

    state = Map.merge(state, %Messages{
      socket_id: state.socket_id,
      supervisor: supervisor,
      exit_monitor: exit_monitor,
      disconnected: false
    })

    {:ok, state}
  end

  def broadcast_state_change(state) do
    RiichiAdvancedWeb.Endpoint.broadcast("messages:" <> state.socket_id, "messages_updated", %{"state" => state})
    state
  end

  # deprecated, use the below call instead
  def handle_call({:new_player, socket}, _from, state) do
    GenServer.call(state.exit_monitor, {:new_player, socket.root_pid, socket.id})
    IO.puts("Retrieving messages for #{socket.id}")
    state = broadcast_state_change(state)
    state = Map.put(state, :disconnected, false)
    {:reply, [state], state}
  end

  def handle_call({:new_player, pid, id}, _from, state) do
    GenServer.call(state.exit_monitor, {:new_player, pid, id})
    IO.puts("Retrieving messages for #{id}")
    state = broadcast_state_change(state)
    state = Map.put(state, :disconnected, false)
    {:reply, [state], state}
  end

  def handle_call({:delete_player, socket_id}, _from, state) do
    state = Map.put(state, :disconnected, true)
    :timer.apply_after(15000, GenServer, :cast, [self(), :terminate_if_disconnected])
    IO.puts("#{socket_id} disconnected, dropping messages in 15 seconds unless reconnected")
    {:reply, :ok, state}
  end

  def handle_cast({:add_message, message}, state) do
    # IO.puts("Player #{state.socket_id} got message #{inspect(message)}")
    state = Map.update!(state, :messages, fn messages -> messages ++ [message] end)
    state = broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast({:add_messages, msgs}, state) do
    # IO.puts("Player #{state.socket_id} got messages #{inspect(msgs)}")
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
      IO.puts("Messages dropped for #{state.socket_id}")
    else
      IO.puts("Not dropping messages for #{state.socket_id}")
    end
    {:noreply, state}
  end

  # deprecated
  def init_socket(socket) do
    # try to initialize a messages state for this socket if it doesn't exist already
    if socket.root_pid != nil do
      # start a new messages process, if it doesn't exist already
      messages_spec = {RiichiAdvanced.MessagesSupervisor, socket_id: socket.id, name: RiichiAdvanced.Utils.via_registry("messages", socket.id)}
      messages_state = case DynamicSupervisor.start_child(RiichiAdvanced.MessagesSessionSupervisor, messages_spec) do
        {:ok, _pid} ->
          IO.puts("Starting messages for socket #{socket.id}")
          [{messages_state, _}] = RiichiAdvanced.Utils.registry_lookup("messages_state", socket.id)
          messages_state
        {:error, {:shutdown, error}} ->
          IO.puts("Error when starting messages for socket #{socket.id}")
          IO.inspect(error)
          nil
        {:error, {:already_started, _pid}} ->
          IO.puts("Already started messages for socket #{socket.id}")
          [{messages_state, _}] = RiichiAdvanced.Utils.registry_lookup("messages_state", socket.id)
          messages_state
      end
      # init a new player and get the current state
      [state] = GenServer.call(messages_state, {:new_player, socket})
      %{
        messages_state: messages_state,
        state: state
      }
    else %{} end
  end

  def link_player_socket(pid, id) do
    # try to initialize a messages state for this socket if it doesn't exist already
    if pid != nil do
      # start a new messages process, if it doesn't exist already
      messages_spec = {RiichiAdvanced.MessagesSupervisor, socket_id: id, name: RiichiAdvanced.Utils.via_registry("messages", id)}
      messages_state = case DynamicSupervisor.start_child(RiichiAdvanced.MessagesSessionSupervisor, messages_spec) do
        {:ok, _pid} ->
          IO.puts("Starting messages for socket #{id}")
          [{messages_state, _}] = RiichiAdvanced.Utils.registry_lookup("messages_state", id)
          messages_state
        {:error, {:shutdown, error}} ->
          IO.puts("Error when starting messages for socket #{id}")
          IO.inspect(error)
          nil
        {:error, {:already_started, _pid}} ->
          IO.puts("Already started messages for socket #{id}")
          [{messages_state, _}] = RiichiAdvanced.Utils.registry_lookup("messages_state", id)
          messages_state
      end
      # init a new player and get the current state
      [state] = GenServer.call(messages_state, {:new_player, pid, id})
      %{
        messages_state: messages_state,
        state: state
      }
    else %{} end
  end
end
