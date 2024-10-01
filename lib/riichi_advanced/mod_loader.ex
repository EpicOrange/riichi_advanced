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
    Enum.reduce(mod_names, ruleset_json, &apply_mod/2)
  end

end
