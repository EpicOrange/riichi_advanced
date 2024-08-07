defmodule RiichiAdvanced.GlobalState do
  use Agent

  def start_link(_initial_data) do
    initial_data = %{:turn => :east}
    Agent.start_link(fn -> initial_data end, name: __MODULE__)
  end

  def get_state do
    Agent.get(__MODULE__, & &1)
  end

  def update_state(fun) do
    Agent.update(__MODULE__, fun)
    RiichiAdvancedWeb.Endpoint.broadcast("game:main", "state_updated", %{"state" => get_state()})
  end

  def print_state do
    IO.puts("Global state:")
    IO.inspect(get_state())
  end
  
  def next_turn(seat, iterations \\ 1) do
    next = cond do
      seat == :east -> :south
      seat == :spectator -> :south
      seat == :south -> :west
      seat == :west -> :north
      seat == :north -> :east
    end
    if iterations <= 1 do next else next_turn(next, iterations - 1) end
  end
  
  def get_seat(seat, direction) do
    cond do
      direction == :shimocha -> next_turn(seat)
      direction == :toimen -> next_turn(seat, 2)
      direction == :kamicha -> next_turn(seat, 3)
      direction == :self -> next_turn(seat, 4)
    end
  end

  def get_relative_seat(seat, seat2) do
    cond do
      seat2 == next_turn(seat) -> :shimocha
      seat2 == next_turn(seat, 2) -> :toimen
      seat2 == next_turn(seat, 3) -> :kamicha
      seat2 == next_turn(seat, 4) -> :self
    end
  end

  def new_player(socket) do
    global_state = get_state()
    seat = cond do
      global_state[:east] == nil  -> :east
      global_state[:south] == nil -> :south
      global_state[:west] == nil  -> :west
      global_state[:north] == nil -> :north
      true                        -> :spectator
    end
    update_state(&Map.put(&1, seat, socket.id))
    IO.puts("Player #{socket.id} joined as #{seat}")
    IO.puts("Figuring out seat: #{seat}")
    {seat, global_state[:turn]}
  end
  
  def delete_player(socket) do
    update_state(&Map.put(&1, socket.assigns.seat, nil))
    IO.puts("Player #{socket.id} (#{socket.assigns.seat}) exited")
  end
  
  def play_tile(seat, tile) do
    IO.puts("#{seat} played tile: #{tile}")
    update_state(&Map.put(&1, :turn, next_turn(&1[:turn])))
    RiichiAdvancedWeb.Endpoint.broadcast("game:main", "played_tile", %{"seat" => seat, "tile" => tile})
  end

end