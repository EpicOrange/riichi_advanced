defmodule RiichiAdvanced.Match.Temp do
  alias RiichiAdvanced.Match, as: Match
  alias RiichiAdvanced.GameState.TileBehavior, as: TileBehavior
  alias RiichiAdvanced.Utils, as: Utils
  import Bitwise

  # encode first argument A into a number, using second argument B as a dictionary
  # (first item of B = 1, second = 2, third = 4, etc)
  # assumes both inputs are sorted
  def _encode_attrs(tile_attrs, all_attrs, acc \\ 0, inc \\ 1)
  def _encode_attrs(_tile_attrs, [], acc, _inc), do: acc
  def _encode_attrs([], _all_attrs, acc, _inc), do: acc
  def _encode_attrs([attr | attrs], [attr | all_attrs], acc, inc) do
    _encode_attrs(attrs, all_attrs, acc + inc, inc * 2)
  end
  def _encode_attrs([l_attr | attrs], [r_attr | _] = all_attrs, acc, inc) when l_attr < r_attr do
    _encode_attrs(attrs, all_attrs, acc, inc)
  end
  def _encode_attrs([_l_attr | _] = attrs, [_r_attr | all_attrs], acc, inc) do
    _encode_attrs(attrs, all_attrs, acc, inc * 2)
  end

  # def _decode_attrs(encoded_attrs, all_attrs, acc \\ [])
  # def _decode_attrs(_encoded_attrs, [], acc), do: Enum.reverse(acc)
  # def _decode_attrs(0, _all_attrs, acc), do: Enum.reverse(acc)
  # def _decode_attrs(encoded_attrs, [attr | all_attrs], acc) when (encoded_attrs &&& 1) == 1 do
  #   _decode_attrs(encoded_attrs >>> 1, all_attrs, [attr | acc])
  # end
  # def _decode_attrs(encoded_attrs, [_attr | all_attrs], acc) do
  #   _decode_attrs(encoded_attrs >>> 1, all_attrs, acc)
  # end

  # tile1 must have at least the attributes of tile2
  def same_tile({t1, attrs1}, {t2, attrs2}) do
    same_id = t1 == t2 or t1 == :any or t2 == :any
           or (t2 == :faceup and t1 not in [:"1x", :"2x", :"3x", :"4x"])
    same_id && (attrs1 &&& attrs2) >= attrs2
  end

  def same_number({t1, attrs1}, {t2, attrs2}) do
    same_tile({Utils.to_manzu(t1), attrs1}, {Utils.to_manzu(t2), attrs2})
  end

  # we want to try not to remove :any if possible (important for american hands)
  # the return value is acc, it tries not to remove :any
  # acc2 is the case where we do remove :any for the first time
  # return immediately if we remove a non-:any tile
  # otherwise if we reach [] we return acc2 (i.e. we removed :any)
  defp _remove_tile(num_hand, check, acc \\ [], acc2 \\ nil, index \\ 0)
  defp _remove_tile([], _check, _acc, nil, _index), do: nil # we didn't remove anything, give up
  defp _remove_tile([], _check, _acc, {acc, rest, index}, _index), do: {Enum.reverse(acc, rest), index}
  defp _remove_tile([t | rest], check, acc, acc2, index) do
    do_remove = check.(t)
    cond do
      do_remove and t != {:any, 0} -> {Enum.reverse(acc, rest), index}
      do_remove and acc2 == nil    -> _remove_tile(rest, check, [t | acc], {acc, rest, index}, index + 1)
      true                         -> _remove_tile(rest, check, [t | acc], acc2, index + 1)
    end
  end
  defp remove_tile(num_hand, tile, ignore_suit) do
    _remove_tile(num_hand, if ignore_suit do &same_number(&1, tile) else &same_tile(&1, tile) end)
  end

  # gets all variations of indices you need to delete (in sequence)
  # if you want to remove `num_tiles` from `num_hand`
  # e.g. [[5,5,5]] means delete index 5 three times
  defp get_indices_of_tiles_in_hand(num_hand, num_tiles, ignore_suit) do
    for tile <- num_tiles, reduce: [{num_hand, []}] do
      []               -> []
      num_hands_ixs ->
        for {num_hand, ixs} <- num_hands_ixs do
          case remove_tile(num_hand, tile, ignore_suit) do
            nil       -> []
            {ret, ix} -> [{ret, [ix | ixs]}]
          end
        end |> Enum.concat()
    end |> Enum.map(fn {_num_hand, ixs} -> Enum.reverse(ixs) end)
  end

  def try_remove_all_tiles(hand, tiles, tile_behavior \\ %TileBehavior{}) do
    if length(hand) >= length(tiles) do
      # first collect all attrs across all tiles we care about
      attr_tiles = tiles
      |> Enum.map(&Utils.to_attr_tile/1)
      |> Enum.map(fn {tile, attrs} -> {tile, Enum.reject(attrs, &String.starts_with?(&1, "_"))} end)
      all_attrs = attr_tiles
      |> Enum.flat_map(fn {_tile, attrs} -> attrs end)
      |> Enum.uniq()
      |> Enum.sort()

      # then normalize each tile to {tile_id, tile_attrs}
      # and encode each tile_attrs as a bitset indexing into all_attrs

      num_hand = hand
      |> Enum.map(&Utils.to_attr_tile/1)
      |> Enum.map(fn {tile, attrs} -> {tile, attrs |> Enum.map(&String.replace_prefix(&1, "_", "")) |> Enum.sort() |> _encode_attrs(all_attrs)} end)

      num_tiles = attr_tiles
      |> Enum.flat_map(&Utils.apply_tile_aliases(&1, tile_behavior) |> MapSet.to_list() |> TileBehavior.sort_by_joker_power(tile_behavior))
      |> Enum.map(fn {tile, attrs} -> {tile, attrs |> Enum.sort() |> _encode_attrs(all_attrs)} end)

      # insta-reject if there is any attr in all_attrs not represented in hand
      expected_sum = (2 ** length(all_attrs)) - 1 # could be zero, in which case no need to check
      sum_hand_attrs = if expected_sum == 0 do 0 else Enum.reduce(num_hand, 0, fn {_tile, attr_bits}, acc -> acc ||| attr_bits end) end
      if expected_sum == sum_hand_attrs do
        # now produce the output by removing each index in turn
        for ixs <- get_indices_of_tiles_in_hand(num_hand, num_tiles, tile_behavior.ignore_suit) do
          for ix <- ixs, reduce: hand do
            hand -> List.delete_at(hand, ix)
          end
        end
        # |> IO.inspect(label: "#{inspect(hand)} (#{inspect(num_hand)}) -- #{inspect(tiles)} (#{inspect(num_tiles)}) =")
      else [] end # otherwise we're asking for more attributes than we have altogether
    else [] end # otherwise we'd be trying to remove more tiles than we have altogether
  end

  def collect_base_tiles_v2(tiles, groups, tile_behavior) do
    tiles = Enum.uniq(tiles)
    for group <- groups do
      cond do
        is_list(group) ->
          {lowest, highest} = List.flatten(group)
          |> Enum.filter(&is_number/1)
          |> Enum.min_max(fn -> {0, 0} end)
          Enum.filter(tiles, fn tile ->
            Match.offset_tile(tile, lowest, tile_behavior) != nil and
            Match.offset_tile(tile, highest, tile_behavior) != nil
          end)
        Match.is_offset(group) -> Enum.filter(tiles, fn tile -> Match.offset_tile(tile, group, tile_behavior) != nil end)
        group == "any" -> tiles
        Utils.is_tile(group) -> []
        is_binary(group) -> []
        true ->
          IO.puts("Unknown group spec #{inspect(group)}")
          []
      end
    end
    |> Enum.concat()
    |> Enum.uniq()
  end

  def elim_group([phand | pcalls], pgroup) do
    from_calls = for {pcall, i} <- Enum.with_index(pcalls), rem(pcall, pgroup) == 0, do: [phand | List.delete_at(pcalls, i)]
    case rem(phand, pgroup) do
      0 -> [[Integer.floor_div(phand, pgroup) | pcalls] | from_calls]
      _ -> from_calls
    end
  end
  def elim_group_once([phand | pcalls], pgroup) do
    case Enum.find_index(pcalls, &rem(&1, pgroup) == 0) do
      nil -> case rem(phand, pgroup) do
        0 -> [[Integer.floor_div(phand, pgroup) | pcalls]]
        _ -> []
      end
      i   -> [[phand | List.delete_at(pcalls, i)]]
    end
  end

  # first 26 primes, to be zipped with unique tiles in hand
  # 26, because the product of the first 26 primes fits in a 128-bit unsigned int
  @primes [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97,101]

  def encode(hand, encoding) do
    Enum.reduce(hand, 1, fn tile, acc -> acc * Map.get(encoding, tile, 1) end)
  end
  def decode(phand, encoding, primes \\ @primes, acc \\ [])
  def decode(1, _encoding, _primes, acc), do: Enum.reverse(acc)
  def decode(_phand, _encoding, [], acc), do: Enum.reverse(acc)
  def decode(phand, encoding, [p | _] = primes, acc) when rem(phand, p) == 0 do
    {tile, _prime} = Enum.find(encoding, fn {_tile, prime} -> prime == p end)
    decode(Integer.floor_div(phand, p), encoding, primes, [tile | acc])
  end
  def decode(phand, encoding, [_p | primes], acc), do: decode(phand, encoding, primes, acc)

  def apply_offsets(base_tile, offsets, tile_behavior, n \\ 0, acc \\ [])
  def apply_offsets(_base_tile, [], _tile_behavior, _n, acc), do: Enum.reverse(acc)
  def apply_offsets(nil, _offsets, _tile_behavior, _n, _acc), do: nil
  def apply_offsets(base_tile, [o | offsets], tile_behavior, n, acc) when is_number(o) and n == o, do: apply_offsets(base_tile, offsets, tile_behavior, n, [base_tile | acc])
  def apply_offsets(base_tile, [o | offsets], tile_behavior, n, acc) when is_number(o) and n < o, do: apply_offsets(tile_behavior.ordering[base_tile], [o | offsets], tile_behavior, n+1, acc)
  def apply_offsets(base_tile, [o | offsets], tile_behavior, n, acc) when is_number(o), do: apply_offsets(base_tile, offsets, tile_behavior, n, acc)
  def apply_offsets(base_tile, [o | offsets], tile_behavior, n, acc), do: apply_offsets(base_tile, offsets, tile_behavior, n, [o | acc])

  # TODO e.g. {:"1m", ["_foo"]} should be removable by {:"1m", ["attr1"]}, {:"1m", ["attr2"]}, {:"1m", ["attr1", "attr2"]}
  # this shouldn't generate the cartesian product of all possible tiles, what to do?
  #   wait, what if tiles with attrs = composite of tile and attr?
  #   so :"1m" = 3, "attr1" = 5, {:"1m", ["attr1"]} = 15
  # oh, but then attr could belong to any tile
  #   wait we solved this already
  #   make each tile a pair {tileprime, attrprime}
  # but then you can't multiply them all together...
  # rn we have e.g. :"1m" = 3, {:"1m", ["attr1"]} = 5
  # is there a way to say "when you wanna remove 3x, also try removing 5x since that also matches?
  #   we could store 5/3, when we wanna remove a group x, try removing 5x/3, 25x/9, etc
  # if we do that our primes method might be slower than lists
  #   that's true, we kinda wanna minimize the number of pgroups we can divide by
  #   actually, it's rare to have many versions of the same tile. the list of 5/3, 25/9, etc should be small
  #   since they come from tiles actually in hand
  #   let's try this?
  # right, we'll just encode attrs as a bitmask and check the lattice using each tile with the same id
  #   
  # so what encode_group actually should do, is give a list of factors like [[3,5,7],[3,5,7],[3,5,7]]
  # the idea being that removing the group is to pick one factor from each sublist
  # other way to say it is, take the cartesian product, that's the pgroup
  # problem: if every tile in hand has an attribute, we can't remove the base tile
  # solution: we separate the problems.
  # - we use the prime multiset to see if we can remove the group at all assuming base tiles
  # - we use an actual tile list to check attributes
  # this seems slower
  # 

  def encode_group(group, all_tiles, encoding, tile_behavior) do
    cond do
      is_list(group) -> Enum.map(all_tiles, &apply_offsets(&1, group, tile_behavior))
      Match.is_offset(group) -> Enum.map(all_tiles, &apply_offsets(&1, [group], tile_behavior))
      group == "any" -> Enum.map(all_tiles, &List.wrap(&1))
      Utils.is_tile(group) -> [group]
      is_binary(group) -> if group in Match.group_keywords() do nil else [group] end # could be a call name
      true ->
        IO.puts("Unknown group spec #{inspect(group)}")
        []
    end
    |> Enum.filter(& &1 != nil)
    |> Enum.uniq()
    |> Enum.map(&encode(&1, encoding))
    # |> IO.inspect(label: inspect({base_tiles, group}))
  end

  def match_hand_v2(hand, calls, match_definitions, tile_behavior) do
    # precondition: hand+calls is <= 26 tiles long
    # TODO can expand to each hand + call being <= 26 tiles long, just limit the number of unique tiles (primes) to like 100
    # first encode hand tiles and call tiles as primes, with most frequent as lower primes
    all_tiles = hand ++ Enum.flat_map(calls, &Utils.call_to_tiles/1)
    encoding = Enum.frequencies(all_tiles)
    |> Enum.sort_by(fn {_tile, freq} -> -freq end)
    |> Enum.zip(@primes)
    |> Map.new(fn {{tile, _freq}, prime} -> {tile, prime} end) 
    phands = [encode(hand, encoding) | Enum.map(calls, fn {_name, call} -> encode(call, encoding) end)]

    # try each match definition in turn
    Enum.any?(match_definitions, fn match_definition ->
      exhaustive_ix = Enum.find_index(match_definition, & &1 == "exhaustive")
      unique_ix = Enum.find_index(match_definition, & &1 == "unique")
      debug = "debug" in match_definition
      for {[groups, num], i} <- Enum.with_index(match_definition), reduce: [phands] do
        []  -> []
        acc ->
          exhaustive = exhaustive_ix != nil and i > exhaustive_ix
          unique = (unique_ix != nil and i > unique_ix) or "unique" in groups
          # use offsets in match definition to determine which tiles can be considered offset 0 (base tiles)
          # base_tiles = collect_base_tiles_v2(all_tiles, groups, tile_behavior)
          # preprocess groups with base tiles
          pgroups = for group <- groups, group not in Match.group_keywords() do
            {encode_group(group, all_tiles, encoding, tile_behavior), group}
          end
          # then try to remove (num) groups
          for j <- (if num == 0 do [1] else 1..abs(num) end), reduce: Enum.map(acc, fn phands -> {phands, pgroups} end) do
            [] -> []
            phands_pgroups ->
              report = if debug do
                line1 = "Acc (before removal #{j}/#{num}): (base tiles #{inspect(base_tiles)})"
                lines = for {[phand | pcalls], remaining_pgroups} <- phands_pgroups do
                  groups = Enum.map(remaining_pgroups, fn {_pgroups, orig_group} -> orig_group end)
                  "- #{inspect(Utils.sort_tiles(decode(phand, encoding)))} / #{inspect(Enum.map(pcalls, &Utils.sort_tiles(decode(&1, encoding))))} \\\\ #{inspect(groups, charlists: :as_lists)}#{if unique do " unique" else "" end}#{if exhaustive do " exhaustive" else "" end}"
                end
                [line1 | lines]
              else "" end
              phands_pgroups =
                for {phands, remaining_pgroups} <- phands_pgroups,
                    {{pgroups, _orig_group}, i} <- Enum.with_index(remaining_pgroups),
                    pgroup <- pgroups,
                    phands <- (if exhaustive do elim_group(phands, pgroup) else elim_group_once(phands, pgroup) end),
                    uniq: true do
                  {phands, if unique do List.delete_at(remaining_pgroups, i) else remaining_pgroups end}
                end
              if debug do
                line1 = "Acc (after removal #{j}/#{num}):"
                lines = for {[phand | pcalls], _remaining_groups} <- phands_pgroups do
                  "- #{inspect(Utils.sort_tiles(decode(phand, encoding)))} / #{inspect(Enum.map(pcalls, &Utils.sort_tiles(decode(&1, encoding))))}"
                end
                IO.puts(Enum.join(report ++ [line1 | lines] ++ [""], "\n"))
              end
              phands_pgroups
          end
          |> Enum.map(fn {phands, _} -> phands end)
          |> Enum.uniq()
      end
      |> Enum.empty?()
      |> Kernel.not()
    end)
  end


end
