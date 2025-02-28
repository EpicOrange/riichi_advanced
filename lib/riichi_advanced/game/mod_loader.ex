defmodule RiichiAdvanced.ModLoader do
  alias RiichiAdvanced.Constants, as: Constants
  alias RiichiAdvanced.GameState.Debug, as: Debug

  def get_mod_name(mod) do
    case mod do
      %{name: name} -> name
      name -> name
    end
  end

  def read_mod(mod) do
    case mod do
      %{name: name, config: config} -> 
        mod_contents = File.read!(Application.app_dir(:riichi_advanced, "/priv/static/mods/#{name <> ".jq"}"))
        config_queries = for {key, val} <- config, is_integer(val) or is_boolean(val) or is_binary(val), do: "(#{inspect(val)}) as $#{key}\n|\n"
        Enum.join(config_queries) <> mod_contents
      name -> File.read!(Application.app_dir(:riichi_advanced, "/priv/static/mods/#{name <> ".jq"}"))
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

  defp read_ruleset_json(ruleset) do
    case File.read(Application.app_dir(:riichi_advanced, "/priv/static/rulesets/#{ruleset}.json")) do
      {:ok, ruleset_json} -> ruleset_json
      {:error, _err}      -> "{}"
    end
  end

  def get_ruleset_json(ruleset, room_code \\ nil, strip_comments? \\ false) do
    if ruleset == "custom" do
      case RiichiAdvanced.ETSCache.get(room_code, ["{}"], :cache_rulesets) do
        [ruleset_json] -> ruleset_json
        _ -> "{}"
      end
    else
      modpacks = Constants.modpacks()
      if Map.has_key?(modpacks, ruleset) do
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
      else
        ruleset_json = read_ruleset_json(ruleset)
        if strip_comments? do strip_comments(ruleset_json) else ruleset_json end
      end
    end
  end

  @default_config """
  {
    // this is for advanced users!
    // this JSON gets merged into the existing ruleset (after applying mods)
    // the below is helpful to test out yaku and stuff

    // "starting_hand": {
    //   "east": ["1m", "9m", "1p", "9p", "1s", "9s", "1z", "2z", "3z", "4z", "5z", "6z", "7z"]
    // },
    // "starting_draws": ["1z", "2z", "3z", "4z", "1z", "2z", "3z", "4z", "1z", "2z", "3z", "4z"],
    // "starting_dead_wall": ["5m", "4m"], // so the first kan draw is 5m. this goes backwards
    // "starting_round": 4, // start in south round
    // "debug_status": true // show statuses, counters, and buttons
  }
  """

  def get_config_json(ruleset, room_code) do
    case RiichiAdvanced.ETSCache.get({ruleset, room_code}, [@default_config], :cache_configs) do
      [ruleset_json] -> ruleset_json
      _ -> @default_config
    end
  end

  def strip_comments(json) do
    Regex.replace(~r{^//.*|\s//.*|/\*[.\n]*?\*/}, json, "")
  end
end
