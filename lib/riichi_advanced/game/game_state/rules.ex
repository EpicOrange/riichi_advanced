defmodule RiichiAdvanced.GameState.Rules do
  alias RiichiAdvanced.GameState.American, as: American
  alias RiichiAdvanced.GameState.Debug, as: Debug
  alias RiichiAdvanced.Match, as: Match
  alias RiichiAdvanced.ModLoader, as: ModLoader
  alias RiichiAdvanced.Utils, as: Utils

  def decode_ruleset_json(ruleset_json, ruleset \\ "unknown") do
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

  # catch-all verification
  # we should probably add more verification than just this, but only if needed
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
    with {:ok, rules} <- decode_ruleset_json(ruleset_json, ruleset),
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

      # yaku list names in yaku_precedence add all yaku of specified yaku lists
      yaku_precedence = get(rules_ref, "yaku_precedence")
      score_rules = get(rules_ref, "score_calculation")
      if yaku_precedence != nil and score_rules != nil do
        yaku_list_names =
             Map.get(score_rules, "yaku_lists", [])
          ++ Map.get(score_rules, "yaku2_lists", [])
          ++ Map.get(score_rules, "extra_yaku_lists", [])
        # yaku list => names of yaku in that list
        yaku_name_map = for yaku_list_name <- yaku_list_names, into: %{} do
          yaku_list = get(rules_ref, yaku_list_name, [])
          {yaku_list_name, Enum.map(yaku_list, & &1["display_name"]) |> Enum.uniq()}
        end
        yaku_precedence =
          for {name, overrides} <- yaku_precedence,
              override <- overrides,
              Enum.member?(yaku_list_names, override),
              reduce: yaku_precedence do
          yaku_precedence ->
            overrides_to_add = Map.get(yaku_name_map, override, [])
            Map.update(yaku_precedence, name, overrides_to_add, &overrides_to_add ++ &1)
        end
        :ets.insert(rules_ref, {"yaku_precedence", yaku_precedence})
      end

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
    for match_definition <- List.wrap(match_definitions), reduce: [] do
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

  # input is rules["available_mods"] and rules["default_mods"]
  # returns {mods, categories}
  # categories are just a list of strings
  # mods are are maps %{modname => modobj} where modobj has keys:
  # - enabled: whether it is in starting_mods (passed in)
  # - index: index of mod in available_mods
  # - name: display name
  # - desc: displayed description
  # - category: declared category
  # - config: map %{config_name => %{"default" => default value, "values" => list of values, :value => selected value depending on default}}
  # - order: integer that decides which pass mod is loaded in (4 loads after 3, etc). negative allowed
  # - class: string that is appended to CSS classes on the button representing this mod
  # - deps: list of mod ids this mod is dependent on
  # - conflicts: list of mod ids this mod conflicts with
  def parse_available_mods(available_mods, starting_mods) do
    {mods, categories} = for {item, i} <- available_mods |> Enum.with_index(), reduce: {[], []} do
      {result, categories} -> cond do
        is_map(item) -> {[item |> Map.put("index", i) |> Map.put("category", Enum.at(categories, 0, nil)) | result], categories}
        is_binary(item) -> {result, [item | categories]}
      end
    end

    available_mods = Enum.map(mods, & &1["id"])
    starting_mods = starting_mods
    |> Enum.map(&case &1 do
      %{"name" => mod_name, "config" => config} -> {mod_name, config}
      %{name: mod_name, config: config}         -> {mod_name, config}
      mod_name when is_binary(mod_name)         -> {mod_name, nil}
    end)
    |> Enum.filter(fn {mod_name, _config} -> mod_name in available_mods end)
    |> Map.new()

    mods = Map.new(mods, fn mod -> {mod["id"], %{
      enabled: Map.has_key?(starting_mods, mod["id"]),
      index: mod["index"],
      name: mod["name"],
      desc: mod["desc"],
      category: mod["category"],
      config: Map.get(mod, "config", [])
           |> Map.new(&Map.pop(&1, "name"))
           |> Map.new(fn {config_name, config} ->
                default = if starting_mods[mod["id"]] != nil do
                  # load the previous config's value as the default
                  old_config = starting_mods[mod["id"]]
                  old_config[config_name]
                else
                  Map.get(config, "default", Enum.at(config["values"], 0))
                end
                config = Map.put(config, :value, default)
                {config_name, config}
              end),
      order: Map.get(mod, "order", 0), # TODO replace this with "load_after" array, and do toposort on the result
      class: mod["class"],
      deps: Map.get(mod, "deps", []),
      conflicts: Map.get(mod, "conflicts", [])
    }} end)
    {mods, Enum.reverse(categories)}
  end

end
