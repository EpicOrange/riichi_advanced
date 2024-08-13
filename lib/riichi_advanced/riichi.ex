defmodule Riichi do

  @pred %{:"2m"=>:"1m", :"3m"=>:"2m", :"4m"=>:"3m", :"5m"=>:"4m", :"6m"=>:"5m", :"7m"=>:"6m", :"8m"=>:"7m", :"9m"=>:"8m", :"0m"=>:"4m",
          :"2p"=>:"1p", :"3p"=>:"2p", :"4p"=>:"3p", :"5p"=>:"4p", :"6p"=>:"5p", :"7p"=>:"6p", :"8p"=>:"7p", :"9p"=>:"8p", :"0p"=>:"4p",
          :"2s"=>:"1s", :"3s"=>:"2s", :"4s"=>:"3s", :"5s"=>:"4s", :"6s"=>:"5s", :"7s"=>:"6s", :"8s"=>:"7s", :"9s"=>:"8s", :"0s"=>:"4s"}
  def pred(tile), do: @pred[tile]

  @succ %{:"1m"=>:"2m", :"2m"=>:"3m", :"3m"=>:"4m", :"4m"=>:"5m", :"5m"=>:"6m", :"6m"=>:"7m", :"7m"=>:"8m", :"8m"=>:"9m", :"0m"=>:"6m",
          :"1p"=>:"2p", :"2p"=>:"3p", :"3p"=>:"4p", :"4p"=>:"5p", :"5p"=>:"6p", :"6p"=>:"7p", :"7p"=>:"8p", :"8p"=>:"9p", :"0p"=>:"6p",
          :"1s"=>:"2s", :"2s"=>:"3s", :"3s"=>:"4s", :"4s"=>:"5s", :"5s"=>:"6s", :"6s"=>:"7s", :"7s"=>:"8s", :"8s"=>:"9s", :"0s"=>:"6s"}
  def succ(tile), do: @succ[tile]

  def offset_tile(tile, n) do
    if n == 0 || n < -10 || n > 10 do
      tile
    else
      if n < 0 do
        offset_tile(pred(tile), n+1)
      else
        offset_tile(succ(tile), n-1)
      end
    end
  end

  @to_tile %{"1m"=>:"1m", "2m"=>:"2m", "3m"=>:"3m", "4m"=>:"4m", "5m"=>:"5m", "6m"=>:"6m", "7m"=>:"7m", "8m"=>:"8m", "9m"=>:"9m", "0m"=>:"0m",
             "1p"=>:"1p", "2p"=>:"2p", "3p"=>:"3p", "4p"=>:"4p", "5p"=>:"5p", "6p"=>:"6p", "7p"=>:"7p", "8p"=>:"8p", "9p"=>:"9p", "0p"=>:"0p",
             "1s"=>:"1s", "2s"=>:"2s", "3s"=>:"3s", "4s"=>:"4s", "5s"=>:"5s", "6s"=>:"6s", "7s"=>:"7s", "8s"=>:"8s", "9s"=>:"9s", "0s"=>:"0s",
             "1z"=>:"1z", "2z"=>:"2z", "3z"=>:"3z", "4z"=>:"4z", "5z"=>:"5z", "6z"=>:"6z", "7z"=>:"7z",
             :"1m"=>:"1m", :"2m"=>:"2m", :"3m"=>:"3m", :"4m"=>:"4m", :"5m"=>:"5m", :"6m"=>:"6m", :"7m"=>:"7m", :"8m"=>:"8m", :"9m"=>:"9m", :"0m"=>:"0m",
             :"1p"=>:"1p", :"2p"=>:"2p", :"3p"=>:"3p", :"4p"=>:"4p", :"5p"=>:"5p", :"6p"=>:"6p", :"7p"=>:"7p", :"8p"=>:"8p", :"9p"=>:"9p", :"0p"=>:"0p",
             :"1s"=>:"1s", :"2s"=>:"2s", :"3s"=>:"3s", :"4s"=>:"4s", :"5s"=>:"5s", :"6s"=>:"6s", :"7s"=>:"7s", :"8s"=>:"8s", :"9s"=>:"9s", :"0s"=>:"0s",
             :"1z"=>:"1z", :"2z"=>:"2z", :"3z"=>:"3z", :"4z"=>:"4z", :"5z"=>:"5z", :"6z"=>:"6z", :"7z"=>:"7z"}
  def to_tile(tile_str), do: @to_tile[tile_str]

  def to_red(tile) do
    case tile do
      :"5m" -> :"0m"
      :"5p" -> :"0p"
      :"5s" -> :"0s"
      _     -> nil
    end
  end

  def normalize_red_five(tile) do
    case tile do
      :"0m" -> :"5m"
      :"0p" -> :"5p"
      :"0s" -> :"5s"
      t    -> t
    end
  end
  def normalize_red_fives(hand), do: Enum.map(hand, &normalize_red_five/1)

  def is_manzu?(tile), do: tile in [:"1m", :"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m", :"9m", :"0m"]
  def is_pinzu?(tile), do: tile in [:"1p", :"2p", :"3p", :"4p", :"5p", :"6p", :"7p", :"8p", :"9p", :"0p"]
  def is_souzu?(tile), do: tile in [:"1s", :"2s", :"3s", :"4s", :"5s", :"6s", :"7s", :"8s", :"9s", :"0s"]
  def is_jihai?(tile), do: tile in [:"1z", :"2z", :"3z", :"4z", :"5z", :"6z", :"7z"]
  def is_num?(tile, num) do
    tile in case num do
      1 -> [:"1m", :"1p", :"1s"]
      2 -> [:"2m", :"2p", :"2s"]
      3 -> [:"3m", :"3p", :"3s"]
      4 -> [:"4m", :"4p", :"4s"]
      5 -> [:"5m", :"5p", :"5s", :"0m", :"0p", :"0s"]
      6 -> [:"6m", :"6p", :"6s"]
      7 -> [:"7m", :"7p", :"7s"]
      8 -> [:"8m", :"8p", :"8s"]
      9 -> [:"9m", :"9p", :"9s"]
    end
  end

  def sort_tiles(tiles) do
    Enum.sort_by(tiles, &case &1 do
      :"1m" -> 0; :"2m" -> 1; :"3m" -> 2; :"4m" -> 3; :"0m" -> 4; :"5m" -> 5; :"6m" -> 6; :"7m" -> 7; :"8m" -> 8; :"9m" -> 9;
      :"1p" -> 10; :"2p" -> 11; :"3p" -> 12; :"4p" -> 13; :"0p" -> 14; :"5p" -> 15; :"6p" -> 16; :"7p" -> 17; :"8p" -> 18; :"9p" -> 19;
      :"1s" -> 20; :"2s" -> 21; :"3s" -> 22; :"4s" -> 23; :"0s" -> 24; :"5s" -> 25; :"6s" -> 26; :"7s" -> 27; :"8s" -> 28; :"9s" -> 29;
      :"1z" -> 30; :"2z" -> 31; :"3z" -> 32; :"4z" -> 33; :"5z" -> 34; :"6z" -> 35; :"7z" -> 36;
      :"1x" -> 37;
    end)
  end

  # return all possible calls of tile, given hand
  # includes returning multiple choices for red fives
  def make_calls(calls_spec, hand, tile) do
    # IO.puts("#{inspect(calls_spec)} / #{inspect(hand)} / #{inspect(tile)}")
    Enum.flat_map(calls_spec, fn call_spec ->
      tile = normalize_red_five(tile)
      other_tiles = Enum.map(call_spec, &offset_tile(tile, &1))
      {_, choices} = Enum.reduce(other_tiles, {hand, []}, fn t, {remaining_hand, tiles} ->
        exists = Enum.member?(remaining_hand, t)
        red_exists = Enum.member?(remaining_hand, to_red(t))
        {List.delete(remaining_hand, if red_exists do to_red(t) else t end),
         [(if exists do [t] else [] end) ++ (if red_exists do [to_red(t)] else [] end) | tiles]}
      end)
      # take the cartesian product of tile choices to get all choice sets
      result = choices
             |> Enum.reduce([[]], fn cs, accs -> for choice <- cs, acc <- accs, do: acc ++ [choice] end)
             |> Enum.map(fn tiles -> sort_tiles(tiles) end)
      # IO.puts("#{inspect(call_spec)}: #{inspect(result)}")
      result
    end)
  end

  def can_call?(calls_spec, hand, tile), do: not Enum.empty?(make_calls(calls_spec, hand, tile))

end