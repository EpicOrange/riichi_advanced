defmodule RiichiAdvanced.GameState.Rules do
  alias RiichiAdvanced.GameState.American
  alias RiichiAdvanced.GameState.Debug
  alias RiichiAdvanced.MatchOld
  alias RiichiAdvanced.ModLoader
  alias RiichiAdvanced.ModLoader.ModState
  alias RiichiAdvanced.Utils
  require Logger

  def decode_ruleset_json(ruleset_json, ruleset \\ "unknown") do
    # decode the rules json
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

  defp toposort_yaku(yakus, yaku_precedence) do
    # IO.inspect(Enum.map(yakus, &{&1.ix, &1["display_name"]}), limit: :infinity, label: inspect(Enum.map(yakus, &elem(&1, 0))))

    yaku_map = %{}
    |> Map.merge(Enum.group_by(yakus, &Map.get(&1, :key)))
    |> Map.merge(Enum.group_by(yakus, &Map.get(&1, :list_name)))
    |> Map.merge(Enum.group_by(yakus, &Map.get(&1, :value_num)))
    |> Map.merge(Enum.group_by(yakus, &Map.get(&1, "value")))
    |> Map.merge(Enum.group_by(yakus, &Map.get(&1, "display_name")))

    # do a pass over yakus to capture dependencies
    # calculate dependent yaku by seeing if any conditions are dependent on other yaku
    # i.e. "has_existing_yaku", "has_no_yaku", "has_points" (plus their negations) only
    # yaku_deps: %{yakuX ix => [dependent yaku.keys that require evaluating yakuX first]}
    all_ixs = Enum.map(yakus, & &1.ix)
    yaku_deps = for yaku <- yakus, reduce: %{} do
      acc ->
        dep_ixs = yaku["when"]
        |> List.flatten()
        |> Enum.flat_map(fn
          %{"name" => "has_existing_yaku",     "opts" => opts} -> Enum.flat_map(opts, &Map.get(yaku_map, &1, []) |> Enum.map(fn yaku -> yaku.ix end))
          %{"name" => "not_has_existing_yaku", "opts" => opts} -> Enum.flat_map(opts, &Map.get(yaku_map, &1, []) |> Enum.map(fn yaku -> yaku.ix end))
          "has_no_yaku"                 -> all_ixs
          "not_has_no_yaku"             -> all_ixs
          %{"name" => "has_points"}     -> all_ixs
          %{"name" => "not_has_points"} -> all_ixs
          _ -> []
        end)
        |> Enum.uniq()
        # |> IO.inspect(label: yaku["display_name"], charlists: :as_lists, limit: :infinity)
        for dep_ix <- dep_ixs, reduce: acc do
          acc -> Map.update(acc, dep_ix, MapSet.new([yaku.key]), &MapSet.put(&1, yaku.key))
        end
    end

    # IO.inspect(yaku_deps, limit: :infinity, label: "yaku_deps")

    # actually perform toposort
    {toposorted, _visited} = for yaku <- yakus, reduce: {[], MapSet.new()} do
      {acc, visited} -> _toposort_yaku(yaku, yaku_deps, yaku_map, yaku_precedence, acc, visited)
    end
    
    # IO.inspect(Enum.map(toposorted, &{&1.ix, &1["display_name"]}), limit: :infinity)

    skip_map = for {prec_from, precs_to} <- yaku_precedence,
                   yaku <- Map.get(yaku_map, prec_from, []),
                   yaku2 <- Enum.flat_map(precs_to, &Map.get(yaku_map, &1, [])),
                   reduce: %{} do
      acc -> Map.update(acc, yaku.key, MapSet.new([yaku2.key]), &MapSet.put(&1, yaku2.key))
    end

    # take transitive closure of skip_map by traversing it in backwards topological order
    skip_map = for %{key: key} <- Enum.reverse(toposorted), reduce: skip_map do
      skip_map when is_map_key(skip_map, key) ->
        for key2 <- Map.get(skip_map, key, MapSet.new()), reduce: skip_map do
          skip_map -> Map.update!(skip_map, key, &MapSet.union(&1, Map.get(skip_map, key2, MapSet.new())))
        end
      skip_map -> skip_map
    end

    # IO.inspect(skip_map, limit: :infinity, label: "skip_map")

    {toposorted, skip_map}
  end

  defp _toposort_yaku(yaku, yaku_deps, yaku_map, yaku_precedence, acc, visited) do
    if yaku.ix in visited do {acc, visited} else
      # look up dependent_yaku using ix
      dependent_yaku = Map.get(yaku_deps, yaku.ix, [])
      |> Enum.flat_map(&Map.get(yaku_map, &1, []))

      # look up overridden_yaku using a variety of keys
      # ignore overridden yaku if there's a dependency in the reverse direction
      overridden_yaku = Enum.flat_map([:key, :list_name, :value_num, "value", "display_name"], &Map.get(yaku_precedence, Map.get(yaku, &1), []))
      |> Enum.flat_map(&Map.get(yaku_map, &1, []))
      |> Enum.reject(fn yaku2 -> yaku.key in Map.get(yaku_deps, yaku2.ix, []) end)

      {acc, visited} = for yaku2 <- dependent_yaku ++ overridden_yaku, yaku.ix != yaku2.ix, reduce: {acc, MapSet.put(visited, yaku.ix)} do
        {acc, visited} -> _toposort_yaku(yaku2, yaku_deps, yaku_map, yaku_precedence, acc, visited)
      end
      {[yaku | acc], visited}
    end
  end

  def load_rules(ruleset_json, ruleset \\ "unknown") do
    with {:ok, rules} <- read_rules_from_json(ruleset_json, ruleset) do
      # store rules in an anonymous ETS table
      rules_ref = :ets.new(nil, [:set, :protected, read_concurrency: true]) 
      :ets.insert(rules_ref, {:ruleset, ruleset})
      :ets.insert(rules_ref, Map.to_list(rules))

      # toposort yaku and calculate shanten definitions and stuff
      preprocess_rules(rules_ref, rules)

      test_heir = Process.whereis(RiichiAdvanced.TestStaticEtsOwner)
      if test_heir != nil do
        # attach rules_ref to a long-lived owner
        :ets.give_away(rules_ref, test_heir, :no_extra_info)
      else
        # attach formatted json if we're not a test
        ruleset_json = RiichiAdvanced.Formatter.format(Jason.decode!(ruleset_json), 80)
        :ets.insert(rules_ref, {:ruleset_json, ruleset_json})
      end

      {:ok, rules_ref}
    end
  end
  defp read_rules_from_json(ruleset_json, ruleset) do
    with {:ok, rules} <- decode_ruleset_json(ruleset_json, ruleset),
         {:ok, rules} <- replace_constants(rules),
         {:ok, rules} <- replace_constants(rules),
         {:ok, rules} <- replace_constants(rules),
         {:ok, rules} <- check_rules(rules) do
      {:ok, rules}
    end
  end
  defp preprocess_rules(rules_ref, rules) do
    # toposort all yaku by precedence
    score_rules = get(rules_ref, "score_calculation", %{})
    yaku_lists = Map.get(score_rules, "yaku_lists", [])
    # use this to handle values without units (old value format)
    default_value = fn value -> if not is_list(value) do [value, score_rules["point_name"]] else value end end
    {toposorted_yaku, skip_map} = yaku_lists
    |> Enum.map(&{&1, get(rules_ref, &1, [])})
    |> Enum.flat_map(fn {list_name, yaku_list} -> Enum.map(yaku_list, &Map.put(&1, :list_name, list_name)) end)
    |> Enum.map(&Map.update(&1, "value", [0, ""], default_value))
    |> Enum.map(&Map.put(&1, :key, [&1["display_name"], Enum.drop_every(&1["value"], 2)]))
    |> Enum.map(&Map.put(&1, :value_num, &1["value"] |> Enum.at(0, 0)))
    |> Enum.with_index()
    |> Enum.map(fn {yaku, ix} -> yaku |> Map.put(:ix, ix) end)
    |> toposort_yaku(get(rules_ref, "yaku_precedence", %{}))
    :ets.insert(rules_ref, {:yaku, toposorted_yaku})
    :ets.insert(rules_ref, {:yaku_by_key, Enum.group_by(toposorted_yaku, & &1.key)})
    :ets.insert(rules_ref, {:yaku_skip_map, skip_map})

    # generate shanten definitions if they don't exist
    shantens = [:win, :tenpai, :iishanten, :ryanshanten, :sanshanten, :suushanten, :uushanten, :roushanten]
    shanten_definitions = Map.new(shantens, fn shanten -> {shanten, translate_match_definitions(rules_ref, Map.get(rules, Atom.to_string(shanten) <> "_definition", []))} end)
    shanten_definitions = for {from, to} <- Enum.zip(Enum.drop(shantens, -1), Enum.drop(shantens, 1)), Enum.empty?(shanten_definitions[to]), reduce: shanten_definitions do
      shanten_definitions ->
        # IO.puts("Generating #{to} definitions")
        if length(shanten_definitions[from]) < 100 do
          next_definitions = MatchOld.compute_almost_match_definitions(shanten_definitions[from])
          if length(next_definitions) > 2 * length(shanten_definitions[from]) do
            # use "almost" keyword instead
            next_definitions = Enum.map(shanten_definitions[from], &["almost" | &1])
            Map.put(shanten_definitions, to, next_definitions)
          else
            Map.put(shanten_definitions, to, next_definitions)
          end
        else
          Map.put(shanten_definitions, to, [])
        end
    end
    :ets.insert(rules_ref, {:shanten_definitions, shanten_definitions})
    # IO.inspect(shanten_definitions, limit: :infinity, charlists: :as_lists)
    # IO.inspect(Map.new(shanten_definitions, fn {shanten, definition} -> {shanten, length(definition)} end))
    # IO.inspect(shanten_definitions.ryanshanten, limit: :infinity, charlists: :as_lists)

    # get all attributes used in the entire ruleset
    all_attrs = rules
    |> Enum.map(fn {_k, v} -> v end)
    |> List.flatten()
    |> Utils.reduce_json(fn %{"attrs" => attrs}, acc -> attrs ++ acc; _, acc -> acc end)
    |> MapSet.new()

    :ets.insert(rules_ref, {:all_attrs, all_attrs})
  end

  def get(rules_ref, key, default \\ nil)
  def get(nil, _key, default), do: default
  def get(rules_ref, key, default) do
    case :ets.lookup(rules_ref, key) do
      [{^key, value}] -> value
      [] -> default
    end
  rescue
    err ->
      Logger.error(err)
      default
  end

  def has_key?(nil, _key), do: false
  def has_key?(rules_ref, key) do
    case :ets.lookup(rules_ref, key) do
      [_] -> true
      [] -> false
    end
  rescue
    err ->
      Logger.error(err)
      false
  end

  def translate_sets_in_match_definitions(match_definitions, set_definitions) do
    for match_definition <- match_definitions do
      for match_definition_elem <- match_definition do
        case match_definition_elem do
          [groups, num] -> [Enum.flat_map(groups, &Map.get(set_definitions, &1, [&1])) |> Enum.map(fn [x] -> x; g -> g end), num]
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
  def translate_match_definitions(rules_ref, match_definitions, fail_silently? \\ false, depth \\ 0)
  def translate_match_definitions(_rules_ref, _match_definitions, _fail_silently?, depth) when depth >= 5, do: []
  def translate_match_definitions(rules_ref, match_definitions, fail_silently?, depth) do
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
                  if not fail_silently? do
                    GenServer.cast(self(), {:show_error, "Could not find match definition \"#{match_definition}_definition\" in the rules."})
                    nil
                  else [] end
                end
              named_match_definitions -> translate_match_definitions(rules_ref, named_match_definitions, fail_silently?, depth + 1)
            end
          is_list(match_definition)   -> translate_sets_in_match_definitions([match_definition], set_definitions)
          true                        ->
            if not fail_silently? do
              GenServer.cast(self(), {:show_error, "#{inspect(match_definition)} is not a valid match definition."})
              nil
            else [] end
        end
        if translated != nil and translated != [] and translated != [[]] do
          [translated | acc]
        else acc end
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
    |> Enum.map(&ModLoader.get_mod_name_config/1)
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
           |> then(&Map.merge(Map.get(starting_mods, mod["id"], %{}) |> Map.new(fn {name, value} -> {name, %{"values" => [value]}} end), &1))
           |> Map.new(fn {config_name, config} ->
                default = get_in(starting_mods[mod["id"]][config_name])
                default = if default == nil do Map.get(config, "default", Enum.at(config["values"], 0)) else default end
                # IO.puts("At mod #{mod["id"]} config name #{config_name}, passed in config is #{inspect(config)} with default #{inspect(default)}")
                config = Map.put(config, :value, default)
                config = if default != nil do
                  config = Map.put(config, "default", default)
                  # add given config's value to the list of allowable values if it isn't already in there
                  if default not in config["values"] do
                    values = case config["values"] do
                      [_] -> [default] # for hidden config, replace it
                      values -> [default | values]
                    end
                    Map.put(config, "values", values)
                  else config end
                else config end
                {config_name, config}
              end),
      order: Map.get(mod, "order", 0), # TODO replace this with "load_after" array, and do toposort on the result
      class: mod["class"],
      deps: Map.get(mod, "deps", []),
      conflicts: Map.get(mod, "conflicts", [])
    }} end)
    {mods, Enum.reverse(categories)}
  end

  # only used by tests!
  # given a ruleset, load its default mods plus the given mods and json config, and return a rules_ref
  # this rules_ref is essentially a clone of a long-lived cached rules_ref, so hopefully it's fast
  # RiichiAdvanced.GameState.Rules.load_default_ruleset("riichi", [], [])
  @always_ignored_default_mods [
    "cancellable_riichi",
    "dora",
    "ura",
    "kandora",
    "lib/tobi",
    "called_game",
    "shuugi/tobi",
    "shuugi/called_game",
  ]
  def load_default_ruleset(ruleset, mods, excluded_mods, json_config \\ "{}") do
    base_rules_ref = case RiichiAdvanced.Cache.get({:cache_default_ruleset, ruleset, mods, excluded_mods}) do
      {:ok, nil} ->
        forbidden_mods = excluded_mods ++ @always_ignored_default_mods
        base_ruleset_state = ModState.load_ruleset(ruleset)
        default_mods = base_ruleset_state
        |> ModState.apply_mods()
        |> ModState.append_jq({nil, "(.default_mods? // [])"})
        |> ModState.extract_json(no_cache: true)
        |> Jason.decode!()
        |> Enum.reject(fn mod -> ModLoader.get_mod_name(mod) in forbidden_mods or mod in forbidden_mods end)
        # |> IO.inspect(limit: :infinity, label: "default_mods")
        # IO.inspect(forbidden_mods, label: "forbidden_mods")

        # now apply these defaults to the base ruleset and return the rules ref
        ruleset_json = base_ruleset_state
        |> ModState.prepend_mods(default_mods)
        |> ModState.append_mods(mods)
        |> ModState.extract_json()
        {:ok, rules_ref} = load_rules(ruleset_json, ruleset)

        # cache if that was successful
        # need to first give it to a static dummy module so it stays alive
        RiichiAdvanced.Cache.put({:cache_default_ruleset, ruleset, mods, excluded_mods}, rules_ref)

        rules_ref
      {:ok, rules_ref} -> rules_ref
    end
    # create a clone that simply adds the json_config
    rules_ref = :ets.new(nil, [:set, :protected, read_concurrency: true])
    :ets.insert(rules_ref, :ets.tab2list(base_rules_ref))
    :ets.insert(rules_ref, json_config |> Jason.decode!() |> Map.to_list())
    rules_ref
  end
end
