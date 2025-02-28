defmodule RiichiAdvanced.SimpleParseTest do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.Constants, as: Constants
  alias RiichiAdvanced.ModLoader, as: ModLoader

  test "parse all rulesets" do
    for ruleset_path <- Path.wildcard(Application.app_dir(:riichi_advanced, "/priv/static/rulesets/**.json")) do
      ruleset = Path.basename(ruleset_path, ".json")
      ruleset_json = ModLoader.get_ruleset_json(ruleset)
      assert ruleset_json != ""
    end
  end

  test "parse all mods" do
    for ruleset_path <- Path.wildcard(Application.app_dir(:riichi_advanced, "/priv/static/rulesets/**.json")) do
      ruleset = Path.basename(ruleset_path, ".json")
      ruleset_json = ModLoader.get_ruleset_json(ruleset, nil, true)
      assert ruleset_json != nil
      rules = Jason.decode!(ModLoader.strip_comments(ruleset_json))
      mod_list = Map.get(rules, "available_mods", [])
      |> Enum.filter(&is_map/1)
      mods = for {mod, i} <- Enum.with_index(mod_list), into: %{} do
        mod_name = mod["id"]
        assert mod_name != nil
        config = for config <- Map.get(mod, "config", []), into: %{} do
          name = config["name"]
          values = config["values"]
          assert name != nil
          assert values != nil

          default_value = Map.get(config, "default", Enum.at(values, 0))
          assert default_value in values
          {name, default_value}
        end
        order = Map.get(mod, "order", 0)
        deps = Map.get(mod, "deps", [])
        conflicts = Map.get(mod, "conflicts", [])
        {mod_name, %{
          name: mod_name,
          spec: if Enum.empty?(config) do mod_name else %{name: mod_name, config: config} end,
          order: {order, i},
          deps: deps,
          conflicts: conflicts,
          config: config
        }}
      end
      # make sure each mod works when applied individually (after dependencies)
      for mod <- Map.values(mods) do
        for dep <- mod.deps do
          assert Map.has_key?(mods, dep), "Mod #{mod.name} for ruleset #{ruleset} can't find dependency #{dep}"
        end
        mod_specs = mod.deps
        |> Enum.sort_by(&mods[&1].order)
        |> Enum.map(&mods[&1].spec)
        mod_specs = mod_specs ++ [mod.spec]
        # IO.inspect(mod_specs)
        modded = ModLoader.apply_multiple_mods(ruleset_json, mod_specs)
        assert modded != nil, "Failed to apply mods #{inspect(mod_specs)} to ruleset #{ruleset})"
      end
    end
  end

  test "parse all tutorials" do
    for tutorial_path <- Path.wildcard(Application.app_dir(:riichi_advanced, "/priv/static/tutorials/**.json")) do
      tutorial_id = Path.basename(tutorial_path, ".json")
      sequence_json = File.read!(tutorial_path)
      assert sequence_json != ""
      sequence = Jason.decode!(ModLoader.strip_comments(sequence_json))

      ruleset = Enum.find(Constants.tutorials(), fn {_ruleset, tutorials} ->
        Enum.any?(tutorials, fn {id, _title, _seat} -> id == tutorial_id end)
      end)
      |> case do
        {ruleset, _tutorials} -> ruleset
        nil -> nil
      end
      if ruleset != nil do
        mod_specs = Map.get(sequence, "mods", [])
        |> Enum.map(&case &1 do
          %{"name" => name, "config" => config} -> %{name: name, config: config}
          name -> name
        end)
        ruleset_json = ModLoader.get_ruleset_json(ruleset, nil, true)
        modded = ModLoader.apply_multiple_mods(ruleset_json, mod_specs)
        assert modded != nil, "Failed to apply mods #{inspect(mod_specs)} to ruleset #{ruleset})"
      else
        # it just means the tutorial file is not in the Constants.tutorials() map
        # not an issue
      end
    end
  end

end
