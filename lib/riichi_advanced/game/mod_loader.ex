defmodule RiichiAdvanced.ModLoader do
  alias RiichiAdvanced.GameState.Debug, as: Debug

  defp mod_names_to_array(mod_names) do
    "[" <> Enum.join(Enum.map(mod_names, &"\"#{&1}\""), ", ") <> "]"
  end

  def apply_single_mod(mod_name, ruleset_json) do
    # apply mods
    query_path = Application.app_dir(:riichi_advanced, "/priv/static/mods/#{mod_name <> ".jq"}")
    IO.puts("Applying mod #{mod_name}")
    ruleset_json = JQ.query_string!(ruleset_json, query_path)
    ruleset_json
  end

  def apply_multiple_mods(ruleset_json, mod_names) do
    mod_contents = mod_names
    |> Enum.map(&File.read!(Application.app_dir(:riichi_advanced, "/priv/static/mods/#{&1 <> ".jq"}")))
    |> Enum.map(&String.trim/1)
    |> Enum.map(&Regex.replace(~r{\s#.*}, &1, "")) # strip comments
    |> Enum.map(&" | (#{&1}) as $_result\n|\n$_result")
    |> Enum.join()
    |> then(&".enabled_mods += #{mod_names_to_array(mod_names)}"<>&1)
    # IO.puts(mod_contents)

    IO.puts("Applying mods #{Enum.join(mod_names, ", ")}")
    JQ.query_string_with_string!(ruleset_json, mod_contents)
  end

  def apply_mods(ruleset_json, mod_names, ruleset) do
    case RiichiAdvanced.ETSCache.get({ruleset, mod_names}, [], :cache_mods) do
      [modded_json] ->
        IO.puts("Using cached mods for ruleset #{ruleset}: #{inspect(mod_names)}")
        modded_json
      []     -> 
        # apply the mods
        # modded_json = Enum.reduce(mod_names, ruleset_json, &apply_mod/2)
        modded_json = apply_multiple_mods(ruleset_json, mod_names)

        if not Debug.skip_ruleset_caching() do
          RiichiAdvanced.ETSCache.put({ruleset, mod_names}, modded_json, :cache_mods)
        end

        modded_json
    end
  end

  @modpacks %{
    "sanma" => %{
      display_name: "Sanma",
      ruleset: "riichi",
      mods: ["sanma"],
      default_mods: [],
    }
  }

  defp read_ruleset_json(ruleset) do
    case File.read(Application.app_dir(:riichi_advanced, "/priv/static/rulesets/#{ruleset <> ".json"}")) do
      {:ok, ruleset_json} -> ruleset_json
      {:error, _err}      -> "{}"
    end
  end

  def get_ruleset_json(ruleset, session_id \\ nil, strip_comments \\ false) do
    if ruleset == "custom" do
      case RiichiAdvanced.ETSCache.get(session_id, ["{}"], :cache_rulesets) do
        [ruleset_json] -> ruleset_json
        _ -> "{}"
      end
    else
      if Map.has_key?(@modpacks, ruleset) do
        modpack = @modpacks[ruleset]
        mod_names = Map.get(modpack, :mods, [])
        display_name = Map.get(modpack, :display_name, ruleset)
        query = ".default_mods += #{mod_names_to_array(Map.get(modpack, :default_mods, []))} | .display_name = \"#{display_name}\""
        query = query <> " | " <> if Map.has_key?(modpack, :tutorial_link) do ".tutorial_link = #{modpack.tutorial_link}" else "del(.tutorial_link)" end
        Regex.replace(~r{ //.*|/\*[.\n]*?\*/}, read_ruleset_json(modpack.ruleset), "")
        |> apply_mods(mod_names, modpack.ruleset)
        |> JQ.query_string_with_string!(query)
      else
        ruleset_json = read_ruleset_json(ruleset)
        if strip_comments do
          Regex.replace(~r{ //.*|/\*[.\n]*?\*/}, ruleset_json, "")
        else ruleset_json end
      end
    end
  end
end
