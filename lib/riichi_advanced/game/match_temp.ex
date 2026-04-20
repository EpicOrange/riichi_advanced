defmodule RiichiAdvanced.Match.Temp do
  alias RiichiAdvanced.Match, as: Match
  alias RiichiAdvanced.GameState.TileBehavior, as: TileBehavior
  alias RiichiAdvanced.Utils, as: Utils
  import Bitwise

  defmodule TileSet do
    defstruct [
      hash: 1,       # product of primes
      attrs: [],     # list of {prime, attr bitset}
      encoding: %{}, # %{tile => corresponding prime}
      all_attrs: [], # list of attrs (strings), such that 0th attr = LSB of bitset
      name: "",      # for calls, this is the call name
    ]

    # solve n rooks, returning a list of column indices, one for each row
    def solve_n_rooks(masks, n_cols), do: _solve_n_rooks(Enum.with_index(masks), (1 <<< n_cols) - 1, length(masks), [])
    # masks = list of bitmasks corresponding to rows, where 1 means you can place a rook there
    # cols_left = bitmask, initially all 1s, corresponding to uncovered cols
    # gas = number of remaining masks
    # acc = list of row indices used
    def _solve_n_rooks(_masks, 0, _gas, acc), do: Enum.reverse(acc)
    def _solve_n_rooks(_masks, _cols_left, 0, acc), do: Enum.reverse(acc)
    def _solve_n_rooks(masks, cols_left, gas, acc) do
      # basic naive backtracking lol
      # isolate last set bit in cols_left (which is nonzero)
      col = cols_left &&& (-cols_left)
      # for every mask that covers this col, use it, and recurse to see if there is a soln
      for {mask, i} <- masks, (mask &&& col) != 0, i not in acc, reduce: nil do
        nil  -> _solve_n_rooks(masks, Bitwise.bxor(cols_left, col), gas - 1, [i | acc])
        soln -> soln
      end
    end

    def remove_indices(xs, is), do: _remove_indices(xs, Enum.sort(is), [], 0)
    def _remove_indices([], _is, acc, _i), do: Enum.reverse(acc)
    def _remove_indices(xs, [], acc, _i), do: Enum.reverse(acc, xs)
    def _remove_indices([_x | xs], [i | is], acc, i), do: _remove_indices(xs, is, acc, i + 1)
    def _remove_indices([x | xs], [i | is], acc, j), do: _remove_indices(xs, [i | is], [x | acc], j + 1)

    # check if arg1 is a subset of arg2
    def is_subset?(l, r), do: subtract(r, l) != nil

    # remove 2nd set from 1st set to get a resulting set, or nil if not removable
    def subtract(%{hash: hash2, attrs: attrs2} = hand, %{hash: hash1, attrs: attrs1}) do
      case rem(hash2, hash1) do
        0 ->
          # solve for every exact cover with ahand2 covering ahand1
          # compute masks where the ith bitmask has jth bit set iff attrs2[i] covers attrs1[j]}
          masks = for {p2, battrs2} <- attrs2 do
            for {{p1, battrs1}, j} <- Enum.with_index(attrs1), p1 == p2, (battrs1 &&& battrs2) == battrs1, reduce: 0 do
              acc -> acc ||| (1 <<< j)
            end
          end
          case solve_n_rooks(masks, length(attrs1)) do
            nil -> nil
            ret -> %{hand | hash: Integer.floor_div(hash2, hash1), attrs: remove_indices(attrs2, ret)}
          end
        _ -> nil
      end
    end

    # encode first argument A into a number, using second argument B as a dictionary
    # (first item of B = 1, second = 2, third = 4, etc)
    # assumes both inputs are sorted
    def encode_attrs(tile_attrs, all_attrs, acc \\ 0, inc \\ 1)
    def encode_attrs(_tile_attrs, [], acc, _inc), do: acc
    def encode_attrs([], _all_attrs, acc, _inc), do: acc
    def encode_attrs([l_attr | attrs], [r_attr | all_attrs], acc, inc) do
      cond do
        # match
        l_attr == r_attr -> encode_attrs(attrs, all_attrs, acc + inc, inc * 2)
        # no match
        l_attr < r_attr  -> encode_attrs(attrs, [r_attr | all_attrs], acc, inc)
        true             -> encode_attrs([l_attr | attrs], all_attrs, acc, inc * 2)
      end
    end

    # # unused
    # def _decode_attrs(encoded_attrs, all_attrs, acc \\ [])
    # def _decode_attrs(_encoded_attrs, [], acc), do: Enum.reverse(acc)
    # def _decode_attrs(0, _all_attrs, acc), do: Enum.reverse(acc)
    # def _decode_attrs(encoded_attrs, [attr | all_attrs], acc) when (encoded_attrs &&& 1) == 1 do
    #   _decode_attrs(encoded_attrs >>> 1, all_attrs, [attr | acc])
    # end
    # def _decode_attrs(encoded_attrs, [_attr | all_attrs], acc) do
    #   _decode_attrs(encoded_attrs >>> 1, all_attrs, acc)
    # end

    def encode(hand, encoding, all_attrs) do
      %TileSet{
        hash: Enum.reduce(hand, 1, fn tile, acc -> acc * Map.get(encoding, Utils.strip_attrs(tile), 1) end),
        attrs: for {tile, attrs} <- Enum.map(hand, &Utils.to_attr_tile/1) do
          attrs = Enum.map(attrs, &String.trim_leading(&1, "_"))
          {Map.get(encoding, tile, 1), encode_attrs(attrs, all_attrs)}
        end,
        encoding: encoding,
        all_attrs: all_attrs,
      }
    end

    def decode(%{attrs: attrs, encoding: encoding, all_attrs: all_attrs}) do
      for {p, attrs} <- attrs do
        {tile, _prime} = Enum.find(encoding, {nil, 1}, fn {_tile, prime} -> prime == p end)
        # bitset to attr
        {_, attrs} = for attr <- all_attrs, reduce: {attrs, []} do
          {0, acc}     -> {0, acc}
          {attrs, acc} ->
            case attrs &&& 1 do
              0 -> {attrs >>> 1, acc}
              1 -> {attrs >>> 1, [attr | acc]}
            end
        end
        {tile, attrs}
      end
    end

    # # old
    # @primes [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97,101]
    # def decode(hand, encoding, primes \\ @primes, acc \\ [])
    # def decode(%{hash: 1}, _encoding, _primes, acc), do: Enum.reverse(acc)
    # def decode(_hand, _encoding, [], acc), do: Enum.reverse(acc)
    # def decode(%{hash: hash}, encoding, [p | _] = primes, acc) when rem(hash, p) == 0 do
    #   {tile, _prime} = Enum.find(encoding, fn {_tile, prime} -> prime == p end)
    #   decode(Integer.floor_div(hash, p), encoding, primes, [tile | acc])
    # end
    # def decode(hand, encoding, [_p | primes], acc), do: decode(hand, encoding, primes, acc)

  end











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
      |> Enum.map(fn {tile, attrs} -> {tile, attrs |> Enum.map(&String.replace_prefix(&1, "_", "")) |> Enum.sort() |> TileSet.encode_attrs(all_attrs)} end)

      num_tiles = attr_tiles
      |> Enum.flat_map(&Utils.apply_tile_aliases(&1, tile_behavior) |> MapSet.to_list() |> TileBehavior.sort_by_joker_power(tile_behavior))
      |> Enum.map(fn {tile, attrs} -> {tile, attrs |> Enum.sort() |> TileSet.encode_attrs(all_attrs)} end)

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

  # def collect_base_tiles_v2(tiles, groups, tile_behavior) do
  #   tiles = Enum.uniq(tiles)
  #   for group <- groups do
  #     cond do
  #       is_list(group) ->
  #         {lowest, highest} = List.flatten(group)
  #         |> Enum.filter(&is_number/1)
  #         |> Enum.min_max(fn -> {0, 0} end)
  #         Enum.filter(tiles, fn tile ->
  #           Match.offset_tile(tile, lowest, tile_behavior) != nil and
  #           Match.offset_tile(tile, highest, tile_behavior) != nil
  #         end)
  #       Match.is_offset(group) -> Enum.filter(tiles, fn tile -> Match.offset_tile(tile, group, tile_behavior) != nil end)
  #       group == "any" -> tiles
  #       Utils.is_tile(group) -> []
  #       is_binary(group) -> []
  #       true ->
  #         IO.puts("Unknown group spec #{inspect(group)}")
  #         []
  #     end
  #   end
  #   |> Enum.concat()
  #   |> Enum.uniq()
  # end

  def elim_group([hand | calls], group) when is_binary(group) do
    # group is a call name, remove every corresponding call
    for {call, i} <- Enum.with_index(calls), call.name == group, do: [hand | List.delete_at(calls, i)]
  end
  def elim_group([hand | calls], group) do
    from_calls = for {call, i} <- Enum.with_index(calls), TileSet.is_subset?(group, call), do: [hand | List.delete_at(calls, i)]
    case TileSet.subtract(hand, group) do
      nil -> from_calls
      ret -> [[ret | calls] | from_calls]
    end
    # |> IO.inspect(label: inspect({TileSet.decode(hand), TileSet.decode(group)}))
  end
  def elim_group_once([hand | calls], group) when is_binary(group) do
    # group is a call name, remove one corresponding call
    case Enum.find_index(calls, & &1.name == group) do
      nil -> []
      i   -> [[hand | List.delete_at(calls, i)]]
    end
  end
  def elim_group_once([hand | calls], group) do
    case Enum.find_index(calls, &TileSet.is_subset?(group, &1)) do
      nil -> case TileSet.subtract(hand, group) do
        nil -> []
        ret -> [[ret | calls]]
      end
      i   -> [[hand | List.delete_at(calls, i)]]
    end
  end

  # first 26 primes, to be zipped with unique tiles in hand
  # 26, because the product of the first 26 primes fits in a 128-bit unsigned int
  @primes [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97,101]

  def apply_ordering(tile, ordering, attrs \\ []) do
    case tile do
      {tile, _attrs} -> if Enum.empty?(attrs) do {ordering[tile], attrs} else ordering[tile] end
      tile -> ordering[tile]
    end
  end
  def apply_offsets(base_tile, offsets, tile_behavior, n \\ 0, acc \\ [])
  def apply_offsets(_base_tile, [], _tile_behavior, _n, acc), do: Enum.reverse(acc)
  def apply_offsets(nil, _offsets, _tile_behavior, _n, _acc), do: nil
  def apply_offsets(base_tile, [o | offsets], tile_behavior, n, acc) when is_number(o) and n == o, do: apply_offsets(base_tile, offsets, tile_behavior, n, [base_tile | acc])
  def apply_offsets(base_tile, [o | offsets], tile_behavior, n, acc) when is_number(o) and n < o and o >= 0, do: apply_offsets(apply_ordering(base_tile, tile_behavior.ordering), [o | offsets], tile_behavior, n+1, acc)
  def apply_offsets(base_tile, [o | offsets], tile_behavior, n, acc) when is_number(o) and n > o and o <= 0, do: apply_offsets(apply_ordering(base_tile, tile_behavior.ordering_r), [o | offsets], tile_behavior, n-1, acc)
  def apply_offsets(base_tile, [o | offsets], tile_behavior, n, acc) when is_number(o), do: apply_offsets(base_tile, offsets, tile_behavior, n, acc)
  def apply_offsets(base_tile, [%{offset: o} | offsets], tile_behavior, n, acc) when is_number(o) and n == o, do: apply_offsets(base_tile, offsets, tile_behavior, n, [base_tile | acc])
  def apply_offsets(base_tile, [%{offset: o, attrs: attrs} | offsets], tile_behavior, n, acc) when is_number(o) and n < o and o >= 0, do: apply_offsets(apply_ordering(base_tile, tile_behavior.ordering, attrs), [o | offsets], tile_behavior, n+1, acc)
  def apply_offsets(base_tile, [%{offset: o, attrs: attrs} | offsets], tile_behavior, n, acc) when is_number(o) and n > o and o <= 0, do: apply_offsets(apply_ordering(base_tile, tile_behavior.ordering_r, attrs), [o | offsets], tile_behavior, n-1, acc)
  def apply_offsets(base_tile, [%{offset: o} | offsets], tile_behavior, n, acc) when is_number(o) and n < o and o >= 0, do: apply_offsets(apply_ordering(base_tile, tile_behavior.ordering), [o | offsets], tile_behavior, n+1, acc)
  def apply_offsets(base_tile, [%{offset: o} | offsets], tile_behavior, n, acc) when is_number(o) and n > o and o <= 0, do: apply_offsets(apply_ordering(base_tile, tile_behavior.ordering_r), [o | offsets], tile_behavior, n-1, acc)
  # for when offset is a tile (non-numeric)
  def apply_offsets(base_tile, [o | offsets], tile_behavior, n, acc), do: apply_offsets(base_tile, offsets, tile_behavior, n, [o | acc])

  def encode_group(group, all_tiles, encoding, all_attrs, tile_behavior) do
    cond do
      is_list(group) -> if is_list(Enum.at(group, 0)) do
        Enum.map(all_tiles, &Enum.map(group, fn subgroup -> apply_offsets(&1, subgroup, tile_behavior) end))
      else
        Enum.map(all_tiles, &apply_offsets(&1, group, tile_behavior))
      end
      Match.is_offset(group) -> Enum.map(all_tiles, &apply_offsets(&1, [group], tile_behavior))
      group == "any" -> Enum.map(all_tiles, &List.wrap(&1))
      Utils.is_tile(group) -> case Utils.to_tile(group) do
        {:any, attrs} -> for tile <- all_tiles, Utils.has_attr?(tile, attrs), do: [tile]
        tile          -> [[tile]]
      end
      is_binary(group) -> if group in Match.group_keywords() do nil else [group] end # could be a call name
      true ->
        IO.puts("Unknown group spec #{inspect(group)}")
        []
    end
    |> Enum.filter(& &1 != nil)
    |> Enum.uniq()
    |> Enum.map(&if is_binary(&1) do &1 else TileSet.encode(&1, encoding, all_attrs) end) # pass through call names
  end

  def match_hand_v2(hand, calls, match_definitions, tile_behavior) do
    # precondition: hand+calls is <= 26 tiles long
    # TODO can expand to each hand + call being <= 26 tiles long, just limit the number of unique tiles (primes) to like 100
    # first encode hand tiles and call tiles as primes, with most frequent as lower primes
    all_tiles = hand ++ Enum.flat_map(calls, &Utils.call_to_tiles/1)
    all_attrs = all_tiles
    |> Enum.flat_map(fn {_tile, attrs} -> Enum.map(attrs, &String.trim_leading(&1, "_")); _tile -> [] end)
    |> Enum.uniq()
    |> Enum.sort()
    # TODO make a faster path if all_attrs is empty

    all_tile_ids = all_tiles
    |> Utils.strip_attrs()
    |> Enum.uniq()
    |> Enum.sort()
    encoding = Enum.frequencies(all_tile_ids)
    |> Enum.sort_by(fn {_tile, freq} -> -freq end)
    |> Enum.zip(@primes)
    |> Map.new(fn {{tile, _freq}, prime} -> {tile, prime} end) 

    hands = [TileSet.encode(hand, encoding, all_attrs) | Enum.map(calls, fn {name, call} -> %{TileSet.encode(call, encoding, all_attrs) | name: name} end)]

    # try each match definition in turn
    Enum.any?(match_definitions, fn match_definition ->
      exhaustive_ix = Enum.find_index(match_definition, & &1 == "exhaustive")
      unique_ix = Enum.find_index(match_definition, & &1 == "unique")
      debug = "debug" in match_definition
      for {[match_elem, num], i} <- Enum.with_index(match_definition), reduce: [hands] do
        []  -> []
        acc ->
          exhaustive = exhaustive_ix != nil and i > exhaustive_ix
          unique = (unique_ix != nil and i > unique_ix) or "unique" in match_elem
          # use offsets in match definition to determine which tiles can be considered offset 0 (base tiles)
          # preprocess groups with all_tiles as base tiles
          groups = for group <- match_elem, group not in Match.group_keywords() do
            {encode_group(group, all_tiles, encoding, all_attrs, tile_behavior), group}
          end

          # then try to remove (num) groups
          new_acc = for j <- (if num == 0 do [1] else 1..abs(num) end), reduce: Enum.map(acc, fn hands -> {hands, groups} end) do
            [] -> []
            hands_groups ->
              report = if debug do
                line1 = "Acc (before removal #{j}/#{num}):"
                lines = for {[hand | calls], remaining_groups} <- hands_groups do
                  groups = Enum.map(remaining_groups, fn {_groups, orig_group} -> orig_group end)
                  "- #{inspect(Utils.sort_tiles(TileSet.decode(hand)))} / #{inspect(Enum.map(calls, &Utils.sort_tiles(TileSet.decode(&1))))} \\\\ #{inspect(groups, charlists: :as_lists)}#{if unique do " unique" else "" end}#{if exhaustive do " exhaustive" else "" end}"
                end
                [line1 | lines]
              else "" end

              hands_groups =
                for {hands, remaining_groups} <- hands_groups,
                    {{groups, _orig_group}, i} <- Enum.with_index(remaining_groups),
                    group <- groups,
                    hands <- (if exhaustive do elim_group(hands, group) else elim_group_once(hands, group) end) do
                  {hands, if unique do List.delete_at(remaining_groups, i) else remaining_groups end}
                end
                |> Enum.uniq_by(fn {hands, _remaining_groups} ->
                  Enum.map(hands, fn %{hash: hash, attrs: attrs} -> {hash, attrs} end)
                end)

              if debug do
                line1 = "Acc (after removal #{j}/#{num}):"
                lines = for {[hand | calls], _remaining_groups} <- hands_groups do
                  "- #{inspect(Utils.sort_tiles(TileSet.decode(hand)))} / #{inspect(Enum.map(calls, &Utils.sort_tiles(TileSet.decode(&1))))}"
                end
                IO.puts(Enum.join(report ++ [line1 | lines] ++ [""], "\n"))
              end
              hands_groups
          end
          |> Enum.map(fn {hands, _} -> hands end)
          |> Enum.uniq()

          cond do
            num == 0 -> # forward lookahead
              if Enum.empty?(new_acc) do
                []
              else
                if debug do IO.puts("Reverting due to last group being a successful forward lookahead (num=0): #{inspect(groups)}") end
                acc # revert
              end
            num < 0  -> # negative lookahead
              if Enum.empty?(new_acc) do
                if debug do IO.puts("Reverting due to last group being a successful negative lookahead (num=#{num}): #{inspect(groups)}") end
                acc # revert
              else
                [] # if we matched anything, no we didn't
              end
            true     ->
              if debug do
                IO.puts("Final result:")
                for {hand, calls} <- new_acc do
                  "- #{inspect(Utils.sort_tiles(TileSet.decode(hand)))} / #{inspect(Enum.map(calls, &Utils.sort_tiles(TileSet.decode(&1))))}"
                end
                IO.puts("")
              end
              new_acc
          end
      end
      |> Enum.empty?()
      |> Kernel.not()
    end)
  end


end
