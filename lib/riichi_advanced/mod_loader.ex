defmodule RiichiAdvanced.ModLoader do

  def apply_mod(mod_name, ruleset_json) do
    # apply mods
    query_path = Application.app_dir(:riichi_advanced, "/priv/static/mods/#{mod_name <> ".jq"}")
    IO.puts("Applying mod #{mod_name}")
    ruleset_json = JQ.query_string!(ruleset_json, query_path)
    ruleset_json
  end

  def apply_mods(ruleset_json, mod_names) do
    # apply the mods
    modded_json = Enum.reduce(mod_names, ruleset_json, &apply_mod/2)

    # list out the mods as a "enabled_mods" key, via string replacement
    modded_json = if String.contains?(modded_json, "\"") do
      String.replace(modded_json, "{", "{\"enabled_mods\":" <> inspect(mod_names) <> ",", global: false)
    else
      # if the json file is empty, don't add the comma
      String.replace(modded_json, "{", "{\"enabled_mods\":" <> inspect(mod_names), global: false)
    end

    modded_json
  end

end
