defmodule RiichiAdvanced.ExitMonitor do
  use GenServer

  def start_link(initial_data) do
    GenServer.start_link(__MODULE__, %{}, name: Keyword.get(initial_data, :name))
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def handle_call({:new_player, pid, seat}, {from_pid, _tag}, state) do
    state = Map.put(state, pid, %{game_state: from_pid, seat: seat, monitor_ref: Process.monitor(pid)})
    {:reply, :ok, state}
  end

  def handle_info({:DOWN, _monitor_ref, :process, pid, _reason}, state) do
    GenServer.call(state[pid].game_state, {:delete_player, state[pid].seat})
    {:noreply, Map.delete(state, pid)}
  end
end
