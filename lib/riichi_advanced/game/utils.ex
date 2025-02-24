defmodule RiichiAdvanced.Utils do
  alias RiichiAdvanced.Constants, as: Constants
  alias RiichiAdvanced.GameState.TileBehavior, as: TileBehavior
  alias RiichiAdvanced.Riichi, as: Riichi
  use Nebulex.Caching

  def to_tile(tile_spec) do
    case tile_spec do
      [tile_spec | attrs] -> {Constants.to_tile()[tile_spec], attrs}
      %{"tile" => tile_spec, "attrs" => attrs} -> {Constants.to_tile()[tile_spec], attrs}
      {tile_spec, attrs} -> {Constants.to_tile()[tile_spec], attrs}
      _ -> Constants.to_tile()[tile_spec]
    end
  end

  def is_tile(tile_spec) do
    case tile_spec do
      [tile_spec | _attrs] -> Map.has_key?(Constants.to_tile(), tile_spec)
      %{"tile" => tile_spec, "attrs" => _attrs} -> Map.has_key?(Constants.to_tile(), tile_spec)
      {tile_spec, attrs} -> Map.has_key?(Constants.to_tile(), tile_spec) and is_list(attrs)
      _ -> Map.has_key?(Constants.to_tile(), tile_spec)
    end
  end

  def tile_to_string(tile) do
    if tile != nil do
      tile |> strip_attrs() |> Atom.to_string()
    else nil end
  end

  def tile_to_attrs(tile) do
    case tile do
      {tile, attrs} -> [Atom.to_string(tile) | attrs]
      tile          -> [Atom.to_string(tile)]
    end
  end

  def to_attr_tile(tile) do
    case tile do
      {tile, attrs} -> {tile, attrs}
      tile          -> {tile, []}
    end
  end

  def add_attr(tile, []), do: tile
  def add_attr(tile, attrs) do
    case tile do
      {tile, existing_attrs} -> {tile, Enum.uniq(existing_attrs ++ attrs)}
      _ when is_list(tile) -> Enum.map(tile, &add_attr(&1, attrs))
      _ when is_struct(tile, MapSet) -> MapSet.new(tile, &add_attr(&1, attrs))
      tile -> {tile, attrs}
    end
  end

  def remove_attr(tile, []), do: tile
  def remove_attr(tile, attrs) do
    case tile do
      {tile, existing_attrs} ->
        case Enum.uniq(existing_attrs -- attrs) do
          []              -> tile
          remaining_attrs -> {tile, remaining_attrs}
        end
      _ when is_list(tile) -> Enum.map(tile, &remove_attr(&1, attrs))
      _ when is_struct(tile, MapSet) -> MapSet.new(tile, &remove_attr(&1, attrs))
      tile -> tile
    end
  end

  def has_attr?(tile, attrs) do
    attrs = Enum.map(attrs, &String.replace_prefix(&1, "_", ""))
    case tile do
      {_tile, existing_attrs} ->
        existing_attrs = Enum.map(existing_attrs, &String.replace_prefix(&1, "_", ""))
        Enum.all?(attrs, & &1 in existing_attrs)
      _ when is_list(tile) -> Enum.any?(tile, &has_attr?(&1, attrs))
      _ when is_struct(tile, MapSet) -> MapSet.new(tile, &has_attr?(&1, attrs))
      _ -> Enum.empty?(attrs)
    end
  end

  def strip_attrs(tile) do
    case tile do
      {tile, _attrs} -> tile
      _ when is_list(tile) -> Enum.map(tile, &strip_attrs/1)
      _ when is_struct(tile, MapSet) -> MapSet.new(tile, &strip_attrs/1)
      tile -> tile
    end
  end

  def tile_color(tile), do: Map.get(Constants.tile_color(), tile, "white")

  def remove_spaces(tiles), do: Enum.reject(tiles, &has_matching_tile?([&1], [:"2x", :"3x", :"4x", :"5x", :"6x", :"7x", :"8x"]))

  # print tile, print hand
  # print tile, print hand
  def pt(tile) do
    {tile, attrs} = to_attr_tile(tile)
    tile = if "concealed" in attrs do :"1x" else tile end
    %{bold: true, color: tile_color(tile), text: "#{tile}"}
  end
  def ph(tiles), do: Enum.map(tiles, &pt/1)

  def sort_tiles(tiles, joker_assignment \\ %{}) do
    tiles
    |> Enum.with_index()
    |> Enum.sort_by(fn {tile, ix} -> Constants.sort_value(Map.get(joker_assignment, ix, tile)) end)
    |> Enum.map(fn {tile, _ix} -> tile end)
  end

  # find all jokers that map to the same tile(s) as the given one
  # together with the tile(s) they are connected by
  @decorate cacheable(cache: RiichiAdvanced.Cache, key: {:apply_tile_aliases, tile, TileBehavior.hash(tile_behavior)})
  def apply_tile_aliases(tile, tile_behavior) do
    if is_list(tile) or is_struct(tile, MapSet) do
      Enum.map(tile, &apply_tile_aliases(&1, tile_behavior))
      |> Enum.reduce(MapSet.new(), &MapSet.union/2)
    else
      # every joker is connected to any-tile jokers
      any_tiles = Map.get(tile_behavior.aliases, :any, %{}) |> Map.values() |> Enum.concat()
      for {tile2, attrs_aliases} <- tile_behavior.aliases, {attrs2, aliases} <- attrs_aliases do
        t2 = add_attr(tile2, attrs2)
        cond do
          has_matching_tile?([tile], aliases) ->
            # aliases = MapSet of all possible {tile, attrs} that map to {tile2, attrs2}
            MapSet.new(aliases)
            |> MapSet.delete(:any) # never return :any
            |> MapSet.put(t2)
          same_tile(tile, t2) -> MapSet.new(aliases)
          true -> MapSet.new()
        end
      end |> Enum.reduce(MapSet.new([tile | any_tiles]), &MapSet.union/2)
    end
  end

  # tile1 must have at least the attributes of tile2 (or any of its aliases)
  def same_tile(tile1, tile2) do
    t1 = strip_attrs(tile1)
    {t2, attrs2} = to_attr_tile(tile2)
    same_id = t1 == t2
           or (t2 == :faceup and t1 not in [:"1x", :"2x", :"3x", :"4x"])
           or :any in [t1, t2]
    attrs_match = has_attr?(tile1, Enum.reject(attrs2, &String.starts_with?(&1, "_")))
    same_id and attrs_match
  end
  def same_tile(tile1, tile2, tile_behavior) when tile_behavior.aliases == %{}, do: same_tile(tile1, tile2)
  def same_tile(tile1, tile2, tile_behavior) do
    t1 = strip_attrs(tile1)
    {t2, attrs2} = to_attr_tile(tile2)
    l1 = strip_attrs(apply_tile_aliases(tile1, tile_behavior))
    l2 = strip_attrs(apply_tile_aliases(tile2, tile_behavior))
    same_id = t1 in l2 or t2 in l1
      or (:faceup in l2 and Enum.any?(l1, fn tile -> tile not in [:"1x", :"2x", :"3x", :"4x"] end))
      or :any in l1 or :any in l2
    attrs_match = has_attr?(tile1, attrs2)
    same_id and attrs_match
  end

  def to_manzu(tile) do
    case tile do
      :"0p" -> :"0m"; :"1p" -> :"1m"; :"2p" -> :"2m"; :"3p" -> :"3m"; :"4p" -> :"4m"; :"5p" -> :"5m"; :"6p" -> :"6m"; :"7p" -> :"7m"; :"8p" -> :"8m"; :"9p" -> :"9m"; :"10p" -> :"10m"
      :"0s" -> :"0m"; :"1s" -> :"1m"; :"2s" -> :"2m"; :"3s" -> :"3m"; :"4s" -> :"4m"; :"5s" -> :"5m"; :"6s" -> :"6m"; :"7s" -> :"7m"; :"8s" -> :"8m"; :"9s" -> :"9m"; :"10s" -> :"10m"
      :"7j" -> :"9j"; :"8j" -> :"9j"; :"17j" -> :"19j"; :"18j" -> :"19j";
      _ -> tile
    end
  end

  def same_number(tile1, tile2, tile_behavior \\ %TileBehavior{}) do
    {t1, attrs1} = to_attr_tile(tile1)
    {t2, attrs2} = to_attr_tile(tile2)
    same_tile({to_manzu(t1), attrs1}, {to_manzu(t2), attrs2}, tile_behavior)
  end

  def has_matching_tile?(hand, tiles, tile_behavior \\ %TileBehavior{}) do
    Enum.any?(hand, fn hand_tile ->
      Enum.any?(tiles, &same_tile(hand_tile, &1, tile_behavior))
    end)
  end

  def count_tiles(hand, tiles, tile_behavior \\ %TileBehavior{}) do
    for hand_tile <- hand do
      if Enum.any?(tiles, &same_tile(hand_tile, &1, tile_behavior)) do 1 else 0 end
    end |> Enum.sum()
  end

  def next_turn(seat, iterations \\ 1) do
    iterations = rem(iterations, 4)
    next = case seat do
      :east     -> :south
      :south    -> :west
      :west     -> :north
      :north    -> :east
      :self     -> :shimocha
      :shimocha -> :toimen
      :toimen   -> :kamicha
      :kamicha  -> :self
    end
    if iterations <= 0 do seat else next_turn(next, iterations - 1) end
  end
  def prev_turn(seat, iterations \\ 1) do
    iterations = rem(iterations, 4)
    prev = case seat do
      :east     -> :north
      :south    -> :east
      :west     -> :south
      :north    -> :west
      :self     -> :kamicha
      :shimocha -> :self
      :toimen   -> :shimocha
      :kamicha  -> :toimen
    end
    if iterations <= 0 do seat else prev_turn(prev, iterations - 1) end
  end
  
  def get_seat(seat, direction) do
    case direction do
      :shimocha -> next_turn(seat)
      :toimen   -> next_turn(seat, 2)
      :kamicha  -> next_turn(seat, 3)
      :self     -> next_turn(seat, 4)
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

  def get_wind_name(wind) do
    case wind do
      :east  -> "東"
      :south -> "南"
      :west  -> "西"
      :north -> "北"
    end
  end


  def to_registry_name(name, id) do
    name <> "-" <> id
  end
  def to_registry_name(name, ruleset, room_code) do
    name <> "-" <> ruleset <> "-" <> room_code
  end
  def via_registry(name, ruleset) do
    {:via, Registry, {:game_registry, to_registry_name(name, ruleset)}}
  end
  def via_registry(name, ruleset, room_code) do
    {:via, Registry, {:game_registry, to_registry_name(name, ruleset, room_code)}}
  end
  def registry_lookup(name, ruleset) do
    Registry.lookup(:game_registry, to_registry_name(name, ruleset))
  end
  def registry_lookup(name, ruleset, room_code) do
    Registry.lookup(:game_registry, to_registry_name(name, ruleset, room_code))
  end

  def try_integer(value) do
    if value == trunc(value) do trunc(value) else value end
  end

  def half_score_rounded_up(value) do
    # half rounded up to the nearest 100
    nominal = Integer.floor_div(value, 100)
    # floor_div rounds towards -infinity, so this is effectively ceil(nominal/2) * 100
    -Integer.floor_div(-nominal, 2) * 100
  end

  @valid_tile_colors [
    "red", "blue", "cyan", "gold",
    "orange", "yellow", "green", "lightblue", "purple",
    "gray", "grey", "lightgray", "lightgrey",
    "brown", "pink", "black", "white", "rainbow"
  ]

  def get_tile_class(tile, i \\ -1, assigns \\ %{}, extra_classes \\ [], animate_played \\ false) do
    id = strip_attrs(tile)
    transparent = has_attr?(tile, ["transparent"])
    inactive = has_attr?(tile, ["inactive"])
    hidden = has_attr?(tile, ["hidden"])
    dora = has_attr?(tile, ["dora"])
    last_sideways = has_attr?(tile, ["last_sideways"])
    reversed = transparent and id == :"1x"
    id = if reversed do flip_faceup(tile) |> strip_attrs() else id end
    facedown = has_attr?(tile, ["facedown"]) and Map.get(assigns, :hover_index, nil) != i
    played = animate_played and Map.get(assigns, :your_hand?, true) and Map.get(assigns, :preplayed_index, nil) == i
    sideways = i == Map.get(assigns, :riichi_index, nil) or has_attr?(tile, ["sideways"])
    just_played = Map.get(assigns, :just_discarded?, false) and Map.has_key?(assigns, :pond) and i == length(assigns.pond) - 1
    riichi = Map.has_key?(assigns, :riichi_index) and i == assigns.riichi_index
    number_class = case Riichi.to_num(tile) do
      1 -> ["one"]
      2 -> ["two"]
      3 -> ["three"]
      4 -> ["four"]
      5 -> ["five"]
      6 -> ["six"]
      7 -> ["seven"]
      8 -> ["eight"]
      9 -> ["nine"]
      10 -> ["ten"]
      _  ->
        letter = Riichi.to_letter(tile)
        if letter != nil do [letter] else [] end
    end
    color_classes = Enum.filter(@valid_tile_colors, &has_attr?(tile, [&1]))
    [
      "tile", id,
      facedown && "facedown",
      transparent && "transparent",
      inactive && "inactive",
      hidden && "hidden",
      dora && "dora",
      last_sideways && "last-sideways",
      reversed && "reversed",
      played && "played",
      sideways && "sideways",
      just_played && "just-played",
      riichi && "sideways",
    ] ++ extra_classes ++ number_class ++ color_classes
  end

  def flip_faceup(tile) do
    case tile do
      {:"1x", attrs} ->
        tile_attr = Enum.find(attrs, &is_tile/1)
        if tile_attr != nil do
          to_tile([tile_attr | attrs]) |> remove_attr([tile_attr])
        else tile end
      tile -> tile
    end
  end

  def flip_facedown(tile) do
    case tile do
      :"1x" -> :"1x"
      {:"1x", attrs} -> {:"1x", attrs}
      tile -> {:"1x", tile_to_attrs(tile)}
    end
  end

  def call_to_tiles({_name, call}, replace_am_jokers \\ false) do
    tiles = Enum.map(call, &flip_faceup/1)
    if replace_am_jokers and has_matching_tile?(tiles, [:"1j"]) do
      # replace all american jokers with the nonjoker tile
      nonjoker = Enum.find(tiles, &not same_tile(&1, :"1j")) |> strip_attrs()
      Enum.map(tiles, fn t -> if same_tile(t, :"1j") do nonjoker else t end end)
    else tiles end
  end

  # get the principal tile from a meld consisting of all one tile and jokers
  def _get_joker_meld_tile(tiles, joker_tiles, tile_behavior) do
    # don't pass tile_behavior to has_matching_tile?/3 here
    # so that we only get exact matches for the joker tile
    non_joker_tiles = Enum.reject(tiles, &has_matching_tile?([&1], joker_tiles))
    has_joker = length(non_joker_tiles) < length(tiles)
    has_nonjoker = length(non_joker_tiles) > 0
    if has_joker and has_nonjoker do
      [tile | rest] = non_joker_tiles
      tile = strip_attrs(tile)
      if Enum.all?(rest, &same_tile(&1, tile, tile_behavior)) do tile else nil end
    else nil end
  end
  def get_joker_meld_tile(call, joker_tiles, tile_behavior) do
    _get_joker_meld_tile(call_to_tiles(call), joker_tiles, tile_behavior)
  end

  def replace_base_tile(tile, new_base_tile) do
    {_tile, attrs} = to_attr_tile(tile)
    add_attr(new_base_tile, attrs)
  end

  def replace_jokers(tiles, joker_tiles, tile_behavior) do
    # don't pass tile_behavior to has_matching_tile?/3 here
    # so that we only get exact matches for the joker tile
    if has_matching_tile?(tiles, joker_tiles) do
      List.duplicate(_get_joker_meld_tile(tiles, joker_tiles, tile_behavior), length(tiles))
    else tiles end
  end

  @pon_like_calls ["pon", "daiminkan", "kakan", "ankan", "am_pung", "am_kong", "am_quint"]
  def replace_jokers_in_calls(calls, joker_tiles, tile_behavior) do
    Enum.map(calls, fn {name, call} ->
      if name in @pon_like_calls and Enum.any?(call, &has_matching_tile?([&1], joker_tiles)) do
        meld_tile = get_joker_meld_tile({name, call}, joker_tiles, tile_behavior)
        {name, Enum.map(call, &replace_base_tile(&1, meld_tile))}
      else {name, call} end
    end)
  end
  
  def maximum_bipartite_matching(adj, pairing \\ %{}, pairing_r \\ %{}) do
    orig_size = map_size(pairing)
    {pairing, pairing_r} = maximum_bipartite_matching_hopcroft_karp_pass(adj, pairing, pairing_r)
    if map_size(pairing) > orig_size do
      maximum_bipartite_matching(adj, pairing, pairing_r)
    else {pairing, pairing_r} end
  end
  defp maximum_bipartite_matching_hopcroft_karp_pass(adj, pairing, pairing_r) when map_size(adj) == 0, do: {pairing, pairing_r}
  defp maximum_bipartite_matching_hopcroft_karp_pass(adj, pairing, pairing_r) do
    start_pts = Map.keys(adj) -- Map.keys(pairing)
    {layers, _, _, _} = Enum.reduce_while(1..map_size(adj), {[], start_pts, MapSet.new(start_pts), MapSet.new()}, fn _, {layers, prev_layer, visited, visited_r} ->
      opp_layer = prev_layer
      |> Enum.flat_map(fn u -> Enum.reject(adj[u], &Map.get(pairing, u) == &1) end)
      |> Enum.uniq()
      |> Enum.reject(& &1 in visited_r)

      new_layer = opp_layer
      |> Enum.map(&Map.get(pairing_r, &1, nil))
      |> Enum.uniq()
      |> Enum.reject(& &1 in visited)

      visited = MapSet.union(visited, MapSet.new(new_layer))
      visited_r = MapSet.union(visited_r, MapSet.new(opp_layer))
      acc = {[MapSet.new(new_layer) | layers], new_layer, visited, visited_r}
      if nil in new_layer or MapSet.size(visited) == map_size(adj) do
        {:halt, acc}
      else
        {:cont, acc}
      end
    end)
    layers = Enum.reverse([MapSet.new() | layers])
    for from <- start_pts, reduce: {pairing, pairing_r} do
      {pairing, pairing_r} ->
        case maximum_bipartite_matching_hopcroft_karp_dfs(from, adj, layers, pairing, pairing_r) do
          {pairing, pairing_r, _layer, true} -> {pairing, pairing_r}
          _                                  -> {pairing, pairing_r}
        end
    end
  end
  defp maximum_bipartite_matching_hopcroft_karp_dfs(nil, _adj, _layers, pairing, pairing_r) do
    {pairing, pairing_r, MapSet.new(), true}
  end
  defp maximum_bipartite_matching_hopcroft_karp_dfs(u, adj, [layer | layers], pairing, pairing_r) do
    Enum.reduce_while(adj[u], {pairing, pairing_r, layer, false}, fn v, {pairing, pairing_r, layer, _found} ->
      case Map.get(pairing_r, v) do
        nil    -> {:halt, {Map.put(pairing, u, v), Map.put(pairing_r, v, u), MapSet.new(), true}}
        next_u ->
          if next_u in layer do
            layer = MapSet.delete(layer, next_u)
            case maximum_bipartite_matching_hopcroft_karp_dfs(next_u, adj, layers, pairing, pairing_r) do
              {pairing, pairing_r, _layer, true} -> {:halt, {Map.put(pairing, u, v), Map.put(pairing_r, v, u), MapSet.new(), true}}
              _                                  -> {:cont, {pairing, pairing_r, layer, false}}
            end
          else {:cont, {pairing, pairing_r, layer, false}} end
      end
    end)
  end

  @decorate cacheable(cache: RiichiAdvanced.Cache, key: {:inverse_frequencies, visible_tiles, TileBehavior.hash(tile_behavior)})
  def inverse_frequencies(visible_tiles, tile_behavior) do
    freqs = if is_map(visible_tiles) do visible_tiles else
      # keep only attrs that appear in the original wall before taking frequencies
      valid_attrs = Map.keys(tile_behavior.tile_freqs)
      |> Enum.map(fn tile ->
        {_, attrs} = to_attr_tile(tile)
        MapSet.new(attrs)
      end)
      |> Enum.reduce(MapSet.new(), &MapSet.union/2)
      visible_tiles
      |> Enum.map(fn tile -> 
        {tile, attrs} = to_attr_tile(tile)
        add_attr(tile, Enum.filter(attrs, & &1 in valid_attrs))
      end)
      |> Enum.frequencies()
    end
    Map.merge(tile_behavior.tile_freqs, freqs, fn _k, l, r -> l - r end)
    |> Enum.filter(fn {_tile, freq} -> freq > 0 end)
    |> Map.new()
  end

  # why is this not builtin
  def _split_on([], _delim, acc, ret), do: [acc | ret]
  def _split_on([x | xs], delim, acc, ret) when x == delim, do: _split_on(xs, delim, [], [acc | ret])
  def _split_on([x | xs], delim, acc, ret), do: _split_on(xs, delim, [x | acc], ret)
  def split_on(xs, delim), do: _split_on(Enum.reverse(xs), delim, [], [])

  @css_color_regex ~r/^#[a-fA-F0-9]{6}$|^#[a-fA-F0-9]{3}$|^rgb\(\d{1,3},\s*\d{1,3},\s*\d{1,3}\)$|^rgba\(\d{1,3},\s*\d{1,3},\s*\d{1,3},\s*[\d.]+\)$|^[a-zA-Z]+$/
  def css_color_regex, do: @css_color_regex
end