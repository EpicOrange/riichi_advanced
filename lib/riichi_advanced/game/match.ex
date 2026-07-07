defmodule RiichiAdvanced.Match do
  alias RiichiAdvanced.Constants, as: Constants
  alias RiichiAdvanced.GameState.TileBehavior, as: TileBehavior
  alias RiichiAdvanced.MatchOld, as: MatchOld
  alias RiichiAdvanced.Riichi, as: Riichi
  alias RiichiAdvanced.Utils, as: Utils
  import Bitwise
  use Nebulex.Caching

  @have_cargo System.find_executable("cargo")
  def have_cargo, do: @have_cargo
  if @have_cargo do
    use Rustler, otp_app: :riichi_advanced, crate: "riichiadvanced_match"
  end

  defmodule TileSet do
    @type t :: %__MODULE__{
      hash: integer(),
      attrs: list({integer(), integer()}),
      name: binary() | nil,
      nojoker: boolean(),
    }
    defstruct [
      hash: 1,    # product of primes in attrs
      attrs: [],  # list of {prime, attr bitset}
      name: nil,
      nojoker: false,
    ]
  end

  @any_prime Constants.to_prime(:any)
  # @primes [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97,101,103,107,109,113,127,131,137,139,149,151,157,163,167,173,179,181,191,193,197,199,211,223,227,229,233,239,241,251,257,263,269,271,277,281,283,293,307,311,313,317,331,337,347,349,353,359,367,373,379,383,389,397,401,409,419,421,431,433,439,443,449,457,461,463,467,479,487,491,499,503,509,521,523,541,547,557,563,569,571,577,587,593,599,601,607,613,617,619,631,641,643,647,653,659,661,673,677,683,691,701,709,719,727,733,739,743,751,757,761,769,773,787,797,809,811,821,823,827,829,839,853,857,859,863,877,881,883,887,907,911,919,929,937,941,947,953,967,971,977,983,991,997,1009,1013,1019,1021,1031,1033,1039,1049,1051,1061,1063,1069,1087,1091,1093,1097,1103,1109,1117,1123,1129,1151,1153,1163,1171,1181,1187,1193,1201,1213,1217,1223,1229,1231,1237,1249,1259,1277,1279,1283,1289,1291,1297,1301,1303,1307,1319,1321,1327,1361,1367,1373,1381,1399,1409,1423,1427,1429,1433,1439,1447,1451,1453,1459,1471,1481,1483,1487,1489,1493,1499,1511,1523,1531,1543,1549,1553,1559,1567,1571,1579,1583,1597,1601,1607,1609,1613,1619,1621,1627,1637,1657,1663,1667,1669,1693,1697,1699,1709,1721,1723,1733,1741,1747,1753,1759,1777,1783,1787,1789,1801,1811,1823,1831,1847,1861,1867,1871,1873,1877,1879,1889,1901,1907,1913,1931,1933,1949,1951,1973,1979,1987,1993,1997,1999,2003,2011,2017,2027,2029,2039,2053,2063,2069,2081,2083,2087,2089,2099,2111,2113,2129,2131,2137,2141,2143,2153,2161,2179,2203,2207,2213,2221,2237,2239,2243,2251,2267,2269,2273,2281,2287,2293,2297,2309,2311,2333,2339,2341,2347,2351,2357,2371,2377,2381,2383,2389,2393,2399,2411,2417,2423,2437,2441,2447,2459,2467,2473,2477,2503,2521,2531,2539,2543,2549,2551,2557,2579,2591,2593,2609,2617,2621,2633,2647,2657,2659,2663]

  # solve n rooks, returning a list of column indices in ascending order
  # the idea is that each column is an element of the match group,
  # and we want to cover as many as needed (given by num_rooks)
  # each mask tells you which columns are covered by that tile in hand
  #   masks     = list of {bitmask, i}, ith bitmask corresponding to row i, where 1 in the bitmask means you can place a rook there
  #   col_mask  = bitmask, initially all 1s, corresponding to uncovered cols
  #   num_rooks = number of remaining masks
  #   acc       = list of row indices used
  def solve_n_rooks(masks, col_mask, num_rooks) do
    _solve_n_rooks(masks, col_mask, num_rooks, [])
  end
  def _solve_n_rooks(_masks, _col_mask, 0, acc), do: {:ok, Enum.reverse(acc)}
  def _solve_n_rooks(_masks, 0, _num_rooks, _acc), do: nil
  def _solve_n_rooks(masks, col_mask, num_rooks, acc) do
    # basic naive backtracking lol

    # isolate last set bit in cols_left (which is nonzero)
    col = col_mask &&& (-col_mask)

    # remove masks that have been chosen already
    masks = Enum.reject(masks, fn {_mask, i} -> i in acc end)

    # for every mask that covers this col, use it, and recurse to see if there is a soln
    ret = masks
    |> Enum.filter(fn {mask, _i} -> (mask &&& col_mask &&& col) != 0 end)
    |> Enum.reduce_while([], fn {_mask, i}, ret ->
      case _solve_n_rooks(masks, Bitwise.bxor(col_mask, col), num_rooks - 1, [i | acc]) do
        nil         -> {:cont, ret}
        {:ok, soln} -> {:halt, soln}
      end
    end)
    {:ok, ret}
  end

  def solve_n_rooks_exhaustive(masks, col_mask, num_rooks) do
    _solve_n_rooks_exhaustive(masks, col_mask, num_rooks, [])
  end
  def _solve_n_rooks_exhaustive(_masks, _col_mask, 0, acc), do: {:ok, [Enum.reverse(acc)]}
  def _solve_n_rooks_exhaustive(_masks, 0, _num_rooks, _acc), do: nil
  def _solve_n_rooks_exhaustive(masks, col_mask, num_rooks, acc) do
    # basic naive backtracking lol

    # isolate last set bit in cols_left (which is nonzero)
    col = col_mask &&& (-col_mask)

    # remove masks that have been chosen already
    masks = Enum.reject(masks, fn {_mask, i} -> i in acc end)

    # for every mask that covers this col, use it, and recurse to see if there is a soln
    ret = masks
    |> Enum.filter(fn {mask, _i} -> (mask &&& col_mask &&& col) != 0 end)
    |> Enum.reduce_while([], fn {_mask, i}, ret ->
      case _solve_n_rooks_exhaustive(masks, Bitwise.bxor(col_mask, col), num_rooks - 1, [i | acc]) do
        nil         -> {:cont, ret}
        {:ok, soln} -> {:cont, soln ++ ret}
      end
    end)
    {:ok, ret}
  end

  def remove_indices(xs, is) when length(xs) == length(is), do: []
  def remove_indices(xs, is), do: _remove_indices(xs, Enum.sort(is), [], 0)
  defp _remove_indices([], _is, acc, _i), do: Enum.reverse(acc)
  defp _remove_indices(xs, [], acc, _i), do: Enum.reverse(acc, xs)
  defp _remove_indices([_x | xs], [i | is], acc, i), do: _remove_indices(xs, is, acc, i + 1)
  defp _remove_indices([x | xs], is, acc, j), do: _remove_indices(xs, is, [x | acc], j + 1)

  # check if arg1 is a subset of arg2
  def is_subset?(l, r, tile_behavior) do
    case subtract(r, l, tile_behavior.encoded_aliases, tile_behavior.encoded_joker_tiles |> Enum.to_list()) do
      nil -> false
      _ -> true
    end
  end

  def count_factors(n, primes) do
    if n > 340282366920938463463374607431768211455 do
      _count_factors(n, primes, 0)
    else
      count_factors_fast(n, primes)
    end
  end
  def count_factors_fast(n, primes) do
    # fall back to _count_factors
    _count_factors(n, primes, 0)
  end

  def _count_factors(n, primes, acc)
  def _count_factors(1, _primes, acc), do: acc
  def _count_factors(0, _primes, acc) do
    IO.puts("factor: somehow tried to get the prime decomposition of 0")
    IO.inspect(Process.info(self(), :current_stacktrace))
    acc
  end
  def _count_factors(_n, [], acc), do: acc + 1
  def _count_factors(_n, [0 | _primes], acc) do
    IO.puts("factor: somehow tried to divide by 0")
    IO.inspect(Process.info(self(), :current_stacktrace))
    acc
  end
  def _count_factors(n, [p | primes], acc) when rem(n, p) == 0, do: _count_factors(Integer.floor_div(n, p), [p | primes], acc + 1)
  def _count_factors(n, [_ | primes], acc), do: _count_factors(n, primes, acc)

  # check if first arg has at least the attributes of second arg
  def check_tile_match({p2, battrs2}, {p1, battrs1}) do
    cond do
      p1 != p2 and p1 != @any_prime and p2 != @any_prime -> false
      (battrs1 &&& battrs2) == battrs1 -> true # battrs1 includes battrs2
      true -> false
    end
  end

  def check_equivalence({p2, battrs2}, {p1, battrs1}, encoded_aliases) do
    # joker lookup is basically term rewriting: {tile, attrs} -> {tile, attrs}
    # so just check if an alias for {p2, battrs2} exists that matches {p1, battrs1}
    cond do
      check_tile_match({p2, battrs2}, {p1, battrs1}) -> true
      Enum.any?(Map.get(encoded_aliases, p1, []), fn {battrs, aliases} ->
        (battrs1 &&& battrs) == battrs1 and Enum.any?(aliases, fn {p3, battrs3} -> check_tile_match({p2, battrs2}, {p3, battrs3}) end)
      end) -> true
      Enum.any?(Map.get(encoded_aliases, @any_prime, []), fn {battrs, aliases} ->
        (battrs1 &&& battrs) == battrs1 and Enum.any?(aliases, fn {p3, battrs3} -> check_tile_match({p2, battrs2}, {p3, battrs3}) end)
      end) -> true
      true -> false
    end
  end

  # check that taking `attrs1` out of `attrs2` is possible with attributes
  # returns a list of indices (if exhaustive, a list of list of indices)
  # or nil if no solution
  # 

  def compute_masks(attrs2, attrs1, encoded_aliases) do
    for tile2 <- attrs2 do
      for {tile1, j} <- Enum.with_index(attrs1),
          check_equivalence(tile2, tile1, encoded_aliases),
          reduce: 0 do
        acc -> acc ||| (1 <<< j)
      end
    end
  end
  def subtract_check_attrs([], _attrs1, _encoded_aliases), do: nil
  def subtract_check_attrs(_attrs2, [], _encoded_aliases), do: {:ok, []}
  def subtract_check_attrs(attrs2, attrs1, encoded_aliases) do
    # compute bitmasks where the ith bitmask has jth bit set iff attrs2[i] covers attrs1[j]}
    masks = compute_masks(attrs2, attrs1, encoded_aliases)
    |> Enum.with_index()
    col_mask = Enum.reduce(masks, 0, fn {mask, _i}, acc -> mask ||| acc end)
    # then it's n-rooks on this bit matrix
    # returns indices into attrs2
    with {:ok, indices} <- solve_n_rooks(masks, col_mask, length(attrs1)) do
      cond do
        Enum.empty?(indices) -> nil
        true -> {:ok, indices}
      end
    end
  end
  def subtract_check_attrs_exhaustive([], _attrs1, _encoded_aliases), do: nil
  def subtract_check_attrs_exhaustive(_attrs2, [], _encoded_aliases), do: {:ok, [[]]}
  def subtract_check_attrs_exhaustive(attrs2, attrs1, encoded_aliases) do
    # compute bitmasks where the ith bitmask has jth bit set iff attrs2[i] covers attrs1[j]}
    masks = compute_masks(attrs2, attrs1, encoded_aliases)
    |> Enum.with_index()
    col_mask = Enum.reduce(masks, 0, fn {mask, _i}, acc -> mask ||| acc end)
    # then it's n-rooks on this bit matrix
    # returns indices into attrs2
    with {:ok, indices} <- solve_n_rooks_exhaustive(masks, col_mask, length(attrs1)) do
      cond do
        Enum.empty?(indices) -> nil
        true -> {:ok, indices}
      end
    end
  end
  
  # remove 2nd set (group) from 1st set (hand) to get resulting set, or nil if not removable
  def subtract(%{hash: hash2, attrs: _attrs2} = hand,
               %{hash: hash1, attrs: _attrs1} = group,
               encoded_aliases, encoded_joker_tiles) do
    if hash2 == 0, do: raise("subtract: somehow obtained a hash of zero in hand")
    if hash1 == 0, do: raise("subtract: somehow obtained a hash of zero in group")
    _subtract(hand, group, encoded_aliases, encoded_joker_tiles |> MapSet.new())
  end
  # returns many possible resulting sets instead of just one
  def subtract_exhaustive(%{hash: hash2, attrs: _attrs2} = hand,
                          %{hash: hash1, attrs: _attrs1} = group,
                          encoded_aliases, encoded_joker_tiles) do
    if hash2 == 0, do: raise("subtract: somehow obtained a hash of zero in hand")
    if hash1 == 0, do: raise("subtract: somehow obtained a hash of zero in group")
    _subtract_exhaustive(hand, group, encoded_aliases, encoded_joker_tiles |> MapSet.new())
  end


  def remove_tileset_indices(%{hash: hash, attrs: attrs} = hand, ixs, encoded_joker_tiles) do
    # extract a hash from the given indices in attrs
    divisor = for i <- ixs, reduce: 1 do
      acc -> acc * case Enum.at(attrs, i) do
        {p, _} = tile -> if tile in encoded_joker_tiles or p == @any_prime do 1 else p end
        _             -> 1
      end
    end

    if rem(hash, divisor) != 0 do
      # raise "subtract: tried to divide #{hash} by #{divisor}, hand was #{inspect(hand, limit: :infinity)}, group was #{inspect(group, limit: :infinity)}"
      raise "subtract: tried to divide #{hash} by #{divisor}, hand was #{inspect(hand, limit: :infinity)}"
    end
    %{hand | hash: Integer.floor_div(hash, divisor), attrs: remove_indices(attrs, ixs)}
  end

  defp _subtract(%{hash: hash2, attrs: attrs2} = hand,
                 %{hash: hash1, attrs: attrs1, nojoker: nojoker} = _group,
                 encoded_aliases, encoded_joker_tiles) do
    hash1 = if nojoker do
      Enum.reduce(attrs1, 1, fn {p, _}, acc -> p * acc end)
    else hash1 end
    encoded_aliases = if nojoker do %{} else encoded_aliases end
    encoded_joker_tiles = if nojoker do %{} else encoded_joker_tiles end

    # put all jokers at the end, so for non-exhaustive searches we guarantee choosing jokers last
    {jokers, nonjokers} = Enum.split_with(attrs2, & &1 in encoded_joker_tiles)
    attrs2 = nonjokers ++ jokers
    hand = %{hand | attrs: attrs2}

    gcd = Integer.gcd(hash2, hash1)

    # dbg = decode(group, tile_behavior) == [:any]
    # if dbg do
    #   IO.inspect({"asdf", hand, group, jokers, gcd, exhaustive})
    #   IO.inspect({"asdf", decode(hand, tile_behavior), decode(group, tile_behavior), exhaustive})
    #   IO.inspect({"asdfs", length(jokers), length(attrs1), count_factors(gcd, Enum.map(attrs1, fn {p, _} -> p end))})
    # end
    cond do
      length(attrs1) > length(attrs2) ->
        # can't remove more tiles than we have
        nil
      length(jokers) < Enum.count(attrs1, fn {p, _} -> p != @any_prime end) - count_factors(gcd, Enum.map(attrs1, fn {p, _} -> p end)) ->
        # not enough jokers to match unmatched tiles
        nil
      true ->
        # if nojoker, try to divide the jokers' primes with the unmatched primes
        gcd = if nojoker do
          unmatched = Integer.floor_div(hash1, gcd)
          hash3 = Enum.reduce(jokers, 1, fn {p, _}, acc -> p * acc end)
          gcd * Integer.gcd(hash3, unmatched)
        else gcd end 
        divides = gcd == hash1

        # if divides, no need to use jokers
        # otherwise, use jokers, but if not exhaustive, prioritize nonjokers-only if possible
        encoded_aliases = if divides do %{} else encoded_aliases end

        case subtract_check_attrs(nonjokers, attrs1, %{}) do
          {:ok, indices} -> remove_tileset_indices(hand, indices, encoded_joker_tiles)
          _ ->
            with {:ok, indices} <- subtract_check_attrs(attrs2, attrs1, encoded_aliases) do
              remove_tileset_indices(hand, indices, encoded_joker_tiles)
            end
        end
    end
  end

  defp _subtract_exhaustive(%{hash: hash2, attrs: attrs2} = hand,
                            %{hash: hash1, attrs: attrs1, nojoker: nojoker} = _group,
                            encoded_aliases, encoded_joker_tiles) do
    hash1 = if nojoker do
      Enum.reduce(attrs1, 1, fn {p, _}, acc -> p * acc end)
    else hash1 end
    encoded_aliases = if nojoker do %{} else encoded_aliases end
    encoded_joker_tiles = if nojoker do %{} else encoded_joker_tiles end

    # put all jokers at the end, so for non-exhaustive searches we guarantee choosing jokers last
    {jokers, nonjokers} = Enum.split_with(attrs2, & &1 in encoded_joker_tiles)
    attrs2 = nonjokers ++ jokers
    hand = %{hand | attrs: attrs2}

    gcd = Integer.gcd(hash2, hash1)

    # dbg = decode(group, tile_behavior) == [:any]
    # if dbg do
    #   IO.inspect({"asdf", hand, group, jokers, gcd, exhaustive})
    #   IO.inspect({"asdf", decode(hand, tile_behavior), decode(group, tile_behavior), exhaustive})
    #   IO.inspect({"asdfs", length(jokers), length(attrs1), count_factors(gcd, Enum.map(attrs1, fn {p, _} -> p end))})
    # end
    cond do
      length(attrs1) > length(attrs2) ->
        # can't remove more tiles than we have
        nil
      length(jokers) < Enum.count(attrs1, fn {p, _} -> p != @any_prime end) - count_factors(gcd, Enum.map(attrs1, fn {p, _} -> p end)) ->
        # not enough jokers to match unmatched tiles
        nil
      true ->
        # if nojoker, try to divide the jokers' primes with the unmatched primes
        gcd = if nojoker do
          unmatched = Integer.floor_div(hash1, gcd)
          hash3 = Enum.reduce(jokers, 1, fn {p, _}, acc -> p * acc end)
          gcd * Integer.gcd(hash3, unmatched)
        else gcd end 
        divides = gcd == hash1

        # if divides, no need to use jokers
        # otherwise, use jokers, but if not exhaustive, prioritize nonjokers-only if possible
        encoded_aliases = if divides do %{} else encoded_aliases end

        with {:ok, indices} <- subtract_check_attrs_exhaustive(attrs2, attrs1, encoded_aliases) do
          for ixs <- indices do remove_tileset_indices(hand, ixs, encoded_joker_tiles) end
          |> Enum.uniq()
        end
    end
  end

  # encode first argument A into a number, using second argument B as a dictionary
  # (first item of B = 1, second = 2, third = 4, etc)
  # assumes both inputs are sorted
  def encode_attrs(tile_attrs, all_attrs), do: _encode_attrs(Enum.sort(tile_attrs), MapSet.to_list(all_attrs), 0, 1)
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

  # use tile_behavior.attrs to encode
  def encode(hand, tile_behavior) do
    attrs = for orig_tile <- hand do
      {tile, attrs} = Utils.to_attr_tile(orig_tile)
      attrs = Enum.map(attrs, &String.trim_leading(&1, "_"))
      encoded_attrs = encode_attrs(attrs, tile_behavior.attrs)
      {Constants.to_prime(tile), encoded_attrs}
    end
    hash = Enum.reduce(attrs, 1, fn {p, _} = tile, acc ->
      if p == @any_prime or tile in tile_behavior.encoded_joker_tiles do acc else acc * p end
    end)
    %TileSet{
      hash: hash,
      attrs: attrs,
    }
  end

  def encode_aliases(tile_behavior) do
    for {tile, attrs_aliases} <- tile_behavior.aliases, reduce: %{} do
      acc ->
        entry = for {attrs, aliases} <- attrs_aliases, reduce: %{} do
          acc2 ->
            encoded_attrs = encode_attrs(attrs, tile_behavior.attrs)
            encoded_aliases = encode(aliases, tile_behavior).attrs
            Map.update(acc2, encoded_attrs, encoded_aliases, &encoded_aliases ++ &1)
        end
        Map.update(acc, Constants.to_prime(tile), entry, &Map.merge(entry, &1))
    end
  end

  def decode_attrs(attrs, tile_behavior) do
    for {p, attrs} <- attrs do
      tile = Constants.from_prime(p)
      # bitset to attr
      {_, attrs} = for attr <- tile_behavior.attrs, reduce: {attrs, []} do
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

  # use tile_behavior.attrs to decode
  def decode(%{attrs: attrs}, tile_behavior) do
    decode_attrs(attrs, tile_behavior)
  end

  # this is used a lot, especially for determining and processing calls
  def try_remove_all_tiles(hand, tiles, tile_behavior) do
    hand_length = length(hand)
    tiles_length = length(tiles)
    cond do
      hand_length < tiles_length -> [] # otherwise we'd be trying to remove more tiles than we have altogether
      hand_length == tiles_length ->
        # we can simply sort and compare pairwise
        hand = Enum.sort(hand)
        tiles = Enum.sort(tiles)
        if Enum.all?(Enum.zip(hand, tiles), fn {t1, t2} ->
          {t1, attrs1} = Utils.to_attr_tile(t1)
          {t2, attrs2} = Utils.to_attr_tile(t2)
          t1 == t2 and Enum.all?(attrs2, &String.starts_with?(&1, "_") or &1 in attrs1 or ("_" <> &1) in attrs1)
        end) do [[]] else [] end
      true ->
        # encode every tile into a TileSet
        hand_set = encode(hand, tile_behavior)
        tiles_set = encode(tiles, TileBehavior.remove_aliases(tile_behavior))
        encoded_aliases = encode_aliases(tile_behavior)
        case subtract_check_attrs_exhaustive(hand_set.attrs, tiles_set.attrs, encoded_aliases) do
          {:ok, ret} ->
            Enum.map(ret, fn is ->
              # IO.puts("Removing #{inspect(tiles)} from #{inspect(hand)} result is #{inspect(is, charlists: :as_lists)} becomes #{inspect(remove_indices(hand, is) |> Utils.remove_attr(["_hand", "_draw"]))}")
              remove_indices(hand, is)
            end)
          _ -> []
        end
    end
  end

  def elim_group([hand | calls], group, _tile_behavior) when is_binary(group) do
    # group is a call name, remove every corresponding call
    for {call, i} <- Enum.with_index(calls), call.name == group, do: [hand | List.delete_at(calls, i)]
  end
  def elim_group([hand | calls], group, tile_behavior) do
    cond do
      is_list(group) ->
        for subgroup <- group, reduce: [[hand | calls]] do
          acc when is_list(subgroup) ->
            # subgroup contains multiple parts that can be removed independently
            for part <- subgroup, reduce: acc do
              nil -> []
              acc -> Enum.flat_map(acc, &elim_group(&1, part, tile_behavior))
            end
          acc -> Enum.flat_map(acc, &elim_group(&1, subgroup, tile_behavior))
        end

        # for subgroup <- group, reduce: [[hand | calls]] do
        #   acc ->
        #     IO.inspect(Enum.map(acc, fn x -> Enum.map(x, &decode/1) end), label: inspect(decode(subgroup)))
        #     Enum.flat_map(acc, &elim_group(&1, subgroup))
        # end |> IO.inspect(label: inspect(Enum.map(group, &decode/1)))
      true ->
        from_calls = for {call, i} <- Enum.with_index(calls), is_subset?(group, call, tile_behavior), do: [hand | List.delete_at(calls, i)]
        # if length(group.attrs) == 3 do IO.puts("#{inspect(hand)}\n- #{inspect(group)}\n= #{inspect(subtract(hand, group))}") end
        case subtract_exhaustive(hand, group, tile_behavior.encoded_aliases, tile_behavior.encoded_joker_tiles |> Enum.to_list()) do
          nil -> from_calls
          ret ->
            for new_hand <- ret do
              # IO.inspect({hand.attrs, "-", group.attrs, "=", new_hand.attrs}, label: "Subtracting", limit: :infinity)
              # IO.inspect({length(hand.attrs), "-", length(group.attrs), "=", length(new_hand.attrs)}, label: "Subtracting")
              [new_hand | calls]
            end ++ from_calls
        end
    end
  end
  def elim_group_once(_hands, [], _tile_behavior) do
    IO.puts("Tried to remove an empty group []")
    []
  end
  def elim_group_once([hand | calls], group, _tile_behavior) when is_binary(group) do
    # group is a call name, remove one corresponding call
    case Enum.find_index(calls, & &1.name == group) do
      nil -> []
      i   -> [[hand | List.delete_at(calls, i)]]
    end
  end
  def elim_group_once([hand | calls], group, tile_behavior) when is_list(group) do
    for subgroup <- group, reduce: [[hand | calls]] do
      [] -> []
      acc ->
        if is_list(subgroup) and is_list(Enum.at(subgroup, 0)) do
          # subgroup contains multiple parts that can be removed independently
          for part <- subgroup, reduce: acc do
            [] -> []
            acc -> elim_group_once(acc |> Enum.at(0), part, tile_behavior)
          end
        else
          elim_group_once(acc |> Enum.at(0), subgroup, tile_behavior)
        end
    end
  end
  def elim_group_once([hand | calls], group, tile_behavior) do
    # we prefer removing from calls over from hand
    case Enum.find_index(calls, &is_subset?(group, &1, tile_behavior)) do
      nil -> case subtract(hand, group, tile_behavior.encoded_aliases, tile_behavior.encoded_joker_tiles |> Enum.to_list()) do
        nil -> []
        ret -> [[ret | calls]]
      end
      i -> [[hand | List.delete_at(calls, i)]]
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

  defp suit_to_offset(tile) do
    cond do
      Riichi.is_manzu?(tile) -> 0
      Riichi.is_pinzu?(tile) -> 10
      Riichi.is_souzu?(tile) -> 20
      true -> nil
    end
  end

  def apply_offset(base_tile, offset, tile_behavior) do
    case apply_offsets(base_tile, [offset], tile_behavior) do
      [t] -> t
      _ -> nil
    end
  end
  # @decorate cacheable(cache: RiichiAdvanced.Cache, key: {:apply_offsets, base_tile, offsets, tile_behavior.uuid})
  def apply_offsets(base_tile, offsets, tile_behavior), do: _apply_offsets(Utils.strip_attrs(base_tile), offsets, tile_behavior, 0, [])
  def _apply_offsets(_base_tile, [], _tile_behavior, n, []) when abs(n) > 100 do
    IO.puts("Infinite loop detected")
    IO.inspect(Process.info(self(), :current_stacktrace))
    nil
  end
  def _apply_offsets(_base_tile, [], _tile_behavior, _n, []), do: nil
  def _apply_offsets(_base_tile, [], _tile_behavior, _n, acc), do: Enum.reverse(acc)
  def _apply_offsets(nil, _offsets, _tile_behavior, _n, _acc), do: nil
  # when offset is a number, convert it into a map
  def _apply_offsets(base_tile, [o | offsets], tile_behavior, n, acc) when is_number(o), do: _apply_offsets(base_tile, [%{"offset" => o} | offsets], tile_behavior, n, acc)
  # when offset is a string, either try it as a tile or a @fixed_offset value
  def _apply_offsets(base_tile, [o | offsets], tile_behavior, n, acc) when is_binary(o) do
    cond do
      Map.has_key?(@fixed_offsets, o) ->
        tile = Map.get(@fixed_offsets, o)
        # then shift it based on the base_tile
        suit_offset = suit_to_offset(base_tile)
        if suit_offset == nil do
          # invalid, abort
         nil
        else
          tile = cond do
            tile == :"7z" and suit_offset ==  0 -> :"7z"
            tile == :"7z" and suit_offset == 10 -> :"0z"
            tile == :"7z" and suit_offset == 20 -> :"6z"
            tile == :"0z" and suit_offset ==  0 -> :"0z"
            tile == :"0z" and suit_offset == 10 -> :"6z"
            tile == :"0z" and suit_offset == 20 -> :"7z"
            tile == :"6z" and suit_offset ==  0 -> :"6z"
            tile == :"6z" and suit_offset == 10 -> :"7z"
            tile == :"6z" and suit_offset == 20 -> :"0z"
            true          -> _apply_offsets(tile, [suit_offset], tile_behavior, 0, []) |> Enum.at(0)
          end
          # IO.inspect({base_tile, o, tile})
          _apply_offsets(base_tile, offsets, tile_behavior, n, [tile | acc])
        end
      Utils.is_tile(o) -> _apply_offsets(base_tile, offsets, tile_behavior, n, [Utils.to_tile(o) | acc]) # also handles "any"
      # otherwise, probably a group keyword; ignore
      true -> _apply_offsets(base_tile, offsets, tile_behavior, n, acc)
    end
  end
  # standard case: when offset is a map (so it can specify attrs)
  def _apply_offsets(base_tile, [%{"offset" => o} | _] = os, tile_behavior, n, acc) when is_number(o) and n < o and o >= 10 and (o-n) >= 10, do: _apply_offsets(base_tile |> apply_ordering(@shift_suit), os, tile_behavior, n+10, acc)
  def _apply_offsets(base_tile, [%{"offset" => o} | _] = os, tile_behavior, n, acc) when is_number(o) and n > o and o <= -10 and (o-n) <= -10, do: _apply_offsets(base_tile |> apply_ordering(@shift_suit) |> apply_ordering(@shift_suit), os, tile_behavior, n-10, acc)
  def _apply_offsets(base_tile, [%{"offset" => o} | _] = os, tile_behavior, n, acc) when is_number(o) and n < o, do: _apply_offsets(base_tile |> apply_ordering(tile_behavior.ordering), os, tile_behavior, n+1, acc)
  def _apply_offsets(base_tile, [%{"offset" => o} | _] = os, tile_behavior, n, acc) when is_number(o) and n > o, do: _apply_offsets(base_tile |> apply_ordering(tile_behavior.ordering_r), os, tile_behavior, n-1, acc)
  # base cases
  def _apply_offsets(base_tile, [%{"offset" => o, "attrs" => attrs} | offsets], tile_behavior, n, acc) when is_number(o) and n == o, do: _apply_offsets(base_tile, offsets, tile_behavior, n, [{base_tile, attrs} | acc])
  def _apply_offsets(base_tile, [%{"offset" => o} | offsets], tile_behavior, n, acc) when is_number(o) and n == o, do: _apply_offsets(base_tile, offsets, tile_behavior, n, [base_tile | acc])
  # for when offset is a tile (non-numeric). also handles %{"attrs" => [...], "offset" => "any"}
  # this will generate nil if o is not a tile
  def _apply_offsets(base_tile, [%{"offset" => o, "attrs" => attrs} | offsets], tile_behavior, n, acc), do: _apply_offsets(base_tile, offsets, tile_behavior, n, [{Utils.to_tile(o), attrs}| acc])
  def _apply_offsets(base_tile, [%{"offset" => o} | offsets], tile_behavior, n, acc), do: _apply_offsets(base_tile, offsets, tile_behavior, n, [Utils.to_tile(o) | acc])
  def _apply_offsets(base_tile, [o | offsets], tile_behavior, n, acc), do: _apply_offsets(base_tile, offsets, tile_behavior, n, [Utils.to_tile(o) | acc])

  def is_bad_group(nil, _tile_behavior), do: true
  def is_bad_group({nil, _}, _tile_behavior), do: true
  def is_bad_group(s, _tile_behavior) when is_binary(s), do: false # it's a call name
  def is_bad_group(l, tile_behavior) when is_list(l), do: Enum.any?(l, &is_bad_group(&1, tile_behavior))
  def is_bad_group({t, _attrs}, tile_behavior), do: t != :any and t not in tile_behavior.all_tiles
  def is_bad_group(_t, _tile_behavior), do: false # t != :any and t not in tile_behavior.all_tiles

  # reifies a group spec into multiple possible groups, including joker usage

  # example input-outputs:

  # [[0, 1, 2], [3, 4, 5], [6, 7, 8]]: [
  #   [[:"1s", :"2s", :"3s"], [:"4s", :"5s", :"6s"], [:"7s", :"8s", :"9s"]],
  #   [[:"1p", :"2p", :"3p"], [:"4p", :"5p", :"6p"], [:"7p", :"8p", :"9p"]],
  #   [[:"1m", :"2m", :"3m"], [:"4m", :"5m", :"6m"], [:"7m", :"8m", :"9m"]]
  # ]

  # [%{"attrs" => ["yaochuu"], "offset" => "any"}]: [["9s": ["yaochuu"]]]
  # [%{"attrs" => ["tanyao"], "offset" => "any"}]: [["9s": ["tanyao"]]]

  # [%{"attrs" => ["yaochuu"], "offset" => 0}, %{"attrs" => ["yaochuu"], "offset" => 0}, %{"attrs" => ["yaochuu"], "offset" => 0}]: [
  #   ["9s": ["yaochuu"], "9s": ["yaochuu"], "9s": ["yaochuu"]],
  #   ["8s": ["yaochuu"], "8s": ["yaochuu"], "8s": ["yaochuu"]]
  # ]

  # [0, 1, 2]: [
  #   [:"3m", :"4m", :"5m"],
  #   [:"1s", :"2s", :"3s"],
  #   [:"5s", :"6s", :"7s"],
  #   [:"1m", :"2m", :"3m"]
  # ]
  # ["1m"]: [[:"1m"]]
  # ["9m"]: [[:"9m"]]
  # ["1p"]: [[:"1p"]]

  # "daiminkan": ["daiminkan"]
  # "kakan": ["kakan"]

  @decorate cacheable(cache: RiichiAdvanced.Cache, key: {:encode_group, group, tile_behavior.uuid})
  def encode_group(group, tile_behavior) do
    nojoker = Map.get(tile_behavior, :mappings, %{}) |> Enum.empty?()

    # when applying offsets to make groups, don't care about jokers
    tile_behavior = TileBehavior.remove_aliases(tile_behavior)

    case group do
      [[_ | _] | _] -> Enum.map(tile_behavior.base_tiles, &Enum.map(group, fn subgroup -> apply_offsets(&1, subgroup, tile_behavior) end))
      [_ | _] -> Enum.map(tile_behavior.base_tiles, &apply_offsets(&1, group, tile_behavior))
      _ ->
        cond do
          group == "any" -> [:any]
          MatchOld.is_offset(group) -> Enum.map(tile_behavior.base_tiles, &apply_offsets(&1, [group], tile_behavior))
          Utils.is_tile(group) -> [Utils.to_tile(group)]
          is_binary(group) -> if group in MatchOld.group_keywords() do [] else [group] end # call name
          true ->
            IO.puts("Unknown group spec #{inspect(group)}")
            []
        end
    end
    # |> IO.inspect(label: inspect(group))
    |> Enum.reject(&is_bad_group(&1, tile_behavior))
    # |> Enum.reject(fn x -> 
    #   ret = is_bad_group(x, tile_behavior)
    #   if ret do IO.inspect(x, label: "bad group #{inspect(group)}") end
    #   ret
    # end)
    |> Enum.uniq()
    # |> IO.inspect(label: inspect(group), limit: :infinity, charlists: :as_lists)
    |> Enum.map(&cond do
      is_binary(&1) -> &1 # pass through call names
      is_list(&1) and is_list(Enum.at(&1, 0)) -> [Enum.map(&1, fn subgroup -> encode(subgroup, tile_behavior) end)]
      is_list(&1) -> encode(&1, tile_behavior)
      true -> encode([&1], tile_behavior)
    end)
    |> Enum.map(fn group -> if nojoker and is_map(group) do
        %{group | nojoker: true}
      else group end
    end)
  end

  # faster match algorithm for when we're checking against an exact set of tiles
  # basically makes kokushi faster to check, also daisangen etc
  @spec perform_unique_match(data: map()) :: list(list(TileSet.t()))
  def perform_unique_match(data) do
    %{
      tile_behavior: tile_behavior,
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
        "- (#{count_factors(hand.hash, Enum.map(hand.attrs, fn {p, _} -> p end))}) #{inspect(Utils.sort_tiles(decode(hand, tile_behavior)))} / #{inspect(Enum.map(calls, &Utils.sort_tiles(decode(&1, tile_behavior))))} \\\\#{if unique do " unique" else "" end}#{if exhaustive do " exhaustive" else "" end}"
      end
      [line1 | lines]
    else "" end

    primes_attrs = groups
    |> Enum.map(fn
      group when is_list(group) -> Enum.map(group, &Utils.to_tile/1)
      group -> Utils.to_tile(group)
    end)
    |> Enum.map(&encode(List.wrap(&1), tile_behavior))

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
              # we need to use subtract in order to handle jokers
              # try removing from calls first
              # IO.inspect([hand | calls], label: "hands")
              # IO.inspect(group, label: "group")
              case Enum.find_index(calls, &is_subset?(group, &1, tile_behavior)) do
                nil ->
                  # remove from hand instead
                  case subtract(hand, group, tile_behavior.encoded_aliases, tile_behavior.encoded_joker_tiles |> Enum.to_list()) do
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
            "- (#{count_factors(hand.hash, Enum.map(hand.attrs, fn {p, _} -> p end))}) #{inspect(Utils.sort_tiles(decode(hand, tile_behavior)))} / #{inspect(Enum.map(calls, &Utils.sort_tiles(decode(&1, tile_behavior))))}"
          end
          IO.puts(Enum.join(report ++ [line1 | lines] ++ [""], "\n"))
        end
        new_acc
    end
  end

  @ignore_suit_mappings %{
    "1m": MapSet.new([:"1p", :"1s"]),
    "2m": MapSet.new([:"2p", :"2s"]),
    "3m": MapSet.new([:"3p", :"3s"]),
    "4m": MapSet.new([:"4p", :"4s"]),
    "5m": MapSet.new([:"5p", :"5s"]),
    "6m": MapSet.new([:"6p", :"6s"]),
    "7m": MapSet.new([:"7p", :"7s"]),
    "8m": MapSet.new([:"8p", :"8s"]),
    "9m": MapSet.new([:"9p", :"9s"]),
    "10m": MapSet.new([:"10p", :"10s"]),
    "1p": MapSet.new([:"1m", :"1s"]),
    "2p": MapSet.new([:"2m", :"2s"]),
    "3p": MapSet.new([:"3m", :"3s"]),
    "4p": MapSet.new([:"4m", :"4s"]),
    "5p": MapSet.new([:"5m", :"5s"]),
    "6p": MapSet.new([:"6m", :"6s"]),
    "7p": MapSet.new([:"7m", :"7s"]),
    "8p": MapSet.new([:"8m", :"8s"]),
    "9p": MapSet.new([:"9m", :"9s"]),
    "10p": MapSet.new([:"10m", :"10s"]),
    "1s": MapSet.new([:"1m", :"1p"]),
    "2s": MapSet.new([:"2m", :"2p"]),
    "3s": MapSet.new([:"3m", :"3p"]),
    "4s": MapSet.new([:"4m", :"4p"]),
    "5s": MapSet.new([:"5m", :"5p"]),
    "6s": MapSet.new([:"6m", :"6p"]),
    "7s": MapSet.new([:"7m", :"7p"]),
    "8s": MapSet.new([:"8m", :"8p"]),
    "9s": MapSet.new([:"9m", :"9p"]),
    "10s": MapSet.new([:"10m", :"10p"]),
  }
  def add_ignore_suit_mappings(mappings) do
    Map.merge(mappings, @ignore_suit_mappings, fn _k, l, r -> MapSet.union(l, r) end)
  end

  @spec perform_standard_match(data: map()) :: list(list(TileSet.t()))
  def perform_standard_match(data) do
    %{
      tile_behavior: tile_behavior,
      acc: acc,
      groups: groups,
      num: num,
      exhaustive: exhaustive,
      unique: unique,
      nojoker: nojoker,
      debug: debug,
    } = data

    # t = System.os_time(:millisecond)

    unique = unique or "unique" in groups
    nojoker_tile_behavior = TileBehavior.remove_aliases(tile_behavior)
    # take all groups and reify them into actual tiles
    # this reverses the order of groups, which is desirable since nojoker tiles will be first
    # embed nojoker into groups, so we don't need to pass a nojoker flag later on
    {_, groups} = for group <- groups, reduce: {nojoker, []} do
      {nojoker, acc} ->
        # reify each group spec into multiple possible groups
        cond do
          group in MatchOld.group_keywords() ->
            # we only care about the group keyword "nojoker" for now
            # this flags all later groups with nojoker = true
            {nojoker or group == "nojoker", acc}
          Map.has_key?(@fixed_offsets, group) || is_number(group) ->
            # amerijong offsets
            # return a version of each group for each possible base tile
            base_tiles = MapSet.union(tile_behavior.base_tiles, MapSet.new([:"1m", :"1p", :"1s"]))
            ret = {for base_tile <- base_tiles, into: %{} do
              {base_tile, encode_group(group, %{tile_behavior |
                mappings: if nojoker do %{} else tile_behavior.mappings end,
                base_tiles: [base_tile],
                uuid: Ecto.UUID.generate()})}
            end, group}
            {nojoker, [ret | acc]}
          true ->
            reified_groups = encode_group(group, if nojoker do nojoker_tile_behavior else tile_behavior end)
            # if length(reified_groups) > 10 do
            #   IO.inspect(tile_behavior.base_tiles, label: "base_tiles")
            #   IO.inspect(reified_groups |> Enum.map(&decode(&1, tile_behavior)), label: inspect(group), limit: :infinity)
            # end
            ret = {reified_groups, group}
            {nojoker, [ret | acc]}
        end
    end

    # if debug do IO.inspect(groups, label: inspect(data.groups), limit: :infinity) end
    # if debug do IO.inspect(tile_behavior.attrs) end
    if debug do IO.inspect(groups, limit: :infinity, label: "groups") end

    # each acc element is {[hand | calls], remaining_groups, base_suit}
    ret = for j <- (if num == 0 do [1] else 1..abs(num) end), reduce: Enum.map(acc, fn hands -> {hands, groups, nil} end) do
      [] -> []
      hands_groups ->
        report = if debug do
          line1 = "Acc (before removal #{j}/#{num}):"
          line1 = if j == 1 and not Enum.empty?(tile_behavior.mappings) do "Joker mapping: #{inspect(tile_behavior.mappings)}\n" <> line1 else line1 end
          lines = for {[hand | calls], remaining_groups, base_suit} <- hands_groups do
            # groups = Enum.map(remaining_groups, fn {groups, _orig_group} -> Enum.map(groups, &decode(&1, tile_behavior)) end)
            # groups = remaining_groups
            IO.inspect(remaining_groups, limit: :infinity)
            groups = Enum.map(remaining_groups, fn {_groups, orig_group} -> orig_group end)
            "- (#{count_factors(hand.hash, Enum.map(hand.attrs, fn {p, _} -> p end))}) #{inspect(Utils.sort_tiles(decode(hand, tile_behavior)))} / #{inspect(Enum.map(calls, &Utils.sort_tiles(decode(&1, tile_behavior))))} \\\\ #{inspect(groups, charlists: :as_lists)}#{if unique do " unique" else "" end}#{if exhaustive do " exhaustive" else "" end}#{if nojoker do " nojoker" else "" end}#{if base_suit != nil do " #{base_suit}" else "" end}"
          end
          [line1 | lines]
        else "" end

        hands_groups = if exhaustive do
          for {hands, remaining_groups, base_suit} <- hands_groups,
              {{groups, _orig_group}, i} <- Enum.with_index(remaining_groups),
              base_suit <- (if base_suit == nil and is_map(groups) do Map.keys(groups) else [base_suit] end),
              groups = (if is_map(groups) do Map.get(groups, base_suit) else groups end),
              group <- groups,
              hands <- (if exhaustive do elim_group(hands, group, tile_behavior) else elim_group_once(hands, group, tile_behavior) end),
              uniq: true do
            {hands, if unique do List.delete_at(remaining_groups, i) else remaining_groups end, base_suit}
          end
        else
          # only keep one result per base suit
          for {hands, remaining_groups, base_suit} <- hands_groups,
              {{groups, _orig_group}, i} <- Enum.with_index(remaining_groups),
              base_suit <- (if base_suit == nil and is_map(groups) do Map.keys(groups) else [base_suit] end),
              groups = (if is_map(groups) do Map.get(groups, base_suit) else groups end),
              group <- groups,
              hands <- (if exhaustive do elim_group(hands, group, tile_behavior) else elim_group_once(hands, group, tile_behavior) end),
              reduce: %{} do
            acc when is_map_key(acc, base_suit) -> acc
            acc -> Map.put(acc, base_suit, {hands, if unique do List.delete_at(remaining_groups, i) else remaining_groups end, base_suit})
          end
          |> Map.values()
          # |> Enum.take(1) # TODO see if correctness holds with this line uncommented
        end

        if debug do
          line1 = "Acc (after removal #{j}/#{num}):"
          lines = for {[hand | calls], _remaining_groups, _base_suit} <- hands_groups do
            "- (#{count_factors(hand.hash, Enum.map(hand.attrs, fn {p, _} -> p end))}) #{inspect(Utils.sort_tiles(decode(hand, tile_behavior)))} / #{inspect(Enum.map(calls, &Utils.sort_tiles(decode(&1, tile_behavior))))}"
          end
          IO.puts(Enum.join(report ++ [line1 | lines] ++ [""], "\n"))
        end

        hands_groups
    end
    |> Enum.map(fn {hands, _, _} -> hands end)

    ret
    |> Enum.uniq()
  end

  def gather_offsets(match_definitions) do
    for match_definition <- match_definitions,
        match_elem <- match_definition,
        is_list(match_elem),
        [groups, _num] = match_elem,
        offset <- List.flatten(List.wrap(groups)),
        offset != "any",
        MatchOld.is_offset(offset),
        uniq: true do
      offset
    end
  end

  def encode_hand([hand | calls], tile_behavior) do
    [encode(hand, tile_behavior) | Enum.map(calls, fn {name, call} ->
      ret = encode(call, tile_behavior)
      %{ret | name: name}
    end)]
  end

  def is_any_tile({:any, _}), do: true
  def is_any_tile(_), do: false

  def identify_jokers(initial_hands, encoded_aliases) do
    # scan thru aliases to identify jokers in hand
    for attrs_aliases <- Map.values(encoded_aliases),
        aliases <- Map.values(attrs_aliases),
        hand <- initial_hands,
        b <- hand.attrs,
        Enum.any?(aliases, fn a -> check_equivalence(b, a, encoded_aliases) end),
        uniq: true do b end
  end

  def prepare_tiles(hands, match_definitions, tile_behavior, base_tiles \\ nil)
  def prepare_tiles([hand | calls], match_definitions, tile_behavior, base_tiles) do
    # let all_tiles = tiles in hand + all joker aliases
    tiles_in_hand = hand ++ Enum.flat_map(calls, &Utils.call_to_tiles/1)
    encodable_tiles = Map.keys(tile_behavior.aliases) |> MapSet.new()

    # first pass

    # all tiles = strip_attrs(tiles_in_hand) ++ encodable_tiles
    all_tiles = tiles_in_hand
    |> Enum.map(&Utils.strip_attrs/1)
    |> MapSet.new()
    |> MapSet.union(encodable_tiles)
    |> MapSet.delete(:any)

    # encode hands and attrs_aliases
    tile_behavior = %{tile_behavior | all_tiles: all_tiles, uuid: Ecto.UUID.generate() }
    initial_hands = encode_hand([hand | calls], tile_behavior)
    encoded_aliases = encode_aliases(tile_behavior)
    tile_behavior = %{tile_behavior | encoded_aliases: encoded_aliases, uuid: Ecto.UUID.generate() }

    # find out which tiles are mappable to other tiles (i.e. they are jokers)
    encoded_joker_tiles = identify_jokers(initial_hands, encoded_aliases)
    joker_tiles = encoded_joker_tiles
    |> decode_attrs(tile_behavior)
    |> MapSet.new()

    # use the passed-in base_tiles, otherwise it's all_tiles minus joker_tiles
    base_tiles = if base_tiles == nil do
      base_tiles = MapSet.difference(all_tiles, joker_tiles)
      |> MapSet.delete(:any)
      base_tiles
    else MapSet.new(base_tiles) end

    # also add all offsets of existing tiles
    # we need to do this because jokers/offsets could reify into a tile
    #   that we can't otherwise encode, since it's not in hand
    offset_tiles =
      for base_tile <- base_tiles,
          group = apply_offsets(base_tile, gather_offsets(match_definitions), tile_behavior),
          not is_bad_group(group, tile_behavior),
          offset_tile <- group,
          not is_any_tile(offset_tile),
          into: MapSet.new() do offset_tile end
    all_tiles = all_tiles
    |> MapSet.union(offset_tiles)
    |> MapSet.delete(:any)

    base_tiles = all_tiles
    |> MapSet.difference(joker_tiles)
    |> MapSet.union(MapSet.new([:"1m", :"1p", :"1s"])) # for amerijong
    tile_behavior = %{tile_behavior | all_tiles: all_tiles, base_tiles: base_tiles, encoded_joker_tiles: encoded_joker_tiles }

    # encode aliases again, using new all_tiles that includes offset tiles
    encoded_aliases = encode_aliases(tile_behavior)
    tile_behavior = %{tile_behavior | encoded_aliases: encoded_aliases, uuid: Ecto.UUID.generate() }
    # dbg = length(hand) === 14
    # if dbg do
    #   # IO.inspect(gather_offsets(match_definitions))
    #   IO.inspect({"aaa", "aliases", tile_behavior.aliases})
    #   IO.inspect({"aaa", "match_definitions", match_definitions})
    #   IO.inspect({"aaa", "all_tiles", all_tiles})
    #   IO.inspect({"aaa", "encoded_joker_tiles", encoded_joker_tiles})
    #   IO.inspect({"aaa", "joker_tiles", joker_tiles})
    #   IO.inspect({"aaa", "base_tiles", base_tiles})
    #   IO.inspect({"aaa", "offset_tiles", offset_tiles})
    #   IO.inspect({"aaa", "initial_hands", initial_hands})
    #   # IO.inspect({"aaa", "group", encode_group([0, 1, 2], %{tile_behavior | all_tiles: all_tiles, base_tiles: base_tiles })}, limit: :infinity)
    #   # IO.inspect(Process.info(self(), :current_stacktrace))
    # end
    # IO.inspect({"asdf", tile_behavior.aliases}, limit: :infinity)

    {tiles_in_hand, initial_hands, tile_behavior}
  end

  def remove_match_definition(hand, calls, match_definition, tile_behavior) do
    prepare_tiles([hand | calls], [match_definition], tile_behavior)
    |> _remove_match_definition(match_definition, true)
  end
  def _remove_match_definition({tiles_in_hand, initial_hands, tile_behavior}, match_definition, decode? \\ false) do
    # early exit if we have more groups than tiles!
    # this is mostly to prevent 14 tile hands, like kokushi, from matching when we have 13 tiles
    debug = "debug" in match_definition
    min_match_length = Enum.reduce(match_definition, 0, fn
      [_match_elem, num], acc -> acc + num
      _, acc -> acc
    end)
    if min_match_length > length(tiles_in_hand) and "restart" not in match_definition and "almost" not in match_definition do
      if debug do IO.puts("Since we only have #{length(tiles_in_hand)} tiles, refusing to match length-#{min_match_length} match #{inspect(match_definition)}") end
      []
    else
      initial_state = %{
        tile_behavior: tile_behavior,
        acc: [initial_hands],
        exhaustive: false,
        unique: false,
        nojoker: false,
        debug: "debug" in match_definition,
      }
      skip_attrs = Enum.all?(tiles_in_hand, fn {_, []} -> true; {_, _} -> false; _ -> true end)
      ret = for match_elem <- match_definition, reduce: initial_state do
        state when state.acc == [] -> state
        state when match_elem == "exhaustive" -> %{state | exhaustive: true}
        state when match_elem == "unique" -> %{state | unique: true}
        state when match_elem == "nojoker" -> %{state | nojoker: true, tile_behavior: TileBehavior.remove_aliases(tile_behavior)}
        state when match_elem == "ignore_suit" ->
          # reencode hands as numeric jokers
          acc = state.acc
          acc = Enum.map(acc, &Enum.map(&1, fn hand -> decode(hand, tile_behavior) end))
          tile_behavior = Map.update!(tile_behavior, :mappings, &add_ignore_suit_mappings/1)
          encoded_aliases = encode_aliases(tile_behavior)
          acc = Enum.map(acc, &Enum.map(&1, fn hand -> encode(hand, tile_behavior) end))
          uuid = Ecto.UUID.generate()
          %{state | tile_behavior: %{tile_behavior | encoded_aliases: encoded_aliases, uuid: uuid}, acc: acc}
        state when match_elem == "almost" ->
          # simply add an :any joker to hand
          acc = Enum.map(state.acc, fn [hand | calls] -> [%{hand | hash: @any_prime * hand.hash, attrs: [{@any_prime, 0} | hand.attrs]} | calls] end)
          %{state | acc: acc}
        state when match_elem == "debug" -> state
        state when match_elem == "restart" -> %{state | acc: [initial_hands]}
        state when match_elem == "dismantle_calls" -> %{state | acc: Enum.map(state.acc, fn hands ->
          [Enum.reduce(hands, fn call, acc ->
            %{acc | hash: acc.hash * call.hash, attrs: call.attrs ++ acc.attrs}
          end)]
        end)}
        state when is_binary(match_elem) ->
          IO.puts("Unknown match keyword #{match_elem}")
          state
        state ->
          [groups, num] = match_elem
          data = Map.merge(state, %{groups: groups, num: num})
          new_acc = cond do
            skip_attrs and data.unique and not data.exhaustive and Enum.all?(groups, &Utils.is_tile(&1) or &1 in MatchOld.group_keywords()) -> perform_unique_match(data)
            true -> perform_standard_match(data)
          end
          new_acc = cond do
            num == 0 -> # forward lookahead
              if Enum.empty?(new_acc) do
                []
              else
                if debug do IO.puts("Reverting due to last group being a successful forward lookahead (num=0)") end
                state.acc # revert
              end
            num < 0  -> # negative lookahead
              if Enum.empty?(new_acc) do
                if debug do IO.puts("Reverting due to last group being a successful negative lookahead (num=#{num})") end
                state.acc # revert
              else
                [] # if we matched anything, no we didn't
              end
            true     ->
              if debug do
                if not Enum.empty?(new_acc) do
                  IO.puts("Final result:")
                  for [hand | calls] <- new_acc do
                    IO.puts("- #{inspect(Utils.sort_tiles(decode(hand, tile_behavior)))} / #{inspect(Enum.map(calls, &Utils.sort_tiles(decode(&1, tile_behavior))))}")
                  end
                else
                  IO.puts("Final result: (empty)")
                end
                IO.puts("")
              end
              new_acc
          end
          %{state | acc: new_acc}
      end
      |> Map.get(:acc)
      if decode? do
        Enum.map(ret, fn hands -> Enum.map(hands, &decode(&1, tile_behavior)) end)
      else ret end
    end
  end

  defp match_hand_v2(hand, calls, match_definitions, tile_behavior) do
    # dbg = Enum.count(hand, & &1 == :"9m") == 1
    # restrict all_tiles to be tiles that exist in hand/calls
    {tiles_in_hand, initial_hands, tile_behavior} = prepare_tiles([hand | calls], match_definitions, tile_behavior)

    # try each match definition in turn
    ret = Enum.any?(match_definitions, fn match_definition ->
      _remove_match_definition({tiles_in_hand, initial_hands, tile_behavior}, match_definition)
      # return if any results exist
      |> Enum.empty?()
      |> Kernel.not()
    end)
    {:ok, ret}
  end

  def match_hand(hand, calls, match_definitions, tile_behavior) do
    case match_hand_v2(hand, calls, match_definitions, tile_behavior) do
      {:ok, ret} -> ret
      _ ->
        IO.puts("Falling back to old match engine for hand #{inspect(hand)}")
        MatchOld.match_hand(hand, calls, match_definitions, tile_behavior)
    end
  end

  def remove_group(hand, group, tile_behavior, exhaustive \\ false, base_tiles \\ nil)
  def remove_group(hand, [], _tile_behavior, false, _base_tiles), do: hand
  def remove_group(hand, [], _tile_behavior, true, _base_tiles), do: [hand]
  def remove_group(hand, group, tile_behavior, exhaustive, base_tiles) do
    {_tiles_in_hand, [initial_hand], tile_behavior} = prepare_tiles([hand], [[[group, 1]]], tile_behavior, base_tiles)

    # debug = group == [-1, %{"attrs" => ["winning_tile"], "offset" => 0}, 1]
    # if debug do
    #   IO.inspect(tile_behavior, charlists: :as_lists, limit: :infinity)
    # end
    group
    |> encode_group(tile_behavior)
    |> Enum.reduce_while([], fn reified_group, acc ->
      subtract_exhaustive(initial_hand, reified_group, tile_behavior.encoded_aliases, tile_behavior.encoded_joker_tiles |> Enum.to_list())
      |> case do
        nil when exhaustive -> {:cont, acc}
        ret when exhaustive -> {:cont, ret ++ acc}
        [ret | _] -> {:halt, [ret]}
        nil -> {:cont, []}
        ret -> {:halt, [ret]}
      end
    end)
    |> case do
      ret when exhaustive -> Enum.map(ret, &decode(&1, tile_behavior))
      [] -> nil
      [ret | _] -> decode(ret, tile_behavior)
    end
  end

  # @decorate cacheable(cache: RiichiAdvanced.Cache, key: {:get_waits_v2, hand, calls, match_definitions, TileBehavior.hash(tile_behavior)})
  defp get_waits_v2(hand, calls, match_definitions, tile_behavior) do
    # basic strategy is to add a custom joker 1x
    # it will start as "all tiles" and progressively split its aliases in half,
    # until it encompasses "all tiles that don't work"
    # then we just take the complement
    all_tiles = Map.keys(tile_behavior.tile_freqs)
    all_tiles -- _get_waits_v2(hand, calls, match_definitions, tile_behavior, all_tiles)
  end
  defp _get_waits_v2(_hand, _calls, _match_definitions, _tile_behavior, []), do: []
  defp _get_waits_v2(hand, calls, match_definitions, tile_behavior, [x]) do
    if match_hand([x | hand], calls, match_definitions, tile_behavior) do
      []
    else
      [x]
    end
  end
  defp _get_waits_v2(hand, calls, match_definitions, tile_behavior, assignables) do
    tile_behavior_temp = TileBehavior.set_tile_alias(tile_behavior, [:"1x"], assignables)
    if match_hand([:"1x" | hand], calls, match_definitions, tile_behavior_temp) do
      # bisect
      {left, right} = Enum.split(assignables, Integer.floor_div(length(assignables), 2))
      left2 = _get_waits_v2(hand, calls, match_definitions, tile_behavior, left)
      right2 = _get_waits_v2(hand, calls, match_definitions, tile_behavior, right)
      left2 ++ right2
    else assignables end
  end

  def get_waits(hand, calls, match_definitions, tile_behavior) do
    get_waits_v2(hand, calls, match_definitions, tile_behavior)
  end

  # @decorate cacheable(cache: RiichiAdvanced.Cache, key: {:get_waits_and_ukeire_v2, hand, calls, match_definitions, visible_tiles, TileBehavior.hash(tile_behavior)})
  defp get_waits_and_ukeire_v2(hand, calls, match_definitions, visible_tiles, tile_behavior) do
    waits = get_waits_v2(hand, calls, match_definitions, tile_behavior)
    freqs = Utils.inverse_frequencies(visible_tiles, tile_behavior)
    Map.new(waits, &{&1, Map.get(freqs, &1, 0)})
  end

  def get_waits_and_ukeire(hand, calls, match_definitions, visible_tiles, tile_behavior) do
    get_waits_and_ukeire_v2(hand, calls, match_definitions, visible_tiles, tile_behavior)
  end

end
