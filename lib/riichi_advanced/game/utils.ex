defmodule Utils do
  @to_tile %{"1m"=>:"1m", "2m"=>:"2m", "3m"=>:"3m", "4m"=>:"4m", "5m"=>:"5m", "6m"=>:"6m", "7m"=>:"7m", "8m"=>:"8m", "9m"=>:"9m", "0m"=>:"0m",
             "1p"=>:"1p", "2p"=>:"2p", "3p"=>:"3p", "4p"=>:"4p", "5p"=>:"5p", "6p"=>:"6p", "7p"=>:"7p", "8p"=>:"8p", "9p"=>:"9p", "0p"=>:"0p",
             "1s"=>:"1s", "2s"=>:"2s", "3s"=>:"3s", "4s"=>:"4s", "5s"=>:"5s", "6s"=>:"6s", "7s"=>:"7s", "8s"=>:"8s", "9s"=>:"9s", "0s"=>:"0s",
             "1t"=>:"1t", "2t"=>:"2t", "3t"=>:"3t", "4t"=>:"4t", "5t"=>:"5t", "6t"=>:"6t", "7t"=>:"7t", "8t"=>:"8t", "9t"=>:"9t", "0t"=>:"0t",
             "1z"=>:"1z", "2z"=>:"2z", "3z"=>:"3z", "4z"=>:"4z", "5z"=>:"5z", "6z"=>:"6z", "7z"=>:"7z", "0z"=>:"0z",
             "1x"=>:"1x", "2x"=>:"2x",
             "1f"=>:"1f", "2f"=>:"2f", "3f"=>:"3f", "4f"=>:"4f",
             "1g"=>:"1g", "2g"=>:"2g", "3g"=>:"3g", "4g"=>:"4g",
             "1a"=>:"1a", "2a"=>:"2a", "3a"=>:"3a", "4a"=>:"4a",
             "1y"=>:"1y", "2y"=>:"2y",
             "1j"=>:"1j", "2j"=>:"2j", "3j"=>:"3j", "4j"=>:"4j", "5j"=>:"5j", "6j"=>:"6j", "7j"=>:"7j", "8j"=>:"8j", "9j"=>:"9j", "10j"=>:"10j",
             "12j"=>:"12j", "13j"=>:"13j", "15j"=>:"15j", "16j"=>:"16j", "18j"=>:"18j", "19j"=>:"19j", 
             "14j"=>:"4j", "17j"=>:"7j",
             "1k"=>:"1k", "2k"=>:"2k", "3k"=>:"3k", "4k"=>:"4k",
             "1q"=>:"1q", "2q"=>:"2q", "3q"=>:"3q", "4q"=>:"4q",
             "11m"=>:"11m", "12m"=>:"12m", "13m"=>:"13m", "14m"=>:"14m", "15m"=>:"15m", "16m"=>:"16m", "17m"=>:"17m", "18m"=>:"18m", "19m"=>:"19m",
             "11p"=>:"11p", "12p"=>:"12p", "13p"=>:"13p", "14p"=>:"14p", "15p"=>:"15p", "16p"=>:"16p", "17p"=>:"17p", "18p"=>:"18p", "19p"=>:"19p",
             "11s"=>:"11s", "12s"=>:"12s", "13s"=>:"13s", "14s"=>:"14s", "15s"=>:"15s", "16s"=>:"16s", "17s"=>:"17s", "18s"=>:"18s", "19s"=>:"19s",
             "11t"=>:"11t", "12t"=>:"12t", "13t"=>:"13t", "14t"=>:"14t", "15t"=>:"15t", "16t"=>:"16t", "17t"=>:"17t", "18t"=>:"18t", "19t"=>:"19t",
             "11z"=>:"11z", "12z"=>:"12z", "13z"=>:"13z", "14z"=>:"14z", "15z"=>:"15z", "16z"=>:"16z", "17z"=>:"17z",
             "110m"=>:"110m", "110p"=>:"110p", "110s"=>:"110s", "110t"=>:"110t",
             "10m"=>:"10m", "10p"=>:"10p", "10s"=>:"10s", "10t"=>:"10t",
             "25z"=>:"25z", "26z"=>:"26z", "27z"=>:"27z",
             :"1m"=>:"1m", :"2m"=>:"2m", :"3m"=>:"3m", :"4m"=>:"4m", :"5m"=>:"5m", :"6m"=>:"6m", :"7m"=>:"7m", :"8m"=>:"8m", :"9m"=>:"9m", :"0m"=>:"0m",
             :"1p"=>:"1p", :"2p"=>:"2p", :"3p"=>:"3p", :"4p"=>:"4p", :"5p"=>:"5p", :"6p"=>:"6p", :"7p"=>:"7p", :"8p"=>:"8p", :"9p"=>:"9p", :"0p"=>:"0p",
             :"1s"=>:"1s", :"2s"=>:"2s", :"3s"=>:"3s", :"4s"=>:"4s", :"5s"=>:"5s", :"6s"=>:"6s", :"7s"=>:"7s", :"8s"=>:"8s", :"9s"=>:"9s", :"0s"=>:"0s",
             :"1t"=>:"1t", :"2t"=>:"2t", :"3t"=>:"3t", :"4t"=>:"4t", :"5t"=>:"5t", :"6t"=>:"6t", :"7t"=>:"7t", :"8t"=>:"8t", :"9t"=>:"9t", :"0t"=>:"0t",
             :"1z"=>:"1z", :"2z"=>:"2z", :"3z"=>:"3z", :"4z"=>:"4z", :"5z"=>:"5z", :"6z"=>:"6z", :"7z"=>:"7z", :"0z"=>:"0z",
             :"1x"=>:"1x", :"2x"=>:"2x",
             :"1f"=>:"1f", :"2f"=>:"2f", :"3f"=>:"3f", :"4f"=>:"4f",
             :"1g"=>:"1g", :"2g"=>:"2g", :"3g"=>:"3g", :"4g"=>:"4g",
             :"1a"=>:"1a", :"2a"=>:"2a", :"3a"=>:"3a", :"4a"=>:"4a",
             :"1y"=>:"1y", :"2y"=>:"2y",
             :"1j"=>:"1j", :"2j"=>:"2j", :"3j"=>:"3j", :"4j"=>:"4j", :"5j"=>:"5j", :"6j"=>:"6j", :"7j"=>:"7j", :"8j"=>:"8j", :"9j"=>:"9j", :"10j"=>:"10j",
             :"12j"=>:"12j", :"13j"=>:"13j", :"15j"=>:"15j", :"16j"=>:"16j", :"18j"=>:"18j", :"19j"=>:"19j",
             :"1k"=>:"1k", :"2k"=>:"2k", :"3k"=>:"3k", :"4k"=>:"4k",
             :"1q"=>:"1q", :"2q"=>:"2q", :"3q"=>:"3q", :"4q"=>:"4q",
             :"11m"=>:"11m", :"12m"=>:"12m", :"13m"=>:"13m", :"14m"=>:"14m", :"15m"=>:"15m", :"16m"=>:"16m", :"17m"=>:"17m", :"18m"=>:"18m", :"19m"=>:"19m",
             :"11p"=>:"11p", :"12p"=>:"12p", :"13p"=>:"13p", :"14p"=>:"14p", :"15p"=>:"15p", :"16p"=>:"16p", :"17p"=>:"17p", :"18p"=>:"18p", :"19p"=>:"19p",
             :"11s"=>:"11s", :"12s"=>:"12s", :"13s"=>:"13s", :"14s"=>:"14s", :"15s"=>:"15s", :"16s"=>:"16s", :"17s"=>:"17s", :"18s"=>:"18s", :"19s"=>:"19s",
             :"11t"=>:"11t", :"12t"=>:"12t", :"13t"=>:"13t", :"14t"=>:"14t", :"15t"=>:"15t", :"16t"=>:"16t", :"17t"=>:"17t", :"18t"=>:"18t", :"19t"=>:"19t",
             :"11z"=>:"11z", :"12z"=>:"12z", :"13z"=>:"13z", :"14z"=>:"14z", :"15z"=>:"15z", :"16z"=>:"16z", :"17z"=>:"17z",
             :"110m"=>:"110m", :"110p"=>:"110p", :"110s"=>:"110s", :"110t"=>:"110t",
             :"10m"=>:"10m", :"10p"=>:"10p", :"10s"=>:"10s", :"10t"=>:"10t",
             :"25z"=>:"25z", :"26z"=>:"26z", :"27z"=>:"27z",
            }
  def to_tile(tile_spec) do
    case tile_spec do
      [tile_spec | attrs] -> {@to_tile[tile_spec], attrs}
      %{"tile" => tile_spec, "attrs" => attrs} -> {@to_tile[tile_spec], attrs}
      _ -> @to_tile[tile_spec]
    end
  end

  def tile_to_string(tile) do
    tile |> strip_attrs() |> Atom.to_string()
  end

  def tile_to_attrs(tile) do
    case tile do
      {tile, attrs} -> [Atom.to_string(tile) | attrs]
      tile          -> [Atom.to_string(tile)]
    end
  end

  defp to_attr_tile(tile) do
    case tile do
      {tile, attrs} -> {tile, attrs}
      tile          -> {tile, []}
    end
  end

  def add_attr(tile, attrs) do
    case tile do
      {tile, existing_attrs} -> {tile, Enum.uniq(existing_attrs ++ attrs)}
      _ when is_list(tile) -> Enum.map(tile, &add_attr(&1, attrs))
      tile -> {tile, attrs}
    end
  end

  def remove_attr(tile, attrs) do
    case tile do
      {tile, existing_attrs} ->
        case Enum.uniq(existing_attrs -- attrs) do
          []              -> tile
          remaining_attrs -> {tile, remaining_attrs}
        end
      _ when is_list(tile) -> Enum.map(tile, &remove_attr(&1, attrs))
      tile -> tile
    end
  end

  def has_attr?(tile, attrs) do
    case tile do
      {_tile, existing_attrs} -> Enum.all?(attrs, & &1 in existing_attrs)
      _ when is_list(tile) -> Enum.any?(tile, &has_attr?(&1, attrs))
      _ -> Enum.empty?(attrs)
    end
  end

  def strip_attrs(tile) do
    case tile do
      {tile, _attrs} -> tile
      _ when is_list(tile) -> Enum.map(tile, &strip_attrs/1)
      tile -> tile
    end
  end

  @tile_color %{:"1m"=>"pink", :"2m"=>"pink", :"3m"=>"pink", :"4m"=>"pink", :"5m"=>"pink", :"6m"=>"pink", :"7m"=>"pink", :"8m"=>"pink", :"9m"=>"pink", :"0m"=>"red",
                :"1p"=>"lightblue", :"2p"=>"lightblue", :"3p"=>"lightblue", :"4p"=>"lightblue", :"5p"=>"lightblue", :"6p"=>"lightblue", :"7p"=>"lightblue", :"8p"=>"lightblue", :"9p"=>"lightblue", :"0p"=>"red",
                :"1s"=>"lightgreen", :"2s"=>"lightgreen", :"3s"=>"lightgreen", :"4s"=>"lightgreen", :"5s"=>"lightgreen", :"6s"=>"lightgreen", :"7s"=>"lightgreen", :"8s"=>"lightgreen", :"9s"=>"lightgreen", :"0s"=>"red",
                :"1x"=>"orange", :"2x"=>"orange",
                :"11m"=>"cyan", :"12m"=>"cyan", :"13m"=>"cyan", :"14m"=>"cyan", :"15m"=>"cyan", :"16m"=>"cyan", :"17m"=>"cyan", :"18m"=>"cyan", :"19m"=>"cyan",
                :"11p"=>"cyan", :"12p"=>"cyan", :"13p"=>"cyan", :"14p"=>"cyan", :"15p"=>"cyan", :"16p"=>"cyan", :"17p"=>"cyan", :"18p"=>"cyan", :"19p"=>"cyan",
                :"11s"=>"cyan", :"12s"=>"cyan", :"13s"=>"cyan", :"14s"=>"cyan", :"15s"=>"cyan", :"16s"=>"cyan", :"17s"=>"cyan", :"18s"=>"cyan", :"19s"=>"cyan",
                :"11z"=>"cyan", :"12z"=>"cyan", :"13z"=>"cyan", :"14z"=>"cyan", :"15z"=>"cyan", :"16z"=>"cyan", :"17z"=>"cyan"}
  def tile_color(tile), do: Map.get(@tile_color, tile, "white")

  # print tile, print hand
  # print tile, print hand
  def pt(tile) do
    {tile, _attrs} = to_attr_tile(tile)
    %{bold: true, color: tile_color(tile), text: "#{tile}"}
  end
  def ph(tiles), do: Enum.map(tiles, &pt/1)

  def sort_value(tile) do
    {tile, _attrs} = to_attr_tile(tile)
    case tile do
      :"1m" ->  10; :"2m" ->  20; :"3m" ->  30; :"4m" ->  40; :"0m" ->  50; :"5m" ->  51; :"6m" ->  60; :"7m" ->  70; :"8m" ->  80; :"9m" ->  90; :"10m" -> 95;
      :"1p" -> 110; :"2p" -> 120; :"3p" -> 130; :"4p" -> 140; :"0p" -> 150; :"5p" -> 151; :"6p" -> 160; :"7p" -> 170; :"8p" -> 180; :"9p" -> 190; :"10p" -> 195;
      :"1s" -> 210; :"2s" -> 220; :"3s" -> 230; :"4s" -> 240; :"0s" -> 250; :"5s" -> 251; :"6s" -> 260; :"7s" -> 270; :"8s" -> 280; :"9s" -> 290; :"10s" -> 295;
      :"1t" -> 310; :"2t" -> 320; :"3t" -> 330; :"4t" -> 340; :"0t" -> 350; :"5t" -> 351; :"6t" -> 360; :"7t" -> 370; :"8t" -> 380; :"9t" -> 390; :"10t" -> 395;
      :"11m" ->  12; :"12m" ->  22; :"13m" ->  32; :"14m" ->  42; :"15m" ->  52; :"16m" ->  62; :"17m" ->  72; :"18m" ->  82; :"19m" ->  92; :"110m" ->  96;
      :"11p" -> 112; :"12p" -> 122; :"13p" -> 132; :"14p" -> 142; :"15p" -> 152; :"16p" -> 162; :"17p" -> 172; :"18p" -> 182; :"19p" -> 192; :"110p" -> 196;
      :"11s" -> 212; :"12s" -> 222; :"13s" -> 232; :"14s" -> 242; :"15s" -> 252; :"16s" -> 262; :"17s" -> 272; :"18s" -> 282; :"19s" -> 292; :"110s" -> 296;
      :"11t" -> 312; :"12t" -> 322; :"13t" -> 332; :"14t" -> 342; :"15t" -> 352; :"16t" -> 362; :"17t" -> 372; :"18t" -> 382; :"19t" -> 392; :"110t" -> 396;
      :"1z" -> 1310; :"2z" -> 1320; :"3z" -> 1330; :"4z" -> 1340; :"0z" -> 1350; :"5z" -> 1351; :"6z" -> 1360; :"7z" -> 1370;
      :"11z" -> 1312; :"12z" -> 1322; :"13z" -> 1332; :"14z" -> 1342; :"15z" -> 1352; :"16z" -> 1362; :"17z" -> 1372;
      :"25z" -> 1353; :"26z" -> 1363; :"27z" -> 1373;
      :"1f" -> 2380; :"2f" -> 2390; :"3f" -> 2400; :"4f" -> 2410;
      :"1g" -> 2420; :"2g" -> 2430; :"3g" -> 2440; :"4g" -> 2450;
      :"1a" -> 2460; :"2a" -> 2470; :"3a" -> 2480; :"4a" -> 2490;
      :"1y" -> 2500; :"2y" -> 2510;
      :"1j" -> 2520; :"2j" -> 2530; :"7j" -> 2540; :"8j" -> 2550; :"9j" -> 2560; :"3j" -> 2570; :"4j" -> 2580; :"10j" -> 2590; :"5j" -> 2600; :"6j" -> 2610; 
      :"12j" -> 2531; :"18j" -> 2551; :"19j" -> 2561; :"13j" -> 2571; :"15j" -> 2601; :"16j" -> 2611; 
      :"1k" -> 2620; :"2k" -> 2630; :"3k" -> 2640; :"4k" -> 2650;
      :"1q" -> 2660; :"2q" -> 2670; :"3q" -> 2680; :"4q" -> 2690;
      :"1x" -> 5000; :"2x" -> 5001
      _ ->
        IO.puts("Unrecognized tile #{inspect(tile)}, cannot sort!")
        0
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

  # tile1 must have at least the attributes of tile2
  def same_tile(tile1, tile2, tile_aliases \\ %{}) do
    l1 = strip_attrs([tile1 | adjacent_jokers(tile1, tile_aliases)])
    l2 = strip_attrs([tile2 | adjacent_jokers(tile2, tile_aliases)])
    same_id = Enum.any?(l1, fn tile -> tile in l2 end)
    {_, attrs2} = to_attr_tile(tile2)
    attrs_match = has_attr?(tile1, attrs2)
    same_id && attrs_match
  end

  def count_tiles(hand, tiles, tile_aliases \\ %{}) do
    for hand_tile <- hand do
      if Enum.any?(tiles, &same_tile(hand_tile, &1, tile_aliases)) do 1 else 0 end
    end |> Enum.sum()
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

  def try_integer(value) do
    if value == trunc(value) do trunc(value) else value end
  end

end