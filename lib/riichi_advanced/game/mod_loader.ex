
# so you'll have a ruleset name, and a list of mods
# first, you'll call ModState.load_ruleset on the ruleset name to get a ModState
# after this, you can use ModState.apply_new_mods to add mods on top
# ModState.apply_post_mods just does ModState.apply_new_mods using the `post_mods` field if the ruleset is a modpack 

defmodule RiichiAdvanced.ModLoader.ModState do
  alias __MODULE__
  alias RiichiAdvanced.Constants, as: Constants
  alias RiichiAdvanced.GameState.Debug, as: Debug
  alias RiichiAdvanced.Compiler, as: Compiler
  alias RiichiAdvanced.Parser, as: Parser
  alias RiichiAdvanced.ModLoader, as: ModLoader
  defstruct [
    # invariant: ruleset_json is always the result of (base_mods ++ mods) applied to base_ruleset
    # cache key is {ruleset, mods}
    ruleset_json: "{}",
    base_ruleset: "",
    base_mods: [],
    ruleset: "",
    mods: [],
    post_mods: [], # this just stores mods for later processing, they haven't been applied yet
    globals: %{},
  ]
  # def get_ruleset_json(ruleset, room_code \\ nil, apply_mods? \\ false, visited \\ [], prev_query \\ ".", prev_mods \\ [], globals \\ %{}, orig_ruleset \\ nil) do

  def load_ruleset(ruleset, room_code \\ nil) do
    # IO.puts("Fetching ruleset #{ruleset}")

    if ruleset == "custom" and room_code != nil do
      ruleset_json = case RiichiAdvanced.ETSCache.get(room_code, ["{}"], :cache_rulesets) do
        [ruleset_json_or_majs] ->
          case Jason.decode(ruleset_json_or_majs) do
            {:ok, _}    -> ruleset_json_or_majs
            {:error, _} -> JQ.query_string_with_string!("{}", ModLoader.convert_to_jq(ruleset_json_or_majs))
          end
        _ -> "{}"
      end
      %ModState{ruleset_json: ruleset_json, base_ruleset: "custom"}
    else
      case RiichiAdvanced.ETSCache.get({ruleset, []}, [], :cache_modloader) do
        [state] ->
          # IO.puts("Cache hit: #{inspect({ruleset, []})}")
          state
        _       ->
          # IO.puts("Cache miss: #{inspect({ruleset, []})}")
          state = load_ruleset_rec(%ModState{ruleset: ruleset}, ruleset)
          if not Debug.skip_ruleset_caching() do
            RiichiAdvanced.ETSCache.put({ruleset, []}, state, :cache_modloader)
          end
          state
      end
    end
  end

  def load_ruleset_rec(state, ruleset, prev_query \\ ".", visited \\ []) do
    modpacks = Constants.modpacks()
    if Map.has_key?(modpacks, ruleset) and ruleset not in visited do
      modpack = modpacks[ruleset]
      mods = Map.get(modpack, :mods, [])
      post_mods = Map.get(modpack, :post_mods, [])
      all_mod_ids = Enum.map(mods ++ post_mods, &ModLoader.get_mod_name/1)
      all_mod_ids_set = MapSet.new(all_mod_ids)

      # set default mods
      default_mods = Map.get(modpack, :default_mods, [])
      |> Enum.reject(&ModLoader.get_mod_name(&1) in all_mod_ids_set)
      query = ".default_mods += #{Jason.encode!(default_mods)}"

      # set or remove display name and/or tutorial link
      query = query <> case Map.get(modpack, :display_name, nil) do
        nil          -> ""
        :delete      -> "| del(.tutorial_link)"
        display_name -> " | .display_name = \"#{display_name}\""
      end
      query = query <> case Map.get(modpack, :tutorial_link, nil) do
        nil           -> ""
        :delete       -> "| del(.tutorial_link)"
        tutorial_link -> "| .tutorial_link = \"#{tutorial_link}\""
      end

      # remove already applied mods
      query = if not Enum.empty?(all_mod_ids) do
        query = query <> " | " <> ".default_mods = (.default_mods // []) - #{Jason.encode!(all_mod_ids)}"
        query = query <> " | " <> ".available_mods = ((.available_mods // []) | map(select(if type == \"object\" then .id else .  end | IN(#{Enum.map_join(all_mod_ids, ", ", &Jason.encode!/1)}) | not)))"
        query
      else query end

      # we're traversing down, so "new" query/mods/globals should be run before "old" ones
      query = query <> "\n|\n" <> prev_query
      globals = Map.get(modpack, :globals, %{}) |> Map.new(fn {k, v} -> {Atom.to_string(k), v} end)
      state = %{state | mods: mods ++ state.mods, post_mods: post_mods ++ state.post_mods, globals: Map.merge(globals, state.globals)}
      # now recurse
      load_ruleset_rec(state, Map.get(modpack, :ruleset, "empty"), query, [ruleset | visited])
    else # else, read the base ruleset filename and apply all mods

      # first check for duplicates
      mods = Enum.uniq(state.mods)
      duplicates = state.mods -- mods
      if not Enum.empty?(duplicates) do
        IO.puts("WARNING: while loading #{state.ruleset}, these mods (for ruleset #{ruleset}) were included twice: #{inspect(duplicates)}")
      end

      # then actually apply all mods to the ruleset, if any
      state = %{state | ruleset_json: ModLoader.read_ruleset_json(ruleset), mods: []}
      state = if not Enum.empty?(mods) do
        ModState.apply_new_mods(state, mods)
      else state end
      ruleset_json = state.ruleset_json
      |> ModLoader.strip_comments()
      |> JQ.query_string_with_string!(prev_query)
      state = %{state | ruleset_json: ruleset_json}

      # return
      state = %{state | base_ruleset: ruleset, base_mods: state.base_mods ++ state.mods, mods: []}

      state
    end
  end

  def apply_new_mods(state, []), do: state
  def apply_new_mods(state, mods) do
    all_mods = state.mods ++ mods
    case RiichiAdvanced.ETSCache.get({state.ruleset, all_mods}, [], :cache_modloader) do
      [state] ->
        # IO.puts("Cache hit for ruleset #{state.ruleset}: #{length(all_mods)} mods #{inspect(all_mods, limit: :infinity)}")
        state
      _ ->
        # IO.puts("Cache miss for ruleset #{state.ruleset}: #{length(all_mods)} mods #{inspect(all_mods, limit: :infinity)}")
        # check for duplicates
        duplicates = all_mods -- Enum.uniq(all_mods)
        if not Enum.empty?(duplicates) do
          IO.puts("Warning, the following mods (for ruleset #{state.base_ruleset}) were included twice: #{inspect(duplicates)}")
        end

        # collect all new jqs in reverse order
        jq_defs = for mod <- mods, reduce: [] do
          acc -> [ModLoader.read_mod(mod) | acc]
        end

        # apply jqs
        mod_contents = jq_defs
        |> Enum.reverse()
        |> Enum.map(fn {jq, defs} ->
          jq = jq |> String.trim() |> String.replace(Compiler.header(), "")
          vars = for {name, val} <- defs.vars, ModLoader.is_jq_var?(name), do: "(#{Jason.encode!(val)}) as $#{name}\n|"
          "(#{Enum.join(vars) <> jq}\n) as $_result\n|\n$_result"
        end)
        
        global_jq = for {name, val} <- state.globals, ModLoader.is_jq_var?(name), do: "(#{Jason.encode!(val)}) as $#{name}"
        boilerplate = [Compiler.header() <> if Enum.empty?(mods) do "." else "\n.enabled_mods += #{Jason.encode!(mods)}" end]
        mod_jq = Enum.join(boilerplate ++ global_jq ++ mod_contents, "\n|")
        state = %{state | ruleset_json: JQ.query_string_with_string!(state.ruleset_json, mod_jq), mods: state.mods ++ mods}

        # IO.puts(mod_jq)
        if Debug.print_mods() do
          mod_string = Enum.map_join(mods, ",\n  ", &Jason.encode!/1)
          |> String.replace(",\"", ", \"")
          |> String.replace(~r"\"([a-zA-Z0-9_]+?)\":", "\\1: ")
          |> String.replace("\":", "\" => ")
          |> String.replace("{", "%{")
          IO.puts("Loading #{state.ruleset}: [\n  #{mod_string}\n]")
        end

        # cache and return
        if not Debug.skip_ruleset_caching() do
          # IO.puts("Caching mods for ruleset #{state.ruleset}: #{length(all_mods)} mods #{inspect(all_mods, limit: :infinity)}")
          RiichiAdvanced.ETSCache.put({state.ruleset, all_mods}, state, :cache_modloader)
        end
        state
    end
  end

  def apply_post_mods(state), do: %{apply_new_mods(state, state.post_mods) | post_mods: []}

