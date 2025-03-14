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
        Enum.join(config_queries) <> mod_contents
      name -> read_mod_jq(name)
    end
  end

  def apply_multiple_mods(ruleset_json, mods) do
    mod_contents = mods
    |> Enum.map(&read_mod/1)
    |> Enum.map(&String.trim/1)
    |> Enum.map_join(&" | (#{&1}\n) as $_result\n|\n$_result")
    |> then(&".enabled_mods += #{Jason.encode!(mods)}"<>&1)

    if Debug.print_mods() do
      IO.puts("Applying mods [#{Enum.map_join(mods, ", ", &inspect/1)}]")
    end
    JQ.query_string_with_string!(ruleset_json, mod_contents)
  end

  def apply_mods(ruleset_json, mods, ruleset) do
    orig_mods = mods
    mods = Enum.uniq(mods)
    if length(mods) < length(orig_mods) do
      IO.puts("Warning, the following mods were included twice: #{inspect(orig_mods -- mods)}")
    end
    case RiichiAdvanced.ETSCache.get({ruleset, mods}, [], :cache_mods) do
      [modded_json] ->
        IO.puts("Using cached mods for ruleset #{ruleset}: #{inspect(mods)}")
        modded_json
      []     -> 
        # apply the mods
        # modded_json = Enum.reduce(mods, ruleset_json, &apply_mod/2)
        modded_json = apply_multiple_mods(ruleset_json, mods)

        if Debug.print_mods() do
          IO.puts("Loading #{ruleset}: [\n  #{Enum.map_join(mods, ",\n  ", &Jason.encode!/1)}\n]")
        end
        
        if not Debug.skip_ruleset_caching() do
          RiichiAdvanced.ETSCache.put({ruleset, mods}, modded_json, :cache_mods)
        end

        modded_json
    end
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

  def read_mod_jq(name) do
    case File.read(Application.app_dir(:riichi_advanced, "/priv/static/mods/#{name}.jq")) do
      {:ok, mod_jq} -> mod_jq
      {:error, _err}      ->
        case File.read(Application.app_dir(:riichi_advanced, "/priv/static/mods/#{name}.majs")) do
          {:ok, mod_majs} -> convert_to_jq(mod_majs)
          {:error, _err}  -> "."
        end
    end
  end

  def get_ruleset_json(ruleset, room_code \\ nil, strip_comments? \\ false) do
    modpacks = Constants.modpacks()
    cond do
      ruleset == "custom" ->
        case RiichiAdvanced.ETSCache.get(room_code, ["{}"], :cache_rulesets) do
          [ruleset_json_or_majs] ->
            case Jason.decode(ruleset_json_or_majs) do
              {:ok, _}    -> ruleset_json_or_majs
              {:error, _} -> JQ.query_string_with_string!("{}", convert_to_jq(ruleset_json_or_majs))
            end
          _ -> "{}"
        end
      Map.has_key?(modpacks, ruleset) ->
        modpack = modpacks[ruleset]
        mods = Map.get(modpack, :mods, [])
        display_name = Map.get(modpack, :display_name, ruleset)
        query = ".default_mods += #{Jason.encode!(Map.get(modpack, :default_mods, []))} | .display_name = \"#{display_name}\""
        query = query <> " | " <> if Map.has_key?(modpack, :tutorial_link) do ".tutorial_link = \"#{modpack.tutorial_link}\"" else "del(.tutorial_link)" end
        modpack.ruleset
        |> read_ruleset_json()
        |> strip_comments()
        |> apply_mods(mods, modpack.ruleset)
        |> JQ.query_string_with_string!(query)
      true ->
        ruleset_json = read_ruleset_json(ruleset)
        if strip_comments? do strip_comments(ruleset_json) else ruleset_json end
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
