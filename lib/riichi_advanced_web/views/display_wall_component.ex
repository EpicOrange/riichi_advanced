defmodule RiichiAdvancedWeb.DisplayWallComponent do
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    socket = assign(socket, :viewer, :spectator)
    socket = assign(socket, :wall, [])
    socket = assign(socket, :dead_wall, [])
    socket = assign(socket, :wall_index, 0)
    socket = assign(socket, :dead_wall_offset, 0)
    socket = assign(socket, :minimized, true)
    socket = assign(socket, :revealed_tiles, [])
    socket = assign(socket, :reserved_tiles, [])
    socket = assign(socket, :drawn_reserved_tiles, [])
    socket = assign(socket, :prepared_wall, %{self: [], kamicha: [], toimen: [], shimocha: []})
    socket = assign(socket, :kyoku, :east)
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

  def prepare_wall(assigns) do
    # visible
    # wall = Enum.drop(assigns.wall, assigns.wall_index)
    # dead_wall = assigns.dead_wall
    # hidden
    wall = List.duplicate(:"1x", length(assigns.wall) - assigns.wall_index)
    dead_wall = List.duplicate(:"1x", length(assigns.dead_wall))

    # show dora indicators in dead wall
    dead_wall = for ix <- assigns.revealed_tiles, is_integer(ix), reduce: dead_wall do
      dead_wall -> List.replace_at(dead_wall, ix, Enum.at(assigns.dead_wall, ix))
    end

    # hide drawn kan tiles in dead wall
    dead_wall = for tile <- assigns.drawn_reserved_tiles, reduce: dead_wall do
      dead_wall ->
        ix = -(1 + Enum.find_index(assigns.reserved_tiles, fn t -> t == tile end))
        # tiles are drawn -2 -1 -4 -3 -6 -5, so we need to figure out the true index
        # basically add 1 if even, sub 1 if odd
        ix = ix + if rem(ix, 2) == 0 do 1 else -1 end
        List.replace_at(dead_wall, ix, :"2x")
    end

    # concatenate
    wall_spaces = List.duplicate(:"2x", assigns.wall_index)
    dead_wall_spaces = List.duplicate(:"2x", assigns.dead_wall_offset)
    live_wall_chunks = (wall_spaces ++ wall ++ dead_wall_spaces)
    |> Enum.chunk_every(2)
    dead_wall_chunks = dead_wall
    |> Enum.reverse()
    |> Enum.chunk_every(2)
    |> Enum.map(&Enum.reverse/1)
    |> Enum.reverse()
    final_wall = live_wall_chunks ++ dead_wall_chunks
    
    # figure out where the wall break is relative to our seat
    seat = if assigns.viewer == :spectator do :east else assigns.viewer end
    break_dir = Riichi.get_break_direction(assigns.dice_roll, assigns.kyoku, seat)
    offset = -assigns.dice_roll - Integer.floor_div(-assigns.dead_wall_offset, 2)
    wall1 = Enum.take(final_wall, -assigns.dice_roll) ++ Enum.take(final_wall, 17 - assigns.dice_roll)
    wall2 = final_wall |> Enum.drop(17 - assigns.dice_roll) |> Enum.take(17)
    wall3 = final_wall |> Enum.drop(34 - assigns.dice_roll) |> Enum.take(17)
    wall4 = final_wall |> Enum.drop(51 + offset) |> Enum.take(17)
    # IO.inspect({length(assigns.dead_wall), dead_wall_chunks, wall4, wall1})
    # IO.inspect({length(assigns.dead_wall), length(wall4), length(wall1)})

    # insert spacer for dead wall
    dead_wall_length = -Integer.floor_div(-length(dead_wall), 2)
    {wall1, wall4} = cond do
      assigns.dice_roll < dead_wall_length -> {wall1, List.insert_at(wall4, -(dead_wall_length - assigns.dice_roll + 1), [:dead, :wall])}
      assigns.wall_index >= length(assigns.wall) -> {wall1, wall4} # no spacer in wall1 if we drew into the dead wall
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
