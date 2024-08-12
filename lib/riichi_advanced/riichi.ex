defmodule Riichi do

  @pred %{:"2m"=>:"1m", :"3m"=>:"2m", :"4m"=>:"3m", :"5m"=>:"4m", :"6m"=>:"5m", :"7m"=>:"6m", :"8m"=>:"7m", :"9m"=>:"8m", :"0m"=>:"4m",
          :"2p"=>:"1p", :"3p"=>:"2p", :"4p"=>:"3p", :"5p"=>:"4p", :"6p"=>:"5p", :"7p"=>:"6p", :"8p"=>:"7p", :"9p"=>:"8p", :"0p"=>:"4p",
          :"2s"=>:"1s", :"3s"=>:"2s", :"4s"=>:"3s", :"5s"=>:"4s", :"6s"=>:"5s", :"7s"=>:"6s", :"8s"=>:"7s", :"9s"=>:"8s", :"0s"=>:"4s"}
  def pred(tile), do: @pred[tile]

  @succ %{:"1m"=>:"2m", :"2m"=>:"3m", :"3m"=>:"4m", :"4m"=>:"5m", :"5m"=>:"6m", :"6m"=>:"7m", :"7m"=>:"8m", :"8m"=>:"9m", :"0m"=>:"6m",
          :"1p"=>:"2p", :"2p"=>:"3p", :"3p"=>:"4p", :"4p"=>:"5p", :"5p"=>:"6p", :"6p"=>:"7p", :"7p"=>:"8p", :"8p"=>:"9p", :"0p"=>:"6p",
          :"1s"=>:"2s", :"2s"=>:"3s", :"3s"=>:"4s", :"4s"=>:"5s", :"5s"=>:"6s", :"6s"=>:"7s", :"7s"=>:"8s", :"8s"=>:"9s", :"0s"=>:"6s"}
  def succ(tile), do: @succ[tile]

  @to_tile %{"1m"=>:"1m", "2m"=>:"2m", "3m"=>:"3m", "4m"=>:"4m", "5m"=>:"5m", "6m"=>:"6m", "7m"=>:"7m", "8m"=>:"8m", "9m"=>:"9m", "0m"=>:"0m",
             "1p"=>:"1p", "2p"=>:"2p", "3p"=>:"3p", "4p"=>:"4p", "5p"=>:"5p", "6p"=>:"6p", "7p"=>:"7p", "8p"=>:"8p", "9p"=>:"9p", "0p"=>:"0p",
             "1s"=>:"1s", "2s"=>:"2s", "3s"=>:"3s", "4s"=>:"4s", "5s"=>:"5s", "6s"=>:"6s", "7s"=>:"7s", "8s"=>:"8s", "9s"=>:"9s", "0s"=>:"0s",
             "1z"=>:"1z", "2z"=>:"2z", "3z"=>:"3z", "4z"=>:"4z", "5z"=>:"5z", "6z"=>:"6z", "7z"=>:"7z",
             :"1m"=>:"1m", :"2m"=>:"2m", :"3m"=>:"3m", :"4m"=>:"4m", :"5m"=>:"5m", :"6m"=>:"6m", :"7m"=>:"7m", :"8m"=>:"8m", :"9m"=>:"9m", :"0m"=>:"0m",
             :"1p"=>:"1p", :"2p"=>:"2p", :"3p"=>:"3p", :"4p"=>:"4p", :"5p"=>:"5p", :"6p"=>:"6p", :"7p"=>:"7p", :"8p"=>:"8p", :"9p"=>:"9p", :"0p"=>:"0p",
             :"1s"=>:"1s", :"2s"=>:"2s", :"3s"=>:"3s", :"4s"=>:"4s", :"5s"=>:"5s", :"6s"=>:"6s", :"7s"=>:"7s", :"8s"=>:"8s", :"9s"=>:"9s", :"0s"=>:"0s",
             :"1z"=>:"1z", :"2z"=>:"2z", :"3z"=>:"3z", :"4z"=>:"4z", :"5z"=>:"5z", :"6z"=>:"6z", :"7z"=>:"7z"}
  def to_tile(tile_str), do: @to_tile[tile_str]
  def from_tile(tile), do: Atom.to_string(tile)

  def normalize_red_fives(hand), do: Enum.map(hand, &case &1 do
    :"0m" -> :"5m"
    :"0p" -> :"5p"
    :"0s" -> :"5s"
    t    -> t
  end)

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

  def can_chii?(hand, tile) do
    hand = normalize_red_fives(hand)
    c1 = Enum.member?(hand, pred(pred(tile)))
    c2 = Enum.member?(hand, pred(tile))
    c3 = Enum.member?(hand, succ(tile))
    c4 = Enum.member?(hand, succ(succ(tile)))
    c1 && c2 || c2 && c3 || c3 && c4
  end

  def can_pon?(hand, tile) do
    hand = normalize_red_fives(hand)
    Enum.count(hand, &tile == &1) >= 2
  end

  def can_daiminkan?(hand, tile) do
    hand = normalize_red_fives(hand)
    Enum.count(hand, &tile == &1) >= 3
  end

end