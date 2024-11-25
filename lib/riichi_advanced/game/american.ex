defmodule RiichiAdvanced.GameState.American do
  # import RiichiAdvanced.GameState

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
                "Z" -> [[["1z","2z","3z","4z"], freq]]
                "0" -> [[["0z"], freq]]
                "N" -> [[["4z"], freq]]
                "E" -> [[["1z"], freq]]
                "W" -> [[["3z"], freq]]
                "S" -> [[["2z"], freq]]
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
        is_list(groups) -> length(groups)
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
  def translate_letter_to_tile_spec(letter, suit) do
    dragons = %{"m" => "7z", "p" => "0z", "s" => "6z"}
    case letter do
      "D" -> dragons[suit]
      "0" -> "0z"
      _ when is_integer(letter) -> letter
      _   -> letter <> suit
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
  def arrange_american_hand(am_match_definitions, hand, winning_tile, ordering, ordering_r, tile_aliases) do
    hand = hand ++ [winning_tile]
    # arrange the given hand (which may contain jokers) to match any of the match definitions
    permutations = [["m", "p", "s"], ["m", "s", "p"], ["p", "m", "s"], ["p", "s", "m"], ["s", "m", "p"], ["s", "p", "m"]]
    for am_match_definition <- am_match_definitions, [a, b, c] <- permutations, reduce: nil do
      nil ->
        # "FF 2024a 4444b 4444c"
        # [
        #   unsuited: [["1f", "2f", "3f", "4f", "1g", "2g", "3g", "4g"], 2],
        #   a: ["2", "0", "2", "4"],
        #   b: ["4", "4", "4", "4"],
        #   c: ["4", "4", "4", "4"]
        # ]
        
        res = for {suit, group} <- preprocess_american_match_definition(am_match_definition), reduce: [{hand, []}] do
          acc -> for {hand, result} <- acc do
            match_definition = case suit do
              :unsuited -> [group]
              # todo handle numeric t
              :a -> [[[Enum.map(group, &translate_letter_to_tile_spec(&1, a))], 1]]
              :b -> [[[Enum.map(group, &translate_letter_to_tile_spec(&1, b))], 1]]
              :c -> [[[Enum.map(group, &translate_letter_to_tile_spec(&1, c))], 1]]
            end
            remaining_hands_nojoker = Riichi.remove_match_definition(hand, [], match_definition, ordering, ordering_r)
            remaining_hands = if Enum.empty?(remaining_hands_nojoker) do
              Riichi.remove_match_definition(hand, [], match_definition, ordering, ordering_r, tile_aliases)
            else remaining_hands_nojoker end
            for {remaining_hand, _calls} <- remaining_hands do
              new_group = hand -- remaining_hand
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
          end |> Enum.concat()
        end
        case res do
          [] -> nil
          [{_hand, result}] -> Enum.concat(Enum.intersperse(result, [:"3x"])) -- [winning_tile]
        end
      hand -> hand
    end
  end

end
