defmodule RiichiAdvanced.GameState.American do
  alias RiichiAdvanced.GameState.Buttons, as: Buttons
  alias RiichiAdvanced.GameState.Debug, as: Debug
  alias RiichiAdvanced.GameState.Player, as: Player
  alias RiichiAdvanced.GameState.TileBehavior, as: TileBehavior
  alias RiichiAdvanced.Match, as: Match
  alias RiichiAdvanced.Utils, as: Utils
  import RiichiAdvanced.GameState

  # each american match definition is a string, like
  # "FF 3333a 6666b 9999c"
  # translated to match definitions this becomes something like
  # [
  #   [[[[["3m","3m","3m","3m"]], 1], [[["6p","6p","6p","6p"]], 1], [[["9s","9s","9s","9s"]], 1], "nojoker", ["1f","2f","3f","4f","1g","2g","3g","4g"], 2]],
  #   [[[[["3m","3m","3m","3m"]], 1], [[["6s","6s","6s","6s"]], 1], [[["9p","9p","9p","9p"]], 1], "nojoker", ["1f","2f","3f","4f","1g","2g","3g","4g"], 2]],
  #   [[[[["3p","3p","3p","3p"]], 1], [[["6m","6m","6m","6m"]], 1], [[["9s","9s","9s","9s"]], 1], "nojoker", ["1f","2f","3f","4f","1g","2g","3g","4g"], 2]],
  #   [[[[["3p","3p","3p","3p"]], 1], [[["6s","6s","6s","6s"]], 1], [[["9m","9m","9m","9m"]], 1], "nojoker", ["1f","2f","3f","4f","1g","2g","3g","4g"], 2]],
  #   [[[[["3s","3s","3s","3s"]], 1], [[["6m","6m","6m","6m"]], 1], [[["9p","9p","9p","9p"]], 1], "nojoker", ["1f","2f","3f","4f","1g","2g","3g","4g"], 2]],
  #   [[[[["3s","3s","3s","3s"]], 1], [[["6p","6p","6p","6p"]], 1], [[["9m","9m","9m","9m"]], 1], "nojoker", ["1f","2f","3f","4f","1g","2g","3g","4g"], 2]]
  # ]
  defp preprocess_american_match_definition(am_match_definition) do
    # e.g. "FF 2024a 2222b 2222c" becomes
    # [
    #   {:unsuited, [["1f", "2f", "3f", "4f", "1g", "2g", "3g", "4g"], 2]},
    #   {:a, ["2", "0", "2", "4"]},
    #   {:b, ["2", "2", "2", "2"]},
    #   {:c, ["2", "2", "2", "2"]}
    # ]
    for group <- String.split(am_match_definition), reduce: [] do
      result ->
        t = String.first(group)
        cond do
          # unsuited groups include F (flowers), Z (winds), 0 (5z), and any wind group (NNN, NEWS, EW, etc)
          # the rest (1-9, D (dragons), X (relative)) are suited
          t in ["F", "Z", "0", "R", "G", "N", "E", "W", "S"] ->
            # unsuited group
            groups = for {c, freq} <- group |> String.graphemes() |> Enum.frequencies() do
              case c do
                "F" -> [[["unique","1f","2f","3f","4f","1g","2g","3g","4g"], freq]]
                # below we use List.duplicate so that they can match calls
                "Z" -> [[[List.duplicate("1z", freq),List.duplicate("2z", freq),List.duplicate("3z", freq),List.duplicate("4z", freq)], 1]]
                "0" -> [[[List.duplicate("0z", freq)], 1]]
                "R" -> [[[List.duplicate("7z", freq)], 1]]
                "G" -> [[[List.duplicate("6z", freq)], 1]]
                "N" -> [[[List.duplicate("4z", freq)], 1]]
                "E" -> [[[List.duplicate("1z", freq)], 1]]
                "W" -> [[[List.duplicate("3z", freq)], 1]]
                "S" -> [[[List.duplicate("2z", freq)], 1]]
                _   -> 
                  IO.inspect("Unknown character #{inspect(c)} in unsuited group #{inspect(group)}")
                  []
              end
            end |> Enum.concat()            
            result ++ Enum.map(groups, &{:unsuited, &1})
          t in ["1", "2", "3", "4", "5", "6", "7", "8", "9", "D"] ->
            suit = case String.last(group) do
              "a" -> :a
              "b" -> :b
              "c" -> :c
            end
            tiles = group |> String.graphemes() |> Enum.drop(-1)
            result ++ [{suit, tiles}]
          t == "X" ->
            suit = case String.last(group) do
              "a" -> :a
              "b" -> :b
              "c" -> :c
            end
            num = group |> String.graphemes() |> Enum.drop(-2) |> length()
            shift = String.slice(group, -2, 1) |> String.to_integer()
            result ++ [{suit, List.duplicate(shift, num)}]
        end
    end
  end
  defp translate_american_match_definitions_suits(groups, suit) do
    if suit != nil do
      for group <- groups do
        Enum.map(group, fn tile ->
          cond do
            is_integer(tile) and suit == "A" -> tile + 0
            is_integer(tile) and suit == "B" -> tile + 10
            is_integer(tile) and suit == "C" -> tile + 20
            tile == "D" -> "D" <> suit
            tile == "R" -> "7z"
            tile == "G" -> "6z"
            tile == "0" -> "0z"
            true -> tile <> suit
          end
        end)
      end
    else [] end
  end

  defp translate_american_match_definitions_postprocess({am_match_definition, match_definition}) do
    # move all single-tile, mixed-tile, and pair groups to the end, separated by a "nojoker" tag
    {use_jokers, nojokers} = Enum.split_with(match_definition, fn [groups, num] ->
      num_tiles = cond do
        is_list(groups) and Enum.all?(groups, &is_list(&1) or &1 in Match.group_keywords()) ->
          groups
          |> Enum.reject(& &1 in Match.group_keywords())
          |> Enum.map(&cond do
            Enum.all?(&1, fn subgroup -> is_list(subgroup) end) -> length(Enum.at(&1, 0))
            Enum.all?(&1, fn tile -> tile == Enum.at(&1, 0) end) -> length(&1)
            true -> 1
          end)
          |> Enum.max()
        true -> num
      end
      num_tiles >= 3
    end)

    nojokers = if Enum.empty?(nojokers) do [] else ["nojoker"] ++ nojokers end

    # add "nojokers" for unique groups as well
    use_jokers = Enum.map(use_jokers, fn [groups, num] ->
      cond do
        is_list(groups) and "unique" in groups ->
          {keywords, groups} = Enum.split_with(groups, & &1 in Match.group_keywords())
          {jokers, nojokers} = if groups == ["1f", "2f", "3f", "4f", "1g", "2g", "3g", "4g"] do
            # flowers are treated specially
            if num >= 3 do {groups, []} else {[], groups} end
          else
            {jokers, nojokers} = Enum.split_with(Enum.frequencies(groups), fn {_tile, freq} -> freq >= 3 end)
            jokers = Enum.flat_map(jokers, fn {tile, freq} -> List.duplicate(tile, freq) end)
            nojokers = if Enum.empty?(nojokers) do [] else ["nojoker"] ++ Enum.flat_map(nojokers, fn {tile, freq} -> List.duplicate(tile, freq) end) end
            {jokers, nojokers}
          end
          [keywords ++ jokers ++ nojokers, num]
        true -> [groups, num]
      end
    end)
    
    # note: do NOT add "exhaustive" (game will refuse to start)

    ret = use_jokers ++ nojokers
    if am_match_definition in Debug.debug_am_match_definitions() do
      ["debug"] ++ ret
    else ret end
  end
  defp _translate_american_match_definitions(am_match_definitions) do
    for am_match_definition <- am_match_definitions do
      # e.g. "FF 2024a 2222b 2222c" becomes
      # %{
      #   unsuited: [[["1f", "2f", "3f", "4f", "1g", "2g", "3g", "4g"], 2]],
      #   a: [["2", "0", "2", "4"]],
      #   b: [["2", "2", "2", "2"]],
      #   c: [["2", "2", "2", "2"]]
      # }
      parsed = for {suit, group} <- preprocess_american_match_definition(am_match_definition), reduce: %{unsuited: [], a: [], b: [], c: []} do
        parsed -> Map.update!(parsed, suit, & &1 ++ [group])
      end
      for [sa, sb, sc] <- [["A","B","C"], ["A","C","B"]] do
        parsed_groups =
          translate_american_match_definitions_suits(parsed.a, sa)
          ++ translate_american_match_definitions_suits(parsed.b, sb)
          ++ translate_american_match_definitions_suits(parsed.c, sc)
        {offsets, nonoffsets} = Enum.split_with(parsed_groups, &Enum.any?(&1, fn t -> Match.is_offset(t) end))
        offsets = Enum.concat(offsets)
        offsets = if Enum.empty?(offsets) do [] else [[["unique" | offsets], length(offsets)]] end
        nonoffsets = Enum.map(nonoffsets, fn g -> [[g], 1] end)
        [offsets ++ nonoffsets ++ parsed.unsuited]
      end
      |> Enum.concat()
      |> Enum.map(&{am_match_definition, &1})
    end
    |> Enum.concat()
    |> Enum.map(&translate_american_match_definitions_postprocess/1)
  end
  def translate_american_match_definitions(am_match_definitions) do
    case RiichiAdvanced.ETSCache.get({:translate_american_match_definitions, am_match_definitions}) do
      [] -> 
        result = _translate_american_match_definitions(am_match_definitions)
        # IO.inspect(result, charlists: :as_lists, label: "def")
        RiichiAdvanced.ETSCache.put({:translate_american_match_definitions, am_match_definitions}, result)
        result
      [result] -> result
    end
  end
  defp translate_letter_to_tile_spec(letter, suit) do
    offsets = %{"A" => 0, "B" => 10, "C" => 20}
    case letter do
      "0" -> "0z"
      _ when is_integer(letter) -> rem(letter + offsets[suit], 30)
      _   -> letter <> suit
    end
  end
  # ["2m", "0z", "2m", "4m"], [:"2m", :"1j", :"4m", :"0z"] => [:"2m", :"0z", :"1j", :"4m"]
  def arrange_american_group(group, tiles, tile_behavior, acc \\ [])
  def arrange_american_group([], tiles, _tile_behavior, acc), do: Enum.reverse(acc) ++ tiles
  def arrange_american_group([tile_spec | group], tiles, tile_behavior, acc) do
    tile = Utils.to_tile(tile_spec)
    case Enum.find_index(tiles, &Utils.same_tile(&1, tile, tile_behavior)) do
      nil -> tiles
      ix  -> arrange_american_group(group, List.delete_at(tiles, ix), tile_behavior, [Enum.at(tiles, ix) | acc])
    end
  end
  def arrange_american_hand(am_match_definitions, hand, calls, tile_behavior) do
    calls = Enum.map(calls, &Utils.call_to_tiles/1)
    available_tiles = Enum.reduce(calls, MapSet.new(Utils.strip_attrs(hand)), &MapSet.union(&2, MapSet.new(Utils.strip_attrs(&1)))) |> MapSet.delete(:"1j")
    possible_base_tiles = available_tiles
    # this is needed since if there are no suited tiles except suited dragons, there won't be a base tile to reach all possible dragons
    |> MapSet.put(:"1m")
    # this is needed since it's not guaranteed that offset 0 exists
    |> Enum.flat_map(fn tile -> [tile, Match.offset_tile(tile, 10, tile_behavior, true), Match.offset_tile(tile, 20, tile_behavior, true)] end)
    |> MapSet.new()
    |> MapSet.delete(nil)
    # arrange the given hand (which may contain jokers) to match any of the match definitions
    # permutations = [["A", "B", "C"], ["A", "C", "B"], ["B", "A", "C"], ["B", "C", "A"], ["C", "A", "B"], ["C", "B", "A"]]
    permutations = [["A", "B", "C"], ["A", "C", "B"]]
    for am_match_definition <- am_match_definitions, [a, b, c] <- permutations, reduce: nil do
      nil ->
        # remove each group in the definition separately
        # e.g. "FF 2024a 4444b 4444c"
        # removes these: [
        #   unsuited: [["1f", "2f", "3f", "4f", "1g", "2g", "3g", "4g"], 2],
        #   a: ["2", "0", "2", "4"],
        #   b: ["4", "4", "4", "4"],
        #   c: ["4", "4", "4", "4"]
        # ]
        # 
        # turn each of those items into a match definition that looks like [[groups, 1]]
        match_definition = for {suit, group} <- preprocess_american_match_definition(am_match_definition) do
          # turn group into a match definition using the base tile and suit
          case suit do
            :unsuited -> group
            :a -> [[Enum.map(group, &translate_letter_to_tile_spec(&1, a))], 1]
            :b -> [[Enum.map(group, &translate_letter_to_tile_spec(&1, b))], 1]
            :c -> [[Enum.map(group, &translate_letter_to_tile_spec(&1, c))], 1]
          end
        end
        # convert [[["9m", "9m", "9m", "9m", "9m"]], 1] -> [["9m"], 5]
        |> Enum.map(fn [groups, num] ->
          all_same = Enum.all?(groups, &is_list(&1) and Enum.all?(&1, fn tile -> tile == Enum.at(&1, 0) end))
          if all_same do
            len = length(Enum.at(groups, 0))
            groups = Enum.map(groups, fn [t | _] -> t; x -> x end)
            [groups, len * num]
          else [groups, num] end
        end)
        # calculate which base tiles will make the offsets in match_definition match the hand
        all_offsets = for [groups, _num] <- Enum.filter(match_definition, &is_list/1),
                          group <- Enum.reject(groups, & &1 in Match.group_keywords()),
                          offset <- (if is_list(group) do group else [group] end),
                          into: MapSet.new() do offset end
        base_tiles = Enum.filter(possible_base_tiles, fn base_tile -> 
          offset_tiles = MapSet.new(all_offsets, &Match.apply_base_tile_to_offset(&1, base_tile, tile_behavior))
          # offset_tiles can contain more than available_tiles because it can have all flowers, while available_tiles doesn't
          MapSet.subset?(available_tiles, offset_tiles)
        end)
        # if Enum.empty?(base_tiles) and [a,b,c] == Enum.at(permutations, -1) do # debug
        #   IO.puts("arrange_american_hand: no base tiles found for hand #{am_match_definition} #{inspect(hand)} / #{inspect(calls)}\n  available_tiles: #{inspect(available_tiles)}\n  all_offsets: #{inspect(all_offsets)}\n  match_definition: #{inspect(match_definition, charlists: :as_lists)}\n  #{inspect([a,b,c])}")
        #   for base_tile <- possible_base_tiles do
        #     offset_tiles = MapSet.new(all_offsets, &Match.apply_base_tile_to_offset(&1, base_tile, tile_behavior))
        #     missing = MapSet.difference(available_tiles, offset_tiles)
        #     IO.puts("applying #{base_tile} to offsets gives #{inspect(MapSet.to_list(offset_tiles))}, missing #{inspect(MapSet.to_list(missing))}")
        #   end
        # end
        arrangements = for base_tile <- base_tiles do
          for [groups, num] <- match_definition, reduce: {hand, calls, []} do
            {hand, calls, nil} -> {hand, calls, nil}
            {hand, calls, ret} ->
              # apply offsets
              groups = Enum.map(groups, &Match.apply_base_tile_to_group(&1, base_tile, tile_behavior))
              # check if this matches a call exactly
              i = Enum.find_index(calls, fn call ->
                jokerless = Utils.replace_jokers(call, [:"1j"], tile_behavior)
                Utils.count_tiles(jokerless, groups) == num
              end)
              if i != nil do
                # if so, use that call directly
                {call, calls} = List.pop_at(calls, i)
                {hand, calls, [call | ret]}
              else
                # if not, we remove groups one at time from hand, prioritizing nonjokers
                new_hand = Enum.reduce_while(1..num, hand, fn n, hand ->
                  # first phase: remove a nonjoker
                  new_hand = Enum.find_value(groups, fn group ->
                    # calls were taken care of above, so we can just focus on hand
                    case Match._remove_group(hand, [], group, base_tile, %TileBehavior{ tile_behavior | aliases: Map.delete(tile_behavior.aliases, :any) }) do
                      [{hand, _} | _] -> hand
                      []              ->
                        # if am_match_definition == "NN EEE 2024a WWW SS" do
                        #   IO.puts("Failed to remove #{inspect(group)} from #{inspect(hand)} / #{inspect(calls)}")
                        # end
                        nil
                    end
                  end)
                  if new_hand != nil do
                    {:cont, new_hand}
                  else
                    # second phase: no more nonjokers, so remove all jokers
                    # we removed n-1 nonjokers, so we need num-(n-1) jokers
                    {:halt, Match.try_remove_all_tiles(hand, List.duplicate(:"1j", num-(n-1))) |> Enum.at(0)}
                  end
                end)
                if new_hand != nil do
                  # sort 2024, NEWS etc according to the corresponding match_definition
                  new_group = case {groups, num} do
                    {[group], 1} -> arrange_american_group(if is_list(group) do group else [group] end, hand -- new_hand, tile_behavior)
                    _            -> Utils.sort_tiles(hand -- new_hand)
                  end
                  {new_hand, calls, [new_group | ret]}
                else
                  # if am_match_definition == "NN EEE 2024a WWW SS" do
                  #   IO.puts("Failed to complete #{inspect(match_definition)} for #{inspect(hand)} / #{inspect(calls)}")
                  # end
                  {[], [], nil}
                end
              end
          end
        end
        case Enum.find(arrangements, fn {hand, calls, ret} -> Enum.empty?(hand) and Enum.empty?(calls) and ret != nil end) do
          nil                  -> nil
          {_hand, _calls, ret} -> Enum.reverse(ret)
        end
      hand -> hand
    end
  end

  def declare_dead_hand(state, seat, dead_seat) do
    past_charleston = "match_start" not in state.players[seat].status
    we_are_not_dead = "dead_hand" not in state.players[seat].status
    they_are_not_dead = "dead_hand" not in state.players[dead_seat].status
    no_one_is_declaring = Enum.all?(state.players, fn {_seat, player} -> not Enum.any?(["declare_shimocha_dead", "declare_toimen_dead", "declare_kamicha_dead"], fn status -> status in player.status end) end)
    dead_seat_has_calls = not Enum.empty?(state.players[dead_seat].calls)
    if past_charleston and we_are_not_dead and they_are_not_dead and no_one_is_declaring and dead_seat_has_calls do
      push_message(state, [%{text: "Player #{player_name(state, seat)} is considering declaring a player's hand dead"}])
      declare_dead_status = case Utils.get_relative_seat(seat, dead_seat) do
        :shimocha -> "declare_shimocha_dead"
        :toimen -> "declare_toimen_dead"
        :kamicha -> "declare_kamicha_dead"
      end
      state = update_player(state, seat, &%Player{ &1 | status: MapSet.put(&1.status, declare_dead_status) })
      state = Buttons.recalculate_buttons(state)
      state = broadcast_state_change(state, true)
      state
    else state end
  end

  def get_viable_am_match_definitions(state, seat, am_match_definitions) do
    # replace winner's hand with :any and check which win definitions match, return those
    # TODO take into account concealed hands
    hand = List.duplicate(:any, length(state.players[seat].hand) + length(state.players[seat].draw))
    tile_behavior = state.players[seat].tile_behavior
    call_tiles = Utils.replace_jokers_in_calls(state.players[seat].calls, [:"1j"], tile_behavior) |> Enum.flat_map(&Utils.call_to_tiles/1)
    Enum.filter(am_match_definitions, &Match.match_hand(hand ++ call_tiles, [], translate_match_definitions(state, [&1]), tile_behavior))
  end

  def check_dead_hand(state, seat, am_match_definitions) do
    viable_am_match_definitions = get_viable_am_match_definitions(state, seat, am_match_definitions)
    # IO.inspect(viable_am_match_definitions, label: "viable_am_match_definitions")

    # at least one win definition must match the hand (entire wall - visible tiles)
    # since our matching mechanism is inefficient for big hands with jokers,
    # use arrange_american_hand instead (this is why we kept around am_match_definition)
    visible_tiles = get_visible_tiles(state) |> Utils.strip_attrs()
    hand = Enum.shuffle(state.wall) -- visible_tiles
    tile_behavior = state.players[seat].tile_behavior
    calls = Utils.replace_jokers_in_calls(state.players[seat].calls, [:"1j"], tile_behavior)
    # IO.inspect(Enum.frequencies(visible_tiles), label: "visible")
    # IO.inspect(Enum.frequencies(hand))

    # # debug
    # ret = viable_am_match_definitions
    # |> Enum.map(&{&1, arrange_american_hand([&1], hand, calls, nil, tile_behavior)})
    # |> Map.new()
    # IO.inspect(ret)
    # not Enum.any?(ret, fn {_a, b} -> b != nil end)

    arrangements = viable_am_match_definitions
    |> Enum.map(&arrange_american_hand([&1], hand, calls, tile_behavior))
    |> Enum.reject(& &1 == nil)

    if not Enum.empty?(arrangements) do
      arrangement = Enum.random(arrangements)
      push_message(state, [%{text: "Possible hand: "}] ++ Enum.flat_map(arrangement, &Utils.ph/1))
    end
    Enum.empty?(arrangements)
  end

  # get a hand that matches the given match definition (omitting any calls that are passed in)
  def instantiate_match_definition(match_definition, tiles, calls, base_tile, tile_behavior) do
    unique_ix = Enum.find_index(match_definition, & &1 == "unique")
    nojoker_ix = Enum.find_index(match_definition, & &1 == "nojoker")
    tiles = Utils.strip_attrs(tiles)
    calls = Enum.map(calls, &Utils.call_to_tiles(&1))
    {joker, nojoker} = for {match_definition_elem, i} <- Enum.with_index(match_definition) do
      unique = unique_ix != nil and i > unique_ix
      case match_definition_elem do
        [groups, num] when num >= 1 ->
          unique = unique or "unique" in groups
          nojoker_ix = if nojoker_ix != nil and i > nojoker_ix do 0 else Enum.find_index(groups, & &1 == "nojoker") end
          instance = case Enum.find(calls, &Enum.any?(groups, fn group -> Match._remove_group(&1, [], group, base_tile, tile_behavior) == [[]] end)) do
            # if this group doesn't match a call, instantiate using base tile
            nil  ->
              hand = if unique do
                # replace tiles with :ignore until you have the right number of tiles
                # if we have the tile in hand, try to avoid ignoring it if possible
                num_ignores = max(0, Enum.count(groups, & &1 not in Match.group_keywords()) - num)
                groups
                |> Enum.with_index()
                |> Enum.sort_by(fn {group, _i} -> cond do
                  group in Match.group_keywords() -> 2
                  not Utils.has_matching_tile?(tiles, [Utils.to_tile(group)]) -> 0
                  true -> 1
                end end)
                |> Enum.map(fn {_group, i} -> i end)
                |> Enum.take(num_ignores)
                |> Enum.reduce(groups, &List.replace_at(&2, &1, :ignore))
              else
                groups
                |> Enum.reject(& &1 in Match.group_keywords())
                |> Enum.at(0)
                |> List.duplicate(num)
                |> Enum.concat()
              end
              Enum.map(hand, &cond do
                Match.is_offset(&1) -> Match.offset_tile(base_tile, &1, tile_behavior)
                Utils.is_tile(&1) -> Utils.to_tile(&1)
                true -> :ignore # need to use a placeholder so that we can split by nojoker_ix later
              end)
            # otherwise, return that call
            call -> call
          end
          if nojoker_ix != nil do Enum.split(instance, nojoker_ix) else {instance, []} end
        _ -> {[], []}
      end 
    end
    |> Enum.unzip()
    joker = joker |> Enum.concat() |> Enum.reject(& &1 == :ignore)
    nojoker = nojoker |> Enum.concat() |> Enum.reject(& &1 == :ignore)
    # break into groups of identical tiles, treating flowers as same tile
    # this is so we can match with calls next
    joker = Enum.chunk_while(joker, [], fn x, acc ->
      if Enum.empty?(acc) or Utils.same_tile(x, Enum.at(acc, 0), tile_behavior) do
        {:cont, [x | acc]}
      else
        {:cont, acc, [x]}
      end
    end, &{:cont, &1, &1})

    # remove calls from the instantiation -- this must account for all the calls
    joker = for call <- calls, reduce: joker do
      [] -> []
      joker ->
        stripped_call = Utils.replace_jokers(call, [:"1j"], tile_behavior) |> Utils.strip_attrs()
        # here we use remove_group instead of match_hand to ensure the length of the call is matched too
        case Enum.find_index(joker, &Match._remove_group(&1, [], stripped_call, base_tile, tile_behavior) == [{[], []}]) do
          nil -> [] # call not found, abort
          i   -> List.delete_at(joker, i)
        end
    end |> Enum.concat()

    if Enum.empty?(joker) or nil in joker or nil in nojoker do nil else {joker, nojoker} end
  end

  def compute_closest_american_hands(state, seat, am_match_definitions, num) do
    hand = state.players[seat].hand
    draw = state.players[seat].draw
    calls = state.players[seat].calls
    tile_behavior = state.players[seat].tile_behavior
    
    hand = hand ++ draw

    # t = System.os_time(:millisecond)

    ret = for am_match_definition <- am_match_definitions do
      Task.async(fn ->
        # pairing = index map from am_match_definition to our hand
        # pairing_r = index map from our hand to am_match_definition
        # missing_tiles = all tiles in am_match_definition that aren't in our hand
        {_edge_cache, {_pairing, pairing_r, missing_tiles}} = for match_definition <- translate_american_match_definitions([am_match_definition]), base_tile <- Match.collect_base_tiles(hand, calls, List.flatten(match_definition), tile_behavior), reduce: {%{}, {%{}, %{}, []}} do
          {edge_cache, acc} -> case instantiate_match_definition(match_definition, hand, calls, base_tile, tile_behavior) do
            nil -> {edge_cache, acc}
            {matching_hand_joker, matching_hand_nojoker} ->
              # matching_hand_joker might include tiles with attr "call"
              matching_hand = matching_hand_joker ++ matching_hand_nojoker
              matching_hand_joker = Utils.strip_attrs(matching_hand_joker)
              # model the problem as a maximum matching problem on bipartite graph (indices of hand and indices of matching_hand)
              # an edge exists if corresponding tiles are the same (according to Utils.same_tile)
              # first populate edge cache with invocations of same_tile
              edge_cache = for tile <- Enum.uniq(matching_hand_joker), tile2 <- Enum.uniq(hand), not Map.has_key?(edge_cache, {tile2, tile, true}), reduce: edge_cache do
                edge_cache -> Map.put(edge_cache, {tile2, tile, true}, Utils.same_tile(tile2, tile, tile_behavior))
              end
              edge_cache = for tile <- Enum.uniq(matching_hand_nojoker), tile2 <- Enum.uniq(hand), not Map.has_key?(edge_cache, {tile2, tile, false}), reduce: edge_cache do
                edge_cache -> Map.put(edge_cache, {tile2, tile, false}, Utils.same_tile(tile2, tile, %TileBehavior{ tile_behavior | aliases: Map.delete(tile_behavior.aliases, :any) }))
              end

              # build adj graph from these cached edges
              # and use hopcroft-karp to find maximum matching
              adj_joker = Map.new(Enum.with_index(matching_hand_joker), fn {tile, i} -> {i, for {tile2, j} <- Enum.with_index(hand), Map.get(edge_cache, {tile2, tile, true}) do j end} end)
              adj_nojoker = Map.new(Enum.with_index(matching_hand_nojoker), fn {tile, i} -> {length(matching_hand_joker) + i, for {tile2, j} <- Enum.with_index(hand), Map.get(edge_cache, {tile2, tile, false}) do j end} end)
              {new_pairing, new_pairing_r} = Map.merge(adj_joker, adj_nojoker)
              |> Utils.maximum_bipartite_matching()

              # keep the best matching
              {pairing, _pairing_r, _missing_tiles} = acc
              acc = if map_size(new_pairing) > map_size(pairing) do
                # get missing tiles for later use
                missing_tiles = Enum.map(Enum.to_list(0..length(matching_hand)-1) -- Map.keys(new_pairing), fn j -> Enum.at(matching_hand, j) end)
                {new_pairing, new_pairing_r, missing_tiles}
              else acc end
              {edge_cache, acc}
          end
        end
        {am_match_definition, pairing_r, missing_tiles}
      end)
    end
    |> Task.yield_many(timeout: :infinity)
    |> Enum.map(fn {_task, {:ok, res}} -> res end)
    |> Enum.sort_by(fn {_am_match_definition, pairing_r, _missing_tiles} -> map_size(pairing_r) end, :desc)
    # |> then(fn x -> IO.inspect(Enum.map(x, fn {a, p, _} -> {a, map_size(p)} end)); x end)
    |> Enum.take(num)
    |> Enum.reject(fn {_am_match_definition, pairing_r, _missing_tiles} -> Enum.empty?(pairing_r) end)
    |> Enum.map(fn {am_match_definition, pairing_r, missing_tiles} ->
      # replace unmatched tiles in hand with missing tiles
      kept_tiles = Enum.map(Map.keys(pairing_r), fn i -> Enum.at(hand, i) end)
      missing_tiles = Enum.reject(missing_tiles, &Utils.has_attr?(&1, ["call"]))
      fixed_hand = kept_tiles ++ Utils.add_attr(missing_tiles, ["inactive"])
      arranged_hand = arrange_american_hand([am_match_definition], fixed_hand, calls, tile_behavior)
      if arranged_hand == nil do
        if seat == :east do
          IO.puts("Failed to arrange #{inspect(hand)} => #{inspect(fixed_hand)} / #{inspect(Enum.map(calls, &Utils.call_to_tiles/1))} into #{am_match_definition}")
        end
        nil
      else
        # IO.puts("#{am_match_definition}\n=> #{inspect(fixed_hand)}\n=> #{inspect(arranged_hand)}")
        arranged_hand = arranged_hand
        |> Enum.intersperse([:"3x"])
        |> Enum.concat()
        {am_match_definition, pairing_r, arranged_hand}
      end
    end)
    |> Enum.reject(&is_nil/1)

    # elapsed_time = System.os_time(:millisecond) - t
    # if elapsed_time > 10 do
    #   IO.puts("compute_closest_american_hands: #{inspect(elapsed_time)} ms")
    # end

    ret
  end
end
