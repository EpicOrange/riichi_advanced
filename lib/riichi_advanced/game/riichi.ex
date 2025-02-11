defmodule RiichiAdvanced.Riichi do
  alias RiichiAdvanced.GameState.TileBehavior, as: TileBehavior
  alias RiichiAdvanced.Match, as: Match
  alias RiichiAdvanced.Utils, as: Utils

  # for fu calculation only
  @terminal_honors [:"1m",:"9m",:"1p",:"9p",:"1s",:"9s",:"1z",:"2z",:"3z",:"4z",:"5z",:"6z",:"7z"]

  @flower_names ["start_flower", "start_joker", "flower", "joker", "pei"]
  def flower_names(), do: @flower_names

  @manzu      [:"1m", :"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m", :"9m", :"0m", :"10m",
               :"11m", :"12m", :"13m", :"14m", :"15m", :"16m", :"17m", :"18m", :"19m",
               :"01m", :"02m", :"03m", :"04m", :"05m", :"06m", :"07m", :"08m", :"09m", :"010m"]
  @pinzu      [:"1p", :"2p", :"3p", :"4p", :"5p", :"6p", :"7p", :"8p", :"9p", :"0p", :"10p",
               :"11p", :"12p", :"13p", :"14p", :"15p", :"16p", :"17p", :"18p", :"19p",
               :"01p", :"02p", :"03p", :"04p", :"05p", :"06p", :"07p", :"08p", :"09p", :"010p"]
  @souzu      [:"1s", :"2s", :"3s", :"4s", :"5s", :"6s", :"7s", :"8s", :"9s", :"0s", :"10s",
               :"11s", :"12s", :"13s", :"14s", :"15s", :"16s", :"17s", :"18s", :"19s",
               :"01s", :"02s", :"03s", :"04s", :"05s", :"06s", :"07s", :"08s", :"09s", :"010s"]
  @jihai      [:"1z", :"2z", :"3z", :"4z", :"5z", :"0z", :"8z", :"6z", :"7z",
               :"11z", :"12z", :"13z", :"14z", :"15z", :"10z", :"16z", :"17z", :"25z", :"26z", :"27z"]
  @wind       [:"1z", :"2z", :"3z", :"4z", :"11z", :"12z", :"13z", :"14z", :"01z", :"02z", :"03z", :"04z"]
  @dragon     [:"5z", :"0z", :"8z", :"6z", :"7z", :"15z", :"10z", :"16z", :"17z", :"25z", :"26z", :"27z", :"05z", :"00z", :"06z", :"07z"]
  @terminal   [:"1m", :"9m", :"1p", :"9p", :"1s", :"9s",
               :"11m", :"19m", :"11p", :"19p", :"11s", :"19s",
               :"01m", :"09m", :"01p", :"09p", :"01s", :"09s"]
  # TODO somehow change these when ten mod is active
  @tanyaohai  [:"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m",
               :"2p", :"3p", :"4p", :"5p", :"6p", :"7p", :"8p",
               :"2s", :"3s", :"4s", :"5s", :"6s", :"7s", :"8s",
               :"02m", :"03m", :"04m", :"05m", :"25m", :"35m", :"06m", :"07m", :"08m",
               :"02p", :"03p", :"04p", :"05p", :"25p", :"35p", :"06p", :"07p", :"08p",
               :"02s", :"03s", :"04s", :"05s", :"25s", :"35s", :"06s", :"07s", :"08s"]
  @yaochuuhai [:"1m", :"9m", :"1p", :"9p", :"1s", :"9s", :"1z", :"2z", :"3z", :"4z", :"5z", :"0z", :"8z", :"6z", :"7z", 
               :"11m", :"19m", :"11p", :"19p", :"11s", :"19s", :"11z", :"12z", :"13z", :"14z", :"15z", :"16z", :"17z",
               :"01m", :"09m", :"01p", :"09p", :"01s", :"09s", :"01z", :"02z", :"03z", :"04z", :"05z", :"00z", :"06z", :"07z"]
  @flower     [:"1f", :"2f", :"3f", :"4f", :"1g", :"2g", :"3g", :"4g", :"1k", :"2k", :"3k", :"4k", :"1q", :"2q", :"3q", :"4q", :"1a", :"2a", :"3a", :"4a", :"1y"]
  @joker      [:"0j", :"1j", :"2j", :"3j", :"4j", :"5j", :"6j", :"7j", :"8j", :"9j", :"10j", :"12j", :"13j", :"14j", :"15j", :"16j", :"17j", :"18j", :"19j", :"37j", :"46j", :"147j", :"258j", :"369j", :"123j", :"456j", :"789j", :"91j", :"73j", :"64j", :"852j", :"20j", :"11j", :"22j", :"30j", :"31j", :"32j", :"33j", :"34j", :"2y"]
  @aka        [:"0m", :"0p", :"0s", :"26z",
               :"01m", :"02m", :"03m", :"04m", :"05m", :"25m", :"35m", :"06m", :"07m", :"08m", :"09m", :"010m",
               :"01p", :"02p", :"03p", :"04p", :"05p", :"25p", :"35p", :"06p", :"07p", :"08p", :"09p", :"010p",
               :"01s", :"02s", :"03s", :"04s", :"05s", :"25s", :"35s", :"06s", :"07s", :"08s", :"09s", :"010s"]

  def is_manzu?(tile), do: Enum.any?(@manzu, &Utils.same_tile(tile, &1))
  def is_pinzu?(tile), do: Enum.any?(@pinzu, &Utils.same_tile(tile, &1))
  def is_souzu?(tile), do: Enum.any?(@souzu, &Utils.same_tile(tile, &1))
  def is_jihai?(tile), do: Enum.any?(@jihai, &Utils.same_tile(tile, &1))
  def is_suited?(tile), do: is_manzu?(tile) or is_pinzu?(tile) or is_souzu?(tile)
  def is_wind?(tile), do: Enum.any?(@wind, &Utils.same_tile(tile, &1))
  def is_dragon?(tile), do: Enum.any?(@dragon, &Utils.same_tile(tile, &1))
  def is_terminal?(tile), do: Enum.any?(@terminal, &Utils.same_tile(tile, &1))
  def is_yaochuuhai?(tile), do: Enum.any?(@yaochuuhai, &Utils.same_tile(tile, &1))
  def is_tanyaohai?(tile), do: Enum.any?(@tanyaohai, &Utils.same_tile(tile, &1))
  def is_flower?(tile), do: Enum.any?(@flower, &Utils.same_tile(tile, &1))
  def is_joker?(tile), do: Enum.any?(@joker, &Utils.same_tile(tile, &1))
  def is_aka?(tile), do: Enum.any?(@aka, &Utils.same_tile(tile, &1))

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

  # return all possible calls of each tile in called_tiles, given hand
  # includes returning multiple choices for jokers (incl. red fives)
  # if called_tiles is an empty list, then we choose from our hand
  # example output: %{:"5m" => [[:"4m", :"6m"], [:"6m", :"7m"]]}
  def make_calls(calls_spec, hand, tile_behavior, called_tiles \\ []) do
    # t = System.os_time(:millisecond)

    # IO.puts("#{inspect(calls_spec)} / #{inspect(hand)} / #{inspect(called_tiles)}")
    from_hand = Enum.empty?(called_tiles)
    {calls_spec, tile_behavior} = if Enum.at(calls_spec, 0) == "nojoker" do
      {Enum.drop(calls_spec, 1), %TileBehavior{ tile_behavior | aliases: %{} }}
    else {calls_spec, tile_behavior} end
    ret = for tile <- (if from_hand do hand else called_tiles end) do
      {tile, Enum.flat_map(calls_spec, fn call_spec ->
        hand = if from_hand do List.delete(hand, tile) else hand end
        target_tiles = Enum.map(call_spec, &Match.offset_tile(Utils.strip_attrs(tile), &1, tile_behavior))
        possible_removals = Match.try_remove_all_tiles(hand, target_tiles, tile_behavior)
        Enum.map(possible_removals, fn remaining -> Utils.sort_tiles(hand -- remaining) end)
      end) |> Enum.uniq()}
    end |> Enum.uniq_by(fn {tile, choices} -> Enum.map(choices, fn choice -> Enum.sort([tile | choice]) end) end) |> Map.new()

    # elapsed_time = System.os_time(:millisecond) - t
    # if elapsed_time > 10 do
    #   IO.puts("make_calls/can_call: #{inspect(elapsed_time)} ms")
    # end
    
    ret
  end
  def can_call?(calls_spec, hand, tile_behavior, called_tiles \\ []), do: Enum.any?(make_calls(calls_spec, hand, tile_behavior, called_tiles), fn {_tile, choices} -> not Enum.empty?(choices) end)

  # get all unique waits for a given 14-tile match definition, like win
  # will not remove a wait if you have four of the tile in hand or calls
  def get_waits(hand, calls, match_definitions, all_tiles, tile_behavior, skip_tenpai_check \\ false) do
    # only check for waits if we're tenpai
    if skip_tenpai_check or Match.match_hand(hand, calls, Enum.map(match_definitions, &["almost" | &1]), tile_behavior) do
      # go through each match definition and see what tiles can be added for it to match
      # as soon as something doesn't match, get all tiles that help make it match
      # take the union of helpful tiles across all match definitions
      for match_definition <- match_definitions do
        # make it exhaustive, unless it's unique
        match_definition = if "unique" not in match_definition and "exhaustive" not in match_definition do ["exhaustive" | match_definition] else match_definition end
        # IO.puts("\n" <> inspect(match_definition))
        {_keywords, waits_complement} = for {last_match_definition_elem, i} <- Enum.with_index(match_definition), reduce: {[], all_tiles} do
          {keywords, []}               -> {keywords, []}
          {keywords, waits_complement} -> case last_match_definition_elem do
            keyword when is_binary(keyword) -> {keywords ++ [keyword], waits_complement}
            [_groups, num] when num <= 0 -> {keywords, waits_complement} # ignore lookaheads
            [groups, num] ->
              # first remove all other groups
              hand_calls = [{hand, calls}]
              remaining_match_definition = List.delete_at(match_definition, i)
              hand_calls = Enum.flat_map(hand_calls, fn {hand, calls} ->
                Match.remove_match_definition(hand, calls, remaining_match_definition, tile_behavior)
              end)
              |> Enum.uniq()

              # then remove groups num-1 times no matter what
              # num_hand_calls = length(hand_calls)
              hand_calls = if num > 1 do
                Enum.flat_map(hand_calls, fn {hand, calls} ->
                  Match.remove_match_definition(hand, calls, keywords ++ [[groups, num - 1]], tile_behavior)
                end)
                |> Enum.uniq()
              else hand_calls end

              # try to remove the last one
              final_match_definition = keywords ++ [[groups, 1]]
              {hand_calls_success, hand_calls_failure} = Enum.map(hand_calls, fn {hand, calls} ->
                case Match.remove_match_definition(hand, calls, final_match_definition, tile_behavior) do
                  []         -> {[], [{hand, calls}]} # failure
                  hand_calls -> {hand_calls, []} # success (new hand_calls)
                end
              end)
              |> Enum.unzip()
              hand_calls_success = Enum.concat(hand_calls_success)
              hand_calls_failure = Enum.concat(hand_calls_failure)
              # IO.puts("#{inspect(keywords)} #{inspect(last_match_definition_elem)}: #{num_hand_calls} tries (#{length(hand_calls)} after filtering), #{length(hand_calls_success)} successes, #{length(hand_calls_failure)} failures")
              # IO.inspect(hand_calls_success, label: "hand_calls_success")
              # IO.inspect(hand_calls_failure, label: "hand_calls_failure")

              # waits_complement = all waits that don't help
              # remove waits that do help
              waits_complement = if Enum.empty?(hand_calls_success) do
                Enum.reject(waits_complement, fn wait ->
                  Enum.any?(hand_calls_failure, fn {hand, calls} ->
                    Match.match_hand([wait | hand], calls, [final_match_definition], tile_behavior)
                  end)
                end)
              else all_tiles end

              {keywords, waits_complement}
            _ -> {keywords, waits_complement}
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

  defp _get_waits_and_ukeire(hand, calls, match_definitions, wall, visible_tiles, tile_behavior, skip_tenpai_check) do
    waits = get_waits(hand, calls, match_definitions, MapSet.new(wall), tile_behavior, skip_tenpai_check)
    # remove irrelevant statuses
    |> Utils.remove_attr(["draw", "discard"])
    visible_tiles = Utils.remove_attr(visible_tiles, ["draw", "discard"])
    freqs = Enum.frequencies(wall -- visible_tiles)
    Map.new(waits, fn wait -> {wait, freqs[wait] || 0} end)
  end

  def get_waits_and_ukeire(hand, calls, match_definitions, wall, visible_tiles, tile_behavior, skip_tenpai_check \\ false) do
    case RiichiAdvanced.ETSCache.get({:get_waits_and_ukeire, hand, calls, match_definitions, wall, visible_tiles, TileBehavior.hash(tile_behavior)}) do
      [] -> 
        result = _get_waits_and_ukeire(hand, calls, match_definitions, wall, visible_tiles, tile_behavior, skip_tenpai_check)
        RiichiAdvanced.ETSCache.put({:get_waits_and_ukeire, hand, calls, match_definitions, wall, visible_tiles, TileBehavior.hash(tile_behavior)}, result)
        result
      [result] -> result
    end
  end

  def get_safe_tiles_against(seat, players, turn \\ nil) do
    riichi_safe = if players[seat].cache.riichi_discard_indices != nil do
      for {dir, ix} <- players[seat].cache.riichi_discard_indices do
        discards = Enum.drop(players[dir].discards, ix)
        # last discard is not safe
        if turn == dir do Enum.drop(discards, -1) else discards end
      end |> Enum.concat()
    else [] end
    players[seat].discards ++ riichi_safe |> Utils.strip_attrs() |> Enum.uniq()
  end

  def tile_matches(tile_specs, context) do
    Enum.any?(tile_specs, fn
      "any" -> true
      "same" ->  Utils.same_tile(context.tile, context.tile2, context.players[context.seat].tile_behavior)
      "not_same" -> not Utils.same_tile(context.tile, context.tile2, context.players[context.seat].tile_behavior)
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
      "dora" -> Utils.has_matching_tile?([context.tile], context.doras)
      "kuikae" ->
        player = context.players[context.seat]
        base_tiles = Match.collect_base_tiles(player.hand, player.calls, [0,1,2], player.tile_behavior)
        potential_set = Utils.add_attr(Enum.take(context.call.other_tiles, 2) ++ [context.tile2], ["hand"])
        triplet = Match.remove_group(potential_set, [], [0,0,0], base_tiles, player.tile_behavior)
        sequence = Match.remove_group(potential_set, [], [0,1,2], base_tiles, player.tile_behavior)
        not Enum.empty?(triplet ++ sequence)
      tile_spec ->
        # "1m", "2z" are also specs
        if Utils.is_tile(tile_spec) do
          Utils.same_tile(context.tile, Utils.to_tile(tile_spec))
        else
          IO.puts("Unhandled tile spec #{inspect(tile_spec)}")
          true
        end
    end)
  end
  def tile_matches_all(tile_specs, context) do
    Enum.all?(tile_specs, &tile_matches([&1], context))
  end

  # given a 14-tile hand, and match definitions for 13-tile hands,
  # return all the (unique) tiles that are not needed for all match definitions
  def get_unneeded_tiles(hand, calls, match_definitions, tile_behavior) do
    # t = System.os_time(:millisecond)
    tile_behavior = Match.filter_irrelevant_tile_aliases(tile_behavior, hand ++ Enum.flat_map(calls, &Utils.call_to_tiles/1))

    match_definitions = for match_definition <- match_definitions do
      # filter out lookaheads from match definition
      match_definition = Enum.filter(match_definition, fn match_definition_elem -> is_binary(match_definition_elem) or with [_groups, num] <- match_definition_elem do num > 0 end end)
      # add exhaustive unless unique
      if "unique" not in match_definition and "exhaustive" not in match_definition do ["exhaustive" | match_definition] else match_definition end
    end

    {leftover_tiles, _} = Enum.flat_map(match_definitions, fn match_definition ->
      Match.remove_match_definition(hand, calls, match_definition, tile_behavior)
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

  def needed_for_hand(hand, calls, tile, match_definitions, tile_behavior) do
    tile not in get_unneeded_tiles(hand, calls, match_definitions, tile_behavior)
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
        kyoku >= 0 and kyoku < 2 -> :east
        kyoku >= 2 and kyoku < 4 -> :south
        kyoku >= 4 and kyoku < 6 -> :west
        kyoku >= 6 -> :north
      end
      3 -> cond do
        kyoku >= 0 and kyoku < 3 -> :east
        kyoku >= 3 and kyoku < 6 -> :south
        kyoku >= 6 and kyoku < 9 -> :west
        kyoku >= 9 -> :north
      end
      4 -> cond do
        kyoku >= 0 and kyoku < 4 -> :east
        kyoku >= 4 and kyoku < 8 -> :south
        kyoku >= 8 and kyoku < 12 -> :west
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
    relevant_tile = Utils.call_to_tiles({name, call}) |> Utils.strip_attrs() |> Enum.at(0)
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

  defp calculate_pair_fu(tile, yakuhai, tile_behavior) do
    2 * Utils.count_tiles(yakuhai, [Utils.strip_attrs(tile)], tile_behavior)
  end

  defp _calculate_fu(starting_hand, calls, winning_tile, win_source, yakuhai, tile_behavior, enable_kontsu_fu) do
    # t = System.os_time(:millisecond)

    # IO.puts("Calculating fu for hand: #{inspect(Utils.sort_tiles(starting_hand))} + #{inspect(winning_tile)} and calls #{inspect(calls)}")

    # first put all ton calls back into the hand
    ton_tiles = calls
    |> Enum.filter(fn {name, _call} -> name == "ton" end)
    |> Enum.flat_map(&Utils.call_to_tiles/1)
    
    starting_hand = starting_hand ++ ton_tiles |> Utils.strip_attrs()
    winning_tiles = Utils.apply_tile_aliases([winning_tile], tile_behavior) |> Utils.strip_attrs()

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
      prev = Map.get(tile_behavior.ordering_r, tile, nil)
      prev2 = Map.get(tile_behavior.ordering_r, prev, nil)
      penchan_l_possible = prev2 != nil and not Map.has_key?(tile_behavior.ordering_r, prev2)
      next = Map.get(tile_behavior.ordering, tile, nil)
      next2 = Map.get(tile_behavior.ordering, next, nil)
      penchan_r_possible = next2 != nil and not Map.has_key?(tile_behavior.ordering, next2)
      kanchan_possible = prev != nil and next != nil
      if penchan_l_possible do [[prev, prev2]] else [] end
      ++ if penchan_r_possible do [[next, next2]] else [] end
      ++ if kanchan_possible do [[prev, next]] else [] end
    end)
    |> Enum.flat_map(&Match.try_remove_all_tiles(starting_hand, &1, tile_behavior))
    |> Enum.map(&{&1, fu+2})

    # add all hands with winning ryanmen removed, associated with fu = fu
    possible_left_ryanmen_removed = Enum.flat_map(winning_tiles, fn winning_tile ->
      if Match.offset_tile(winning_tile, -3, tile_behavior) != nil do
        Match.try_remove_all_tiles(starting_hand, [Match.offset_tile(winning_tile, -2, tile_behavior), Match.offset_tile(winning_tile, -1, tile_behavior)], tile_behavior)
        |> Enum.map(fn hand -> {hand, fu+(if enable_kontsu_fu and Match.offset_tile(winning_tile, 10, tile_behavior) == nil do (if win_source == :draw do 4 else 2 end) else 0 end)} end)
      else [] end
    end)
    possible_right_ryanmen_removed = Enum.flat_map(winning_tiles, fn winning_tile ->
      if Match.offset_tile(winning_tile, 3, tile_behavior) != nil do
        Match.try_remove_all_tiles(starting_hand, [Match.offset_tile(winning_tile, 1, tile_behavior), Match.offset_tile(winning_tile, 2, tile_behavior)], tile_behavior)
        |> Enum.map(fn hand -> {hand, fu+(if enable_kontsu_fu and Match.offset_tile(winning_tile, 10, tile_behavior) == nil do (if win_source == :draw do 4 else 2 end) else 0 end)} end)
      else [] end
    end)

    # add all hands with winning kontsu removed, associated with fu = fu+1,2,4 (depending on kontsu)
    possible_kontsu_removed = if enable_kontsu_fu do
      Enum.flat_map(winning_tiles, fn winning_tile ->
        Match.try_remove_all_tiles(starting_hand, [Match.offset_tile(winning_tile, 10, tile_behavior), Match.offset_tile(winning_tile, 20, tile_behavior)], tile_behavior)
        |> Enum.map(fn hand -> {hand, fu+((if win_source == :draw do 2 else 1 end)*(if winning_tile in @terminal_honors do 2 else 1 end))} end)
      end)
    else [] end

    # all the {hand, fu}s together
    hands_fu = possible_penchan_kanchan_removed ++ possible_left_ryanmen_removed ++ possible_right_ryanmen_removed ++ possible_kontsu_removed ++ [{starting_hand, fu}]

    # from these, remove all triplets and add the according amount of closed triplet fu
    hands_fu = for _ <- 1..4, reduce: hands_fu do
      all_hands ->
        Enum.flat_map(all_hands, fn {hand, fu} ->
          hand |> Enum.uniq() |> Utils.apply_tile_aliases(tile_behavior) |> Enum.flat_map(fn base_tile ->
            case Match.try_remove_all_tiles(hand, [base_tile, base_tile, base_tile], tile_behavior) do
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
            {honors, suited} = hand |> Enum.uniq() |> Utils.apply_tile_aliases(tile_behavior)
            |> Enum.split_with(fn base_tile -> Match.offset_tile(base_tile, 10, tile_behavior) == nil end)
            # remove suited kontsu
            suited_hands_fu = Enum.flat_map(suited, fn base_tile ->
              case Match.try_remove_all_tiles(hand, [base_tile, Match.offset_tile(base_tile, 10, tile_behavior), Match.offset_tile(base_tile, 20, tile_behavior)], tile_behavior) do
                [] -> [{hand, fu}]
                removed -> Enum.map(removed, fn hand -> {hand, fu + if base_tile in @terminal_honors do 4 else 2 end} end)
              end
            end)
            # remove honor kontsu
            honors_hands_fu = Enum.flat_map(honors, fn base_tile ->
              case Match.try_remove_all_tiles(hand, [Match.offset_tile(base_tile, -1, tile_behavior), base_tile, Match.offset_tile(base_tile, 1, tile_behavior)], tile_behavior) do
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
          sequence_tiles = hand |> Enum.uniq() |> Utils.apply_tile_aliases(tile_behavior)
          sequence_tiles = if enable_kontsu_fu do
            # honor sequences are considered mixed triplets, ignore them
            Enum.reject(sequence_tiles, fn base_tile -> Match.offset_tile(base_tile, 10, tile_behavior) == nil end)
          else sequence_tiles end
          sequence_tiles |> Enum.flat_map(fn base_tile -> 
            case Match.try_remove_all_tiles(hand, [Match.offset_tile(base_tile, -1, tile_behavior), base_tile, Match.offset_tile(base_tile, 1, tile_behavior)], tile_behavior) do
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
        length(hand) == 1 and Utils.has_matching_tile?(hand, winning_tiles, tile_behavior) -> [fu + 2 + calculate_pair_fu(Enum.at(hand, 0), yakuhai, tile_behavior)]
        length(hand) == 2 and num_pairs == 1 -> [fu + calculate_pair_fu(Enum.at(hand, 0), yakuhai, tile_behavior)]
        length(hand) == 4 and num_pairs == 2 ->
          [tile1, tile2] = Enum.uniq(hand)
          tile1_fu = fu + calculate_pair_fu(tile2, yakuhai, tile_behavior) + (if tile1 in @terminal_honors do 4 else 2 end * if win_source == :draw do 2 else 1 end)
          tile2_fu = fu + calculate_pair_fu(tile1, yakuhai, tile_behavior) + (if tile2 in @terminal_honors do 4 else 2 end * if win_source == :draw do 2 else 1 end)
          if Utils.count_tiles([tile1], winning_tiles, tile_behavior) == 1 do [tile1_fu] else [] end
          ++ if Utils.count_tiles([tile2], winning_tiles, tile_behavior) == 1 do [tile2_fu] else [] end
        # cosmic hand
        enable_kontsu_fu and length(hand) == 4 and num_pairs == 1 ->
          {pair_tile, _freq} = Enum.frequencies(hand) |> Enum.find(fn {_tile, freq} -> freq == 2 end)
          [mixed1, _mixed2] = hand -- [pair_tile, pair_tile]
          pair_fu = calculate_pair_fu(pair_tile, yakuhai, tile_behavior)
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
      case Match.try_remove_all_tiles(starting_hand ++ [winning_tile], kokushi_tiles, tile_behavior) do
        [] -> [fu]
        _  -> [if win_source == :draw do 30 else 40 end]
      end
    end) |> Enum.max()

    # IO.inspect(fu)

    num_pairs = Match.binary_search_count_matches([{starting_hand, []}], [[[[[0, 0]], 1]]], tile_behavior)
    ret = cond do
      fu == 22 and win_source == :draw and is_closed_hand -> 20 # closed pinfu tsumo
      fu == 30 and win_source != :draw and is_closed_hand -> 30 # closed pinfu ron
      fu == 20 and not is_closed_hand                     -> 30 # open pinfu
      Enum.empty?(fus) and num_pairs == 6                 -> 25 # chiitoitsu
      Enum.empty?(fus) and num_pairs == 5                 -> 30 # kakura kurumi (saki card)
      true                                                ->
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

  def calculate_fu(starting_hand, calls, winning_tile, win_source, yakuhai, tile_behavior, enable_kontsu_fu \\ false) do
    case RiichiAdvanced.ETSCache.get({:calculate_fu, starting_hand, calls, winning_tile, win_source, yakuhai, TileBehavior.hash(tile_behavior), enable_kontsu_fu}) do
      [] -> 
        result = _calculate_fu(starting_hand, calls, winning_tile, win_source, yakuhai, tile_behavior, enable_kontsu_fu)
        RiichiAdvanced.ETSCache.put({:calculate_fu, starting_hand, calls, winning_tile, win_source, yakuhai, TileBehavior.hash(tile_behavior), enable_kontsu_fu}, result)
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
    oya_payment = trunc(Float.round(2 * score / divisor / han_fu_rounding_factor) * han_fu_rounding_factor)
    # oya_payment is only relevant if is_dealer is false
    # (it is just double ko payment if is_dealer is true, which is useless)
    {ko_payment, oya_payment}
  end

  # TODO take in wall
  def count_ukeire(waits, hand, visible_ponds, visible_calls, winning_tile, tile_behavior) do
    all_tiles = hand ++ visible_ponds ++ Enum.flat_map(visible_calls, &Utils.call_to_tiles/1) -- [winning_tile]
    waits
    |> Enum.map(fn wait -> 4 - Utils.count_tiles(all_tiles, [wait], tile_behavior) end)
    |> Enum.sum()
  end

  def test_tiles(hand, tiles, tile_behavior) do
    not Enum.empty?(Match.try_remove_all_tiles(hand, tiles, tile_behavior))
  end

  def get_disconnected_tiles(hand, tile_behavior) do
    hand
    |> Enum.uniq()
    |> Enum.filter(fn tile ->
      cond do
        Utils.count_tiles(hand, [tile], tile_behavior) >= 2 -> false
        Utils.count_tiles(hand, [Utils.strip_attrs(tile)], tile_behavior) >= 2 -> false
        is_jihai?(tile) -> true
        true ->
          past_suji_left = test_tiles(hand, [Match.offset_tile(tile, -4, tile_behavior), tile], tile_behavior)
          suji_left = test_tiles(hand, [Match.offset_tile(tile, -3, tile_behavior), tile], tile_behavior)
          jump_left = test_tiles(hand, [Match.offset_tile(tile, -2, tile_behavior), tile], tile_behavior)
          adjacent_left = test_tiles(hand, [Match.offset_tile(tile, -1, tile_behavior), tile], tile_behavior)
          adjacent_right = test_tiles(hand, [Match.offset_tile(tile, 1, tile_behavior), tile], tile_behavior)
          jump_right = test_tiles(hand, [Match.offset_tile(tile, 2, tile_behavior), tile], tile_behavior)
          suji_right = test_tiles(hand, [Match.offset_tile(tile, 3, tile_behavior), tile], tile_behavior)
          past_suji_right = test_tiles(hand, [Match.offset_tile(tile, 4, tile_behavior), tile], tile_behavior)
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
      true             -> 0
    end
  end

  def genbutsu_to_suji(genbutsu, tile_behavior) do
    Enum.flat_map(genbutsu, &cond do
      Enum.any?([1,2,3], fn k -> is_num?(&1, k) end) -> if Match.offset_tile(&1, 6, tile_behavior) in genbutsu do [Match.offset_tile(&1, 3, tile_behavior)] else [] end
      Enum.any?([4,5,6], fn k -> is_num?(&1, k) end) -> [Match.offset_tile(&1, -3, tile_behavior), Match.offset_tile(&1, 3, tile_behavior)]
      Enum.any?([7,8,9], fn k -> is_num?(&1, k) end) -> if Match.offset_tile(&1, -6, tile_behavior) in genbutsu do [Match.offset_tile(&1, -3, tile_behavior)] else [] end
      true -> []
    end)
  end

end
