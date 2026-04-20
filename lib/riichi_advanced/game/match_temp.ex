defmodule RiichiAdvanced.Match.Temp do
  alias RiichiAdvanced.Match, as: Match
  alias RiichiAdvanced.GameState.TileBehavior, as: TileBehavior
  alias RiichiAdvanced.Utils, as: Utils
  import Bitwise

  defmodule TileSet do
    defstruct [
      hash: 1,    # product of primes
      attrs: [],  # list of {prime, attr bitset}
                  # may also include {:name, call name}
                  # may also include jokers in the form of {:joker, list of possible {prime, attr bitset} which that joker can be}
                  # note that jokers are not included in hash
    ]
    # first 256 primes should be enough
    @primes [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97,101,103,107,109,113,127,131,137,139,149,151,157,163,167,173,179,181,191,193,197,199,211,223,227,229,233,239,241,251,257,263,269,271,277,281,283,293,307,311,313,317,331,337,347,349,353,359,367,373,379,383,389,397,401,409,419,421,431,433,439,443,449,457,461,463,467,479,487,491,499,503,509,521,523,541,547,557,563,569,571,577,587,593,599,601,607,613,617,619,631,641,643,647,653,659,661,673,677,683,691,701,709,719,727,733,739,743,751,757,761,769,773,787,797,809,811,821,823,827,829,839,853,857,859,863,877,881,883,887,907,911,919,929,937,941,947,953,967,971,977,983,991,997,1009,1013,1019,1021,1031,1033,1039,1049,1051,1061,1063,1069,1087,1091,1093,1097,1103,1109,1117,1123,1129,1151,1153,1163,1171,1181,1187,1193,1201,1213,1217,1223,1229,1231,1237,1249,1259,1277,1279,1283,1289,1291,1297,1301,1303,1307,1319,1321,1327,1361,1367,1373,1381,1399,1409,1423,1427,1429,1433,1439,1447,1451,1453,1459,1471,1481,1483,1487,1489,1493,1499,1511,1523,1531,1543,1549,1553,1559,1567,1571,1579,1583,1597,1601,1607,1609,1613,1619]
    def primes, do: @primes

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

    # uses attrs as a source of primes to check
    def prime_decompose(n, primes \\ @primes, acc \\ [])
    def prime_decompose(1, _primes, acc), do: acc
    def prime_decompose(n, [p | primes], acc) when rem(n, p) == 0, do: prime_decompose(Integer.floor_div(n, p), [p | primes], [p | acc])
    def prime_decompose(n, [_ | primes], acc), do: prime_decompose(n, primes, acc)

    # remove 2nd set from 1st set to get a resulting set, or nil if not removable
    def subtract(%{hash: hash2, attrs: attrs2} = hand,
                 %{hash: hash1, attrs: attrs1}) do
      if hash2 == 0 do raise("TileSet.subtract: somehow obtained a hash of zero in hand") end
      if hash1 == 0 do raise("TileSet.subtract: somehow obtained a hash of zero in group") end
      jokers = Enum.filter(attrs2, fn {p2, _} -> p2 === :joker end)
      gcd = Integer.gcd(hash2, hash1)
      # if there are no jokers or attrs, succeed early
      if Enum.empty?(jokers) and Enum.empty?(attrs2) and gcd == hash1 do
        %{hand | hash: Integer.floor_div(hash2, hash1)}
      else
        # if we don't have enough jokers in hand to match all unmatched tiles, fail early
        early_fail = gcd < hash1 and length(jokers) < length(Integer.floor_div(hash1, gcd) |> prime_decompose())
        if early_fail do
          nil
        else
          # solve exact cover for attributes, where ahand2 covers ahand1
          # first, compute bitmasks where the ith bitmask has jth bit set iff attrs2[i] covers attrs1[j]}
          masks = for {p2, battrs2} <- attrs2, p2 != :name do
            case p2 do
              :joker ->
                for {{p1, battrs1}, j} <- Enum.with_index(attrs1), Enum.any?(battrs2, fn {p2, battrs2} -> p1 == p2 and (battrs1 &&& battrs2) == battrs1 end), reduce: 0 do
                  acc -> acc ||| (1 <<< j)
                end
              _ ->
                for {{p1, battrs1}, j} <- Enum.with_index(attrs1), p1 == p2, (battrs1 &&& battrs2) == battrs1, reduce: 0 do
                  acc -> acc ||| (1 <<< j)
                end
            end
          end
          # then it's n-rooks on this bit matrix
          case solve_n_rooks(masks, length(attrs1)) do
            nil -> nil
            ret ->
              divisor = for i <- ret, reduce: gcd do
                acc -> case Enum.at(attrs2, i) do
                  {:joker, [{p, _} | _]} when rem(hash2, acc * p) == 0 -> acc * p
                  _ -> acc
                end
              end
              %{hand | hash: Integer.floor_div(hash2, divisor), attrs: remove_indices(attrs2, ret)}
          end
        end
      end
    end

    # encode first argument A into a number, using second argument B as a dictionary
    # (first item of B = 1, second = 2, third = 4, etc)
    # assumes both inputs are sorted
    def encode_attrs(tile_attrs, all_attrs), do: _encode_attrs(Enum.sort(tile_attrs), all_attrs, 0, 1)
    def _encode_attrs(_tile_attrs, [], acc, _inc), do: acc
    def _encode_attrs([], _all_attrs, acc, _inc), do: acc
    def _encode_attrs([l_attr | attrs], [r_attr | all_attrs], acc, inc) do
      cond do
        # match
        l_attr == r_attr -> _encode_attrs(attrs, all_attrs, acc + inc, inc * 2)
        # no match
        l_attr < r_attr  -> _encode_attrs(attrs, [r_attr | all_attrs], acc, inc)
        true             -> _encode_attrs([l_attr | attrs], all_attrs, acc, inc * 2)
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

    def encode(hand, encoding, [], %{}) when not is_map_key(encoding, :mappings) do
      %TileSet{
        hash: Enum.reduce(hand, 1, fn tile, acc -> acc * Map.get(encoding, Utils.strip_attrs(tile), 1) end),
        attrs: []
      }
    end
    def encode(hand, encoding, all_attrs) do
      %TileSet{
        hash: Enum.reduce(hand, 1, fn tile, acc -> acc * Map.get(encoding, Utils.strip_attrs(tile), 1) end),
        attrs: for orig_tile <- hand do
          {tile, attrs} = Utils.to_attr_tile(orig_tile)
          attrs = Enum.map(attrs, &String.trim_leading(&1, "_"))
          encoded = {Map.get(encoding, tile, 1), encode_attrs(attrs, all_attrs)}
          tile_mappings = Map.get(encoding, :mappings, %{})
          case Map.get(tile_mappings, tile) do
            nil -> encoded
            mappings ->
              aliases = for {tile2, attrs2} <- Enum.map(mappings, &Utils.to_attr_tile/1), Map.has_key?(encoding, tile2) do
                attrs = Enum.map(attrs2, &String.trim_leading(&1, "_"))
                {Map.get(encoding, tile2, 1), encode_attrs(attrs, all_attrs)}
              end
              if Enum.empty?(aliases) do
                encoded
              else
                {:joker, [encoded | aliases]}
              end
          end
        end
      }
    end

    def decode(hand, encoding, []), do: decode_primes(hand, encoding)
    def decode(%{attrs: attrs}, encoding, all_attrs) do
      for {p, attrs} <- attrs, p != :name do
        attrs = if p == :joker do Enum.at(attrs, 0) else attrs end
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
        if Enum.empty?(attrs) do tile else {tile, attrs} end
      end
    end

    def decode_primes(hand, encoding, primes \\ @primes, acc \\ [])
    def decode_primes(%{hash: 1}, _encoding, _primes, acc), do: Enum.reverse(acc)
    def decode_primes(_hand, _encoding, [], acc), do: Enum.reverse(acc)
    def decode_primes(%{hash: hash} = set, encoding, [p | _] = primes, acc) when rem(hash, p) == 0 do
      {tile, _prime} = Enum.find(encoding, fn {_tile, prime} -> prime == p end)
      decode_primes(%{set | hash: Integer.floor_div(hash, p)}, encoding, primes, [tile | acc])
    end
    def decode_primes(hand, encoding, [_p | primes], acc), do: decode_primes(hand, encoding, primes, acc)

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
      |> Enum.flat_map(&Utils.apply_tile_aliases(&1, tile_behavior) |> MapSet.to_list())
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
    for {call, i} <- Enum.with_index(calls), Keyword.get(call.attrs, :name) == group, do: [hand | List.delete_at(calls, i)]
  end
  def elim_group([hand | calls], group) do
    cond do
      is_list(group) ->
        for subgroup <- group, reduce: [[hand | calls]] do
          acc -> Enum.flat_map(acc, &elim_group(&1, subgroup))
        end
        # for subgroup <- group, reduce: [[hand | calls]] do
        #   acc ->
        #     IO.inspect(Enum.map(acc, fn x -> Enum.map(x, &TileSet.decode/1) end), label: inspect(TileSet.decode(subgroup)))
        #     Enum.flat_map(acc, &elim_group(&1, subgroup))
        # end |> IO.inspect(label: inspect(Enum.map(group, &TileSet.decode/1)))
      true ->
        from_calls = for {call, i} <- Enum.with_index(calls), TileSet.is_subset?(group, call), do: [hand | List.delete_at(calls, i)]
        case TileSet.subtract(hand, group) do
          nil -> from_calls
          ret -> [[ret | calls] | from_calls]
        end
    end
  end
  def elim_group_once([hand | calls], group) when is_binary(group) do
    # group is a call name, remove one corresponding call
    case Enum.find_index(calls, &Keyword.get(&1.attrs, :name) == group) do
      nil -> []
      i   -> [[hand | List.delete_at(calls, i)]]
    end
  end
  def elim_group_once([hand | calls], group) do
    cond do
      is_list(group) ->
        ret = for subgroup <- group, reduce: [hand | calls] do
          nil -> nil
          acc -> elim_group_once(acc, subgroup)
        end
        if ret == [] do [] else [ret] end
      true ->
        case Enum.find_index(calls, &TileSet.is_subset?(group, &1)) do
          nil -> case TileSet.subtract(hand, group) do
            nil -> []
            ret -> [[ret | calls]]
          end
          i   -> [[hand | List.delete_at(calls, i)]]
        end
    end
  end

  @shift_suit %{:"1m"=>:"1p", :"2m"=>:"2p", :"3m"=>:"3p", :"4m"=>:"4p", :"5m"=>:"5p", :"6m"=>:"6p", :"7m"=>:"7p", :"8m"=>:"8p", :"9m"=>:"9p", :"10m"=>:"10p",
                :"1p"=>:"1s", :"2p"=>:"2s", :"3p"=>:"3s", :"4p"=>:"4s", :"5p"=>:"5s", :"6p"=>:"6s", :"7p"=>:"7s", :"8p"=>:"8s", :"9p"=>:"9s", :"10p"=>:"10s",
                :"1s"=>:"1m", :"2s"=>:"2m", :"3s"=>:"3m", :"4s"=>:"4m", :"5s"=>:"5m", :"6s"=>:"6m", :"7s"=>:"7m", :"8s"=>:"8m", :"9s"=>:"9m", :"10s"=>:"10m",
                :"0z"=>nil, :"1z"=>nil, :"2z"=>nil, :"3z"=>nil, :"4z"=>nil, :"5z"=>nil, :"6z"=>nil, :"7z"=>nil, :"8z"=>nil}
  def apply_ordering(tile, ordering, attrs \\ []) do
    case tile do
      {tile, _attrs} -> if Enum.empty?(attrs) do ordering[tile] else {ordering[tile], attrs} end
      tile -> ordering[tile]
    end
  end
  # def apply_offsets(base_tile, offsets, tile_behavior, n \\ 0, acc \\ [], test \\ true)
  # def apply_offsets(base_tile, offsets, tile_behavior, n, acc, true) do
  #   IO.inspect(%{base_tile: base_tile, offsets: offsets, n: n, acc: acc})
  #   apply_offsets(base_tile, offsets, tile_behavior, n, acc, false)
  # end
  def apply_offsets(base_tile, offsets, tile_behavior), do: _apply_offsets(base_tile, offsets, tile_behavior, 0, [])
  def _apply_offsets(_base_tile, [], _tile_behavior, _n, acc), do: Enum.reverse(acc)
  def _apply_offsets(nil, _offsets, _tile_behavior, _n, _acc), do: nil
  # for when offset is a number
  def _apply_offsets(base_tile, [o | offsets], tile_behavior, n, acc) when is_number(o), do: _apply_offsets(base_tile, [%{"offset" => o} | offsets], tile_behavior, n, acc)
  # for when offset is a map (so it can specify attrs)
  def _apply_offsets(base_tile, [%{"offset" => o} | _] = os, tile_behavior, n, acc) when is_number(o) and n < o and o >= 10 and (o-n) >= 10, do: _apply_offsets(base_tile |> apply_ordering(@shift_suit), os, tile_behavior, n+10, acc)
  def _apply_offsets(base_tile, [%{"offset" => o} | _] = os, tile_behavior, n, acc) when is_number(o) and n > o and o <= -10 and (o-n) <= -10, do: _apply_offsets(base_tile |> apply_ordering(@shift_suit) |> apply_ordering(@shift_suit), os, tile_behavior, n-10, acc)
  def _apply_offsets(base_tile, [%{"offset" => o} | _] = os, tile_behavior, n, acc) when is_number(o) and n < o and o >= 0, do: _apply_offsets(base_tile |> apply_ordering(tile_behavior.ordering), os, tile_behavior, n+1, acc)
  def _apply_offsets(base_tile, [%{"offset" => o} | _] = os, tile_behavior, n, acc) when is_number(o) and n > o and o <= 0, do: _apply_offsets(base_tile |> apply_ordering(tile_behavior.ordering_r), os, tile_behavior, n-1, acc)
  # base cases
  def _apply_offsets(base_tile, [%{"offset" => o, "attrs" => attrs} | offsets], tile_behavior, n, acc) when is_number(o) and n == o, do: _apply_offsets(base_tile, offsets, tile_behavior, n, [base_tile |> Utils.strip_attrs() |> Utils.add_attr(attrs) | acc])
  def _apply_offsets(base_tile, [%{"offset" => o} | offsets], tile_behavior, n, acc) when is_number(o) and n == o, do: _apply_offsets(base_tile, offsets, tile_behavior, n, [base_tile |> Utils.strip_attrs() | acc])
  # for when offset is a tile (non-numeric)
  def _apply_offsets(base_tile, [o | offsets], tile_behavior, n, acc), do: _apply_offsets(base_tile, offsets, tile_behavior, n, [Utils.to_tile(o) | acc])

  def is_bad_group(nil, _encoding), do: true
  def is_bad_group({nil, _}, _encoding), do: true
  def is_bad_group(s, _encoding) when is_binary(s), do: false # it's a call name
  def is_bad_group(l, encoding) when is_list(l), do: Enum.any?(l, &is_bad_group(&1, encoding))
  def is_bad_group({t, _}, encoding), do: not Map.has_key?(encoding, t)
  def is_bad_group(t, encoding), do: not Map.has_key?(encoding, t)

  # reifies a group spec into multiple possible groups
  def encode_group(group, all_tiles, encoding, all_attrs, tile_behavior) do
    encoding = Map.delete(encoding, :mappings)
    nested = is_list(group) and is_list(Enum.at(group, 0))
    all_tiles = all_tiles ++ Enum.flat_map(all_tiles, fn tile -> Map.get(tile_behavior.mappings, tile, []) end)
    cond do
      nested -> Enum.map(all_tiles, &Enum.map(group, fn subgroup -> apply_offsets(&1, subgroup, tile_behavior) end) |> Enum.sort())
      is_list(group) -> Enum.map(all_tiles, &apply_offsets(&1, group, tile_behavior))
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
    |> Enum.reject(&is_bad_group(&1, encoding))
    # |> Enum.reject(fn x -> 
    #   ret = is_bad_group(x, encoding)
    #   if ret do IO.inspect({x, encoding}, label: "bad group #{inspect(group)}") end
    #   ret
    # end)
    |> Enum.uniq()
    |> Enum.map(&cond do
      is_binary(&1) -> &1 # pass through call names
      nested        -> [[Enum.map(&1, fn subgroup -> TileSet.encode(subgroup, encoding, all_attrs) end)]]
      true          -> TileSet.encode(&1, encoding, all_attrs)
    end)
  end

  # faster match algorithm for when we're checking against a set of tiles
  # basically makes kokushi faster to check
  def perform_unique_match(data) do
    %{
      encoding: encoding,
      all_attrs: all_attrs,
      acc: acc,
      match_elem: match_elem,
      num: num,
      exhaustive: exhaustive,
      unique: unique,
      debug: debug,
    } = data
    report = if debug do
      line1 = "Acc (before removing #{num} tile#{if num == 1 do "" else "s" end} #{inspect(match_elem, charlists: :as_lists)}):"
      lines = for [hand | calls] <- acc do
        "- #{inspect(Utils.sort_tiles(TileSet.decode(hand, encoding, all_attrs)))} / #{inspect(Enum.map(calls, &Utils.sort_tiles(TileSet.decode(&1, encoding, all_attrs))))} \\\\#{if unique do " unique" else "" end}#{if exhaustive do " exhaustive" else "" end}"
      end
      [line1 | lines]
    else "" end

    primes_attrs = match_elem
    |> Enum.map(&Enum.map(&1, fn tile -> Utils.to_tile(tile) end))
    |> Enum.filter(&Enum.all?(&1, fn tile -> Map.has_key?(encoding, tile) end))
    |> Enum.map(&TileSet.encode(&1, encoding, all_attrs))

    num_targets = length(primes_attrs)
    cond do
      num_targets < num ->
        if debug do
          line1 = "Acc (failed to find #{num} matching tile#{if num == 1 do "" else "s" end}):"
          IO.puts(Enum.join(report ++ [line1] ++ [""], "\n"))
        end
        []
      num_targets > num ->
        new_acc = for [%{hash: hand_prime} = hand | calls] <- acc do
          {new_hand_prime, count} = for %{hash: prime} <- primes_attrs, reduce: {hand_prime, 0} do
            {hand_prime, count} when count == num -> {hand_prime, count}
            {hand_prime, count} when rem(hand_prime, prime) == 0 -> {Integer.floor_div(hand_prime, prime), count + 1}
            {hand_prime, count} -> {hand_prime, count}
          end
          if count == num do [[%{hand | hash: new_hand_prime} | calls]] else [] end
        end
        |> Enum.concat()
        if debug do
          line1 = "Acc (after removing #{num} tile#{if num == 1 do "" else "s" end}):"
          lines = for [hand | calls] <- new_acc do
            "- #{inspect(Utils.sort_tiles(TileSet.decode(hand, encoding, all_attrs)))} / #{inspect(Enum.map(calls, &Utils.sort_tiles(TileSet.decode(&1, encoding, all_attrs))))}"
          end
          IO.puts(Enum.join(report ++ [line1 | lines] ++ [""], "\n"))
        end
        new_acc
      true -> # num_targets == num
        # we can just multiply all the primes together and remove from hand
        product = Enum.map(primes_attrs, & &1.hash) |> Enum.product()
        new_acc = for [%{hash: hand_prime} = hand | calls] <- acc, rem(hand_prime, product) == 0 do
          [%{hand | hash: Integer.floor_div(hand_prime, product)} | calls]
        end
        if debug do
          line1 = "Acc (after removing exactly #{num} tile#{if num == 1 do "" else "s" end}):"
          lines = for [hand | calls] <- new_acc do
            "- #{inspect(Utils.sort_tiles(TileSet.decode(hand, encoding, all_attrs)))} / #{inspect(Enum.map(calls, &Utils.sort_tiles(TileSet.decode(&1, encoding, all_attrs))))}"
          end
          IO.puts(Enum.join(report ++ [line1 | lines] ++ [""], "\n"))
        end
        new_acc
    end
  end

  def perform_standard_match(data) do
    %{
      tile_behavior: tile_behavior,
      encoding: encoding,
      all_tiles: all_tiles,
      all_attrs: all_attrs,
      acc: acc,
      match_elem: match_elem,
      num: num,
      exhaustive: exhaustive,
      unique: unique,
      nojoker: nojoker,
      debug: debug,
    } = data
    encoding = if nojoker do Map.delete(encoding, :mappings) else encoding end

    groups = for group <- match_elem, group not in Match.group_keywords() do
      # reifies a group spec into multiple possible groups
      {encode_group(group, all_tiles, encoding, all_attrs, tile_behavior), group}
    end

    for j <- (if num == 0 do [1] else 1..abs(num) end), reduce: Enum.map(acc, fn hands -> {hands, groups} end) do
      [] -> []
      hands_groups ->
        report = if debug do
          line1 = "Acc (before removal #{j}/#{num}):"
          lines = for {[hand | calls], remaining_groups} <- hands_groups do
            groups = Enum.map(remaining_groups, fn {_groups, orig_group} -> orig_group end)
            "- #{inspect(hand)} #{inspect(calls)}\n"
            <> "#{inspect(encoding)}\n"
            <> "- #{inspect(Utils.sort_tiles(TileSet.decode(hand, encoding, all_attrs)))} / #{inspect(Enum.map(calls, &Utils.sort_tiles(TileSet.decode(&1, encoding, all_attrs))))} \\\\ #{inspect(groups, charlists: :as_lists)}#{if unique do " unique" else "" end}#{if exhaustive do " exhaustive" else "" end}"
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

        hands_groups = if exhaustive do
          hands_groups
          |> Enum.uniq_by(fn {hands, _remaining_groups} ->
            Enum.map(hands, fn %{hash: hash, attrs: attrs} -> {hash, attrs} end)
          end)
        else Enum.take(hands_groups, 1) end

        if debug do
          line1 = "Acc (after removal #{j}/#{num}):"
          lines = for {[hand | calls], _remaining_groups} <- hands_groups do
            "- #{inspect(Utils.sort_tiles(TileSet.decode(hand, encoding, all_attrs)))} / #{inspect(Enum.map(calls, &Utils.sort_tiles(TileSet.decode(&1, encoding, all_attrs))))}"
          end
          IO.puts(Enum.join(report ++ [line1 | lines] ++ [""], "\n"))
        end

        hands_groups
    end
    |> Enum.map(fn {hands, _} -> hands end)
    |> Enum.uniq()
  end

  def create_encoding(all_tiles, mappings) do
    all_tile_ids = Utils.strip_attrs(all_tiles)
    all_joker_ids = for {tile, mappings} <- mappings, Utils.strip_attrs(tile) in all_tiles, mapping <- mappings, do: Utils.strip_attrs(mapping)
    all_tile_ids = all_tile_ids ++ all_joker_ids
    |> Enum.uniq()
    |> Enum.sort()
    encoding = Enum.frequencies(all_tile_ids)
    |> Enum.sort_by(fn {_tile, freq} -> -freq end)
    |> Enum.zip(TileSet.primes())
    |> Map.new(fn {{tile, _freq}, prime} -> {tile, prime} end)
    # add aliases to encoding
    if not Enum.empty?(mappings) do
      Map.put(encoding, :mappings, mappings)
    else encoding end
  end

  def match_hand_v2(hand, calls, match_definitions, tile_behavior) do
    # precondition: hand+calls is <= 26 tiles long
    # TODO can expand to each hand + call being <= 26 tiles long, just limit the number of unique tiles (primes) to like 100

    # first encode hand tiles and call tiles as primes, with most frequent as lower primes
    all_tiles = hand ++ Enum.flat_map(calls, &Utils.call_to_tiles/1)
    match_attrs = List.flatten(match_definitions) |> Enum.flat_map(fn %{"attrs" => attrs} -> attrs; _ -> [] end)
    all_attrs = if Enum.empty?(match_attrs) do
      []
    else
      hand_attrs = Enum.flat_map(all_tiles, fn {_tile, attrs} -> Enum.map(attrs, &String.trim_leading(&1, "_")); _tile -> [] end)
      Enum.uniq(hand_attrs ++ match_attrs)
      |> Enum.sort()
    end

    never_jokers = Enum.all?(match_definitions, fn match_definition -> "nojoker" in match_definition end)
    encoding = create_encoding(all_tiles, if never_jokers do %{} else tile_behavior.mappings end)

    hands = [TileSet.encode(hand, encoding, all_attrs) | Enum.map(calls, fn {name, call} ->
      ret = TileSet.encode(call, encoding, all_attrs)
      %{ret | attrs: [{:name, name} | ret.attrs]}
    end)]
    # try each match definition in turn
    Enum.any?(match_definitions, fn match_definition ->
      # early exit if we have more groups than tiles!
      # this is mostly to prevent 14 tile hands, like kokushi, from matching when we have 13 tiles
      debug = "debug" in match_definition
      min_match_length = Enum.reduce(match_definition, 0, fn
        [_match_elem, num], acc -> acc + num
        _, acc -> acc
      end)
      hand_length = length(all_tiles)
      if min_match_length > hand_length and "restart" not in match_definition do
        if debug do IO.puts("Since we only have #{hand_length} tiles, refusing to match length-#{min_match_length} match #{inspect(match_definition)}") end
        false
      else
        exhaustive_ix = Enum.find_index(match_definition, & &1 == "exhaustive")
        unique_ix = Enum.find_index(match_definition, & &1 == "unique")
        nojoker_ix = Enum.find_index(match_definition, & &1 == "nojoker")
        for {[match_elem, num], i} <- Enum.with_index(match_definition), reduce: [hands] do
          []  -> []
          acc ->
            data = %{
              tile_behavior: tile_behavior,
              encoding: encoding,
              all_tiles: all_tiles,
              all_attrs: all_attrs,
              acc: acc,
              match_elem: match_elem,
              num: num,
              exhaustive: exhaustive_ix != nil and i > exhaustive_ix,
              unique: (unique_ix != nil and i > unique_ix) or "unique" in match_elem,
              nojoker: (nojoker_ix != nil and i > nojoker_ix) or "nojoker" in match_elem,
              debug: debug,
            }
            new_acc = cond do
              Enum.empty?(all_attrs) and data.unique and not data.exhaustive and Enum.all?(match_elem, &Utils.is_tile(&1) or &1 in Match.group_keywords()) -> perform_unique_match(data)
              true -> perform_standard_match(data)
            end
            cond do
              num == 0 -> # forward lookahead
                if Enum.empty?(new_acc) do
                  []
                else
                  if debug do IO.puts("Reverting due to last group being a successful forward lookahead (num=0)") end
                  acc # revert
                end
              num < 0  -> # negative lookahead
                if Enum.empty?(new_acc) do
                  if debug do IO.puts("Reverting due to last group being a successful negative lookahead (num=#{num})") end
                  acc # revert
                else
                  [] # if we matched anything, no we didn't
                end
              true     ->
                if debug do
                  IO.puts("Final result:")
                  for {hand, calls} <- new_acc do
                    "- #{inspect(Utils.sort_tiles(TileSet.decode(hand, encoding, all_attrs)))} / #{inspect(Enum.map(calls, &Utils.sort_tiles(TileSet.decode(&1, encoding, all_attrs))))}"
                  end
                  IO.puts("")
                end
                new_acc
            end
        end
        |> Enum.empty?()
        |> Kernel.not()
      end
    end)
  end


end
