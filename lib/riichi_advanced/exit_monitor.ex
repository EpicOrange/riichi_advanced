defmodule RiichiAdvanced.ExitMonitor do
  use GenServer

  def start_link(_initial_data) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def handle_call({:new_player, pid, callback}, _from, state) do
    state = Map.put(state, pid, %{callback: callback, monitor_ref: Process.monitor(pid)})
    {:reply, :ok, state}
  end

  def handle_info({:DOWN, _monitor_ref, :process, pid, _reason}, state) do
    state[pid].callback.()
    {:noreply, Map.delete(state, pid)}
  end
end
