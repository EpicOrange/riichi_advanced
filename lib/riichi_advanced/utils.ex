defmodule Utils do

  def next_turn(seat, iterations \\ 1) do
    next = cond do
      seat == :east  -> :south
      seat == :south -> :west
      seat == :west  -> :north
      seat == :north -> :east
    end
    if iterations <= 0 do seat else next_turn(next, iterations - 1) end
  end
  def prev_turn(seat, iterations \\ 1) do
    prev = cond do
      seat == :east  -> :north
      seat == :south -> :east
      seat == :west  -> :south
      seat == :north -> :west
    end
    if iterations <= 0 do seat else prev_turn(prev, iterations - 1) end
  end
  
  def get_seat(seat, direction) do
    cond do
      direction == :shimocha -> next_turn(seat)
      direction == :toimen   -> next_turn(seat, 2)
      direction == :kamicha  -> next_turn(seat, 3)
      direction == :self     -> next_turn(seat, 4)
    end
  end

  def get_relative_seat(seat, seat2) do
    cond do
      seat2 == next_turn(seat)    -> :shimocha
      seat2 == next_turn(seat, 2) -> :toimen
      seat2 == next_turn(seat, 3) -> :kamicha
      seat2 == next_turn(seat, 4) -> :self
    end
  end
  
  def rotate_4([a,b,c,d], seat) do
    case seat do
      :east  -> [a,b,c,d]
      :south -> [b,c,d,a]
      :west  -> [c,d,a,b]
      :north -> [d,a,b,c]
    end
  end

end