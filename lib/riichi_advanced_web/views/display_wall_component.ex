defmodule RiichiAdvancedWeb.DisplayWallComponent do
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    socket = assign(socket, :wall, [])
    socket = assign(socket, :viewer, :spectator)
    socket = assign(socket, :kyoku, :east)
    socket = assign(socket, :dead_wall, [])
    socket = assign(socket, :wall_index, 0)
    socket = assign(socket, :minimized, true)
    socket = assign(socket, :revealed_tiles, [])
    socket = assign(socket, :prepared_wall, %{self: [], kamicha: [], toimen: [], shimocha: []})
    socket = assign(socket, :die1, 3)
    socket = assign(socket, :die2, 4)
    socket = assign(socket, :dice_roll, 7)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="display-wall-container">
      <input id="display-wall-minimize" type="checkbox" class="display-wall-minimize" checked={not @minimized}>
      <label for="display-wall-minimize" class="display-wall-minimize-label" phx-cancellable-click="minimize" phx-target={@myself}><%= if @minimized do "Show wall" else "Hide wall" end %></label>
      <div class={[@id, @minimized && "minimized"]}>
        <.live_component module={RiichiAdvancedWeb.DisplayWallWallComponent}
          id="wall toimen"
          wall={@prepared_wall[:toimen]} />
        <.live_component module={RiichiAdvancedWeb.DisplayWallWallComponent}
          id="wall shimocha"
          wall={@prepared_wall[:shimocha]} />
        <.live_component module={RiichiAdvancedWeb.DisplayWallWallComponent}
          id="wall self"
          wall={@prepared_wall[:self]} />
        <.live_component module={RiichiAdvancedWeb.DisplayWallWallComponent}
          id="wall kamicha"
          wall={@prepared_wall[:kamicha]} />
        <div class="dice">
          <div class={["die", to_die_class(@die1)]}></div>
          <div class={["die", to_die_class(@die2)]}></div>
        </div>
      </div>
    </div>
    """
  end

  # def prepare_visible_wall(assigns) do
  #   wall = Enum.drop(assigns.wall, assigns.wall_index)
  #   wall_spaces = List.duplicate(:"2x", assigns.wall_index)
  #   wall_spaces ++ wall ++ [:"2x", :"2x"] ++ assigns.dead_wall
  #   |> Enum.chunk_every(2)
  # end

  def prepare_wall(assigns) do
    wall = List.duplicate(:"1x", length(assigns.wall) - assigns.wall_index)
    dead_wall = List.duplicate(:"1x", length(assigns.dead_wall))
    dead_wall = for ix <- assigns.revealed_tiles, is_integer(ix), reduce: dead_wall do
      dead_wall -> List.replace_at(dead_wall, ix, Enum.at(assigns.dead_wall, ix))
    end
    wall_spaces = List.duplicate(:"2x", assigns.wall_index)
    final_wall = wall_spaces ++ wall ++ dead_wall
    |> Enum.chunk_every(2)
    # figure out where the wall break is relative to our seat
    wall_dir = cond do
      assigns.dice_roll in [2, 6, 10] -> :south
      assigns.dice_roll in [3, 7, 11] -> :west
      assigns.dice_roll in [4, 8, 12] -> :north
      true                            -> :east
    end
    our_dir = if assigns.viewer == :spectator do :east else assigns.viewer end
    break_dir = Riichi.get_seat_wind(assigns.kyoku, our_dir) |> Utils.get_relative_seat(wall_dir)
    wall1 = Enum.take(final_wall, -assigns.dice_roll) ++ Enum.take(final_wall, 17 - assigns.dice_roll)
    wall2 = final_wall |> Enum.drop(17 - assigns.dice_roll) |> Enum.take(17)
    wall3 = final_wall |> Enum.drop(34 - assigns.dice_roll) |> Enum.take(17)
    wall4 = final_wall |> Enum.drop(51 - assigns.dice_roll) |> Enum.take(17)
    # insert spacer for dead wall
    dead_wall_length = -Integer.floor_div(-length(dead_wall), 2) # half rounded up
    IO.inspect({dead_wall_length, dead_wall})
    {wall1, wall4} = cond do
      assigns.dice_roll < dead_wall_length -> {wall1, List.insert_at(wall4, -(dead_wall_length - assigns.dice_roll + 1), [:dead, :wall])}
      assigns.dice_roll > dead_wall_length -> {List.insert_at(wall1, assigns.dice_roll - dead_wall_length, [:dead, :wall]), wall4}
      true -> {wall1, wall4}
    end
    %{
      break_dir                     => wall1,
      Utils.prev_turn(break_dir)    => wall2,
      Utils.prev_turn(break_dir, 2) => wall3,
      Utils.prev_turn(break_dir, 3) => wall4
    }
  end

  def to_die_class(die) do
    case die do
      1 -> "one"
      2 -> "two"
      3 -> "three"
      4 -> "four"
      5 -> "five"
      6 -> "six"
    end
  end

  def handle_event("minimize", _assigns, socket) do
    socket = assign(socket, :minimized, not socket.assigns.minimized)
    {:noreply, socket}
  end

  def update(assigns, socket) do
    socket = assigns
    |> Map.drop([:flash])
    |> Enum.reduce(socket, fn {key, value}, acc_socket -> assign(acc_socket, key, value) end)

    socket = assign(socket, :prepared_wall, prepare_wall(socket.assigns))

    {:ok, socket}
  end
end
