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
             "1j"=>:"1j", "2j"=>:"2j", "3j"=>:"3j", "4j"=>:"4j", "5j"=>:"5j", "6j"=>:"6j", "7j"=>:"7j", "8j"=>:"8j", "9j"=>:"9j", "10j"=>:"10j",
             "1k"=>:"1k", "2k"=>:"2k", "3k"=>:"3k", "4k"=>:"4k",
             "1q"=>:"1q", "2q"=>:"2q", "3q"=>:"3q", "4q"=>:"4q",
             "11m"=>:"11m", "12m"=>:"12m", "13m"=>:"13m", "14m"=>:"14m", "15m"=>:"15m", "16m"=>:"16m", "17m"=>:"17m", "18m"=>:"18m", "19m"=>:"19m",
             "11p"=>:"11p", "12p"=>:"12p", "13p"=>:"13p", "14p"=>:"14p", "15p"=>:"15p", "16p"=>:"16p", "17p"=>:"17p", "18p"=>:"18p", "19p"=>:"19p",
             "11s"=>:"11s", "12s"=>:"12s", "13s"=>:"13s", "14s"=>:"14s", "15s"=>:"15s", "16s"=>:"16s", "17s"=>:"17s", "18s"=>:"18s", "19s"=>:"19s",
             "11z"=>:"11z", "12z"=>:"12z", "13z"=>:"13z", "14z"=>:"14z", "15z"=>:"15z", "16z"=>:"16z", "17z"=>:"17z",
             "10m"=>:"10m", "10p"=>:"10p", "10s"=>:"10s",
             "25z"=>:"25z", "26z"=>:"26z", "27z"=>:"27z",
             :"1m"=>:"1m", :"2m"=>:"2m", :"3m"=>:"3m", :"4m"=>:"4m", :"5m"=>:"5m", :"6m"=>:"6m", :"7m"=>:"7m", :"8m"=>:"8m", :"9m"=>:"9m", :"0m"=>:"0m",
             :"1p"=>:"1p", :"2p"=>:"2p", :"3p"=>:"3p", :"4p"=>:"4p", :"5p"=>:"5p", :"6p"=>:"6p", :"7p"=>:"7p", :"8p"=>:"8p", :"9p"=>:"9p", :"0p"=>:"0p",
             :"1s"=>:"1s", :"2s"=>:"2s", :"3s"=>:"3s", :"4s"=>:"4s", :"5s"=>:"5s", :"6s"=>:"6s", :"7s"=>:"7s", :"8s"=>:"8s", :"9s"=>:"9s", :"0s"=>:"0s",
             :"1z"=>:"1z", :"2z"=>:"2z", :"3z"=>:"3z", :"4z"=>:"4z", :"5z"=>:"5z", :"6z"=>:"6z", :"7z"=>:"7z", :"0z"=>:"0z",
             :"1x"=>:"1x", :"2x"=>:"2x",
             :"1f"=>:"1f", :"2f"=>:"2f", :"3f"=>:"3f", :"4f"=>:"4f",
             :"1g"=>:"1g", :"2g"=>:"2g", :"3g"=>:"3g", :"4g"=>:"4g",
             :"1a"=>:"1a", :"2a"=>:"2a", :"3a"=>:"3a", :"4a"=>:"4a",
             :"1y"=>:"1y", :"2y"=>:"2y",
             :"1j"=>:"1j", :"2j"=>:"2j", :"3j"=>:"3j", :"4j"=>:"4j", :"5j"=>:"5j", :"6j"=>:"6j", :"7j"=>:"7j", :"8j"=>:"8j", :"9j"=>:"9j", :"10j"=>:"10j",
             :"1k"=>:"1k", :"2k"=>:"2k", :"3k"=>:"3k", :"4k"=>:"4k",
             :"1q"=>:"1q", :"2q"=>:"2q", :"3q"=>:"3q", :"4q"=>:"4q",
             :"11m"=>:"11m", :"12m"=>:"12m", :"13m"=>:"13m", :"14m"=>:"14m", :"15m"=>:"15m", :"16m"=>:"16m", :"17m"=>:"17m", :"18m"=>:"18m", :"19m"=>:"19m",
             :"11p"=>:"11p", :"12p"=>:"12p", :"13p"=>:"13p", :"14p"=>:"14p", :"15p"=>:"15p", :"16p"=>:"16p", :"17p"=>:"17p", :"18p"=>:"18p", :"19p"=>:"19p",
             :"11s"=>:"11s", :"12s"=>:"12s", :"13s"=>:"13s", :"14s"=>:"14s", :"15s"=>:"15s", :"16s"=>:"16s", :"17s"=>:"17s", :"18s"=>:"18s", :"19s"=>:"19s",
             :"11z"=>:"11z", :"12z"=>:"12z", :"13z"=>:"13z", :"14z"=>:"14z", :"15z"=>:"15z", :"16z"=>:"16z", :"17z"=>:"17z",
             :"10m"=>:"10m", :"10p"=>:"10p", :"10s"=>:"10s",
             :"25z"=>:"25z", :"26z"=>:"26z", :"27z"=>:"27z",
            }
  def to_tile(tile_str), do: @to_tile[tile_str]

  @tile_color %{:"1m"=>"pink", :"2m"=>"pink", :"3m"=>"pink", :"4m"=>"pink", :"5m"=>"pink", :"6m"=>"pink", :"7m"=>"pink", :"8m"=>"pink", :"9m"=>"pink", :"0m"=>"red",
                :"1p"=>"lightblue", :"2p"=>"lightblue", :"3p"=>"lightblue", :"4p"=>"lightblue", :"5p"=>"lightblue", :"6p"=>"lightblue", :"7p"=>"lightblue", :"8p"=>"lightblue", :"9p"=>"lightblue", :"0p"=>"red",
                :"1s"=>"lightgreen", :"2s"=>"lightgreen", :"3s"=>"lightgreen", :"4s"=>"lightgreen", :"5s"=>"lightgreen", :"6s"=>"lightgreen", :"7s"=>"lightgreen", :"8s"=>"lightgreen", :"9s"=>"lightgreen", :"0s"=>"red",
                :"1z"=>"white", :"2z"=>"white", :"3z"=>"white", :"4z"=>"white", :"5z"=>"white", :"6z"=>"white", :"7z"=>"white", :"0z"=>"white",
                :"1x"=>"orange", :"2x"=>"orange",
                :"1f"=>"white", :"2f"=>"white", :"3f"=>"white", :"4f"=>"white",
                :"1g"=>"white", :"2g"=>"white", :"3g"=>"white", :"4g"=>"white",
                :"1a"=>"white", :"2a"=>"white", :"3a"=>"white", :"4a"=>"white",
                :"1y"=>"white", :"2y"=>"white",
                :"1j"=>"white", :"2j"=>"white", :"3j"=>"white", :"4j"=>"white", :"5j"=>"white", :"6j"=>"white", :"7j"=>"white", :"8j"=>"white", :"9j"=>"white", :"10j"=>"white",
                :"1k"=>"white", :"2k"=>"white", :"3k"=>"white", :"4k"=>"white",
                :"1q"=>"white", :"2q"=>"white", :"3q"=>"white", :"4q"=>"white",
                :"11m"=>"cyan", :"12m"=>"cyan", :"13m"=>"cyan", :"14m"=>"cyan", :"15m"=>"cyan", :"16m"=>"cyan", :"17m"=>"cyan", :"18m"=>"cyan", :"19m"=>"cyan",
                :"11p"=>"cyan", :"12p"=>"cyan", :"13p"=>"cyan", :"14p"=>"cyan", :"15p"=>"cyan", :"16p"=>"cyan", :"17p"=>"cyan", :"18p"=>"cyan", :"19p"=>"cyan",
                :"11s"=>"cyan", :"12s"=>"cyan", :"13s"=>"cyan", :"14s"=>"cyan", :"15s"=>"cyan", :"16s"=>"cyan", :"17s"=>"cyan", :"18s"=>"cyan", :"19s"=>"cyan",
                :"11z"=>"cyan", :"12z"=>"cyan", :"13z"=>"cyan", :"14z"=>"cyan", :"15z"=>"cyan", :"16z"=>"cyan", :"17z"=>"cyan"}
  def tile_color(tile), do: @tile_color[tile]

  # print tile, print hand
  def pt(tile), do: %{bold: true, color: tile_color(tile), text: "#{tile}"}
  def ph(tiles), do: Enum.map(tiles, &pt/1)

  def sort_value(tile) do
    case tile do
      :"1m" ->  10; :"2m" ->  20; :"3m" ->  30; :"4m" ->  40; :"0m" ->  50; :"5m" ->  51; :"6m" ->  60; :"7m" ->  70; :"8m" ->  80; :"9m" ->  90; :"10m" -> 91;
      :"1p" -> 110; :"2p" -> 120; :"3p" -> 130; :"4p" -> 140; :"0p" -> 150; :"5p" -> 151; :"6p" -> 160; :"7p" -> 170; :"8p" -> 180; :"9p" -> 190; :"10p" -> 191;
      :"1s" -> 210; :"2s" -> 220; :"3s" -> 230; :"4s" -> 240; :"0s" -> 250; :"5s" -> 251; :"6s" -> 260; :"7s" -> 270; :"8s" -> 280; :"9s" -> 290; :"10s" -> 291;
      :"1z" -> 310; :"2z" -> 320; :"3z" -> 330; :"4z" -> 340; :"0z" -> 350; :"5z" -> 351; :"6z" -> 360; :"7z" -> 370;
      :"11m" ->  12; :"12m" ->  22; :"13m" ->  32; :"14m" ->  42; :"15m" ->  52; :"16m" ->  62; :"17m" ->  72; :"18m" ->  82; :"19m" ->  92;
      :"11p" -> 112; :"12p" -> 122; :"13p" -> 132; :"14p" -> 142; :"15p" -> 152; :"16p" -> 162; :"17p" -> 172; :"18p" -> 182; :"19p" -> 192;
      :"11s" -> 212; :"12s" -> 222; :"13s" -> 232; :"14s" -> 242; :"15s" -> 252; :"16s" -> 262; :"17s" -> 272; :"18s" -> 282; :"19s" -> 292;
      :"11z" -> 312; :"12z" -> 322; :"13z" -> 332; :"14z" -> 342; :"15z" -> 352; :"16z" -> 362; :"17z" -> 372;
      :"25z" -> 353; :"26z" -> 363; :"27z" -> 373;
      :"1f" -> 380; :"2f" -> 390; :"3f" -> 400; :"4f" -> 410;
      :"1g" -> 420; :"2g" -> 430; :"3g" -> 440; :"4g" -> 450;
      :"1a" -> 460; :"2a" -> 470; :"3a" -> 480; :"4a" -> 490;
      :"1y" -> 500; :"2y" -> 510;
      :"1j" -> 520; :"2j" -> 530; :"7j" -> 540; :"8j" -> 550; :"9j" -> 560; :"3j" -> 570; :"4j" -> 580; :"10j" -> 590; :"5j" -> 600; :"6j" -> 610; 
      :"1k" -> 620; :"2k" -> 630; :"3k" -> 640; :"4k" -> 650;
      :"1q" -> 660; :"2q" -> 670; :"3q" -> 680; :"4q" -> 690;
      :"1x" -> 1000; :"2x" -> 1001
    end
  end
  def sort_tiles(tiles, joker_assignment \\ %{}) do
    tiles
    |> Enum.with_index()
    |> Enum.sort_by(fn {tile, ix} -> sort_value(Map.get(joker_assignment, ix, tile)) end)
    |> Enum.map(fn {tile, _ix} -> tile end)
  end

  # find all jokers that map to the same tile(s) as the given one
  # together with the tile(s) they are connected by
  def adjacent_jokers(joker, tile_aliases) do
    tile_aliases
    |> Enum.filter(fn {_t, aliases} -> joker in aliases end)
    |> Enum.flat_map(fn {t, aliases} -> [t | aliases] end)
    |> Enum.uniq()
  end

  def same_tile(tile1, tile2, tile_aliases) do
    l1 = [tile1] ++ adjacent_jokers(tile1, tile_aliases)
    l2 = [tile2] ++ adjacent_jokers(tile2, tile_aliases)
    Enum.any?(l1, fn tile -> tile in l2 end)
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