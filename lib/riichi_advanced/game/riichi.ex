defmodule Riichi do

  @shift_suit %{:"1m"=>:"1p", :"2m"=>:"2p", :"3m"=>:"3p", :"4m"=>:"4p", :"5m"=>:"5p", :"6m"=>:"6p", :"7m"=>:"7p", :"8m"=>:"8p", :"9m"=>:"9p",
                :"1p"=>:"1s", :"2p"=>:"2s", :"3p"=>:"3s", :"4p"=>:"4s", :"5p"=>:"5s", :"6p"=>:"6s", :"7p"=>:"7s", :"8p"=>:"8s", :"9p"=>:"9s",
                :"1s"=>:"1m", :"2s"=>:"2m", :"3s"=>:"3m", :"4s"=>:"4m", :"5s"=>:"5m", :"6s"=>:"6m", :"7s"=>:"7m", :"8s"=>:"8m", :"9s"=>:"9m",
                :"1z"=>nil, :"2z"=>nil, :"3z"=>nil, :"4z"=>nil, :"5z"=>nil, :"6z"=>nil, :"7z"=>nil}
  def shift_suit(tile), do: @shift_suit[tile]

  @terminal_honors [:"1m",:"9m",:"1p",:"9p",:"1s",:"9s",:"1z",:"2z",:"3z",:"4z",:"5z",:"6z",:"7z"]

  # TODO remove this, replace with wall - joker tiles
  @all_tiles [
    :"1m",:"2m",:"3m",:"4m",:"5m",:"6m",:"7m",:"8m",:"9m",
    :"1p",:"2p",:"3p",:"4p",:"5p",:"6p",:"7p",:"8p",:"9p",
    :"1s",:"2s",:"3s",:"4s",:"5s",:"6s",:"7s",:"8s",:"9s",
    :"1z",:"2z",:"3z",:"4z",:"5z",:"6z",:"7z"
  ]

  def _offset_tile(tile, n, order, order_r) do
    if tile != nil do
      cond do
        n == 100 -> # dragon of the same suit, used in american
          cond do
            is_manzu?(tile) -> :"7z"
            is_pinzu?(tile) -> :"0z"
            is_souzu?(tile) -> :"6z"
            true           -> tile
          end
        n == 101 -> # dragon of a different suit, used in american
          cond do
            is_manzu?(tile) -> :"0z"
            is_pinzu?(tile) -> :"6z"
            is_souzu?(tile) -> :"7z"
            true           -> tile
          end
        n == 102 -> # dragon of a different suit, used in american
          cond do
            is_manzu?(tile) -> :"6z"
            is_pinzu?(tile) -> :"7z"
            is_souzu?(tile) -> :"0z"
            true           -> tile
          end
        (n < 1 && n > -1) || n < -10 || n >= 30 ->
          tile
        n >= 10 ->
          _offset_tile(shift_suit(tile), n-10, order, order_r)
        n < 0 ->
          _offset_tile(order_r[tile], n+1, order, order_r)
        true ->
          _offset_tile(order[tile], n-1, order, order_r)
      end
    else nil end
  end

  def offset_tile(tile, n, order, order_r) do
    case tile do
      {tile, attrs} -> {_offset_tile(tile, n, order, order_r), attrs}
      tile -> _offset_tile(tile, n, order, order_r)
    end    
  end

  @manzu      [:"1m", :"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m", :"9m", :"0m", :"10m",
               :"11m", :"12m", :"13m", :"14m", :"15m", :"16m", :"17m", :"18m", :"19m"]
  @pinzu      [:"1p", :"2p", :"3p", :"4p", :"5p", :"6p", :"7p", :"8p", :"9p", :"0p", :"10p",
               :"11p", :"12p", :"13p", :"14p", :"15p", :"16p", :"17p", :"18p", :"19p"]
  @souzu      [:"1s", :"2s", :"3s", :"4s", :"5s", :"6s", :"7s", :"8s", :"9s", :"0s", :"10s",
               :"11s", :"12s", :"13s", :"14s", :"15s", :"16s", :"17s", :"18s", :"19s"]
  @jihai      [:"1z", :"2z", :"3z", :"4z", :"5z", :"0z", :"6z", :"7z",
               :"11z", :"12z", :"13z", :"14z", :"15z", :"10z", :"16z", :"17z", :"25z", :"26z", :"27z"]
  @wind       [:"1z", :"2z", :"3z", :"4z", :"11z", :"12z", :"13z", :"14z"]
  @dragon     [:"5z", :"0z", :"6z", :"7z", :"15z", :"10z", :"16z", :"17z", :"25z", :"26z", :"27z"]
  @terminal   [:"1m", :"9m", :"1p", :"9p", :"1s", :"9s",
               :"11m", :"19m", :"11p", :"19p", :"11s", :"19s"]
  @tanyaohai  [:"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m",
               :"2p", :"3p", :"4p", :"5p", :"6p", :"7p", :"8p",
               :"2s", :"3s", :"4s", :"5s", :"6s", :"7s", :"8s"]
  @yaochuuhai [:"1m", :"9m", :"1p", :"9p", :"1s", :"9s", :"1z", :"2z", :"3z", :"4z", :"5z", :"6z", :"7z", 
               :"11m", :"19m", :"11p", :"19p", :"11s", :"19s", :"11z", :"12z", :"13z", :"14z", :"15z", :"16z", :"17z"]
  @flower     [:"1f", :"2f", :"3f", :"4f", :"1g", :"2g", :"3g", :"4g", :"1k", :"2k", :"3k", :"4k", :"1q", :"2q", :"3q", :"4q"]
  @joker      [:"1j", :"2j", :"3j", :"4j", :"5j", :"6j", :"7j", :"8j", :"9j", :"10j"]

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

  def try_remove_all_tiles(hand, tiles, tile_aliases \\ %{}, ignore_suit \\ false, _initial \\ true)
  def try_remove_all_tiles(hand, [], _tile_aliases, _ignore_suit, _initial), do: [hand]
  def try_remove_all_tiles(hand, [tile | tiles], tile_aliases, ignore_suit, _initial) do
    # t = System.os_time(:millisecond)
    ret = for t <- [tile] ++ Map.get(tile_aliases, tile, []) ++ Map.get(tile_aliases, :any, []) do
      hand
      |> Enum.with_index()
      |> Enum.filter(fn {hand_tile, _ix} -> if ignore_suit do Utils.same_number(hand_tile, t) else Utils.same_tile(hand_tile, t) end end)
      |> Enum.flat_map(fn {_hand_tile, ix} -> try_remove_all_tiles(List.delete_at(hand, ix), tiles, tile_aliases, ignore_suit) end)
    end |> Enum.concat() |> Enum.uniq()
    # elapsed_time = System.os_time(:millisecond) - t
    # if initial && elapsed_time > 10 do
    #   IO.puts("try_remove_all_tiles: #{inspect(hand)} #{inspect(tile)} #{inspect(elapsed_time)} ms")
    # end
    ret
  end

  def remove_from_hand_calls(hand, calls, tiles, tile_aliases \\ %{}, ignore_suit \\ false) do
    # from hand
    from_hand = try_remove_all_tiles(hand, tiles, tile_aliases, ignore_suit) |> Enum.map(fn hand -> {hand, calls} end)

    # from calls
    matching_indices = calls |> Enum.map(&call_to_tiles/1) |> Enum.with_index() |> Enum.flat_map(fn {call, i} ->
      case try_remove_all_tiles(call, tiles, tile_aliases, ignore_suit) do
        [] -> []
        _  -> [i]
      end
    end)
    from_calls = Enum.map(matching_indices, fn i -> {hand, List.delete_at(calls, i)} end)
    from_hand ++ from_calls |> Enum.uniq()
  end

  def try_remove_call(hand, calls, call_name) do
    ix = Enum.find_index(calls, fn {name, _call} -> name == call_name end)
    if ix != nil do [{hand, List.delete_at(calls, ix)}] else [] end
  end

  defp apply_tile_aliases(tiles, tile_aliases) do
    # add all aliases of the given tiles to tiles
    Enum.flat_map(tiles, fn tile ->
      [Utils.strip_attrs(tile), tile] ++ Enum.flat_map(tile_aliases, fn {from, to_tiles} ->
        if Enum.any?(to_tiles, &Utils.same_tile(tile, &1)) do [from] else [] end
      end) |> Enum.uniq()
    end) |> Enum.uniq()
  end

  @group_keywords ["nojoker"]

  def remove_group(hand, calls, group, ignore_suit, ordering, ordering_r, tile_aliases \\ %{}) do
    # IO.puts("removing group #{inspect(group)} from hand #{inspect(hand)}")
    # t = System.os_time(:millisecond)
    ret = cond do
      # group of tiles
      is_list(group) && not Enum.empty?(group) ->
        cond do
          # list of integers specifying a group of tiles
          Enum.all?(group, &is_integer/1) ->
            all_tiles = hand ++ Enum.flat_map(calls, &call_to_tiles/1)
            |> apply_tile_aliases(tile_aliases)
            all_tiles |> Enum.uniq() |> Enum.reject(& &1 == :any) |> Enum.flat_map(fn base_tile ->
              tiles = Enum.map(group, fn tile_or_offset -> if Utils.is_tile(tile_or_offset) do Utils.to_tile(tile_or_offset) else offset_tile(base_tile, tile_or_offset, ordering, ordering_r) end end)
              remove_from_hand_calls(hand, calls, tiles, tile_aliases, ignore_suit)
            end)
          # list of lists of integers specifying multiple related subgroups of tiles
          # can include a "nojoker" keyword specifying that subgroups after it should not use jokers
          Enum.all?(group, &is_list(&1) || &1 in @group_keywords) && Enum.all?(group, & &1 in @group_keywords || Enum.all?(&1, fn item -> is_integer(item) end)) ->
            no_joker_index = Enum.find_index(group, fn elem -> elem == "nojoker" end)
            hand ++ Enum.flat_map(calls, &call_to_tiles/1)
            |> apply_tile_aliases(tile_aliases)
            |> Enum.uniq()
            |> Enum.reject(& &1 == :any)
            |> Enum.flat_map(fn base_tile ->
              for {set, i} <- Enum.with_index(group), set not in @group_keywords, reduce: [{hand, calls}] do
                hand_calls ->
                  for {hand, calls} <- hand_calls do
                    tiles = Enum.map(set, fn tile_or_offset -> if Utils.is_tile(tile_or_offset) do Utils.to_tile(tile_or_offset) else offset_tile(base_tile, tile_or_offset, ordering, ordering_r) end end)
                    tile_aliases = if no_joker_index != nil && i > no_joker_index do %{} else tile_aliases end
                    remove_from_hand_calls(hand, calls, tiles, tile_aliases)
                  end |> Enum.concat()
              end
            end)
          # list of tiles
          Enum.all?(group, &Utils.is_tile/1) ->
            tiles = Enum.map(group, fn tile -> Utils.to_tile(tile) end)
            remove_from_hand_calls(hand, calls, tiles, tile_aliases)
          # single tile (with attrs)
          Utils.is_tile(group) -> remove_from_hand_calls(hand, calls, [Utils.to_tile(group)], tile_aliases, ignore_suit)
          true ->
            IO.puts("Unhandled group #{inspect(group)}")
            [{hand, calls}]
        end
      # single tile (no attrs)
      Utils.is_tile(group) -> remove_from_hand_calls(hand, calls, [Utils.to_tile(group)], tile_aliases, ignore_suit)
      # call
      is_binary(group) -> try_remove_call(hand, calls, group)
      true ->
        IO.puts("Unhandled group #{inspect(group)}")
        [{hand, calls}]
    end
    # elapsed_time = System.os_time(:millisecond) - t
    # if elapsed_time > 10 do
    #   IO.puts("remove_group: #{inspect(hand)} #{inspect(group)} #{inspect(elapsed_time)} ms")
    # end
    ret
  end

  # @match_keywords ["almost", "exhaustive", "ignore_suit", "restart", "unique", "nojoker", "debug"]

  def filter_irrelevant_tile_aliases(tile_aliases, all_tiles) do
    # filter out irrelevant tile aliases
    tile_aliases
    |> Enum.map(fn {tile, aliases} -> {tile, Enum.filter(aliases, fn t -> Enum.any?(all_tiles, &Utils.same_tile(&1, t)) end)} end)
    |> Enum.reject(fn {_tile, aliases} -> Enum.empty?(aliases) end)
    |> Map.new()
  end

  defp _remove_match_definition(hand, calls, match_definition, ordering, ordering_r, tile_aliases) do
    # t = System.os_time(:millisecond)
    almost = "almost" in match_definition
    exhaustive = "exhaustive" in match_definition
    ignore_suit = "ignore_suit" in match_definition
    unique_ix = Enum.find_index(match_definition, & &1 == "unique")
    debug = "debug" in match_definition
    if almost && :any in hand do
      IO.puts("Warning: \"almost\" keyword does not support hands that have :any yet")
    end
    hand = if almost do hand ++ [:any] else hand end
    filtered_tile_aliases = filter_irrelevant_tile_aliases(tile_aliases, hand ++ Enum.flat_map(calls, &call_to_tiles/1))
    if debug do
      IO.puts("======================================================")
      IO.puts("Match definition: #{inspect(match_definition, charlists: :as_lists)}")
      IO.puts("Tile aliases: #{inspect(filtered_tile_aliases)}")
    end
    no_joker_index = Enum.find_index(match_definition, fn elem -> elem == "nojoker" end)
    ret = for {match_definition_elem, i} <- Enum.with_index(match_definition), reduce: [{hand, calls}] do
      [] -> []
      hand_calls ->
        unique = unique_ix != nil && i > unique_ix
        case match_definition_elem do
          "restart" -> [{hand, calls}]
          [groups, num] ->
            tile_aliases = if no_joker_index != nil && i > no_joker_index do %{} else filtered_tile_aliases end
            if num == 0 do
              hand_calls # no op, this is created by decompose_match_definitions
            else
              new_hand_calls = if unique && not exhaustive && Enum.all?(groups, &Utils.is_tile/1) do
                # optimized routine for non-exhaustive unique tile-only groups
                # note: this assumes no duplicate tiles in the group
                for {hand, calls} <- hand_calls do
                  tiles = Enum.map(groups, &Utils.to_tile/1) |> Enum.uniq()
                  {tiles, matching_hand} = for tile <- hand, reduce: {tiles, []} do
                    {tiles, matching_hand} ->
                      if Enum.any?(tiles, &Utils.same_tile(tile, &1, tile_aliases)) do
                        {tiles -- [tile], [tile | matching_hand]}
                      else {tiles, matching_hand} end
                  end
                  {_tiles, matching_calls} = for call <- calls, reduce: {tiles, []} do
                    {tiles, matching_calls} ->
                      tile = Enum.find(call_to_tiles(call), & &1 in tiles)
                      if tile != nil do
                        {tiles -- [tile], [call | matching_calls]}
                      else {tiles, matching_calls} end
                  end
                  if length(matching_hand) + length(matching_calls) == num do
                    num_from_hand = min(num, length(matching_hand))
                    num_from_calls = min(num - num_from_hand, length(matching_calls))
                    hand = hand -- Enum.take(matching_hand, num_from_hand)
                    calls = calls -- Enum.take(matching_calls, num_from_calls)
                    [{hand, calls}]
                  else [] end
                end |> Enum.concat()
              else
                for _ <- 1..abs(num), reduce: Enum.map(hand_calls, fn {hand, calls} -> {hand, calls, groups} end) do
                  [] -> []
                  hand_calls_groups ->
                    if debug do
                      IO.puts("Hand: #{inspect(hand)}\nCalls: #{inspect(calls)}\nAcc (before removal):")
                      for {hand, calls, remaining_groups} <- hand_calls_groups do
                        IO.puts("- #{inspect(hand)} / #{inspect(calls)} / #{inspect(remaining_groups, charlists: :as_lists)}#{if unique do " unique" else "" end}#{if exhaustive do " exhaustive" else "" end}")
                      end
                    end
                    new_hand_calls_groups = if exhaustive do
                      for {hand, calls, remaining_groups} <- hand_calls_groups, group <- remaining_groups do
                        Task.async(fn ->
                          remove_group(hand, calls, group, ignore_suit, ordering, ordering_r, tile_aliases)
                          |> Enum.map(fn {hand, calls} -> {hand, calls, if unique do remaining_groups -- [group] else remaining_groups end} end)
                        end)
                      end
                      |> Task.yield_many(timeout: :infinity)
                      |> Enum.flat_map(fn {_task, {:ok, res}} -> res end)
                      |> Enum.uniq()
                    else
                      for {hand, calls, remaining_groups} <- hand_calls_groups, group <- remaining_groups, reduce: [] do
                        [] ->
                          remove_group(hand, calls, group, ignore_suit, ordering, ordering_r, tile_aliases)
                          |> Enum.take(1)
                          |> Enum.map(fn {hand, calls} -> {hand, calls, if unique do remaining_groups -- [group] else remaining_groups end} end)
                        result -> result
                      end
                    end
                    if debug do
                      IO.puts("Acc (after removal):")
                      for {hand, calls, remaining_groups} <- new_hand_calls_groups do
                        IO.puts("- #{inspect(hand)} / #{inspect(calls)} / #{inspect(remaining_groups, charlists: :as_lists)}")
                      end
                    end
                    new_hand_calls_groups
                end |> Enum.map(fn {hand, calls, _} -> {hand, calls} end)
              end
              if num < 0 do # this is a negative match
                if length(new_hand_calls) == 0 do
                  hand_calls # revert
                else
                  [] # if we matched anything, no we didn't
                end
              else
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
        matched = Enum.any?(hand_calls, fn {hand, calls} -> Riichi.match_hand(hand, calls, multiplied_match_def, ordering, ordering_r, tile_aliases) end)
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
    # IO.puts("#{inspect(calls_spec)} / #{inspect(hand)} / #{inspect(called_tiles)}")
    from_hand = Enum.empty?(called_tiles)
    {calls_spec, tile_aliases, tile_mappings} = if Enum.at(calls_spec, 0) == "nojoker" do
      {Enum.drop(calls_spec, 1), %{}, %{}}
    else {calls_spec, tile_aliases, tile_mappings} end
    for tile <- (if from_hand do hand else called_tiles end) do
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
  end
  def can_call?(calls_spec, hand, ordering, ordering_r, called_tiles \\ [], tile_aliases \\ %{}, tile_mappings \\ %{}), do: Enum.any?(make_calls(calls_spec, hand, ordering, ordering_r, called_tiles, tile_aliases, tile_mappings), fn {_tile, choices} -> not Enum.empty?(choices) end)

  def partially_apply_match_definitions(hand, calls, match_definitions, ordering, ordering_r, tile_aliases \\ %{}) do
    # take out one copy of each group to process last
    decomposed_match_definitions = for match_definition <- match_definitions do
      {result, _keywords} = for {match_definition_elem, i} <- Enum.with_index(match_definition), reduce: {[], []} do
        {result, keywords} -> case match_definition_elem do
          [groups, num] when num >= 1     ->
            entry = {List.replace_at(match_definition, i, [groups, num-1]), keywords ++ [[groups, 1]]}
            {[entry | result], keywords}
          [_groups, num] when num < 1     -> {result, keywords}
          keyword when is_binary(keyword) -> {result, keywords ++ [keyword]}
        end
      end
      Enum.reverse(result)
    end |> Enum.concat()
    for {def1, def2} <- decomposed_match_definitions do
      {remove_match_definition(hand, calls, def1, ordering, ordering_r, tile_aliases), def2}
    end
  end

  # hand_calls_def is the output of partially_apply_match_definitions
  def is_waiting_on(tile, hand_calls_def, ordering, ordering_r, tile_aliases \\ %{}) do
    Enum.any?(hand_calls_def, fn {hand_calls, def2} ->
      Enum.any?(hand_calls, fn {hand, calls} ->
        match_hand(hand ++ [tile], calls, [def2], ordering, ordering_r, tile_aliases)
      end)
    end)
  end

  # TODO move wall to front, remove @all_tiles
  # get all unique waits for a given 14-tile match definition, like win
  # will not remove a wait if you have four of the tile in hand or calls
  def get_waits(hand, calls, match_definitions, ordering, ordering_r, tile_aliases \\ %{}, wall \\ @all_tiles, skip_tenpai_check \\ false) do
    # t = System.os_time(:millisecond)

    # only check for waits if we're tenpai
    ret = if skip_tenpai_check || match_hand(hand, calls, Enum.map(match_definitions, &["almost" | &1]), ordering, ordering_r, tile_aliases) do
      filtered_tile_aliases = filter_irrelevant_tile_aliases(tile_aliases, hand ++ Enum.flat_map(calls, &call_to_tiles/1))
      hand_calls_def = partially_apply_match_definitions(hand, calls, match_definitions, ordering, ordering_r, tile_aliases)
      for tile <- Enum.uniq(wall), reduce: [] do
        waits -> if tile in waits do waits else
          tile_aliases = if tile_aliases[tile] != nil do
            Map.put(filtered_tile_aliases, tile, tile_aliases[tile])
          else tile_aliases end
          if is_waiting_on(tile, hand_calls_def, ordering, ordering_r, tile_aliases) do
            other_waits = [tile | Map.get(tile_aliases, tile, [])] |> Utils.strip_attrs()
            waits ++ other_waits
          else waits end
        end |> Enum.uniq()
      end
    else [] end

    # elapsed_time = System.os_time(:millisecond) - t
    # if elapsed_time > 10 do
    #   IO.puts("get_waits: #{inspect(elapsed_time)} ms")
    # end

    ret
  end

  def _get_waits_and_ukeire(wall, visible_tiles, hand, calls, match_definitions, ordering, ordering_r, tile_aliases, skip_tenpai_check) do
    waits = get_waits(hand, calls, match_definitions, ordering, ordering_r, tile_aliases, wall, skip_tenpai_check)
    freqs = Enum.frequencies(wall -- Utils.strip_attrs(visible_tiles))
    Map.new(waits, fn wait -> {wait, freqs[wait] || 0} end)
  end

  def get_waits_and_ukeire(wall, visible_tiles, hand, calls, match_definitions, ordering, ordering_r, tile_aliases \\ %{}, skip_tenpai_check \\ false) do
    case RiichiAdvanced.ETSCache.get({:get_waits_and_ukeire, wall, visible_tiles, hand, calls, match_definitions, ordering, tile_aliases}) do
      [] -> 
        result = _get_waits_and_ukeire(wall, visible_tiles, hand, calls, match_definitions, ordering, ordering_r, tile_aliases, skip_tenpai_check)
        RiichiAdvanced.ETSCache.put({:get_waits_and_ukeire, wall, visible_tiles, hand, calls, match_definitions, ordering, tile_aliases}, result)
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
        potential_set = Utils.add_attr(Enum.take(context.call.other_tiles, 2) ++ [context.tile2], ["hand"])
        triplet = remove_group(potential_set, [], [0,0,0], false, context.players[context.seat].tile_ordering, context.players[context.seat].tile_ordering_r, context.players[context.seat].tile_aliases)
        sequence = remove_group(potential_set, [], [0,1,2], false, context.players[context.seat].tile_ordering, context.players[context.seat].tile_ordering_r, context.players[context.seat].tile_aliases)
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

  def get_player_from_seat_wind(kyoku, wind) do
    Utils.next_turn(wind, rem(kyoku, 4))
  end

  def get_east_player_seat(kyoku) do
    Utils.next_turn(:east, rem(kyoku, 4))
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
      :"1z" -> if :east in [seat_wind, round_wind] do 2 else 0 end
      :"2z" -> if :south in [seat_wind, round_wind] do 2 else 0 end
      :"3z" -> if :west in [seat_wind, round_wind] do 2 else 0 end
      :"4z" -> if :north in [seat_wind, round_wind] do 2 else 0 end
      :"5z" -> 2
      :"6z" -> 2
      :"7z" -> 2
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
    
    starting_hand = starting_hand ++ ton_tiles
    standard_length = length(starting_hand) in [1, 4, 7, 10, 13]
    winning_tiles = if standard_length do apply_tile_aliases([winning_tile], tile_aliases) else @all_tiles end
    starting_hand = if standard_length do starting_hand else starting_hand ++ [winning_tile] end
    # initial fu
    fu = case win_source do
      :draw -> 22
      _     -> if Enum.all?(calls, fn {name, _call} -> name == "ankan" end) do 30 else 20 end
    end

    # add called triplets
    fu = fu + (Enum.map(calls, &calculate_call_fu/1) |> Enum.sum)

    # TODO actually generalize wrapping based on ordering
    # rather than hardcoding
    wraps = "1m" in Map.get(ordering, "9m", [])
    possible_penchan_removed = if wraps do [] else
      Enum.flat_map(winning_tiles, fn winning_tile ->
        case Utils.strip_attrs(winning_tile) do
          :"3m" -> try_remove_all_tiles(starting_hand, [:"1m", :"2m"], tile_aliases)
          :"7m" -> try_remove_all_tiles(starting_hand, [:"8m", :"9m"], tile_aliases)
          :"3p" -> try_remove_all_tiles(starting_hand, [:"1p", :"2p"], tile_aliases)
          :"7p" -> try_remove_all_tiles(starting_hand, [:"8p", :"9p"], tile_aliases)
          :"3s" -> try_remove_all_tiles(starting_hand, [:"1s", :"2s"], tile_aliases)
          :"7s" -> try_remove_all_tiles(starting_hand, [:"8s", :"9s"], tile_aliases)
          :"2z" -> if wraps do [] else try_remove_all_tiles(starting_hand, [:"3z", :"4z"], tile_aliases) end
          :"3z" -> if wraps do [] else try_remove_all_tiles(starting_hand, [:"1z", :"2z"], tile_aliases) end
          _     -> []
        end |> Enum.map(fn hand -> {hand, fu+2} end)
      end)
    end
    middle_tiles = [:"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m", :"2p", :"3p", :"4p", :"5p", :"6p", :"7p", :"8p", :"2s", :"3s", :"4s", :"5s", :"6s", :"7s", :"8s", :"2z", :"3z", :"6z"]
    all_tiles = middle_tiles ++ [:"1m", :"9m", :"1p", :"9p", :"1s", :"9s", :"1z", :"4z", :"5z", :"7z"]
    kanchan_tiles = if wraps do all_tiles else middle_tiles end
    possible_kanchan_removed = Enum.flat_map(winning_tiles, fn winning_tile ->
      if Utils.count_tiles(kanchan_tiles, [winning_tile], tile_aliases) >= 1 do
        try_remove_all_tiles(starting_hand, [offset_tile(winning_tile, -1, ordering, ordering_r), offset_tile(winning_tile, 1, ordering, ordering_r)], tile_aliases)
        |> Enum.map(fn hand -> {hand, fu+2} end)
      else [] end
    end)
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
    possible_kontsu_removed = if enable_kontsu_fu do
      Enum.flat_map(winning_tiles, fn winning_tile ->
        try_remove_all_tiles(starting_hand, [offset_tile(winning_tile, 10, ordering, ordering_r), offset_tile(winning_tile, 20, ordering, ordering_r)], tile_aliases)
        |> Enum.map(fn hand -> {hand, fu+((if win_source == :draw do 2 else 1 end)*(if winning_tile in @terminal_honors do 2 else 1 end))} end)
      end)
    else [] end
    hands_fu = possible_penchan_removed ++ possible_kanchan_removed ++ possible_left_ryanmen_removed ++ possible_right_ryanmen_removed ++ possible_kontsu_removed ++ [{starting_hand, fu}]

    # from these hands, remove all triplets and add the according amount of closed triplet fu
    hands_fu = for _ <- 1..4, reduce: hands_fu do
      all_hands ->
        Enum.flat_map(all_hands, fn {hand, fu} ->
          hand |> Enum.uniq() |> apply_tile_aliases(tile_aliases) |> Enum.flat_map(fn base_tile ->
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
            {honors, suited} = hand |> Enum.uniq() |> apply_tile_aliases(tile_aliases)
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
          sequence_tiles = hand |> Enum.uniq() |> apply_tile_aliases(tile_aliases)
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
        true                                                   -> []
      end
    end)

    # IO.inspect(winning_tiles)
    # IO.inspect(fus, charlists: :as_lists)

    fu = if Enum.empty?(fus) do 0 else Enum.max(fus) end

    # if we can get (closed) pinfu, we should
    closed_pinfu_fu = if win_source == :draw do 22 else 30 end
    fu = if closed_pinfu_fu in fus do closed_pinfu_fu else fu end

    # if it's kokushi, 30 fu (tsumo) or 40 fu (ron)
    kokushi_tiles = [:"1m", :"9m", :"1p", :"9p", :"1s", :"9s", :"1z", :"2z", :"3z", :"4z", :"5z", :"6z", :"7z"]
    fu = Enum.flat_map(winning_tiles, fn winning_tile ->
      case try_remove_all_tiles(starting_hand ++ [winning_tile], kokushi_tiles, tile_aliases) do
        [] -> [fu]
        _  -> [if win_source == :draw do 30 else 40 end]
      end
    end) |> Enum.max()

    # IO.inspect(fu)

    # closed pinfu is 20 tsumo/30 ron, open pinfu is 30, chiitoitsu is 25
    num_pairs = binary_search_count_matches([{starting_hand, []}], [[[[[0, 0]], 1]]], ordering, ordering_r, tile_aliases)
    ret = cond do
      fu == 22 && win_source == :draw && Enum.empty?(calls) -> 20
      fu == 30 && win_source != :draw && Enum.empty?(calls) -> 30
      fu == 20 && not Enum.empty?(calls)                    -> 30
      Enum.empty?(fus) && num_pairs == 6                    -> 25
      Enum.empty?(fus) && num_pairs == 5                    -> 30 # kakura kurumi
      true                                                  ->
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

end
