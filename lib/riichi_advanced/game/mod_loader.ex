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
    |> Enum.map_join(&" | (#{&1}\n) as $_result\n|\n$_result")
    |> then(&".enabled_mods += #{mod_names_to_array(mod_names)}"<>&1)
    # IO.puts(mod_contents)

    if Debug.print_mods() do
      IO.puts("Applying mods [#{Enum.join(mod_names, ", ")}]")
    end
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
      tutorial_link: "https://github.com/EpicOrange/riichi_advanced/blob/main/documentation/sanma.md",
      ruleset: "riichi",
      mods: ["sanma"],
      default_mods: [],
    },
    "cosmic" => %{
      display_name: "Cosmic Riichi",
      tutorial_link: "https://docs.google.com/document/d/1F-NhQ5fdi5CnAyEqwNE_qWR0Og99NtCo2NGkvBc5EwU/edit",
      ruleset: "riichi",
      mods: ["cosmic_base"],
      default_mods: ["cosmic", "space", "kontsu", "yaku/kontsu_yaku", "yaku/chanfuun", "yaku/fuunburi", "yaku/uumensai_cosmic", "cosmic_calls", "yakuman_13_han", "yaku/tsubame_gaeshi", "yaku/kanburi", "yaku/uumensai", "yaku/isshoku_sanjun", "yaku/isshoku_yonjun"],
    },
    "nojokersmahjongleague" => %{
      display_name: "No Jokers Mahjong League 2024",
      tutorial_link: "https://docs.google.com/document/d/1APpd-YBnsKKssGmyLQiCp90Wk-06SlIScV1sKpJUbQo/edit?usp=sharing",
      ruleset: "riichi",
      mods: ["nojokersmahjongleague", "kiriage_mangan", "agarirenchan", "tenpairenchan", "dora", "ura", "kandora", "yaku/ippatsu", "tobi", "immediate_kan_dora", "head_bump", "no_double_yakuman"],
      default_mods: ["show_waits"],
    },
    "space" => %{
      display_name: "Space Mahjong",
      tutorial_link: "https://riichi.wiki/Space_mahjong",
      ruleset: "riichi",
      mods: [],
      default_mods: ["space"],
    },
    "galaxy" => %{
      display_name: "Galaxy Mahjong",
      tutorial_link: "https://github.com/EpicOrange/riichi_advanced/blob/main/documentation/galaxy.md",
      ruleset: "riichi",
      mods: [],
      default_mods: ["galaxy"],
    },
    "chinitsu" => %{
      display_name: "Chinitsu Challenge",
      tutorial_link: "https://github.com/EpicOrange/riichi_advanced/blob/main/documentation/chinitsu_challenge.md",
      ruleset: "riichi",
      mods: ["chinitsu_challenge"],
      default_mods: ["chombo", "tobi", "yaku/renhou_yakuman", "no_honors"],
    },
    "minefield" => %{
      display_name: "Minefield",
      tutorial_link: "https://riichi.wiki/Minefield_mahjong",
      ruleset: "riichi",
      mods: ["minefield"],
      default_mods: ["kiriage_mangan"],
    },
    "kansai" => %{
      display_name: "Kansai Sanma",
      tutorial_link: "https://github.com/EpicOrange/riichi_advanced/blob/main/documentation/kansai.md",
      ruleset: "riichi",
      mods: ["sanma", "dora", "aka", "nagashi", "kansai"],
      default_mods: ["tobi"],
    }
  }

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
      if Map.has_key?(@modpacks, ruleset) do
        modpack = @modpacks[ruleset]
        mod_names = Map.get(modpack, :mods, [])
        display_name = Map.get(modpack, :display_name, ruleset)
        query = ".default_mods += #{mod_names_to_array(Map.get(modpack, :default_mods, []))} | .display_name = \"#{display_name}\""
        query = query <> " | " <> if Map.has_key?(modpack, :tutorial_link) do ".tutorial_link = \"#{modpack.tutorial_link}\"" else "del(.tutorial_link)" end
        modpack.ruleset
        |> read_ruleset_json()
        |> strip_comments()
        |> apply_mods(mod_names, modpack.ruleset)
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
