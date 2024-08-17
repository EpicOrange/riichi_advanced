defmodule RiichiAdvanced.ExitMonitor do
  use GenServer

  def start_link(initial_data) do
    IO.puts("ExitMonitor start_link: #{inspect(initial_data)}")
    GenServer.start_link(__MODULE__, %{}, name: Keyword.get(initial_data, :name))
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def handle_call({:new_player, pid, seat}, _from, state) do
    state = Map.put(state, pid, %{seat: seat, monitor_ref: Process.monitor(pid)})
    {:reply, :ok, state}
  end

  def handle_info({:DOWN, _monitor_ref, :process, pid, _reason}, state) do
    x = Registry.lookup(RiichiAdvanced.Registry, :game_state)
    IO.inspect(x)
    [{game_state, _}] = x
    GenServer.call(game_state, {:delete_player, state[pid].seat})
    {:noreply, Map.delete(state, pid)}
  end
end
