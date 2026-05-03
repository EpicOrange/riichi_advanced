defmodule RiichiAdvanced.Match do
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
      attrs: list({integer(), integer()} | {:name, binary()} | {:nojoker, boolean()} | {:joker, list({integer(), integer()})}),
    }
    defstruct [
      hash: 1,    # product of primes
      attrs: [],  # list of {prime, attr bitset}
                  # may also include {:name, call name}
                  # may also include {:nojoker, true} if this is a group and jokers should not be used
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
    def factor(n, primes \\ @primes, acc \\ [])
    def factor(1, _primes, acc), do: acc
    def factor(_n, [], acc), do: acc
    def factor(0, _primes, acc) do
      IO.puts("factor: somehow tried to get the prime decomposition of 0")
      IO.inspect(Process.info(self(), :current_stacktrace))
      acc
    end
    def factor(_n, [0 | _primes], acc) do
      IO.puts("factor: somehow tried to divide by 0")
      IO.inspect(Process.info(self(), :current_stacktrace))
      acc
    end
    def factor(n, [p | primes], acc) when rem(n, p) == 0, do: factor(Integer.floor_div(n, p), [p | primes], [p | acc])
    def factor(n, [_ | primes], acc), do: factor(n, primes, acc)

    def find_ixs_helper(attrs2, attrs1, goal_hash, use_jokers) do
      attrs2_indexed = if use_jokers do
        {joker, nonjoker} = attrs2
        |> Enum.with_index()
        |> Enum.split_with(fn {{p, _}, _} -> p == :joker end)
        nonjoker ++ joker
      else Enum.with_index(attrs2) end

      # compute bitmasks where the ith bitmask has jth bit set iff attrs2[i] covers attrs1[j]}
      masks = for {{p2, battrs2}, _i} <- attrs2_indexed do
        case p2 do
          :joker when use_jokers -> for {{p1, battrs1}, j} <- Enum.with_index(attrs1), Enum.any?(battrs2, fn {p2, battrs2} -> p1 == p2 and (battrs1 &&& battrs2) == battrs1 end), reduce: 0 do
            acc -> acc ||| (1 <<< j)
          end
          :joker ->
            {p2, battrs2} = Enum.at(battrs2, 0)
            for {{p1, battrs1}, j} <- Enum.with_index(attrs1), p1 == p2, (battrs1 &&& battrs2) == battrs1, reduce: 0 do
              acc -> acc ||| (1 <<< j)
            end
          p when is_number(p) -> for {{p1, battrs1}, j} <- Enum.with_index(attrs1), p1 == p2, (battrs1 &&& battrs2) == battrs1, reduce: 0 do
            acc -> acc ||| (1 <<< j)
          end
          _ -> 0
        end
      end
      if Enum.empty?(masks) do
        nil
      else
        col_mask = Enum.reduce(masks, &Bitwise.|||/2)
        masks = masks
        |> Enum.with_index()
        |> Enum.reject(fn {mask, _i} -> mask == 0 end)
        
        # then it's n-rooks on this bit matrix
        with {:ok, ixs} <- solve_n_rooks(masks, col_mask, length(factor(goal_hash))) do
          # convert mask indices to the original hand indices
          {:ok, Enum.map(ixs, &Enum.at(attrs2_indexed, &1) |> elem(1))}
        end
      end
    end
      
    # remove 2nd set from 1st set to get a resulting set, or nil if not removable
    def subtract(%{hash: hash2, attrs: _attrs2} = hand,
                 %{hash: hash1, attrs: _attrs1} = group, return_indices \\ false) do
      if hash2 == 0, do: raise("TileSet.subtract: somehow obtained a hash of zero in hand")
      if hash1 == 0, do: raise("TileSet.subtract: somehow obtained a hash of zero in group")
      # if RiichiAdvanced.Match.have_cargo() do
      #   indices = subtract_rust(hash2, hash1, attrs2, attrs1)
      # else
        _subtract(hand, group, return_indices)
      # end
    end
    # def subtract_rust(_hash2, _hash1, _attrs2, _attrs1), do: :erlang.nif_error(:nif_not_loaded)
    defp _subtract(%{hash: hash2, attrs: attrs2} = hand,
                   %{hash: hash1, attrs: attrs1} = group,
                   return_indices) do
      precheck = rem(hash2, hash1) == 0
      cond do
        # if there are no attrs, succeed early since we don't need to make a new attrs
        precheck && Enum.empty?(attrs2) -> %{hand | hash: Integer.floor_div(hash2, hash1)}
        # otherwise, we need to craft a new attrs list
        precheck && Keyword.has_key?(attrs1, :nojoker) ->
          with {:ok, ixs} <- find_ixs_helper(attrs2, attrs1, hash1, false) do
            cond do
              return_indices -> ixs
              # TODO does gcd give us any info we can check here for optimizations?
              # gcd = Integer.gcd(hash2, hash1)
              true -> %{hand | hash: Integer.floor_div(hash2, hash1), attrs: remove_indices(attrs2, ixs)}
            end
          end
        # if we can use jokers, try to use jokers to fill partial matches, if any
        not Keyword.has_key?(attrs1, :nojoker) ->
          jokers = Enum.filter(attrs2, fn {p2, _} -> p2 === :joker end)
          with {:ok, ixs} <- find_ixs_helper(attrs2, attrs1, hash1, not Enum.empty?(jokers)) do
            # IO.inspect({attrs2, attrs1, hash1, not Enum.empty?(jokers), ixs})
            cond do
              return_indices -> ixs
              true ->
                # we need to divide hash by each joker's prime, not the goal prime
                divisor = for i <- ixs, reduce: 1 do
                  acc -> acc * case Enum.at(attrs2, i) do
                    {:joker, [{p, _} | _]}   -> p
                    {p, _} when is_number(p) -> p
                    _                        -> 1
                  end
                end
                if rem(hash2, divisor) != 0 do
                  raise "TileSet.subtract: tried to divide #{hash2} by #{divisor}, hand was #{inspect(hand, limit: :infinity)}, group was #{inspect(group, limit: :infinity)}"
                end
                %{hand | hash: Integer.floor_div(hash2, divisor), attrs: remove_indices(attrs2, ixs)}
            end
          end
        true -> nil
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
    
    def verify(%{hash: hash, attrs: attrs} = hand) do
      prod = for {p, v} <- attrs, reduce: 1 do
        acc -> acc * case p do
          :joker -> elem(hd(v), 0)
          p when is_number(p) -> p
          _ -> 1
        end
      end
      if prod != hash do
        raise "Hand with hash #{hash} has actual product #{prod}: #{inspect(attrs)}"
      end
      hand
    end

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
      for {p, attrs} <- attrs, p == :joker or is_number(p) do
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
      # (this is more efficient than list subtract, even with no attr jokerless hands)
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
    IO.puts("Tried to remove an empty group []")
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
    # we prefer removing from calls over from hand
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
      true -> 0
    end
  end

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
  # when offset is a string, either try it as a tile or a @fixed_offset value
  def _apply_offsets(base_tile, [o | offsets], tile_behavior, n, acc) when is_binary(o) do
    cond do
      Map.has_key?(@fixed_offsets, o) ->
        tile = Map.get(@fixed_offsets, o)
        # then shift it based on the base_tile
        suit_offset = suit_to_offset(base_tile)
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
      Utils.is_tile(o) -> _apply_offsets(base_tile, offsets, tile_behavior, n, [Utils.to_tile(o) | acc])
      # otherwise, probably a group keyword; ignore
      true -> _apply_offsets(base_tile, offsets, tile_behavior, n, acc)
    end
  end
  # standard case: when offset is a map (so it can specify attrs)
  def _apply_offsets(base_tile, [%{"offset" => o} | _] = os, tile_behavior, n, acc) when is_number(o) and n < o and o >= 10 and (o-n) >= 10, do: _apply_offsets(base_tile |> apply_ordering(@shift_suit), os, tile_behavior, n+10, acc)
  def _apply_offsets(base_tile, [%{"offset" => o} | _] = os, tile_behavior, n, acc) when is_number(o) and n > o and o <= -10 and (o-n) <= -10, do: _apply_offsets(base_tile |> apply_ordering(@shift_suit) |> apply_ordering(@shift_suit), os, tile_behavior, n-10, acc)
  def _apply_offsets(base_tile, [%{"offset" => o} | _] = os, tile_behavior, n, acc) when is_number(o) and n < o and o > 0, do: _apply_offsets(base_tile |> apply_ordering(tile_behavior.ordering), os, tile_behavior, n+1, acc)
  def _apply_offsets(base_tile, [%{"offset" => o} | _] = os, tile_behavior, n, acc) when is_number(o) and n > o and o < 0, do: _apply_offsets(base_tile |> apply_ordering(tile_behavior.ordering_r), os, tile_behavior, n-1, acc)
  def _apply_offsets(base_tile, [%{"offset" => o} | _] = os, tile_behavior, n, acc) when is_number(o) and n > o and o == 0, do: _apply_offsets(base_tile, os, tile_behavior, n, acc)
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

  # reifies a group spec into multiple possible groups, including joker usage
  def encode_group(group, all_tiles, encoding, all_attrs, tile_behavior) do
    nojoker = not Map.has_key?(encoding, :mappings)
    encoding = Map.delete(encoding, :mappings)

    nested = is_list(group) and is_list(Enum.at(group, 0))
    cond do
      nested -> Enum.map(all_tiles, &Enum.map(group, fn
        subgroup -> apply_offsets(&1, subgroup, tile_behavior)
      end))
      is_list(group) -> Enum.map(all_tiles, &apply_offsets(&1, group, tile_behavior))
      MatchOld.is_offset(group) -> Enum.map(all_tiles, &apply_offsets(&1, [group], tile_behavior))
      group == "any" -> Enum.map(all_tiles, &List.wrap(&1))
      Utils.is_tile(group) -> case Utils.to_tile(group) do
        {:any, attrs} -> for tile <- all_tiles, Utils.has_attr?(tile, attrs), do: [tile]
        tile          -> [[tile]]
      end
      is_binary(group) -> if group in MatchOld.group_keywords() do nil else [group] end # could be a call name
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
    |> Enum.map(fn group -> if nojoker and is_map(group) do %{group | attrs: [{:nojoker, true} | group.attrs]} else group end end)
  end

  # faster match algorithm for when we're checking against an exact set of tiles
  # basically makes kokushi faster to check, also daisangen etc
  @spec perform_unique_match(data: map()) :: [[TileSet.t()]]
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
        "- (#{TileSet.factor(hand.hash) |> length()}) #{inspect(Utils.sort_tiles(TileSet.decode(hand, encoding, all_attrs)))} / #{inspect(Enum.map(calls, &Utils.sort_tiles(TileSet.decode(&1, encoding, all_attrs))))} \\\\#{if unique do " unique" else "" end}#{if exhaustive do " exhaustive" else "" end}"
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
            "- (#{TileSet.factor(hand.hash) |> length()}) #{inspect(Utils.sort_tiles(TileSet.decode(hand, encoding, all_attrs)))} / #{inspect(Enum.map(calls, &Utils.sort_tiles(TileSet.decode(&1, encoding, all_attrs))))}"
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

  @spec perform_standard_match(data: map()) :: [[TileSet.t()]]
  def perform_standard_match(data) do
    %{
      tile_behavior: tile_behavior,
      encoding: encoding,
      all_tiles: all_tiles,
      all_tiles_jokers: all_tiles_jokers,
      all_attrs: all_attrs,
      acc: acc,
      groups: groups,
      num: num,
      exhaustive: exhaustive,
      unique: unique,
      nojoker: nojoker,
      debug: debug,
    } = data
    unique = unique or "unique" in groups
    # take all groups and reify them into actual tiles
    # this reverses the order of groups, which is desirable since nojoker tiles will be first

    {_, groups} = for group <- groups, reduce: {nojoker, []} do
      {nojoker, acc} ->
        # reify each group spec into multiple possible groups
        cond do
          group in MatchOld.group_keywords() -> {nojoker or group == "nojoker", acc}
          Map.has_key?(@fixed_offsets, group) || is_number(group) ->
            # amerijong
            # return a version of each group for each possible base tile
            ret = {for base_tile <- [:"1m", :"1p", :"1s" | all_tiles], into: %{} do
              {base_tile, encode_group(group, [base_tile], encoding, all_attrs, tile_behavior)}
            end, group}
            {nojoker, [ret | acc]}
          true ->
            all_tiles = if nojoker do all_tiles else all_tiles_jokers end
            reified_groups = encode_group(group, all_tiles, encoding, all_attrs, tile_behavior)
            # IO.inspect(reified_groups |> Enum.map(&TileSet.decode(&1, encoding, all_attrs)), label: inspect(group), limit: :infinity)
            ret = {reified_groups, group}
            {nojoker, [ret | acc]}
        end
    end
    for j <- (if num == 0 do [1] else 1..abs(num) end), reduce: Enum.map(acc, fn hands -> {hands, groups, nil} end) do
      [] -> []
      hands_groups ->
        report = if debug do
          line1 = "Acc (before removal #{j}/#{num}):"
          mappings = Map.get(encoding, :mappings, %{})
          line1 = if j == 1 and not Enum.empty?(mappings) do "Joker mapping: #{inspect(mappings)}\n" <> line1 else line1 end
          lines = for {[hand | calls], remaining_groups, base_suit} <- hands_groups do
            groups = Enum.map(remaining_groups, fn {_groups, orig_group} -> orig_group end)
            "- (#{TileSet.factor(hand.hash) |> length()}) #{inspect(Utils.sort_tiles(TileSet.decode(hand, encoding, all_attrs)))} / #{inspect(Enum.map(calls, &Utils.sort_tiles(TileSet.decode(&1, encoding, all_attrs))))} \\\\ #{inspect(groups, charlists: :as_lists)}#{if unique do " unique" else "" end}#{if exhaustive do " exhaustive" else "" end}#{if nojoker do " nojoker" else "" end}#{if base_suit != nil do " #{base_suit}" else "" end}"
          end
          [line1 | lines]
        else "" end

        hands_groups =
          for {hands, remaining_groups, base_suit} <- hands_groups,
              {{groups, _orig_group}, i} <- Enum.with_index(remaining_groups),
              base_suit <- (if base_suit == nil and is_map(groups) do [:"1m", :"1p", :"1s" | all_tiles] else [base_suit] end),
              groups = (if is_map(groups) do Map.get(groups, base_suit) else groups end),
              group <- groups,
              new_hands <- (if exhaustive do elim_group(hands, group) else elim_group_once(hands, group) end) do
            {new_hands, if unique do List.delete_at(remaining_groups, i) else remaining_groups end, base_suit}
          end

        hands_groups = if exhaustive do Enum.uniq(hands_groups) else Enum.uniq_by(hands_groups, fn {_, _, base_suit} -> base_suit end) end

        if debug do
          line1 = "Acc (after removal #{j}/#{num}):"
          lines = for {[hand | calls], _remaining_groups, _base_suit} <- hands_groups do
            "- (#{TileSet.factor(hand.hash) |> length()}) #{inspect(Utils.sort_tiles(TileSet.decode(hand, encoding, all_attrs)))} / #{inspect(Enum.map(calls, &Utils.sort_tiles(TileSet.decode(&1, encoding, all_attrs))))}"
          end
          IO.puts(Enum.join(report ++ [line1 | lines] ++ [""], "\n"))
        end

        hands_groups
    end
    |> Enum.map(fn {hands, _, _} -> hands end)
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
    has_almost = Enum.any?(match_definitions, fn match_definition -> "almost" in match_definition end)
    any_tile_jokers_exist = has_almost or Enum.any?(hand, fn tile ->
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

    # if the encoding is too large (we ran out of primes!) fall back to old match engine
    # in practice, this doesn't happen (at least in the test suite)
    if map_size(encoding) >= 250 do
      {:error, :out_of_primes}
    else
      initial_hands = [TileSet.encode(hand, encoding, all_attrs) | Enum.map(calls, fn {name, call} ->
        ret = TileSet.encode(call, encoding, all_attrs)
        %{ret | attrs: [{:name, name} | ret.attrs]}
      end)]

      # calculate all possible base tiles according to jokers in hand
      all_wall_tiles = Map.keys(tile_behavior.tile_freqs)
      all_tiles_jokers = Enum.flat_map(all_tiles, fn tile ->
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
        end) |> Enum.uniq()

      # try each match definition in turn
      ret = Enum.any?(match_definitions, fn match_definition ->
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
          initial_state = %{
            encoding: encoding,
            acc: [initial_hands],
            tile_behavior: tile_behavior,
            all_tiles: all_tiles,
            all_tiles_jokers: all_tiles_jokers,
            all_attrs: all_attrs,
            exhaustive: false,
            unique: false,
            nojoker: false,
            debug: "debug" in match_definition,
          }

          for match_elem <- match_definition, reduce: initial_state do
            state when state.acc == [] -> state
            state when match_elem == "exhaustive" -> %{state | exhaustive: true}
            state when match_elem == "unique" -> %{state | unique: true}
            state when match_elem == "nojoker" -> %{state | nojoker: true, encoding: Map.delete(state.encoding, :mappings)}
            state when match_elem == "ignore_suit" ->
              # reencode hands as numeric jokers
              acc = state.acc
              acc = Enum.map(acc, &Enum.map(&1, fn hand -> TileSet.decode(hand, encoding, all_attrs) end))
              mappings = Map.get(encoding, :mappings, %{}) |> add_ignore_suit_mappings()
              encoding = create_encoding(all_tiles, mappings)
              acc = Enum.map(acc, &Enum.map(&1, fn hand -> TileSet.encode(hand, encoding, all_attrs) end))
              all_tiles = Enum.flat_map(all_tiles, &apply_offsets(&1, [0, 10, 20], tile_behavior)) |> Enum.uniq()
              %{state | encoding: encoding, acc: acc, all_tiles: all_tiles}
            state when match_elem == "almost" ->
              # simply add an :any joker to hand
              encoding = Map.put_new_lazy(encoding, :any, fn -> Enum.at(TileSet.primes(), map_size(encoding)) end)
              prime = Map.get(encoding, :any)
              joker = {:joker, [{prime, 0} | encoding |> Map.drop([:mappings]) |> Map.values() |> Enum.map(&{&1, 0})]}
              acc = Enum.map(state.acc, fn [hand | calls] -> [%{hand | hash: hand.hash * prime, attrs: [joker | hand.attrs]} | calls] end)
              %{state | encoding: encoding, acc: acc, all_tiles: all_wall_tiles}
            state when match_elem == "debug" -> state
            state when match_elem == "restart" -> %{state | acc: [initial_hands]}
            state when match_elem == "dismantle_calls" -> %{state | acc: Enum.map(state.acc, fn hands ->
              [Enum.reduce(hands, fn call, acc ->
                %{acc | hash: acc.hash * call.hash, attrs: Enum.filter(call.attrs, fn {p, _} -> p == :joker or is_number(p) end) ++ acc.attrs}
              end)]
            end)}
            state when is_binary(match_elem) ->
              IO.puts("Unknown match keyword #{match_elem}")
              state
            state ->
              [groups, num] = match_elem
              data = Map.merge(state, %{groups: groups, num: num})
              new_acc = cond do
                Enum.empty?(match_attrs) and data.unique and not data.exhaustive and Enum.all?(groups, &Utils.is_tile(&1) or &1 in MatchOld.group_keywords()) -> perform_unique_match(data)
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
                        IO.puts("- #{inspect(Utils.sort_tiles(TileSet.decode(hand, encoding, all_attrs)))} / #{inspect(Enum.map(calls, &Utils.sort_tiles(TileSet.decode(&1, encoding, all_attrs))))}")
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
          |> Enum.empty?()
          |> Kernel.not()
        end
      end)
      {:ok, ret}
    end
  end

  def match_hand(hand, calls, match_definitions, tile_behavior) do
    case match_hand_v2(hand, calls, match_definitions, tile_behavior) do
      {:ok, ret} -> ret
      {:error, :out_of_primes} ->
        IO.puts("Falling back to old match engine for hand #{inspect(hand)}")
        MatchOld.match_hand(hand, calls, match_definitions, tile_behavior)
    end
  end

  # @decorate cacheable(cache: RiichiAdvanced.Cache, key: {:get_waits_v2, hand, calls, match_definitions, TileBehavior.hash(tile_behavior)})
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
    if match_hand([x | hand], calls, match_definitions, tile_behavior) do
      []
    else
      [x]
    end
  end
  def _get_waits_v2(hand, calls, match_definitions, tile_behavior, assignables) do
    tile_behavior_temp = TileBehavior.set_tile_alias(tile_behavior, [:"1x"], assignables)
    if match_hand([:"1x" | hand], calls, match_definitions, tile_behavior_temp) do
      # bisect
      {left, right} = Enum.split(assignables, Integer.floor_div(length(assignables), 2))
      left2 = _get_waits_v2(hand, calls, match_definitions, tile_behavior, left)
      right2 = _get_waits_v2(hand, calls, match_definitions, tile_behavior, right)
      left2 ++ right2
    else assignables end
  end

  # @decorate cacheable(cache: RiichiAdvanced.Cache, key: {:get_waits_and_ukeire_v2, hand, calls, match_definitions, visible_tiles, TileBehavior.hash(tile_behavior)})
  def get_waits_and_ukeire_v2(hand, calls, match_definitions, visible_tiles, tile_behavior) do
    waits = get_waits_v2(hand, calls, match_definitions, tile_behavior)
    freqs = Utils.inverse_frequencies(visible_tiles, tile_behavior)
    Map.new(waits, &{&1, Map.get(freqs, &1, 0)})
  end


end
