defmodule RiichiAdvanced.ModLoader do
  alias RiichiAdvanced.Constants, as: Constants
  alias RiichiAdvanced.GameState.Debug, as: Debug
  alias RiichiAdvanced.Compiler, as: Compiler
  alias RiichiAdvanced.Parser, as: Parser

  def get_mod_name(mod) do
    case mod do
      %{name: name} -> name
      name -> name
    end
  end

  def read_mod(mod) do
    case mod do
      %{name: name, config: config} -> 
        mod_contents = read_mod_jq(name)
        config_queries = for {key, val} <- config, is_integer(val) or is_boolean(val) or is_binary(val), do: "(#{inspect(val)}) as $#{key}\n|\n"
        Enum.join(config_queries) <> "(" <> mod_contents <> ")"
      name -> read_mod_jq(name)
    end
  end

  def apply_multiple_mods(ruleset_json, mods, globals \\ %{}) do
    mod_contents = mods
    |> Enum.map(&read_mod/1)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.replace(&1, Compiler.header(), ""))
    |> Enum.map(&"(#{&1}\n) as $_result\n|\n$_result")
    global_jq = Enum.map(globals, fn {name, val} -> "(#{Jason.encode!(val)}) as $#{name}" end)
    boilerplate = [Compiler.header() <> "\n.enabled_mods += #{Jason.encode!(mods)}"]
    mod_jq = Enum.join(boilerplate ++ global_jq ++ mod_contents, "\n|")
    # IO.puts(mod_jq)
    if Debug.print_mods() do
      IO.puts("Applying mods [#{Enum.map_join(mods, ", ", &inspect/1)}]")
    end
    JQ.query_string_with_string!(ruleset_json, mod_jq)
  end

  def apply_mods(ruleset_json, mods, ruleset, globals \\ %{})
  def apply_mods(ruleset_json, [], _ruleset, _globals), do: ruleset_json
  def apply_mods(ruleset_json, mods, ruleset, globals) do
    orig_mods = mods
    mods = Enum.uniq(mods)
    if length(mods) < length(orig_mods) do
      IO.puts("Warning, the following mods were included twice: #{inspect(orig_mods -- mods)}")
    end
    case RiichiAdvanced.ETSCache.get({ruleset, mods}, [], :cache_mods) do
      [modded_json] ->
        # IO.puts("Using cached mods for ruleset #{ruleset}: #{inspect(mods)}")
        modded_json
      []     -> 
        # apply the mods
        # modded_json = Enum.reduce(mods, ruleset_json, &apply_mod/2)
        modded_json = apply_multiple_mods(ruleset_json, mods, globals)

        if Debug.print_mods() do
          mod_string = Enum.map_join(mods, ",\n  ", &Jason.encode!/1)
          |> String.replace(",\"", ", \"")
          |> String.replace(~r"\"([a-zA-Z0-9_]+?)\":", "\\1: ")
          |> String.replace("\":", "\" => ")
          |> String.replace("{", "%{")
          IO.puts("Loading #{ruleset}: [\n  #{mod_string}\n]")
        end
        
        if not Debug.skip_ruleset_caching() do
          RiichiAdvanced.ETSCache.put({ruleset, mods}, modded_json, :cache_mods)
        end

        modded_json
    end
  end

  def apply_post_mods(ruleset_json, ruleset) do
    modpacks = Constants.modpacks()
    if Map.has_key?(modpacks, ruleset) do
      modpack = modpacks[ruleset]
      post_mods = Map.get(modpack, :post_mods, [])
      apply_mods(ruleset_json, post_mods, modpack.ruleset, Map.get(modpack, :globals, %{}))
    else ruleset_json end
  end

  def convert_to_jq(majs) do
    # first check that it's not actually json
    case Jason.decode(majs) do
      {:ok, json}    -> ". * " <> Jason.encode!(json) # just merge the json (reencoding to ensure it's safe)
      {:error, _} -> 
        # now try to parse it as majs
        with {:ok, ast} <- Parser.parse(majs),
             {:ok, jq} <- Compiler.compile_jq(ast) do
          jq
        else
          {:error, msg} ->
            IO.puts("Error in convert_to_jq:")
            if is_binary(msg) do IO.puts(msg) else IO.inspect(msg) end
            IO.puts("Input majs was:")
            IO.puts(majs)
            "." # no-op
        end
    end
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
  def read_mod_jq(name) do
    case File.read(Application.app_dir(:riichi_advanced, "/priv/static/mods/#{name}.jq")) do
      {:ok, mod_jq} ->
        verify_jq(name, mod_jq)
        mod_jq
      {:error, _err}      ->
        case File.read(Application.app_dir(:riichi_advanced, "/priv/static/mods/#{name}.majs")) do
          {:ok, mod_majs} -> convert_to_jq(mod_majs)
          {:error, _err}  ->
            IO.puts("WARNING: Could not find mod #{name}!")
            "."
        end
    end
  end

  def get_ruleset_json(ruleset, room_code \\ nil, strip_comments? \\ false, visited \\ [], prev_query \\ ".", prev_mods \\ [], globals \\ %{}) do
    # IO.puts("Fetching ruleset #{ruleset}")
    modpacks = Constants.modpacks()
    cond do
      ruleset == "custom" and Enum.empty?(visited) ->
        case RiichiAdvanced.ETSCache.get(room_code, ["{}"], :cache_rulesets) do
          [ruleset_json_or_majs] ->
            case Jason.decode(ruleset_json_or_majs) do
              {:ok, _}    -> ruleset_json_or_majs
              {:error, _} -> JQ.query_string_with_string!("{}", convert_to_jq(ruleset_json_or_majs))
            end
          _ -> "{}"
        end
      Map.has_key?(modpacks, ruleset) and ruleset not in visited ->
        modpack = modpacks[ruleset]
        mods = Map.get(modpack, :mods, [])
        post_mods = Map.get(modpack, :post_mods, [])
        all_mod_names = Enum.map(mods ++ post_mods, fn
          %{name: name} -> name
          name          -> name
        end)
        default_mods = Map.get(modpack, :default_mods, []) |> Enum.reject(& &1 in all_mod_names)
        display_name = Map.get(modpack, :display_name, ruleset)
        # set default mods and display name
        query = ".default_mods += #{Jason.encode!(default_mods)} | .display_name = \"#{display_name}\""
        # set or remove tutorial link
        query = query <> " | " <> if Map.has_key?(modpack, :tutorial_link) do ".tutorial_link = \"#{modpack.tutorial_link}\"" else "del(.tutorial_link)" end
        # remove already applied mods
        query = query <> " | " <> ".default_mods = (.default_mods // []) - #{Jason.encode!(all_mod_names)}"
        query = query <> " | " <> ".available_mods = ((.available_mods // []) | map(select(if type == \"object\" then .id else .  end | IN(#{Enum.map_join(all_mod_names, ", ", &Jason.encode!/1)}) | not)))"
        # we're traversing down, so "new" query/mods/globals should be run before "old" ones
        query = query <> "\n|\n" <> prev_query
        mods = mods ++ prev_mods
        globals = Map.merge(Map.get(modpack, :globals, %{}), globals)
        # now recurse
        get_ruleset_json(modpack.ruleset, room_code, true, [ruleset | visited], query, mods, globals)
      true ->
        ruleset_json = read_ruleset_json(ruleset)
        if strip_comments? do
          mods = Enum.uniq(prev_mods)
          duplicates = prev_mods -- mods
          if not Enum.empty?(duplicates) do
            IO.puts("WARNING: these mods were included twice: #{inspect(duplicates)}")
          end
          ruleset_json
          |> strip_comments()
          |> apply_mods(mods, ruleset, globals)
          |> JQ.query_string_with_string!(prev_query)
        else ruleset_json end
    end
  end

  @default_config """
  # this is for advanced users!
  # this mahjongscript gets applied to the ruleset after applying other mods
  # so basically here is where you write a custom mod
  # see documentation here: https://github.com/EpicOrange/riichi_advanced/blob/main/documentation/documentation.md
  # feel free to submit your mod to the repository by opening an issue or pull request!

  # the examples below are helpful to test out yaku and stuff

  # set starting_hand, %{
  #   "east": ["1m", "9m", "1p", "9p", "1s", "9s", "1z", "2z", "3z", "4z", "5z", "6z", "7z"]
  # }
  # set starting_draws, ["1z", "2z", "3z", "4z", "1z", "2z", "3z", "4z", "1z", "2z", "3z", "4z"]
  # set starting_dead_wall, ["5m", "4m"] # so the first kan draw is 5m. this goes backwards
  # set starting_round, 4 # start in south round
  # set debug_status, true # show statuses, counters, and buttons
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
