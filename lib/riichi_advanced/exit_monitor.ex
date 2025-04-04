defmodule RiichiAdvanced.ExitMonitor do
  use GenServer

  def start_link(initial_data) do
    GenServer.start_link(__MODULE__, %{}, name: Keyword.get(initial_data, :name))
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def handle_call({:new_player, pid, identifier}, {from_pid, _tag}, state) do
    if not Map.has_key?(state, pid) do
      state = Map.put(state, pid, %{from: from_pid, identifier: identifier, monitor_ref: Process.monitor(pid)})
      # IO.puts("#{inspect(self())}: Now monitoring #{inspect(pid)}! state: #{inspect(state)}")
      {:reply, :ok, state}
    else
      # IO.puts("#{inspect(self())}: Already monitoring #{inspect(pid)}! state: #{inspect(state)}")
      {:reply, :ok, state}
    end
  end

  def handle_info({:DOWN, _monitor_ref, :process, pid, _reason}, state) do
    # IO.puts("#{inspect(self())}: #{inspect(pid)} just went down! notifying #{inspect(state[pid].from)}\nstate: #{inspect(state)}")
    GenServer.call(state[pid].from, {:delete_player, state[pid].identifier})
    {:noreply, Map.delete(state, pid)}
  end
end
