defmodule Riichi do

  @shift_suit %{:"1m"=>:"1p", :"2m"=>:"2p", :"3m"=>:"3p", :"4m"=>:"4p", :"5m"=>:"5p", :"6m"=>:"6p", :"7m"=>:"7p", :"8m"=>:"8p", :"9m"=>:"9p", :"10m"=>:"101p",
                :"1p"=>:"1s", :"2p"=>:"2s", :"3p"=>:"3s", :"4p"=>:"4s", :"5p"=>:"5s", :"6p"=>:"6s", :"7p"=>:"7s", :"8p"=>:"8s", :"9p"=>:"9s", :"10p"=>:"101s",
                :"1s"=>:"1m", :"2s"=>:"2m", :"3s"=>:"3m", :"4s"=>:"4m", :"5s"=>:"5m", :"6s"=>:"6m", :"7s"=>:"7m", :"8s"=>:"8m", :"9s"=>:"9m", :"10s"=>:"101m",
                :"0z"=>nil, :"1z"=>nil, :"2z"=>nil, :"3z"=>nil, :"4z"=>nil, :"5z"=>nil, :"6z"=>nil, :"7z"=>nil, :"8z"=>nil}
  def shift_suit(tile), do: @shift_suit[tile]

  # for fu calculation only
  @terminal_honors [:"1m",:"9m",:"1p",:"9p",:"1s",:"9s",:"1z",:"2z",:"3z",:"4z",:"5z",:"6z",:"7z"]

  @flower_names ["start_flower", "start_joker", "flower", "joker", "pei"]
  def flower_names(), do: @flower_names

  @fixed_offsets %{
    "1A"  => :"1m",
    "2A"  => :"2m",
    "3A"  => :"3m",
    "4A"  => :"4m",
    "5A"  => :"5m",
    "6A"  => :"6m",
    "7A"  => :"7m",
    "8A"  => :"8m",
    "9A"  => :"9m",
    "10A" => :"10m",
    "DA"  => :"7z",
    "1B"  => :"1p",
    "2B"  => :"2p",
    "3B"  => :"3p",
    "4B"  => :"4p",
    "5B"  => :"5p",
    "6B"  => :"6p",
    "7B"  => :"7p",
    "8B"  => :"8p",
    "9B"  => :"9p",
    "10B" => :"10p",
    "DB"  => :"0z",
    "1C"  => :"1s",
    "2C"  => :"2s",
    "3C"  => :"3s",
    "4C"  => :"4s",
    "5C"  => :"5s",
    "6C"  => :"6s",
    "7C"  => :"7s",
    "8C"  => :"8s",
    "9C"  => :"9s",
    "10C" => :"10s",
    "DC"  => :"6z",
  }

  def is_offset(tile) do
    is_integer(tile) or Map.has_key?(@fixed_offsets, tile)
  end

  def suit_to_offset(tile) do
    cond do
      is_manzu?(tile) -> 0
      is_pinzu?(tile) -> 10
      is_souzu?(tile) -> 20
      true -> 0
    end
  end

  def _offset_tile(tile, n, order, order_r, shift_dragons \\ false) do
    if tile != nil do
      cond do
        Map.has_key?(@fixed_offsets, n) -> _offset_tile(@fixed_offsets[n], suit_to_offset(tile), order, order_r, true)
        (n < 1 && n > -1) || n < -30 || n >= 30 ->
          tile
        n >= 10 ->
          cond do
            shift_dragons && tile == :"7z" -> _offset_tile(:"0z", n-10, order, order_r, true)
            shift_dragons && tile == :"0z" -> _offset_tile(:"6z", n-10, order, order_r, true)
            shift_dragons && tile == :"6z" -> _offset_tile(:"7z", n-10, order, order_r, true)
            true -> _offset_tile(shift_suit(tile), n-10, order, order_r)
          end
        n <= -10 ->
          cond do
            shift_dragons && tile == :"7z" -> _offset_tile(:"6z", n+10, order, order_r, true)
            shift_dragons && tile == :"0z" -> _offset_tile(:"7z", n+10, order, order_r, true)
            shift_dragons && tile == :"6z" -> _offset_tile(:"0z", n+10, order, order_r, true)
            true -> _offset_tile(shift_suit(shift_suit(tile)), n+10, order, order_r)
          end
        n <= -1 ->
          _offset_tile(order_r[tile], n+1, order, order_r)
        true -> # n >= 1
          _offset_tile(order[tile], n-1, order, order_r)
      end
    else nil end
  end

  def offset_tile(tile, n, order, order_r, shift_dragons \\ false) do
    case tile do
      :any -> :any
      {tile, attrs} -> {_offset_tile(tile, n, order, order_r, shift_dragons), attrs}
      tile -> _offset_tile(tile, n, order, order_r, shift_dragons)
    end    
  end

  @manzu      [:"1m", :"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m", :"9m", :"0m", :"10m",
               :"11m", :"12m", :"13m", :"14m", :"15m", :"16m", :"17m", :"18m", :"19m"]
  @pinzu      [:"1p", :"2p", :"3p", :"4p", :"5p", :"6p", :"7p", :"8p", :"9p", :"0p", :"10p",
               :"11p", :"12p", :"13p", :"14p", :"15p", :"16p", :"17p", :"18p", :"19p"]
  @souzu      [:"1s", :"2s", :"3s", :"4s", :"5s", :"6s", :"7s", :"8s", :"9s", :"0s", :"10s",
               :"11s", :"12s", :"13s", :"14s", :"15s", :"16s", :"17s", :"18s", :"19s"]
  @jihai      [:"1z", :"2z", :"3z", :"4z", :"5z", :"0z", :"8z", :"6z", :"7z",
               :"11z", :"12z", :"13z", :"14z", :"15z", :"10z", :"16z", :"17z", :"25z", :"26z", :"27z"]
  @wind       [:"1z", :"2z", :"3z", :"4z", :"11z", :"12z", :"13z", :"14z"]
  @dragon     [:"5z", :"0z", :"8z", :"6z", :"7z", :"15z", :"10z", :"16z", :"17z", :"25z", :"26z", :"27z"]
  @terminal   [:"1m", :"9m", :"1p", :"9p", :"1s", :"9s",
               :"11m", :"19m", :"11p", :"19p", :"11s", :"19s"]
  @tanyaohai  [:"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m",
               :"2p", :"3p", :"4p", :"5p", :"6p", :"7p", :"8p",
               :"2s", :"3s", :"4s", :"5s", :"6s", :"7s", :"8s"]
  @yaochuuhai [:"1m", :"9m", :"1p", :"9p", :"1s", :"9s", :"1z", :"2z", :"3z", :"4z", :"5z", :"0z", :"8z", :"6z", :"7z", 
               :"11m", :"19m", :"11p", :"19p", :"11s", :"19s", :"11z", :"12z", :"13z", :"14z", :"15z", :"16z", :"17z"]
  @flower     [:"1f", :"2f", :"3f", :"4f", :"1g", :"2g", :"3g", :"4g", :"1k", :"2k", :"3k", :"4k", :"1q", :"2q", :"3q", :"4q", :"1a", :"2a", :"3a", :"4a", :"1y"]
  @joker      [:"1j", :"2j", :"3j", :"4j", :"5j", :"6j", :"7j", :"8j", :"9j", :"10j", :"12j", :"13j", :"14j", :"15j", :"16j", :"17j", :"18j", :"19j", :"2y"]

  def is_manzu?(tile), do: Enum.any?(@manzu, &Utils.same_tile(tile, &1))
  def is_pinzu?(tile), do: Enum.any?(@pinzu, &Utils.same_tile(tile, &1))
  def is_souzu?(tile), do: Enum.any?(@souzu, &Utils.same_tile(tile, &1))
  def is_jihai?(tile), do: Enum.any?(@jihai, &Utils.same_tile(tile, &1))
  def is_suited?(tile), do: is_manzu?(tile) || is_pinzu?(tile) || is_souzu?(tile)
  def is_wind?(tile), do: Enum.any?(@wind, &Utils.same_tile(tile, &1))
  def is_dragon?(tile), do: Enum.any?(@dragon, &Utils.same_tile(tile, &1))
  def is_terminal?(tile), do: Enum.any?(@terminal, &Utils.same_tile(tile, &1))
  def is_yaochuuhai?(tile), do: Enum.any?(@yaochuuhai, &Utils.same_tile(tile, &1))
  def is_tanyaohai?(tile), do: Enum.any?(@tanyaohai, &Utils.same_tile(tile, &1))
  def is_flower?(tile), do: Enum.any?(@flower, &Utils.same_tile(tile, &1))
  def is_joker?(tile), do: Enum.any?(@joker, &Utils.same_tile(tile, &1))

  def is_num?(tile, num) do
    Enum.any?(case num do
      1 -> [:"1m", :"1p", :"1s", :"11m", :"11p", :"11s"]
      2 -> [:"2m", :"2p", :"2s", :"12m", :"12p", :"12s"]
      3 -> [:"3m", :"3p", :"3s", :"13m", :"13p", :"13s"]
      4 -> [:"4m", :"4p", :"4s", :"14m", :"14p", :"14s"]
      5 -> [:"5m", :"5p", :"5s", :"15m", :"15p", :"15s", :"0m", :"0p", :"0s"]
      6 -> [:"6m", :"6p", :"6s", :"16m", :"16p", :"16s"]
      7 -> [:"7m", :"7p", :"7s", :"17m", :"17p", :"17s"]
      8 -> [:"8m", :"8p", :"8s", :"18m", :"18p", :"18s"]
      9 -> [:"9m", :"9p", :"9s", :"19m", :"19p", :"19s"]
    end, &Utils.same_tile(tile, &1))
  end
  def same_suit?(tile, tile2) do
    cond do
      is_manzu?(tile) -> is_manzu?(tile2)
      is_pinzu?(tile) -> is_pinzu?(tile2)
      is_souzu?(tile) -> is_souzu?(tile2)
      is_jihai?(tile) -> is_jihai?(tile2)
      true            -> false
    end
  end
  def same_number?(tile, tile2) do
    cond do
      is_num?(tile, 1) -> is_num?(tile2, 1) 
      is_num?(tile, 2) -> is_num?(tile2, 2) 
      is_num?(tile, 3) -> is_num?(tile2, 3) 
      is_num?(tile, 4) -> is_num?(tile2, 4) 
      is_num?(tile, 5) -> is_num?(tile2, 5) 
      is_num?(tile, 6) -> is_num?(tile2, 6) 
      is_num?(tile, 7) -> is_num?(tile2, 7) 
      is_num?(tile, 8) -> is_num?(tile2, 8) 
      is_num?(tile, 9) -> is_num?(tile2, 9) 
      true            -> false
    end
  end

  def remove_tile(hand, tile, ignore_suit \\ false, acc \\ [])
  def remove_tile([], _tile, _ignore_suit, _acc), do: []
  def remove_tile([t | hand], tile, ignore_suit, acc) do
    do_remove = if ignore_suit do Utils.same_number(t, tile) else Utils.same_tile(t, tile) end
    if do_remove do
      ret = [Enum.reduce(acc, hand, &[&1 | &2])]
      # try not to remove :any if possible (important for american hands)
      if t == :any do
        case remove_tile(hand, tile, ignore_suit, [t | acc]) do
          []  -> ret
          ret -> ret
        end
      else ret end
    else
      remove_tile(hand, tile, ignore_suit, [t | acc])
    end
  end

  defp _try_remove_all_tiles(hand, [], _tile_aliases, _ignore_suit), do: [hand]
  defp _try_remove_all_tiles(hand, [tile | tiles], tile_aliases, ignore_suit) do
    # remove all tiles, with the first result removing non-jokers over jokers or :any
    [tile | (Utils.apply_tile_aliases(tile, tile_aliases) |> MapSet.delete(tile) |> MapSet.to_list())]
    |> Enum.flat_map(&remove_tile(hand, &1, ignore_suit))
    |> Enum.flat_map(&_try_remove_all_tiles(&1, tiles, tile_aliases, ignore_suit))
    |> Enum.uniq()
  end

  def try_remove_all_tiles(hand, tiles, tile_aliases \\ %{}, ignore_suit \\ false) do
    if length(hand) >= length(tiles) do _try_remove_all_tiles(hand, tiles, tile_aliases, ignore_suit) else [] end
  end

  def remove_from_hand_calls(hand, calls, tiles, tile_aliases \\ %{}, ignore_suit \\ false) do
    if Enum.empty?(tiles) do
      [{hand, calls}]
    else
      from_hand = try_remove_all_tiles(hand, tiles, tile_aliases, ignore_suit) |> Enum.map(fn hand -> {hand, calls} end)
      from_calls = calls
      |> Enum.map(&call_to_tiles/1)
      |> Enum.with_index()
      |> Enum.flat_map(fn {call, i} -> if Enum.empty?(try_remove_all_tiles(call, tiles, tile_aliases, ignore_suit)) do [] else [i] end end)
      |> Enum.map(&{hand, List.delete_at(calls, &1)})
      from_hand ++ from_calls |> Enum.uniq()
    end
  end

  def try_remove_call(hand, calls, call_name) do
    ix = Enum.find_index(calls, fn {name, _call} -> name == call_name end)
    if ix != nil do [{hand, List.delete_at(calls, ix)}] else [] end
  end

  @group_keywords ["nojoker", "unique"]
  def group_keywords(), do: @group_keywords

  defp group_to_subgroups(group, ordering, ordering_r, base_tile) do
    {subgroups, tiles} = group
    |> Enum.reject(& &1 in @group_keywords)
    |> Enum.split_with(&is_list/1)
    if Enum.empty?(subgroups) do
      # treat the whole group as its own subgroup
      if Enum.empty?(tiles) do [] else [tiles] end
    else
      # treat each tile as an individual subgroup
      subgroups ++ Enum.map(tiles, &[&1])
    end
    |> Enum.map(&Enum.map(&1, fn tile -> if Utils.is_tile(tile) do Utils.to_tile(tile) else offset_tile(base_tile, tile, ordering, ordering_r) end end))
  end

  def _remove_group(hand, calls, group, ignore_suit, ordering, ordering_r, tile_aliases, base_tile) do
    # IO.puts("removing group #{inspect(group)} with base tile #{base_tile} from hand #{inspect(hand)}")
    cond do
      is_list(group) ->
        no_joker_index = Enum.find_index(group, fn elem -> elem == "nojoker" end)
        {joker, nojoker} = Enum.split(group, if no_joker_index != nil do no_joker_index else length(group) end)
        # handle nojoker subgroups first
        hand_calls = for subgroup <- group_to_subgroups(nojoker, ordering, ordering_r, base_tile), reduce: [{hand, calls}] do
          hand_calls -> Enum.flat_map(hand_calls, fn {hand, calls} -> remove_from_hand_calls(hand, calls, subgroup, %{}, ignore_suit) end)
        end
        # handle joker subgroups next
        hand_calls = for subgroup <- group_to_subgroups(joker, ordering, ordering_r, base_tile), reduce: hand_calls do
          hand_calls -> Enum.flat_map(hand_calls, fn {hand, calls} -> remove_from_hand_calls(hand, calls, subgroup, tile_aliases, ignore_suit) end)
        end
        hand_calls
      is_offset(group) -> remove_from_hand_calls(hand, calls, [offset_tile(base_tile, group, ordering, ordering_r)], tile_aliases, ignore_suit)
      Utils.is_tile(group) -> remove_from_hand_calls(hand, calls, [Utils.to_tile(group)], tile_aliases, ignore_suit)
      is_binary(group) -> try_remove_call(hand, calls, group)
      true ->
        IO.puts("Unhandled group #{inspect(group)}")
        [{hand, calls}]
    end
  end

  def remove_group(hand, calls, group, ignore_suit, ordering, ordering_r, tile_aliases \\ %{}, base_tiles \\ []) do
    # IO.puts("removing group #{inspect(group)} from hand #{inspect(hand)}")
    # t = System.os_time(:millisecond)
    ret = base_tiles
    |> Enum.map(&Task.async(fn -> _remove_group(hand, calls, group, ignore_suit, ordering, ordering_r, tile_aliases, &1) end))
    |> Task.yield_many(timeout: :infinity)
    |> Enum.flat_map(fn {_task, {:ok, res}} -> res end)
    # elapsed_time = System.os_time(:millisecond) - t
    # if elapsed_time > 10 do
    #   IO.puts("remove_group: #{inspect(hand)} #{inspect(group)} #{inspect(elapsed_time)} ms")
    # end
    ret
  end

  # @match_keywords ["almost", "exhaustive", "ignore_suit", "restart", "unique", "nojoker", "debug"]
  # def match_keywords(), do: @match_keywords

  def filter_irrelevant_tile_aliases(tile_aliases, all_tiles) do
    # filter out irrelevant tile aliases
    for {tile, attrs_aliases} <- tile_aliases do
      new_attrs_aliases = for {attrs, aliases} <- attrs_aliases do
        {attrs, Enum.filter(aliases, fn t -> Enum.any?(all_tiles, &Utils.same_tile(&1, t)) end)}
      end
      |> Enum.reject(fn {_attrs, aliases} -> Enum.empty?(aliases) end)
      |> Map.new()
      {tile, new_attrs_aliases}
    end
    |> Enum.reject(fn {_tile, attrs_aliases} -> Enum.empty?(attrs_aliases) end)
    |> Map.new()
  end

  defp _remove_match_definition(hand, calls, match_definition, ordering, ordering_r, tile_aliases) do
    # t = System.os_time(:millisecond)
    almost = "almost" in match_definition
    exhaustive = "exhaustive" in match_definition
    ignore_suit_ix = Enum.find_index(match_definition, & &1 == "ignore_suit")
    unique_ix = Enum.find_index(match_definition, & &1 == "unique")
    debug = "debug" in match_definition
    if almost && :any in hand do
      IO.puts("Warning: \"almost\" keyword does not support hands that have :any yet")
    end
    hand = if almost || :any in hand do
      {any, hand} = Enum.split_with(hand, & &1 == :any)
      any = if almost do [:any | any] else any end
      hand ++ any
    else hand end
    filtered_tile_aliases = filter_irrelevant_tile_aliases(tile_aliases, hand ++ Enum.flat_map(calls, &call_to_tiles/1))
    if debug do
      IO.puts("======================================================")
      IO.puts("Match definition: #{inspect(match_definition, charlists: :as_lists)}")
      IO.puts("Starting hand / calls: #{inspect(hand, charlists: :as_lists)} / #{inspect(calls, charlists: :as_lists)}")
      IO.puts("Tile aliases: #{inspect(filtered_tile_aliases)}")
    end
    no_joker_index = Enum.find_index(match_definition, fn elem -> elem == "nojoker" end)
    ret = for {match_definition_elem, i} <- Enum.with_index(match_definition), reduce: [{hand, calls}] do
      [] -> []
      hand_calls ->
        unique = unique_ix != nil && i > unique_ix
        ignore_suit = ignore_suit_ix != nil && i > ignore_suit_ix
        case match_definition_elem do
          "restart" -> [{hand, calls}]
          [groups, num] ->
            unique = unique || "unique" in groups
            nojoker = no_joker_index != nil && i > no_joker_index
            tile_aliases = if nojoker do %{} else filtered_tile_aliases end
            new_hand_calls = if unique && num >= 1 && not exhaustive && Enum.all?(groups, &not is_list(&1) && (Utils.is_tile(&1) || &1 in @group_keywords)) do
              # optimized routine for unique non-exhaustive tile-only groups
              # since we know the exact tiles required and each can only be used once,
              # this is just a matching problem between our hand/calls and the group
              # (we need to find any `num` matchings subject to joker restrictions)

              group_tiles = groups
              |> Enum.reject(& &1 in @group_keywords)
              |> Enum.map(&Utils.to_tile/1)
              # certain groups can be marked nojoker
              {joker, nojoker} = Enum.split(group_tiles, Enum.find_index(group_tiles, fn elem -> elem == "nojoker" end) || length(group_tiles))
              nojoker = Enum.reject(nojoker, & &1 in @group_keywords)
              joker = Enum.reject(joker, & &1 in @group_keywords)
              Enum.flat_map(hand_calls, fn {hand, calls} ->
                if debug do
                  IO.puts("Using optimized routine / #{inspect(hand)} / #{inspect(calls)} / about to remove #{inspect(groups, charlists: :as_lists)}")
                  # IO.puts("#{inspect(matching_hand, charlists: :as_lists)} / #{inspect(matching_calls, charlists: :as_lists)}")
                  # IO.puts("#{inspect(joker, charlists: :as_lists)} / #{inspect(nojoker, charlists: :as_lists)}")
                end
                # treat hand as just another call (order of removal does not matter since non-exhaustive)
                {[hand | calls], _, _, to_remove_num} = for {call, is_hand} <- Enum.map(calls, &{&1, false}) ++ [{hand, true}], reduce: {[], joker, nojoker, num} do
                  {ret, joker, nojoker, to_remove_num} ->
                    tiles = if is_hand do call else call_to_tiles(call) end
                    num_tiles = length(tiles)
                    adj_joker   = Map.new(Enum.with_index(joker),   fn {tile, i} -> {i,                 for {tile2, j}  <- Enum.with_index(tiles), Utils.same_tile(tile2, tile, tile_aliases)  do j end} end)
                    adj_nojoker = Map.new(Enum.with_index(nojoker), fn {tile, i} -> {length(joker) + i, for {tile2, j}  <- Enum.with_index(tiles), Utils.same_tile(tile2, tile)                do j end} end)
                    adj = Map.merge(adj_joker, adj_nojoker)
                    {pairing, pairing_r} = Utils.maximum_bipartite_matching(adj)
                    consumes_call = map_size(pairing) == num_tiles
                    consumes_match = map_size(pairing) == to_remove_num
                    if consumes_call || consumes_match do
                      n = length(joker) 
                      to_remove = pairing |> Map.keys() |> Enum.take(to_remove_num)
                      {from_joker, from_nojoker} = to_remove |> Enum.sort(:desc) |> Enum.split_while(fn i -> i >= n end)
                      nojoker = for i <- from_nojoker, reduce: nojoker do nojoker -> List.delete_at(nojoker, i - n) end
                      joker   = for i <- from_joker,   reduce: joker   do joker   -> List.delete_at(joker,   i    ) end
                      ret = if is_hand do # is hand, so we keep all unmatched tiles
                        to_remove_r = pairing_r |> Map.keys() |> Enum.take(to_remove_num)
                        hand = for j <- to_remove_r |> Enum.sort(:desc), reduce: tiles do hand -> List.delete_at(hand, j) end
                        [hand | ret]
                      else ret end # not hand, so we discard all unmatched tiles
                      {ret, joker, nojoker, to_remove_num - length(to_remove)}
                    else {[call | ret], joker, nojoker, to_remove_num} end
                end
                # check that match is consumed
                if to_remove_num == 0 do [{hand, calls}] else [] end
              end)
              |> Enum.uniq()
            else
              tile_aliases = if (no_joker_index != nil && i > no_joker_index) do %{} else filtered_tile_aliases end
              # unique makes it so all groups must be offset by the same tile
              # (no such restriction for non-unique groups)
              base_tiles = collect_base_tiles(hand, calls, List.flatten(groups), ordering, ordering_r)
              for base_tile <- (if unique do base_tiles else [nil] end) do
                Task.async(fn ->
                  for _ <- (if num == 0 do [1] else 1..abs(num) end), reduce: Enum.map(hand_calls, fn {hand, calls} -> {hand, calls, groups} end) do
                    [] -> []
                    hand_calls_groups ->
                      report = if debug do
                        line1 = "Acc (before removal):"
                        lines = for {hand, calls, remaining_groups} <- hand_calls_groups do
                          "- #{inspect(hand)} / #{inspect(calls)} / #{inspect(remaining_groups, charlists: :as_lists)}#{if unique do " unique" else "" end}#{if exhaustive do " exhaustive" else "" end} #{if base_tile != nil do inspect(base_tile) else "" end}"
                        end
                        [line1 | lines]
                      else "" end
                      new_hand_calls_groups = if exhaustive do
                        for {hand, calls, remaining_groups} <- hand_calls_groups, {group, i} <- Enum.with_index(remaining_groups), group not in @group_keywords do
                          no_joker_index = Enum.find_index(remaining_groups, fn elem -> elem == "nojoker" end)
                          nojoker = no_joker_index != nil && i > no_joker_index
                          tile_aliases = if nojoker do %{} else tile_aliases end
                          Task.async(fn ->
                            if unique do
                              _remove_group(hand, calls, group, ignore_suit, ordering, ordering_r, tile_aliases, base_tile)
                            else
                              remove_group(hand, calls, group, ignore_suit, ordering, ordering_r, tile_aliases, base_tiles)
                            end
                            |> Enum.map(fn {hand, calls} -> {hand, calls, if unique do List.delete_at(remaining_groups, i) else remaining_groups end} end)
                          end)
                        end
                        |> Task.yield_many(timeout: :infinity)
                        |> Enum.flat_map(fn {_task, {:ok, res}} -> res end)
                        |> Enum.uniq()
                      else
                        for {hand, calls, remaining_groups} <- hand_calls_groups, {group, i} <- Enum.with_index(remaining_groups), group not in @group_keywords, reduce: [] do
                          [] ->
                            no_joker_index = Enum.find_index(remaining_groups, fn elem -> elem == "nojoker" end)
                            nojoker = no_joker_index != nil && i > no_joker_index
                            tile_aliases = if nojoker do %{} else tile_aliases end
                            if unique do
                              _remove_group(hand, calls, group, ignore_suit, ordering, ordering_r, tile_aliases, base_tile)
                            else
                              remove_group(hand, calls, group, ignore_suit, ordering, ordering_r, tile_aliases, base_tiles)
                            end
                            |> Enum.take(1)
                            |> Enum.map(fn {hand, calls} -> {hand, calls, if unique do List.delete_at(remaining_groups, i) else remaining_groups end} end)
                          result -> result
                        end
                      end
                      if debug do
                        line1 = "Acc (after removal):"
                        lines = for {hand, calls, remaining_groups} <- new_hand_calls_groups do
                          "- #{inspect(hand)} / #{inspect(calls)} / #{inspect(remaining_groups, charlists: :as_lists)}"
                        end
                        IO.puts(Enum.join(report ++ [line1 | lines], "\n"))
                      end
                      new_hand_calls_groups
                  end
                end)
              end
              |> Task.yield_many(timeout: :infinity)
              |> Enum.flat_map(fn {_task, {:ok, res}} -> res end)
              |> Enum.map(fn {hand, calls, _} -> {hand, calls} end)
            end
            |> Enum.uniq()
            cond do
              num == 0 -> # forward lookahead
                if Enum.empty?(new_hand_calls) do
                  []
                else
                  hand_calls # revert
                end
              num < 0  -> # negative lookahead
                if Enum.empty?(new_hand_calls) do
                  hand_calls # revert
                else
                  [] # if we matched anything, no we didn't
                end
              true     ->
                result = new_hand_calls
                |> Enum.uniq_by(fn {hand, calls} -> {Enum.sort(hand), calls} end)
                if debug do
                  IO.puts("Final result:")
                  for {hand, calls} <- result do
                    IO.puts("- #{inspect(hand)} / #{inspect(calls)}")
                  end
                end
                result
            end
          _ -> hand_calls
        end
    end
    ret = if almost do Enum.reject(ret, fn {hand, _calls} -> :any in hand end) else ret end
    # elapsed_time = System.os_time(:millisecond) - t
    # if elapsed_time > 10 do
    #   IO.puts("_remove_match_definition: #{inspect(hand)} #{inspect(match_definition)} #{inspect(elapsed_time)} ms")
    # end
    ret
  end

  def remove_match_definition(hand, calls, match_definition, ordering, ordering_r, tile_aliases \\ %{}) do
    # calls = Enum.map(calls, fn {name, call} -> {name, Enum.map(call, fn {tile, _sideways} -> tile end)} end)
    case RiichiAdvanced.ETSCache.get({:remove_match_definition, hand, calls, match_definition, ordering, tile_aliases}) do
      [] -> 
        result = _remove_match_definition(hand, calls, match_definition, ordering, ordering_r, tile_aliases)
        RiichiAdvanced.ETSCache.put({:remove_match_definition, hand, calls, match_definition, ordering, tile_aliases}, result)
        # IO.puts("Results:\n  hand: #{inspect(hand)}\n  result: #{inspect(result)}")
        result
      [result] -> result
    end
  end

  # check if hand contains all groups in each definition in match_definitions
  defp _match_hand(hand, calls, match_definitions, ordering, ordering_r, tile_aliases) do
    tile_aliases = filter_irrelevant_tile_aliases(tile_aliases, hand ++ Enum.flat_map(calls, &call_to_tiles/1))
    Enum.any?(match_definitions, fn match_definition -> not Enum.empty?(remove_match_definition(hand, calls, match_definition, ordering, ordering_r, tile_aliases)) end)
  end

  def match_hand(hand, calls, match_definitions, ordering, ordering_r, tile_aliases \\ %{}) do
    # t = System.os_time(:millisecond)
    ret = case RiichiAdvanced.ETSCache.get({:match_hand, hand, calls, match_definitions, ordering, tile_aliases}) do
      [] -> 
        result = _match_hand(hand, calls, match_definitions, ordering, ordering_r, tile_aliases)
        RiichiAdvanced.ETSCache.put({:match_hand, hand, calls, match_definitions, ordering, tile_aliases}, result)
        # IO.puts("Results:\n  hand: #{inspect(hand)}\n  match_definitions: #{inspect(match_definitions)}\n  result: #{inspect(result)}")
        result
      [result] -> result
    end
    # elapsed_time = System.os_time(:millisecond) - t
    # if elapsed_time > 10 do
    #   IO.puts("match_hand: #{inspect(elapsed_time)} ms")
    # end
    ret
  end

  defp multiply_match_definitions(match_definitions, mult) do
    for match_definition <- match_definitions do
      for [groups, num] <- match_definition do
        [groups, if num < 0 do num else num * mult end]
      end
    end
  end

  def binary_search_count_matches(hand_calls, match_definitions, ordering, ordering_r, tile_aliases, l \\ -1, r \\ 1) do
    if l < r do
      m = if l == -1 do r else Integer.floor_div(l + r + 1, 2) end
      multiplied_match_def = multiply_match_definitions(match_definitions, m)
      if Enum.empty?(multiplied_match_def) do
        IO.inspect("Error: empty match definition given: #{inspect(match_definitions)}")
        0
      else
        matched = Enum.any?(hand_calls, fn {hand, calls} -> match_hand(hand, calls, multiplied_match_def, ordering, ordering_r, tile_aliases) end)
        {l, r} = if matched do
          if l == -1 do {l, r * 2} else {m, r} end
        else
          if l == -1 do {0, r} else {l, m - 1} end
        end
        binary_search_count_matches(hand_calls, match_definitions, ordering, ordering_r, tile_aliases, l, r)
      end
    else l end 
  end

  # return all possible calls of each tile in called_tiles, given hand
  # includes returning multiple choices for jokers (incl. red fives)
  # if called_tiles is an empty list, then we choose from our hand
  # example output: %{:"5m" => [[:"4m", :"6m"], [:"6m", :"7m"]]}
  def make_calls(calls_spec, hand, ordering, ordering_r, called_tiles \\ [], tile_aliases \\ %{}, tile_mappings \\ %{}) do
    # t = System.os_time(:millisecond)

    # IO.puts("#{inspect(calls_spec)} / #{inspect(hand)} / #{inspect(called_tiles)}")
    from_hand = Enum.empty?(called_tiles)
    {calls_spec, tile_aliases, tile_mappings} = if Enum.at(calls_spec, 0) == "nojoker" do
      {Enum.drop(calls_spec, 1), %{}, %{}}
    else {calls_spec, tile_aliases, tile_mappings} end
    ret = for tile <- (if from_hand do hand else called_tiles end) do
      {tile, Enum.flat_map(calls_spec, fn call_spec ->
        hand = if from_hand do List.delete(hand, tile) else hand end
        for choice <- [tile] ++ Map.get(tile_mappings, tile, []), reduce: [] do
          choices ->
            target_tiles = Enum.map(call_spec, &offset_tile(Utils.strip_attrs(choice), &1, ordering, ordering_r))
            possible_removals = try_remove_all_tiles(hand, target_tiles, tile_aliases)
            choices ++ Enum.map(possible_removals, fn remaining -> hand -- remaining end)
        end |> Enum.map(fn tiles -> Utils.sort_tiles(tiles) end) |> Enum.uniq()
      end) |> Enum.uniq()}
    end |> Enum.uniq_by(fn {tile, choices} -> Enum.map(choices, fn choice -> Enum.sort([tile | choice]) end) end) |> Map.new()

    # elapsed_time = System.os_time(:millisecond) - t
    # if elapsed_time > 10 do
    #   IO.puts("make_calls/can_call: #{inspect(elapsed_time)} ms")
    # end
    
    ret
  end
  def can_call?(calls_spec, hand, ordering, ordering_r, called_tiles \\ [], tile_aliases \\ %{}, tile_mappings \\ %{}), do: Enum.any?(make_calls(calls_spec, hand, ordering, ordering_r, called_tiles, tile_aliases, tile_mappings), fn {_tile, choices} -> not Enum.empty?(choices) end)

  # used in "call_changes_waits" condition
  def partially_apply_match_definitions(hand, calls, match_definitions, ordering, ordering_r, tile_aliases \\ %{}) do
    # take out one copy of each group to process last
    decomposed_match_definitions = for match_definition <- match_definitions do
      {result, _keywords} = for {match_definition_elem, i} <- Enum.with_index(match_definition), reduce: {[], []} do
        {result, keywords} ->
          unique = "unique" in keywords
          case match_definition_elem do
            [groups, num] when num == 1 or unique ->
              # can't remove one from a unique group, so take out the whole group
              entry = {List.delete_at(match_definition, i), keywords ++ [[groups, 1]]}
              {[entry | result], keywords}
            [groups, num] when num > 1      ->
              entry = {List.replace_at(match_definition, i, [groups, num-1]), keywords ++ [[groups, 1]]}
              {[entry | result], keywords}
            [_groups, num] when num < 1     -> {result, keywords}
            keyword when is_binary(keyword) -> {result, keywords ++ [keyword]}
          end
      end
      Enum.reverse(result)
    end |> Enum.concat()
    for {def1, def2} <- decomposed_match_definitions do
      removed = remove_match_definition(hand, calls, def1, ordering, ordering_r, tile_aliases)
      IO.inspect({hand, def1, removed, def2})
      {removed, def2}
    end
  end

  def apply_base_tile_to_offset(offset, base_tile, ordering, ordering_r) do
    cond do
      is_offset(offset)     -> offset_tile(base_tile, offset, ordering, ordering_r)
      Utils.is_tile(offset) -> Utils.to_tile(offset)
      true                  ->
        IO.puts("Unsupported offset #{inspect(offset)}")
        nil
    end
  end

  def apply_base_tile_to_group(group, base_tile, ordering, ordering_r) do
    cond do
      is_offset(group) -> apply_base_tile_to_offset(group, base_tile, ordering, ordering_r)
      is_list(group) -> Enum.map(group, &apply_base_tile_to_offset(&1, base_tile, ordering, ordering_r))
      Utils.is_tile(group) -> Utils.to_tile(group)
      true -> group
    end
  end

  # hand_calls_def is the output of partially_apply_match_definitions
  def is_waiting_on(tile, hand_calls_skipped, ordering, ordering_r, tile_aliases \\ %{}) do
    Enum.any?(hand_calls_skipped, fn {hand, calls, skipped_match_defn} ->
      match_hand(hand ++ [tile], calls, [skipped_match_defn], ordering, ordering_r, tile_aliases)
    end)
  end

  # get all unique waits for a given 14-tile match definition, like win
  # will not remove a wait if you have four of the tile in hand or calls
  def get_waits(hand, calls, match_definitions, all_tiles, ordering, ordering_r, tile_aliases \\ %{}, skip_tenpai_check \\ false) do
    # only check for waits if we're tenpai
    if skip_tenpai_check || match_hand(hand, calls, Enum.map(match_definitions, &["almost" | &1]), ordering, ordering_r, tile_aliases) do
      # go through each match definition and see what tiles can be added for it to match
      # as soon as something doesn't match, get all tiles that help make it match
      # take the union of helpful tiles across all match definitions
      for match_definition <- match_definitions do
        # IO.puts("\n" <> inspect(match_definition))
        {_hand_calls, _keywords, waits_complement} = for {match_definition_elem, i} <- Enum.with_index(match_definition), reduce: {[{hand, calls}], [], all_tiles} do
          {[], keywords, waits_complement}         -> {[], keywords, waits_complement}
          {hand_calls, keywords, []}               -> {hand_calls, keywords, []}
          {hand_calls, keywords, waits_complement} -> case match_definition_elem do
            [_groups, num] when num <= 0 ->
              # TODO lookahead; ignore for now
              {hand_calls, keywords, waits_complement}
            [groups, num] ->
              # must remove groups num-1 times no matter what
              # num_hand_calls = length(hand_calls)
              hand_calls = if num > 1 do
                Enum.flat_map(hand_calls, fn {hand, calls} ->
                  remove_match_definition(hand, calls, keywords ++ [[groups, num - 1]], ordering, ordering_r, tile_aliases)
                  |> Enum.uniq()
                end)
              else hand_calls end

              # try to remove the last one
              {hand_calls_success, hand_calls_failure} = Enum.map(hand_calls, fn {hand, calls} ->
                case remove_match_definition(hand, calls, keywords ++ [[groups, num - 1]], ordering, ordering_r, tile_aliases) do
                  []         -> {[], [{hand, calls}]} # failure
                  hand_calls -> {hand_calls, []} # success (new hand_calls)
                end
              end)
              |> Enum.unzip()
              hand_calls_success = Enum.concat(hand_calls_success)
              hand_calls_failure = Enum.concat(hand_calls_failure)
              # IO.puts("#{inspect(keywords)} #{inspect(match_definition_elem)}: #{num_hand_calls} tries (#{length(hand_calls)} after filtering), #{length(hand_calls_success)} successes, #{length(hand_calls_failure)} failures")

              # waits_complement = all waits that don't help
              # remove waits that do help
              remaining_match_defn = keywords ++ [[groups, 1]] ++ Enum.drop(match_definition, i+1)
              waits_complement = Enum.reject(waits_complement, fn wait ->
                Enum.any?(hand_calls_failure, fn {hand, calls} ->
                  match_hand([wait | hand], calls, [remaining_match_defn], ordering, ordering_r, tile_aliases)
                end)
              end)

              {hand_calls_success, keywords, waits_complement}
            keyword when is_binary(keyword) -> {hand_calls, keywords ++ [keyword], waits_complement}
            _ -> {hand_calls, keywords, waits_complement}
          end
        end
        # TODO maybe instead of taking union of differences, take the difference of intersection
        waits = MapSet.difference(MapSet.new(all_tiles), MapSet.new(waits_complement))
        # IO.inspect(hand, label: "===\nhand")
        # IO.inspect(match_definition, label: "match_definition")
        # IO.inspect(waits, label: "waits")
        waits
      end
      |> Enum.reduce(MapSet.new(), &MapSet.union/2)
    else MapSet.new() end
  end

  defp _get_waits_and_ukeire(hand, calls, match_definitions, wall, visible_tiles, ordering, ordering_r, tile_aliases, skip_tenpai_check) do
    waits = get_waits(hand, calls, match_definitions, MapSet.new(wall), ordering, ordering_r, tile_aliases, skip_tenpai_check)
    # remove irrelevant statuses
    |> Utils.remove_attr(["draw", "discard"])
    visible_tiles = Utils.remove_attr(visible_tiles, ["draw", "discard"])
    freqs = Enum.frequencies(wall -- visible_tiles)
    Map.new(waits, fn wait -> {wait, freqs[wait] || 0} end)
  end

  def get_waits_and_ukeire(hand, calls, match_definitions, wall, visible_tiles, ordering, ordering_r, tile_aliases \\ %{}, skip_tenpai_check \\ false) do
    case RiichiAdvanced.ETSCache.get({:get_waits_and_ukeire, hand, calls, match_definitions, wall, visible_tiles, ordering, tile_aliases}) do
      [] -> 
        result = _get_waits_and_ukeire(hand, calls, match_definitions, wall, visible_tiles, ordering, ordering_r, tile_aliases, skip_tenpai_check)
        RiichiAdvanced.ETSCache.put({:get_waits_and_ukeire, hand, calls, match_definitions, wall, visible_tiles, ordering, tile_aliases}, result)
        result
      [result] -> result
    end
  end

  def get_safe_tiles_against(seat, players, turn \\ nil) do
    riichi_safe = if players[seat].riichi_discard_indices != nil do
      for {dir, ix} <- players[seat].riichi_discard_indices do
        discards = Enum.drop(players[dir].discards, ix)
        # last discard is not safe
        if turn == dir do Enum.drop(discards, -1) else discards end
      end |> Enum.concat()
    else [] end
    players[seat].discards ++ riichi_safe |> Utils.strip_attrs() |> Enum.uniq()
  end

  def collect_base_tiles(hand, calls, offsets, ordering, ordering_r) do
    # essentially take all the tiles we have
    # then apply every offset from groups in reverse
    tiles = Enum.uniq(hand ++ Enum.flat_map(calls, &call_to_tiles/1))
    offsets
    |> Enum.flat_map(fn offset ->
      cond do
        is_integer(offset) -> Enum.map(tiles, &offset_tile(&1, -offset, ordering, ordering_r))
        Map.has_key?(@fixed_offsets, offset) -> [:"1m", :"1p", :"1s"]
        Utils.is_tile(offset) -> [:"1m"]
        true -> []
      end
    end)
    |> Enum.uniq()
  end

  def tile_matches(tile_specs, context) do
    Enum.any?(tile_specs, &case &1 do
      "any" -> true
      "same" ->  Utils.same_tile(context.tile, context.tile2, context.players[context.seat].tile_aliases)
      "not_same" -> not Utils.same_tile(context.tile, context.tile2, context.players[context.seat].tile_aliases)
      "manzu" -> is_manzu?(context.tile)
      "pinzu" -> is_pinzu?(context.tile)
      "souzu" -> is_souzu?(context.tile)
      "jihai" -> is_jihai?(context.tile)
      "terminal" -> is_terminal?(context.tile)
      "yaochuuhai" -> is_yaochuuhai?(context.tile)
      "tanyaohai" -> is_tanyaohai?(context.tile)
      "flower" -> is_flower?(context.tile)
      "joker" -> is_joker?(context.tile)
      "1" -> is_num?(context.tile, 1)
      "2" -> is_num?(context.tile, 2)
      "3" -> is_num?(context.tile, 3)
      "4" -> is_num?(context.tile, 4)
      "5" -> is_num?(context.tile, 5)
      "6" -> is_num?(context.tile, 6)
      "7" -> is_num?(context.tile, 7)
      "8" -> is_num?(context.tile, 8)
      "9" -> is_num?(context.tile, 9)
      "tedashi" -> not Utils.has_attr?(context.tile, ["draw"])
      "tsumogiri" -> Utils.has_attr?(context.tile, ["draw"])
      "dora" -> Utils.count_tiles([context.tile], context.doras) >= 1
      "kuikae" ->
        player = context.players[context.seat]
        base_tiles = collect_base_tiles(player.hand, player.calls, [0,1,2], player.tile_ordering, player.tile_ordering_r)
        potential_set = Utils.add_attr(Enum.take(context.call.other_tiles, 2) ++ [context.tile2], ["hand"])
        triplet = remove_group(potential_set, [], [0,0,0], false, player.tile_ordering, player.tile_ordering_r, player.tile_aliases, base_tiles)
        sequence = remove_group(potential_set, [], [0,1,2], false, player.tile_ordering, player.tile_ordering_r, player.tile_aliases, base_tiles)
        not Enum.empty?(triplet ++ sequence)
      _   ->
        # "1m", "2z" are also specs
        if Utils.is_tile(&1) do
          Utils.same_tile(context.tile, Utils.to_tile(&1))
        else
          IO.puts("Unhandled tile spec #{inspect(&1)}")
          true
        end
    end)
  end
  def tile_matches_all(tile_specs, context) do
    Enum.all?(tile_specs, &tile_matches([&1], context))
  end

  # given a 14-tile hand, and match definitions for 13-tile hands,
  # return all the (unique) tiles that are not needed for all match definitions
  def get_unneeded_tiles(hand, calls, match_definitions, ordering, ordering_r, tile_aliases \\ %{}) do
    # t = System.os_time(:millisecond)
    tile_aliases = filter_irrelevant_tile_aliases(tile_aliases, hand ++ Enum.flat_map(calls, &call_to_tiles/1))

    # filter out negative groups from match definition
    match_definitions = for match_definition <- match_definitions do
      Enum.filter(match_definition, fn match_definition_elem -> is_binary(match_definition_elem) || with [_groups, num] <- match_definition_elem do num > 0 end end)
    end

    {leftover_tiles, _} = Enum.flat_map(match_definitions, fn match_definition ->
      remove_match_definition(hand, calls, match_definition, ordering, ordering_r, tile_aliases)
    end) |> Enum.unzip()
    ret = leftover_tiles
    |> Enum.concat()
    |> Enum.uniq()
    # elapsed_time = System.os_time(:millisecond) - t
    # if elapsed_time > 10 do
    #   IO.puts("get_unneeded_tiles: #{inspect(elapsed_time)} ms")
    # end
    ret
  end

  def needed_for_hand(hand, calls, tile, match_definitions, ordering, ordering_r, tile_aliases \\ %{}) do
    tile not in get_unneeded_tiles(hand, calls, match_definitions, ordering, ordering_r, tile_aliases)
  end

  def flip_faceup(tile) do
    case tile do
      {:"1x", attrs} ->
        tile_attr = Enum.find(attrs, &Utils.is_tile/1)
        if tile_attr != nil do
          Utils.to_tile([tile_attr | attrs]) |> Utils.remove_attr([tile_attr])
        else tile end
      tile -> tile
    end
  end

  def flip_facedown(tile) do
    case tile do
      :"1x" -> :"1x"
      {:"1x", attrs} -> {:"1x", attrs}
      tile -> {:"1x", Utils.tile_to_attrs(tile)}
    end
  end

  def call_to_tiles({_name, call}, replace_am_jokers \\ false) do
    tiles = for {tile, _sideways} <- call do
      flip_faceup(tile)
    end
    if replace_am_jokers && Utils.count_tiles(tiles, [:"1j"]) > 0 do
      # replace all american jokers with the nonjoker tile
      nonjoker = Enum.find(tiles, &not Utils.same_tile(&1, :"1j")) |> Utils.strip_attrs()
      Enum.map(tiles, fn t -> if Utils.same_tile(t, :"1j") do nonjoker else t end end)
    else tiles end
  end

  def get_round_wind(kyoku, num_players) do
    case num_players do
      1 -> cond do
        kyoku == 0 -> :east
        kyoku == 1 -> :south
        kyoku == 2 -> :west
        kyoku >= 3 -> :north
      end
      2 -> cond do
        kyoku >= 0 && kyoku < 2 -> :east
        kyoku >= 2 && kyoku < 4 -> :south
        kyoku >= 4 && kyoku < 6 -> :west
        kyoku >= 6 -> :north
      end
      3 -> cond do
        kyoku >= 0 && kyoku < 3 -> :east
        kyoku >= 3 && kyoku < 6 -> :south
        kyoku >= 6 && kyoku < 9 -> :west
        kyoku >= 9 -> :north
      end
      4 -> cond do
        kyoku >= 0 && kyoku < 4 -> :east
        kyoku >= 4 && kyoku < 8 -> :south
        kyoku >= 8 && kyoku < 12 -> :west
        kyoku >= 12 -> :north
      end
    end
  end

  def get_seat_wind(kyoku, seat, available_seats) do
    ix = Enum.find_index(available_seats, & &1 == seat)
    if ix == nil do nil else Enum.at(available_seats, Integer.mod(ix - kyoku, length(available_seats))) end
  end

  def get_player_from_seat_wind(kyoku, wind, available_seats) do
    Utils.next_turn(wind, rem(kyoku, length(available_seats)))
  end

  def get_east_player_seat(kyoku, available_seats) do
    Enum.at(available_seats, rem(kyoku, length(available_seats)))
  end

  def get_seat_scoring_offset(kyoku, seat, available_seats) do
    case get_seat_wind(kyoku, seat, available_seats) do
      :east  -> 3
      :south -> 2
      :west  -> 1
      :north -> 0
    end
  end

  def get_break_direction(dice_roll, kyoku, seat, available_seats) do
    wall_dir = cond do
      dice_roll in [2, 6, 10] -> :south
      dice_roll in [3, 7, 11] -> :west
      dice_roll in [4, 8, 12] -> :north
      true                    -> :east
    end
    get_seat_wind(kyoku, seat, available_seats) |> Utils.get_relative_seat(wall_dir)
  end

  defp calculate_call_fu({name, call}) do
    {relevant_tile, _sideways} = Enum.at(call, 1, {nil, nil}) # avoids the initial 1x from ankan
    case name do
      "chii"        -> 0
      "pon"         -> if relevant_tile in @terminal_honors do 4 else 2 end
      "ankan"       -> if relevant_tile in @terminal_honors do 32 else 16 end
      "daiminkan"   -> if relevant_tile in @terminal_honors do 16 else 8 end
      "kakan"       -> if relevant_tile in @terminal_honors do 16 else 8 end
      "chon"        -> if relevant_tile in @terminal_honors do 2 else 1 end
      "chon_honors" -> 2
      "anfuun"      -> 16
      "daiminfuun"  -> 8
      "kafuun"      -> 8
      _             -> 0
    end
  end

  defp calculate_pair_fu(tile, seat_wind, round_wind) do
    fu = case Utils.strip_attrs(tile) do
      :"1z" -> if :east  in [seat_wind, round_wind] do 2 else 0 end
      :"2z" -> if :south in [seat_wind, round_wind] do 2 else 0 end
      :"3z" -> if :west  in [seat_wind, round_wind] do 2 else 0 end
      :"4z" -> if :north in [seat_wind, round_wind] do 2 else 0 end
      :"5z" -> 2
      :"6z" -> 2
      :"7z" -> 2
      :"8z" -> 2
      :"0z" -> 2
      _     -> 0
    end
    # double wind 4 fu
    fu = if fu == 2 && tile in [:"1z", :"2z", :"3z", :"4z"] && seat_wind == round_wind do 4 else fu end
    fu
  end

  defp _calculate_fu(starting_hand, calls, winning_tile, win_source, seat_wind, round_wind, ordering, ordering_r, tile_aliases, enable_kontsu_fu) do
    # t = System.os_time(:millisecond)

    IO.puts("Calculating fu for hand: #{inspect(Utils.sort_tiles(starting_hand))} + #{inspect(winning_tile)} and calls #{inspect(calls)}")

    # first put all ton calls back into the hand
    ton_tiles = calls
    |> Enum.filter(fn {name, _call} -> name == "ton" end)
    |> Enum.flat_map(&call_to_tiles/1)
    
    starting_hand = starting_hand ++ ton_tiles |> Utils.strip_attrs()
    winning_tiles = Utils.apply_tile_aliases([winning_tile], tile_aliases) |> Utils.strip_attrs()

    # initial fu: 20 (open ron), 22 (tsumo), or 30 (closed ron)
    is_closed_hand = Enum.all?(calls, fn {name, _call} -> name == "ankan" end)
    fu = cond do
      win_source == :draw -> 22
      is_closed_hand      -> 30
      true                -> 20
    end

    # add fu of called triplets
    fu = fu + (Enum.map(calls, &calculate_call_fu/1) |> Enum.sum)

    # add all hands with winning kanchan/penchan removed, associated with fu = fu+2
    possible_penchan_kanchan_removed = winning_tiles
    |> Enum.flat_map(fn tile ->
      prev = Map.get(ordering_r, tile, nil)
      prev2 = Map.get(ordering_r, prev, nil)
      penchan_l_possible = prev2 != nil && not Map.has_key?(ordering_r, prev2)
      next = Map.get(ordering, tile, nil)
      next2 = Map.get(ordering, next, nil)
      penchan_r_possible = next2 != nil && not Map.has_key?(ordering, next2)
      kanchan_possible = prev != nil && next != nil
      if penchan_l_possible do [[prev, prev2]] else [] end
      ++ if penchan_r_possible do [[next, next2]] else [] end
      ++ if kanchan_possible do [[prev, next]] else [] end
    end)
    |> Enum.flat_map(&try_remove_all_tiles(starting_hand, &1, tile_aliases))
    |> Enum.map(&{&1, fu+2})

    # add all hands with winning ryanmen removed, associated with fu = fu
    possible_left_ryanmen_removed = Enum.flat_map(winning_tiles, fn winning_tile ->
      if offset_tile(winning_tile, -3, ordering, ordering_r) != nil do
        try_remove_all_tiles(starting_hand, [offset_tile(winning_tile, -2, ordering, ordering_r), offset_tile(winning_tile, -1, ordering, ordering_r)], tile_aliases)
        |> Enum.map(fn hand -> {hand, fu+(if enable_kontsu_fu && offset_tile(winning_tile, 10, ordering, ordering_r) == nil do (if win_source == :draw do 4 else 2 end) else 0 end)} end)
      else [] end
    end)
    possible_right_ryanmen_removed = Enum.flat_map(winning_tiles, fn winning_tile ->
      if offset_tile(winning_tile, 3, ordering, ordering_r) != nil do
        try_remove_all_tiles(starting_hand, [offset_tile(winning_tile, 1, ordering, ordering_r), offset_tile(winning_tile, 2, ordering, ordering_r)], tile_aliases)
        |> Enum.map(fn hand -> {hand, fu+(if enable_kontsu_fu && offset_tile(winning_tile, 10, ordering, ordering_r) == nil do (if win_source == :draw do 4 else 2 end) else 0 end)} end)
      else [] end
    end)

    # add all hands with winning kontsu removed, associated with fu = fu+1,2,4 (depending on kontsu)
    possible_kontsu_removed = if enable_kontsu_fu do
      Enum.flat_map(winning_tiles, fn winning_tile ->
        try_remove_all_tiles(starting_hand, [offset_tile(winning_tile, 10, ordering, ordering_r), offset_tile(winning_tile, 20, ordering, ordering_r)], tile_aliases)
        |> Enum.map(fn hand -> {hand, fu+((if win_source == :draw do 2 else 1 end)*(if winning_tile in @terminal_honors do 2 else 1 end))} end)
      end)
    else [] end

    # all the {hand, fu}s together
    hands_fu = possible_penchan_kanchan_removed ++ possible_left_ryanmen_removed ++ possible_right_ryanmen_removed ++ possible_kontsu_removed ++ [{starting_hand, fu}]

    # from these, remove all triplets and add the according amount of closed triplet fu
    hands_fu = for _ <- 1..4, reduce: hands_fu do
      all_hands ->
        Enum.flat_map(all_hands, fn {hand, fu} ->
          hand |> Enum.uniq() |> Utils.apply_tile_aliases(tile_aliases) |> Enum.flat_map(fn base_tile ->
            case try_remove_all_tiles(hand, [base_tile, base_tile, base_tile], tile_aliases) do
              [] -> [{hand, fu}]
              removed -> Enum.map(removed, fn hand -> {hand, fu + if base_tile in @terminal_honors do 8 else 4 end} end)
            end
          end) |> Enum.uniq()
        end) |> Enum.uniq()
    end

    # if kontsu (mixed triplets) is enabled, remove all kontsu and add the corresponding closed kontsu fu
    hands_fu = if enable_kontsu_fu do
      for _ <- 1..4, reduce: hands_fu do
        all_hands ->
          Enum.flat_map(all_hands, fn {hand, fu} ->
            {honors, suited} = hand |> Enum.uniq() |> Utils.apply_tile_aliases(tile_aliases)
            |> Enum.split_with(fn base_tile -> offset_tile(base_tile, 10, ordering, ordering_r) == nil end)
            # remove suited kontsu
            suited_hands_fu = Enum.flat_map(suited, fn base_tile ->
              case try_remove_all_tiles(hand, [base_tile, offset_tile(base_tile, 10, ordering, ordering_r), offset_tile(base_tile, 20, ordering, ordering_r)], tile_aliases) do
                [] -> [{hand, fu}]
                removed -> Enum.map(removed, fn hand -> {hand, fu + if base_tile in @terminal_honors do 4 else 2 end} end)
              end
            end)
            # remove honor kontsu
            honors_hands_fu = Enum.flat_map(honors, fn base_tile ->
              case try_remove_all_tiles(hand, [offset_tile(base_tile, -1, ordering, ordering_r), base_tile, offset_tile(base_tile, 1, ordering, ordering_r)], tile_aliases) do
                [] -> [{hand, fu}]
                removed -> Enum.map(removed, fn hand -> {hand, fu + 4} end)
              end
            end)
            Enum.uniq(suited_hands_fu ++ honors_hands_fu)
          end) |> Enum.uniq()
      end
    else hands_fu end

    # now remove all sequences (no increase in fu)
    hands_fu = for _ <- 1..4, reduce: hands_fu do
      all_hands ->
        Enum.flat_map(all_hands, fn {hand, fu} ->
          sequence_tiles = hand |> Enum.uniq() |> Utils.apply_tile_aliases(tile_aliases)
          sequence_tiles = if enable_kontsu_fu do
            # honor sequences are considered mixed triplets, ignore them
            Enum.reject(sequence_tiles, fn base_tile -> offset_tile(base_tile, 10, ordering, ordering_r) == nil end)
          else sequence_tiles end
          sequence_tiles |> Enum.flat_map(fn base_tile -> 
            case try_remove_all_tiles(hand, [offset_tile(base_tile, -1, ordering, ordering_r), base_tile, offset_tile(base_tile, 1, ordering, ordering_r)], tile_aliases) do
              [] -> [{hand, fu}]
              removed -> Enum.map(removed, fn hand -> {hand, fu} end)
            end
          end)
        end) |> Enum.uniq()
    end

    # IO.inspect(hands_fu)

    # standard hands should either have:
    # - one tile remaining (tanki)
    # - one pair remaining (standard)
    # - two pairs remaining (shanpon)
    # cosmic hand can also have
    # - one pair, one mixed pair remaining
    fus = Enum.flat_map(hands_fu, fn {hand, fu} ->
      num_pairs = Enum.frequencies(hand) |> Map.values() |> Enum.count(& &1 == 2)
      cond do
        length(hand) == 1 && Utils.count_tiles(hand, winning_tiles, tile_aliases) >= 1 -> [fu + 2 + calculate_pair_fu(Enum.at(hand, 0), seat_wind, round_wind)]
        length(hand) == 2 && num_pairs == 1 -> [fu + calculate_pair_fu(Enum.at(hand, 0), seat_wind, round_wind)]
        length(hand) == 4 && num_pairs == 2 ->
          [tile1, tile2] = Enum.uniq(hand)
          tile1_fu = fu + calculate_pair_fu(tile2, seat_wind, round_wind) + (if tile1 in @terminal_honors do 4 else 2 end * if win_source == :draw do 2 else 1 end)
          tile2_fu = fu + calculate_pair_fu(tile1, seat_wind, round_wind) + (if tile2 in @terminal_honors do 4 else 2 end * if win_source == :draw do 2 else 1 end)
          if Utils.count_tiles([tile1], winning_tiles, tile_aliases) == 1 do [tile1_fu] else [] end
          ++ if Utils.count_tiles([tile2], winning_tiles, tile_aliases) == 1 do [tile2_fu] else [] end
        # cosmic hand
        enable_kontsu_fu && length(hand) == 4 && num_pairs == 1 ->
          {pair_tile, _freq} = Enum.frequencies(hand) |> Enum.find(fn {_tile, freq} -> freq == 2 end)
          [mixed1, _mixed2] = hand -- [pair_tile, pair_tile]
          pair_fu = calculate_pair_fu(pair_tile, seat_wind, round_wind)
          kontsu_fu = (if mixed1 in @terminal_honors do 2 else 1 end * if win_source == :draw do 2 else 1 end)
          [fu + pair_fu + kontsu_fu]
        true                                                    -> []
      end
    end)

    # IO.inspect(winning_tiles)
    # IO.inspect(fus, charlists: :as_lists)

    # if we can get (closed) pinfu, we should
    # otherwise, get the max fu possible (= 0 if not a standard hand)
    closed_pinfu_fu = if win_source == :draw do 22 else 30 end
    fu = if closed_pinfu_fu in fus do closed_pinfu_fu else Enum.max(fus, &>=/2, fn -> 0 end) end

    # if it's kokushi, 30 fu (tsumo) or 40 fu (ron)
    # this is balanced for open kokushi being 3 han in space mahjong
    kokushi_tiles = [:"1m", :"9m", :"1p", :"9p", :"1s", :"9s", :"1z", :"2z", :"3z", :"4z", :"5z", :"6z", :"7z"]
    fu = Enum.flat_map(winning_tiles, fn winning_tile ->
      case try_remove_all_tiles(starting_hand ++ [winning_tile], kokushi_tiles, tile_aliases) do
        [] -> [fu]
        _  -> [if win_source == :draw do 30 else 40 end]
      end
    end) |> Enum.max()

    # IO.inspect(fu)

    num_pairs = binary_search_count_matches([{starting_hand, []}], [[[[[0, 0]], 1]]], ordering, ordering_r, tile_aliases)
    ret = cond do
      fu == 22 && win_source == :draw && is_closed_hand -> 20 # closed pinfu tsumo
      fu == 30 && win_source != :draw && is_closed_hand -> 30 # closed pinfu ron
      fu == 20 && not is_closed_hand                    -> 30 # open pinfu
      Enum.empty?(fus) && num_pairs == 6                -> 25 # chiitoitsu
      Enum.empty?(fus) && num_pairs == 5                -> 30 # kakura kurumi (saki card)
      true                                              ->
        # round up to nearest 10
        remainder = rem(fu, 10)
        if remainder == 0 do fu else fu - remainder + 10 end
    end

    # elapsed_time = System.os_time(:millisecond) - t
    # if elapsed_time > 4 do
    #   IO.puts("calculate_fu: #{inspect(elapsed_time)} ms")
    # end

    ret
  end

  def calculate_fu(starting_hand, calls, winning_tile, win_source, seat_wind, round_wind, ordering, ordering_r, tile_aliases \\ %{}, enable_kontsu_fu \\ false) do
    case RiichiAdvanced.ETSCache.get({:calculate_fu, starting_hand, calls, winning_tile, win_source, seat_wind, round_wind, ordering, tile_aliases, enable_kontsu_fu}) do
      [] -> 
        result = _calculate_fu(starting_hand, calls, winning_tile, win_source, seat_wind, round_wind, ordering, ordering_r, tile_aliases, enable_kontsu_fu)
        RiichiAdvanced.ETSCache.put({:calculate_fu, starting_hand, calls, winning_tile, win_source, seat_wind, round_wind, ordering, tile_aliases, enable_kontsu_fu}, result)
        result
      [result] -> result
    end
  end

  def calc_ko_oya_points(score, is_dealer, num_players, han_fu_rounding_factor) do
    divisor = if num_players == 4 do
      if is_dealer do 3 else 4 end
    else # sanma
      if is_dealer do 2 else 3 end
    end
    ko_payment = trunc(Float.ceil(score / divisor / han_fu_rounding_factor) * han_fu_rounding_factor)
    oya_payment = trunc(Float.ceil(2 * score / divisor / han_fu_rounding_factor) * han_fu_rounding_factor)
    # oya_payment is only relevant if is_dealer is false
    # (it is just double ko payment if is_dealer is true, which is useless)
    {ko_payment, oya_payment}
  end

  # TODO take in wall
  def count_ukeire(waits, hand, visible_ponds, visible_calls, winning_tile, tile_aliases \\ %{}) do
    all_tiles = hand ++ visible_ponds ++ Enum.flat_map(visible_calls, &call_to_tiles/1) -- [winning_tile]
    waits
    |> Enum.map(fn wait -> 4 - Utils.count_tiles(all_tiles, [wait], tile_aliases) end)
    |> Enum.sum()
  end

  def test_tiles(hand, tiles, tile_aliases) do
    not Enum.empty?(try_remove_all_tiles(hand, tiles, tile_aliases))
  end

  def get_disconnected_tiles(hand, ordering, ordering_r, tile_aliases \\ %{}) do
    hand
    |> Enum.uniq()
    |> Enum.filter(fn tile ->
      cond do
        Utils.count_tiles(hand, [tile], tile_aliases) >= 2 -> false
        Utils.count_tiles(hand, [Utils.strip_attrs(tile)], tile_aliases) >= 2 -> false
        is_jihai?(tile) -> true
        true ->
          past_suji_left = test_tiles(hand, [offset_tile(tile, -4, ordering, ordering_r), tile], tile_aliases)
          suji_left = test_tiles(hand, [offset_tile(tile, -3, ordering, ordering_r), tile], tile_aliases)
          jump_left = test_tiles(hand, [offset_tile(tile, -2, ordering, ordering_r), tile], tile_aliases)
          adjacent_left = test_tiles(hand, [offset_tile(tile, -1, ordering, ordering_r), tile], tile_aliases)
          adjacent_right = test_tiles(hand, [offset_tile(tile, 1, ordering, ordering_r), tile], tile_aliases)
          jump_right = test_tiles(hand, [offset_tile(tile, 2, ordering, ordering_r), tile], tile_aliases)
          suji_right = test_tiles(hand, [offset_tile(tile, 3, ordering, ordering_r), tile], tile_aliases)
          past_suji_right = test_tiles(hand, [offset_tile(tile, 4, ordering, ordering_r), tile], tile_aliases)
          arr = [past_suji_left, suji_left, jump_left, adjacent_left, true, adjacent_right, jump_right, suji_right, past_suji_right]
          # IO.inspect({tile, arr})
          case arr do
            [_, _, false, false, _t, false, false, _, _] -> true
            [_, _, false, false, _t, _, _, true, false] -> true # 14 or 134 or 124 -> toss 1
            [false, true, _, _, _t, false, false, _, _] -> true # 69 or 679 or 689 -> toss 9
            # [_, _, _, _, _t, true, _, _, _] -> false
            _ -> false
          end
      end
    end)
    # |> IO.inspect(label: "result")
  end

  def get_centralness(tile) do
    cond do
      is_num?(tile, 1) -> 1
      is_num?(tile, 2) -> 2
      is_num?(tile, 3) -> 3
      is_num?(tile, 4) -> 4
      is_num?(tile, 5) -> 4
      is_num?(tile, 6) -> 4
      is_num?(tile, 7) -> 3
      is_num?(tile, 8) -> 2
      is_num?(tile, 9) -> 1
      true                    -> 0
    end
  end

  def genbutsu_to_suji(genbutsu, ordering, ordering_r) do
    Enum.flat_map(genbutsu, &cond do
      Enum.any?([1,2,3], fn k -> is_num?(&1, k) end) -> if offset_tile(&1, 6, ordering, ordering_r) in genbutsu do [offset_tile(&1, 3, ordering, ordering_r)] else [] end
      Enum.any?([4,5,6], fn k -> is_num?(&1, k) end) -> [offset_tile(&1, -3, ordering, ordering_r), offset_tile(&1, 3, ordering, ordering_r)]
      Enum.any?([7,8,9], fn k -> is_num?(&1, k) end) -> if offset_tile(&1, -6, ordering, ordering_r) in genbutsu do [offset_tile(&1, -3, ordering, ordering_r)] else [] end
      true -> []
    end)
  end

  def compute_almost_group(group) do
    cond do
      # group of tiles
      is_list(group) && not Enum.empty?(group) ->
        cond do
          # list of integers specifying a group of tiles
          Enum.any?(group, &is_offset/1) ->
            for {tile, i} <- Enum.with_index(group), tile not in @group_keywords do
              almost_group = List.delete_at(group, i)
              lowest = almost_group |> Enum.filter(&is_integer/1) |> Enum.min(&<=/2, fn -> 0 end)
              Enum.map(almost_group, &if is_integer(&1) do &1 - lowest else &1 end)
            end
          # list of lists of integers specifying multiple related subgroups of tiles
          Enum.all?(group, &is_list(&1) || &1 in @group_keywords) && Enum.all?(group, & &1 in @group_keywords || Enum.all?(&1, fn item -> is_offset(item) end)) ->
            for {subgroup, i} <- Enum.with_index(group), is_list(subgroup), {_tile, j} <- Enum.with_index(subgroup) do
              almost_group = if length(subgroup) == 1 do List.delete_at(group, i) else List.update_at(group, i, &List.delete_at(&1, j)) end
              lowest = almost_group |> Enum.filter(&is_list/1) |> Enum.concat() |> Enum.filter(&is_integer/1) |> Enum.min()
              Enum.map(almost_group, fn subgroup -> if is_list(subgroup) do Enum.map(subgroup, & &1 - lowest) else subgroup end end)
            end
          # list of tiles
          Enum.all?(group, &Utils.is_tile/1) ->
            for {_tile, i} <- Enum.with_index(group) do
              List.delete_at(group, i)
            end
          true -> []
        end
      true -> []
    end |> Enum.uniq()
  end

  def combine_groups(match_definition) do
    {result, _keywords, _acc} = for {match_definition_elem, i} <- Enum.with_index(match_definition), reduce: {[], [], 0} do
      {result, keywords, acc} ->
        if "unique" in keywords do
          # can't combine groups if we're marked unique
          {[match_definition_elem | result], keywords, 0}
        else
          case {match_definition_elem, Enum.at(match_definition, i + 1)} do
            {[groups, num], [next_groups, _next_num]} when groups == next_groups -> {result, keywords, acc + max(0, num)}
            {[groups, num], _} -> {[[groups, num + acc] | result], keywords, 0}
            {keyword, _} when is_binary(keyword) -> {[keyword | result], [keyword | keywords], 0}
            _ -> {[match_definition_elem | result], keywords, 0}
          end
        end
    end
    Enum.reverse(result)
  end

  def groups_subsumes?(groups1, groups2) do
    if ("unique" in groups1) != ("unique" in groups2) do
      false
    else
      nojoker_ix_1 = Enum.find_index(groups1, & &1 == "nojoker")
      nojoker_ix_2 = Enum.find_index(groups2, & &1 == "nojoker")
      {joker1, ["nojoker" | nojoker1]} = if nojoker_ix_1 != nil do Enum.split(groups1, nojoker_ix_1) else {groups1, ["nojoker"]} end
      {joker2, ["nojoker" | nojoker2]} = if nojoker_ix_2 != nil do Enum.split(groups2, nojoker_ix_2) else {groups2, ["nojoker"]} end
      Enum.empty?(joker2 -- joker1) && Enum.empty?(nojoker2 -- ((joker1 -- joker2) ++ nojoker1))
    end
  end

  # we're checking if match_definition1 matches equally or strictly more than match_definition2
  def match_definition_subsumes?(match_definition1, match_definition2, keywords1 \\ [], keywords2 \\ [])
  def match_definition_subsumes?(_match_definition1, [], keywords1, keywords2) do
    # IO.inspect({keywords1, keywords2}, label: "iteration")
    cond do
      "exhaustive" not in keywords1 && "exhaustive" in keywords2 -> false
      "debug" not in keywords1 && "debug" in keywords2 -> false
      true -> true
    end
  end
  def match_definition_subsumes?([], _match_definition2, _keywords1, _keywords2), do: false
  def match_definition_subsumes?([match_definition_elem1 | match_definition1], [match_definition_elem2 | match_definition2], keywords1, keywords2) do
    # IO.inspect({[match_definition_elem1 | match_definition1], [match_definition_elem2 | match_definition2]}, label: "iteration")
    case {match_definition_elem1, match_definition_elem2} do
      {_, r} when is_binary(r) -> match_definition_subsumes?([match_definition_elem1 | match_definition1], match_definition2, keywords1, [r | keywords2])
      {l, _} when is_binary(l) -> match_definition_subsumes?(match_definition1, [match_definition_elem2 | match_definition2], [l | keywords1], keywords2)
      {[groups1, num1], [groups2, num2]} ->
        if groups_subsumes?(groups1, groups2) do
          cond do
            num1 == num2 || (num1 >= num2 && "unique" in keywords2) -> match_definition_subsumes?(match_definition1, match_definition2, keywords1, keywords2)
            num1 >  num2 -> match_definition_subsumes?([[groups1, num1 - num2] | match_definition1], match_definition2, keywords1, keywords2)
            num1 <  num2 -> match_definition_subsumes?(match_definition1, [[groups2, num2 - num1] | match_definition2], keywords1, keywords2)
          end
        else false end
      _ -> false
    end
  end

  # not only does this deduplicate, but it also removes match definitions subsumed by another
  def deduplicate_match_definitions(match_definitions) do
    for match_definition <- match_definitions, reduce: [] do
      acc -> if Enum.any?(acc, &match_definition_subsumes?(&1, match_definition)) do
        # IO.inspect(match_definition, label: "removed")
        acc
      else
        [match_definition | acc]
      end
    end |> Enum.reverse()
  end

  def compute_almost_match_definition_at_index(match_definition, i, groups, num) do
    new_groups = groups
    |> Enum.flat_map(&compute_almost_group/1)
    |> Enum.reject(&Enum.empty?/1)
    |> Enum.uniq()
    cond do
      abs(num) <= 1 && "unique" in groups ->
        # group with unique keyword with num <= 1
        match_definition
        |> List.delete_at(i)
      abs(num) > 1 && "unique" in groups ->
        # group with unique keyword with num > 1
        match_definition
        |> List.replace_at(i, [groups, num - 1])
      abs(num) <= 1 && Enum.empty?(new_groups) ->
        # lookahead for one item
        match_definition
        |> List.delete_at(i)
      abs(num) <= 1 ->
        # lookahead for more than one item
        match_definition
        |> List.replace_at(i, [new_groups, num])
      Enum.empty?(new_groups) ->
        # normal group with one item
        match_definition
        |> List.replace_at(i, [groups, if num > 0 do num - 1 else num + 1 end])
      true ->
        # normal group with more than one item
        match_definition
        |> List.replace_at(i, [groups, if num > 0 do num - 1 else num + 1 end])
        |> List.insert_at(i, [new_groups, if num > 0 do 1 else -1 end])
    end
    |> combine_groups()
  end

  def compute_almost_match_definitions(match_definitions) do
    # first, decrement all lookaheads
    match_definitions = for match_definition <- match_definitions do
      for {match_definition_elem, i} <- Enum.reverse(Enum.with_index(match_definition)), reduce: match_definition do
        match_definition -> case match_definition_elem do
          [groups, num] when num <= 0 -> compute_almost_match_definition_at_index(match_definition, i, groups, num)
          _ -> match_definition
        end
      end
    end
    # then remove one from each group
    for match_definition <- match_definitions do
      {result, _keywords} = for {match_definition_elem, i} <- Enum.with_index(match_definition), reduce: {[], []} do
        {result, keywords} -> case match_definition_elem do
          [groups, num] when num >= 1 ->
            entry = compute_almost_match_definition_at_index(match_definition, i, groups, num)
            {[entry | result], keywords}
          keyword when is_binary(keyword) -> {result, keywords ++ [keyword]}
          _ -> {result, keywords}
        end
      end
      Enum.reverse(result)
    end
    |> Enum.concat()
    |> Enum.uniq()
    # |> IO.inspect(label: "before deduplication")
    |> deduplicate_match_definitions()
    # |> then(fn result ->
    #   IO.inspect(length(result), label: "result")
    #   result
    # end)
  end

end
