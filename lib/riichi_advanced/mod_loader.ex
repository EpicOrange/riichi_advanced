defmodule RiichiAdvanced.ModLoader do

  def apply_mod(mod_name, ruleset_json) do
    # apply mods
    mod = case File.read(Application.app_dir(:riichi_advanced, "/priv/static/mods/#{mod_name <> ".jq"}")) do
      {:ok, mod}     -> mod
      {:error, _err} -> nil
    end
    IO.puts("Applying mod #{mod_name}: #{mod}")
    ruleset_json = JQ.query_string!(ruleset_json, mod)
    ruleset_json
  end

  def apply_mods(ruleset_json, mod_names) do
    # first list out the mods as a "enabled_mods" key
    # do this via string replacement
    enabled_mods = "\"enabled_mods\":" <> inspect(mod_names) <> ","
    ruleset_json = String.replace(ruleset_json, "{", "{" <> enabled_mods, global: false)

    # then apply the mods
    Enum.reduce(mod_names, ruleset_json, &apply_mod/2)
  end

end
