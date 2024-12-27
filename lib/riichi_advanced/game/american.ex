defmodule RiichiAdvanced.GameState.American do
  alias RiichiAdvanced.GameState.Buttons, as: Buttons
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
          t in ["F", "Z", "0", "N", "E", "W", "S"] ->
            # unsuited group
            groups = for {c, freq} <- group |> String.graphemes() |> Enum.frequencies() do
              case c do
                "F" -> [[["unique","1f","2f","3f","4f","1g","2g","3g","4g"], freq]]
                # below we use List.duplicate so that they can match calls
                "Z" -> [[[List.duplicate("1z", freq),List.duplicate("2z", freq),List.duplicate("3z", freq),List.duplicate("4z", freq)], 1]]
                "0" -> [[[List.duplicate("0z", freq)], 1]]
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
            is_integer(tile) && suit == "A" -> tile + 0
            is_integer(tile) && suit == "B" -> tile + 10
            is_integer(tile) && suit == "C" -> tile + 20
            tile == "D" -> "D" <> suit
            tile == "0" -> "0z"
            true -> tile <> suit
          end
        end)
      end
    else [] end
  end

  defp combine_unique_groups(match_definition) do
    # combine groups that are just [[["A","B"]], 1], [[["C","D"]], 1] into [["unique","A","B","C","D"], 4]
    {simple_groups, complex_groups} = Enum.split_with(match_definition, fn elem -> case elem do [[group], 1] -> Enum.all?(group, &Utils.is_tile(&1) || Riichi.is_offset(&1)); _ -> false end end)
    simple_group = Enum.flat_map(simple_groups, fn [[group], 1] -> group end)
    complex_groups ++ if Enum.empty?(simple_group) do [] else [[["unique" | simple_group], length(simple_group)]] end
  end

  defp translate_american_match_definitions_postprocess(match_definition) do
    # move all single-tile, mixed-tile, and pair groups to the end, separated by a "nojoker" tag
    {use_jokers, nojokers} = Enum.split_with(match_definition, fn [groups, num] ->
      num_tiles = cond do
        is_list(groups) && Enum.all?(groups, &is_list(&1) || &1 in Riichi.group_keywords()) ->
          groups
          |> Enum.reject(& &1 in Riichi.group_keywords())
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

    use_jokers = combine_unique_groups(use_jokers)
    nojokers = if Enum.empty?(nojokers) do [] else ["nojoker"] ++ combine_unique_groups(nojokers) end

    # add "nojokers" for unique groups as well
    use_jokers = Enum.map(use_jokers, fn [groups, num] ->
      cond do
        is_list(groups) && "unique" in groups ->
          {keywords, groups} = Enum.split_with(groups, & &1 in Riichi.group_keywords())
          {jokers, nojokers} = Enum.split_with(Enum.frequencies(groups), fn {_tile, freq} -> freq >= 3 end)
          jokers = Enum.flat_map(jokers, fn {tile, freq} -> List.duplicate(tile, freq) end)
          nojokers = if Enum.empty?(nojokers) do [] else ["nojoker"] ++ Enum.flat_map(nojokers, fn {tile, freq} -> List.duplicate(tile, freq) end) end
          [keywords ++ jokers ++ nojokers, num]
        true -> [groups, num]
      end
    end)
    
    # note: do NOT add "exhaustive" (game will refuse to start)

    # ["debug"] ++
    use_jokers ++ nojokers
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
        {numeric, nonnumeric} = Enum.split_with(parsed_groups, &Enum.any?(&1, fn t -> is_integer(t) end))
        numeric = Enum.concat(numeric)
        numeric = if Enum.empty?(numeric) do [] else [[["unique" | numeric], length(numeric)]] end
        nonnumeric = Enum.map(nonnumeric, fn g -> [[g], 1] end)
        [numeric ++ nonnumeric ++ parsed.unsuited]
      end |> Enum.concat()
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
  def translate_letter_to_tile_spec(letter, suit, base_tile, ordering, ordering_r) do
    dragons = %{m: "7z", p: "0z", s: "6z"}
    offsets = %{m: %{m: 0, p: 10, s: 20}, p: %{m: 20, p: 0, s: 10}, s: %{m: 10, p: 20, s: 0}, unsuited: %{m: nil, p: nil, s: nil}}
    case letter do
      "D" -> dragons[suit]
      "0" -> "0z"
      _ when is_integer(letter) ->
        base_tile_suit = cond do
          Riichi.is_manzu?(base_tile) -> :m
          Riichi.is_pinzu?(base_tile) -> :p
          Riichi.is_souzu?(base_tile) -> :s
          true -> :unsuited
        end
        offset = offsets[base_tile_suit][suit]
        if offset != nil do
          Riichi.offset_tile(base_tile, letter + offset, ordering, ordering_r) |> Utils.tile_to_string()
        else nil end
      _   -> letter <> Atom.to_string(suit)
    end
  end
  # ["2m", "0z", "2m", "4m"], [:"2m", :"1j", :"4m", :"0z"] => [:"2m", :"0z", :"1j", :"4m"]
  def arrange_american_group([], tiles, _tile_aliases), do: tiles
  def arrange_american_group([tile_spec | group], tiles, tile_aliases) do
    tile = Utils.to_tile(tile_spec)
    case Enum.find_index(tiles, &Utils.same_tile(&1, tile, tile_aliases)) do
      nil -> tiles
      ix  -> [Enum.at(tiles, ix) | arrange_american_group(group, List.delete_at(tiles, ix), tile_aliases)]
    end
  end
  def arrange_american_hand(am_match_definitions, hand, calls, ordering, ordering_r, tile_aliases) do
    call_tiles = Enum.flat_map(calls, &Riichi.call_to_tiles/1)
    hand = hand ++ call_tiles
    # arrange the given hand (which may contain jokers) to match any of the match definitions
    permutations = [[:m, :p, :s], [:m, :s, :p], [:p, :m, :s], [:p, :s, :m], [:s, :m, :p], [:s, :p, :m]]
    for am_match_definition <- am_match_definitions, [a, b, c] <- permutations, base_tile <- Enum.uniq(hand), reduce: nil do
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

        results = for {suit, group} <- preprocess_american_match_definition(am_match_definition), reduce: [{hand, []}] do
          [] -> []
          hand_result ->
            # turn group into a match definition based on the base tile and suit
            # (we try every base tile <- hand)
            match_definition = case suit do
              :unsuited -> [group]
              :a -> [[[Enum.map(group, &translate_letter_to_tile_spec(&1, a, base_tile, ordering, ordering_r))], 1]]
              :b -> [[[Enum.map(group, &translate_letter_to_tile_spec(&1, b, base_tile, ordering, ordering_r))], 1]]
              :c -> [[[Enum.map(group, &translate_letter_to_tile_spec(&1, c, base_tile, ordering, ordering_r))], 1]]
            end
            [[groups, _]] = match_definition
            invalid_match_definition = Enum.any?(groups, fn group -> group == nil || (is_list(group) && nil in group) end)
            if not invalid_match_definition do
              # turn groups that look like [[["9m", "9m", "9m", "9m", "9m"]], 1] into [["9m"], 5]
              match_definition = for match_definition_elem <- match_definition do
                case match_definition_elem do
                  [sets, num] ->
                    all_same = Enum.all?(sets, fn set -> is_list(set) && Enum.all?(set, & &1 == Enum.at(set, 0)) end)
                    if all_same do
                      len = length(Enum.at(sets, 0))
                      sets = Enum.map(sets, fn set ->
                        case set do
                          [t | _] -> t
                          _       -> set
                        end
                      end)
                      [sets, len * num]
                    else match_definition_elem end
                  _ -> match_definition_elem
                end
              end
              [[groups, orig_num]] = match_definition
              Enum.flat_map(hand_result, fn {hand, result} ->
                # remove the given match definition from hand to get a remaining_hand
                # first try the fast and easy way of using no jokers
                remaining_hands_nojoker = Riichi.remove_match_definition(hand, [], match_definition, ordering, ordering_r)
                # IO.inspect({hand, match_definition, remaining_hands_nojoker})
                remaining_hands = if Enum.empty?(remaining_hands_nojoker) && orig_num >= 3 do
                  # couldn't remove this group without using jokers, so we need to remove jokers
                  # note that we can only remove jokers if the group is 3+ tiles
                  # remove as many nonjokers as we can first
                  {hand, num_removed} = for n <- 1..orig_num, reduce: {hand, nil} do
                    {hand, nil} -> 
                      removed = Riichi.remove_match_definition(hand, [], [[groups, 1]], ordering, ordering_r)
                      if not Enum.empty?(removed) do
                        {hand, _calls} = Enum.at(removed, 0)
                        {hand, nil}
                      else {hand, n - 1} end
                    {hand, num_removed} -> {hand, num_removed}
                  end
                  # then remove the remaining number as jokers
                  # TODO this assumes the group in question is length 1 (e.g. flowers)
                  num_jokers = orig_num - num_removed # guaranteed to be at least 1 since remaining_hands_nojoker is empty
                  jokers = List.duplicate(:"1j", num_jokers)
                  for hand <- Riichi.try_remove_all_tiles(hand, jokers) do
                    {hand, []}
                  end
                else remaining_hands_nojoker end

                # each remaining_hand represents a group removed
                # filter for remaining_hands that represents a group being removed
                groups_removed = remaining_hands
                |> Enum.map(fn {remaining_hand, _calls} -> {remaining_hand, hand -- remaining_hand} end)
                |> Enum.reject(fn {_remaining_hand, new_group} -> Enum.empty?(new_group) end)

                # postprocess the groups and add it to our result list
                for {remaining_hand, new_group} <- groups_removed do
                  # sort 2024, NEWS etc according to the match_definition
                  # must keep jokers in mind
                  new_group = case match_definition do
                    [[[group], 1]] ->
                      group = if is_list(group) do group else [group] end
                      arrange_american_group(group, new_group, tile_aliases)
                    _ -> Utils.sort_tiles(new_group)
                  end
                  {remaining_hand, result ++ [new_group]}
                end
              end)
            else [] end
        end
        for {_hand, result} <- results, reduce: nil do
          nil -> 
            if [] in result do # some group failed to match
              nil
            else
              # check if we used all our calls
              if Enum.any?(calls, &Riichi.call_to_tiles(&1) not in result) do
                nil
              else result end
            end
          result -> result
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
    if past_charleston && we_are_not_dead && they_are_not_dead && no_one_is_declaring && dead_seat_has_calls do
      push_message(state, [%{text: "Player #{seat} #{state.players[seat].nickname} is considering declaring a player's hand dead"}])
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
    call_tiles = Utils.replace_jokers_in_calls(state.players[seat].calls, [:"1j"]) |> Enum.flat_map(&Riichi.call_to_tiles/1)
    ordering = state.players[seat].tile_ordering
    ordering_r = state.players[seat].tile_ordering_r
    Enum.filter(am_match_definitions, &Riichi.match_hand(hand ++ call_tiles, [], translate_match_definitions(state, [&1]), ordering, ordering_r))
  end

  def check_dead_hand(state, seat, am_match_definitions) do
    viable_am_match_definitions = get_viable_am_match_definitions(state, seat, am_match_definitions)
    # IO.inspect(viable_am_match_definitions, label: "viable_am_match_definitions")

    # at least one win definition must match the hand (entire wall - visible tiles)
    # since our matching mechanism is inefficient for big hands with jokers,
    # use arrange_american_hand instead (this is why we kept around am_match_definition)
    visible_tiles = get_visible_tiles(state) |> Utils.strip_attrs()
    hand = Enum.shuffle(state.wall) -- visible_tiles
    calls = Utils.replace_jokers_in_calls(state.players[seat].calls, [:"1j"])
    ordering = state.players[seat].tile_ordering
    ordering_r = state.players[seat].tile_ordering_r
    tile_aliases = state.players[seat].tile_aliases
    # IO.inspect(Enum.frequencies(visible_tiles), label: "visible")
    # IO.inspect(Enum.frequencies(hand))

    # # debug
    # ret = viable_am_match_definitions
    # |> Enum.map(&{&1, arrange_american_hand([&1], hand, calls, nil, ordering, ordering_r, tile_aliases)})
    # |> Map.new()
    # IO.inspect(ret)
    # not Enum.any?(ret, fn {_a, b} -> b != nil end)

    arrangements = viable_am_match_definitions
    |> Enum.map(&arrange_american_hand([&1], hand, calls, ordering, ordering_r, tile_aliases))
    |> Enum.reject(& &1 == nil)

    if not Enum.empty?(arrangements) do
      arrangement = Enum.random(arrangements)
      push_message(state, [%{text: "Possible hand: "}] ++ Enum.flat_map(arrangement, &Utils.ph/1))
    end
    Enum.empty?(arrangements)
  end

  def instantiate_match_definition(match_definition, hand, base_tile, ordering, ordering_r) do
    unique_ix = Enum.find_index(match_definition, & &1 == "unique")
    nojoker_ix = Enum.find_index(match_definition, & &1 == "nojoker")
    {joker, nojoker} = for {match_definition_elem, i} <- Enum.with_index(match_definition) do
      unique = unique_ix != nil && i > unique_ix
      case match_definition_elem do
        [groups, num] when num >= 1 ->
          unique = unique || "unique" in groups
          nojoker_ix = if nojoker_ix != nil && i > nojoker_ix do 0 else Enum.find_index(groups, & &1 == "nojoker") end
          hand = if unique do
            # replace groups with :ignore until you have the right number of groups
            # if the group is a tile in hand, try to avoid ignoring it if possible
            groups
            |> Enum.with_index()
            |> Enum.sort_by(fn {group, _i} -> cond do
              group in Riichi.group_keywords() -> 2
              Utils.count_tiles(hand, [Utils.to_tile(group)]) == 0 -> 0
              true -> 1
            end end)
            |> Enum.map(fn {_group, i} -> i end)
            |> Enum.take(max(0, Enum.count(groups, & &1 not in Riichi.group_keywords()) - num))
            |> Enum.reduce(groups, &List.replace_at(&2, &1, :ignore))
          else
            groups
            |> Enum.reject(& &1 in Riichi.group_keywords())
            |> Enum.at(0)
            |> List.duplicate(num)
            |> Enum.concat()
          end
          Enum.map(hand, &cond do
            Riichi.is_offset(&1) -> Riichi.offset_tile(base_tile, &1, ordering, ordering_r)
            Utils.is_tile(&1) -> Utils.to_tile(&1)
            true -> :ignore # need to use a placeholder so that we can split by nojoker_ix later
          end)
          |> Enum.split(if nojoker_ix != nil do nojoker_ix else length(hand) end)
        _ -> {[], []}
      end
    end
    |> Enum.unzip()
    joker = joker |> Enum.concat() |> Enum.reject(& &1 == :ignore)
    nojoker = nojoker |> Enum.concat() |> Enum.reject(& &1 == :ignore)
    if nil in joker || nil in nojoker do nil else {joker, nojoker} end
  end

  def compute_closest_american_hands(state, seat, am_match_definitions, num) do
    hand = state.players[seat].hand
    draw = state.players[seat].draw
    calls = state.players[seat].calls
    ordering = state.players[seat].tile_ordering
    ordering_r = state.players[seat].tile_ordering_r
    tile_aliases = state.players[seat].tile_aliases
    
    hand = hand ++ draw ++ Enum.flat_map(calls, &Riichi.call_to_tiles/1)
    all_tiles = hand
    |> Enum.uniq()
    |> Utils.apply_tile_aliases(tile_aliases)
    |> Enum.reject(& &1 == :any)

    # t = System.os_time(:millisecond)

    ret = for am_match_definition <- am_match_definitions do
      Task.async(fn ->
        # pairing = index map from am_match_definition to our hand
        # pairing_r = index map from our hand to am_match_definition
        # missing_tiles = all tiles in am_match_definition that aren't in our hand
        {_edge_cache, {_pairing, pairing_r, missing_tiles}} = for match_definition <- translate_american_match_definitions([am_match_definition]), base_tile <- all_tiles, reduce: {%{}, {%{}, %{}, []}} do
          {edge_cache, acc} -> case instantiate_match_definition(match_definition, hand, base_tile, ordering, ordering_r) do
            nil -> {edge_cache, acc}
            {matching_hand_joker, matching_hand_nojoker} ->
              # model the problem as a maximum matching problem on bipartite graph (indices of hand and indices of matching_hand)
              # an edge exists if corresponding tiles are the same (Util.same_tile)
              # first populate edge cache with invocations of same_tile
              edge_cache = for tile <- Enum.uniq(matching_hand_joker), tile2 <- Enum.uniq(hand), not Map.has_key?(edge_cache, {tile2, tile, true}), reduce: edge_cache do
                edge_cache -> Map.put(edge_cache, {tile2, tile, true}, Utils.same_tile(tile2, tile, tile_aliases))
              end
              edge_cache = for tile <- Enum.uniq(matching_hand_nojoker), tile2 <- Enum.uniq(hand), not Map.has_key?(edge_cache, {tile2, tile, false}), reduce: edge_cache do
                edge_cache -> Map.put(edge_cache, {tile2, tile, false}, Utils.same_tile(tile2, tile))
              end

              # build adj graph from these cached edges
              adj_joker = Map.new(Enum.with_index(matching_hand_joker), fn {tile, i} -> {i, for {tile2, j} <- Enum.with_index(hand), Map.get(edge_cache, {tile2, tile, true}) do j end} end)
              adj_nojoker = Map.new(Enum.with_index(matching_hand_nojoker), fn {tile, i} -> {length(matching_hand_joker) + i, for {tile2, j} <- Enum.with_index(hand), Map.get(edge_cache, {tile2, tile, false}) do j end} end)
              adj = Map.merge(adj_joker, adj_nojoker)

              # use dfs to find all augmenting paths, starting with valid edges in the previous pairing
              {pairing, _pairing_r, _missing_tiles} = acc
              # this actually leads to incorrect matchings (e.g. two A nodes matching with the same B node)
              # TODO fix
              # init_pairing = Enum.filter(pairing, fn {i, j} -> j in adj[i] end) |> Map.new()
              # init_pairing_r = Enum.filter(pairing_r, fn {i, j} -> i in adj[j] end) |> Map.new()
              init_pairing = %{}
              init_pairing_r = %{}
              {new_pairing, new_pairing_r} = for i <- Map.keys(adj), reduce: {init_pairing, init_pairing_r} do
                {pairing, pairing_r} -> case compute_closest_american_hands_dfs(i, adj, pairing, pairing_r, MapSet.new()) do
                  {true, pairing, pairing_r, _} -> {pairing, pairing_r}
                  {false, _, _, _}              -> {pairing, pairing_r}
                end
              end

              # keep the best matching
              acc = if map_size(new_pairing) > map_size(pairing) do
                # get missing tiles for later use
                matching_hand = matching_hand_joker ++ matching_hand_nojoker
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
    |> Enum.map(fn {am_match_definition, pairing_r, missing_tiles} ->
      # replace unmatched tiles in hand with missing tiles
      kept_tiles = Enum.map(Map.keys(pairing_r), fn i -> Enum.at(hand, i) end)
      fixed_hand = kept_tiles ++ Utils.add_attr(missing_tiles, ["transparent"])
      arranged_hand = arrange_american_hand([am_match_definition], fixed_hand, [], ordering, ordering_r, tile_aliases)
      if arranged_hand == nil do
        IO.puts("Failed to arrange #{inspect(fixed_hand)} into #{am_match_definition}")
      end
      arranged_hand = arranged_hand
      |> Enum.intersperse([:"3x"])
      |> Enum.concat()
      {am_match_definition, pairing_r, arranged_hand}
    end)

    # elapsed_time = System.os_time(:millisecond) - t
    # if elapsed_time > 10 do
    #   IO.puts("compute_closest_american_hands: #{inspect(elapsed_time)} ms")
    # end

    ret
  end

  defp compute_closest_american_hands_dfs(i, adj, pairing, pairing_r, visited) do
    Enum.reduce_while(Map.get(adj, i, []), {false, pairing, pairing_r, visited}, fn j, {_, pairing, pairing_r, visited} ->
      if MapSet.member?(visited, j) do
        {:cont, {false, pairing, pairing_r, visited}}
      else
        visited = MapSet.put(visited, j)
        if not Map.has_key?(pairing_r, j) do
          {:halt, {true, Map.put(pairing, i, j), Map.put(pairing_r, j, i), visited}}
        else
          {halt, pairing, pairing_r, visited} = compute_closest_american_hands_dfs(pairing_r[j], adj, pairing, pairing_r, visited)
          if halt do
            {:halt, {true, Map.put(pairing, i, j), Map.put(pairing_r, j, i), visited}}
          else
            {:cont, {false, pairing, pairing_r, visited}}
          end
        end
      end
    end)
  end
end
