
# should probably explain how this works
# you'll have a ruleset name and a list of mods
# first, you'll call ModLoader.get_ruleset_json to get {ruleset_json, defs}
# this will give you a base json, which is either
# 1) the parsed json object direct from a file
# 2) if ruleset is a modpack in Constants.modpacks then
#    it applies all the `mods ++ post_mods` in the modpack to the given ruleset.
#    this can recurse if the base ruleset of the modpack is also in Constants.modpacks
#    (we do check for loops, don't worry)
# meanwhile `defs` contains all `define` clauses used in `if defined(...)`
# after this, you can use ModLoader.apply_mods to add more mods on top of your base json
# ModLoader.apply_post_mods just does ModLoader.apply_mods using the `post_mods` field of a given modpack

defmodule RiichiAdvanced.ModLoader do
  alias RiichiAdvanced.Constants, as: Constants
  alias RiichiAdvanced.GameState.Debug, as: Debug
  alias RiichiAdvanced.Compiler, as: Compiler
  alias RiichiAdvanced.Parser, as: Parser

  def get_mod_name(mod) do
    case mod do
      %{"name" => name}         -> name
      %{name: name}             -> name
      name when is_binary(name) -> name
    end
  end

  def get_mod_name_config(mod) do
    case mod do
      %{"name" => name, "config" => config} -> {name, config}
      %{name: name, config: config}         -> {name, config}
      name when is_binary(name)             -> {name, %{}}
    end
  end

  defp is_jq_var?(key) when is_binary(key), do: Regex.match?(~r/^[a-zA-Z_][a-zA-Z0-9_]*$/, key)
  defp is_jq_var?(key) when is_atom(key), do: Regex.match?(~r/^[a-zA-Z_][a-zA-Z0-9_]*$/, Atom.to_string(key))
  defp is_jq_var?(_key), do: false

  defp read_mod(mod, defs) do
    {name, config} = get_mod_name_config(mod)
    {mod_contents, defs} = read_mod_jq_defs(name, defs)
    config_queries = for {key, val} <- config, is_integer(val) or is_boolean(val) or is_binary(val), is_jq_var?(key), do: "(#{inspect(val)}) as $#{key}\n|\n"
    {Enum.join(config_queries) <> "(" <> mod_contents <> ")", defs}
  end

  def apply_multiple_mods(ruleset_json, mods, globals \\ %{}, defs \\ MapSet.new()) do
    {jqs, defs} = for mod <- mods, reduce: {[], defs} do
      {acc, defs} ->
        {jq, defs} = read_mod(mod, defs)
        {[jq | acc], defs}
    end
    mod_contents = jqs
    |> Enum.reverse()
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.replace(&1, Compiler.header(), ""))
    |> Enum.map(&"(#{&1}\n) as $_result\n|\n$_result")
    global_jq = for {name, val} <- globals, is_jq_var?(name), do: "(#{Jason.encode!(val)}) as $#{name}"
    boilerplate = [Compiler.header() <> if Enum.empty?(mods) do "." else "\n.enabled_mods += #{Jason.encode!(mods)}" end]
    mod_jq = Enum.join(boilerplate ++ global_jq ++ mod_contents, "\n|")
    # IO.puts(mod_jq)
    if Debug.print_mods() do
      IO.puts("Applying mods [#{Enum.map_join(mods, ", ", &inspect/1)}]")
    end
    {JQ.query_string_with_string!(ruleset_json, mod_jq), defs}
  end

  # def check_and_apply_mods(ruleset_json, input_mods, ruleset) do
  #   # check the ruleset to see and set missing default configs
  #   # note this only checks for mods mentioned in ruleset_json
  #   # so mods added by other mods will not be checked
  #   input_mods =
  #     with {:ok, decoded} <- Rules.decode_ruleset_json(ruleset_json, ruleset),
  #          {mods, _categories} <- Rules.parse_available_mods(Map.get(decoded, "available_mods", []), Map.get(decoded, "default_mods", [])) do
  #       # normalize to {name, config} just for this part
  #       input_mods = Enum.map(input_mods, &get_mod_name_config/1)
  #       for {name, config} <- input_mods do
  #         config = if Map.has_key?(mods, name) do
  #           # check if there is more config we haven't mentioned
  #           missing_config = Map.keys(mods[name].config) -- Map.keys(config)
  #           for config_name <- missing_config, reduce: config do
  #             config ->
  #               config_obj = mods[name].config[config_name]
  #               default = Map.get(config_obj, "default", Enum.at(config_obj["values"], 0))
  #               Map.put(config, config_name, default)
  #           end
  #         else config end
  #         if Enum.empty?(config) do name else %{name: name, config: config} end
  #       end
  #     end
  #   apply_mods(ruleset_json, input_mods, ruleset)
  # end

  # ruleset argument used only for debug outputs and as a cache key
  def apply_mods(ruleset_json, mods, ruleset, globals \\ %{}, defs \\ MapSet.new())
  def apply_mods(ruleset_json, [], _ruleset, _globals, defs), do: {ruleset_json, defs}
  def apply_mods(ruleset_json, mods, ruleset, globals, defs) do
    orig_mods = mods
    mods = Enum.uniq(mods)
    if length(mods) < length(orig_mods) do
      IO.puts("Warning, the following mods (for ruleset #{ruleset}) were included twice: #{inspect(orig_mods -- mods)}")
    end
    case RiichiAdvanced.ETSCache.get({ruleset, mods}, [], :cache_json) do
      [{modded_json, defs}] ->
        # IO.puts("Using cached mods for ruleset #{ruleset}: #{inspect(mods)}")
        {modded_json, defs}
      []     -> 
        # apply the mods
        # modded_json = Enum.reduce(mods, ruleset_json, &apply_mod/2)
        {modded_json, defs} = apply_multiple_mods(ruleset_json, mods, globals, defs)

        if Debug.print_mods() do
          mod_string = Enum.map_join(mods, ",\n  ", &Jason.encode!/1)
          |> String.replace(",\"", ", \"")
          |> String.replace(~r"\"([a-zA-Z0-9_]+?)\":", "\\1: ")
          |> String.replace("\":", "\" => ")
          |> String.replace("{", "%{")
          IO.puts("Loading #{ruleset}: [\n  #{mod_string}\n]")
        end
        
        if not Debug.skip_ruleset_caching() do
          RiichiAdvanced.ETSCache.put({ruleset, mods}, {modded_json, defs}, :cache_json)
        end

        {modded_json, defs}
    end
  end

  def apply_post_mods(ruleset_json, ruleset, defs \\ MapSet.new()) do
    modpacks = Constants.modpacks()
    if Map.has_key?(modpacks, ruleset) do
      modpack = modpacks[ruleset]
      post_mods = Map.get(modpack, :post_mods, [])
      apply_mods(ruleset_json, post_mods, modpack.ruleset, Map.get(modpack, :globals, %{}), defs)
    else {ruleset_json, defs} end
  end

  def convert_to_jq_defs(majs, defs \\ MapSet.new()) do
    # first check that it's not actually json
    case Jason.decode(majs) do
      {:ok, json}    -> {". * " <> Jason.encode!(json), defs} # just merge the json (reencoding to ensure it's safe)
      {:error, _} -> 
        # now try to parse it as majs
        with {:ok, ast} <- Parser.parse(majs),
             {:ok, {jq, defs}} <- Compiler.compile_jq_defs(ast, defs) do
          {jq, defs}
        else
          {:error, msg} ->
            IO.puts("Error in convert_to_jq:")
            if is_binary(msg) do IO.puts(msg) else IO.inspect(msg) end
            IO.puts("Input majs was:")
            IO.puts(majs)
            {".", defs} # no-op
        end
    end
  end
  def convert_to_jq(majs) do
    {jq, _defs} = convert_to_jq_defs(majs)
    jq
  end

  defp read_ruleset_json(ruleset) do
    case File.read(Application.app_dir(:riichi_advanced, "/priv/static/rulesets/#{ruleset}.json")) do
      {:ok, ruleset_json} -> ruleset_json
      {:error, _err}      ->
        case File.read(Application.app_dir(:riichi_advanced, "/priv/static/rulesets/#{ruleset}.majs")) do
          {:ok, ruleset_majs} -> JQ.query_string_with_string!("{}", convert_to_jq(ruleset_majs))
          {:error, _err}      -> "{}"
        end
    end
  end

  @some_majs_commands ["set", "on", "define_set", "define_match", "define_const", "define_yaku", "define_yaku_precedence", "remove_yaku", "replace_yaku", "define_button", "define_auto_button", "define_mod_category", "define_mod", "config_mod", "remove_mod", "apply", "replace_all"]
  defp verify_jq(name, jq) do
    # this is mostly for in case you forget to change the .jq extension to .majs
    jq
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1) |> Enum.at(0))
    |> Enum.any?(& &1 in @some_majs_commands)
    |> if do
      IO.puts("\nWARNING: file #{name}.jq looks kind of like .majs!\n")
    end
  end
  defp read_mod_jq_defs(name, defs) do
    case File.read(Application.app_dir(:riichi_advanced, "/priv/static/mods/#{name}.jq")) do
      {:ok, mod_jq} ->
        verify_jq(name, mod_jq)
        {mod_jq, defs}
      {:error, _err}      ->
        case File.read(Application.app_dir(:riichi_advanced, "/priv/static/mods/#{name}.majs")) do
          {:ok, mod_majs} -> convert_to_jq_defs(mod_majs, defs)
          {:error, _err}  ->
            IO.puts("WARNING: Could not find mod #{name}!")
            {".", defs}
        end
    end
  end

  def get_ruleset_json(ruleset, room_code \\ nil, apply_mods? \\ false, visited \\ [], prev_query \\ ".", prev_mods \\ [], globals \\ %{}) do
    # IO.puts("Fetching ruleset #{ruleset}")
    modpacks = Constants.modpacks()
    cond do
      ruleset == "custom" and Enum.empty?(visited) ->
        ruleset_json = case RiichiAdvanced.ETSCache.get(room_code, ["{}"], :cache_rulesets) do
          [ruleset_json_or_majs] ->
            case Jason.decode(ruleset_json_or_majs) do
              {:ok, _}    -> ruleset_json_or_majs
              {:error, _} -> JQ.query_string_with_string!("{}", convert_to_jq(ruleset_json_or_majs))
            end
          _ -> "{}"
        end
        {ruleset_json, MapSet.new()}
      Map.has_key?(modpacks, ruleset) and ruleset not in visited ->
        case RiichiAdvanced.ETSCache.get({ruleset, []}, [], :cache_json) do
          [{ruleset_json, defs}] -> {ruleset_json, defs}
          _ ->
            modpack = modpacks[ruleset]
            mods = Map.get(modpack, :mods, [])
            post_mods = Map.get(modpack, :post_mods, [])
            all_mod_ids = Enum.map(mods ++ post_mods, fn
              %{name: id} -> id
              id          -> id
            end)
            default_mods = Map.get(modpack, :default_mods, []) |> Enum.reject(fn
              id when is_binary(id) -> id in all_mod_ids
              mod -> mod.name in all_mod_ids
            end)
            # set default mods
            query = ".default_mods += #{Jason.encode!(default_mods)}"
            # set or remove display name and/or tutorial link
            query = query <> case Map.get(modpack, :display_name, nil) do
              nil          -> ""
              :delete      -> "| del(.tutorial_link)"
              display_name -> " | .display_name = \"#{display_name}\""
            end
            query = query <> case Map.get(modpack, :tutorial_link, nil) do
              nil           -> ""
              :delete       -> "| del(.tutorial_link)"
              tutorial_link -> "| .tutorial_link = \"#{tutorial_link}\""
            end
            # remove already applied mods
            query = if not Enum.empty?(all_mod_ids) do
              query = query <> " | " <> ".default_mods = (.default_mods // []) - #{Jason.encode!(all_mod_ids)}"
              query = query <> " | " <> ".available_mods = ((.available_mods // []) | map(select(if type == \"object\" then .id else .  end | IN(#{Enum.map_join(all_mod_ids, ", ", &Jason.encode!/1)}) | not)))"
              query
            else query end
            # we're traversing down, so "new" query/mods/globals should be run before "old" ones
            query = query <> "\n|\n" <> prev_query
            mods = mods ++ prev_mods
            globals = Map.merge(Map.get(modpack, :globals, %{}), globals)
            # now recurse
            get_ruleset_json(modpack.ruleset, room_code, true, [ruleset | visited], query, mods, globals)
        end
      true ->
        ruleset_json = read_ruleset_json(ruleset)
        if apply_mods? do
          mods = Enum.uniq(prev_mods)
          duplicates = prev_mods -- mods
          if not Enum.empty?(duplicates) do
            IO.puts("WARNING: these mods (for ruleset #{ruleset}) were included twice: #{inspect(duplicates)}")
          end
          {ruleset_json, defs} = ruleset_json
          |> strip_comments()
          |> apply_mods(mods, ruleset, globals)
          ruleset_json = JQ.query_string_with_string!(ruleset_json, prev_query)
          if not Debug.skip_ruleset_caching() do
            RiichiAdvanced.ETSCache.put({ruleset, mods}, {ruleset_json, defs}, :cache_json)
          end
          {ruleset_json, defs}
          # |> IO.inspect(limit: :infinity)
        else {ruleset_json, MapSet.new()} end
    end
  end

  @default_config """
  # this is for advanced users!
  # this mahjongscript gets applied to the ruleset after applying other mods
  # so basically here is where you write a custom mod
  # see documentation here: https://github.com/EpicOrange/riichi_advanced/blob/main/documentation/documentation.md
  # feel free to submit your mod to the repository by opening an issue or pull request!

  # here are some useful toggles

  # set win_timer, 30 # how many seconds before win screen goes "next"
  # set tsumogiri_bots, true # make bots only discard their draws (if possible)

  # these are are helpful to test out yaku and stuff

  # set debug_status, true # show statuses, counters, and buttons
  # set starting_hand, %{
  #   "east": ["1m", "9m", "1p", "9p", "1s", "9s", "1z", "2z", "3z", "4z", "5z", "6z", "7z"]
  # }
  # set starting_draws, ["1z", "2z", "3z", "4z", "1z", "2z", "3z", "4z", "1z", "2z", "3z", "4z"]
  # set starting_dead_wall, ["5m", "4m"] # so the first kan draw is 5m. this goes backwards
  # set starting_round, 4 # start in south 1
  """

  def default_config, do: @default_config

  def get_config_majs(ruleset, room_code) do
    case RiichiAdvanced.ETSCache.get({ruleset, room_code}, nil, :cache_configs) do
      [config_majs] -> config_majs
      _ -> @default_config
    end
  end

  def strip_comments(json) do
    Regex.replace(~r{^//.*|\s//.*|/\*[.\n]*?\*/}, json, "")
  end
end
