
defmodule RiichiAdvanced.GameState do
  alias RiichiAdvanced.GameState.Actions, as: Actions
  alias RiichiAdvanced.GameState.American, as: American
  alias RiichiAdvanced.GameState.Buttons, as: Buttons
  alias RiichiAdvanced.GameState.Conditions, as: Conditions
  alias RiichiAdvanced.GameState.Debug, as: Debug
  alias RiichiAdvanced.GameState.Saki, as: Saki
  alias RiichiAdvanced.GameState.Scoring, as: Scoring
  alias RiichiAdvanced.GameState.Marking, as: Marking
  alias RiichiAdvanced.GameState.Log, as: Log
  alias RiichiAdvanced.Constants, as: Constants
  alias RiichiAdvanced.LobbyState.LobbyRoom, as: LobbyRoom
  alias RiichiAdvanced.Match, as: Match
  alias RiichiAdvanced.ModLoader, as: ModLoader
  alias RiichiAdvanced.Riichi, as: Riichi
  alias RiichiAdvanced.RoomState.RoomPlayer, as: RoomPlayer
  alias RiichiAdvanced.Utils, as: Utils
  use GenServer
  
  defmodule Choice do
    defstruct [
      name: "skip",
      chosen_actions: nil,
      chosen_called_tile: nil,
      chosen_call_choice: nil,
      chosen_saki_card: nil
    ]
  end

  defmodule PlayerCache do
    defstruct [
      saved_tile_mappings: %{},
      saved_tile_aliases: %{},
      riichi_discard_indices: nil,
      playable_indices: [],
      closest_american_hands: [],
      winning_hand: nil,
      arranged_hand: [],
      arranged_calls: [],
    ]
  end

  defmodule TileBehavior do
    defstruct [
      aliases: %{},
      ordering: %{:"1m"=>:"2m", :"2m"=>:"3m", :"3m"=>:"4m", :"4m"=>:"5m", :"5m"=>:"6m", :"6m"=>:"7m", :"7m"=>:"8m", :"8m"=>:"9m",
                  :"1p"=>:"2p", :"2p"=>:"3p", :"3p"=>:"4p", :"4p"=>:"5p", :"5p"=>:"6p", :"6p"=>:"7p", :"7p"=>:"8p", :"8p"=>:"9p",
                  :"1s"=>:"2s", :"2s"=>:"3s", :"3s"=>:"4s", :"4s"=>:"5s", :"5s"=>:"6s", :"6s"=>:"7s", :"7s"=>:"8s", :"8s"=>:"9s"},
      ordering_r: %{:"2m"=>:"1m", :"3m"=>:"2m", :"4m"=>:"3m", :"5m"=>:"4m", :"6m"=>:"5m", :"7m"=>:"6m", :"8m"=>:"7m", :"9m"=>:"8m",
                    :"2p"=>:"1p", :"3p"=>:"2p", :"4p"=>:"3p", :"5p"=>:"4p", :"6p"=>:"5p", :"7p"=>:"6p", :"8p"=>:"7p", :"9p"=>:"8p",
                    :"2s"=>:"1s", :"3s"=>:"2s", :"4s"=>:"3s", :"5s"=>:"4s", :"6s"=>:"5s", :"7s"=>:"6s", :"8s"=>:"7s", :"9s"=>:"8s"},
      ignore_suit: false
    ]
    def tile_mappings(tile_behavior) do
      for {tile1, attrs_aliases} <- tile_behavior.aliases, {attrs, aliases} <- attrs_aliases, tile2 <- aliases do
        %{tile2 => [Utils.add_attr(tile1, attrs)]}
      end |> Enum.reduce(%{}, &Map.merge(&1, &2, fn _k, l, r -> l ++ r end))
    end
    def is_any_joker?(tile, tile_behavior) do
      {tile2, attrs2} = Utils.to_attr_tile(tile)
      attrs2 = MapSet.new(attrs2)
      Enum.any?(Map.get(tile_behavior.aliases, :any, %{}), fn {attrs, aliases} ->
        MapSet.subset?(MapSet.new(attrs), attrs2) and tile2 in aliases
      end)
    end
    def is_joker?(tile, tile_behavior) do
      {tile2, attrs2} = Utils.to_attr_tile(tile)
      attrs2 = MapSet.new(attrs2)
      Enum.any?(tile_behavior.aliases, fn {_tile1, attrs_aliases} ->
        Enum.any?(attrs_aliases, fn {attrs, aliases} ->
          MapSet.subset?(MapSet.new(attrs), attrs2) and tile2 in aliases
        end)
      end)
    end
    def hash(tile_behavior) do
      :erlang.phash2({tile_behavior.aliases, tile_behavior.ordering, tile_behavior.ignore_suit})
    end
  end

  defmodule Player do
    # ensure this stays at or below 32 keys (currently 28)
    defstruct [
      # persistent
      score: 0,
      start_score: 0, # for logging purposes
      nickname: nil,
      # working (reset every round)
      hand: [],
      draw: [],
      pond: [],
      discards: [],
      calls: [],
      aside: [],
      buttons: [],
      button_choices: %{},
      auto_buttons: [],
      call_buttons: %{},
      choice: nil,
      deferred_actions: [],
      deferred_context: %{},
      big_text: "",
      status: MapSet.new(),
      counters: %{},
      riichi_stick: false,
      hand_revealed: false,
      num_scryed_tiles: 0,
      declared_yaku: nil,
      last_discard: nil, # for animation purposes and to avoid double discarding
      ready: false,
      ai_thinking: false,
      tile_behavior: %TileBehavior{},
      cache: %PlayerCache{},
    ]
  end

  defmodule Game do
    defstruct [
      # params
      ruleset: nil,
      room_code: nil,
      ruleset_json: nil,
      mods: nil,
      config: nil,
      private: true,
      reserved_seats: nil,
      # pids
      supervisor: nil,
      mutex: nil,
      smt_solver: nil,
      ai_supervisor: nil,
      exit_monitor: nil,
      play_tile_debounce: nil,
      play_tile_debouncers: nil,
      big_text_debouncers: nil,
      timer_debouncer: nil,
      east: nil,
      south: nil,
      west: nil,
      north: nil,
      messages_states: Map.new([:east, :south, :west, :north], fn seat -> {seat, nil} end),
      calculate_playable_indices_pids: Map.new([:east, :south, :west, :north], fn seat -> {seat, nil} end),
      calculate_closest_american_hands_pid: nil,
      get_best_minefield_hand_pid: nil,
      # remember to edit :put_state if you change anything above

      # control variables
      available_seats: [:east, :south, :west, :north],
      game_active: false,
      visible_screen: nil,
      error: nil,
      round_result: nil,
      winners: %{},
      winner_seats: [],
      winner_index: 0,
      delta_scores: %{},
      delta_scores_reason: nil,
      next_dealer: nil,
      timer: 0,
      log_loading_mode: false, # disables pause and doesn't notify players on state change
      log_seeking_mode: false, # disables round change on round end

      # persistent game state (not reset on new round)
      ref: "",
      players: Map.new([:east, :south, :west, :north], fn seat -> {seat, %Player{}} end),
      rules: %{},
      interruptible_actions: %{},
      all_tiles: MapSet.new(),
      wall: [],
      kyoku: 0,
      honba: 0,
      pot: 0,
      tags: %{},
      log_state: %{},
      call_stack: [], # call stack limit is 10 for now

      # working game state (reset on new round)
      # (these are all reset manually, so if you add a new one go to initialize_new_round to reset it)
      turn: :east,
      awaiting_discard: true, # prevent double discards
      die1: 3,
      die2: 4,
      wall_index: 0,
      dead_wall_index: 0,
      haipai: [],
      actions: [],
      dead_wall: [],
      reversed_turn_order: false,
      reserved_tiles: [],
      revealed_tiles: [],
      saved_revealed_tiles: [],
      max_revealed_tiles: 0,
      drawn_reserved_tiles: [],
      marking: Map.new([:east, :south, :west, :north], fn seat -> {seat, %{}} end),
      processed_bloody_end: false,
    ]
  end

  def start_link(init_data) do
    # IO.puts("Game supervisor PID is #{inspect(self())}")
    GenServer.start_link(
      __MODULE__,
      %{
        room_code: Keyword.get(init_data, :room_code),
        ruleset: Keyword.get(init_data, :ruleset),
        mods: Keyword.get(init_data, :mods, []),
        config: Keyword.get(init_data, :config, nil),
        private: Keyword.get(init_data, :private, true),
        reserved_seats: Keyword.get(init_data, :reserved_seats, %{}),
      },
      name: Keyword.get(init_data, :name))
  end

  defp debounce_worker(debouncers, delay, id, message, seat \\ nil) do
    message = if seat == nil do message else {message, seat} end
    DynamicSupervisor.start_child(debouncers, %{
      id: id,
      start: {Debounce, :start_link, [{GenServer, :cast, [self(), message]}, delay]},
      type: :worker,
      restart: :transient
    })
  end

  def init(state) do
    # IO.puts("Game state PID is #{inspect(self())}")

    # lookup pids of the other processes we'll be using
    [{debouncers, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("debouncers", state.ruleset, state.room_code))
    [{supervisor, _}] = case Registry.lookup(:game_registry, Utils.to_registry_name("log", state.ruleset, state.room_code)) do
      [{supervisor, _}] -> [{supervisor, nil}]
      _ -> Registry.lookup(:game_registry, Utils.to_registry_name("game", state.ruleset, state.room_code))
    end
    [{mutex, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("mutex", state.ruleset, state.room_code))
    [{ai_supervisor, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("ai_supervisor", state.ruleset, state.room_code))
    [{exit_monitor, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("exit_monitor", state.ruleset, state.room_code))
    [{smt_solver, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("smt_solver", state.ruleset, state.room_code))

    # initialize all debouncers
    {:ok, play_tile_debouncer_east} = debounce_worker(debouncers, 100, :play_tile_debouncer_east, :reset_play_tile_debounce, :east)
    {:ok, play_tile_debouncer_south} = debounce_worker(debouncers, 100, :play_tile_debouncer_south, :reset_play_tile_debounce, :south)
    {:ok, play_tile_debouncer_west} = debounce_worker(debouncers, 100, :play_tile_debouncer_west, :reset_play_tile_debounce, :west)
    {:ok, play_tile_debouncer_north} = debounce_worker(debouncers, 100, :play_tile_debouncer_north, :reset_play_tile_debounce, :north)
    {:ok, big_text_debouncer_east} = debounce_worker(debouncers, 1500, :big_text_debouncer_east, :reset_big_text, :east)
    {:ok, big_text_debouncer_south} = debounce_worker(debouncers, 1500, :big_text_debouncer_south, :reset_big_text, :south)
    {:ok, big_text_debouncer_west} = debounce_worker(debouncers, 1500, :big_text_debouncer_west, :reset_big_text, :west)
    {:ok, big_text_debouncer_north} = debounce_worker(debouncers, 1500, :big_text_debouncer_north, :reset_big_text, :north)
    {:ok, timer_debouncer} = debounce_worker(debouncers, 1000, :timer_debouncer, :tick_timer)
    play_tile_debouncers = %{
      :east => play_tile_debouncer_east,
      :south => play_tile_debouncer_south,
      :west => play_tile_debouncer_west,
      :north => play_tile_debouncer_north
    }
    big_text_debouncers = %{
      :east => big_text_debouncer_east,
      :south => big_text_debouncer_south,
      :west => big_text_debouncer_west,
      :north => big_text_debouncer_north
    }

    # read in the ruleset
    mods = Map.get(state, :mods, [])
    ruleset_json = ModLoader.get_ruleset_json(state.ruleset, state.room_code, not Enum.empty?(mods))

    # apply mods
    ruleset_json = if state.ruleset != "custom" and not Enum.empty?(mods) do
      RiichiAdvanced.ModLoader.apply_mods(ruleset_json, mods, state.ruleset)
    else ruleset_json end
    if not Enum.empty?(mods) do
      # cache mods
      RiichiAdvanced.ETSCache.put({state.ruleset, state.room_code}, mods, :cache_mods)
    end

    # apply config
    ruleset_json = if state.config != nil do
      JQ.merge_jsons!(RiichiAdvanced.ModLoader.strip_comments(ruleset_json), RiichiAdvanced.ModLoader.strip_comments(state.config))
    else ruleset_json end

    # put params, debouncers, and process ids into state
    state = Map.merge(state, %Game{
      ruleset: state.ruleset,
      room_code: state.room_code,
      mods: state.mods,
      config: state.config,
      private: state.private,
      reserved_seats: state.reserved_seats,
      ruleset_json: ruleset_json,
      supervisor: supervisor,
      mutex: mutex,
      smt_solver: smt_solver,
      ai_supervisor: ai_supervisor,
      exit_monitor: exit_monitor,
      play_tile_debounce: %{:east => false, :south => false, :west => false, :north => false},
      play_tile_debouncers: play_tile_debouncers,
      big_text_debouncers: big_text_debouncers,
      timer_debouncer: timer_debouncer
    })

    # decode the rules json
    {state, rules} = try do
      case Jason.decode(RiichiAdvanced.ModLoader.strip_comments(ruleset_json)) do
        {:ok, rules} -> {state, rules}
        {:error, err} ->
          IO.puts("Erroring json:")
          IO.puts(ruleset_json)
          state = show_error(state, "WARNING: Failed to read rules file at character position #{err.position}!\nRemember that trailing commas are invalid!")
          # state = show_error(state, inspect(err))
          {state, %{}}
      end
    rescue
      ArgumentError -> 
        state = show_error(state, "WARNING: Ruleset \"#{state.ruleset}\" doesn't exist!")
        {state, %{}}
    end

    state = Map.put(state, :rules, rules)

    # generate shanten definitions if they don't exist in rules
    shantens = [:win, :tenpai, :iishanten, :ryanshanten, :sanshanten, :suushanten, :uushanten, :roushanten]
    shanten_definitions = Map.new(shantens, fn shanten -> {shanten, translate_match_definitions(state, Map.get(state.rules, Atom.to_string(shanten) <> "_definition", []))} end)
    shanten_definitions = for {from, to} <- Enum.zip(Enum.drop(shantens, -1), Enum.drop(shantens, 1)), Enum.empty?(shanten_definitions[to]), reduce: shanten_definitions do
      shanten_definitions ->
        # IO.puts("Generating #{to} definitions")
        if length(shanten_definitions[from]) < 100 do
          Map.put(shanten_definitions, to, Match.compute_almost_match_definitions(shanten_definitions[from]))
        else
          Map.put(shanten_definitions, to, [])
        end
    end
    state = Map.put(state, :shanten_definitions, shanten_definitions)
    # IO.inspect(state.shanten_definitions)
    # IO.inspect(Map.new(state.shanten_definitions, fn {shanten, definition} -> {shanten, length(definition)} end))

    state = Map.put(state, :available_seats, case Map.get(rules, "num_players", 4) do
      1 -> [:east]
      2 -> [:east, :west]
      3 -> [:east, :south, :west]
      4 -> [:east, :south, :west, :north]
    end)
    state = Map.put(state, :players, Map.new(state.available_seats, fn seat -> {seat, %Player{}} end))
    state = Log.init_log(state)

    state = Map.put(state, :kyoku, Map.get(state.rules, "starting_round", 0))

    initial_score = Map.get(rules, "initial_score", 0)
    state = update_players(state, &%Player{ &1 | score: initial_score, start_score: initial_score })

    state = if not Enum.empty?(Debug.debug_am_match_definitions()) do
      put_in(state.rules["show_nearest_american_hand"], true)
    else state end

    # generate a UUID
    state = Map.put(state, :ref, Ecto.UUID.generate())

    # terminate game if no one joins
    :timer.apply_after(60000, GenServer, :cast, [self(), :terminate_game_if_empty])

    {:ok, state}
  end

  def update_player(state, seat, fun), do: Map.update!(state, :players, &Map.update!(&1, seat, fun))
  def update_players(state, fun), do: Map.update!(state, :players, &Map.new(&1, fn {seat, player} -> {seat, fun.(player)} end))
  def update_players_by_seat(state, fun), do: Map.update!(state, :players, &Map.new(&1, fn {seat, player} -> {seat, fun.(seat, player)} end))
  # TODO replace calls to this last one with either update_players or update_players_by_seat
  def update_all_players(state, fun), do: Map.update!(state, :players, &Map.new(&1, fn {seat, player} -> {seat, if seat in state.available_seats do fun.(seat, player) else player end} end))
  
  def get_last_action(state), do: Enum.at(state.actions, 0)
  def get_last_call_action(state), do: state.actions |> Enum.drop_while(fn action -> action.action != :call end) |> Enum.at(0)
  def get_last_discard_action(state), do: state.actions |> Enum.drop_while(fn action -> action.action != :discard end) |> Enum.at(0)
  def update_action(state, seat, action, opts \\ %{}), do: Map.update!(state, :actions, &[opts |> Map.put(:seat, seat) |> Map.put(:action, action) | &1])
  def clear_actions(state), do: Map.put(state, :actions, [])

  def show_error(state, message) do
    state = Map.update!(state, :error, fn err -> if err == nil do message else err <> "\n\n" <> message end end)
    state = broadcast_state_change(state)
    state
  end

  def translate(state, string) do
    if Map.has_key?(state.rules, "translations") do
      Map.get(state.rules["translations"], string, string)
    else string end
  end

  def initialize_new_round(state, kyoku_log \\ nil) do
    # t = System.os_time(:millisecond)

    rules = state.rules
    {state, hands, scores} = if kyoku_log == nil do
      # initialize wall
      wall = Enum.map(Map.get(rules, "wall", []), &Utils.to_tile(&1))
      all_tiles = MapSet.new(wall)

      # check that there are no nil tiles
      state = wall
      |> Enum.zip(Map.get(rules, "wall", []))
      |> Enum.filter(fn {result, _orig} -> result == nil end)
      |> Enum.reduce(state, fn {_result, orig}, state -> show_error(state, "#{inspect(orig)} is not a valid wall tile!") end)

      # shuffle wall
      wall = Enum.shuffle(wall)
      wall = if Debug.debug() do Debug.set_wall(wall) else wall end

      # distribute haipai
      starting_tiles = Map.get(rules, "starting_tiles", 0)
      hands = Map.new([:east, :south, :west, :north], &{&1, []})
      hands = if Debug.debug() do Debug.set_starting_hand(wall) else
        if starting_tiles > 0 do
          tiles = [
            Enum.slice(wall, 0..(starting_tiles-1)),
            Enum.slice(wall, starting_tiles..(starting_tiles*2-1)),
            Enum.slice(wall, (starting_tiles*2)..(starting_tiles*3-1)),
            Enum.slice(wall, (starting_tiles*3)..(starting_tiles*4-1))
          ]
          Map.merge(hands, Enum.zip(state.available_seats, tiles) |> Map.new())
        else hands end
      end

      # "starting_hand" debug key
      hands = if Map.has_key?(state.rules, "starting_hand") do
        for {seat, starting_hand} <- state.rules["starting_hand"], reduce: hands do
          hands ->
            seat = case seat do
              "east" -> :east
              "south" -> :south
              "west" -> :west
              "north" -> :north
              _ -> nil
            end
            starting_hand = Enum.map(starting_hand, &Utils.to_tile/1)
            if seat != nil do Map.put(hands, seat, starting_hand) else hands end
        end
      else hands end
      wall_index = Map.values(hands) |> Enum.map(&Kernel.length/1) |> Enum.sum()
      # "starting_draws" debug key
      wall = if Map.has_key?(state.rules, "starting_draws") do
        replacements = state.rules["starting_draws"]
        |> Enum.map(&Utils.to_tile/1)
        |> Enum.with_index()
        for {tile, i} <- replacements, reduce: wall do
          wall -> List.replace_at(wall, wall_index + i, tile)
        end
      else wall end
      # "starting_dead_wall" debug key
      wall = if Map.has_key?(state.rules, "starting_dead_wall") do
        replacements = state.rules["starting_dead_wall"]
        |> Enum.map(&Utils.to_tile/1)
        |> Enum.with_index()
        |> Enum.reverse()
        for {tile, i} <- replacements, reduce: wall do
          wall -> List.replace_at(wall, -i-1, tile)
        end
      else wall end

      dead_wall_length = Map.get(rules, "initial_dead_wall_length", 0)
      {wall, dead_wall} = if dead_wall_length > 0 do
        Enum.split(wall, -dead_wall_length)
      else {wall, []} end
      revealed_tiles = Map.get(rules, "revealed_tiles", [])
      max_revealed_tiles = Map.get(rules, "max_revealed_tiles", 0)
      state = state
      |> Map.put(:all_tiles, all_tiles)
      |> Map.put(:wall, wall)
      |> Map.put(:haipai, hands)
      |> Map.put(:dead_wall, dead_wall)
      |> Map.put(:wall_index, wall_index)
      |> Map.put(:dead_wall_index, 0)
      |> Map.put(:revealed_tiles, revealed_tiles)
      |> Map.put(:saved_revealed_tiles, revealed_tiles)
      |> Map.put(:max_revealed_tiles, max_revealed_tiles)

      # reserve some tiles in the dead wall
      reserved_tiles = Map.get(rules, "reserved_tiles", [])
      state = if length(reserved_tiles) > 0 and length(reserved_tiles) <= dead_wall_length do
        state 
        |> Map.put(:reserved_tiles, reserved_tiles)
        |> Map.put(:drawn_reserved_tiles, [])
      else
        state = state
        |> Map.put(:reserved_tiles, [])
        |> Map.put(:drawn_reserved_tiles, [])
        if length(reserved_tiles) > dead_wall_length do
          show_error(state, "length of \"reserved_tiles\" should not exceed \"initial_dead_wall_length\"!")
        else state end
      end

      scores = Map.new(state.players, fn {seat, player} -> {seat, player.score} end)

      # roll dice
      state = state
      |> Map.put(:die1, :rand.uniform(6))
      |> Map.put(:die2, :rand.uniform(6))

      {state, hands, scores}
    else
      hands = Enum.zip(state.available_seats, kyoku_log["players"])
      |> Map.new(fn {seat, player} -> {seat, player["haipai"] |> Enum.map(&Utils.to_tile/1)} end)
      wall = Map.get(hands, :east, [])
          ++ Map.get(hands, :south, [])
          ++ Map.get(hands, :west, [])
          ++ Map.get(hands, :north, [])
          ++ kyoku_log["wall"]
      |> Enum.map(&Utils.to_tile/1)
      wall_index = Map.values(hands) |> Enum.map(&Kernel.length/1) |> Enum.sum()

      # reconstruct dead wall
      dead_wall = Enum.zip(kyoku_log["uras"], kyoku_log["doras"])
      |> Enum.flat_map(fn {a, b} -> [a, b] end)
      |> Enum.reverse()
      dead_wall = dead_wall ++ kyoku_log["kan_tiles"]
      |> Enum.map(&Utils.to_tile/1)
      all_tiles = MapSet.new(wall ++ dead_wall)
      reserved_tiles = Map.get(rules, "reserved_tiles", [])
      revealed_tiles = Map.get(rules, "revealed_tiles", [])
      max_revealed_tiles = Map.get(rules, "max_revealed_tiles", 0)

      state = state
      |> Map.put(:all_tiles, all_tiles)
      |> Map.put(:wall, wall)
      |> Map.put(:haipai, hands)
      |> Map.put(:dead_wall, dead_wall)
      |> Map.put(:wall_index, wall_index)
      |> Map.put(:dead_wall_index, 0)
      |> Map.put(:reserved_tiles, reserved_tiles)
      |> Map.put(:revealed_tiles, revealed_tiles)
      |> Map.put(:saved_revealed_tiles, revealed_tiles)
      |> Map.put(:max_revealed_tiles, max_revealed_tiles)
      |> Map.put(:drawn_reserved_tiles, [])
      |> Map.put(:processed_bloody_end, false)

      scores = kyoku_log["players"]
      |> Enum.zip(state.available_seats)
      |> Map.new(fn {player_obj, seat} -> {seat, player_obj["points"]} end)

      # set other variables that log contains
      state = state
      |> Map.put(:kyoku, kyoku_log["kyoku"])
      |> Map.put(:pot, kyoku_log["riichi_sticks"] * 1000)
      |> Map.put(:honba, kyoku_log["honba"])
      |> Map.put(:die1, kyoku_log["die1"])
      |> Map.put(:die2, kyoku_log["die2"])

      {state, hands, scores}
    end

    # initialize other constants
    persistent_statuses = if Map.has_key?(rules, "persistent_statuses") do rules["persistent_statuses"] else [] end
    persistent_counters = if Map.has_key?(rules, "persistent_counters") do rules["persistent_counters"] else [] end
    initial_auto_buttons = for {name, auto_button} <- Map.get(rules, "auto_buttons", []) do
      {name, auto_button["desc"], auto_button["enabled_at_start"]}
    end
    state = state
    |> update_all_players(&%Player{
         score: scores[&1],
         start_score: scores[&1],
         nickname: &2.nickname,
         hand: hands[&1],
         auto_buttons: initial_auto_buttons,
         status: MapSet.filter(&2.status, fn status -> status in persistent_statuses end),
         counters: Enum.filter(&2.counters, fn {counter, _amt} -> counter in persistent_counters end) |> Map.new()
       })
    |> Map.put(:actions, [])
    |> Map.put(:reversed_turn_order, false)
    |> Map.put(:game_active, true)
    |> Map.put(:turn, nil) # so that change_turn detects a turn change
    |> Map.put(:round_result, nil)
    |> Map.put(:winners, %{})
    |> Map.put(:winner_seats, [])
    |> Map.put(:winner_index, 0)
    |> Map.put(:delta_scores, %{})
    |> Map.put(:delta_scores_reason, nil)
    |> Map.put(:next_dealer, nil)

    # initialize marking
    state = Marking.initialize_marking(state)

    # initialize saki if needed
    state = if state.rules["enable_saki_cards"] do Saki.initialize_saki(state) else state end
    
    # start the game
    state = Actions.change_turn(state, Riichi.get_east_player_seat(state.kyoku, state.available_seats))

    # run after_start actions
    state = if Map.has_key?(state.rules, "after_start") do
      Actions.run_actions(state, state.rules["after_start"]["actions"], %{seat: state.turn})
    else state end

    # initialize interruptible actions
    # we only do this after running change_turn and after_start, so that their actions can't be interrupted
    interruptible_actions = Map.get(rules, "interrupt_levels", %{})
    |> Map.merge(Map.new(Map.get(rules, "interruptible_actions", []), fn action -> {action, 100} end))
    state = Map.put(state, :interruptible_actions, interruptible_actions)

    # recalculate buttons at the start of the game
    state = Buttons.recalculate_buttons(state)

    notify_ai(state)

    # ensure playable_indices is populated after the after_start actions
    state = broadcast_state_change(state, true)

    # IO.puts("initialize_new_round: #{inspect(System.os_time(:millisecond) - t)} ms")

    state
  end

  def win(state, seat, winning_tile, win_source) do
    state = Map.put(state, :round_result, :win)

    # run before_win actions
    state = if Map.has_key?(state.rules, "before_win") do
      Actions.run_actions(state, state.rules["before_win"]["actions"], %{seat: seat, winning_tile: winning_tile, win_source: win_source})
    else state end

    # reset animation (and allow discarding again, in bloody end rules)
    state = update_all_players(state, fn _seat, player -> %Player{ player | last_discard: nil } end)

    state = Map.put(state, :game_active, false)
    state = Map.put(state, :visible_screen, :winner)
    state = start_timer(state)

    winner = Scoring.calculate_winner_details(state, seat, [winning_tile], win_source)
    state = update_player(state, seat, fn player -> %Player{ player | cache: %PlayerCache{ player.cache | arranged_hand: winner.arranged_hand, arranged_calls: winner.arranged_calls } } end)
    state = Map.update!(state, :winners, &Map.put(&1, seat, winner))
    state = Map.update!(state, :winner_seats, & &1 ++ [seat])

    push_message(state, [
      %{text: "Player #{player_name(state, seat)} called "},
      %{bold: true, text: "#{String.downcase(winner.winning_tile_text)}"},
      %{text: " on "},
      Utils.pt(winner.winning_tile),
      %{text: " with hand "}
    ] ++ Utils.ph(state.players[seat].hand |> Utils.sort_tiles())
      ++ Utils.ph(state.players[seat].calls |> Enum.flat_map(&Utils.call_to_tiles/1))
    )

    state = if Map.get(state.rules, "bloody_end", false) do
      # only end the round once there are three winners; otherwise, continue
      Map.put(state, :round_result, if map_size(state.winners) == 3 do :win else :continue end)
    else state end

    # run after_win actions
    state = if Map.has_key?(state.rules, "after_win") do
      context = %{
        seat: seat,
        winning_tile: winning_tile,
        win_source: win_source,
        minipoints: winner.minipoints,
        existing_yaku: winner.yaku ++ winner.yaku2
      }
      Actions.run_actions(state, state.rules["after_win"]["actions"], context)
    else state end

    # after the after_win actions, check if pao was set, and add it onto the winner object
    winner = Scoring.update_winner_pao(state, winner)
    state = Map.update!(state, :winners, &Map.put(&1, seat, winner))

    state
  end

  def exhaustive_draw(state) do
    state = Map.put(state, :round_result, :draw)

    push_message(state, [%{text: "Game ended by exhaustive draw"}])

    # run before_exhaustive_draw actions
    state = if Map.has_key?(state.rules, "before_exhaustive_draw") do
      Actions.run_actions(state, state.rules["before_exhaustive_draw"]["actions"], %{seat: state.turn})
    else state end

    # reset animation
    state = update_all_players(state, fn _seat, player -> %Player{ player | last_discard: nil } end)

    state = Map.put(state, :game_active, false)
    state = Map.put(state, :visible_screen, :scores)
    state = start_timer(state)

    {state, delta_scores, delta_scores_reason, next_dealer} = Scoring.adjudicate_draw_scoring(state)

    state = Map.put(state, :delta_scores, delta_scores)
    state = Map.put(state, :delta_scores_reason, delta_scores_reason)
    state = Map.put(state, :next_dealer, next_dealer)
    state
  end

  def abortive_draw(state, draw_name) do
    state = Map.put(state, :round_result, :draw)
    IO.puts("Abort")

    push_message(state, [%{text: "Game ended by abortive draw (#{draw_name})"}])

    # run before_abortive_draw actions
    state = if Map.has_key?(state.rules, "before_abortive_draw") do
      Actions.run_actions(state, state.rules["before_abortive_draw"]["actions"], %{seat: state.turn})
    else state end

    # reset animation
    state = update_all_players(state, fn _seat, player -> %Player{ player | last_discard: nil } end)

    state = Map.put(state, :game_active, false)
    state = Map.put(state, :visible_screen, :scores)
    state = start_timer(state)

    delta_scores = Map.new(state.players, fn {seat, _player} -> {seat, 0} end)
    state = Map.put(state, :delta_scores, delta_scores)
    state = Map.put(state, :delta_scores_reason, draw_name)
    state = Map.put(state, :next_dealer, :self)
    state
  end

  defp timer_finished(state) do
    bloody_end = Map.get(state.rules, "bloody_end", false)
    num_tenpai = Map.new(state.players, fn {seat, player} -> {seat, "tenpai" in player.status} end) |> Map.values() |> Enum.count(& &1)
    num_nagashi = Map.new(state.players, fn {seat, player} -> {seat, "nagashi" in player.status} end) |> Map.values() |> Enum.count(& &1)
    cond do
      state.visible_screen == :winner and state.winner_index + 1 < map_size(state.winners) -> # need to see next winner screen
        # show the next winner
        state = Map.update!(state, :winner_index, & &1 + 1)

        # reset timer
        state = start_timer(state)

        state
      state.visible_screen == :scores and bloody_end and not state.processed_bloody_end and map_size(state.winners) >= 3 and (num_tenpai > 0 or num_nagashi > 0) ->
        state
        |> Map.put(:visible_screen, :bloody_end)
        |> start_timer()
        |> Map.put(:timer, 0)
      state.visible_screen == :bloody_end ->
        # if bloody end is enabled, we also check for tenpai and nagashi after 3 players win
        # in practice, "nagashi" is used for void suit payments in SBR
        prev_round_result = state.round_result
        {state, delta_scores, delta_scores_reason, _next_dealer} = Scoring.adjudicate_draw_scoring(state)

        state = Map.put(state, :processed_bloody_end, true)
        state = Map.put(state, :visible_screen, :scores)
        state = Map.put(state, :round_result, prev_round_result)
        state = Map.put(state, :delta_scores, delta_scores)
        state = Map.put(state, :delta_scores_reason, delta_scores_reason)

        # run after_bloody_end actions
        state = if Map.has_key?(state.rules, "after_bloody_end") do
          Actions.run_actions(state, state.rules["after_bloody_end"]["actions"], %{seat: state.turn})
        else state end

        # reset timer
        state = start_timer(state)

        state
      state.visible_screen == :winner -> # need to see score exchange screen
        # next time we're on the winner screen, show the next winner
        state = Map.update!(state, :winner_index, & &1 + 1)

        # show score exchange screen
        state = Map.put(state, :visible_screen, :scores)

        # since seeing this screen means we're done with all the winners so far, calculate the delta scores
        {state, delta_scores, delta_scores_reason, next_dealer} = Scoring.adjudicate_win_scoring(state)
        state = Map.put(state, :delta_scores, delta_scores)
        state = Map.put(state, :delta_scores_reason, delta_scores_reason)
        # only populate next_dealer the first time we call Scoring.adjudicate_win_scoring
        state = if state.next_dealer == nil do Map.put(state, :next_dealer, next_dealer) else state end
        
        # reset timer
        state = start_timer(state)
        
        state
      state.visible_screen == :scores -> # finished seeing the score exchange screen
        # clear pot
        # but only if ezaki hitomi hasn't cleared it already and set it to their bet
        state = if state.round_result == :win and not Enum.any?(state.players, fn {_seat, player} -> "ezaki_hitomi_bet_instead" in player.status end) do
          Map.put(state, :pot, 0)
        else state end

        # apply delta scores
        state = update_all_players(state, fn seat, player -> %Player{ player | score: player.score + state.delta_scores[seat] } end)

        # run before_new_round actions
        # we need to run it here instead of in initialize_new_round
        # so that it can impact e.g. tobi calculations
        state = if Map.has_key?(state.rules, "before_start") do
          Actions.run_actions(state, state.rules["before_start"]["actions"], %{seat: state.turn})
        else state end

        # check for tobi
        tobi = if Map.has_key?(state.rules, "score_calculation") do Map.get(state.rules["score_calculation"], "tobi", false) else false end
        state = if tobi and Enum.any?(state.players, fn {_seat, player} -> player.score < 0 end) do Map.put(state, :round_result, :end_game) else state end

        # log
        if not state.log_seeking_mode do
          Log.output_to_file(state)
        end
        state = Log.finalize_kyoku(state)
        state = update_all_players(state, fn _seat, player -> %Player{ player | start_score: player.score } end)
        state = Map.put(state, :delta_scores, %{})

        # update kyoku and honba
        state = case state.round_result do
          :win when state.next_dealer == :self ->
            state
              |> Map.update!(:honba, & &1 + 1)
              |> Map.put(:visible_screen, nil)
          :win ->
            state
              |> Map.update!(:kyoku, & &1 + 1)
              |> Map.put(:honba, 0)
              |> Map.put(:visible_screen, nil)
          :draw when state.next_dealer == :self ->
            state
              |> Map.update!(:honba, & &1 + 1)
              |> Map.put(:visible_screen, nil)
          :draw ->
            state
              |> Map.update!(:kyoku, & &1 + 1)
              |> Map.update!(:honba, & &1 + 1)
              |> Map.put(:visible_screen, nil)
          :continue -> state
          :end_game -> state
        end

        # finish or initialize new round if needed, otherwise continue
        state = if state.round_result != :continue do
          if should_end_game(state) do
            finalize_game(state)
          else
            if not state.log_seeking_mode do
              initialize_new_round(state)
            else
              if not state.log_loading_mode do
                # seek to the next round
                [{log_control_state, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("log_control_state", state.ruleset, state.room_code))
                GenServer.cast(log_control_state, {:seek, state.kyoku + 1, -1})
                state
              else state end
            end
          end
        else 
          state = Map.put(state, :visible_screen, nil)
          state = Map.put(state, :game_active, true)

          # trigger before_continue actions
          state = if Map.has_key?(state.rules, "before_continue") do
            Actions.run_actions(state, state.rules["before_continue"]["actions"], %{seat: state.turn})
          else state end

          state = Buttons.recalculate_buttons(state)
          notify_ai(state)
          state
        end
        state
      true ->
        IO.puts("timer_finished() called; unsure what the timer was for")
        state
    end
  end

  def should_end_game(state) do
    forced = state.round_result == :end_game # e.g. tobi
    dealer = Riichi.get_east_player_seat(state.kyoku, state.available_seats)
    agariyame = Map.get(state.rules, "agariyame", false) and state.round_result == :win and dealer in state.winner_seats
    tenpaiyame = Map.get(state.rules, "tenpaiyame", false) and state.round_result == :draw and "tenpai" in state.players[dealer].status
    forced or agariyame or tenpaiyame or if Map.has_key?(state.rules, "sudden_death_goal") do
      above_goal = Enum.any?(state.players, fn {_seat, player} -> player.score >= state.rules["sudden_death_goal"] end)
      past_max_rounds = Map.has_key?(state.rules, "max_rounds") and state.kyoku >= state.rules["max_rounds"] + 4
      above_goal or past_max_rounds
    else
      past_max_rounds = Map.has_key?(state.rules, "max_rounds") and state.kyoku >= state.rules["max_rounds"]
      past_max_rounds
    end
  end

  def finalize_game(state) do
    # trigger before_conclusion actions
    state = if Map.has_key?(state.rules, "before_conclusion") do
      Actions.run_actions(state, state.rules["before_conclusion"]["actions"], %{seat: state.turn})
    else state end

    IO.puts("Game concluded")
    state = Map.put(state, :visible_screen, :game_end)
    state
  end

  def has_unskippable_button?(state, seat) do
    not Enum.empty?(state.players[seat].call_buttons)
    or
    Enum.any?(state.players[seat].buttons, fn button_name -> state.rules["buttons"][button_name] != nil and Map.has_key?(state.rules["buttons"][button_name], "unskippable") and state.rules["buttons"][button_name]["unskippable"] end)
  end

  def is_playable?(state, seat, tile) do
    tile != nil and not has_unskippable_button?(state, seat) and not Utils.has_attr?(tile, ["no_discard"]) and if Map.has_key?(state.rules, "play_restrictions") do
      Enum.all?(state.rules["play_restrictions"], fn [tile_spec, cond_spec] ->
        not Riichi.tile_matches(tile_spec, %{seat: seat, tile: tile, players: state.players}) or not Conditions.check_cnf_condition(state, cond_spec, %{seat: seat, tile: tile})
      end)
    else true end
  end

  defp _reindex_hand(hand, from, to) do
    if from < length(hand) do
      {l1, [tile | r1]} = Enum.split(hand, from)
      {l2, r2} = Enum.split(l1 ++ r1, to)
      l2 ++ [tile] ++ r2
    else hand end
  end

  def from_named_tile(state, tile_name) do
    cond do
      is_binary(tile_name) and tile_name in state.reserved_tiles ->
        case Enum.find_index(state.reserved_tiles, fn name -> name == tile_name end) do
          nil -> Map.get(state.tags, tile_name, nil) # check tags
          ix  -> Enum.at(state.dead_wall, -ix-1)
        end
      Utils.is_tile(tile_name) -> Utils.to_tile(tile_name)
      is_integer(tile_name) -> Enum.at(state.dead_wall, tile_name)
      is_atom(tile_name) -> tile_name
      true ->
        IO.puts("Unknown tile name #{inspect(tile_name)}")
        tile_name
    end
  end

  # TODO replace these calls
  def notify_ai(_state) do
    # IO.puts("Notifying ai")
    # IO.inspect(Process.info(self(), :current_stacktrace))
    GenServer.cast(self(), :notify_ai)
  end
  def notify_ai_marking(_state, seat) do
    GenServer.cast(self(), {:notify_ai_marking, seat})
  end
  def notify_ai_call_buttons(_state, seat) do
    GenServer.cast(self(), {:notify_ai_call_buttons, seat})
  end
  def notify_ai_declare_yaku(_state, seat) do
    GenServer.cast(self(), {:notify_ai_declare_yaku, seat})
  end

  defp translate_sets_in_match_definitions(match_definitions, set_definitions) do
    for match_definition <- match_definitions do
      for match_definition_elem <- match_definition do
        case match_definition_elem do
          [groups, num] ->
            translated_groups = for group <- groups do
              result = Map.get(set_definitions, group, group)
              # if is_binary(result) and not Utils.is_tile(result) do
              #   IO.puts("Warning: unrecognized set #{result}. Did you forget to put it in set_definitions?")
              # end
              result
            end
            [translated_groups, num]
          _ when is_binary(match_definition_elem) -> match_definition_elem
          _ ->
            IO.puts("#{inspect(match_definition_elem)} is not a valid match definition element.")
            GenServer.cast(self(), {:show_error, "#{inspect(match_definition_elem)} is not a valid match definition element."})
            nil
        end
      end
    end
  end

  # match_definitions is a list of match definitions, each of which is itself
  # a two-element list [groups, num] representing num times groups.
  # 
  # A list of match definitions succeeds when at least one match definition does,
  # and a match definition succeeds when each of its groups match some part of
  # the hand / calls in a non-overlapping manner.
  # 
  # A group is a list of tile sets. A group matches when any set matches.
  # 
  # Named match definitions can be defined as a key "mydef_definition" at the top level.
  # They expand to a list of match definitions that all get added to the list of
  # match definitions they appear in.
  # The toplevel "mydef_definition" may not reference other named match definitions.
  # 
  # Named sets can be found in the key "set_definitions".
  # This function simply swaps out all names for their respective definitions.
  # 
  # A match definition can also have one of the following strings as flags:
  #   "exhaustive": Perform an exhaustive backtracking search.
  #                 Useful when groups may overlap, thus a naive search without
  #                 backtracking will fail without this flag.
  #                 Runs in factorial time n! where n is the total number of groups.
  #   "unique": Use each group in each group set exactly once. Useful for defining kokushi.
  #   "nojoker": Ignore joker abilities.
  #
  # Example of a list of match definitions representing a winning hand:
  # [
  #   ["exhaustive", [["shuntsu", "koutsu"], 4], [["pair"], 1]],
  #   [[["pair"], 7]],
  #   "kokushi_musou" // defined top-level as "kokushi_musou_definition"
  # ]
  def translate_match_definitions(state, match_definitions) do
    set_definitions = if Map.has_key?(state.rules, "set_definitions") do state.rules["set_definitions"] else %{} end
    for match_definition <- match_definitions, reduce: [] do
      acc ->
        translated = cond do
          is_binary(match_definition) ->
            name = match_definition <> "_definition"
            if Map.has_key?(state.rules, name) do
              {am_match_definitions, match_definitions} = Enum.split_with(state.rules[name], &is_binary/1)
              translated_match_definitions = translate_sets_in_match_definitions(match_definitions, set_definitions)
              translated_am_match_definitions = American.translate_american_match_definitions(am_match_definitions)
              translated_match_definitions ++ translated_am_match_definitions
            else
              if String.contains?(match_definition, " ") do
                American.translate_american_match_definitions([match_definition])
              else
                GenServer.cast(self(), {:show_error, "Could not find match definition \"#{name}\" in the rules."})
                []
              end
            end
          is_list(match_definition)   -> translate_sets_in_match_definitions([match_definition], set_definitions)
          true                        ->
            GenServer.cast(self(), {:show_error, "#{inspect(match_definition)} is not a valid match definition."})
            []
        end
        [translated | acc]
    end |> Enum.reverse() |> Enum.concat()
  end

  def get_revealed_tiles(state) do
    for tile_spec <- state.revealed_tiles, reduce: [] do
      result ->
        cond do
          is_integer(tile_spec)    -> [Enum.at(state.dead_wall, tile_spec, :"1x") | result]
          Utils.is_tile(tile_spec) -> [Utils.to_tile(tile_spec) | result]
          true                     ->
            GenServer.cast(self(), {:show_error, "Unknown revealed tile spec: #{inspect(tile_spec)}"})
            result
        end
    end |> Enum.reverse()
  end

  def replace_revealed_tile(state, index, tile) do
    tile_spec = Enum.at(state.revealed_tiles, index)
    cond do
      is_integer(tile_spec)    -> update_in(state.dead_wall, &List.replace_at(&1, tile_spec, tile))
      Utils.is_tile(tile_spec) -> update_in(state.revealed_tiles, &List.replace_at(&1, index, tile))
      true                     ->
        GenServer.cast(self(), {:show_error, "Unknown revealed tile spec: #{inspect(tile_spec)}"})
        state
    end
  end

  def get_visible_tiles(state, seat \\ nil) do
    # construct all visible tiles
    visible_ponds = Enum.flat_map(state.players, fn {_seat, player} -> player.pond end)
    visible_calls = Enum.flat_map(state.players, fn {_seat, player} -> player.calls end) |> Enum.flat_map(&Utils.call_to_tiles/1) |> Enum.reject(&Utils.has_attr?(&1, ["concealed"]))
    visible_hands = Enum.flat_map(state.players, fn {dir, player} -> if player.hand_revealed or seat == dir do player.hand ++ player.draw else Enum.filter(player.hand ++ player.draw, fn tile -> Utils.has_attr?(tile, ["revealed"]) end) end end)
    visible_ponds ++ visible_calls ++ visible_hands
  end

  def get_visible_waits(state, seat, index) do
    hand = state.players[seat].hand ++ state.players[seat].draw
    hand = if index != nil do
      List.delete_at(hand, index)
    else hand end
    calls = state.players[seat].calls
    win_definitions = translate_match_definitions(state, Map.get(state.rules["show_waits"], "win_definitions", []))
    tile_behavior = state.players[seat].tile_behavior
    visible_tiles = get_visible_tiles(state, seat)
    Riichi.get_waits_and_ukeire(hand, calls, win_definitions, state.wall ++ state.dead_wall, visible_tiles, tile_behavior)
  end

  def get_doras(state) do
    Enum.flat_map(state.revealed_tiles, fn named_tile ->
      dora_indicator = from_named_tile(state, named_tile)
      (get_in(state.rules["dora_indicators"][Utils.tile_to_string(dora_indicator)]) || [])
      |> Enum.map(&Utils.to_tile/1)
    end)
  end

  def get_best_minefield_hand(state, seat, win_definitions, tiles, max_results \\ 100) do
    # returns {yakuman, han, minipoints, hand}
    tile_behavior = state.players[seat].tile_behavior
    score_rules = state.rules["score_calculation"]
    Enum.flat_map(win_definitions, &Match.remove_match_definition(tiles, [], ["almost" | &1], tile_behavior))
    |> Enum.take(max_results)
    |> Enum.map(fn {hand, _calls} -> tiles -- hand end)
    |> Enum.uniq()
    |> Enum.map(fn hand ->
      state2 = update_player(state, seat, &%Player{ &1 | hand: hand })
      {yaku, minipoints, _winning_tile} = Scoring.get_best_yaku_from_lists(state2, score_rules["yaku_lists"], seat, [:any], :discard)
      {yaku2, _minipoints, _winning_tile} = Scoring.get_best_yaku_from_lists(state2, score_rules["yaku2_lists"], seat, [:any], :discard)
      han = Enum.map(yaku, fn {_name, value} -> value end) |> Enum.sum()
      yakuman = Enum.map(yaku2, fn {_name, value} -> value end) |> Enum.sum()
      {yakuman, han, minipoints, hand}
    end)
    |> Enum.max(&>=/2, fn ->
      # take all doras and also take the most central tiles
      doras = get_doras(state)
      hand = tiles
      |> Enum.sort_by(&{&1 in doras, Riichi.get_centralness(&1)})
      |> Enum.take(-13)
      if length(hand) == 13 do {0, 0, 0, hand} else {-1, -1, -1, []} end
    end)
  end

  def player_name(state, seat) do
    "#{Riichi.get_seat_wind(state.kyoku, seat, state.available_seats)} #{state.players[seat].nickname}"
  end

  def push_message(state, message) do
    if not state.log_loading_mode do
      for {_seat, messages_state} <- state.messages_states, messages_state != nil do
        # IO.puts("Sending to #{inspect(messages_state)} the message #{inspect(message)}")
        GenServer.cast(messages_state, {:add_message, message})
      end
    end
  end

  def push_messages(state, messages) do
    if not state.log_loading_mode do
      for {_seat, messages_state} <- state.messages_states, messages_state != nil do
        # IO.puts("Sending to #{inspect(messages_state)} the messages #{inspect(messages)}")
        GenServer.cast(messages_state, {:add_messages, messages})
      end
    end
  end

  def broadcast_state_change(state, postprocess \\ false) do
    if postprocess do
      # async calculate playable indices for current turn player
      GenServer.cast(self(), :calculate_playable_indices)
      # async populate closest_american_hands for all players
      if state.ruleset == "american" do
        GenServer.cast(self(), :calculate_closest_american_hands)
      end
    end
    # IO.puts("broadcast_state_change called")
    RiichiAdvancedWeb.Endpoint.broadcast(state.ruleset <> ":" <> state.room_code, "state_updated", %{"state" => state})
    # reset anim
    state = update_all_players(state, fn _seat, player -> %Player{ player | last_discard: nil } end)
    state
  end

  def play_sound(state, path, seat \\ nil) do
    if not state.log_loading_mode do
      RiichiAdvancedWeb.Endpoint.broadcast(state.ruleset <> ":" <> state.room_code, "play_sound", %{"seat" => seat, "path" => path})
    end
  end

  def add_player(state, socket, seat, spectator) do
    state = if not spectator do
      # if we're replacing an ai, shutdown the ai
      state = if is_pid(Map.get(state, seat)) do
        IO.puts("Stopping AI for #{seat}: #{inspect(Map.get(state, seat))}")
        DynamicSupervisor.terminate_child(state.ai_supervisor, Map.get(state, seat))
        Map.put(state, seat, nil)
      else state end

      # tell everyone else
      push_message(state, %{text: "Player #{socket.assigns.nickname} joined as #{seat}"})

      # initialize the player
      state = Map.put(state, seat, socket.id)
      messages_state = Map.get(RiichiAdvanced.MessagesState.init_socket(socket), :messages_state, nil)
      state = put_in(state.messages_states[seat], messages_state)
      state = update_player(state, seat, &%Player{ &1 | nickname: socket.assigns.nickname })
      GenServer.call(state.exit_monitor, {:new_player, socket.root_pid, seat})
      IO.puts("Player #{socket.id} joined as #{seat}")

      # tell them about the replay UUID
      GenServer.cast(messages_state, {:add_message, [%{text: "Log ID:"}, %{bold: true, text: state.ref}]})
      state
    else
      messages_state = Map.get(RiichiAdvanced.MessagesState.init_socket(socket), :messages_state, nil)
      state = put_in(state.messages_states[socket.id], messages_state)
      GenServer.call(state.exit_monitor, {:new_player, socket.root_pid, socket.id})
      state
    end

    # for players with no seats, initialize an ai
    GenServer.cast(self(), {:fill_empty_seats_with_ai, false})
    state = broadcast_state_change(state)
    state
  end
  
  defp start_timer(state) do
    state = Map.put(state, :timer, Map.get(state.rules, "win_timer", 10))
    state = update_all_players(state, fn seat, player -> %Player{ player | ready: is_pid(Map.get(state, seat)) } end)
    
    if state.log_loading_mode do
      GenServer.cast(self(), :tick_timer)
    else
      Debounce.apply(state.timer_debouncer)
    end
    state
  end

  def handle_call({:new_player, socket}, _from, state) do
    {seat, spectator} = cond do
      :east in state.available_seats  and Map.get(socket.assigns, :seat_param) == "east"  and (Map.get(state, :east)  == nil or is_pid(Map.get(state, :east)))  and Map.get(state.reserved_seats, :east,  nil) in [nil, socket.assigns.session_id] -> {:east, false}
      :south in state.available_seats and Map.get(socket.assigns, :seat_param) == "south" and (Map.get(state, :south) == nil or is_pid(Map.get(state, :south))) and Map.get(state.reserved_seats, :south, nil) in [nil, socket.assigns.session_id] -> {:south, false}
      :west in state.available_seats  and Map.get(socket.assigns, :seat_param) == "west"  and (Map.get(state, :west)  == nil or is_pid(Map.get(state, :west)))  and Map.get(state.reserved_seats, :west,  nil) in [nil, socket.assigns.session_id] -> {:west, false}
      :north in state.available_seats and Map.get(socket.assigns, :seat_param) == "north" and (Map.get(state, :north) == nil or is_pid(Map.get(state, :north))) and Map.get(state.reserved_seats, :north, nil) in [nil, socket.assigns.session_id] -> {:north, false}
      Map.get(socket.assigns, :seat_param) == "spectator" -> {:east, true}
      :east in state.available_seats  and (Map.get(state, :east) == nil  or is_pid(Map.get(state, :east)))  and Map.get(state.reserved_seats, :east,  nil) in [nil, socket.assigns.session_id] -> {:east, false}
      :south in state.available_seats and (Map.get(state, :south) == nil or is_pid(Map.get(state, :south))) and Map.get(state.reserved_seats, :south, nil) in [nil, socket.assigns.session_id] -> {:south, false}
      :west in state.available_seats  and (Map.get(state, :west) == nil  or is_pid(Map.get(state, :west)))  and Map.get(state.reserved_seats, :west,  nil) in [nil, socket.assigns.session_id] -> {:west, false}
      :north in state.available_seats and (Map.get(state, :north) == nil or is_pid(Map.get(state, :north))) and Map.get(state.reserved_seats, :north, nil) in [nil, socket.assigns.session_id] -> {:north, false}
      true                                          -> {:east, true}
    end
    state = add_player(state, socket, seat, spectator)
    state = if not spectator and Map.get(state.reserved_seats, seat, nil) == nil do
      put_in(state.reserved_seats[seat], socket.assigns.session_id)
    else state end
    {:reply, {state, seat, spectator}, state}
  end
  
  def handle_call({:spectate, socket}, _from, state) do
    seat = :east
    spectator = true
    state = add_player(state, socket, seat, spectator)
    {:reply, {state, seat, spectator}, state}
  end

  def handle_call({:delete_player, seat}, _from, state) do
    state = put_in(state.messages_states[seat], nil)

    state = if seat in [:east, :south, :west, :north] do
      IO.puts("Player #{player_name(state, seat)} exited")
      state = Map.put(state, seat, nil)
      state = update_player(state, seat, &%Player{ &1 | nickname: nil })

      # tell everyone else
      push_message(state, %{text: "Player #{player_name(state, seat)} exited"})
      state
    else state end

    state = if Enum.all?(state.messages_states, fn {_seat, messages_state} -> messages_state == nil end) do
      # all players and spectators have left, schedule a shutdown
      if map_size(state.reserved_seats) <= 1 do
        # immediately stop solo games
        GenServer.cast(self(), :terminate_game_if_empty)
      else
        IO.puts("Stopping game #{state.room_code} in 60 seconds")
        :timer.apply_after(60000, GenServer, :cast, [self(), :terminate_game_if_empty])
      end
      state
    else
      # schedule replacing empty seats with AI after 5 seconds
      :timer.apply_after(5000, GenServer, :cast, [self(), {:fill_empty_seats_with_ai, true}])
      state = broadcast_state_change(state)
      state
    end
    {:reply, :ok, state}
  end

  def handle_call(:get_room_players, _from, state) do
    reserved_seats = state.reserved_seats
    |> Enum.filter(fn {seat, _session_id} -> seat != nil end)
    |> Map.new(fn {seat, session_id} -> {seat, %RoomPlayer{
      nickname: if state.players[seat].nickname == "" do
          "player" <> String.slice(Map.get(state, seat), 10, 4)
        else state.players[seat].nickname end,
      id: Map.get(state, seat),
      session_id: session_id,
      seat: seat
    }} end)
    {:reply, reserved_seats, state}
  end

  def handle_call({:is_playable, seat, tile}, _from, state), do: {:reply, is_playable?(state, seat, tile), state}

  # the AI calls these to figure out if it's allowed to play
  # (this is since they operate on a delay, so state may have changed between when they were
  # notified and when they decide to act)
  def handle_call({:can_discard, seat}, _from, state) do
    {:reply, Actions.can_discard(state, seat), state}
  end

  # marking calls
  def handle_call({:needs_marking?, seat}, _from, state), do: {:reply, Marking.needs_marking?(state, seat), state}
  def handle_call({:is_marked?, marking_player, seat, index, source}, _from, state), do: {:reply, Marking.is_marked?(state, marking_player, seat, index, source), state}
  def handle_call({:can_mark?, marking_player, seat, index, source}, _from, state), do: {:reply, Marking.can_mark?(state, marking_player, seat, index, source), state}

  # log control
  def handle_call({:put_log_loading_mode, mode}, _from, state) do
    prev_mode = state.log_loading_mode
    state = Map.put(state, :log_loading_mode, mode)
    {:reply, prev_mode, state}
  end
  def handle_call({:put_log_seeking_mode, mode}, _from, state) do
    prev_mode = state.log_seeking_mode
    state = Map.put(state, :log_seeking_mode, mode)
    {:reply, prev_mode, state}
  end

  # debugging only
  def handle_call(:get_log, _from, state) do
    log = Log.output(state)
    {:reply, log, state}
  end
  # debugging only
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end
  def handle_call({:put_state, new_state}, _from, state) do
    new_state = Map.drop(new_state, [
      :ruleset,
      :room_code,
      :ruleset_json,
      :mods,
      :supervisor,
      :mutex,
      :smt_solver,
      :ai_supervisor,
      :exit_monitor,
      :play_tile_debounce,
      :play_tile_debouncers,
      :big_text_debouncers,
      :timer_debouncer,
      :east,
      :south,
      :west,
      :north,
      :messages_states,
      :log_loading_mode,
      :log_seeking_mode,
    ])
    new_state = Map.merge(new_state, %{
      game_active: true,
      visible_screen: nil,
      error: nil,
      timer: 0,
    })
    new_state = Map.merge(state, new_state)
    new_state = broadcast_state_change(new_state, true)
    {:reply, new_state, new_state}
  end

  # used by lobby to get a room state from this game
  def handle_call(:get_lobby_room, _from, state) do
    lobby_room = %LobbyRoom{
      players: Map.new(state.players, fn {seat, player} -> {seat,
          if is_pid(Map.get(state, seat)) do
            %RoomPlayer{ nickname: player.nickname, seat: seat }
          else nil end
        } end),
      mods: state.mods,
      private: state.private,
      started: true
    }
    {:reply, lobby_room, state}
  end

  def handle_cast({:initialize_game, log}, state) do
    # run before_new_round actions
    state = if Map.has_key?(state.rules, "before_start") do
      Actions.run_actions(state, state.rules["before_start"]["actions"], %{seat: state.turn})
    else state end

    state = initialize_new_round(state, log)
    {:noreply, state}
  end

  def handle_cast(:terminate_game_if_empty, state) do
    if Enum.all?(state.messages_states, fn {_seat, messages_state} -> messages_state == nil end) do
      # all players and spectators have left, shutdown
      IO.puts("Stopping game #{state.room_code}")
      DynamicSupervisor.terminate_child(RiichiAdvanced.GameSessionSupervisor, state.supervisor)
    else
      IO.puts("Not stopping game #{state.room_code}")
    end
    {:noreply, state}
  end

  def handle_cast({:fill_empty_seats_with_ai, disconnected?}, state) do
    state = if not state.log_seeking_mode do
      state = for dir <- state.available_seats, Map.get(state, dir) == nil, disconnected? or not Map.has_key?(state.reserved_seats, dir), reduce: state do
        state ->
          {:ok, ai_pid} = DynamicSupervisor.start_child(state.ai_supervisor, %{
            id: RiichiAdvanced.AIPlayer,
            start: {RiichiAdvanced.AIPlayer, :start_link, [%{game_state: self(), ruleset: state.ruleset, seat: dir, player: state.players[dir], wall: Utils.sort_tiles(state.wall ++ state.dead_wall), shanten_definitions: state.shanten_definitions}]},
            restart: :permanent
          })
          IO.puts("Starting AI for #{dir}: #{inspect(ai_pid)}")
          state = Map.put(state, dir, ai_pid)

          # mark the ai as having clicked the timer, if one exists
          # also give them a nickname that hasn't been used
          nicknames = Constants.ai_names() -- Enum.map(state.players, fn {_seat, player} -> player.nickname end)
          state = update_player(state, dir, &%Player{ &1 | nickname: Enum.random(nicknames), ready: true })
          
          state
      end
      notify_ai(state)
      state = broadcast_state_change(state)
      state
    else state end
    {:noreply, state}
  end

  # log control
  def handle_cast(:sort_hands, state) do
    state = update_all_players(state, fn _seat, player -> %Player{ player | hand: Utils.sort_tiles(player.hand) } end)
    {:noreply, state}
  end

  def handle_cast({:reset_play_tile_debounce, seat}, state) do
    state = Map.update!(state, :play_tile_debounce, &Map.put(&1, seat, false))
    {:noreply, state}
  end
  
  def handle_cast({:reset_big_text, seat}, state) do
    state = update_player(state, seat, &Map.put(&1, :big_text, ""))
    state = broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast({:unpause, context}, state) do
    actions = state.players[context.seat].deferred_actions
    IO.puts("Unpausing with context #{inspect(context)}; actions are #{inspect(actions)}")
    state = Map.put(state, :game_active, true)
    state = Actions.run_deferred_actions(state, context)
    state = broadcast_state_change(state)
    notify_ai(state)
    {:noreply, state}
  end

  def handle_cast({:reindex_hand, seat, from, to}, state) do
    state = Actions.temp_disable_play_tile(state, seat)
    # IO.puts("#{seat} moved tile from #{from} to #{to}")
    state = update_player(state, seat, &%Player{ &1 | hand: _reindex_hand(&1.hand, from, to) })
    state = broadcast_state_change(state, true)
    {:noreply, state}
  end

  def handle_cast({:run_actions, actions, context}, state) do 
    state = Actions.run_actions(state, actions, context)
    state = broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast({:run_deferred_actions, context}, state) do 
    state = Actions.run_deferred_actions(state, context)
    state = broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast(:recalculate_buttons, state) do 
    state = Buttons.recalculate_buttons(state)
    notify_ai(state)
    state = broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast({:play_tile, seat, index}, state) do
    tile = Enum.at(state.players[seat].hand ++ state.players[seat].draw, index)
    can_discard = Actions.can_discard(state, seat)
    playable = is_playable?(state, seat, tile)
    if not can_discard or not playable do
      IO.puts("#{seat} tried to play an unplayable tile: #{inspect{tile}}")
    end
    state = if can_discard and playable and (state.play_tile_debounce[seat] == false or state.log_loading_mode) do
      state = Actions.temp_disable_play_tile(state, seat)
      # assume we're skipping our button choices
      state = update_player(state, seat, &%Player{ &1 | buttons: [], button_choices: %{}, call_buttons: %{}, choice: nil })
      actions = [["play_tile", tile, index], ["check_discard_passed"], ["advance_turn"]]
      state = Actions.submit_actions(state, seat, "play_tile", actions)
      state
    else state end
    {:noreply, state}
  end

  def handle_cast({:press_button, seat, button_name}, state) do
    {:noreply, Buttons.press_button(state, seat, button_name)}
  end

  def handle_cast({:press_call_button, seat, call_choice, called_tile}, state) do
    {:noreply, Buttons.press_call_button(state, seat, call_choice, called_tile)}
  end
  
  def handle_cast({:press_first_call_button, seat, button_name}, state) do
    button_choice = Map.get(state.players[seat].button_choices, button_name, nil)
    case button_choice do
      {:call, call_choices} ->
        {called_tile, choices} = Enum.at(call_choices, 0)
        call_choice = Enum.at(choices, 0)
        GenServer.cast(self(), {:press_call_button, seat, call_choice, called_tile})
      _ -> :ok
    end
    {:noreply, state}
  end
  
  def handle_cast({:press_saki_card, seat, choice}, state) do
    {:noreply, Buttons.press_call_button(state, seat, nil, nil, choice)}
  end

  def handle_cast({:trigger_auto_button, seat, auto_button_name}, state) do
    state = Actions.run_actions(state, state.rules["auto_buttons"][auto_button_name]["actions"], %{seat: seat, auto: true})
    state = broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast({:toggle_auto_button, seat, auto_button_name, enabled}, state) do
    # Keyword.put screws up ordering, so we need to use Enum.map
    state = update_player(state, seat, fn player -> %Player{ player | auto_buttons: Enum.map(player.auto_buttons, fn {name, desc, on} ->
      if auto_button_name == name do {name, desc, enabled} else {name, desc, on} end
    end) } end)
    # schedule a :trigger_auto_button message
    state = Buttons.trigger_auto_button(state, seat, auto_button_name, enabled)
    state = broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast({:cancel_call_buttons, seat}, state) do
    # go back to button clicking phase
    state = update_player(state, seat, fn player -> %Player{ player | buttons: Buttons.to_buttons(state, player.button_choices), call_buttons: %{}, deferred_actions: [], deferred_context: %{} } end)
    notify_ai(state)

    state = broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast(:notify_ai, state) do
    if not state.log_loading_mode do
      if state.game_active do
        # if there are any new buttons for any AI players, notify them
        # otherwise, just tell the current player it's their turn
        if Buttons.no_buttons_remaining?(state) do
          if is_pid(Map.get(state, state.turn)) do
            # IO.puts("Notifying #{state.turn} AI that it's their turn")
            params = %{
              player: state.players[state.turn],
              visible_tiles: get_visible_tiles(state, state.turn),
              closest_american_hands: state.players[state.turn].cache.closest_american_hands,
            }
            send(Map.get(state, state.turn), {:your_turn, params})
          end
        else
          Enum.each(state.available_seats, fn seat ->
            has_buttons = not Enum.empty?(state.players[seat].buttons)
            has_call_buttons = not Enum.empty?(state.players[seat].call_buttons)
            has_marking_ui = not Enum.empty?(state.marking[seat])
            last_discard_action = get_last_discard_action(state)
            last_discard = if last_discard_action != nil do Map.get(last_discard_action, :tile, nil) else nil end
            if is_pid(Map.get(state, seat)) and has_buttons and not has_call_buttons and not has_marking_ui do
              # IO.puts("Notifying #{seat} AI about their buttons: #{inspect(state.players[seat].buttons)}")
              send(Map.get(state, seat), {:buttons, %{player: state.players[seat], turn: state.turn, last_discard: last_discard}})
            end
          end)
        end
      else
        :timer.apply_after(1000, GenServer, :cast, [self(), :notify_ai])
      end
    end
    {:noreply, state}
  end

  def handle_cast({:notify_ai_marking, seat}, state) do
    if not state.log_loading_mode do
      if state.game_active do
        if is_pid(Map.get(state, seat)) and Marking.needs_marking?(state, seat) do
          # IO.puts("Notifying #{seat} AI about marking")
          state = update_player(state, seat, fn player -> %Player{ player | ai_thinking: true } end)
          state = broadcast_state_change(state)
          params = %{
            player: state.players[seat],
            players: state.players,
            visible_tiles: get_visible_tiles(state, seat),
            revealed_tiles: get_revealed_tiles(state),
            doras: get_doras(state),
            wall: Enum.drop(state.wall, state.wall_index),
            marked_objects: state.marking[seat],
            closest_american_hands: state.players[state.turn].cache.closest_american_hands,
          }
          send(Map.get(state, seat), {:mark_tiles, params})
        end
      else
        :timer.apply_after(1000, GenServer, :cast, [self(), {:notify_ai_marking, seat}])
      end
    end
    {:noreply, state}
  end

  def handle_cast({:notify_ai_call_buttons, seat}, state) do
    if not state.log_loading_mode do
      if state.game_active do
        call_choices = state.players[seat].call_buttons
        if is_pid(Map.get(state, seat)) and not Enum.empty?(call_choices) and not Enum.empty?(call_choices |> Map.values() |> Enum.concat()) do
          # IO.puts("Notifying #{seat} AI about their call buttons: #{inspect(state.players[seat].call_buttons)}")
          state = update_player(state, seat, fn player -> %Player{ player | ai_thinking: true } end)
          state = broadcast_state_change(state)
          send(Map.get(state, seat), {:call_buttons, %{player: state.players[seat]}})
        end
      else
        :timer.apply_after(1000, GenServer, :cast, [self(), {:notify_ai_call_buttons, seat}])
      end
    end
    {:noreply, state}
  end

  def handle_cast({:notify_ai_declare_yaku, seat}, state) do
    if not state.log_loading_mode do
      if state.game_active do
        if is_pid(Map.get(state, seat)) do
          state = update_player(state, seat, fn player -> %Player{ player | ai_thinking: true } end)
          state = broadcast_state_change(state)
          send(Map.get(state, seat), {:declare_yaku, %{player: state.players[seat]}})
        end
      else
        :timer.apply_after(1000, GenServer, :cast, [self(), {:notify_ai_declare_yaku, seat}])
      end
    end
    {:noreply, state}
  end

  # this is called by current turn ai when they decide to skip buttons
  def handle_cast({:ai_ignore_buttons, seat}, state) do
    if not state.log_loading_mode do
      if state.game_active do
        if is_pid(Map.get(state, seat)) and seat == state.turn do
          # IO.puts("Notifying #{seat} AI that it's their turn")
          state = update_player(state, seat, fn player -> %Player{ player | ai_thinking: true } end)
          state = broadcast_state_change(state)
          params = %{
            player: state.players[seat],
            visible_tiles: get_visible_tiles(state, seat),
            closest_american_hands: state.players[seat].cache.closest_american_hands,
          }
          send(Map.get(state, seat), {:your_turn, params})
        end
      else
        :timer.apply_after(1000, GenServer, :cast, [self(), {:ai_ignore_buttons, seat}])
      end
    end
    {:noreply, state}
  end

  # this is called by AI when they start thinking of what tile to drop or mark
  def handle_cast({:ai_thinking, seat}, state) do
    state = update_player(state, seat, fn player -> %Player{ player | ai_thinking: true } end)
    state = broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast({:ready_for_next_round, seat}, state) do
    state = update_player(state, seat, &%Player{ &1 | ready: true })
    {:noreply, state}
  end

  def handle_cast(:dismiss_error, state) do
    state = Map.put(state, :error, nil)
    state = broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast(:tick_timer, state) do
    state = cond do
      state.log_loading_mode    -> timer_finished(state)
      state.timer == :cancelled -> Map.put(state, :timer, 0)
      state.timer <= 0 or Enum.all?(state.players, fn {_seat, player} -> player.ready end) ->
        state = Map.put(state, :timer, 0)
        state = timer_finished(state)
        state
      true ->
        Debounce.apply(state.timer_debouncer)
        state = Map.put(state, :timer, state.timer - 1)
        state
    end
    state = broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast({:push_message, message}, state) do
    push_message(state, message)
    {:noreply, state}
  end

  def handle_cast({:show_error, message}, state) do
    state = show_error(state, message)
    {:noreply, state}
  end

  def handle_cast({:get_visible_waits, from, seat, index}, state) do
    if Map.has_key?(state.rules, "show_waits") do
      hand = state.players[seat].hand
      draw = state.players[seat].draw
      waits = cond do
        index == nil -> get_visible_waits(state, seat, nil)
        is_playable?(state, seat, Enum.at(hand ++ draw, index)) -> get_visible_waits(state, seat, index)
        true -> %{}
      end
      send(from, {:set_visible_waits, hand, index, waits})
    end
    {:noreply, state}
  end

  # marking calls
  def handle_cast({:mark_tile, marking_player, seat, index, source}, state) do
    state = Marking.mark_tile(state, marking_player, seat, index, source)
    state = Marking.adjudicate_marking(state)
    if Marking.needs_marking?(state, marking_player) do
      notify_ai_marking(state, marking_player)
    end
    state = broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast({:clear_marked_objects, marking_player}, state) do
    state = Marking.clear_marked_objects(state, marking_player)
    notify_ai_marking(state, marking_player)
    state = broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast({:reset_marking, seat}, state) do
    state = Marking.reset_marking(state, seat)

    # go back to button clicking phase
    state = Buttons.recalculate_buttons(state)
    state = update_player(state, seat, fn player -> %Player{ player | deferred_actions: [], deferred_context: %{} } end)
    notify_ai(state)

    state = broadcast_state_change(state)
    {:noreply, state}
  end

  # for log replays only
  def handle_cast({:put_marking, seat, marking}, state) do
    state = put_in(state.marking[seat], Log.decode_marking(marking))
    state = Marking.adjudicate_marking(state)
    if Marking.needs_marking?(state, seat) do
      notify_ai_marking(state, seat)
    end
    state = broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast({:declare_yaku, seat, yakus}, state) do
    state = update_player(state, seat, &%Player{ &1 | declared_yaku: yakus })
    button_name = state.players[seat].choice.name
    actions = state.rules["buttons"][button_name]["actions"]
    state = Actions.submit_actions(state, seat, button_name, actions, nil, nil, nil, yakus)
    state = broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast({:declare_dead_hand, seat, dead_seat}, state) do
    state = American.declare_dead_hand(state, seat, dead_seat)
    {:noreply, state}
  end

  def handle_cast(:calculate_playable_indices, state) do
    if state.calculate_playable_indices_pids[state.turn] do
      Process.exit(state.calculate_playable_indices_pids[state.turn], :kill)
    end
    self = self()
    {:ok, pid} = Task.start(fn ->
      player = state.players[state.turn]
      GenServer.cast(self, {:set_playable_indices, state.turn, for {tile, ix} <- Enum.with_index(player.hand ++ player.draw), is_playable?(state, state.turn, tile) do ix end})
    end)
    # set interim playable indices to include every tile
    state = state
    |> update_player(state.turn, &%Player{ &1 | cache: %PlayerCache{ &1.cache | playable_indices: Enum.with_index(&1.hand ++ &1.draw) |> Enum.map(fn {_, i} -> i end) } })
    |> Map.update!(:calculate_playable_indices_pids, &Map.put(&1, state.turn, pid))
    # IO.puts("done calculating playable indices for #{state.turn}")
    {:noreply, state}
  end

  def handle_cast(:calculate_closest_american_hands, state) do
    if state.calculate_closest_american_hands_pid do
      Process.exit(state.calculate_closest_american_hands_pid, :kill)
    end
    self = self()
    {:ok, pid} = Task.start(fn ->
      win_definition = Map.get(state.rules, "win_definition", [])
      for seat <- state.available_seats do
        closest_american_hands = American.compute_closest_american_hands(state, seat, win_definition, 5)
        GenServer.cast(self, {:set_closest_american_hands, seat, closest_american_hands})
      end
      # some conditions (namely "is_tenpai_american") might have changed based on closest american hands, so recalculate buttons
      GenServer.cast(self, :recalculate_buttons)
      # note that this races the AI: the AI might act before closest_american_hands is calculated, so they may miss buttons that should be there
      # TODO maybe fix this by pausing the game at the start of this particular async calculation, and unpausing after
    end)
    state = state
    |> Map.put(:calculate_closest_american_hands_pid, pid)
    # IO.puts("done calculating closest american hands")
    {:noreply, state}
  end

  def handle_cast({:set_playable_indices, seat, playable_indices}, state) do
    state = state
    |> update_player(seat, &%Player{ &1 | cache: %PlayerCache{ &1.cache | playable_indices: playable_indices } })
    |> Map.update!(:calculate_playable_indices_pids, &Map.put(&1, seat, nil))
    state = broadcast_state_change(state, false)
    {:noreply, state}
  end

  def handle_cast({:set_closest_american_hands, seat, closest_american_hands}, state) do
    state = state
    |> update_player(seat, &%Player{ &1 | cache: %PlayerCache{ &1.cache | closest_american_hands: closest_american_hands } })
    |> Map.put(:calculate_closest_american_hands_pid, nil)
    state = broadcast_state_change(state, false)
    {:noreply, state}
  end

  # for minefield ai
  def handle_cast({:get_best_minefield_hand, seat, win_definitions}, state) do
    self = self()
    {:ok, pid} = Task.start(fn ->
      tiles = Utils.strip_attrs(state.players[seat].hand)
      # look for certain hands
      {_yakuman, _han, _minipoints, hand} = Enum.max([
        # tsuuiisou
        get_best_minefield_hand(state, seat, win_definitions, Enum.filter(tiles, &Riichi.is_jihai?/1), 5),
        # chinitsu
        get_best_minefield_hand(state, seat, win_definitions, Enum.filter(tiles, &Riichi.is_manzu?/1), 10),
        get_best_minefield_hand(state, seat, win_definitions, Enum.filter(tiles, &Riichi.is_pinzu?/1), 10),
        get_best_minefield_hand(state, seat, win_definitions, Enum.filter(tiles, &Riichi.is_souzu?/1), 10),
        # honitsu
        get_best_minefield_hand(state, seat, win_definitions, Enum.filter(tiles, &Riichi.is_manzu?(&1) or Riichi.is_jihai?(&1)), 10),
        get_best_minefield_hand(state, seat, win_definitions, Enum.filter(tiles, &Riichi.is_pinzu?(&1) or Riichi.is_jihai?(&1)), 10),
        get_best_minefield_hand(state, seat, win_definitions, Enum.filter(tiles, &Riichi.is_pinzu?(&1) or Riichi.is_jihai?(&1)), 10),
        # tanyao
        get_best_minefield_hand(state, seat, win_definitions, Enum.filter(tiles, &Riichi.is_tanyaohai?/1), 10),
        # chanta
        get_best_minefield_hand(state, seat, win_definitions, Enum.filter(tiles, &Riichi.is_yaochuuhai?/1), 5),
        # any hand
        get_best_minefield_hand(state, seat, win_definitions, tiles, 10),
      ])
      # IO.inspect({yakuman, han, minipoints, hand})
      GenServer.cast(self, {:set_best_minefield_hand, seat, tiles, hand})
    end)
    state = Map.put(state, :get_best_minefield_hand_pid, pid)
    {:noreply, state}
  end

  def handle_cast({:set_best_minefield_hand, seat, tiles, hand}, state) do
    if length(hand) == 13 do
      send(Map.get(state, seat), {:set_best_minefield_hand, tiles, hand})
      notify_ai_marking(state, seat)
    else
      IO.inspect(hand, label: "#{seat} failed to calculate a valid minefield hand")
    end
    state = Map.put(state, :get_best_minefield_hand_pid, nil)
    {:noreply, state}
  end
end
