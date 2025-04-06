defmodule RiichiAdvanced.GameState.Rules do
  alias RiichiAdvanced.GameState.American, as: American
  alias RiichiAdvanced.GameState.Debug, as: Debug
  alias RiichiAdvanced.Match, as: Match
  alias RiichiAdvanced.ModLoader, as: ModLoader
  alias RiichiAdvanced.Utils, as: Utils

  defp decode_rules(ruleset, ruleset_json) do
    # decode the rules json
    try do
      case Jason.decode(ModLoader.strip_comments(ruleset_json)) do
        {:ok, rules} -> {:ok, rules}
        {:error, err} ->
          IO.puts("Erroring json:")
          IO.puts(ruleset_json)
          {:error, "WARNING: Failed to read rules file at character position #{err.position}!\nRemember that trailing commas are invalid!"}
      end
    rescue
      ArgumentError -> {:error, "WARNING: Ruleset \"#{ruleset}\" doesn't exist!"}
    end
  end

  defp check_rules(rules) do
    if get_in(rules["buttons"]["skip"]) != nil do
      {:error, "Error: \"skip\" is an invalid button name."}
    else
      # if we're debugging american hands then always show the nearest hand button
      rules = if not Enum.empty?(Debug.debug_am_match_definitions()) do
        Map.put(rules, "show_nearest_american_hand", true)
      else rules end

      {:ok, rules}
    end
  end

  defp replace_constants(rules) do
    # replace all @ constants in rules
    rules = if Map.has_key?(rules, "constants") do
      Utils.splat_json(rules, fn
        <<"@splat$" <> name>> -> List.wrap(Map.get(rules["constants"], name, name))
        <<"@" <> name>> -> [Map.get(rules["constants"], name, name)]
        value -> [value]
      end)
    else rules end
    {:ok, rules}
  end

  def load_rules(ruleset_json, ruleset) do
    with {:ok, rules} <- decode_rules(ruleset, ruleset_json),
         {:ok, rules} <- replace_constants(rules),
         {:ok, rules} <- check_rules(rules) do
      # store rules in an anonymous ETS table
      # this is cleaned up once the creating process (GameState) dies
      rules_ref = :ets.new(nil, [:set, :public, read_concurrency: true]) 
      for {k, v} <- rules do
        :ets.insert(rules_ref, {k, v})
      end

      # add the json
      :ets.insert(rules_ref, {:ruleset_json, ruleset_json})

      # generate shanten definitions if they don't exist
      shantens = [:win, :tenpai, :iishanten, :ryanshanten, :sanshanten, :suushanten, :uushanten, :roushanten]
      shanten_definitions = Map.new(shantens, fn shanten -> {shanten, translate_match_definitions(rules_ref, Map.get(rules, Atom.to_string(shanten) <> "_definition", []))} end)
      shanten_definitions = for {from, to} <- Enum.zip(Enum.drop(shantens, -1), Enum.drop(shantens, 1)), Enum.empty?(shanten_definitions[to]), reduce: shanten_definitions do
        shanten_definitions ->
          # IO.puts("Generating #{to} definitions")
          if length(shanten_definitions[from]) < 100 do
            Map.put(shanten_definitions, to, Match.compute_almost_match_definitions(shanten_definitions[from]))
          else
            Map.put(shanten_definitions, to, [])
          end
      end
      :ets.insert(rules_ref, {:shanten_definitions, shanten_definitions})
      # IO.inspect(shanten_definitions)
      # IO.inspect(Map.new(shanten_definitions, fn {shanten, definition} -> {shanten, length(definition)} end))

      {:ok, rules_ref}
    end
  end

  def get(rules_ref, key, default \\ nil)
  def get(nil, _key, default), do: default
  def get(rules_ref, key, default) do
    try do
      case :ets.lookup(rules_ref, key) do
        [{^key, value}] -> value
        [] -> default
      end
    rescue
      _ -> default
    end
  end

  def has_key?(nil, _key), do: false
  def has_key?(rules_ref, key) do
    try do
      case :ets.lookup(rules_ref, key) do
        [_] -> true
        [] -> false
      end
    rescue
      _ -> false
    end
  end



  def translate_sets_in_match_definitions(match_definitions, set_definitions) do
    for match_definition <- match_definitions do
      for match_definition_elem <- match_definition do
        case match_definition_elem do
          [groups, num] -> [Enum.flat_map(groups, &Map.get(set_definitions, &1, [&1])), num]
          _ when is_binary(match_definition_elem) -> match_definition_elem
          _ ->
            IO.puts("#{inspect(match_definition_elem)} is not a valid match definition element.")
            GenServer.cast(self(), {:show_error, "#{inspect(match_definition_elem)} is not a valid match definition element."})
            nil
        end
      end
    end
  end

  # match_definitions is a list of match definitions, each of which is itself
  # a two-element list [groups, num] representing num times groups.
  # 
  # A list of match definitions succeeds when at least one match definition does,
  # and a match definition succeeds when each of its groups match some part of
  # the hand / calls in a non-overlapping manner.
  # 
  # A group is a list of tile sets. A group matches when any set matches.
  # 
  # Named match definitions can be defined as a key "mydef_definition" at the top level.
  # They expand to a list of match definitions that all get added to the list of
  # match definitions they appear in.
  # The toplevel "mydef_definition" may not reference other named match definitions.
  # 
  # Named sets can be found in the key "set_definitions".
  # This function simply swaps out all names for their respective definitions.
  # 
  # A match definition can also have one of the following strings as flags:
  #   "exhaustive": Perform an exhaustive backtracking search.
  #                 Useful when groups may overlap, thus a naive search without
  #                 backtracking will fail without this flag.
  #                 Runs in factorial time n! where n is the total number of groups.
  #   "unique": Use each group in each group set exactly once. Useful for defining kokushi.
  #   "nojoker": Ignore joker abilities.
  #
  # Example of a list of match definitions representing a winning hand:
  # [
  #   ["exhaustive", [["shuntsu", "koutsu"], 4], [["pair"], 1]],
  #   [[["pair"], 7]],
  #   "kokushi_musou" // defined top-level as "kokushi_musou_definition"
  # ]
  def translate_match_definitions(rules_ref, match_definitions) do
    set_definitions = get(rules_ref, "set_definitions", %{})
    for match_definition <- match_definitions, reduce: [] do
      acc ->
        translated = cond do
          is_binary(match_definition) ->
            case get(rules_ref, match_definition <> "_definition", nil) do
              nil ->
                if String.contains?(match_definition, " ") do
                  American.translate_american_match_definitions([match_definition])
                else
                  GenServer.cast(self(), {:show_error, "Could not find match definition \"#{match_definition}_definition\" in the rules."})
                  []
                end
              named_match_definitions -> 
                {am_match_definitions, match_definitions} = Enum.split_with(named_match_definitions, &is_binary/1)
                translated_match_definitions = translate_sets_in_match_definitions(match_definitions, set_definitions)
                translated_am_match_definitions = American.translate_american_match_definitions(am_match_definitions)
                translated_match_definitions ++ translated_am_match_definitions
            end
          is_list(match_definition)   -> translate_sets_in_match_definitions([match_definition], set_definitions)
          true                        ->
            GenServer.cast(self(), {:show_error, "#{inspect(match_definition)} is not a valid match definition."})
            []
        end
        [translated | acc]
    end |> Enum.reverse() |> Enum.concat()
  end

end
