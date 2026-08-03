
# so you'll have a ruleset name, and a list of mods
# first, you'll call ModState.load_ruleset on the ruleset/modpack name to get a ModState
# after this, you can use ModState.prepend_mods to add mods on top
# ModState.apply_mods then apply the stored mods to the stored json
# then ModState.extract_json gives you the ruleset json

defmodule RiichiAdvanced.ModLoader.ModState do
  alias __MODULE__, as: ModState
  alias RiichiAdvanced.Constants, as: Constants
  alias RiichiAdvanced.GameState.Debug, as: Debug
  alias RiichiAdvanced.Compiler, as: Compiler
  alias RiichiAdvanced.Compiler.Defs, as: Defs
  alias RiichiAdvanced.Parser, as: Parser
  alias RiichiAdvanced.ModLoader, as: ModLoader
  alias RiichiAdvanced.Validator, as: Validator
  defstruct [
    # invariant: ruleset_json is always the result of `ruleset_jq` applied to base_ruleset
    ruleset_json: "{}",
    ruleset_jq: [], # reversed list of {mod, jq} entries, the jqs are joinable with "|"
    base_ruleset: nil,

    # cache key is {ruleset, mods}
    ruleset: "",
    mods: [], # unapplied mods

    # these are all globals
    globals: %{},
    defines: MapSet.new(),
    libs: MapSet.new(),
  ]

  def inspect_state(state), do: IO.inspect(Map.drop(state, [:ruleset_json, :ruleset_jq]))
  def inspect_state_jq(state) do
    for {x, i} <- state.ruleset_jq |> Enum.reverse() |> Enum.with_index() do IO.puts("\n#{i}: #{x}") end
  end

  # main entry point
  def load_ruleset(ruleset, room_code \\ nil) do
    # IO.puts("Fetching ruleset #{ruleset}")

    if ruleset == "custom" and room_code != nil do
      {:ok, ruleset_json_or_majs} = RiichiAdvanced.Cache.get({:cache_rulesets, room_code}, "{}")
      ruleset_json = case Jason.decode(ruleset_json_or_majs) do
        {:ok, _}    -> ruleset_json_or_majs
        {:error, _} -> JQ.query_string_with_string!("{}", ModLoader.convert_to_jq(ruleset_json_or_majs))
      end
      %ModState{ruleset_json: ruleset_json, base_ruleset: "custom", ruleset: "custom"}
    else
      case RiichiAdvanced.Cache.get({:cache_modloader, ruleset, []}) do
        {:ok, nil} ->
          # IO.puts("Cache miss: #{inspect({ruleset, []})}")
          state = load_ruleset_rec(%ModState{ruleset: ruleset}, ruleset)
          if not Debug.skip_ruleset_caching() do
            # RiichiAdvanced.Cache.put({:cache_modloader, ruleset, []}, state)
          end
          state
        {:ok, state} ->
          # IO.puts("Cache hit: #{inspect({ruleset, []})}")
          state
      end
    end
  end

  defp load_ruleset_rec(state, ruleset, modpack_query \\ ".", visited \\ MapSet.new()) do
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

      # we're traversing to previous rulesets, so their query/mods/globals should be run before ours
      query = query <> "\n|\n" <> modpack_query
      globals = Map.get(modpack, :globals, %{}) |> Map.new(fn {k, v} -> {Atom.to_string(k), v} end)
      state = %{state |
        mods: Enum.reverse(post_mods) ++ Enum.reverse(mods) ++ state.mods,
        globals: Map.merge(globals, state.globals),
      }
      # now recurse
      load_ruleset_rec(state, Map.get(modpack, :ruleset, "empty"), query, MapSet.put(visited, ruleset))
    else
      # else, read the actual ruleset file(s)
      for {jq, defs} <- read_ruleset(ruleset, %Defs{}), reduce: state do
        state ->
          # update state with defs' (older) globals and defines
          state = %{state |
            mods: [],
            globals: Map.merge(defs.globals, state.globals),
            defines: MapSet.union(defs.defines, state.defines),
            libs: MapSet.union(defs.libs, state.libs),
          }
          # then apply everything in the right order
          # (ruleset mods, ruleset, modpack mods, post_mods, modpack query)
          jq = String.replace_leading(jq, Compiler.header(), "")
          state = update_in(state.globals, &Map.merge(&1, defs.globals))
          # IO.puts("Loading ruleset #{defs.base_ruleset} with mods #{inspect(Enum.reverse(defs.mods), limit: :infinity)}")
          modpack_mods = state.mods
          state = %{state | mods: defs.mods} |> apply_mods()
          |> append_jq({"ruleset/#{defs.base_ruleset}", jq})
          |> prepend_mods(modpack_mods)
          |> apply_mods()
          |> Map.put(:mods, defs.post_mods)
          state = if state.base_ruleset == nil do put_in(state.base_ruleset, defs.base_ruleset) else state end
          state = put_in(state.ruleset, ruleset)
          |> append_jq({nil, modpack_query})

          if Debug.print_mods() do
            # IO.inspect(defs.vars)
            inspect_state(state)
            # inspect_state_jq(state)
            # IO.puts("")
          end

          # IO.inspect(defs)
          # inspect_state(state)
          # inspect_state_jq(state)
          # IO.puts("")
          # IO.puts(jq)

          state
      end
    end
  end

  # returns list [{jq, defs}] whose first item is the base ruleset
  # note that we need to compile in reverse order of rulesets
  # since knowing the base ruleset of ruleset X depends on compiling X first
  # this means defines in later rulesets are passed to earlier rulesets, not the reverse
  defp read_ruleset(ruleset, defs, acc \\ [], visited \\ [])
  defp read_ruleset(nil, _defs, acc, _visited), do: acc
  defp read_ruleset(ruleset, _defs, _acc, visited) when length(visited) >= 5, do: raise "read_ruleset: Reached max ruleset depth of 5 while trying to load base ruleset #{ruleset} (stack was #{inspect(visited)})"
  defp read_ruleset(ruleset, defs, acc, visited) do
    if ruleset in visited do acc else
      case File.read(Application.app_dir(:riichi_advanced, "/priv/static/rulesets/#{ruleset}.json")) do
        {:ok, ruleset_json} -> [{"(. = #{ModLoader.strip_comments(ruleset_json)})", defs}]
        {:error, _err} -> case File.read(Application.app_dir(:riichi_advanced, "/priv/static/rulesets/#{ruleset}.majs")) do
          {:ok, ruleset_majs} ->
            if Debug.print_mods() do
              IO.puts("Reading ruleset #{ruleset} with defines #{inspect(defs.defines)}")
            end
            {jq, defs} = ModLoader.convert_to_jq_defs(ruleset_majs, defs)
            read_ruleset(
              defs.base_ruleset,
              %{defs | mods: [], post_mods: []},
              [{jq, %{defs | base_ruleset: ruleset}} | acc],
              [ruleset | visited]
            )
          {:error, _err} -> raise "read_ruleset: Unable to read ruleset #{inspect(ruleset)}!"
        end
      end
    end
  end

  # these are reversed because the respective fields are stacks
  def append_mods(state, mods), do: %{state | mods: mods ++ state.mods}
  def prepend_mods(state, mods), do: %{state | mods: state.mods ++ mods}
  def append_jq(state, jq), do: %{state | ruleset_jq: [jq | state.ruleset_jq]}
  def prepend_jqs(state, jqs), do: %{state | ruleset_jq: state.ruleset_jq ++ jqs}
  def append_jqs(state, jqs), do: %{state | ruleset_jq: jqs ++ state.ruleset_jq}

  def apply_mods(state) when state.mods == [], do: state
  def apply_mods(state) do
    # inspect_state(state)
    case RiichiAdvanced.Cache.get({:cache_modloader, state.ruleset, state.mods}) do
      {:ok, nil} ->
        # IO.puts("Cache miss for ruleset #{state.ruleset}: #{length(state.mods)} mods #{inspect(state.mods, limit: :infinity)}")
        mods = state.mods |> Enum.uniq() |> Enum.reverse()
        if Debug.print_mods() do
          IO.puts("Applying mods #{inspect(mods, limit: :infinity)}")
        end
        # check for duplicates
        applied_mods = Enum.map(state.ruleset_jq, fn {mod, _jq} -> mod end) |> Enum.reject(&is_nil/1)
        all_mod_names = MapSet.new(state.mods ++ applied_mods, &ModLoader.get_mod_name/1)
        duplicates = MapSet.difference(all_mod_names, MapSet.new(all_mod_names))
        if not Enum.empty?(duplicates) do
          IO.puts("Warning, the following mods (for ruleset #{state.base_ruleset}) were included twice: #{inspect(Enum.to_list(duplicates))}")
        end

        # collect all new jqs
        defs = %Defs{globals: state.globals, defines: state.defines, libs: state.libs}
        {jqs, defs} = for mod <- mods, reduce: {[], defs} do
          {jqs, defs} -> 
            if Debug.print_mods() do
              IO.puts("Reading mod #{inspect(mod)} with defines #{inspect(defs.defines)}")
            end
            {jq, defs} = read_mod(mod, %{defs | vars: [], mods: []})

            # immediately apply any new mod dependencies from the mod we just read
            all_mod_names = MapSet.union(all_mod_names, MapSet.new(jqs, fn {mod, _jq} -> mod end))
            deps = Enum.reject(defs.mods, fn mod -> mod in all_mod_names end)
            {jqs, defs} = if not Enum.empty?(deps) do
              state = apply_mods(%{state | ruleset_jq: [], mods: deps, globals: defs.globals, defines: defs.defines, libs: defs.libs})
              {state.ruleset_jq ++ jqs, %{defs | globals: state.globals, defines: state.defines, libs: state.libs}}
            else {jqs, defs} end

            # IO.puts("Done reading mod #{inspect(mod)}")
            {[{mod, jq} | jqs], defs}
        end
        # update state with new globals and defines
        state = %{state |
          mods: [],
          globals: defs.globals,
          defines: defs.defines,
          libs: defs.libs,
        }

        # apply jqs
        mod_contents = for {mod, jq} <- jqs do
          jq = jq |> String.trim() |> String.replace(Compiler.header(), "")
          jq = "(#{jq}) as $_result\n|$_result"
          # IO.puts(jq)
          {mod, jq}
        end
        state = append_jqs(state, mod_contents)
        encoded_mods = mods
        # |> IO.inspect(limit: :infinity)
        |> Enum.map(fn
          %{config: config} = mod -> %{ mod | config: Map.new(config) }
          mod -> mod
        end)
        |> Jason.encode!()
        # IO.puts(encoded_mods)
        enabled_mods = if Enum.empty?(mods) do "." else ".enabled_mods += #{encoded_mods}" end
        # IO.inspect(enabled_mods, limit: :infinity)
        state = append_jq(state, {nil, enabled_mods})

        state
      {:ok, state} ->
        # IO.puts("Cache hit for ruleset #{state.ruleset}: #{length(state.mods)} mods #{inspect(state.mods, limit: :infinity)}")
        state
    end
  end

  def extract_json(state) when state.ruleset_jq == [], do: state.ruleset_json
  def extract_json(state) do
    global_jq = for {name, val} <- state.globals, ModLoader.is_jq_var?(name), do: {nil, "(#{Jason.encode!(val)}) as $#{name}"}
    state = prepend_jqs(state, Enum.reverse(global_jq))

    state = apply_mods(state)

    # now actually apply the jq
    {applied_mods, jqs} = state.ruleset_jq |> Enum.reverse() |> Enum.unzip()
    if Debug.print_mods() do
      IO.puts("Extracting json after applying the following mods:")
      IO.inspect(applied_mods |> Enum.reject(&is_nil/1), limit: :infinity)
    end
    ruleset_json = JQ.query_string_with_string!(state.ruleset_json, Compiler.header() <> Enum.join(jqs, "\n|"))
    # IO.puts(state.ruleset_json)
    # IO.puts(ruleset_json)
    # cache and return
    if not Debug.skip_ruleset_caching() do
      # TODO redo this
      # IO.puts("Caching mods for ruleset #{state.ruleset}: #{length(state.mods)} mods #{inspect(state.mods, limit: :infinity)}")
      # RiichiAdvanced.Cache.put({:cache_modloader, state.ruleset, state.mods}, state)
    end
    ruleset_json
  end

  @some_majs_commands ["on", "define_set", "define_match", "define_const", "define_yaku", "define_yaku_precedence", "remove_yaku", "replace_yaku", "define_button", "define_auto_button", "define_mod_category", "define_mod", "config_mod", "remove_mod", "apply", "replace_all"]
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
  defp read_mod_jq_defs(name, defs) do
    case File.read(Application.app_dir(:riichi_advanced, "/priv/static/mods/#{name}.jq")) do
      {:ok, mod_jq} ->
        verify_jq(name, mod_jq)
        {mod_jq, defs}
      {:error, _err}      ->
        case File.read(Application.app_dir(:riichi_advanced, "/priv/static/mods/#{name}.majs")) do
          {:ok, mod_majs} -> ModLoader.convert_to_jq_defs(mod_majs, defs)
          {:error, _err}  ->
            IO.puts("WARNING: Could not find mod #{name}!")
            {".", defs}
        end
    end
  end
  defp read_mod(mod, defs) do
    {name, config} = ModLoader.get_mod_name_config(mod)
    {mod_contents, defs} = read_mod_jq_defs(name, defs)
    defaults = Map.new(Enum.reverse(defs.vars))
    vars = Map.merge(defaults, config, fn _k, l, nil -> l; _k, _l, r -> r end)
    config_queries = for {key, val} <- vars,
                         is_integer(val) or is_boolean(val) or is_binary(val) or Validator.is_variable?(val),
                         ModLoader.is_jq_var?(key), do: "(#{Jason.encode!(val)}) as $#{key}\n|\n"
    # IO.inspect({defaults, config, vars})
    # IO.puts(Enum.join(config_queries))
    {Enum.join(config_queries) <> "(" <> mod_contents <> ")", defs}
  end

