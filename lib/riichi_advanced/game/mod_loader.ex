defmodule RiichiAdvanced.ModLoader do
  alias RiichiAdvanced.GameState.Debug, as: Debug

  def apply_mod(mod_name, ruleset_json) do
    # apply mods
    query_path = Application.app_dir(:riichi_advanced, "/priv/static/mods/#{mod_name <> ".jq"}")
    IO.puts("Applying mod #{mod_name}")
    ruleset_json = JQ.query_string!(ruleset_json, query_path)
    ruleset_json
  end

  def apply_mods(ruleset, ruleset_json, mod_names) do
    case RiichiAdvanced.ETSCache.get({ruleset, mod_names}, [], :cache_mods) do
      [modded_json] ->
        IO.puts("Using cached mods for ruleset #{ruleset}: #{inspect(mod_names)}")
        modded_json
      []     -> 
        # apply the mods
        modded_json = Enum.reduce(mod_names, ruleset_json, &apply_mod/2)

        # list out the mods as a "enabled_mods" key, via string replacement
        modded_json = if String.contains?(modded_json, "\"") do
          String.replace(modded_json, "{", "{\"enabled_mods\":" <> inspect(mod_names) <> ",", global: false)
        else
          # if the json file is empty, don't add the comma
          String.replace(modded_json, "{", "{\"enabled_mods\":" <> inspect(mod_names), global: false)
        end

        if not Debug.skip_ruleset_caching() do
          RiichiAdvanced.ETSCache.put({ruleset, mod_names}, modded_json, :cache_mods)
        end

        modded_json
    end
  end

end
