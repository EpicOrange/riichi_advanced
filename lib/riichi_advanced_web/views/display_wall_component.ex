defmodule RiichiAdvancedWeb.DisplayWallComponent do
  alias RiichiAdvanced.Riichi, as: Riichi
  alias RiichiAdvanced.Utils, as: Utils
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    socket = assign(socket, :viewer, :spectator)
    socket = assign(socket, :seat, :east)
    socket = assign(socket, :wall, [])
    socket = assign(socket, :dead_wall, [])
    socket = assign(socket, :wall_length, 136)
    socket = assign(socket, :wall_index, 0)
    socket = assign(socket, :dead_wall_index, 0)
    socket = assign(socket, :revealed_tiles, [])
    socket = assign(socket, :reserved_tiles, [])
    socket = assign(socket, :drawn_reserved_tiles, [])
    socket = assign(socket, :prepared_wall, %{self: [], kamicha: [], toimen: [], shimocha: []})
    socket = assign(socket, :kyoku, :east)
    socket = assign(socket, :dice, [3, 4])
    socket = assign(socket, :dice_roll, 7)
    socket = assign(socket, :available_seats, [:east, :south, :west, :north])
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={["display-wall-container"]}>
      <div class={[@id]}>
        <.live_component module={RiichiAdvancedWeb.DisplayWallWallComponent}
          id="wall toimen"
          wall={Map.get(@prepared_wall, :toimen, [])} />
        <.live_component module={RiichiAdvancedWeb.DisplayWallWallComponent}
          id="wall shimocha"
          wall={Map.get(@prepared_wall, :shimocha, [])} />
        <.live_component module={RiichiAdvancedWeb.DisplayWallWallComponent}
          id="wall self"
          wall={Map.get(@prepared_wall, :self, [])} />
        <.live_component module={RiichiAdvancedWeb.DisplayWallWallComponent}
          id="wall kamicha"
          wall={Map.get(@prepared_wall, :kamicha, [])} />
        <div class="dice">
          <div class={["die", to_die_class(die)]} :for={die <- @dice}></div>
        </div>
      </div>
    </div>
    """
  end

  def prepare_wall(assigns) do
    # visible
    wall = Enum.drop(assigns.wall, assigns.wall_index)
    |> Enum.map(&if Utils.is_space?(&1) do &1 else :"1x" end)
    dead_wall = Enum.drop(assigns.dead_wall, -assigns.dead_wall_index)
    |> Enum.map(&if Utils.is_space?(&1) do &1 else :"1x" end)

    # show dora indicators in dead wall
    dead_wall = for ix <- assigns.revealed_tiles, is_integer(ix), reduce: dead_wall do
      dead_wall ->
        pos = ix + assigns.dead_wall_index
        if pos < 0 do
          List.replace_at(dead_wall, pos, Enum.at(assigns.dead_wall, ix))
        else dead_wall end
    end

    # make stacks, the idea being each stack looks like [top tile, bottom tile]
    live_wall_spaces = List.duplicate(:"2x", assigns.wall_index)
    live_wall_stacks = Enum.chunk_every(live_wall_spaces ++ wall, 2)
    dead_wall_spaces = List.duplicate(:"2x", assigns.dead_wall_index)
    dead_wall_stacks = (dead_wall ++ dead_wall_spaces)
    |> Enum.reverse()
    |> Enum.chunk_every(2)
    |> Enum.map(&Enum.reverse/1)
    |> Enum.reverse()
    |> Enum.map(&if &1 == [:"1x", :"2x"] do [:"1x"] else &1 end) # don't let any tiles "float"
    final_wall = live_wall_stacks ++ dead_wall_stacks
    # add tiles atop wall
    {final_wall, _acc} = final_wall
    |> Enum.zip([[] | final_wall])
    |> Enum.reverse()
    |> Enum.map_reduce({[], length(final_wall), false}, fn {stack, next_stack}, {acc, dist, looked_ahead} ->
      atop = if dist >= 0 do nil else Map.get(assigns.atop_wall, dist, nil) end
      acc = if atop != nil and not looked_ahead do [{atop, dist} | acc] else acc end
      if Enum.all?(stack, &Utils.is_space?/1) do
        {stack, {acc, dist - 1, false}}
      else
        # look ahead one tile to see if there's a tile atop a non-2-stack
        # if so, pick it up here instead
        atop2 = if dist >= 0 do nil else Map.get(assigns.atop_wall, dist-1, nil) end
        looked_ahead = atop2 != nil and length(next_stack) < 2
        acc = if looked_ahead do [{atop2, dist} | acc] else acc end

        dist = if dist >= 0 do -1 else dist end
        if length(stack) >= 2 and not Enum.empty?(acc) do
          {here, acc} = Enum.split_with(acc, fn {_atop, ix} -> ix >= dist end)
          {Enum.map(here, fn {atop, _ix} -> atop end) ++ stack, {acc, dist - 1, looked_ahead}}
        else {stack, {acc, dist - 1, looked_ahead}} end
      end
    end)
    final_wall = Enum.reverse(final_wall)
    # IO.inspect(final_wall, limit: :infinity)

    # figure out where the wall break is relative to our seat
    num_players = length(assigns.available_seats)
    wall_length = trunc(Float.ceil(assigns.wall_length / num_players / 2))
    break_dir = Riichi.get_break_direction(assigns.dice_roll, assigns.kyoku, assigns.seat, assigns.available_seats)
    dead_wall_length = length(dead_wall_stacks)
    case num_players do
      2 ->
        wall1 = Enum.take(final_wall, -assigns.dice_roll) ++ Enum.take(final_wall, max(0, wall_length - assigns.dice_roll))
        wall2 = final_wall |> Enum.drop(wall_length - assigns.dice_roll) |> Enum.take(length(final_wall) - wall_length)
        # IO.inspect({length(assigns.dead_wall), length(live_wall_stacks), length(dead_wall_stacks), wall2, wall1})
        # IO.inspect({length(assigns.dead_wall), length(wall2), length(wall1)})

        # insert spacer for dead wall
        {wall1, wall2} = cond do
          assigns.dice_roll < dead_wall_length -> {wall1, List.insert_at(wall2, -(dead_wall_length - assigns.dice_roll + 1), [:dead, :wall])}
          assigns.wall_index >= length(assigns.wall) -> {wall1, wall2} # no spacer in wall1 if we drew into the dead wall
          assigns.dice_roll > dead_wall_length -> {List.insert_at(wall1, assigns.dice_roll - dead_wall_length, [:dead, :wall]), wall2}
          true -> {wall1, wall2}
        end
        available_dirs = Enum.map(assigns.available_seats, &Utils.get_relative_seat(assigns.seat, &1))
        [break_dir, Utils.prev_turn(break_dir), Utils.prev_turn(break_dir, 2), Utils.prev_turn(break_dir, 3)]
        |> Enum.filter(& &1 in available_dirs)
        |> Enum.zip([wall1, wall2])
        |> Map.new()
      3 ->
        wall1 = Enum.take(final_wall, -assigns.dice_roll) ++ Enum.take(final_wall, max(0, wall_length - assigns.dice_roll))
        wall2 = final_wall |> Enum.drop(wall_length - assigns.dice_roll) |> Enum.take(wall_length)
        wall3 = final_wall |> Enum.drop(2*wall_length - assigns.dice_roll) |> Enum.take(length(final_wall) - 2*wall_length)
        # IO.inspect({length(assigns.dead_wall), length(live_wall_stacks), length(dead_wall_stacks), wall3, wall1})
        # IO.inspect({length(assigns.dead_wall), length(wall3), length(wall1)})

        # insert spacer for dead wall
        {wall1, wall3} = cond do
          assigns.dice_roll < dead_wall_length -> {wall1, List.insert_at(wall3, -(dead_wall_length - assigns.dice_roll + 1), [:dead, :wall])}
          assigns.wall_index >= length(assigns.wall) -> {wall1, wall3} # no spacer in wall1 if we drew into the dead wall
          assigns.dice_roll > dead_wall_length -> {List.insert_at(wall1, assigns.dice_roll - dead_wall_length, [:dead, :wall]), wall3}
          true -> {wall1, wall3}
        end
        available_dirs = Enum.map(assigns.available_seats, &Utils.get_relative_seat(assigns.seat, &1))
        [break_dir, Utils.prev_turn(break_dir), Utils.prev_turn(break_dir, 2), Utils.prev_turn(break_dir, 3)]
        |> Enum.filter(& &1 in available_dirs)
        |> Enum.zip([wall1, wall2, wall3])
        |> Map.new()
      4 ->
        wall1 = Enum.take(final_wall, -assigns.dice_roll) ++ Enum.take(final_wall, max(0, wall_length - assigns.dice_roll))
        wall2 = final_wall |> Enum.drop(wall_length - assigns.dice_roll) |> Enum.take(wall_length)
        wall3 = final_wall |> Enum.drop(2*wall_length - assigns.dice_roll) |> Enum.take(wall_length)
        wall4 = final_wall |> Enum.drop(3*wall_length - assigns.dice_roll) |> Enum.take(length(final_wall) - 3*wall_length)
        # IO.inspect({length(assigns.dead_wall), length(live_wall_stacks), length(dead_wall_stacks), wall4, wall1})
        # IO.inspect({length(assigns.dead_wall), length(wall4), length(wall1)})

        # insert spacer for dead wall
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

  def update(assigns, socket) do
    socket = assigns
    |> Map.drop([:flash])
    |> Enum.reduce(socket, fn {key, value}, acc_socket -> assign(acc_socket, key, value) end)

    socket = assign(socket, :prepared_wall, prepare_wall(socket.assigns))

    {:ok, socket}
  end
end