end

defmodule RiichiAdvanced.ModLoader do
  alias RiichiAdvanced.Constants, as: Constants
  alias RiichiAdvanced.GameState.Debug, as: Debug
  alias RiichiAdvanced.Compiler, as: Compiler
  alias RiichiAdvanced.Compiler.Defs, as: Defs
  alias RiichiAdvanced.Parser, as: Parser
  alias RiichiAdvanced.ModLoader.ModState, as: ModState

  def get_mod_name(mod) do
    case mod do
      %{"name" => name}         -> name
      %{name: name}             -> name
      name when is_binary(name) -> name
    end
  end

  def get_mod_name_config(mod) do
    case mod do
      %{"name" => name, "config" => config} -> {name, Map.new(config)}
      %{name: name, config: config}         -> {name, Map.new(config)}
      name when is_binary(name)             -> {name, %{}}
    end
  end

  def is_jq_var?(key) when is_binary(key), do: Regex.match?(~r/^[a-zA-Z_][a-zA-Z0-9_]*$/, key)
  def is_jq_var?(key) when is_atom(key), do: Regex.match?(~r/^[a-zA-Z_][a-zA-Z0-9_]*$/, Atom.to_string(key))
  def is_jq_var?(_key), do: false

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

  def convert_to_jq_defs(majs, defs) do
    # first check that it's not actually json
    case Jason.decode(majs) do
      {:ok, json}    -> {". * " <> Jason.encode!(json), defs} # just merge the json (reencoding to ensure it's safe)
      {:error, _} -> 
        # now try to parse it as majs
        with {:ok, ast} <- Parser.parse(majs),
             {:ok, {jq, defs}} <- Compiler.compile_jq_defs(ast, defs) do
          # IO.inspect(jq, label: "jq", limit: :infinity)
          # IO.inspect(defs, label: "defs", limit: :infinity)
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
    {jq, _defs} = convert_to_jq_defs(majs, %Defs{})
    jq
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
    {:ok, config} = RiichiAdvanced.Cache.get({:cache_configs, ruleset, room_code}, @default_config)
    config
  end

  def strip_comments(json) do
    Regex.replace(~r{^//.*|\s//.*|/\*[.\n]*?\*/}, json, "")
  end
end
