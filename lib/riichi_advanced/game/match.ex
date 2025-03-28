defmodule RiichiAdvanced.Match do
  alias RiichiAdvanced.GameState.TileBehavior, as: TileBehavior
  alias RiichiAdvanced.Riichi, as: Riichi
  alias RiichiAdvanced.Utils, as: Utils
  use Nebulex.Caching

  @shift_suit %{:"1m"=>:"1p", :"2m"=>:"2p", :"3m"=>:"3p", :"4m"=>:"4p", :"5m"=>:"5p", :"6m"=>:"6p", :"7m"=>:"7p", :"8m"=>:"8p", :"9m"=>:"9p", :"10m"=>:"10p",
                :"1p"=>:"1s", :"2p"=>:"2s", :"3p"=>:"3s", :"4p"=>:"4s", :"5p"=>:"5s", :"6p"=>:"6s", :"7p"=>:"7s", :"8p"=>:"8s", :"9p"=>:"9s", :"10p"=>:"10s",
                :"1s"=>:"1m", :"2s"=>:"2m", :"3s"=>:"3m", :"4s"=>:"4m", :"5s"=>:"5m", :"6s"=>:"6m", :"7s"=>:"7m", :"8s"=>:"8m", :"9s"=>:"9m", :"10s"=>:"10m",
                :"0z"=>nil, :"1z"=>nil, :"2z"=>nil, :"3z"=>nil, :"4z"=>nil, :"5z"=>nil, :"6z"=>nil, :"7z"=>nil, :"8z"=>nil}
  defp shift_suit(tile), do: @shift_suit[tile]

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

  def is_integer_offset(tile) do
    case tile do
      %{"offset" => offset} -> is_integer(offset)
      _ -> is_integer(tile)
    end
  end

  def is_offset(tile) do
    is_integer_offset(tile) or Map.has_key?(@fixed_offsets, tile)
  end

  def combine_offsets(o1, o2, op \\ &+/2) do
    {o1, attrs1} = case o1 do
      %{"offset" => offset} -> {offset, Map.get(o1, "attrs", [])}
      offset                -> {offset, []}
    end
    {o2, attrs2} = case o2 do
      %{"offset" => offset} -> {offset, Map.get(o2, "attrs", [])}
      offset                -> {offset, []}
    end
    attrs = MapSet.to_list(MapSet.intersection(MapSet.new(attrs1), MapSet.new(attrs2)))
    %{"offset" => op.(o1, o2), "attrs" => attrs}
  end

  defp suit_to_offset(tile) do
    cond do
      Riichi.is_manzu?(tile) -> 0
      Riichi.is_pinzu?(tile) -> 10
      Riichi.is_souzu?(tile) -> 20
      true -> 0
    end
  end

  defp _offset_tile(tile, n, tile_behavior, shift_dragons \\ false) do
    if tile != nil do
      cond do
        Map.has_key?(@fixed_offsets, n) -> _offset_tile(@fixed_offsets[n], suit_to_offset(tile), tile_behavior, true)
        Utils.is_tile(n) -> Utils.to_tile(n)
        (n < 1 and n > -1) or n < -30 or n >= 30 ->
          tile
        n >= 10 ->
          cond do
            shift_dragons and tile == :"7z" -> _offset_tile(:"0z", n-10, tile_behavior, true)
            shift_dragons and tile == :"0z" -> _offset_tile(:"6z", n-10, tile_behavior, true)
            shift_dragons and tile == :"6z" -> _offset_tile(:"7z", n-10, tile_behavior, true)
            true -> _offset_tile(shift_suit(tile), n-10, tile_behavior)
          end
        n <= -10 ->
          cond do
            shift_dragons and tile == :"7z" -> _offset_tile(:"6z", n+10, tile_behavior, true)
            shift_dragons and tile == :"0z" -> _offset_tile(:"7z", n+10, tile_behavior, true)
            shift_dragons and tile == :"6z" -> _offset_tile(:"0z", n+10, tile_behavior, true)
            true -> _offset_tile(shift_suit(shift_suit(tile)), n+10, tile_behavior)
          end
        n <= -1 ->
          _offset_tile(tile_behavior.ordering_r[tile], n+1, tile_behavior)
        true -> # n >= 1
          _offset_tile(tile_behavior.ordering[tile], n-1, tile_behavior)
      end
    else nil end
  end

  def offset_tile(tile, n, tile_behavior, shift_dragons \\ false) do
    {n, attrs} = case n do
      %{"offset" => offset} -> {offset, Map.get(n, "attrs", [])}
      n -> {n, []}
    end
    if n != nil do
      case tile do
        :any -> :any
        {tile, attrs2} -> Utils.add_attr(_offset_tile(tile, n, tile_behavior, shift_dragons), attrs2)
        tile -> _offset_tile(tile, n, tile_behavior, shift_dragons)
      end
      |> Utils.add_attr(attrs)
    else nil end
  end

  defp remove_tile(hand, tile, ignore_suit, acc \\ [])
  defp remove_tile([], _tile, _ignore_suit, _acc), do: []
  defp remove_tile([t | hand], tile, ignore_suit, acc) do
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

  defp _try_remove_all_tiles(hand, [], _tile_behavior), do: [hand]
  defp _try_remove_all_tiles(hand, [tile | tiles], tile_behavior) when tile_behavior.aliases == %{} do
    [tile]
    |> Enum.flat_map(&remove_tile(hand, &1, tile_behavior.ignore_suit))
    |> Enum.flat_map(&_try_remove_all_tiles(&1, tiles, tile_behavior))
    |> Enum.uniq()
  end
  defp _try_remove_all_tiles(hand, [tile | tiles], tile_behavior) do
    # remove all tiles, with the first result removing non-jokers over jokers or :any
    tile
    |> Utils.apply_tile_aliases(tile_behavior)
    |> MapSet.to_list()
    |> TileBehavior.sort_by_joker_power(tile_behavior)
    |> Enum.flat_map(&remove_tile(hand, &1, tile_behavior.ignore_suit))
    |> Enum.flat_map(&_try_remove_all_tiles(&1, tiles, tile_behavior))
    |> Enum.uniq()
  end

  def try_remove_all_tiles(hand, tiles, tile_behavior \\ %TileBehavior{}) do
    if length(hand) >= length(tiles) do
      # even if there are no jokers,
      # we want to sort by attr length so tiles with more attrs get removed last
      hand = TileBehavior.sort_by_joker_power(hand, tile_behavior)
      if nil in tiles do
        IO.puts("WARNING: try_remove_all_tiles was passed a nil tile!")
      end
      _try_remove_all_tiles(hand, tiles, tile_behavior)
    else [] end
  end

  def remove_from_hand_calls(hand, calls, [], _tile_behavior), do: [{hand, calls}]
  def remove_from_hand_calls(hand, calls, tiles, tile_behavior) do
    if nil in tiles do
      []
    else
      from_hand = try_remove_all_tiles(hand, tiles, tile_behavior) |> Enum.map(fn hand -> {hand, calls} end)
      from_calls = calls
      |> Enum.map(&Utils.call_to_tiles/1)
      |> Enum.with_index()
      |> Enum.flat_map(fn {call, i} ->
        removed = try_remove_all_tiles(call, tiles, tile_behavior)
        if Enum.empty?(removed) do [] else
          if tile_behavior.dismantle_calls do
            for new_call <- removed do
              {hand, List.update_at(calls, i, fn {name, _call} -> {name, new_call} end)}
            end
          else
            [{hand, List.delete_at(calls, i)}]
          end
        end
      end)
      # prioritize removing calls
      Enum.uniq(from_calls ++ from_hand)
    end
  end

  defp try_remove_call(hand, calls, call_name) do
    ix = Enum.find_index(calls, fn {name, _call} -> name == call_name end)
    if ix != nil do [{hand, List.delete_at(calls, ix)}] else [] end
  end

  @group_keywords ["nojoker", "unique"]
  def group_keywords(), do: @group_keywords

  defp group_to_subgroups([], _base_tile, _tile_behavior), do: []
  defp group_to_subgroups(group, base_tile, tile_behavior) do
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
    |> Enum.map(&Enum.map(&1, fn tile -> if Utils.is_tile(tile) do Utils.to_tile(tile) else offset_tile(base_tile, tile, tile_behavior) end end))
  end

  def _remove_group(hand, calls, group, base_tile, tile_behavior) do
    # IO.puts("removing group #{inspect(group)} with base tile #{base_tile} from hand #{inspect(hand)}")
    cond do
      is_list(group) ->
        no_joker_index = Enum.find_index(group, fn elem -> elem == "nojoker" end)
        {joker, nojoker} = Enum.split(group, if no_joker_index != nil do no_joker_index else length(group) end)
        # handle nojoker subgroups first
        hand_calls = for subgroup <- group_to_subgroups(nojoker, base_tile, tile_behavior), reduce: [{hand, calls}] do
          hand_calls -> Enum.flat_map(hand_calls, fn {hand, calls} -> remove_from_hand_calls(hand, calls, subgroup, %TileBehavior{ tile_behavior | aliases: %{} }) end)
        end
        # handle joker subgroups next
        hand_calls = for subgroup <- group_to_subgroups(joker, base_tile, tile_behavior), reduce: hand_calls do
          hand_calls ->
            ret = Enum.flat_map(hand_calls, fn {hand, calls} -> remove_from_hand_calls(hand, calls, subgroup, tile_behavior) end)
            # if {:ok, [group]} == RiichiAdvanced.Parser.parse_set("0@yaochuu 0@yaochuu 0@winning_tile&tsumo") do
            #   if ret != [] do
            #     IO.inspect({subgroup, hand_calls, ret})
            #     IO.inspect(tile_behavior.aliases)
            #     IO.puts("")
            #   end
            # end
            ret
        end
        hand_calls
      is_offset(group) -> remove_from_hand_calls(hand, calls, [offset_tile(base_tile, group, tile_behavior)], tile_behavior)
      Utils.is_tile(group) -> remove_from_hand_calls(hand, calls, [Utils.to_tile(group)], tile_behavior)
      is_binary(group) -> try_remove_call(hand, calls, group)
      true ->
        IO.puts("Unhandled group #{inspect(group)}")
        [{hand, calls}]
    end
  end

  def remove_group(hand, calls, group, base_tiles, tile_behavior) do
    # IO.puts("removing group #{inspect(group)} from hand #{inspect(hand)}")
    # t = System.os_time(:millisecond)
    ret = base_tiles
    |> Enum.map(&Task.async(fn -> _remove_group(hand, calls, group, &1, tile_behavior) end))
    |> Task.yield_many(timeout: :infinity)
    |> Enum.flat_map(fn {_task, {:ok, res}} -> res end)
    # elapsed_time = System.os_time(:millisecond) - t
    # if elapsed_time > 10 do
    #   IO.puts("remove_group: #{inspect(hand)} #{inspect(group)} #{inspect(elapsed_time)} ms")
    # end
    ret
  end

  # @match_keywords ["almost", "exhaustive", "ignore_suit", "restart", "dismantle_calls", "unique", "nojoker", "debug"]
  # def match_keywords(), do: @match_keywords

  def filter_irrelevant_tile_aliases(tile_behavior, relevant_tiles) do
    # filter out irrelevant tile aliases
    %TileBehavior{ tile_behavior | aliases:
      for {tile, attrs_aliases} <- tile_behavior.aliases do
        new_attrs_aliases = for {attrs, aliases} <- attrs_aliases do
          {attrs, Enum.filter(aliases, fn t -> Enum.any?(relevant_tiles, &Utils.same_tile(&1, t)) end) |> MapSet.new()}
        end
        |> Enum.reject(fn {_attrs, aliases} -> Enum.empty?(aliases) end)
        |> Map.new()
        {tile, new_attrs_aliases}
      end
      |> Enum.reject(fn {_tile, attrs_aliases} -> Enum.empty?(attrs_aliases) end)
      |> Map.new()
    }
  end

  def arrange_by_base_tile(tiles, base_tile, group, tile_behavior) do
    # this only handles groups that are a sequence of offsets like [0, 1, 2]
    if is_list(group) && Enum.all?(group, &is_offset/1) do
      base_tile = Utils.strip_attrs(base_tile)
      tiles_i = Enum.with_index(tiles)
      {pairing, _pairing_r} = group
      |> Enum.map(&offset_tile(base_tile, &1, tile_behavior))
      |> Enum.with_index()
      |> Map.new(fn {tile, i} -> {i, for {tile2, j} <- tiles_i, Utils.same_tile(tile2, tile, tile_behavior) do j end} end)
      |> Utils.maximum_bipartite_matching()
      Enum.map(0..length(group)-1, &Enum.at(tiles, pairing[&1]))
    else tiles end
  end

  def _extract_groups([], acc, _group, _base_tiles, _tile_behavior), do: Enum.uniq_by(acc, fn {hand, _groups} -> hand end)
  def _extract_groups(hand_groups, acc, group, base_tiles, tile_behavior) do
    hand_groups
    |> Enum.uniq_by(fn {hand, _groups} -> hand end)
    |> Enum.flat_map(fn {hand, groups} ->
      base_tiles
      |> Enum.map(&Task.async(fn ->
        _remove_group(hand, [], group, &1, tile_behavior)
        |> Enum.map(fn {hand, []} -> {hand, &1} end)
      end))
      |> Task.yield_many(timeout: :infinity)
      |> Enum.flat_map(fn {_task, {:ok, res}} -> res end)
      |> Enum.map(fn {removed, base_tile} -> {removed, [arrange_by_base_tile(hand -- removed, base_tile, group, tile_behavior) | groups]} end)
    end)
    |> _extract_groups(hand_groups ++ acc, group, base_tiles, tile_behavior)
  end
  def extract_groups(hand, group, tile_behavior) do
    # try to extract group as many times as you can from hand
    # this should return shortest hands first, so take the first one found
    base_tiles = collect_base_tiles(hand, [], group, tile_behavior)
    _extract_groups([{hand, []}], [{hand, []}], group, base_tiles, tile_behavior)
  end

  def collect_base_tiles(hand, calls, offsets, tile_behavior \\ %TileBehavior{}) do
    # essentially take all the tiles we have
    # then apply every offset from groups in reverse
    tiles = Enum.uniq(hand ++ Enum.flat_map(calls, &Utils.call_to_tiles/1))
    base_tiles = offsets
    |> Enum.flat_map(fn offset ->
      cond do
        is_integer_offset(offset) -> Enum.map(tiles, fn tile -> offset_tile(tile, combine_offsets(offset, -1, &*/2), tile_behavior) end)
        Map.has_key?(@fixed_offsets, offset) -> [:"1m", :"1p", :"1s"]
        Utils.is_tile(offset) -> [:"1m"]
        true -> []
      end
    end)
    |> Enum.uniq()
    # also add all tile mappings
    mappings = for {tile, mappings} <- TileBehavior.tile_mappings(tile_behavior), base_tile <- base_tiles, Utils.same_tile(base_tile, tile) do mappings end
    base_tiles = [base_tiles | mappings]
    |> Enum.concat()
    |> Enum.uniq()
    # also strip attrs (after applying tile mappings)
    base_tiles = base_tiles ++ Utils.strip_attrs(base_tiles)
    |> Enum.uniq()
    # never let :any be a base tile
    |> Enum.reject(&Utils.strip_attrs(&1) in [nil, :any])
    # no jokers
    |> Enum.reject(&TileBehavior.is_joker?(&1, tile_behavior))
    # if there are no offsets, always return 1m as a base tile
    if Enum.empty?(base_tiles) do [:"1m"] else base_tiles end
  end

  @decorate cacheable(cache: RiichiAdvanced.Cache, key: {:remove_match_definition, hand, calls, match_definition, TileBehavior.hash(tile_behavior)})
  def remove_match_definition(hand, calls, match_definition, tile_behavior) do
    # t = System.os_time(:millisecond)
    almost = "almost" in match_definition
    exhaustive_ix = Enum.find_index(match_definition, & &1 == "exhaustive")
    ignore_suit_ix = Enum.find_index(match_definition, & &1 == "ignore_suit")
    dismantle_calls_ix = Enum.find_index(match_definition, & &1 == "dismantle_calls")
    no_joker_index = Enum.find_index(match_definition, & &1 == "nojoker")
    unique_ix = Enum.find_index(match_definition, & &1 == "unique")
    debug = "debug" in match_definition
    if almost and :any in hand do
      IO.puts("Warning: \"almost\" keyword does not support hands that have :any yet")
    end
    hand = if almost or :any in hand do
      {any, hand} = Enum.split_with(hand, & &1 == :any)
      any = if almost do [:any | any] else any end
      hand ++ any
    else hand end
    tile_behavior = filter_irrelevant_tile_aliases(tile_behavior, hand ++ Enum.flat_map(calls, &Utils.call_to_tiles/1))
    if debug do
      IO.puts("======================================================")
      IO.puts("Match definition: #{inspect(match_definition, charlists: :as_lists)}")
      IO.puts("Starting hand / calls: #{inspect(hand, charlists: :as_lists)} / #{inspect(calls, charlists: :as_lists)}")
      IO.puts("Tile aliases: #{inspect(tile_behavior.aliases)}")
      # IO.puts("Tile ordering: #{inspect(tile_behavior.ordering)}")
    end
    ret = for {match_definition_elem, i} <- Enum.with_index(match_definition), reduce: [{hand, calls}] do
      [] -> []
      hand_calls ->
        exhaustive = exhaustive_ix != nil and i > exhaustive_ix
        unique = unique_ix != nil and i > unique_ix
        tile_behavior = %TileBehavior{ tile_behavior |
          dismantle_calls: dismantle_calls_ix != nil and i > dismantle_calls_ix,
          ignore_suit: ignore_suit_ix != nil and i > ignore_suit_ix
        }
        case match_definition_elem do
          "restart" -> [{hand, calls}]
          [groups, num] ->
            unique = unique or "unique" in groups
            nojoker = no_joker_index != nil and i > no_joker_index
            tile_behavior = if nojoker do %TileBehavior{ tile_behavior | aliases: %{} } else tile_behavior end
            new_hand_calls = if unique and num >= 1 and not exhaustive and Enum.all?(groups, &not is_list(&1) and (Utils.is_tile(&1) or &1 in @group_keywords)) do
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
                    tiles = if is_hand do call else Utils.call_to_tiles(call) end
                    num_tiles = length(tiles)
                    adj_joker   = Map.new(Enum.with_index(joker),   fn {tile, i} -> {i,                 for {tile2, j}  <- Enum.with_index(tiles), Utils.same_tile(tile2, tile, tile_behavior) do j end} end)
                    adj_nojoker = Map.new(Enum.with_index(nojoker), fn {tile, i} -> {length(joker) + i, for {tile2, j}  <- Enum.with_index(tiles), Utils.same_tile(tile2, tile, %TileBehavior{ tile_behavior | aliases: %{} }) do j end} end)
                    adj = Map.merge(adj_joker, adj_nojoker)
                    {pairing, pairing_r} = Utils.maximum_bipartite_matching(adj)
                    consumes_call = map_size(pairing) == num_tiles or tile_behavior.dismantle_calls
                    consumes_match = map_size(pairing) == to_remove_num
                    if consumes_call or consumes_match do
                      n = length(joker) 
                      to_remove = pairing |> Map.keys() |> Enum.take(to_remove_num)
                      {from_joker, from_nojoker} = to_remove |> Enum.sort(:desc) |> Enum.split_while(fn i -> i < n end)
                      nojoker = for i <- from_nojoker, reduce: nojoker do nojoker -> List.delete_at(nojoker, i - n) end
                      joker   = for i <- from_joker,   reduce: joker   do joker   -> List.delete_at(joker,   i    ) end
                      # if this call is hand or dismantlable, we keep all unmatched tiles
                      ret = if is_hand or tile_behavior.dismantle_calls do
                        to_remove_r = pairing_r |> Map.keys() |> Enum.take(to_remove_num)
                        tiles = for j <- to_remove_r |> Enum.sort(:desc), reduce: tiles do tiles -> List.delete_at(tiles, j) end
                        item = if is_hand do tiles else with {name, _call} <- call do {name, tiles} end end
                        [item | ret]
                      else ret end # not hand or dismantlable, so we discard all unmatched tiles
                      {ret, joker, nojoker, to_remove_num - length(to_remove)}
                    else {[call | ret], joker, nojoker, to_remove_num} end
                end
                # check that match is consumed
                if to_remove_num == 0 do [{hand, calls}] else [] end
              end)
              |> Enum.uniq()
            else
              tile_behavior = if no_joker_index != nil and i > no_joker_index do %TileBehavior{ tile_behavior | aliases: %{} } else tile_behavior end
              # unique makes it so all groups must be offset by the same tile
              # (no such restriction for non-unique groups)
              base_tiles = collect_base_tiles(hand, calls, List.flatten(groups), tile_behavior)
              for base_tile <- (if unique do base_tiles else [nil] end) do
                Task.async(fn ->
                  for _ <- (if num == 0 do [1] else 1..abs(num) end), reduce: Enum.map(hand_calls, fn {hand, calls} -> {hand, calls, groups} end) do
                    [] -> []
                    hand_calls_groups ->
                      report = if debug do
                        line1 = "Acc (before removal): (base tiles #{inspect(base_tiles)})"
                        lines = for {hand, calls, remaining_groups} <- hand_calls_groups do
                          "- #{inspect(hand)} / #{inspect(calls)} \\\\ #{inspect(remaining_groups, charlists: :as_lists)}#{if unique do " unique" else "" end}#{if exhaustive do " exhaustive" else "" end} #{if base_tile != nil do inspect(base_tile) else "" end}"
                        end
                        [line1 | lines]
                      else "" end
                      new_hand_calls_groups = if exhaustive do
                        for {hand, calls, remaining_groups} <- hand_calls_groups, {group, i} <- Enum.with_index(remaining_groups), group not in @group_keywords do
                          no_joker_index = Enum.find_index(remaining_groups, fn elem -> elem == "nojoker" end)
                          nojoker = no_joker_index != nil and i > no_joker_index
                          tile_behavior = if nojoker do %TileBehavior{ tile_behavior | aliases: %{} } else tile_behavior end
                          Task.async(fn ->
                            if unique do
                              _remove_group(hand, calls, group, base_tile, tile_behavior)
                            else
                              remove_group(hand, calls, group, base_tiles, tile_behavior)
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
                            nojoker = no_joker_index != nil and i > no_joker_index
                            tile_behavior = if nojoker do %TileBehavior{ tile_behavior | aliases: %{} } else tile_behavior end
                            if unique do
                              _remove_group(hand, calls, group, base_tile, tile_behavior)
                            else
                              remove_group(hand, calls, group, base_tiles, tile_behavior)
                            end
                            |> Enum.take(1)
                            |> Enum.map(fn {hand, calls} -> {hand, calls, if unique do List.delete_at(remaining_groups, i) else remaining_groups end} end)
                          result -> result
                        end
                      end
                      if debug do
                        line1 = "Acc (after removal):"
                        lines = for {hand, calls, _remaining_groups} <- new_hand_calls_groups do
                          "- #{inspect(hand)} / #{inspect(calls)}"
                        end
                        IO.puts(Enum.join(report ++ [line1 | lines] ++ [""], "\n"))
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
                  IO.puts("")
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

  # check if hand contains all groups in each definition in match_definitions
  @decorate cacheable(cache: RiichiAdvanced.Cache, key: {:match_hand, hand, calls, match_definitions, TileBehavior.hash(tile_behavior)})
  def match_hand(hand, calls, match_definitions, tile_behavior) do
    # t = System.os_time(:millisecond)
    tile_behavior = filter_irrelevant_tile_aliases(tile_behavior, hand ++ Enum.flat_map(calls, &Utils.call_to_tiles/1))
    ret = Enum.any?(match_definitions, fn match_definition -> not Enum.empty?(remove_match_definition(hand, calls, match_definition, tile_behavior)) end)
    # elapsed_time = System.os_time(:millisecond) - t
    # if elapsed_time > 10 do
    #   IO.puts("match_hand: #{inspect(elapsed_time)} ms")
    # end
    ret
  end

  defp multiply_match_definitions(match_definitions, mult) do
    for match_definition <- match_definitions do
      for match_definition_elem <- match_definition do
        case match_definition_elem do
          [groups, num] -> [groups, if num < 0 do num else num * mult end]
          _             -> match_definition_elem
        end
      end
    end
  end

  def binary_search_count_matches(hand_calls, match_definitions, tile_behavior, l \\ -1, r \\ 1) do
    if l < r do
      m = if l == -1 do r else Integer.floor_div(l + r + 1, 2) end
      multiplied_match_def = multiply_match_definitions(match_definitions, m)
      if Enum.empty?(multiplied_match_def) do
        IO.inspect("Error: empty match definition given: #{inspect(match_definitions)}")
        0
      else
        matched = Enum.any?(hand_calls, fn {hand, calls} -> match_hand(hand, calls, multiplied_match_def, tile_behavior) end)
        {l, r} = if matched do
          if l == -1 do {l, r * 2} else {m, r} end
        else
          if l == -1 do {0, r} else {l, m - 1} end
        end
        binary_search_count_matches(hand_calls, match_definitions, tile_behavior, l, r)
      end
    else l end 
  end

  def apply_base_tile_to_offset(offset, base_tile, tile_behavior) do
    cond do
      is_offset(offset)     -> offset_tile(base_tile, offset, tile_behavior)
      Utils.is_tile(offset) -> Utils.to_tile(offset)
      true                  ->
        IO.puts("Unsupported offset #{inspect(offset)}")
        nil
    end
  end

  def apply_base_tile_to_group(group, base_tile, tile_behavior) do
    cond do
      is_offset(group) -> apply_base_tile_to_offset(group, base_tile, tile_behavior)
      is_list(group) -> Enum.map(group, &apply_base_tile_to_offset(&1, base_tile, tile_behavior))
      Utils.is_tile(group) -> Utils.to_tile(group)
      true -> group
    end
  end

  defp compute_almost_group(group) do
    cond do
      # group of tiles
      is_list(group) and not Enum.empty?(group) ->
        cond do
          # list of integers specifying a group of tiles
          Enum.any?(group, &is_offset/1) ->
            for {tile, i} <- Enum.with_index(group), tile not in @group_keywords do
              almost_group = List.delete_at(group, i)
              lowest = almost_group |> Enum.filter(&is_integer/1) |> Enum.min(&<=/2, fn -> 0 end)
              Enum.map(almost_group, &if is_integer_offset(&1) do combine_offsets(&1, -lowest) else &1 end)
            end
          # list of lists of integers specifying multiple related subgroups of tiles
          Enum.all?(group, &is_list(&1) or &1 in @group_keywords) and Enum.all?(group, & &1 in @group_keywords or Enum.all?(&1, fn item -> is_offset(item) end)) ->
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

  defp combine_groups(match_definition) do
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

  defp groups_subsumes?(groups1, groups2) do
    if ("unique" in groups1) != ("unique" in groups2) do
      false
    else
      nojoker_ix_1 = Enum.find_index(groups1, & &1 == "nojoker")
      nojoker_ix_2 = Enum.find_index(groups2, & &1 == "nojoker")
      {joker1, ["nojoker" | nojoker1]} = if nojoker_ix_1 != nil do Enum.split(groups1, nojoker_ix_1) else {groups1, ["nojoker"]} end
      {joker2, ["nojoker" | nojoker2]} = if nojoker_ix_2 != nil do Enum.split(groups2, nojoker_ix_2) else {groups2, ["nojoker"]} end
      Enum.empty?(joker2 -- joker1) and Enum.empty?(nojoker2 -- ((joker1 -- joker2) ++ nojoker1))
    end
  end

  # we're checking if match_definition1 matches equally or strictly more than match_definition2
  defp match_definition_subsumes?(match_definition1, match_definition2, keywords1 \\ [], keywords2 \\ [])
  defp match_definition_subsumes?(_match_definition1, [], keywords1, keywords2) do
    # IO.inspect({keywords1, keywords2}, label: "iteration")
    cond do
      "exhaustive" not in keywords1 and "exhaustive" in keywords2 -> false
      "debug" not in keywords1 and "debug" in keywords2 -> false
      true -> true
    end
  end
  defp match_definition_subsumes?([], _match_definition2, _keywords1, _keywords2), do: false
  defp match_definition_subsumes?([match_definition_elem1 | match_definition1], [match_definition_elem2 | match_definition2], keywords1, keywords2) do
    # IO.inspect({[match_definition_elem1 | match_definition1], [match_definition_elem2 | match_definition2]}, label: "iteration")
    case {match_definition_elem1, match_definition_elem2} do
      {_, r} when is_binary(r) -> match_definition_subsumes?([match_definition_elem1 | match_definition1], match_definition2, keywords1, [r | keywords2])
      {l, _} when is_binary(l) -> match_definition_subsumes?(match_definition1, [match_definition_elem2 | match_definition2], [l | keywords1], keywords2)
      {[groups1, num1], [groups2, num2]} ->
        if groups_subsumes?(groups1, groups2) do
          cond do
            num1 == num2 or (num1 >= num2 and "unique" in keywords2) -> match_definition_subsumes?(match_definition1, match_definition2, keywords1, keywords2)
            num1 >  num2 -> match_definition_subsumes?([[groups1, num1 - num2] | match_definition1], match_definition2, keywords1, keywords2)
            num1 <  num2 -> match_definition_subsumes?(match_definition1, [[groups2, num2 - num1] | match_definition2], keywords1, keywords2)
          end
        else false end
      _ -> false
    end
  end

  # not only does this deduplicate, but it also removes match definitions subsumed by another
  defp deduplicate_match_definitions(match_definitions) do
    for match_definition <- match_definitions, reduce: [] do
      acc -> if Enum.any?(acc, &match_definition_subsumes?(&1, match_definition)) do
        # IO.inspect(match_definition, label: "removed")
        acc
      else
        [match_definition | acc]
      end
    end |> Enum.reverse()
  end

  defp compute_almost_match_definition_at_index(match_definition, i, groups, num) do
    new_groups = groups
    |> Enum.flat_map(&compute_almost_group/1)
    |> Enum.reject(&Enum.empty?/1)
    |> Enum.uniq()
    cond do
      abs(num) <= 1 and "unique" in groups ->
        # group with unique keyword with num <= 1
        match_definition
        |> List.delete_at(i)
      abs(num) > 1 and "unique" in groups ->
        # group with unique keyword with num > 1
        match_definition
        |> List.replace_at(i, [groups, num - 1])
      abs(num) <= 1 and Enum.empty?(new_groups) ->
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
