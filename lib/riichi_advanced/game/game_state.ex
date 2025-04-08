
defmodule RiichiAdvanced.GameState do
  alias RiichiAdvanced.GameState.Actions, as: Actions
  alias RiichiAdvanced.GameState.American, as: American
  alias RiichiAdvanced.GameState.Buttons, as: Buttons
  alias RiichiAdvanced.GameState.Conditions, as: Conditions
  alias RiichiAdvanced.GameState.Debug, as: Debug
  alias RiichiAdvanced.GameState.Rules, as: Rules
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
      saved_tile_behavior: %{}, # label => TileBehavior
      riichi_discard_indices: nil,
      playable_indices: [],
      closest_american_hands: [],
      winning_hand: [],
      arranged_hand: [],
      arranged_calls: [],
    ]
  end

  defmodule TileBehavior do
    defstruct [
      # aliases is a map looking like this:
      # %{"3m": %{["example"] => MapSet.new([{:any, ["joker"]}])}}
      # this says that any tile with the "joker" attr can be treated as "3m" with the "example" attr
      aliases: %{},
      ordering: %{:"1m"=>:"2m", :"2m"=>:"3m", :"3m"=>:"4m", :"4m"=>:"5m", :"5m"=>:"6m", :"6m"=>:"7m", :"7m"=>:"8m", :"8m"=>:"9m",
                  :"1p"=>:"2p", :"2p"=>:"3p", :"3p"=>:"4p", :"4p"=>:"5p", :"5p"=>:"6p", :"6p"=>:"7p", :"7p"=>:"8p", :"8p"=>:"9p",
                  :"1s"=>:"2s", :"2s"=>:"3s", :"3s"=>:"4s", :"4s"=>:"5s", :"5s"=>:"6s", :"6s"=>:"7s", :"7s"=>:"8s", :"8s"=>:"9s"},
      ordering_r: %{:"2m"=>:"1m", :"3m"=>:"2m", :"4m"=>:"3m", :"5m"=>:"4m", :"6m"=>:"5m", :"7m"=>:"6m", :"8m"=>:"7m", :"9m"=>:"8m",
                    :"2p"=>:"1p", :"3p"=>:"2p", :"4p"=>:"3p", :"5p"=>:"4p", :"6p"=>:"5p", :"7p"=>:"6p", :"8p"=>:"7p", :"9p"=>:"8p",
                    :"2s"=>:"1s", :"3s"=>:"2s", :"4s"=>:"3s", :"5s"=>:"4s", :"6s"=>:"5s", :"7s"=>:"6s", :"8s"=>:"7s", :"9s"=>:"8s"},
      tile_freqs: %{},
      dismantle_calls: false,
      ignore_suit: false
    ]
    def get_all_tiles(tile_behavior) do
      Map.keys(tile_behavior.tile_freqs) ++ Map.keys(tile_behavior.aliases)
    end
    def tile_mappings(tile_behavior) do
      for {tile1, attrs_aliases} <- tile_behavior.aliases, {attrs, aliases} <- attrs_aliases, tile2 <- aliases do
        %{tile2 => [Utils.add_attr(tile1, attrs)]}
      end |> Enum.reduce(%{}, &Map.merge(&1, &2, fn _k, l, r -> l ++ r end))
    end
    def is_any_joker?(tile, tile_behavior) do
      Enum.any?(Map.get(tile_behavior.aliases, :any, %{}), fn {_attrs, aliases} ->
        Utils.has_matching_tile?([tile], aliases)
      end)
    end
    def is_joker?(tile, tile_behavior) do
      Enum.any?(tile_behavior.aliases, fn {_tile1, attrs_aliases} ->
        Enum.any?(attrs_aliases, fn {_attrs, aliases} ->
          Utils.has_matching_tile?([tile], aliases)
        end)
      end)
    end
    def hash(tile_behavior) do
      :erlang.phash2({tile_behavior.aliases, tile_behavior.ordering, tile_behavior.tile_freqs, tile_behavior.dismantle_calls, tile_behavior.ignore_suit})
    end
    def joker_power(tile, tile_behavior) do
      is_any_joker = case Map.get(tile_behavior.aliases, :any) do
        nil -> false
        attrs_aliases ->
          Map.values(attrs_aliases)
          |> Enum.concat()
          |> Utils.has_matching_tile?([tile])
      end
      if is_any_joker do 1000000 else
        aliases = Utils.apply_tile_aliases(tile, tile_behavior)
        MapSet.size(aliases)
      end
    end
    # the idea is to move the most powerful jokers to the back
    # power is just number of aliases
    # then we sort by number of attrs (more attrs should be in the back)
    def sort_by_joker_power(tiles, tile_behavior) do
      Enum.sort_by(tiles, &{joker_power(&1, tile_behavior), length(Utils.get_attrs(&1))})
    end
    # replace aliases with the assignment given by the joker solver
    def from_joker_assignment(tile_behavior, smt_hand, joker_assignment) do
      # first get a map from joker to a list of tiles it got assigned to
      new_aliases = joker_assignment
      |> Enum.map(fn {joker_ix, tile} -> {Enum.at(smt_hand, joker_ix), tile} end)
      |> Enum.group_by(fn {joker, _tile} -> joker end)
      |> Enum.map(fn {joker, tiles} -> {joker, Enum.map(tiles, fn {_joker, tile} -> tile end)} end)
      |> Enum.reduce(%{}, fn {from, to_tiles}, aliases ->
        from_tiles = MapSet.new([from])
        for to <- to_tiles, reduce: aliases do
          aliases ->
            {to, attrs} = Utils.to_attr_tile(to)
            Map.update(aliases, to, %{attrs => from_tiles}, fn from -> Map.update(from, attrs, from_tiles, &MapSet.union(&1, from_tiles)) end)
        end
      end)
      %TileBehavior{ tile_behavior | aliases: new_aliases }
    end
    # get an assignment for the obvious jokers (the ones with only one assignable value)
    def get_obvious_joker_assignment(tile_behavior, smt_hand, smt_calls) do
      obvious_joker_map = tile_mappings(tile_behavior)
      |> Enum.flat_map(fn
        {joker, [assign]} -> [{joker, assign}]
        _ -> []
      end)
      |> Map.new()
      # return a map %{index => tile}
      Enum.with_index(smt_hand ++ Enum.concat(smt_calls))
      |> Enum.flat_map(fn {tile, ix} ->
        case Enum.find(obvious_joker_map, fn {from, _to} -> Utils.same_tile(tile, from) end) do
          nil         -> []
          {from, to} ->
            # replace any tiles
            base = if Utils.strip_attrs(to) == :any do tile else to end
            attrs = (Utils.get_attrs(tile) ++ Utils.get_attrs(to)) -- Utils.get_attrs(from)
            [{ix, Utils.add_attr(base, attrs)}]
        end
      end)
      |> Map.new()
    end
  end

  defmodule Player do
    # ensure this stays at or below 32 keys (currently 29)
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
      pao_map: %{}, # an entry %{seat => [yaku]} means if this player wins, `seat` must pay for `yaku`
      tile_behavior: %TileBehavior{},
      cache: %PlayerCache{},
    ]
  end

  defmodule Game do
    defstruct [
      # params
      ruleset: nil,
      room_code: nil,
      mods: nil,
      config: nil,
      private: true,
      reserved_seats: nil,
      init_actions: nil,
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
      rules_ref: nil,
      rules_text: %{},
      rules_text_order: [],
      interruptible_actions: %{},
      wall: [],
      kyoku: 0,
      honba: 0,
      pot: 0,
      log_state: %{},
      call_stack: [], # call stack limit is 10 for now
      block_events: false, # for tutorials
      forced_events: nil, # for tutorials
      last_event: nil, # for tutorials

      # working game state (reset on new round)
      # (these are all reset manually, so if you add a new one go to initialize_new_round to reset it)
      turn: :east,
      awaiting_discard: true, # prevent double discards
      dice: [],
      wall_index: 0,
      dead_wall_index: 0,
      haipai: [],
      actions: [],
      dead_wall: [],
      atop_wall: %{},
      reversed_turn_order: false,
      reserved_tiles: [],
      revealed_tiles: [],
      saved_revealed_tiles: [],
      max_revealed_tiles: 0,
      drawn_reserved_tiles: [],
      tags: %{},
      marking: Map.new([:east, :south, :west, :north], fn seat -> {seat, %{}} end),
    ]
  end

  def start_link(init_data) do
    # IO.puts("Game supervisor PID is #{inspect(self())}")
    GenServer.start_link(
      __MODULE__,
      %Game{
        supervisor: Keyword.get(init_data, :supervisor),
        room_code: Keyword.get(init_data, :room_code),
        ruleset: Keyword.get(init_data, :ruleset),
        mods: Keyword.get(init_data, :mods, []),
        config: Keyword.get(init_data, :config, nil),
        private: Keyword.get(init_data, :private, true),
        reserved_seats: Keyword.get(init_data, :reserved_seats, %{}),
        init_actions: Keyword.get(init_data, :init_actions, []),
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
    [{debouncers, _}] = Utils.registry_lookup("debouncers", state.ruleset, state.room_code)
    [{mutex, _}] = Utils.registry_lookup("mutex", state.ruleset, state.room_code)
    [{ai_supervisor, _}] = Utils.registry_lookup("ai_supervisor", state.ruleset, state.room_code)
    [{exit_monitor, _}] = Utils.registry_lookup("exit_monitor", state.ruleset, state.room_code)
    [{smt_solver, _}] = Utils.registry_lookup("smt_solver", state.ruleset, state.room_code)

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
      ModLoader.apply_mods(ruleset_json, mods, state.ruleset)
    else ruleset_json end
    |> ModLoader.apply_post_mods(state.ruleset)
    if not Enum.empty?(mods) do
      # cache mods
      RiichiAdvanced.ETSCache.put({state.ruleset, state.room_code}, mods, :cache_mods)
    end

    # apply config
    ruleset_json = if state.config != nil do
      try do
        ruleset_json = ModLoader.strip_comments(ruleset_json)
        query = ModLoader.convert_to_jq(ModLoader.strip_comments(state.config))
        JQ.query_string_with_string!(ruleset_json, query)
      rescue
        err ->
          IO.puts("Failed to load config:\n#{state.config}\nError was #{inspect(err)}")
          ruleset_json
      end
    else ruleset_json end

    # put params, debouncers, and process ids into state
    state = Map.merge(state, %Game{
      ruleset: state.ruleset,
      room_code: state.room_code,
      mods: state.mods,
      config: state.config,
      private: state.private,
      reserved_seats: state.reserved_seats,
      init_actions: state.init_actions,
      supervisor: state.supervisor,
      mutex: mutex,
      smt_solver: smt_solver,
      ai_supervisor: ai_supervisor,
      exit_monitor: exit_monitor,
      play_tile_debounce: %{:east => false, :south => false, :west => false, :north => false},
      play_tile_debouncers: play_tile_debouncers,
      big_text_debouncers: big_text_debouncers,
      timer_debouncer: timer_debouncer
    })

    state = case Rules.load_rules(ruleset_json, state.ruleset) do
      {:ok, rules_ref} -> Map.put(state, :rules_ref, rules_ref)
      {:error, msg}    -> show_error(state, msg)
    end

    state = Map.put(state, :available_seats, case Rules.get(state.rules_ref, "num_players", 4) do
      1 -> [:east]
      2 -> [:east, :west]
      3 -> [:east, :south, :west]
      4 -> [:east, :south, :west, :north]
    end)
    state = Map.put(state, :players, Map.new(state.available_seats, fn seat -> {seat, %Player{}} end))
    state = Log.init_log(state)

    state = Map.put(state, :kyoku, Rules.get(state.rules_ref, "starting_round", 0))
    state = Map.put(state, :honba, Rules.get(state.rules_ref, "starting_honba", 0))

    # initialize player state
    initial_score = Rules.get(state.rules_ref, "initial_score", 0)
    state = update_players(state, &%Player{ &1 | score: initial_score, start_score: initial_score })

    # generate a UUID
    state = Map.put(state, :ref, Ecto.UUID.generate())

    # run init actions
    state = run_init_actions(state)

    # run after_initialization actions
    state = Actions.trigger_event(state, "after_initialization", %{seat: state.turn})

    # terminate game if no one joins in 15 minutes
    # (also effectively serves as a 15 minute timeout for exunit tests)
    :timer.apply_after(900_000, GenServer, :cast, [self(), :terminate_game_if_empty])

    {:ok, state}
  end

  def run_init_actions(state) do
    for action <- state.init_actions, reduce: state do
      state -> case action do
        ["vacate_room" | _opts] ->
          RiichiAdvancedWeb.Endpoint.broadcast(state.ruleset <> "-room:" <> state.room_code, "vacate_room", nil)
          state
        ["initialize_tutorial" | _opts] ->
          state = Map.put(state, :forced_events, [])
          state = Map.put(state, :block_events, true)
          state
        ["init_player" | opts] ->
          session_id = Enum.at(opts, 0, nil)
          seat = Enum.at(opts, 1, "east")
          GenServer.cast(self(), {:init_player, session_id, seat})
          state
        ["fetch_messages" | opts] ->
          session_id = Enum.at(opts, 0, nil)
          GenServer.cast(self(), {:fetch_messages, session_id})
          state
        ["initialize_game" | opts] ->
          # this should happen after init_player calls (which populate state.reserved_seats)
          session_id = Enum.at(opts, 0, nil)
          log = Enum.at(opts, 1, nil)

          # run before_start actions
          state = Actions.trigger_event(state, "before_start", %{seat: state.turn})

          state = initialize_new_round(state, log)

          state = if log == nil do
            # add AI after initialization
            GenServer.cast(self(), {:fill_empty_seats_with_ai, false})
            state
          else
            # save session id as east reserved seat
            # this is so when log_control_state sends :load_log_control_state
            # we can relay it to the log_live with this session id
            put_in(state.reserved_seats, %{east: session_id})
          end

          state
        ["set_log_seeking_mode" | opts] ->
          log_seeking_mode = Enum.at(opts, 0, false)
          Map.put(state, :log_seeking_mode, log_seeking_mode)
        ["set_log_loading_mode" | opts] ->
          log_loading_mode = Enum.at(opts, 0, false)
          Map.put(state, :log_loading_mode, log_loading_mode)
        ["put_state", new_state] ->
          IO.puts("Restoring state for " <> Utils.to_registry_name("game_state", state.ruleset, state.room_code))
          :timer.apply_after(5000, GenServer, :cast, [self(), {:fill_empty_seats_with_ai, true}])
          merge_state(state, new_state)
        _ ->
          IO.puts("Unknown init action #{inspect(action)}")
          state
      end
    end
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
  def get_last_call(state) do
    last_call_action = get_last_call_action(state)
    if last_call_action != nil do
      {last_call_action.call_name, [last_call_action.called_tile | last_call_action.other_tiles]}
    else nil end
  end

  def show_error(state, message) do
    state = Map.update!(state, :error, fn err -> if err == nil do message else err <> "\n\n" <> message end end)
    state = broadcast_state_change(state)
    state
  end

  def translate(state, string) do
    case Rules.get(state.rules_ref, "translations") do
      nil -> string
      translations -> Map.get(translations, string, string)
    end
  end

  def initialize_new_round(state, kyoku_log \\ nil) do
    # t = System.os_time(:millisecond)
    {state, hands, scores} = if kyoku_log == nil do
      # initialize wall
      wall_tiles = Enum.map(Rules.get(state.rules_ref, "wall", []), &Utils.to_tile(&1))

      # check that there are no nil tiles
      state = wall_tiles
      |> Enum.zip(Rules.get(state.rules_ref, "wall", []))
      |> Enum.filter(fn {result, _orig} -> result == nil end)
      |> Enum.reduce(state, fn {_result, orig}, state -> show_error(state, "#{inspect(orig)} is not a valid wall tile!") end)

      # shuffle wall
      wall = Enum.shuffle(wall_tiles)
      starting_tiles = Rules.get(state.rules_ref, "starting_tiles", 0)
      # wall_index = Map.values(hands) |> Enum.map(&Kernel.length/1) |> Enum.sum()
      wall_index = starting_tiles * length(state.available_seats)

      # rig the wall as the gods command
      wall = if Debug.debug() do Debug.set_wall(wall) else wall end

      # "starting_hand" debug key
      rig_starting_hand = case Rules.get(state.rules_ref, "starting_hand") do
        nil -> []
        starting_hands ->
          for {seat, starting_hand} <- starting_hands, reduce: [] do
            rig_starting_hand ->
              start_index = case seat do
                "east"  -> 0
                "south" -> starting_tiles
                "west"  -> if length(state.available_seats) == 2 do starting_tiles else starting_tiles * 2 end
                "north" -> starting_tiles * 3
                _       -> nil
              end
              rig = if seat != nil do
                starting_hand
                |> Enum.map(&Utils.to_tile/1)
                |> Enum.with_index()
                |> Enum.map(fn {tile, i} -> {start_index + i, tile} end)
              else [] end
              rig ++ rig_starting_hand
          end
      end

      # "starting_draws" debug key
      rig_starting_draws = case Rules.get(state.rules_ref, "starting_draws") do
        nil -> []
        starting_draws ->
          starting_draws
          |> Enum.map(&Utils.to_tile/1)
          |> Enum.with_index()
          |> Enum.map(fn {tile, i} -> {wall_index + i, tile} end)
      end

      # "starting_dead_wall" debug key
      rig_dead_wall = case Rules.get(state.rules_ref, "starting_dead_wall") do
        nil -> []
        starting_dead_wall ->
          starting_dead_wall
          |> Enum.map(&Utils.to_tile/1)
          |> Enum.with_index()
          |> Enum.map(fn {tile, i} ->
            reverse_parity = if rem(i, 2) == 0 do -1 else 1 end
            {length(wall) - i - 1 + reverse_parity, tile}
          end)
      end

      # swap tiles so that the specified tiles are at the specified indices
      rig_spec = rig_starting_hand ++ rig_starting_draws ++ rig_dead_wall
      wall = if not Enum.empty?(rig_spec) do
        rig_spec = Map.new(rig_spec)
        {wall, _tiles} =  for i <- length(wall)-1..0//-1, reduce: {[], Enum.shuffle(wall -- Map.values(rig_spec))} do
          {wall, tiles} -> cond do
            Map.has_key?(rig_spec, i) -> {[rig_spec[i] | wall], tiles}
            not Enum.empty?(tiles) -> with [tile | tiles] <- tiles, do: {[tile | wall], tiles}
            true -> {wall, []}
          end
        end
        wall
      else wall end

      # wall is now built
      if Enum.frequencies(wall) != Enum.frequencies(wall_tiles) do
        missing = wall_tiles -- wall
        extra = wall -- wall_tiles
        IO.puts("Warning: rigged wall:\n- is missing these tiles: #{inspect(missing)}\n- is extra these tiles: #{inspect(extra)}")
      end

      # distribute haipai
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

      # build dead wall
      dead_wall_length = Rules.get(state.rules_ref, "initial_dead_wall_length", 0)
      {wall, dead_wall} = if dead_wall_length > 0 do
        Enum.split(wall, -dead_wall_length)
      else {wall, []} end
      revealed_tiles = Rules.get(state.rules_ref, "revealed_tiles", [])
      max_revealed_tiles = Rules.get(state.rules_ref, "max_revealed_tiles", 0)

      state = state
      |> Map.put(:wall, wall)
      |> Map.put(:haipai, hands)
      |> Map.put(:dead_wall, dead_wall)
      |> Map.put(:wall_index, wall_index)
      |> Map.put(:dead_wall_index, 0)
      |> Map.put(:revealed_tiles, revealed_tiles)
      |> Map.put(:saved_revealed_tiles, revealed_tiles)
      |> Map.put(:max_revealed_tiles, max_revealed_tiles)

      # reserve some tiles in the dead wall
      reserved_tiles = Rules.get(state.rules_ref, "reserved_tiles", [])
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

      # roll dice
      num_dice = Rules.get(state.rules_ref, "num_dice", 2)
      num_dice = max(2, num_dice)
      num_dice = min(10, num_dice)
      dice = [
        Rules.get(state.rules_ref, "die1", :rand.uniform(6)),
        Rules.get(state.rules_ref, "die2", :rand.uniform(6))
      ] ++ Enum.map(2..(num_dice - 2)//1, fn _ -> :rand.uniform(6) end)

      state = Map.put(state, :dice, dice)

      scores = Map.new(state.players, fn {seat, player} -> {seat, player.score} end)

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
      reserved_tiles = Rules.get(state.rules_ref, "reserved_tiles", [])
      revealed_tiles = Rules.get(state.rules_ref, "revealed_tiles", [])
      max_revealed_tiles = Rules.get(state.rules_ref, "max_revealed_tiles", 0)

      state = state
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

      scores = kyoku_log["players"]
      |> Enum.zip(state.available_seats)
      |> Map.new(fn {player_obj, seat} -> {seat, player_obj["points"]} end)

      # set other variables that log contains
      state = state
      |> Map.put(:kyoku, kyoku_log["kyoku"])
      |> Map.put(:pot, kyoku_log["riichi_sticks"] * 1000)
      |> Map.put(:honba, kyoku_log["honba"])
      |> Map.put(:dice, [kyoku_log["die1"], kyoku_log["die2"]])

      {state, hands, scores}
    end

    # initialize other constants
    persistent_statuses = Rules.get(state.rules_ref, "persistent_statuses", [])
    persistent_counters = Rules.get(state.rules_ref, "persistent_counters", [])
    persistent_tags = Rules.get(state.rules_ref, "persistent_tags", [])
    initial_auto_buttons = for {name, auto_button} <- Rules.get(state.rules_ref, "auto_buttons", []) do
      {name, auto_button["desc"], Map.get(auto_button, "enabled_at_start", false) and not state.log_seeking_mode}
    end

    # reset player state
    tile_freqs = Enum.frequencies(state.wall ++ state.dead_wall)
    state = state
    |> update_all_players(&%Player{
         score: scores[&1],
         start_score: scores[&1],
         nickname: &2.nickname,
         hand: hands[&1],
         auto_buttons: initial_auto_buttons,
         status: MapSet.filter(&2.status, fn status -> status in persistent_statuses end),
         counters: Enum.filter(&2.counters, fn {counter, _amt} -> counter in persistent_counters end) |> Map.new(),
         tile_behavior: %TileBehavior{ tile_freqs: tile_freqs }
       })
    |> Map.put(:atop_wall, %{})
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
    |> Map.update!(:tags, &Enum.filter(&1, fn {tag, _tiles} -> tag in persistent_tags end) |> Map.new())

    # initialize marking
    state = Marking.initialize_marking(state)

    # initialize log
    state = Log.initialize_new_round(state)

    # initialize saki if needed
    state = if Rules.get(state.rules_ref, "enable_saki_cards", false) do Saki.initialize_saki(state) else state end
    
    # start the game with interrupts disabled
    state = Map.put(state, :interruptible_actions, %{})
    state = Actions.change_turn(state, Riichi.get_east_player_seat(state.kyoku, state.available_seats))

    # run after_start actions
    state = Actions.trigger_event(state, "after_start", %{seat: state.turn})

    # initialize interruptible actions
    # we only do this after running change_turn and after_start, so that their actions can't be interrupted
    interruptible_actions = Map.new(Rules.get(state.rules_ref, "interruptible_actions", []), fn action -> {action, 100} end)
    |> Map.merge(Rules.get(state.rules_ref, "interrupt_levels", %{}))
    state = Map.put(state, :interruptible_actions, interruptible_actions)

    # recalculate buttons at the start of the game
    state = Buttons.recalculate_buttons(state)

    notify_ai_new_round(state)

    # ensure playable_indices is populated after the after_start actions
    state = broadcast_state_change(state, true)

    # IO.puts("initialize_new_round: #{inspect(System.os_time(:millisecond) - t)} ms")

    state
  end

  def win(state, seat, win_source) do
    state = Map.put(state, :round_result, :win)

    # run before_win actions
    state = Actions.trigger_event(state, "before_win", %{seat: seat, win_source: win_source})

    # reset animation (and allow discarding again, in bloody end rules)
    state = update_all_players(state, fn _seat, player -> %Player{ player | last_discard: nil } end)

    state = Map.put(state, :game_active, false)
    state = Map.put(state, :visible_screen, :winner)
    state = start_timer(state)

    winner = Scoring.calculate_winner_details(state, seat, win_source)
    state = update_player(state, seat, fn player -> %Player{ player | cache: %PlayerCache{ player.cache | arranged_hand: winner.arranged_hand, arranged_calls: winner.arranged_calls } } end)
    state = Map.update!(state, :winners, &Map.put(&1, seat, winner))
    state = Map.update!(state, :winner_seats, & &1 ++ [seat])

    hand = (state.players[seat].hand ++ Enum.flat_map(state.players[seat].calls, &Utils.call_to_tiles/1))
    |> Utils.sort_tiles()

    push_message(state, player_prefix(state, seat) ++ [%{
      text: "called %{call} on %{tile} with hand %{hand}",
      vars: %{
        call: {:text, "#{String.downcase(winner.winning_tile_text)}", %{bold: true}},
        tile: {:tile, winner.winning_tile},
        hand: {:hand, hand}
      }
    }])

    state = if Rules.get(state.rules_ref, "bloody_end", false) do
      # only end the round once there are three winners; otherwise, continue
      Map.put(state, :round_result, if map_size(state.winners) == 3 do :win else :continue end)
    else state end

    # run after_win actions
    state = Actions.trigger_event(state, "after_win", winner)

    # Push message about yaku and score
    winner = state.winners[seat]
    push_message(state, player_prefix(state, seat) ++ [
      %{text: "scored a %{score}-point hand", vars: %{score: winner.displayed_score}},
    ] ++ if not Enum.empty?(winner.yaku) or not Enum.empty?(winner.yaku2) do
           [%{text: "with yaku:"}]
           ++ Utils.print_yaku(winner.yaku)
           ++ if Enum.empty?(winner.yaku) or Enum.empty?(winner.yaku2) do [] else [%{text: " / "}] end
           ++ Utils.print_yaku(winner.yaku2)
         else [] end
    )

    state
  end

  def exhaustive_draw(state, draw_name) do
    state = Map.put(state, :round_result, :exhaustive_draw)

    push_message(state, [%{text: "Game ended by exhaustive draw"}])

    # run before_exhaustive_draw actions
    state = Actions.trigger_event(state, "before_exhaustive_draw", %{seat: state.turn})

    # reset animation
    state = update_all_players(state, fn _seat, player -> %Player{ player | last_discard: nil } end)

    state = Map.put(state, :game_active, false)

    {state, delta_scores, delta_scores_reason, next_dealer} = Scoring.adjudicate_draw_scoring(state)
    state = Map.put(state, :delta_scores, delta_scores)
    state = Map.put(state, :delta_scores_reason, if draw_name do draw_name else delta_scores_reason end)
    state = Map.put(state, :next_dealer, next_dealer)

    # run after_scoring actions
    state = Actions.trigger_event(state, "after_scoring", %{seat: state.turn})

    state = if state.winner_index < map_size(state.winners) do
      # in sichuan you get winners for tenpai players at draw, so show winner screen if needed
      Map.put(state, :visible_screen, :winner)
    else
      # otherwise show score exchange screen as normal
      Map.put(state, :visible_screen, :scores)
    end
    state = start_timer(state)
    state
  end

  def abortive_draw(state, draw_name) do
    state = Map.put(state, :round_result, :abortive_draw)
    IO.puts("Abort")

    push_message(state, [%{text: "Game ended by abortive draw: (%{draw_name})", vars: %{draw_name: draw_name}}])

    # run before_abortive_draw actions
    state = Actions.trigger_event(state, "before_abortive_draw", %{seat: state.turn})

    # reset animation
    state = update_all_players(state, fn _seat, player -> %Player{ player | last_discard: nil } end)

    state = Map.put(state, :game_active, false)

    delta_scores = Map.new(state.players, fn {seat, _player} -> {seat, 0} end)
    state = Map.put(state, :delta_scores, delta_scores)
    state = Map.put(state, :delta_scores_reason, if draw_name do draw_name else "Abortive Draw" end)
    state = Map.put(state, :next_dealer, :self)

    # run after_scoring actions
    state = Actions.trigger_event(state, "after_scoring", %{seat: state.turn})

    state = Map.put(state, :visible_screen, :scores)
    state = start_timer(state)

    state
  end

  defp timer_finished(state) do
    cond do
      state.visible_screen == :winner and state.winner_index + 1 < map_size(state.winners) -> # need to see next winner screen
        # show the next winner
        state = Map.update!(state, :winner_index, & &1 + 1)

        # reset timer
        state = start_timer(state)

        state
      state.visible_screen == :winner -> # need to see score exchange screen
        # since seeing this screen means we're done with all the winners so far, calculate the delta scores
        {state, delta_scores, delta_scores_reason, next_dealer} = Scoring.adjudicate_win_scoring(state)
        state = Map.put(state, :delta_scores, delta_scores)
        state = Map.put(state, :delta_scores_reason, delta_scores_reason)
        # only populate next_dealer the first time we call Scoring.adjudicate_win_scoring
        state = if state.next_dealer == nil do Map.put(state, :next_dealer, next_dealer) else state end

        state = if Rules.get(state.rules_ref, "bloody_end", false) and state.round_result != :continue do
          push_message(state, [%{text: "Game ended after three winners"}])

          # run before_exhaustive_draw actions
          state = Actions.trigger_event(state, "before_exhaustive_draw", %{seat: state.turn})

          # reset animation
          state = update_all_players(state, fn _seat, player -> %Player{ player | last_discard: nil } end)

          state = Map.put(state, :game_active, false)

          prev_round_result = state.round_result
          {state, delta_scores, delta_scores_reason, _next_dealer} = Scoring.adjudicate_draw_scoring(state)
          state = Map.put(state, :delta_scores, Map.merge(state.delta_scores, delta_scores, fn _k, l, r -> l + r end))
          state = Map.put(state, :delta_scores_reason, delta_scores_reason)
          state = Map.put(state, :round_result, prev_round_result)
          state
        else state end

        # run after_scoring actions
        context = state.winners[Enum.at(state.winner_seats, state.winner_index)]
        state = Actions.trigger_event(state, "after_scoring", context)

        # show score exchange screen
        state = Map.put(state, :visible_screen, :scores)
        
        # next time we're on the winner screen, show the next winner
        state = Map.update!(state, :winner_index, & &1 + 1)

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

        # run before_start actions
        # we need to run it here instead of in initialize_new_round
        # so that it can impact e.g. tobi calculations and log
        state = if state.round_result != :continue do
          Actions.trigger_event(state, "before_start", %{seat: state.turn})
        else state end

        # log game, unless we are viewing a log or if this is a tutorial
        if not state.log_seeking_mode and state.forced_events == nil do
          IO.puts("Logging game #{state.ref}")
          Log.output_to_file(state)
        end
        state = Log.finalize_kyoku(state)

        # check for tobi
        state = case Rules.get(state.rules_ref, "score_calculation") do
          nil -> state
          score_calculation ->
            if Map.has_key?(score_calculation, "tobi") do
              tobi = Map.get(score_calculation, "tobi", 0)
              if Enum.any?(state.players, fn {_seat, player} -> player.score < tobi end) do
                Map.put(state, :round_result, :end_game)
              else state end
            else state end
        end

        # finish or initialize new round if needed, otherwise continue
        state = if state.round_result != :continue do

          if should_end_game(state) do
            finalize_game(state)
          else
            if not state.log_seeking_mode do
              # update starting score for the round
              state = update_all_players(state, fn _seat, player -> %Player{ player | start_score: player.score } end)
              # clear delta scores (TODO is :delta_scores really a control variable then?)
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
                :exhaustive_draw when state.next_dealer == :self ->
                  state
                    |> Map.update!(:honba, & &1 + 1)
                    |> Map.put(:visible_screen, nil)
                :exhaustive_draw ->
                  state
                    |> Map.update!(:kyoku, & &1 + 1)
                    |> Map.update!(:honba, & &1 + 1)
                    |> Map.put(:visible_screen, nil)
                :abortive_draw when state.next_dealer == :self ->
                  state
                    |> Map.update!(:honba, & &1 + 1)
                    |> Map.put(:visible_screen, nil)
                :abortive_draw ->
                  state
                    |> Map.update!(:kyoku, & &1 + 1)
                    |> Map.update!(:honba, & &1 + 1)
                    |> Map.put(:visible_screen, nil)
                :continue -> state
                :end_game -> state
              end
              initialize_new_round(state)
            else
              if not state.log_loading_mode do
                # seek to the next round
                [{log_control_state, _}] = Utils.registry_lookup("log_control_state", state.ruleset, state.room_code)
                GenServer.cast(log_control_state, {:seek, state.kyoku + 1, -1})
                state
              else state end
            end
          end
        else 
          state = Map.put(state, :visible_screen, nil)
          state = Map.put(state, :game_active, true)

          # trigger before_continue actions
          state = Actions.trigger_event(state, "before_continue", %{seat: state.turn})

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
    agariyame = Rules.get(state.rules_ref, "agariyame", false) and state.round_result == :win and dealer in state.winner_seats
    tenpaiyame = Rules.get(state.rules_ref, "tenpaiyame", false) and state.round_result in [:exhaustive_draw, :abortive_draw] and "tenpai" in state.players[dealer].status
    max_rounds = Rules.get(state.rules_ref, "max_rounds", :infinity)
    past_max_rounds = state.kyoku >= max_rounds - 1
    forced or (agariyame and past_max_rounds) or (tenpaiyame and past_max_rounds) or if Rules.has_key?(state.rules_ref, "sudden_death_goal") do
      above_goal = Enum.any?(state.players, fn {_seat, player} -> player.score >= Rules.get(state.rules_ref, "sudden_death_goal") end)
      past_extra_max_rounds = state.kyoku >= max_rounds + 3
      (above_goal and past_max_rounds) or past_extra_max_rounds
    else past_max_rounds end
  end

  def finalize_game(state) do
    # trigger before_conclusion actions
    state = Actions.trigger_event(state, "before_conclusion", %{seat: state.turn})

    IO.puts("Game concluded")
    state = Map.put(state, :visible_screen, :game_end)
    state
  end

  def has_unskippable_button?(state, seat) do
    buttons = Rules.get(state.rules_ref, "buttons", %{})
    not Enum.empty?(state.players[seat].call_buttons)
    or
    Enum.any?(state.players[seat].buttons, fn button_name ->
      buttons[button_name] != nil
      and Map.has_key?(buttons[button_name], "unskippable")
      and buttons[button_name]["unskippable"]
    end)
  end

  def is_playable?(state, seat, tile) do
    tile != nil
    and not has_unskippable_button?(state, seat)
    and not Utils.has_attr?(tile, ["no_discard"])
    and if Rules.has_key?(state.rules_ref, "play_restrictions") do
      Enum.all?(Rules.get(state.rules_ref, "play_restrictions"), fn [tile_spec, cond_spec] ->
        not Riichi.tile_matches(tile_spec, %{seat: seat, tile: tile, players: state.players})
        or not Conditions.check_cnf_condition(state, cond_spec, %{seat: seat, tile: tile})
        # or not (Conditions.check_cnf_condition(state, cond_spec, %{seat: seat, tile: tile}) |> IO.inspect(label: inspect({seat, tile, cond_spec})))
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

  def is_named_tile(state, tile_name) do
    cond do
      is_binary(tile_name) and tile_name in state.reserved_tiles -> true
      Utils.is_tile(tile_name) -> true
      is_integer(tile_name) -> true
      is_atom(tile_name) -> true
      true -> false
    end
  end
  
  def from_named_tile(state, context, tile_name) do
    cond do
      is_binary(tile_name) and tile_name in state.reserved_tiles ->
        case Enum.find_index(state.reserved_tiles, fn name -> name == tile_name end) do
          nil -> Map.get(state.tags, tile_name, MapSet.new()) |> Enum.at(0) # check tags
          ix  -> Enum.at(state.dead_wall, -ix-1)
        end
      Utils.is_tile(tile_name) -> Utils.to_tile(tile_name)
      is_binary(tile_name)
          and Map.has_key?(context, :seat)
          and Map.has_key?(state.players[context.seat].counters, tile_name) ->
        Enum.at(state.dead_wall, state.players[context.seat].counters[tile_name])
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
  def notify_ai_new_round(_state) do
    GenServer.cast(self(), :notify_ai_new_round)
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

  def get_scryed_tiles(state, seat) do
    Enum.slice(state.wall, state.wall_index, state.players[seat].num_scryed_tiles)
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

  def get_winning_tiles(state, seat, :draw) do
    winning_tile = Enum.at(state.players[seat].draw, 0)
    if winning_tile != nil do MapSet.new([winning_tile]) else MapSet.new() end
  end
  def get_winning_tiles(state, _seat, :discard) do
    last_discarder_action = get_last_discard_action(state)
    if last_discarder_action != nil do
      last_discarder = last_discarder_action.seat
      winning_tile = Enum.at(state.players[last_discarder].discards, -1)
      if winning_tile != nil do MapSet.new([winning_tile]) else MapSet.new() end
    else MapSet.new() end
  end
  def get_winning_tiles(state, _seat, :call) do
    last_call_action = get_last_call_action(state)
    if last_call_action != nil do
      {_name, call} = Enum.at(state.players[last_call_action.seat].calls, -1)
      winning_tile = Enum.find(call, &Utils.same_tile(&1, last_call_action.called_tile))
      if winning_tile != nil do MapSet.new([winning_tile]) else MapSet.new() end
    else MapSet.new() end
  end
  def get_winning_tiles(state, _seat, :second_discard) do
    winning_tile = state.players[get_last_discard_action(state).seat].pond
    |> Enum.reverse()
    |> Enum.drop(1)
    |> Enum.find(fn tile -> not Utils.has_matching_tile?([tile], [:"1x", :"2x"]) end)
    if winning_tile != nil do MapSet.new([winning_tile]) else MapSet.new() end
  end
  def get_winning_tiles(state, seat, win_source) do
    cond do
      win_source in [:worst_discard, :best_draw] ->
        winner = state.players[seat]
        win_definitions = Rules.translate_match_definitions(state.rules_ref, ["win"])
        waits = Riichi.get_waits(winner.hand, winner.calls, win_definitions, winner.tile_behavior)
        if Enum.empty?(waits) do MapSet.new([:"2x"]) else waits end
    end
  end

  def update_winning_tile(state, seat, :draw, fun) do
    update_in(state.players[seat].draw, fn
      [draw] -> [fun.(draw)]
      draw -> draw # no op if 0 or 2+ draws
    end)
  end
  def update_winning_tile(state, seat, :best_draw, fun), do: update_winning_tile(state, seat, :draw, fun)
  def update_winning_tile(state, _seat, :call, fun) do
    last_call_action = get_last_call_action(state)
    if last_call_action != nil do
      update_in(state.players[last_call_action.seat].calls, fn calls ->
        {name, call} = Enum.at(calls, -1)
        ix = Enum.find_index(call, &Utils.same_tile(&1, last_call_action.called_tile))
        updated_call = List.update_at(call, ix, fun)
        List.replace_at(calls, -1, {name, updated_call})
      end)
    else state end
  end
  def update_winning_tile(state, _seat, win_source, fun) do
    ix = case win_source do
      :discard -> -1
      :second_discard -> -2
      :worst_discard -> -1
    end
    last_discard_action = get_last_discard_action(state)
    if last_discard_action != nil do
      last_discarder = last_discard_action.seat
      state = update_in(state.players[last_discarder].discards, &List.update_at(&1, ix, fun))
      state = update_in(state.players[last_discarder].pond, &List.update_at(&1, ix, fun))
      state
    else
      # this branch is basically only used for tests
      last_discarder = Utils.prev_turn(state.turn)
      state = update_in(state.players[last_discarder].discards, fn _ -> IO.inspect([fun.(:"4x")]) end)
      state = update_in(state.players[last_discarder].pond, fn _ -> [fun.(:"4x")] end)
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
    win_definitions = Rules.translate_match_definitions(state.rules_ref, Rules.get(state.rules_ref, "show_waits", %{}) |> Map.get("win_definitions", []))
    tile_behavior = state.players[seat].tile_behavior
    visible_tiles = get_visible_tiles(state, seat)
    Riichi.get_waits_and_ukeire(hand, calls, win_definitions, visible_tiles, tile_behavior)
  end

  def get_open_riichi_hands(state) do
    state.players
    |> Enum.filter(fn {_seat, player} -> player.hand_revealed end)
    |> Enum.map(fn {_seat, player} -> {player.hand, player.calls, player.tile_behavior} end)
  end

  def get_doras(state) do
    dora_indicators_map = Rules.get(state.rules_ref, "dora_indicators", %{})
    Enum.flat_map(state.revealed_tiles, fn named_tile ->
      dora_indicator = from_named_tile(state, %{}, named_tile)
      Map.get(dora_indicators_map, Utils.tile_to_string(dora_indicator), [])
      |> Enum.map(&Utils.to_tile/1)
    end)
  end

  def get_best_minefield_hand(state, seat, tenpai_definitions, tiles, max_results \\ 100) do
    # returns {yakuman, han, minipoints, hand}
    tile_behavior = state.players[seat].tile_behavior
    # all_tiles = TileBehavior.get_all_tiles(tile_behavior)
    score_rules = Rules.get(state.rules_ref, "score_calculation", %{})
    Enum.flat_map(tenpai_definitions, &Match.remove_match_definition(tiles, [], &1, tile_behavior))
    |> Enum.take(max_results)
    |> Enum.map(fn {hand, _calls} -> tiles -- hand end)
    |> Enum.uniq()
    |> Enum.map(fn hand ->
      state = update_player(state, seat, &%Player{ &1 | hand: hand, status: MapSet.new(["riichi"]) }) # avoid renhou
      # run before_win actions
      state = Actions.trigger_event(state, "before_win", %{seat: seat, win_source: :discard})
      # run before_scoring actions
      state = Actions.trigger_event(state, "before_scoring", %{seat: seat, win_source: :discard})
      {yaku, minipoints, _winning_tile} = Scoring.get_best_yaku_from_lists(state, score_rules["yaku_lists"], seat, [:any], :discard)
      {yaku2, _minipoints, _winning_tile} = Scoring.get_best_yaku_from_lists(state, score_rules["yaku2_lists"], seat, [:any], :discard)
      # IO.inspect({yaku, yaku2, hand})
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

  def player_prefix(state, seat) do
    [
      %{text: "Player"},
      %{text: Riichi.get_seat_wind(state.kyoku, seat, state.available_seats) |> Atom.to_string()},
      %{bold: true, text: state.players[seat].nickname}
    ]
  end

  def push_message(state, message) do
    if not state.log_loading_mode do
      for {_seat, messages_states} <- state.messages_states, messages_states != nil, {_id, messages_state} <- messages_states do
        # IO.puts("Sending to #{inspect(messages_state)} the message #{inspect(message)}")
        GenServer.cast(messages_state, {:add_message, message})
      end
    end
  end

  def push_messages(state, messages) do
    if not state.log_loading_mode do
      for {_seat, messages_states} <- state.messages_states, messages_states != nil, {_id, messages_state} <- messages_states do
        # IO.puts("Sending to #{inspect(messages_state)} the messages #{inspect(messages)}")
        GenServer.cast(messages_state, {:add_messages, messages})
      end
    end
  end

  def broadcast_state_change(state, postprocess \\ false) do
    if postprocess do
      # async calculate playable indices for current turn player
      GenServer.cast(self(), :calculate_playable_indices)
      # notify ai marking for all other players
      for seat <- state.available_seats, seat != state.turn, Marking.needs_marking?(state, seat) do
        notify_ai_marking(state, seat)
      end
      
      # async populate closest_american_hands for all players
      if state.ruleset == "american" do
        win_definition = Rules.get(state.rules_ref, "win_definition", [])
        # the am_card_free mod sets win_definition to the empty one, because it uses an alternate wincon
        # in which case we don't calculate closest hands
        if win_definition != [[]] do
          GenServer.cast(self(), :calculate_closest_american_hands)
        end
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

  def disconnect_ai(state, seat) do
    # if we're replacing an ai, shutdown the ai
    state = if is_pid(Map.get(state, seat)) do
      IO.puts("Stopping AI for #{seat}: #{inspect(Map.get(state, seat))}")
      DynamicSupervisor.terminate_child(state.ai_supervisor, Map.get(state, seat))
      Map.put(state, seat, nil)
    else state end
    state = broadcast_state_change(state)
    state
  end

  def kill_all_tasks(state) do
    for seat <- state.available_seats do
      if state.calculate_playable_indices_pids[seat] do
        Process.exit(state.calculate_playable_indices_pids[seat], :kill)
      end
    end
    if state.calculate_closest_american_hands_pid do
      Process.exit(state.calculate_closest_american_hands_pid, :kill)
    end
    if state.get_best_minefield_hand_pid do
      Process.exit(state.get_best_minefield_hand_pid, :kill)
    end
  end

  defp start_timer(state) do
    state = Map.put(state, :timer, Rules.get(state.rules_ref, "win_timer", 10))
    state = update_all_players(state, fn seat, player -> %Player{ player | ready: is_pid(Map.get(state, seat)) } end)
    
    if state.log_loading_mode do
      GenServer.cast(self(), :tick_timer)
    else
      Debounce.apply(state.timer_debouncer)
    end
    state
  end

  def handle_call({:link_player_socket, session_id, seat, spectator, nickname}, {from_pid, _}, state) do
    # make it call :delete_player if the pid goes down
    identifier = if spectator do session_id else seat end
    # initialize message state and exit monitor
    messages_state = Map.get(RiichiAdvanced.MessagesState.link_player_socket(from_pid, session_id), :messages_state, nil)
    GenServer.call(state.exit_monitor, {:new_player, from_pid, session_id})
    state = update_in(state.messages_states[identifier], &case &1 do
      nil -> %{session_id => messages_state}
      mss -> Map.put(mss, session_id, messages_state)
    end)

    if not spectator do
      # tell everyone else if it's a new player
      if Map.get(state, seat, nil) == nil do
        push_message(state, %{text: "Player %{nickname} joined as %{seat}", vars: %{nickname: nickname || "", seat: Atom.to_string(seat)}})
      end

      # initialize the player
      state = Map.update!(state, seat, &case &1 do
        nil -> [session_id]
        ids -> if session_id in ids do ids else [session_id | ids] end
      end)
      state = update_player(state, seat, &%Player{ &1 | nickname: nickname })
      IO.puts("#{inspect(from_pid)} Player #{session_id} joined as #{seat}")

      # tell them about the replay UUID, unless this is a tutorial
      if state.forced_events == nil do
        GenServer.cast(messages_state, {:add_message, [%{text: "Log ID:"}, %{bold: true, text: state.ref}]})
      end
      state = broadcast_state_change(state, false)
      {:reply, :ok, state}
    else
      {:reply, :ok, state}
    end
  end

  def handle_call(:get_room_players, _from, state) do
    reserved_seats = state.reserved_seats
    |> Enum.filter(fn {seat, _session_id} -> seat != nil and Map.get(state, seat) != nil and not is_pid(Map.get(state, seat)) end)
    |> Map.new(fn {seat, session_id} -> {seat, %RoomPlayer{
      nickname: if state.players[seat].nickname == "" do
          "player" <> String.slice(Map.get(state, seat) |> Enum.at(-1), 10, 4)
        else state.players[seat].nickname end,
      id: Map.get(state, seat) |> Enum.at(-1),
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
    state = broadcast_state_change(merge_state(state, new_state), true)
    {:reply, state, state}
  end

  # called by exit monitor
  def handle_call({:delete_player, session_id}, _from, state) do
    seat = Map.take(state, [:east, :south, :west, :north])
    |> Enum.find(fn {_seat, session_ids} -> session_id in session_ids end)
    |> case do
      nil -> nil
      {seat, _session_ids} -> seat
    end
    state = if seat in [:east, :south, :west, :north] do
      case Map.get(state, seat) do
        nil  ->
          IO.puts("Player #{seat} somehow exists, and exited")
          state
        [_id] ->
          IO.puts("Player #{player_name(state, seat)} exited")
          state = update_player(state, seat, &%Player{ &1 | nickname: nil })
          state = Map.put(state, seat, nil)
          state = put_in(state.messages_states[seat], nil)
          # tell everyone else
          push_message(state, player_prefix(state, seat) ++ [%{text: "exited"}])
          state
        [_id | ids]  ->
          state = Map.put(state, seat, ids)
          state
      end
    else state end

    state = if Enum.all?(state.messages_states, fn {_seat, messages_state} -> messages_state == nil end) do
      # all players and spectators have left, schedule a shutdown
      if map_size(state.reserved_seats) <= 1 do
        # immediately stop solo games
        IO.puts("Stopping game #{state.room_code} #{inspect(self())}")
        GenServer.cast(self(), :terminate_game)
      else
        IO.puts("Stopping game #{state.room_code} #{inspect(self())} in 60 seconds")
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

  # used by lobby to get a room state from this game
  def handle_call(:get_lobby_room, _from, state) do
    lobby_room = %LobbyRoom{
      players: Map.new(state.players, fn {seat, player} -> {seat,
          if is_list(Map.get(state, seat)) do
            %RoomPlayer{ nickname: player.nickname, seat: seat }
          else nil end
        } end),
      mods: state.mods,
      private: state.private,
      started: true
    }
    {:reply, lobby_room, state}
  end

  def handle_call({:force_event, events, blocking}, _from, state) do
    state = Map.put(state, :forced_events, events)
    state = Map.put(state, :block_events, blocking)
    notify_ai(state)
    {:reply, :ok, state}
  end

  def handle_cast({:initialize_game, log}, state) do
    # run before_start actions
    state = Actions.trigger_event(state, "before_start", %{seat: state.turn})

    state = initialize_new_round(state, log)
    {:noreply, state}
  end

  def handle_cast(:terminate_game, state) do
    kill_all_tasks(state)
    GenServer.stop(state.supervisor, :normal)
    {:noreply, state}
  end

  def handle_cast(:terminate_game_if_empty, state) do
    if Enum.all?(state.messages_states, fn {_seat, messages_state} -> messages_state == nil end) do
      # all players and spectators have left, shutdown
      IO.puts("Stopping game #{state.room_code} #{inspect(self())}")
      # DynamicSupervisor.terminate_child(RiichiAdvanced.GameSessionSupervisor, state.supervisor)
      kill_all_tasks(state)
      GenServer.stop(state.supervisor, :normal)
    else
      IO.puts("Not stopping game #{state.room_code} #{inspect(self())}")
    end
    {:noreply, state}
  end

  def handle_cast({:fill_empty_seats_with_ai, disconnected?}, state) do
    tsumogiri_bot = Rules.get(state.rules_ref, "tsumogiri_bots", Debug.debug())
    state = if not state.log_seeking_mode do
      state = for dir <- state.available_seats, Map.get(state, dir) == nil, disconnected? or not Map.has_key?(state.reserved_seats, dir), reduce: state do
        state ->
          {:ok, ai_pid} = DynamicSupervisor.start_child(state.ai_supervisor, %{
            id: RiichiAdvanced.AIPlayer,
            start: {RiichiAdvanced.AIPlayer, :start_link, [%{game_state: self(), ruleset: state.ruleset, seat: dir, player: state.players[dir], shanten_definitions: Rules.get(state.rules_ref, :shanten_definitions), tsumogiri_bot: tsumogiri_bot}]},
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

  def handle_cast({:init_player, session_id, seat}, state) do
    {seat, spectator} = cond do
      seat == "spectator" -> {:east, true}
      :east in state.available_seats  and Map.get(state, :east)  != nil and Map.get(state.reserved_seats, :east, nil) == session_id -> {:east, false}
      :south in state.available_seats and Map.get(state, :south) != nil and Map.get(state.reserved_seats, :south, nil) == session_id -> {:south, false}
      :west in state.available_seats  and Map.get(state, :west)  != nil and Map.get(state.reserved_seats, :west, nil) == session_id -> {:west, false}
      :north in state.available_seats and Map.get(state, :north) != nil and Map.get(state.reserved_seats, :north, nil) == session_id -> {:north, false}
      :east in state.available_seats  and seat == "east"  and (Map.get(state, :east)  == nil or is_pid(Map.get(state, :east)))  and Map.get(state.reserved_seats, :east,  nil) in [nil, session_id] -> {:east, false}
      :south in state.available_seats and seat == "south" and (Map.get(state, :south) == nil or is_pid(Map.get(state, :south))) and Map.get(state.reserved_seats, :south, nil) in [nil, session_id] -> {:south, false}
      :west in state.available_seats  and seat == "west"  and (Map.get(state, :west)  == nil or is_pid(Map.get(state, :west)))  and Map.get(state.reserved_seats, :west,  nil) in [nil, session_id] -> {:west, false}
      :north in state.available_seats and seat == "north" and (Map.get(state, :north) == nil or is_pid(Map.get(state, :north))) and Map.get(state.reserved_seats, :north, nil) in [nil, session_id] -> {:north, false}
      :east in state.available_seats  and (Map.get(state, :east) == nil  or is_pid(Map.get(state, :east)))  and Map.get(state.reserved_seats, :east,  nil) in [nil, session_id] -> {:east, false}
      :south in state.available_seats and (Map.get(state, :south) == nil or is_pid(Map.get(state, :south))) and Map.get(state.reserved_seats, :south, nil) in [nil, session_id] -> {:south, false}
      :west in state.available_seats  and (Map.get(state, :west) == nil  or is_pid(Map.get(state, :west)))  and Map.get(state.reserved_seats, :west,  nil) in [nil, session_id] -> {:west, false}
      :north in state.available_seats and (Map.get(state, :north) == nil or is_pid(Map.get(state, :north))) and Map.get(state.reserved_seats, :north, nil) in [nil, session_id] -> {:north, false}
      true                                          -> {:east, true}
    end
    state = if spectator do state else disconnect_ai(state, seat) end
    state = if not spectator and Map.get(state.reserved_seats, seat, nil) == nil do
      put_in(state.reserved_seats[seat], session_id)
    else state end
    # this tells the liveview client associated with session_id to call :link_player_socket with socket info
    RiichiAdvancedWeb.Endpoint.broadcast(state.ruleset <> ":" <> state.room_code, "initialize_player", %{
      "session_id" => session_id,
      "game_state" => self(),
      "state" => state,
      "seat" => seat,
      "spectator" => spectator
    })
    {:noreply, state}
  end
  
  def handle_cast({:fetch_messages, session_id}, state) do
    RiichiAdvancedWeb.Endpoint.broadcast(state.ruleset <> ":" <> state.room_code, "fetch_messages", %{"session_id" => session_id})
    {:noreply, state}
  end
  
  # log control
  def handle_cast({:load_log_control_state, log_control_state}, state) do
    # send log_control_state with the liveview client associated with session_id
    RiichiAdvancedWeb.Endpoint.broadcast(state.ruleset <> ":" <> state.room_code, "load_log_control_state", %{
      "session_id" => state.reserved_seats.east,
      "game_state" => self(),
      "log_control_state" => log_control_state
    })
    {:noreply, state}
  end

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

  def handle_cast(:pause, state) do
    state = Map.put(state, :game_active, false)
    {:noreply, state}
  end
  def handle_cast(:unpause, state) do
    state = Map.put(state, :game_active, true)
    notify_ai(state)
    {:noreply, state}
  end
  def handle_cast({:unpause, context}, state) do
    actions = state.players[context.seat].deferred_actions
    if Debug.debug_actions() do
      IO.puts("Unpausing with context #{inspect(context)}; actions are #{inspect(actions)}")
    end
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
    event = ["play_tile", Atom.to_string(seat), index]
    if not state.block_events or state.forced_events == nil or event in state.forced_events do
      tile = Enum.at(state.players[seat].hand ++ state.players[seat].draw, index)
      can_discard = Actions.can_discard(state, seat)
      playable = is_playable?(state, seat, tile)
      # if not can_discard or not playable do
      #   IO.puts("#{seat} tried to play an unplayable tile: #{inspect{tile}}")
      # end
      state = if can_discard and playable and (state.play_tile_debounce[seat] == false or state.log_loading_mode) do
        state = Actions.temp_disable_play_tile(state, seat)
        # assume we're skipping our button choices
        state = update_player(state, seat, &%Player{ &1 | buttons: [], button_choices: %{}, call_buttons: %{}, choice: nil })
        actions = [["play_tile", tile, index], ["check_discard_passed"], ["advance_turn"]]
        state = Actions.submit_actions(state, seat, "play_tile", actions)
        state = if state.forced_events != nil and event in state.forced_events do
          state
          |> Map.put(:block_events, true)
          |> Map.put(:forced_events, [])
          |> Map.put(:last_event, event)
          |> broadcast_state_change()
        else
          if Debug.debug_tutorial() do
            IO.inspect("Allowed #{inspect(event)}; waiting for #{inspect(state.forced_events)}")
          end
          state
        end
        state
      else state end
      {:noreply, state}
    else
      if Debug.debug_tutorial() do
        IO.inspect("Blocked #{inspect(event)}; waiting for #{inspect(state.forced_events)}")
      end
      {:noreply, state}
    end
  end

  def handle_cast({:press_button, seat, button_name}, state) do
    event = ["press_button", Atom.to_string(seat), button_name]
    if not state.block_events or state.forced_events == nil or event in state.forced_events do
      state = Buttons.press_button(state, seat, button_name)
      state = if state.forced_events != nil and event in state.forced_events do
        state
        |> Map.put(:block_events, true)
        |> Map.put(:forced_events, [])
        |> Map.put(:last_event, event)
        |> broadcast_state_change()
      else
        if Debug.debug_tutorial() do
          IO.inspect("Allowed #{inspect(event)}; waiting for #{inspect(state.forced_events)}")
        end
        state
      end
      {:noreply, state}
    else
      if Debug.debug_tutorial() do
        IO.inspect("Blocked #{inspect(event)}; waiting for #{inspect(state.forced_events)}")
      end
      {:noreply, state}
    end
  end

  def handle_cast({:press_call_button, seat, call_choice, called_tile}, state) do
    event = ["press_call_button", Atom.to_string(seat), Enum.map(call_choice, &Utils.tile_to_string/1), Utils.tile_to_string(called_tile)]
    if not state.block_events or state.forced_events == nil or event in state.forced_events do
      state = Buttons.press_call_button(state, seat, call_choice, called_tile)
      state = if state.forced_events != nil and event in state.forced_events do
        state
        |> Map.put(:block_events, true)
        |> Map.put(:forced_events, [])
        |> Map.put(:last_event, event)
        |> broadcast_state_change()
      else
        if Debug.debug_tutorial() do
          IO.inspect("Allowed #{inspect(event)}; waiting for #{inspect(state.forced_events)}")
        end
        state
      end
      {:noreply, state}
    else
      if Debug.debug_tutorial() do
        IO.inspect("Blocked #{inspect(event)}; waiting for #{inspect(state.forced_events)}")
      end
      {:noreply, state}
    end
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
    auto_buttons = Rules.get(state.rules_ref, "auto_buttons", %{})
    if Map.has_key?(auto_buttons, auto_button_name) do
      state = Actions.run_actions(state, auto_buttons[auto_button_name]["actions"], %{seat: seat, auto: true})
      state = broadcast_state_change(state)
      {:noreply, state}
    else
      {:noreply, state}
    end
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
    event = ["press_call_button", Atom.to_string(seat), "cancel"]
    if state.forced_events == nil or event in state.forced_events do
      # go back to button clicking phase
      state = update_player(state, seat, fn player -> %Player{ player | buttons: Buttons.to_buttons(state, player.button_choices), call_buttons: %{}, deferred_actions: [], deferred_context: %{}, choice: nil } end)

      # tutorial stuff
      state = if state.forced_events != nil and event in state.forced_events do
        state
        |> Map.put(:block_events, true)
        |> Map.put(:forced_events, [])
        |> Map.put(:last_event, event)
      else
        if Debug.debug_tutorial() do
          IO.inspect("Allowed #{inspect(event)}; waiting for #{inspect(state.forced_events)}")
        end
        state
      end

      notify_ai(state)
      state = broadcast_state_change(state)
      {:noreply, state}
    else
      if Debug.debug_tutorial() do
        IO.inspect("Blocked #{inspect(event)}; waiting for #{inspect(state.forced_events)}")
      end
      {:noreply, state}
    end
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
              open_riichis: get_open_riichi_hands(state),
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

  def handle_cast(:notify_ai_new_round, state) do
    if not state.log_loading_mode do
      if state.game_active do
        Enum.each(state.available_seats, fn seat ->
          if is_pid(Map.get(state, seat)) do
            send(Map.get(state, seat), :initialize)
          end
        end)
      else
        :timer.apply_after(1000, GenServer, :cast, [self(), :notify_ai_new_round])
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
            scryed_tiles: get_scryed_tiles(state, seat),
            doras: get_doras(state),
            marked_objects: state.marking[seat],
            closest_american_hands: state.players[seat].cache.closest_american_hands,
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
            open_riichis: get_open_riichi_hands(state),
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
        # IO.inspect(Map.new(state.players, fn {seat, player} -> {seat, player.ready} end))
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
    if Rules.has_key?(state.rules_ref, "show_waits") do
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

  def handle_cast({:mark_tile, marking_player, seat, index, source}, state) do
    state = Marking.mark_tile(state, marking_player, seat, index, source)
    state = Marking.adjudicate_marking(state)
    if Marking.needs_marking?(state, marking_player) do
      notify_ai_marking(state, marking_player)
    end
    state = broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast({:unmark_tile, marking_player, seat, index, source}, state) do
    state = Marking.unmark_tile(state, marking_player, seat, index, source)
    notify_ai_marking(state, marking_player)
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
    # run cancel actions
    state = case Marking.get_mark_infos(state.marking[seat], :cancel_actions) do
      [{:cancel_actions, cancel_actions}] -> 
        if Debug.debug_actions() do
          IO.puts("Running cancel actions for #{seat}: #{inspect(cancel_actions)}")
        end
          IO.puts("Running cancel actions for #{seat}: #{inspect(cancel_actions)}")
        Actions.run_actions(state, cancel_actions, %{seat: seat})
      _ -> state
    end

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
    buttons = Rules.get(state.rules_ref, "buttons", %{})
    if Map.has_key?(buttons, button_name) do
      actions = buttons[button_name]["actions"]
      state = Actions.submit_actions(state, seat, button_name, actions, nil, nil, nil, yakus)
      state = broadcast_state_change(state)
      {:noreply, state}
    else
      {:noreply, state}
    end
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
      closed_win_definition = Rules.get(state.rules_ref, "win_definition", [])
      open_win_definition = Rules.get(state.rules_ref, "open_win_definition", [])
      for seat <- state.available_seats do
        win_definition = if Enum.empty?(state.players[seat].calls) do closed_win_definition else open_win_definition end
        closest_american_hands = American.compute_closest_american_hands(state, seat, win_definition, 5)
        GenServer.cast(self, {:set_closest_american_hands, seat, closest_american_hands})
      end
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
    if Marking.needs_marking?(state, seat) do
      notify_ai_marking(state, seat)
    end
    {:noreply, state}
  end

  def handle_cast({:set_closest_american_hands, seat, closest_american_hands}, state) do
    state = state
    |> update_player(seat, &%Player{ &1 | cache: %PlayerCache{ &1.cache | closest_american_hands: closest_american_hands } })
    |> Map.put(:calculate_closest_american_hands_pid, nil)

    # some conditions (namely "is_tenpai_american") might have changed based on closest american hands, so recalculate buttons
    # of course, only calculate this if the match has started
    state = if Enum.all?(state.players, fn {_seat, player} -> "match_start" not in player.status end) do
      Buttons.recalculate_buttons(state)
    else state end
    # note that this races the AI: the AI might act before closest_american_hands is calculated, so they may miss buttons that should be there
    # TODO maybe fix this by pausing the game at the start of this particular async calculation, and unpausing after
    state = broadcast_state_change(state, false)
    {:noreply, state}
  end

  # for minefield ai
  def handle_cast({:get_best_minefield_hand, seat, tenpai_definitions}, state) do
    state = if state.get_best_minefield_hand_pid == nil do
      self = self()
      {:ok, pid} = Task.start(fn ->
        tiles = state.players[seat].hand

        # add a fake :any tile to toimen's discards (resulting state is thrown away once this thread completes)
        toimen = Utils.get_seat(seat, :toimen)
        state = state
        |> update_player(toimen, &%Player{ &1 | discards: &1.discards ++ [:any] })
        |> Actions.register_discard(toimen, :any, true, true)

        # look for certain hands
        {_yakuman, _han, _minipoints, hand} = Enum.max([
          # tsuuiisou
          get_best_minefield_hand(state, seat, tenpai_definitions, Enum.filter(tiles, &Riichi.is_jihai?/1), 5),
          # chinitsu
          get_best_minefield_hand(state, seat, tenpai_definitions, Enum.filter(tiles, &Riichi.is_manzu?/1), 10),
          get_best_minefield_hand(state, seat, tenpai_definitions, Enum.filter(tiles, &Riichi.is_pinzu?/1), 10),
          get_best_minefield_hand(state, seat, tenpai_definitions, Enum.filter(tiles, &Riichi.is_souzu?/1), 10),
          # honitsu
          get_best_minefield_hand(state, seat, tenpai_definitions, Enum.filter(tiles, &Riichi.is_manzu?(&1) or Riichi.is_jihai?(&1)), 10),
          get_best_minefield_hand(state, seat, tenpai_definitions, Enum.filter(tiles, &Riichi.is_pinzu?(&1) or Riichi.is_jihai?(&1)), 10),
          get_best_minefield_hand(state, seat, tenpai_definitions, Enum.filter(tiles, &Riichi.is_pinzu?(&1) or Riichi.is_jihai?(&1)), 10),
          # tanyao
          get_best_minefield_hand(state, seat, tenpai_definitions, Enum.filter(tiles, &Riichi.is_tanyaohai?/1), 10),
          # chanta
          get_best_minefield_hand(state, seat, tenpai_definitions, Enum.filter(tiles, &Riichi.is_yaochuuhai?/1), 5),
          # any hand
          get_best_minefield_hand(state, seat, tenpai_definitions, tiles, 10),
        ])
        # IO.inspect({yakuman, han, minipoints, hand})
        GenServer.cast(self, {:set_best_minefield_hand, seat, tiles, hand})
      end)
      Map.put(state, :get_best_minefield_hand_pid, pid)
    else state end
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

  def handle_cast({:respawn_on, node_sname}, state) do
    # spawn a game state with an init_action that pulls state from this pid
    sanitized_state = sanitize_state(state)
    init_actions = [["put_state", sanitized_state]]
    args = [room_code: state.room_code, ruleset: state.ruleset, mods: state.mods, config: state.config, private: state.private, reserved_seats: state.reserved_seats, init_actions: init_actions, name: Utils.via_registry("game", state.ruleset, state.room_code)]
    game_spec = Supervisor.child_spec(%{
      id: {RiichiAdvanced.GameSupervisor, state.ruleset, state.room_code},
      start: {RiichiAdvanced.GameSupervisor, :start_link, [args]},
    }, restart: :temporary)
    
    :rpc.cast(node_sname, DynamicSupervisor, :start_child, [RiichiAdvanced.GameSessionSupervisor, game_spec])
    # kill this game instance
    DynamicSupervisor.terminate_child(RiichiAdvanced.GameSessionSupervisor, state.supervisor)
    # this won't immediately make connections shift over,
    # but the idea is to terminate the server after respawning everything
    {:noreply, state}
  end

  def sanitize_state(state) do
    Map.drop(state, [
      :ruleset,
      :room_code,
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
      :rules_ref,
    ])
    |> Map.merge(%{
      game_active: true,
      visible_screen: nil,
      error: nil,
      timer: 0,
    })
  end

  def merge_state(state, new_state) do
    Map.merge(state, sanitize_state(new_state))
  end
end