end

defmodule RiichiAdvanced.ModLoader do
  alias RiichiAdvanced.Constants, as: Constants
  alias RiichiAdvanced.GameState.Debug, as: Debug
  alias RiichiAdvanced.Compiler, as: Compiler
  alias RiichiAdvanced.Compiler.Defs, as: Defs
  alias RiichiAdvanced.Parser, as: Parser

  def get_mod_name(mod) do
    case mod do
      %{"name" => name}         -> name
      %{name: name}             -> name
      name when is_binary(name) -> name
    end
  end

  def get_mod_name_config(mod) do
    case mod do
      %{"name" => name, "config" => config} -> {name, config}
      %{name: name, config: config}         -> {name, config}
      name when is_binary(name)             -> {name, %{}}
    end
  end

  def is_jq_var?(key) when is_binary(key), do: Regex.match?(~r/^[a-zA-Z_][a-zA-Z0-9_]*$/, key)
  def is_jq_var?(key) when is_atom(key), do: Regex.match?(~r/^[a-zA-Z_][a-zA-Z0-9_]*$/, Atom.to_string(key))
  def is_jq_var?(_key), do: false

  def read_mod(mod) do
    {name, config} = get_mod_name_config(mod)
    {mod_contents, defs} = read_mod_jq_defs(name)
    config_queries = for {key, val} <- config, is_integer(val) or is_boolean(val) or is_binary(val), is_jq_var?(key), do: "(#{inspect(val)}) as $#{key}\n|\n"
    {Enum.join(config_queries) <> "(" <> mod_contents <> ")", defs}
  end

  # def check_and_apply_mods(ruleset_json, input_mods, ruleset) do
  #   # check the ruleset to see and set missing default configs
  #   # note this only checks for mods mentioned in ruleset_json
  #   # so mods added by other mods will not be checked
  #   input_mods =
  #     with {:ok, decoded} <- Rules.decode_ruleset_json(ruleset_json, ruleset),
  #          {mods, _categories} <- Rules.parse_available_mods(Map.get(decoded, "available_mods", []), Map.get(decoded, "default_mods", [])) do
  #       # normalize to {name, config} just for this part
  #       input_mods = Enum.map(input_mods, &get_mod_name_config/1)
  #       for {name, config} <- input_mods do
  #         config = if Map.has_key?(mods, name) do
  #           # check if there is more config we haven't mentioned
  #           missing_config = Map.keys(mods[name].config) -- Map.keys(config)
  #           for config_name <- missing_config, reduce: config do
  #             config ->
  #               config_obj = mods[name].config[config_name]
  #               default = Map.get(config_obj, "default", Enum.at(config_obj["values"], 0))
  #               Map.put(config, config_name, default)
  #           end
  #         else config end
  #         if Enum.empty?(config) do name else %{name: name, config: config} end
  #       end
  #     end
  #   apply_mods(ruleset_json, input_mods, ruleset)
  # end

  def convert_to_jq_defs(majs, defs \\ %Defs{}) do
    # first check that it's not actually json
    case Jason.decode(majs) do
      {:ok, json}    -> {". * " <> Jason.encode!(json), defs} # just merge the json (reencoding to ensure it's safe)
      {:error, _} -> 
        # now try to parse it as majs
        with {:ok, ast} <- Parser.parse(majs),
             {:ok, {jq, defs}} <- Compiler.compile_jq_defs(ast, defs) do
          # IO.inspect(jq, label: "jq", limit: :infinity)
          {jq, defs}
        else
          {:error, msg} ->
            IO.puts("Error in convert_to_jq:")
            if is_binary(msg) do IO.puts(msg) else IO.inspect(msg) end
            IO.puts("Input majs was:")
            IO.puts(majs)
            {".", defs} # no-op
        end
    end
  end
  def convert_to_jq(majs) do
    {jq, _defs} = convert_to_jq_defs(majs)
    jq
  end

  def read_ruleset_json(ruleset) do
    # IO.puts("Loading ruleset #{ruleset}")
    case File.read(Application.app_dir(:riichi_advanced, "/priv/static/rulesets/#{ruleset}.json")) do
      {:ok, ruleset_json} -> ruleset_json
      {:error, _err}      ->
        case File.read(Application.app_dir(:riichi_advanced, "/priv/static/rulesets/#{ruleset}.majs")) do
          {:ok, ruleset_majs} ->
            jq = convert_to_jq(ruleset_majs)
            # IO.puts("Successfully loaded ruleset #{ruleset}")
            JQ.query_string_with_string!("{}", jq)
          {:error, _err}      -> "{}"
        end
    end
  end

  @some_majs_commands ["set", "on", "define_set", "define_match", "define_const", "define_yaku", "define_yaku_precedence", "remove_yaku", "replace_yaku", "define_button", "define_auto_button", "define_mod_category", "define_mod", "config_mod", "remove_mod", "apply", "replace_all"]
  defp verify_jq(name, jq) do
    # this is mostly for in case you forget to change the .jq extension to .majs
    jq
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1) |> Enum.at(0))
    |> Enum.any?(& &1 in @some_majs_commands)
    |> if do
      IO.puts("\nWARNING: file #{name}.jq looks kind of like .majs!\n")
    end
  end
  defp read_mod_jq_defs(name, defs \\ %Defs{}) do
    case File.read(Application.app_dir(:riichi_advanced, "/priv/static/mods/#{name}.jq")) do
      {:ok, mod_jq} ->
        verify_jq(name, mod_jq)
        {mod_jq, defs}
      {:error, _err}      ->
        case File.read(Application.app_dir(:riichi_advanced, "/priv/static/mods/#{name}.majs")) do
          {:ok, mod_majs} -> convert_to_jq_defs(mod_majs, defs)
          {:error, _err}  ->
            IO.puts("WARNING: Could not find mod #{name}!")
            {".", defs}
        end
    end
  end

  @default_config """
  # this is for advanced users!
  # this mahjongscript gets applied to the ruleset after applying other mods
  # so basically here is where you write a custom mod
  # see documentation here: https://github.com/EpicOrange/riichi_advanced/blob/main/documentation/documentation.md
  # feel free to submit your mod to the repository by opening an issue or pull request!

  # here are some useful toggles

  # set win_timer, 30 # how many seconds before win screen goes "next"
  # set tsumogiri_bots, true # make bots only discard their draws (if possible)

  # these are are helpful to test out yaku and stuff

  # set debug_status, true # show statuses, counters, and buttons
  # set starting_hand, %{
  #   "east": ["1m", "9m", "1p", "9p", "1s", "9s", "1z", "2z", "3z", "4z", "5z", "6z", "7z"]
  # }
  # set starting_draws, ["1z", "2z", "3z", "4z", "1z", "2z", "3z", "4z", "1z", "2z", "3z", "4z"]
  # set starting_dead_wall, ["5m", "4m"] # so the first kan draw is 5m. this goes backwards
  # set starting_round, 4 # start in south 1
  """

  def default_config, do: @default_config

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
