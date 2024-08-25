defmodule Riichi do

  @pred %{:"2m"=>:"1m", :"3m"=>:"2m", :"4m"=>:"3m", :"5m"=>:"4m", :"6m"=>:"5m", :"7m"=>:"6m", :"8m"=>:"7m", :"9m"=>:"8m", :"0m"=>:"4m",
          :"2p"=>:"1p", :"3p"=>:"2p", :"4p"=>:"3p", :"5p"=>:"4p", :"6p"=>:"5p", :"7p"=>:"6p", :"8p"=>:"7p", :"9p"=>:"8p", :"0p"=>:"4p",
          :"2s"=>:"1s", :"3s"=>:"2s", :"4s"=>:"3s", :"5s"=>:"4s", :"6s"=>:"5s", :"7s"=>:"6s", :"8s"=>:"7s", :"9s"=>:"8s", :"0s"=>:"4s"}
  def pred(tile), do: @pred[tile]

  @succ %{:"1m"=>:"2m", :"2m"=>:"3m", :"3m"=>:"4m", :"4m"=>:"5m", :"5m"=>:"6m", :"6m"=>:"7m", :"7m"=>:"8m", :"8m"=>:"9m", :"0m"=>:"6m",
          :"1p"=>:"2p", :"2p"=>:"3p", :"3p"=>:"4p", :"4p"=>:"5p", :"5p"=>:"6p", :"6p"=>:"7p", :"7p"=>:"8p", :"8p"=>:"9p", :"0p"=>:"6p",
          :"1s"=>:"2s", :"2s"=>:"3s", :"3s"=>:"4s", :"4s"=>:"5s", :"5s"=>:"6s", :"6s"=>:"7s", :"7s"=>:"8s", :"8s"=>:"9s", :"0s"=>:"6s"}
  def succ(tile), do: @succ[tile]

  @dora %{:"1m"=>:"2m", :"2m"=>:"3m", :"3m"=>:"4m", :"4m"=>:"5m", :"5m"=>:"6m", :"6m"=>:"7m", :"7m"=>:"8m", :"8m"=>:"9m", :"9m"=>:"1m", :"0m"=>:"6m",
          :"1p"=>:"2p", :"2p"=>:"3p", :"3p"=>:"4p", :"4p"=>:"5p", :"5p"=>:"6p", :"6p"=>:"7p", :"7p"=>:"8p", :"8p"=>:"9p", :"9p"=>:"1p", :"0p"=>:"6p",
          :"1s"=>:"2s", :"2s"=>:"3s", :"3s"=>:"4s", :"4s"=>:"5s", :"5s"=>:"6s", :"6s"=>:"7s", :"7s"=>:"8s", :"8s"=>:"9s", :"9s"=>:"1s", :"0s"=>:"6s",
          :"1z"=>:"2z", :"2z"=>:"3z", :"3z"=>:"4z", :"4z"=>:"5z",
          :"5z"=>:"6z", :"6z"=>:"7z", :"7z"=>:"5z"
        }
  def dora(tile), do: @dora[tile]

  @pred_wraps %{:"1m"=>:"9m", :"2m"=>:"1m", :"3m"=>:"2m", :"4m"=>:"3m", :"5m"=>:"4m", :"6m"=>:"5m", :"7m"=>:"6m", :"8m"=>:"7m", :"9m"=>:"8m", :"0m"=>:"4m",
                :"1p"=>:"9p", :"2p"=>:"1p", :"3p"=>:"2p", :"4p"=>:"3p", :"5p"=>:"4p", :"6p"=>:"5p", :"7p"=>:"6p", :"8p"=>:"7p", :"9p"=>:"8p", :"0p"=>:"4p",
                :"1s"=>:"9s", :"2s"=>:"1s", :"3s"=>:"2s", :"4s"=>:"3s", :"5s"=>:"4s", :"6s"=>:"5s", :"7s"=>:"6s", :"8s"=>:"7s", :"9s"=>:"8s", :"0s"=>:"4s"}
  def pred_wraps(tile), do: @pred_wraps[tile]

  @succ_wraps %{:"1m"=>:"2m", :"2m"=>:"3m", :"3m"=>:"4m", :"4m"=>:"5m", :"5m"=>:"6m", :"6m"=>:"7m", :"7m"=>:"8m", :"8m"=>:"9m", :"9m"=>:"1m", :"0m"=>:"6m",
                :"1p"=>:"2p", :"2p"=>:"3p", :"3p"=>:"4p", :"4p"=>:"5p", :"5p"=>:"6p", :"6p"=>:"7p", :"7p"=>:"8p", :"8p"=>:"9p", :"9p"=>:"1p", :"0p"=>:"6p",
                :"1s"=>:"2s", :"2s"=>:"3s", :"3s"=>:"4s", :"4s"=>:"5s", :"5s"=>:"6s", :"6s"=>:"7s", :"7s"=>:"8s", :"8s"=>:"9s", :"9s"=>:"1s", :"0s"=>:"6s"}
  def succ_wraps(tile), do: @succ_wraps[tile]

  @terminal_honors [:"1m",:"9m",:"1p",:"9p",:"1s",:"9s",:"1z",:"2z",:"3z",:"4z",:"5z",:"6z",:"7z"]

  def offset_tile(tile, n, wraps \\ false) do
    if tile != nil do
      if (n < 1 && n > -1) || n < -10 || n > 10 do
        normalize_red_five(tile)
      else
        if n < 0 do
          offset_tile(if wraps do pred_wraps(tile) else pred(tile) end, n+1, wraps)
        else
          offset_tile(if wraps do succ_wraps(tile) else succ(tile) end, n-1, wraps)
        end
      end
    else nil end
  end

  def to_red(tile) do
    case tile do
      :"5m" -> :"0m"
      :"5p" -> :"0p"
      :"5s" -> :"0s"
      _     -> nil
    end
  end

  def normalize_red_five(tile) do
    case tile do
      :"0m" -> :"5m"
      :"0p" -> :"5p"
      :"0s" -> :"5s"
      t    -> t
    end
  end
  def normalize_red_fives(hand), do: Enum.map(hand, &normalize_red_five/1)

  def is_manzu?(tile), do: tile in [:"1m", :"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m", :"9m", :"0m"]
  def is_pinzu?(tile), do: tile in [:"1p", :"2p", :"3p", :"4p", :"5p", :"6p", :"7p", :"8p", :"9p", :"0p"]
  def is_souzu?(tile), do: tile in [:"1s", :"2s", :"3s", :"4s", :"5s", :"6s", :"7s", :"8s", :"9s", :"0s"]
  def is_jihai?(tile), do: tile in [:"1z", :"2z", :"3z", :"4z", :"5z", :"6z", :"7z"]
  def is_suited?(tile), do: is_manzu?(tile) || is_pinzu?(tile) || is_souzu?(tile)
  def is_terminal?(tile), do: tile in [:"1m", :"9m", :"1p", :"9p", :"1s", :"9s"]
  def is_yaochuuhai?(tile), do: tile in [:"1m", :"9m", :"1p", :"9p", :"1s", :"9s", :"1z", :"2z", :"3z", :"4z", :"5z", :"6z", :"7z"]
  def is_tanyaohai?(tile), do: tile not in [:"1m", :"9m", :"1p", :"9p", :"1s", :"9s", :"1z", :"2z", :"3z", :"4z", :"5z", :"6z", :"7z"]
  def is_num?(tile, num) do
    tile in case num do
      1 -> [:"1m", :"1p", :"1s"]
      2 -> [:"2m", :"2p", :"2s"]
      3 -> [:"3m", :"3p", :"3s"]
      4 -> [:"4m", :"4p", :"4s"]
      5 -> [:"5m", :"5p", :"5s", :"0m", :"0p", :"0s"]
      6 -> [:"6m", :"6p", :"6s"]
      7 -> [:"7m", :"7p", :"7s"]
      8 -> [:"8m", :"8p", :"8s"]
      9 -> [:"9m", :"9p", :"9s"]
    end
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

  # return all possible calls of each tile in called_tiles, given hand
  # includes returning multiple choices for red fives
  # if called_tiles is an empty list, then we choose from our hand
  # example: %{:"5m" => [[:"4m", :"6m"], [:"6m", :"7m"]]}
  def make_calls(calls_spec, hand, called_tiles \\ [], wraps \\ false) do
    # IO.puts("#{inspect(calls_spec)} / #{inspect(hand)} / #{inspect(called_tiles)}")
    from_hand = Enum.empty?(called_tiles)
    call_choices = if from_hand do hand else called_tiles end
    Map.new(call_choices, fn tile ->
      {tile, Enum.flat_map(calls_spec, fn call_spec ->
        hand = if from_hand do List.delete(hand, tile) else hand end
        other_tiles = Enum.map(call_spec, &offset_tile(tile, &1, wraps))
        {_, choices} = Enum.reduce(other_tiles, {hand, []}, fn t, {remaining_hand, tiles} ->
          exists = Enum.member?(remaining_hand, t)
          red_exists = Enum.member?(remaining_hand, to_red(t))
          {List.delete(remaining_hand, if red_exists do to_red(t) else t end),
           [(if exists do [t] else [] end) ++ (if red_exists do [to_red(t)] else [] end) | tiles]}
        end)
        # take the cartesian product of tile choices to get all choice sets
        result = choices
               |> Enum.reduce([[]], fn cs, accs -> for choice <- cs, acc <- accs, do: acc ++ [choice] end)
               |> Enum.map(fn tiles -> Utils.sort_tiles(tiles) end)
               |> Enum.uniq()
        result
      end)}
    end)
  end

  def can_call?(calls_spec, hand, called_tiles \\ [], wraps \\ false), do: Enum.any?(make_calls(calls_spec, hand, called_tiles, wraps), fn {_tile, choices} -> not Enum.empty?(choices) end)

  def try_remove_all_tiles(hand, tiles) do
    removed = hand -- tiles
    if length(removed) + length(tiles) == length(hand) do [removed] else [] end
  end

  def try_remove_all_tiles(hand, tiles, calls) do
    removed = hand -- tiles
    from_hand = if length(removed) + length(tiles) == length(hand) do [{removed, calls}] else [] end
    matching_indices = calls |> Enum.map(&call_to_tiles/1) |> Enum.with_index() |> Enum.flat_map(fn {call, i} ->
      case try_remove_all_tiles(call, tiles) do
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

  def remove_group(hand, calls, group, wrapping \\ false) do
    # IO.puts("removing group #{inspect(group)} from hand #{inspect(hand)}")
    cond do
      is_list(group) && not Enum.empty?(group) ->
        if Enum.all?(group, fn tile -> Utils.to_tile(tile) != nil end) do
          # list of tiles
          tiles = Enum.map(group, fn tile -> Utils.to_tile(tile) end)
          try_remove_all_tiles(hand, tiles, calls)
        else
          # list of integers specifying a group of tiles
          all_tiles = hand ++ Enum.flat_map(calls, &call_to_tiles/1)
          all_tiles |> Enum.uniq() |> Enum.flat_map(fn base_tile ->
            tiles = Enum.map(group, fn tile_or_offset -> if Utils.to_tile(tile_or_offset) != nil do Utils.to_tile(tile_or_offset) else offset_tile(base_tile, tile_or_offset, wrapping) end end)
            try_remove_all_tiles(hand, tiles, calls)
          end)
        end
      # tile
      Utils.to_tile(group) != nil -> 
        if Enum.member?(hand, Utils.to_tile(group)) do
          [{List.delete(hand, Utils.to_tile(group)), calls}]
        else
          []
        end
      # call
      is_binary(group) -> try_remove_call(hand, calls, group)
      true ->
        IO.puts("Unhandled group #{inspect(group)}")
        []
    end
  end

  defp _remove_hand_definition(hand, calls, hand_definition, wrapping) do
    Enum.reduce(hand_definition, [{hand, calls}, {normalize_red_fives(hand), calls}], fn [groups, num], all_hands ->
      Enum.reduce(1..num, all_hands, fn _, hands ->
        for {hand, calls} <- hands, group <- groups do
          remove_group(hand, calls, group, wrapping)
        end |> Enum.concat()
      end) |> Enum.uniq_by(fn {hand, calls} -> {Enum.sort(hand), calls} end)
    end)
  end

  def remove_hand_definition(hand, calls, hand_definition, wrapping \\ false) do
    # calls = Enum.map(calls, fn {name, call} -> {name, Enum.map(call, fn {tile, _sideways} -> tile end)} end)
    case RiichiAdvanced.ETSCache.get({:remove_hand_definition, hand, calls, hand_definition, wrapping}) do
      [] -> 
        result = _remove_hand_definition(hand, calls, hand_definition, wrapping)
        RiichiAdvanced.ETSCache.put({:remove_hand_definition, hand, calls, hand_definition, wrapping}, result)
        # IO.puts("Results:\n  hand: #{inspect(hand)}\n  result: #{inspect(result)}")
        result
      [result] -> result
    end
  end

  # check if hand contains all groups in each definition in hand_definitions
  defp _check_hand(hand, calls, hand_definitions, wrapping) do
    Enum.any?(hand_definitions, fn hand_definition -> not Enum.empty?(remove_hand_definition(hand, calls, hand_definition, wrapping)) end)
  end

  def check_hand(hand, calls, hand_definitions, wrapping \\ false) do
    case RiichiAdvanced.ETSCache.get({:check_hand, hand, calls, hand_definitions, wrapping}) do
      [] -> 
        result = _check_hand(hand, calls, hand_definitions, wrapping)
        RiichiAdvanced.ETSCache.put({:check_hand, hand, calls, hand_definitions, wrapping}, result)
        # IO.puts("Results:\n  hand: #{inspect(hand)}\n  hand_definitions: #{inspect(hand_definitions)}\n  result: #{inspect(result)}")
        result
      [result] -> result
    end
  end

  def match_hand(hand, calls, match_definitions, wrapping \\ false) do
    # TODO replace check_hand
    check_hand(hand, calls, match_definitions, wrapping)
  end

  # only keeps one version of the hand (assumes groups don't overlap)
  defp remove_hand_definition_simple(hand, calls, hand_definition) do
    Enum.reduce(hand_definition, [{hand, calls}], fn [groups, num], hand_calls ->
      Enum.reduce(1..num, hand_calls, fn _, hand_calls ->
        case hand_calls do
          [{hand, calls}] -> for group <- groups do
            remove_group(hand, calls, group)
          end |> Enum.concat() |> Enum.take(1)
          [] -> []
        end
      end)
    end)
  end

  def match_hand_simple(hand, calls, match_definitions) do
    Enum.any?(match_definitions, fn match_definition ->
      removed = remove_hand_definition_simple(hand, calls, match_definition)
      removed2 = remove_hand_definition_simple(normalize_red_fives(hand), calls, match_definition)
      not Enum.empty?(removed ++ removed2)
    end)
  end

  def tile_matches(tile_specs, context) do
    Enum.any?(tile_specs, &case &1 do
      "any" -> true
      "same" -> normalize_red_five(context.tile) == normalize_red_five(context.tile2)
      "not_same" -> normalize_red_five(context.tile) != normalize_red_five(context.tile2)
      "manzu" -> is_manzu?(context.tile)
      "pinzu" -> is_pinzu?(context.tile)
      "souzu" -> is_souzu?(context.tile)
      "jihai" -> is_jihai?(context.tile)
      "terminal" -> is_terminal?(context.tile)
      "yaochuuhai" -> is_yaochuuhai?(context.tile)
      "tanyaohai" -> is_tanyaohai?(context.tile)
      "1" -> is_num?(context.tile, 1)
      "2" -> is_num?(context.tile, 2)
      "3" -> is_num?(context.tile, 3)
      "4" -> is_num?(context.tile, 4)
      "5" -> is_num?(context.tile, 5)
      "6" -> is_num?(context.tile, 6)
      "7" -> is_num?(context.tile, 7)
      "8" -> is_num?(context.tile, 8)
      "9" -> is_num?(context.tile, 9)
      "not_kuikae" ->
        tiles_called = normalize_red_fives(context.call.other_tiles)
        case tiles_called do
          [tile1, tile2] ->
            cond do
              succ(tile1) == tile2 && context.tile == pred(tile1) -> context.tile2 != succ(tile2)
              succ(tile1) == tile2 && context.tile == succ(tile2) -> context.tile2 != pred(tile1)
              true -> true
            end
          _ -> true
        end
      _   ->
        # "1m", "2z" are also specs
        if Utils.to_tile(&1) != nil do
          context.tile == Utils.to_tile(&1)
        else
          IO.puts("Unhandled tile spec #{inspect(&1)}")
          true
        end
    end)
  end

  def not_needed_for_hand(hand, calls, tile, hand_definitions) do
    Enum.any?(hand_definitions, fn hand_definition ->
      removed = remove_hand_definition(hand, calls, hand_definition)
      normalize_red_five(tile) in Enum.concat(Enum.map(removed, fn {hand, _calls} -> hand end))
    end)
  end

  def call_to_tiles({_name, call}) do
    if {:"1x", false} in call do
      # TODO support more than just ankan
      {red, _} = Enum.at(call, 1)
      {nored, _} = Enum.at(call, 2)
      [red, nored, nored, nored]
    else
      Enum.map(call, fn {tile, _sideways} -> tile end)
    end
  end

  def get_round_wind(kyoku) do
    cond do
      kyoku >= 0 && kyoku < 4 -> :east
      kyoku >= 4 && kyoku < 8 -> :south
      kyoku >= 8 && kyoku < 12 -> :west
      kyoku >= 12 -> :north
    end
  end

  def get_seat_wind(kyoku, seat) do
    Utils.prev_turn(seat, rem(kyoku, 4))
  end

  def get_player_from_seat_wind(kyoku, wind) do
    Utils.next_turn(wind, rem(kyoku, 4))
  end

  def get_east_player_seat(kyoku) do
    Utils.next_turn(:east, rem(kyoku, 4))
  end

  def get_seat_scoring_offset(kyoku, seat) do
    case get_seat_wind(kyoku, seat) do
      :east  -> 3
      :south -> 2
      :west  -> 1
      :north -> 0
    end
  end

  defp calculate_call_fu({name, call}) do
    {relevant_tile, _sideways} = Enum.at(call, 1) # avoids the initial 1x from ankan
    case name do
      "chii"  -> 0
      "pon"   -> if relevant_tile in @terminal_honors do 4 else 2 end
      "ankan" -> if relevant_tile in @terminal_honors do 32 else 16 end
      _       -> if relevant_tile in @terminal_honors do 16 else 8 end
    end
  end

  defp calculate_pair_fu(tile, seat_wind, round_wind) do
    fu = case tile do
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

  def calculate_fu(starting_hand, calls, winning_tile, win_source, seat_wind, round_wind) do
    starting_hand = normalize_red_fives(starting_hand)
    winning_tile = normalize_red_five(winning_tile)
    num_pairs = Enum.frequencies(starting_hand ++ [winning_tile]) |> Map.values |> Enum.count(& &1 == 2)
    # initial fu
    fu = case win_source do
      :draw -> 22
      _     -> if Enum.all?(calls, fn {name, _call} -> name == "ankan" end) do 30 else 20 end
    end

    # add called triplets
    fu = fu + (Enum.map(calls, &calculate_call_fu/1) |> Enum.sum)

    possible_penchan_removed = case winning_tile do
      :"3m" -> try_remove_all_tiles(starting_hand, [:"1m", :"2m"])
      :"7m" -> try_remove_all_tiles(starting_hand, [:"8m", :"9m"])
      :"3p" -> try_remove_all_tiles(starting_hand, [:"1p", :"2p"])
      :"7p" -> try_remove_all_tiles(starting_hand, [:"8p", :"9p"])
      :"3s" -> try_remove_all_tiles(starting_hand, [:"1s", :"2s"])
      :"7s" -> try_remove_all_tiles(starting_hand, [:"8s", :"9s"])
      _     -> []
    end
    possible_penchan_removed = case possible_penchan_removed do
      [] -> []
      [removed] -> [{removed, fu + 2}]
    end
    tanyao_tiles = [:"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m", :"2p", :"3p", :"4p", :"5p", :"6p", :"7p", :"8p", :"2s", :"3s", :"4s", :"5s", :"6s", :"7s", :"8s"]
    possible_kanchan_removed = if winning_tile in tanyao_tiles do
      case try_remove_all_tiles(starting_hand, [pred_wraps(winning_tile), succ_wraps(winning_tile)]) do
        [] -> []
        [removed] -> [{removed, fu + 2}]
      end
    else [] end
    possible_left_ryanmen_removed = if offset_tile(winning_tile, -3, true) != nil do
      case try_remove_all_tiles(starting_hand, [pred_wraps(pred_wraps(winning_tile)), pred_wraps(winning_tile)]) do
        [] -> []
        [removed] -> [{removed, fu}]
      end
    else [] end
    possible_right_ryanmen_removed = if offset_tile(winning_tile, 3, true) != nil do
      case try_remove_all_tiles(starting_hand, [succ_wraps(winning_tile), succ_wraps(succ_wraps(winning_tile))]) do
        [] -> []
        [removed] -> [{removed, fu}]
      end
    else [] end
    hands_fu = possible_penchan_removed ++ possible_kanchan_removed ++ possible_left_ryanmen_removed ++ possible_right_ryanmen_removed ++ [{starting_hand, fu}]

    # from these hands, remove all triplets and add the according amount of closed triplet fu
    hands_fu = for _ <- 1..4, reduce: hands_fu do
      all_hands ->
        Enum.flat_map(all_hands, fn {hand, fu} ->
          hand |> Enum.uniq() |> Enum.flat_map(fn base_tile ->
            case try_remove_all_tiles(hand, [base_tile, base_tile, base_tile]) do
              [] -> [{hand, fu}]
              [removed] -> [{removed, fu + if base_tile in @terminal_honors do 8 else 4 end}]
            end
          end) |> Enum.uniq()
        end) |> Enum.uniq()
    end

    # now remove all sequences (no increase in fu)
    hands_fu = for _ <- 1..4, reduce: hands_fu do
      all_hands ->
        Enum.flat_map(all_hands, fn {hand, fu} ->
          hand |> Enum.uniq() |> Enum.flat_map(fn base_tile -> 
            case try_remove_all_tiles(hand, [pred_wraps(base_tile), base_tile, succ_wraps(base_tile)]) do
              [] -> [{hand, fu}]
              [removed] -> [{removed, fu}]
            end
          end)
        end) |> Enum.uniq()
    end

    # only valid hands should either have:
    # - one tile remaining (tanki)
    # - one pair remaining (standard)
    # - two pairs remaining (shanpon)
    fus = Enum.flat_map(hands_fu, fn {hand, fu} ->
      num_pairs = Enum.frequencies(hand) |> Map.values |> Enum.count(& &1 == 2)
      cond do
        length(hand) == 1 && Enum.at(hand, 0) == winning_tile -> [fu + 2 + calculate_pair_fu(Enum.at(hand, 0), seat_wind, round_wind)]
        length(hand) == 2 && num_pairs == 1                   -> [fu + calculate_pair_fu(Enum.at(hand, 0), seat_wind, round_wind)]
        length(hand) == 4 && num_pairs == 2                   ->
          [tile1, tile2] = Enum.uniq(hand)
          if tile1 == winning_tile do
            [fu + calculate_pair_fu(tile2, seat_wind, round_wind) + (if tile1 in @terminal_honors do 4 else 2 end * if win_source == :draw do 2 else 1 end)]
          else
            [fu + calculate_pair_fu(tile1, seat_wind, round_wind) + (if tile2 in @terminal_honors do 4 else 2 end * if win_source == :draw do 2 else 1 end)]
          end
        true                                                  -> []
      end
    end)
    fu = if Enum.empty?(fus) do 0 else Enum.max(fus) end

    # if we can get (closed) pinfu, we should
    closed_pinfu_fu = if win_source == :draw do 22 else 30 end
    fu = if closed_pinfu_fu in fus do closed_pinfu_fu else fu end

    # IO.inspect(fu)

    # closed pinfu is 20 tsumo/30 ron, open pinfu is 30, chiitoitsu is 25
    cond do
      fu == 22 && win_source == :draw && Enum.empty?(calls) -> 20
      fu == 30 && win_source != :draw && Enum.empty?(calls) -> 30
      fu == 20 && not Enum.empty?(calls)                    -> 30
      Enum.empty?(fus) && num_pairs == 7                    -> 25
      true                                                  ->
        # round up to nearest 10
        remainder = rem(fu, 10)
        if remainder == 0 do fu else fu - remainder + 10 end
    end
  end

  def calc_ko_oya_points(score, is_dealer) do
    divisor = if is_dealer do 3 else 4 end
    ko_payment = trunc(Float.round(score / divisor / 100) * 100)
    num_ko_payers = if is_dealer do 3 else 2 end
    oya_payment = score - num_ko_payers * ko_payment
    {ko_payment, oya_payment}
  end

end
