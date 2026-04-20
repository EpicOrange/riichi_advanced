defmodule RiichiAdvanced.Match.Temp do
  alias RiichiAdvanced.Match, as: Match
  alias RiichiAdvanced.GameState.TileBehavior, as: TileBehavior
  alias RiichiAdvanced.Utils, as: Utils
  import Bitwise
  use Nebulex.Caching

  defmodule TileSet do
    use Nebulex.Caching

    @type t :: %__MODULE__{
      hash: integer(),
      attrs: list({integer(), integer()} | {:name, binary()} | {:joker, list({integer(), integer()})}),
    }
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

    # solve n rooks, returning a list of column indices in ascending order
    # the idea is that each column is an element of the match group,
    # and we want to cover as many as needed (given by num_rooks)
    # each mask tells you which columns are covered by that tile in hand
    #   masks     = list of {bitmask, i} corresponding to row i, where 1 in the bitmask means you can place a rook there
    #   col_mask  = bitmask, initially all 1s, corresponding to uncovered cols
    #   num_rooks = number of remaining masks
    #   acc       = list of row indices used
    def solve_n_rooks(_masks, col_mask, num_rooks, acc \\ [])
    def solve_n_rooks(_masks, _col_mask, 0, acc), do: {:ok, Enum.reverse(acc)}
    def solve_n_rooks(_masks, 0, _num_rooks, _acc), do: nil
    def solve_n_rooks(masks, col_mask, num_rooks, acc) do
      # basic naive backtracking lol

      # isolate last set bit in cols_left (which is nonzero)
      col = col_mask &&& (-col_mask)

      # for every mask that covers this col, use it, and recurse to see if there is a soln
      masks
      |> Enum.filter(fn {mask, i} -> (mask &&& col_mask &&& col) != 0 and i not in acc end)
      |> Enum.reduce_while(nil, fn {_mask, i}, _ ->
        case solve_n_rooks(masks, Bitwise.bxor(col_mask, col), num_rooks - 1, [i | acc]) do
          nil         -> {:cont, nil}
          {:ok, soln} -> {:halt, {:ok, soln}}
        end
      end)
    end

    def remove_indices(xs, is), do: _remove_indices(xs, Enum.sort(is), [], 0)
    def _remove_indices([], _is, acc, _i), do: Enum.reverse(acc)
    def _remove_indices(xs, [], acc, _i), do: Enum.reverse(acc, xs)
    def _remove_indices([_x | xs], [i | is], acc, i), do: _remove_indices(xs, is, acc, i + 1)
    def _remove_indices([x | xs], [i | is], acc, j), do: _remove_indices(xs, [i | is], [x | acc], j + 1)

    # check if arg1 is a subset of arg2
    def is_subset?(l, r), do: subtract(r, l) != nil

    # uses optional 2nd arg as a source of primes to check
    def prime_decompose(n, primes \\ @primes, acc \\ [])
    def prime_decompose(1, _primes, acc), do: acc
    def prime_decompose(_n, [], acc), do: acc
    def prime_decompose(0, _primes, acc) do
      IO.puts("prime_decompose: somehow tried to get the prime decomposition of 0")
      IO.inspect(Process.info(self(), :current_stacktrace))
      acc
    end
    def prime_decompose(_n, [0 | _primes], acc) do
      IO.puts("prime_decompose: somehow tried to divide by 0")
      IO.inspect(Process.info(self(), :current_stacktrace))
      acc
    end
    def prime_decompose(n, [p | primes], acc) when rem(n, p) == 0, do: prime_decompose(Integer.floor_div(n, p), [p | primes], [p | acc])
    def prime_decompose(n, [_ | primes], acc), do: prime_decompose(n, primes, acc)

    def find_ixs_helper(attrs2, attrs1, goal_hash, reorder_jokers \\ false) do
      attrs2_indexed = if reorder_jokers do
        {joker, nonjoker} = attrs2
        |> Enum.with_index()
        |> Enum.split_with(fn {{p, _}, _} -> p == :joker end)
        nonjoker ++ joker
      else Enum.with_index(attrs2) end

      # compute bitmasks where the ith bitmask has jth bit set iff attrs2[i] covers attrs1[j]}
      masks = for {{p2, battrs2}, _i} <- attrs2_indexed do
        case p2 do
          :name -> 0
          :joker -> for {{p1, battrs1}, j} <- Enum.with_index(attrs1), Enum.any?(battrs2, fn {p2, battrs2} -> p1 == p2 and (battrs1 &&& battrs2) == battrs1 end), reduce: 0 do
            acc -> acc ||| (1 <<< j)
          end
          _ -> for {{p1, battrs1}, j} <- Enum.with_index(attrs1), p1 == p2, (battrs1 &&& battrs2) == battrs1, reduce: 0 do
            acc -> acc ||| (1 <<< j)
          end
        end
      end

      # then it's n-rooks on this bit matrix
      with {:ok, ixs} <- solve_n_rooks(Enum.with_index(masks), (1 <<< length(attrs1)) - 1, length(prime_decompose(goal_hash))) do
        # convert mask indices to the original hand indices
        {:ok, Enum.map(ixs, &Enum.at(attrs2_indexed, &1) |> elem(1))}
      end
    end
      
    # remove 2nd set from 1st set to get a resulting set, or nil if not removable
    @decorate cacheable(cache: RiichiAdvanced.Cache, key: {:tileset_subtract, hash1, hash2, attrs1, attrs2, return_indices})
    def subtract(%{hash: hash2, attrs: attrs2} = hand,
                 %{hash: hash1, attrs: attrs1} = group, return_indices \\ false) do
      if hash2 == 0 do raise("TileSet.subtract: somehow obtained a hash of zero in hand") end
      if hash1 == 0 do raise("TileSet.subtract: somehow obtained a hash of zero in group") end
      jokers = Enum.filter(attrs2, fn {p2, _} -> p2 === :joker end)
      gcd = Integer.gcd(hash2, hash1)
      cond do
        # if there are no jokers or attrs, succeed early
        gcd == hash1 && Enum.empty?(jokers) and Enum.empty?(attrs2) -> %{hand | hash: Integer.floor_div(hash2, hash1)}
        true ->
          # otherwise, just solve for attrs in one pass
          with {:ok, ixs} <- find_ixs_helper(attrs2, attrs1, hash1, not Enum.empty?(jokers)) do
            # IO.inspect({attrs2, attrs1, hash1, not Enum.empty?(jokers), ixs})
            cond do
              return_indices -> ixs
              gcd == hash1 -> %{hand | hash: Integer.floor_div(hash2, hash1), attrs: remove_indices(attrs2, ixs)}
              true ->
                # if gcd < hash1 then we use jokers
                # then we need to divide hash by each joker's prime, not the goal prime
                divisor = for i <- ixs, reduce: 1 do
                  acc -> case Enum.at(attrs2, i) do
                    {:joker, [{p, _} | _]} -> acc * p
                    {p, _} when is_number(p) -> acc * p
                    _ -> acc
                  end
                end
                if rem(hash2, divisor) != 0 do
                  raise "tried to divide #{hash2} by #{divisor}, hand was #{inspect(hand)}, group was #{inspect(group)}"
                end
                %{hand | hash: Integer.floor_div(hash2, divisor), attrs: remove_indices(attrs2, ixs)}
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
          case Enum.find(tile_mappings, fn {key, _} -> Utils.same_tile(orig_tile, key) end) do
            nil -> encoded
            {_, mappings} ->
              aliases = for {tile2, attrs2} <- Enum.map(mappings, &Utils.to_attr_tile/1), tile2 == :any or Map.has_key?(encoding, tile2) do
                attrs = Enum.map(attrs2, &String.trim_leading(&1, "_"))
                |> encode_attrs(all_attrs)
                if tile2 == :any do
                  for prime <- Map.values(encoding), is_number(prime), do: {prime, attrs}
                else
                  prime = Map.get(encoding, tile2, 1)
                  [{prime, attrs}]
                end
              end
              |> Enum.concat()
              if Enum.empty?(aliases) do
                encoded
              else
                {:joker, [encoded | aliases]}
              end
          end
        end
        # # put all jokers at the end
        # # note; this messes up subtract, which returns the unsorted indices
        # |> Enum.split_with(fn {tag, _} -> tag == :joker end)
        # |> then(fn {jokers, nonjokers} -> nonjokers ++ jokers end)
      }
    end

    # use hash to decode
    def decode(hand, encoding, []), do: decode_primes(hand, encoding)
    # use attrs to decode
    def decode(%{attrs: attrs}, encoding, all_attrs) do
      for {p, attrs} <- attrs, p != :name do
        {p, attrs} = if p == :joker do Enum.at(attrs, 0) else {p, attrs} end
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

  def try_remove_all_tiles(hand, tiles, tile_behavior \\ %TileBehavior{}) do
    if length(hand) < length(tiles) do [] else # otherwise we'd be trying to remove more tiles than we have altogether
      # first collect all attrs across all tiles we care about
      all_tiles = hand ++ tiles
      all_attrs = all_tiles
      |> Enum.map(&Utils.to_attr_tile/1)
      |> Enum.flat_map(fn {_tile, attrs} -> attrs end)
      |> Enum.uniq()
      |> Enum.sort() # sorting is required for TileSet.encode_attrs

      # encode every tile into a TileSet
      encoding = create_encoding(all_tiles, tile_behavior.mappings)
      hand_set = TileSet.encode(hand, encoding, all_attrs)
      tiles_set = TileSet.encode(tiles, encoding, all_attrs)

      case TileSet.subtract(hand_set, tiles_set, true) do
        nil -> []
        is  -> [TileSet.remove_indices(hand, is)]
      end
    end
  end

  def elim_group([hand | calls], group) when is_binary(group) do
    # group is a call name, remove every corresponding call
    for {call, i} <- Enum.with_index(calls), Keyword.get(call.attrs, :name) == group, do: [hand | List.delete_at(calls, i)]
  end
  def elim_group([hand | calls], group) do
    cond do
      is_list(group) ->
        for subgroup <- group, reduce: [[hand | calls]] do
          acc when is_list(subgroup) ->
            # subgroup contains multiple parts that can be removed independently
            for part <- subgroup, reduce: acc do
              nil -> nil
              acc -> Enum.flat_map(acc, &elim_group(&1, part))
            end
          acc -> Enum.flat_map(acc, &elim_group(&1, subgroup))
        end

        # for subgroup <- group, reduce: [[hand | calls]] do
        #   acc ->
        #     IO.inspect(Enum.map(acc, fn x -> Enum.map(x, &TileSet.decode/1) end), label: inspect(TileSet.decode(subgroup)))
        #     Enum.flat_map(acc, &elim_group(&1, subgroup))
        # end |> IO.inspect(label: inspect(Enum.map(group, &TileSet.decode/1)))
      true ->
        from_calls = for {call, i} <- Enum.with_index(calls), TileSet.is_subset?(group, call), do: [hand | List.delete_at(calls, i)]
        # if length(group.attrs) == 3 do IO.puts("#{inspect(hand)}\n- #{inspect(group)}\n= #{inspect(TileSet.subtract(hand, group))}") end

        case TileSet.subtract(hand, group) do
          nil -> from_calls
          ret ->
            # IO.inspect({hand.attrs, "-", group.attrs, "=", ret.attrs}, label: "Subtracting", limit: :infinity)
            # IO.inspect({length(hand.attrs), "-", length(group.attrs), "=", length(ret.attrs)}, label: "Subtracting")
            [[ret | calls] | from_calls]
        end
    end
  end
  def elim_group_once(hands, group) do
    case _elim_group_once(hands, group) do
      nil -> []
      ret -> [ret]
    end
  end
  def _elim_group_once(_hands, []) do
    IO.inspect("Tried to remove an empty group []")
    nil
  end
  def _elim_group_once([hand | calls], group) when is_binary(group) do
    # group is a call name, remove one corresponding call
    case Enum.find_index(calls, &Keyword.get(&1.attrs, :name) == group) do
      nil -> nil
      i   -> [hand | List.delete_at(calls, i)]
    end
  end
  def _elim_group_once([hand | calls], group) when is_list(group) do
    for subgroup <- group, reduce: [hand | calls] do
      nil -> nil
      acc ->
        if is_list(subgroup) and is_list(Enum.at(subgroup, 0)) do
          # subgroup contains multiple parts that can be removed independently
          for part <- subgroup, reduce: acc do
            nil -> nil
            acc -> _elim_group_once(acc, part)
          end
        else
          _elim_group_once(acc, subgroup)
        end
    end
  end
  def _elim_group_once([hand | calls], group) do
    case Enum.find_index(calls, &TileSet.is_subset?(group, &1)) do
      nil -> case TileSet.subtract(hand, group) do
        nil -> nil
        ret -> [ret | calls]
      end
      i   -> [hand | List.delete_at(calls, i)]
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
  def apply_offsets(base_tile, offsets, tile_behavior) do
    # handle any-tile offsets first
    {any_offsets, offsets} = Enum.split_with(offsets, &is_map(&1) and &1["offset"] == "any")
    acc = for %{"attrs" => attrs} <- any_offsets, Utils.has_attr?(base_tile, attrs), do: base_tile
    _apply_offsets(base_tile, offsets, tile_behavior, 0, acc)
  end
  def _apply_offsets(_base_tile, [], _tile_behavior, _n, []), do: nil
  def _apply_offsets(_base_tile, [], _tile_behavior, _n, acc), do: Enum.reverse(acc)
  def _apply_offsets(nil, _offsets, _tile_behavior, _n, _acc), do: nil
  # when offset is a number, convert it into a map
  def _apply_offsets(base_tile, [o | offsets], tile_behavior, n, acc) when is_number(o), do: _apply_offsets(base_tile, [%{"offset" => o} | offsets], tile_behavior, n, acc)
  # standard case: when offset is a map (so it can specify attrs)
  def _apply_offsets(base_tile, [%{"offset" => o} | _] = os, tile_behavior, n, acc) when is_number(o) and n < o and o >= 10 and (o-n) >= 10, do: _apply_offsets(base_tile |> apply_ordering(@shift_suit), os, tile_behavior, n+10, acc)
  def _apply_offsets(base_tile, [%{"offset" => o} | _] = os, tile_behavior, n, acc) when is_number(o) and n > o and o <= -10 and (o-n) <= -10, do: _apply_offsets(base_tile |> apply_ordering(@shift_suit) |> apply_ordering(@shift_suit), os, tile_behavior, n-10, acc)
  def _apply_offsets(base_tile, [%{"offset" => o} | _] = os, tile_behavior, n, acc) when is_number(o) and n < o and o >= 0, do: _apply_offsets(base_tile |> apply_ordering(tile_behavior.ordering), os, tile_behavior, n+1, acc)
  def _apply_offsets(base_tile, [%{"offset" => o} | _] = os, tile_behavior, n, acc) when is_number(o) and n > o and o <= 0, do: _apply_offsets(base_tile |> apply_ordering(tile_behavior.ordering_r), os, tile_behavior, n-1, acc)
  # base cases
  def _apply_offsets(base_tile, [%{"offset" => o, "attrs" => attrs} | offsets], tile_behavior, n, acc) when is_number(o) and n == o, do: _apply_offsets(base_tile, offsets, tile_behavior, n, [base_tile |> Utils.strip_attrs() |> Utils.add_attr(attrs) | acc])
  def _apply_offsets(base_tile, [%{"offset" => o} | offsets], tile_behavior, n, acc) when is_number(o) and n == o, do: _apply_offsets(base_tile, offsets, tile_behavior, n, [base_tile |> Utils.strip_attrs() | acc])
  # for when offset is a tile (non-numeric)
  def _apply_offsets(base_tile, [%{"offset" => o, "attrs" => attrs} | offsets], tile_behavior, n, acc), do: _apply_offsets(base_tile, offsets, tile_behavior, n, [Utils.to_tile(o) |> Utils.add_attr(attrs)| acc])
  def _apply_offsets(base_tile, [%{"offset" => o} | offsets], tile_behavior, n, acc), do: _apply_offsets(base_tile, offsets, tile_behavior, n, [Utils.to_tile(o) | acc])
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
    all_wall_tiles = Map.keys(tile_behavior.tile_freqs)
    # TODO the following doesn't depend on group, should precalculate this
    all_tiles = Enum.flat_map(all_tiles, fn tile ->
      case Enum.find(tile_behavior.mappings, fn {key, _} -> Utils.same_tile(tile, key) end) do
        nil           -> [tile]
        {_, mappings} ->
          tiles = Enum.flat_map(mappings, fn
            # :any tiles are replaced with every tile in game (plus attributes)
            # TODO there has got to be a more efficient way to do this replacement
            :any          -> all_wall_tiles
            {:any, attrs} -> Enum.map(all_wall_tiles, &Utils.add_attr(&1, attrs))
            tile          -> [tile]
          end)
          [tile | tiles]
      end
    end)
    |> Enum.uniq()

    nested = is_list(group) and is_list(Enum.at(group, 0))
    cond do
      nested -> Enum.map(all_tiles, &Enum.map(group, fn
        subgroup -> apply_offsets(&1, subgroup, tile_behavior)
      end))
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

  # faster match algorithm for when we're checking against an exact set of tiles
  # basically makes kokushi faster to check, also daisangen etc
  @spec perform_unique_match(data: map()) :: list(list(TileSet.t()))
  def perform_unique_match(data) do
    %{
      encoding: encoding,
      all_attrs: all_attrs,
      acc: acc,
      groups: groups,
      num: num,
      exhaustive: exhaustive,
      unique: unique,
      debug: debug,
    } = data
    report = if debug do
      line1 = "Acc (before removing #{num} group#{if num == 1 do "" else "s" end} #{inspect(groups, charlists: :as_lists)}):"
      lines = for [hand | calls] <- acc do
        "- (#{TileSet.prime_decompose(hand.hash) |> length()}) #{inspect(Utils.sort_tiles(TileSet.decode(hand, encoding, all_attrs)))} / #{inspect(Enum.map(calls, &Utils.sort_tiles(TileSet.decode(&1, encoding, all_attrs))))} \\\\#{if unique do " unique" else "" end}#{if exhaustive do " exhaustive" else "" end}"
      end
      [line1 | lines]
    else "" end

    primes_attrs = groups
    |> Enum.map(fn
      group when is_list(group) -> Enum.map(group, &Utils.to_tile/1)
      group -> Utils.to_tile(group)
    end)
    |> Enum.filter(fn
      group when is_list(group) -> Enum.all?(group, &Map.has_key?(encoding, &1))
      group -> Map.has_key?(encoding, group)
    end)
    |> Enum.map(&TileSet.encode(List.wrap(&1), encoding, all_attrs))

    num_targets = length(primes_attrs)
    cond do
      num_targets < num ->
        if debug do
          line1 = "Acc (failed to find #{num} matching group#{if num == 1 do "" else "s" end}):"
          IO.puts(Enum.join(report ++ [line1] ++ [""], "\n"))
        end
        []
      num_targets >= num ->
        new_acc = for hands <- acc do
          # try to remove exactly num of the given groups (in primes_attrs) from hand/calls
          {new_hands, remaining, _} = for group <- primes_attrs, reduce: {hands, num, length(primes_attrs)} do
            {hands, remaining, groups_left} when remaining == 0 -> {hands, remaining, groups_left} # skip
            {hands, remaining, groups_left} when groups_left < remaining -> {hands, remaining, groups_left - 1} # give up
            {[hand | calls], remaining, groups_left} ->
              # we need to use TileSet.subtract in order to handle jokers
              # try removing from calls first
              # IO.inspect([hand | calls], label: "hands")
              # IO.inspect(group, label: "group")
              case Enum.find_index(calls, &TileSet.is_subset?(group, &1)) do
                nil ->
                  # remove from hand instead
                  case TileSet.subtract(hand, group) do
                    nil -> {[hand | calls], remaining, groups_left - 1}    # didn't match
                    ret -> {[ret | calls], remaining - 1, groups_left - 1} # matched and updated
                  end
                ix ->
                  # remove this call and we're done
                  {[hand | List.delete_at(calls, ix)], remaining - 1, groups_left - 1}
              end
              # |> IO.inspect(label: "result")
          end
          if remaining == 0 do [new_hands] else [] end
        end
        |> Enum.concat()
        if debug do
          line1 = "Acc (after removing #{num} group#{if num == 1 do "" else "s" end}):"
          lines = for [hand | calls] <- new_acc do
            "- (#{TileSet.prime_decompose(hand.hash) |> length()}) #{inspect(Utils.sort_tiles(TileSet.decode(hand, encoding, all_attrs)))} / #{inspect(Enum.map(calls, &Utils.sort_tiles(TileSet.decode(&1, encoding, all_attrs))))}"
          end
          IO.puts(Enum.join(report ++ [line1 | lines] ++ [""], "\n"))
        end
        new_acc
    end
  end

  @spec perform_standard_match(data: map()) :: list(list(TileSet.t()))
  def perform_standard_match(data) do
    %{
      tile_behavior: tile_behavior,
      encoding: encoding,
      all_tiles: all_tiles,
      all_attrs: all_attrs,
      acc: acc,
      groups: groups,
      num: num,
      exhaustive: exhaustive,
      unique: unique,
      nojoker: nojoker,
      debug: debug,
    } = data
    encoding = if nojoker do Map.delete(encoding, :mappings) else encoding end

    groups = for group <- groups, group not in Match.group_keywords() do
      # reifies a group spec into multiple possible groups
      reified_groups = encode_group(group, all_tiles, encoding, all_attrs, tile_behavior)
      # IO.inspect(reified_groups |> Enum.map(&TileSet.decode(&1, encoding, all_attrs)), label: inspect(group), limit: :infinity)
      {reified_groups, group}
    end
    for j <- (if num == 0 do [1] else 1..abs(num) end), reduce: Enum.map(acc, fn hands -> {hands, groups} end) do
      [] -> []
      hands_groups ->
        report = if debug do
          line1 = "Acc (before removal #{j}/#{num}):"
          mappings = Map.get(encoding, :mappings, %{})
          line1 = if j == 1 and not Enum.empty?(mappings) do "Joker mapping: #{inspect(mappings)}\n" <> line1 else line1 end
          lines = for {[hand | calls], remaining_groups} <- hands_groups do
            groups = Enum.map(remaining_groups, fn {_groups, orig_group} -> orig_group end)
            "- (#{TileSet.prime_decompose(hand.hash) |> length()}) #{inspect(hand)} #{inspect(Utils.sort_tiles(TileSet.decode(hand, encoding, all_attrs)))} / #{inspect(Enum.map(calls, &Utils.sort_tiles(TileSet.decode(&1, encoding, all_attrs))))} \\\\ #{inspect(groups, charlists: :as_lists)}#{if unique do " unique" else "" end}#{if exhaustive do " exhaustive" else "" end}"
          end
          [line1 | lines]
        else "" end

        hands_groups =
          for {hands, remaining_groups} <- hands_groups,
              {{groups, _orig_group}, i} <- Enum.with_index(remaining_groups),
              group <- groups,
              new_hands <- (if exhaustive do elim_group(hands, group) else elim_group_once(hands, group) end) do
            {new_hands, if unique do List.delete_at(remaining_groups, i) else remaining_groups end}
          end

        hands_groups = if exhaustive do Enum.uniq(hands_groups) else Enum.take(hands_groups, 1) end

        if debug do
          line1 = "Acc (after removal #{j}/#{num}):"
          lines = for {[hand | calls], _remaining_groups} <- hands_groups do
            "- (#{TileSet.prime_decompose(hand.hash) |> length()}) #{inspect(hand)} #{inspect(Utils.sort_tiles(TileSet.decode(hand, encoding, all_attrs)))} / #{inspect(Enum.map(calls, &Utils.sort_tiles(TileSet.decode(&1, encoding, all_attrs))))}"
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
    all_joker_ids = for {tile, mappings} <- mappings, Utils.strip_attrs(tile) in all_tile_ids, mapping <- mappings, do: Utils.strip_attrs(mapping)
    all_tile_ids = all_tile_ids ++ all_joker_ids
    |> Enum.uniq()
    encoding = Enum.frequencies(all_tile_ids)
    |> Enum.sort_by(fn {_tile, freq} -> -freq end)
    |> Enum.zip(TileSet.primes())
    |> Map.new(fn {{tile, _freq}, prime} -> {tile, prime} end)
    # add mappings as encoding.mappings
    if not Enum.empty?(mappings) do
      Map.put(encoding, :mappings, mappings)
    else encoding end
  end

  def match_hand_v2(hand, calls, match_definitions, tile_behavior) do
    # first encode hand tiles and call tiles as primes, with most frequent as lower primes
    # if there are :any jokers, though, add every tile in the wall
    any_tile_jokers_exist = Enum.any?(hand, fn tile ->
      case Enum.find(tile_behavior.mappings, fn {key, _} -> Utils.same_tile(tile, key) end) do
        nil -> false
        {_, mappings} -> Enum.any?(mappings, fn 
          :any      -> true
          {:any, _} -> true
          _         -> false
        end)
      end
    end)
    hand_tiles = hand ++ Enum.flat_map(calls, &Utils.call_to_tiles/1)
    maximum_tile_count = length(hand_tiles)
    all_tiles = hand_tiles ++ if any_tile_jokers_exist do Map.keys(tile_behavior.tile_freqs) else [] end

    # retrieve relevant attributes from match
    match_attrs = List.flatten(match_definitions) |> Enum.flat_map(fn %{"attrs" => attrs} -> attrs; _ -> [] end)
    # if there's no attributes or jokers, then we don't care about attributes in hand either
    never_jokers = Enum.all?(match_definitions, fn match_definition -> "nojoker" in match_definition end)
    all_attrs = if Enum.empty?(match_attrs) and never_jokers do
      []
    else
      hand_attrs = Enum.flat_map(all_tiles, fn {_tile, attrs} -> Enum.map(attrs, &String.trim_leading(&1, "_")); _tile -> [] end)
      Enum.uniq(hand_attrs ++ match_attrs)
    end
    |> Enum.sort() # sorting is required for TileSet.encode_attrs
    # |> IO.inspect(label: "all_attrs", char_lists: :as_lists, limit: :infinity)

    encoding = create_encoding(all_tiles, if never_jokers do %{} else tile_behavior.mappings end)
    # |> IO.inspect(label: "encoding", char_lists: :as_lists, limit: :infinity)

    initial_hands = [TileSet.encode(hand, encoding, all_attrs) | Enum.map(calls, fn {name, call} ->
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
      if min_match_length > maximum_tile_count and "restart" not in match_definition and "almost" not in match_definition do
        if debug do IO.puts("Since we only have #{maximum_tile_count} tiles, refusing to match length-#{min_match_length} match #{inspect(match_definition)}") end
        false
      else
        exhaustive_ix = Enum.find_index(match_definition, & &1 == "exhaustive")
        unique_ix = Enum.find_index(match_definition, & &1 == "unique")
        # ignore_suit_ix = Enum.find_index(match_definition, & &1 == "ignore_suit") # unused rn!
        nojoker_ix = Enum.find_index(match_definition, & &1 == "nojoker")
        for {match_elem, i} <- Enum.with_index(match_definition), reduce: [initial_hands] do
          []  -> []
          _acc when match_elem == "restart" -> [initial_hands]
          acc when match_elem == "dismantle_calls" ->
            for hands <- acc do
              [Enum.reduce(hands, fn call, acc ->
                %{acc | hash: acc.hash * call.hash, attrs: Enum.reject(call.attrs, fn {p, _} -> p == :name end) ++ acc.attrs}
              end)]
            end
          acc when is_binary(match_elem) -> acc
          acc ->
            [groups, num] = match_elem
            data = %{
              tile_behavior: tile_behavior,
              encoding: encoding,
              all_tiles: all_tiles,
              all_attrs: all_attrs,
              acc: acc,
              groups: groups,
              num: num,
              exhaustive: exhaustive_ix != nil and i > exhaustive_ix,
              unique: (unique_ix != nil and i > unique_ix) or "unique" in groups,
              nojoker: (nojoker_ix != nil and i > nojoker_ix) or "nojoker" in groups,
              debug: debug,
            }
            new_acc = cond do
              Enum.empty?(match_attrs) and data.unique and not data.exhaustive and Enum.all?(groups, &Utils.is_tile(&1) or &1 in Match.group_keywords()) -> perform_unique_match(data)
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
                  if not Enum.empty?(new_acc) do
                    IO.puts("Final result:")
                    for [hand | calls] <- new_acc do
                      IO.puts("- #{inspect(Utils.sort_tiles(TileSet.decode(hand, encoding, all_attrs)))} / #{inspect(Enum.map(calls, &Utils.sort_tiles(TileSet.decode(&1, encoding, all_attrs))))}")
                    end
                  else
                    IO.puts("Final result: (empty)")
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




  @decorate cacheable(cache: RiichiAdvanced.Cache, key: {:get_waits_v2, hand, calls, match_definitions, TileBehavior.hash(tile_behavior)})
  def get_waits_v2(hand, calls, match_definitions, tile_behavior) do
    # basic strategy is to add a custom joker 1x
    # it will start as "all tiles" and progressively split its aliases in half,
    # until it encompasses "all tiles that don't work"
    # then we just take the complement
    all_tiles = Map.keys(tile_behavior.tile_freqs)
    all_tiles -- _get_waits_v2(hand, calls, match_definitions, tile_behavior, all_tiles)
  end
  def _get_waits_v2(_hand, _calls, _match_definitions, _tile_behavior, []), do: []
  def _get_waits_v2(hand, calls, match_definitions, tile_behavior, [x]) do
    if match_hand_v2([x | hand], calls, match_definitions, tile_behavior) do
      []
    else
      [x]
    end
  end
  def _get_waits_v2(hand, calls, match_definitions, tile_behavior, assignables) do
    tile_behavior_temp = TileBehavior.set_tile_alias(tile_behavior, [:"1x"], assignables)
    if match_hand_v2([:"1x" | hand], calls, match_definitions, tile_behavior_temp) do
      # bisect
      {left, right} = Enum.split(assignables, Integer.floor_div(length(assignables), 2))
      left2 = _get_waits_v2(hand, calls, match_definitions, tile_behavior, left)
      right2 = _get_waits_v2(hand, calls, match_definitions, tile_behavior, right)
      left2 ++ right2
    else assignables end
  end

  @decorate cacheable(cache: RiichiAdvanced.Cache, key: {:get_waits_and_ukeire_v2, hand, calls, match_definitions, visible_tiles, TileBehavior.hash(tile_behavior)})
  def get_waits_and_ukeire_v2(hand, calls, match_definitions, visible_tiles, tile_behavior) do
    waits = get_waits_v2(hand, calls, match_definitions, tile_behavior)
    freqs = Utils.inverse_frequencies(visible_tiles, tile_behavior)
    Map.new(waits, &{&1, Map.get(freqs, &1, 0)})
  end


end
