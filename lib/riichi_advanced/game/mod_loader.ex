defmodule RiichiAdvanced.ModLoader do
  alias RiichiAdvanced.GameState.Debug, as: Debug

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
    |> then(&"."<>&1)

    # IO.puts(mod_contents)

    # write to path
    {fd, query_path} = Temp.open!(%{mode: [:write, :utf8]})
    IO.write(fd, mod_contents)
    File.close(fd)

    try do
      IO.puts("Applying mods #{Enum.join(mod_names, ", ")}")
      JQ.query_string!(ruleset_json, query_path)
    after
      File.rm!(query_path)
    end
  end

  def apply_mods(ruleset, ruleset_json, mod_names) do
    case RiichiAdvanced.ETSCache.get({ruleset, mod_names}, [], :cache_mods) do
      [modded_json] ->
        IO.puts("Using cached mods for ruleset #{ruleset}: #{inspect(mod_names)}")
        modded_json
      []     -> 
        # apply the mods
        # modded_json = Enum.reduce(mod_names, ruleset_json, &apply_mod/2)
        modded_json = apply_multiple_mods(ruleset_json, mod_names)

        # list out the mods as a "enabled_mods" key, via string replacement
        # if the json file is empty, don't add a trailing comma
        trailing_comma = if String.contains?(modded_json, "\"") do "," else "" end
        modded_json = String.replace(modded_json, "{", "{\"enabled_mods\": [" <> Enum.join(Enum.map(mod_names, &"\"#{&1}\""), ", ") <> "]" <> trailing_comma, global: false)

        if not Debug.skip_ruleset_caching() do
          RiichiAdvanced.ETSCache.put({ruleset, mod_names}, modded_json, :cache_mods)
        end

        modded_json
    end
  end

end
