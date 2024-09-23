defmodule Utils do
  @to_tile %{"1m"=>:"1m", "2m"=>:"2m", "3m"=>:"3m", "4m"=>:"4m", "5m"=>:"5m", "6m"=>:"6m", "7m"=>:"7m", "8m"=>:"8m", "9m"=>:"9m", "0m"=>:"0m",
             "1p"=>:"1p", "2p"=>:"2p", "3p"=>:"3p", "4p"=>:"4p", "5p"=>:"5p", "6p"=>:"6p", "7p"=>:"7p", "8p"=>:"8p", "9p"=>:"9p", "0p"=>:"0p",
             "1s"=>:"1s", "2s"=>:"2s", "3s"=>:"3s", "4s"=>:"4s", "5s"=>:"5s", "6s"=>:"6s", "7s"=>:"7s", "8s"=>:"8s", "9s"=>:"9s", "0s"=>:"0s",
             "1z"=>:"1z", "2z"=>:"2z", "3z"=>:"3z", "4z"=>:"4z", "5z"=>:"5z", "6z"=>:"6z", "7z"=>:"7z", "0z"=>:"0z",
             "1x"=>:"1x", "2x"=>:"2x",
             "1f"=>:"1f", "2f"=>:"2f", "3f"=>:"3f", "4f"=>:"4f",
             "1g"=>:"1g", "2g"=>:"2g", "3g"=>:"3g", "4g"=>:"4g",
             "1a"=>:"1a", "2a"=>:"2a", "3a"=>:"3a", "4a"=>:"4a",
             "1y"=>:"1y", "2y"=>:"2y",
             "1j"=>:"1j", "2j"=>:"2j", "3j"=>:"3j", "4j"=>:"4j", "5j"=>:"5j", "6j"=>:"6j", "7j"=>:"7j", "8j"=>:"8j", "9j"=>:"9j",
             "1k"=>:"1k", "2k"=>:"2k", "3k"=>:"3k", "4k"=>:"4k",
             "1q"=>:"1q", "2q"=>:"2q", "3q"=>:"3q", "4q"=>:"4q", 
             :"1m"=>:"1m", :"2m"=>:"2m", :"3m"=>:"3m", :"4m"=>:"4m", :"5m"=>:"5m", :"6m"=>:"6m", :"7m"=>:"7m", :"8m"=>:"8m", :"9m"=>:"9m", :"0m"=>:"0m",
             :"1p"=>:"1p", :"2p"=>:"2p", :"3p"=>:"3p", :"4p"=>:"4p", :"5p"=>:"5p", :"6p"=>:"6p", :"7p"=>:"7p", :"8p"=>:"8p", :"9p"=>:"9p", :"0p"=>:"0p",
             :"1s"=>:"1s", :"2s"=>:"2s", :"3s"=>:"3s", :"4s"=>:"4s", :"5s"=>:"5s", :"6s"=>:"6s", :"7s"=>:"7s", :"8s"=>:"8s", :"9s"=>:"9s", :"0s"=>:"0s",
             :"1z"=>:"1z", :"2z"=>:"2z", :"3z"=>:"3z", :"4z"=>:"4z", :"5z"=>:"5z", :"6z"=>:"6z", :"7z"=>:"7z", :"0z"=>:"0z",
             :"1x"=>:"1x", :"2x"=>:"2x",
             :"1f"=>:"1f", :"2f"=>:"2f", :"3f"=>:"3f", :"4f"=>:"4f",
             :"1g"=>:"1g", :"2g"=>:"2g", :"3g"=>:"3g", :"4g"=>:"4g",
             :"1a"=>:"1a", :"2a"=>:"2a", :"3a"=>:"3a", :"4a"=>:"4a",
             :"1y"=>:"1y", :"2y"=>:"2y",
             :"1j"=>:"1j", :"2j"=>:"2j", :"3j"=>:"3j", :"4j"=>:"4j", :"5j"=>:"5j", :"6j"=>:"6j", :"7j"=>:"7j", :"8j"=>:"8j", :"9j"=>:"9j",
             :"1k"=>:"1k", :"2k"=>:"2k", :"3k"=>:"3k", :"4k"=>:"4k",
             :"1q"=>:"1q", :"2q"=>:"2q", :"3q"=>:"3q", :"4q"=>:"4q"}
  def to_tile(tile_str), do: @to_tile[tile_str]

  def sort_value(tile) do
    case tile do
      :"1m" -> 0; :"2m" -> 1; :"3m" -> 2; :"4m" -> 3; :"0m" -> 4; :"5m" -> 5; :"6m" -> 6; :"7m" -> 7; :"8m" -> 8; :"9m" -> 9;
      :"1p" -> 10; :"2p" -> 11; :"3p" -> 12; :"4p" -> 13; :"0p" -> 14; :"5p" -> 15; :"6p" -> 16; :"7p" -> 17; :"8p" -> 18; :"9p" -> 19;
      :"1s" -> 20; :"2s" -> 21; :"3s" -> 22; :"4s" -> 23; :"0s" -> 24; :"5s" -> 25; :"6s" -> 26; :"7s" -> 27; :"8s" -> 28; :"9s" -> 29;
      :"1z" -> 30; :"2z" -> 31; :"3z" -> 32; :"4z" -> 33; :"0z" -> 34; :"5z" -> 35; :"6z" -> 36; :"7z" -> 37;
      :"1f" -> 38; :"2f" -> 39; :"3f" -> 40; :"4f" -> 41;
      :"1g" -> 42; :"2g" -> 43; :"3g" -> 44; :"4g" -> 45;
      :"1a" -> 46; :"2a" -> 47; :"3a" -> 48; :"4a" -> 49;
      :"1y" -> 50; :"2y" -> 51;
      :"1j" -> 52; :"2j" -> 53; :"3j" -> 54; :"4j" -> 55; :"5j" -> 56; :"6j" -> 57; :"7j" -> 58; :"8j" -> 59; :"9j" -> 60;
      :"1k" -> 61; :"2k" -> 62; :"3k" -> 63; :"4k" -> 64;
      :"1q" -> 65; :"2q" -> 66; :"3q" -> 67; :"4q" -> 68;
      :"1x" -> 69; :"2x" -> 70
    end
  end
  def sort_tiles(tiles, joker_assignment \\ %{}) do
    tiles
    |> Enum.with_index()
    |> Enum.sort_by(fn {tile, ix} -> sort_value(Map.get(joker_assignment, ix, tile)) end)
    |> Enum.map(fn {tile, _ix} -> tile end)
  end

  def next_turn(seat, iterations \\ 1) do
    iterations = rem(iterations, 4)
    next = cond do
      seat == :east  -> :south
      seat == :south -> :west
      seat == :west  -> :north
      seat == :north -> :east
    end
    if iterations <= 0 do seat else next_turn(next, iterations - 1) end
  end
  def prev_turn(seat, iterations \\ 1) do
    iterations = rem(iterations, 4)
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

  def get_wind_name(wind) do
    case wind do
      :east  -> "東"
      :south -> "南"
      :west  -> "西"
      :north -> "北"
    end
  end

  def to_registry_name(name, ruleset, session_id) do
    name <> "-" <> ruleset <> "-" <> session_id
  end

end