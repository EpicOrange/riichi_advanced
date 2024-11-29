defmodule RiichiAdvanced.GameState.American do
  alias RiichiAdvanced.GameState.Buttons, as: Buttons
  alias RiichiAdvanced.GameState.Conditions, as: Conditions
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
                "F" -> [[["1f","2f","3f","4f","1g","2g","3g","4g"], freq]]
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
  defp translate_american_match_definitions_suits(groups, suit, is_numeric?) do
    if suit != nil do
      for group <- groups do
        Enum.map(group, fn tile ->
          cond do
            is_integer(tile) -> tile + case suit do
                "m" -> 0
                "p" -> 10
                "s" -> 20
              end
            tile == "D" -> case suit do
                "m" -> if is_numeric? do 100 else "7z" end
                "p" -> if is_numeric? do 101 else "0z" end
                "s" -> if is_numeric? do 102 else "6z" end
              end
            tile == "0" -> "0z"
            true -> tile <> suit
          end
        end)
      end
    else [] end
  end
  defp translate_american_match_definitions_postprocess(match_definition) do
    # move all nonflower single-tile and pair groups to the end, separated by a "nojokers" tag
    {use_jokers, nojokers} = Enum.split_with(match_definition, fn [groups, num] ->
      num_tiles = cond do
        is_list(groups) && Enum.all?(groups, &is_list(&1) || &1 == "nojoker") ->
          groups
          |> Enum.reject(& &1 == "nojoker")
          |> Enum.max_by(&length/1)
        true -> num
      end
      num_tiles >= 3
    end)
    # for integer groups, make sure that the single tile subgroups are nojoker
    use_jokers = for [groups, num] <- use_jokers do
      groups = for group <- groups do
        if is_list(group) && Enum.all?(group, &is_list/1) do
          {short, long} = Enum.split_with(group, &length(&1) <= 2)
          if Enum.empty?(short) do long else long ++ ["nojoker"] ++ short end
        else group end
      end
      [groups, num]
    end
    # ["debug"] ++
    ["exhaustive"] ++ if Enum.empty?(nojokers) do use_jokers else use_jokers ++ ["nojoker"] ++ nojokers end
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
      a = not Enum.empty?(parsed.a)
      b = not Enum.empty?(parsed.b)
      c = not Enum.empty?(parsed.c)
      permutations = cond do
        a && b && c -> [["m", "p", "s"], ["m", "s", "p"], ["p", "m", "s"], ["p", "s", "m"], ["s", "m", "p"], ["s", "p", "m"]]
        a && b && not c -> [["m", "p", nil], ["m", "s", nil], ["p", "s", nil], ["p", "m", nil], ["s", "m", nil], ["s", "p", nil]]
        a && not b && not c -> [["m", nil, nil], ["p", nil, nil], ["s", nil, nil]]
        not a && not b && not c -> [[nil, nil, nil]]
        true ->
          IO.inspect("Invalid suit specification in #{inspect(am_match_definition)}")
          []
      end
      is_numeric? = Enum.any?(parsed.a ++ parsed.b ++ parsed.c, &Enum.any?(&1, fn tile -> is_integer(tile) end))
      for [sa, sb, sc] <- permutations do
        parsed_groups =
          translate_american_match_definitions_suits(parsed.a, sa, is_numeric?)
          ++ translate_american_match_definitions_suits(parsed.b, sb, is_numeric?)
          ++ translate_american_match_definitions_suits(parsed.c, sc, is_numeric?)
        {numeric, nonnumeric} = Enum.split_with(parsed_groups, &Enum.any?(&1, fn t -> is_integer(t) end))
        invalid_numeric = cond do
          Enum.empty?(numeric)         -> false
          is_list(Enum.at(numeric, 0)) -> 0 not in Enum.concat(numeric)
          true                         -> 0 not in numeric
        end
        if invalid_numeric do [] else
          numeric = if Enum.empty?(numeric) do [] else [[[numeric], 1]] end
          nonnumeric = Enum.map(nonnumeric, fn g -> [[g], 1] end)
          [numeric ++ nonnumeric ++ parsed.unsuited]
        end
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
  def arrange_american_hand(am_match_definitions, hand, calls, winning_tile, ordering, ordering_r, tile_aliases) do
    call_tiles = Enum.flat_map(calls, &Riichi.call_to_tiles/1)
    hand = hand ++ call_tiles ++ if winning_tile != nil do [winning_tile] else [] end
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
            invalid_match_definition = Enum.any?(groups, fn group -> group == nil || is_list(group) && nil in group end)
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
                  # sort 2024 etc according to the match_definition
                  # must keep jokers in mind
                  new_group = case match_definition do
                    [[[group], 1]] ->
                      group = if is_list(group) do group else [group] end
                      arrange_american_group(group, new_group, tile_aliases)
                    _ -> new_group
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
      state = update_player(state, seat, &%Player{ &1 | status: Enum.uniq(&1.status ++ [declare_dead_status]) })
      state = Buttons.recalculate_buttons(state)
      state = broadcast_state_change(state)
      state
    else state end
  end

  def check_dead_hand(state, seat, am_match_definitions) do
    am_win_definitions = Enum.map(am_match_definitions, &{&1, translate_match_definitions(state, [&1])})
    # # strip all "nojoker" tags from am_win_definitions
    # # this is unnecessary now since we use :any instead of jokers
    # am_win_definitions = for {am_match_definition, win_definitions} <- am_win_definitions do
    #   {am_match_definition, for win_definition <- win_definitions do 
    #     for win_definition_elem <- win_definition, win_definition_elem != "nojoker" do 
    #       case win_definition_elem do
    #         [groups, num] ->
    #           groups = for group <- groups do
    #             cond do
    #               is_list(group) -> Enum.filter(group, & &1 != "nojoker")
    #               true -> group
    #             end
    #           end
    #           [groups, num]
    #         _ -> win_definition_elem
    #       end
    #     end
    #   end}
    # end

    # replace winner's hand with :any and check which win definitions match, save those
    hand = List.duplicate(:any, length(state.players[seat].hand) + 1)
    calls = state.players[seat].calls
    |> Enum.map(fn {name, call} ->
      if Enum.any?(call, fn {tile, _sideways} -> Utils.same_tile(tile, :"1j") end) do
        # replace jokers so we don't have to use tile_aliases
        [meld_tile] = Conditions.get_joker_meld_tile({name, call}, :"1j")
        {name, Enum.map(call, fn {_tile, sideways} -> {meld_tile, sideways} end)}
      else {name, call} end
    end)
    ordering = state.players[seat].tile_ordering
    ordering_r = state.players[seat].tile_ordering_r
    viable_am_match_definitions = am_win_definitions
    |> Enum.filter(fn {_am_match_definition, win_definitions} -> Riichi.match_hand(hand, calls, win_definitions, ordering, ordering_r, %{}) end)
    |> Enum.map(fn {am_match_definition, _win_definitions} -> am_match_definition end)
    IO.inspect(viable_am_match_definitions, label: "viable_am_match_definitions")

    # at least one win definition must match the hand (entire wall - visible tiles)
    # since our matching mechanism is inefficient for big hands with jokers,
    # use arrange_american_hand instead (this is why we kept around am_match_definition)
    visible_tiles = get_visible_tiles(state) |> Utils.strip_attrs()
    hand = Enum.shuffle(state.wall) -- visible_tiles
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
    |> Enum.map(&arrange_american_hand([&1], hand, calls, nil, ordering, ordering_r, tile_aliases))
    |> Enum.reject(& &1 == nil)

    if not Enum.empty?(arrangements) do
      arrangement = Enum.random(arrangements)
      push_message(state, [%{text: "Possible hand: "}] ++ Enum.flat_map(arrangement, &Utils.ph/1))
    end
    Enum.empty?(arrangements)
  end
end
