defmodule Player do
  defstruct [
    # persistent
    score: 0,
    nickname: nil,
    # working
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
    call_name: "",
    tile_mappings: %{},
    tile_aliases: %{},
    tile_ordering: %{:"1m"=>:"2m", :"2m"=>:"3m", :"3m"=>:"4m", :"4m"=>:"5m", :"5m"=>:"6m", :"6m"=>:"7m", :"7m"=>:"8m", :"8m"=>:"9m",
                     :"1p"=>:"2p", :"2p"=>:"3p", :"3p"=>:"4p", :"4p"=>:"5p", :"5p"=>:"6p", :"6p"=>:"7p", :"7p"=>:"8p", :"8p"=>:"9p",
                     :"1s"=>:"2s", :"2s"=>:"3s", :"3s"=>:"4s", :"4s"=>:"5s", :"5s"=>:"6s", :"6s"=>:"7s", :"7s"=>:"8s", :"8s"=>:"9s"},
    tile_ordering_r: %{:"2m"=>:"1m", :"3m"=>:"2m", :"4m"=>:"3m", :"5m"=>:"4m", :"6m"=>:"5m", :"7m"=>:"6m", :"8m"=>:"7m", :"9m"=>:"8m",
                       :"2p"=>:"1p", :"3p"=>:"2p", :"4p"=>:"3p", :"5p"=>:"4p", :"6p"=>:"5p", :"7p"=>:"6p", :"8p"=>:"7p", :"9p"=>:"8p",
                       :"2s"=>:"1s", :"3s"=>:"2s", :"4s"=>:"3s", :"5s"=>:"4s", :"6s"=>:"5s", :"7s"=>:"6s", :"8s"=>:"7s", :"9s"=>:"8s"},
    choice: nil,
    chosen_actions: nil,
    deferred_actions: [],
    deferred_context: %{},
    big_text: "",
    status: [],
    counters: %{},
    riichi_stick: false,
    riichi_discard_indices: nil,
    hand_revealed: false,
    num_scryed_tiles: 0,
    declared_yaku: nil,
    last_discard: nil, # for animation purposes only
    winning_hand: nil,
    ready: false
  ]
  use Accessible
end

defmodule Game do
  defstruct [
    # params
    ruleset: nil,
    session_id: nil,
    ruleset_json: nil,
    mods: nil,
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

    # control variables
    game_active: false,
    visible_screen: nil,
    error: nil,
    round_result: nil,
    winners: %{},
    winner_index: 0,
    delta_scores: nil,
    delta_scores_reason: nil,
    next_dealer: nil,
    timer: 0,
    actions_cv: 0, # condition variable

    # persistent game state (not reset on new round)
    players: Map.new([:east, :south, :west, :north], fn seat -> {seat, %Player{}} end),
    rules: %{},
    interruptible_actions: %{},
    all_tiles: [],
    wall: [],
    kyoku: 0,
    honba: 0,
    pot: 0,
    tags: %{},
    log_state: %{},

    # working game state (reset on new round)
    # (these are all reset manually, so if you add a new one go to initialize_new_round to reset it)
    turn: :east,
    wall_index: 0,
    haipai: [],
    actions: [],
    dead_wall: [],
    reversed_turn_order: false,
    reserved_tiles: [],
    revealed_tiles: [],
    max_revealed_tiles: 0,
    drawn_reserved_tiles: [],
    marking: Map.new([:east, :south, :west, :north], fn seat -> {seat, %{}} end),
  ]
  use Accessible
end

defmodule RiichiAdvanced.GameState do
  alias RiichiAdvanced.GameState.Actions, as: Actions
  alias RiichiAdvanced.GameState.Buttons, as: Buttons
  alias RiichiAdvanced.GameState.Conditions, as: Conditions
  alias RiichiAdvanced.GameState.Debug, as: Debug
  alias RiichiAdvanced.GameState.Saki, as: Saki
  alias RiichiAdvanced.GameState.Scoring, as: Scoring
  alias RiichiAdvanced.GameState.Marking, as: Marking
  alias RiichiAdvanced.GameState.Log, as: Log
  use GenServer

  def start_link(init_data) do
    IO.puts("Game supervisor PID is #{inspect(self())}")
    GenServer.start_link(
      __MODULE__,
      %{
        session_id: Keyword.get(init_data, :session_id),
        ruleset: Keyword.get(init_data, :ruleset),
        mods: Keyword.get(init_data, :mods, [])
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
    IO.puts("Game state PID is #{inspect(self())}")

    # lookup pids of the other processes we'll be using
    [{debouncers, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("debouncers", state.ruleset, state.session_id))
    [{supervisor, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("game", state.ruleset, state.session_id))
    [{mutex, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("mutex", state.ruleset, state.session_id))
    [{ai_supervisor, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("ai_supervisor", state.ruleset, state.session_id))
    [{exit_monitor, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("exit_monitor", state.ruleset, state.session_id))
    [{smt_solver, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("smt_solver", state.ruleset, state.session_id))

    # initilize all debouncers
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
    ruleset_json = if state.ruleset == "custom" do
      RiichiAdvanced.ETSCache.get(state.session_id, ["{}"], :cache_rulesets) |> Enum.at(0)
    else
      case File.read(Application.app_dir(:riichi_advanced, "/priv/static/rulesets/#{state.ruleset <> ".json"}")) do
        {:ok, ruleset_json} -> ruleset_json
        {:error, _err}      -> nil
      end
    end

    # strip comments
    orig_ruleset_json = ruleset_json
    ruleset_json = Regex.replace(~r{ //.*|/\*[.\n]*?\*/}, ruleset_json, "")

    # apply mods
    mods = Map.get(state, :mods, [])
    ruleset_json = RiichiAdvanced.ModLoader.apply_mods(ruleset_json, mods)
    if not Enum.empty?(mods) do
      # cache mods
      RiichiAdvanced.ETSCache.put({state.ruleset, state.session_id}, mods, :cache_mods)
    end

    # put params, debouncers, and process ids into state
    state = Map.merge(state, %Game{
      ruleset: state.ruleset,
      session_id: state.session_id,
      mods: state.mods,
      ruleset_json: if Enum.empty?(mods) do orig_ruleset_json else ruleset_json end,
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

    # decode the rules json, removing comments first
    {state, rules} = try do
      case Jason.decode(ruleset_json) do
        {:ok, rules} -> {state, rules}
        {:error, err} ->
          IO.inspect(ruleset_json)
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
    state = Log.init_log(state)

    # initialize interruptible actions
    interruptible_actions = Map.get(rules, "interrupt_levels", %{})
    |> Map.merge(Map.new(Map.get(rules, "interruptible_actions", []), fn action -> {action, 100} end))
    state = Map.put(state, :interruptible_actions, interruptible_actions)

    initial_score = if Map.has_key?(rules, "initial_score") do rules["initial_score"] else 0 end

    state = update_players(state, &%Player{ &1 | score: initial_score })
    state = initialize_new_round(state)

    # Scoring.run_yaku_tests(state)

    {:ok, state}
  end

  def update_player(state, seat, fun), do: Map.update!(state, :players, &Map.update!(&1, seat, fun))
  def update_players(state, fun), do: Map.update!(state, :players, &Map.new(&1, fn {seat, player} -> {seat, fun.(player)} end))
  def update_players_by_seat(state, fun), do: Map.update!(state, :players, &Map.new(&1, fn {seat, player} -> {seat, fun.(seat, player)} end))
  # TODO replace calls to this last one with either update_players or update_players_by_seat
  def update_all_players(state, fun), do: Map.update!(state, :players, &Map.new(&1, fn {seat, player} -> {seat, fun.(seat, player)} end))
  
  def get_last_action(state), do: Enum.at(state.actions, 0)
  def get_last_call_action(state), do: state.actions |> Enum.drop_while(fn action -> action.action != :call end) |> Enum.at(0)
  def get_last_discard_action(state), do: state.actions |> Enum.drop_while(fn action -> action.action != :discard end) |> Enum.at(0)
  def update_action(state, seat, action, opts \\ %{}), do: Map.update!(state, :actions, &[opts |> Map.put(:seat, seat) |> Map.put(:action, action) | &1])

  def show_error(state, message) do
    state = Map.update!(state, :error, fn err -> if err == nil do message else err <> "\n\n" <> message end end)
    state = broadcast_state_change(state)
    state
  end

  def initialize_new_round(state) do
    rules = state.rules

    all_tiles = Enum.map(Map.get(rules, "wall", []), &Utils.to_tile(&1))
    wall = all_tiles
    
    # check that there are no nil tiles
    state = wall
    |> Enum.zip(Map.get(rules, "wall", []))
    |> Enum.filter(fn {result, _orig} -> result == nil end)
    |> Enum.reduce(state, fn {_result, orig}, state -> show_error(state, "#{inspect(orig)} is not a valid wall tile!") end)

    wall = Enum.shuffle(wall)
    wall = if Debug.debug() do Debug.set_wall(wall) else wall end

    starting_tiles = if Map.has_key?(rules, "starting_tiles") do rules["starting_tiles"] else 0 end
    hands = if starting_tiles > 0 do
      %{:east  => Enum.slice(wall, 0..(starting_tiles-1)),
        :south => Enum.slice(wall, starting_tiles..(starting_tiles*2-1)),
        :west  => Enum.slice(wall, (starting_tiles*2)..(starting_tiles*3-1)),
        :north => Enum.slice(wall, (starting_tiles*3)..(starting_tiles*4-1))}
    else Map.new([:east, :south, :west, :north], &{&1, []}) end
    hands = if Debug.debug() do Debug.set_starting_hand(wall) else hands end

    # reserve some tiles in the dead wall
    reserved_tile_names = Map.get(rules, "reserved_tiles", [])
    dead_wall_length = Map.get(rules, "initial_dead_wall_length", 0)
    state = if length(reserved_tile_names) > 0 && length(reserved_tile_names) <= dead_wall_length do
      {wall, dead_wall} = Enum.split(wall, -dead_wall_length)
      reserved_tiles = reserved_tile_names
      revealed_tiles = if Map.has_key?(rules, "revealed_tiles") do rules["revealed_tiles"] else [] end
      max_revealed_tiles = if Map.has_key?(rules, "max_revealed_tiles") do rules["max_revealed_tiles"] else 0 end
      state 
      |> Map.put(:all_tiles, all_tiles)
      |> Map.put(:wall, wall)
      |> Map.put(:haipai, hands)
      |> Map.put(:dead_wall, dead_wall)
      |> Map.put(:reserved_tiles, reserved_tiles)
      |> Map.put(:revealed_tiles, revealed_tiles)
      |> Map.put(:max_revealed_tiles, max_revealed_tiles)
      |> Map.put(:drawn_reserved_tiles, [])
    else
      state = state
      |> Map.put(:all_tiles, all_tiles)
      |> Map.put(:wall, wall)
      |> Map.put(:dead_wall, [])
      |> Map.put(:reserved_tiles, [])
      |> Map.put(:revealed_tiles, [])
      |> Map.put(:max_revealed_tiles, 0)
      |> Map.put(:drawn_reserved_tiles, [])
      if length(reserved_tile_names) > dead_wall_length do
        show_error(state, "length of \"reserved_tiles\" should not exceed \"initial_dead_wall_length\"!")
      else state end
    end
    state = state
    |> Map.put(:round_result, nil)
    |> Map.put(:winners, %{})
    |> Map.put(:winner_index, 0)
    |> Map.put(:delta_scores, nil)
    |> Map.put(:delta_scores_reason, nil)
    |> Map.put(:next_dealer, nil)

    # initialize auto buttons
    initial_auto_buttons = for {name, auto_button} <- Map.get(rules, "auto_buttons", []) do
      {name, auto_button["enabled_at_start"]}
    end

    # statuses to keep between rounds
    persistent_statuses = if Map.has_key?(rules, "persistent_statuses") do rules["persistent_statuses"] else [] end
    persistent_counters = if Map.has_key?(rules, "persistent_counters") do rules["persistent_counters"] else [] end

    state = state
     |> Map.put(:wall_index, starting_tiles*4)
     |> update_all_players(&%Player{
          score: &2.score,
          nickname: &2.nickname,
          hand: hands[&1],
          auto_buttons: initial_auto_buttons,
          status: Enum.filter(&2.status, fn status -> status in persistent_statuses end),
          counters: Enum.filter(&2.counters, fn {counter, _amt} -> counter in persistent_counters end) |> Map.new()
        })
     |> Map.put(:actions, [])
     |> Map.put(:reversed_turn_order, false)
     |> Map.put(:game_active, true)
     |> Map.put(:turn, nil) # so that change_turn detects a turn change
    
    state = Marking.initialize_marking(state)

    # initialize saki if needed
    state = if state.rules["enable_saki_cards"] do Saki.initialize_saki(state) else state end
    
    # start the game
    state = Actions.change_turn(state, Riichi.get_east_player_seat(state.kyoku))

    # run after_start actions
    state = if Map.has_key?(state.rules, "after_start") do
      Actions.run_actions(state, state.rules["after_start"]["actions"], %{seat: state.turn})
    else state end

    state = Buttons.recalculate_buttons(state)

    notify_ai(state)

    state
  end

  def win(state, seat, winning_tile, win_source) do
    state = Map.put(state, :round_result, :win)

    # run before_win actions
    state = if Map.has_key?(state.rules, "before_win") do
      Actions.run_actions(state, state.rules["before_win"]["actions"], %{seat: seat, winning_tile: winning_tile, win_source: win_source})
    else state end

    # reset animation
    state = update_all_players(state, fn _seat, player -> %Player{ player | last_discard: nil } end)

    state = Map.put(state, :game_active, false)
    state = Map.put(state, :timer, 10)
    state = Map.put(state, :visible_screen, :winner)
    state = update_all_players(state, fn seat, player -> %Player{ player | ready: is_pid(Map.get(state, seat)) } end)
    Debounce.apply(state.timer_debouncer)

    call_tiles = Enum.flat_map(state.players[seat].calls, &Riichi.call_to_tiles/1)

    # add winning hand to the winner player (for yaku purposes)
    winning_hand = state.players[seat].hand ++ call_tiles ++ if winning_tile != nil do [winning_tile] else [] end
    state = update_player(state, seat, fn player -> %Player{ player | winning_hand: winning_hand } end)

    # add winning_tile_text to the state so yaku conditions can refer to the winner
    winning_tile_text = if Map.has_key?(state.rules, "score_calculation") do
      case win_source do
        :draw -> Map.get(state.rules["score_calculation"], "win_by_draw_name", "")
        :discard -> Map.get(state.rules["score_calculation"], "win_by_discard_name", "")
        :call -> Map.get(state.rules["score_calculation"], "win_by_discard_name", "")
      end
    else "" end
    winner = %{
      seat: seat,
      player: state.players[seat],
      winning_tile: winning_tile,
      winning_tile_text: winning_tile_text, # for display use only
      win_source: win_source,
      point_name: Map.get(state.rules, "point_name", ""),
      limit_point_name: Map.get(state.rules, "limit_point_name", ""),
      minipoint_name: Map.get(state.rules, "minipoint_name", ""),
    }
    state = Map.update!(state, :winners, &Map.put(&1, seat, winner))

    state = if Map.has_key?(state.rules, "score_calculation") do
        if Map.has_key?(state.rules["score_calculation"], "method") do
          state
        else
          show_error(state, "\"score_calculation\" object lacks \"method\" key!")
        end
      else
        show_error(state, "\"score_calculation\" key is missing from rules!")
      end
    scoring_table = state.rules["score_calculation"]
    # deal with jokers
    joker_assignments = if Enum.empty?(state.players[seat].tile_mappings) do [%{}] else
      smt_hand = state.players[seat].hand ++ if winning_tile != nil do [winning_tile] else [] end
      RiichiAdvanced.SMT.match_hand_smt_v2(state.smt_solver, smt_hand, state.players[seat].calls, state.all_tiles, translate_match_definitions(state, ["win"]), state.players[seat].tile_ordering, state.players[seat].tile_mappings)
    end
    IO.puts("Joker assignments: #{inspect(joker_assignments)}")
    joker_assignments = if Enum.empty?(joker_assignments) do [%{}] else joker_assignments end
    {state, new_winning_tile} = case scoring_table["method"] do
      "riichi" ->
        # find the maximum yaku obtainable across all joker assignments
        {joker_assignment, yaku, yakuman, minipoints, score, points, yakuman_mult, score_name, new_winning_tile} = for joker_assignment <- joker_assignments do
          # temporarily replace winner's hand with joker assignment to determine yaku
          {state, assigned_winning_tile} = Scoring.apply_joker_assignment(state, seat, joker_assignment, winning_tile)
          # in saki you can win with 14 tiles all in hand (no draw)
          # this necessitates choosing a winning tile out of the 14, which is what this does
          {new_winning_tile, {minipoints, yaku}} = Scoring.get_best_yaku_and_winning_tile(state, state.rules["yaku"] ++ state.rules["extra_yaku"], seat, [assigned_winning_tile], win_source)
          yaku = if Map.has_key?(state.rules, "meta_yaku") do
            Scoring.get_best_yaku(state, state.rules["meta_yaku"], seat, [assigned_winning_tile], win_source, yaku)
          else yaku end
          yakuman = Scoring.get_best_yaku(state, state.rules["yakuman"], seat, [assigned_winning_tile], win_source)
          is_dealer = Riichi.get_east_player_seat(state.kyoku) == winner.seat

          # handle ryuumonbuchi touka's scoring quirk
          score_as_dealer = "score_as_dealer" in state.players[winner.seat].status
          if score_as_dealer do
            push_message(state, [%{text: "Player #{winner.seat} #{state.players[winner.seat].nickname} is treated as a dealer for scoring purposes (Ryuumonbuchi Touka)"}])
          end
          is_dealer = is_dealer || score_as_dealer
          
          {score, points, yakuman_mult} = Scoring.score_yaku(state, seat, yaku, yakuman, is_dealer, win_source == :draw, minipoints)
          IO.puts("won by #{win_source}; hand: #{inspect(state.players[seat].winning_hand)}, yaku: #{inspect(yaku)}")
          han = Integer.to_string(points)
          fu = Integer.to_string(minipoints)
          score_name = if yakuman_mult > 0 do
            scoring_table["yakuman_limit_hand_name"]
          else
            case Map.get(scoring_table["limit_hand_names"], han, scoring_table["limit_hand_names"]["max"]) do
              score_name when is_binary(score_name) -> score_name
              score_name_table                      -> Map.get(score_name_table, fu, score_name_table["max"])
            end
          end
          {joker_assignment, yaku, yakuman, minipoints, score, points, yakuman_mult, score_name, new_winning_tile}
        end |> Enum.sort_by(fn {_, _, _, _, score, _, _, _, _} -> score end) |> Enum.at(-1)

        # IO.inspect({joker_assignment, phan_yaku, mun_yaku, score, phan, mun})

        # sort jokers into the hand for hand display
        orig_hand = state.players[seat].hand
        joker_hand = Utils.sort_tiles(orig_hand, joker_assignment)
        state = update_player(state, seat, fn player -> %Player{ player | hand: joker_hand } end)
        winner = Map.merge(winner, %{player: state.players[seat]})
        # restore original hand
        state = update_player(state, seat, fn player -> %Player{ player | hand: orig_hand } end)

        payer = case win_source do
          :draw    -> nil
          :discard -> get_last_discard_action(state).seat
          :call    -> get_last_call_action(state).seat
        end
        pao_seat = cond do
          "pao" in state.players[:east].status -> :east
          "pao" in state.players[:south].status -> :south
          "pao" in state.players[:west].status -> :west
          "pao" in state.players[:north].status -> :north
          true -> nil
        end
        winner = Map.merge(winner, %{
          yaku: if yakuman_mult > 0 do [] else yaku end,
          yakuman: yakuman,
          points: if yakuman_mult > 0 do yakuman_mult else points end,
          yakuman_mult: yakuman_mult,
          score: score,
          score_name: score_name,
          point_name: if yakuman_mult > 0 do winner.limit_point_name else winner.point_name end,
          minipoints: minipoints,
          payer: payer,
          pao_seat: pao_seat,
          winning_tile: new_winning_tile
        })
        state = Map.update!(state, :winners, &Map.put(&1, seat, winner))

        {state, new_winning_tile}
      "hk" ->
        # find the maximum yaku obtainable across all joker assignments
        is_dealer = Riichi.get_east_player_seat(state.kyoku) == winner.seat
        {joker_assignment, yaku, score, fan} = for joker_assignment <- joker_assignments do
          # replace 5z with 0z
          joker_assignment = Map.new(joker_assignment, fn {ix, tile} -> if tile == :"5z" do {ix, :"0z"} else {ix, tile} end end)

          # temporarily replace winner's hand with joker assignment to determine yaku
          {state, assigned_winning_tile} = Scoring.apply_joker_assignment(state, seat, joker_assignment, winning_tile)
          yaku = Scoring.get_best_yaku(state, state.rules["yaku"], seat, [assigned_winning_tile], win_source)
          yaku = if Map.has_key?(state.rules, "meta_yaku") do
            Scoring.get_best_yaku(state, state.rules["meta_yaku"], seat, [assigned_winning_tile], win_source, yaku)
          else yaku end
          {score, fan, _} = Scoring.score_yaku(state, seat, yaku, [], is_dealer, win_source == :draw)

          {joker_assignment, yaku, score, fan}
        end |> Enum.sort_by(fn {_, _, score, _} -> score end) |> Enum.at(-1)

        # sort jokers into the hand for hand display
        orig_hand = state.players[seat].hand
        joker_hand = Utils.sort_tiles(orig_hand, joker_assignment)
        state = update_player(state, seat, fn player -> %Player{ player | hand: joker_hand } end)
        winner = Map.merge(winner, %{player: state.players[seat]})
        # restore original hand
        state = update_player(state, seat, fn player -> %Player{ player | hand: orig_hand } end)

        payer = case win_source do
          :draw    -> nil
          :discard -> get_last_discard_action(state).seat
          :call    -> get_last_call_action(state).seat
        end
        winner = Map.merge(winner, %{
          yaku: yaku,
          yakuman: [],
          points: fan,
          score: score,
          payer: payer
        })
        state = Map.update!(state, :winners, &Map.put(&1, seat, winner))
        {state, winning_tile}
      "sichuan" -> # TODO this is same as hk
        # find the maximum yaku obtainable across all joker assignments
        is_dealer = Riichi.get_east_player_seat(state.kyoku) == winner.seat
        opponents = Enum.reject([:east, :south, :west, :north], fn dir -> Map.has_key?(state.winners, dir) || dir == winner.seat end)
        {joker_assignment, yaku, score, fan} = for joker_assignment <- joker_assignments do
          # replace 5z with 0z
          joker_assignment = Map.new(joker_assignment, fn {ix, tile} -> if tile == :"5z" do {ix, :"0z"} else {ix, tile} end end)

          # temporarily replace winner's hand with joker assignment to determine yaku
          {state, assigned_winning_tile} = Scoring.apply_joker_assignment(state, seat, joker_assignment, winning_tile)
          yaku = Scoring.get_best_yaku(state, state.rules["yaku"], seat, [assigned_winning_tile], win_source)
          yaku = if Map.has_key?(state.rules, "meta_yaku") do
            Scoring.get_best_yaku(state, state.rules["meta_yaku"], seat, [assigned_winning_tile], win_source, yaku)
          else yaku end
          {score, fan, _} = Scoring.score_yaku(state, seat, yaku, [], is_dealer, win_source == :draw, 0, length(opponents))

          {joker_assignment, yaku, score, fan}
        end |> Enum.sort_by(fn {_, _, score, _} -> score end) |> Enum.at(-1)

        # sort jokers into the hand for hand display
        orig_hand = state.players[seat].hand
        joker_hand = Utils.sort_tiles(orig_hand, joker_assignment)
        IO.inspect(joker_hand, label: "joker_hand")
        state = update_player(state, seat, fn player -> %Player{ player | hand: joker_hand } end)
        winner = Map.merge(winner, %{player: state.players[seat]})
        # restore original hand
        state = update_player(state, seat, fn player -> %Player{ player | hand: orig_hand } end)

        payer = case win_source do
          :draw    -> nil
          :discard -> get_last_discard_action(state).seat
          :call    -> get_last_call_action(state).seat
        end
        winner = Map.merge(winner, %{
          yaku: yaku,
          yakuman: [],
          points: fan,
          score: score,
          payer: payer,
          opponents: opponents
        })
        state = Map.update!(state, :winners, &Map.put(&1, seat, winner))
        {state, winning_tile}
      "vietnamese" ->
        # find the maximum yaku obtainable across all joker assignments
        {joker_assignment, phan_yaku, mun_yaku, score, phan, mun} = for joker_assignment <- joker_assignments do
          # replace 5z with 0z
          joker_assignment = Map.new(joker_assignment, fn {ix, tile} -> if tile == :"5z" do {ix, :"0z"} else {ix, tile} end end)

          # temporarily replace winner's hand with joker assignment to determine yaku
          {state, assigned_winning_tile} = Scoring.apply_joker_assignment(state, seat, joker_assignment, winning_tile)
          phan_yaku = Scoring.get_best_yaku(state, state.rules["yaku"], seat, [assigned_winning_tile], win_source)
          mun_yaku = Scoring.get_best_yaku(state, state.rules["yakuman"], seat, [assigned_winning_tile], win_source)
          phan_yaku = if Map.has_key?(state.rules, "meta_yaku") do
            Scoring.get_best_yaku(state, state.rules["meta_yaku"], seat, [assigned_winning_tile], win_source, mun_yaku ++ phan_yaku)
          else phan_yaku end -- mun_yaku
          is_dealer = Riichi.get_east_player_seat(state.kyoku) == winner.seat
          {score, phan, mun} = Scoring.score_yaku(state, seat, phan_yaku, mun_yaku, is_dealer, win_source == :draw)

          {joker_assignment, phan_yaku, mun_yaku, score, phan, mun}
        end |> Enum.sort_by(fn {_, _, _, score, _, _} -> score end) |> Enum.at(-1)

        # IO.inspect({joker_assignment, phan_yaku, mun_yaku, score, phan, mun})

        # sort jokers into the hand for hand display
        orig_hand = state.players[seat].hand
        joker_hand = Utils.sort_tiles(orig_hand, joker_assignment)
        state = update_player(state, seat, fn player -> %Player{ player | hand: joker_hand } end)
        winner = Map.merge(winner, %{player: state.players[seat]})
        # restore original hand
        state = update_player(state, seat, fn player -> %Player{ player | hand: orig_hand } end)

        payer = case win_source do
          :draw    -> nil
          :discard -> get_last_discard_action(state).seat
          :call    -> get_last_call_action(state).seat
        end
        winner = Map.merge(winner, %{
          yaku: phan_yaku,
          yakuman: mun_yaku,
          points: phan,
          yakuman_mult: mun,
          minipoints: mun,
          score: score,
          payer: payer
        })
        state = Map.update!(state, :winners, &Map.put(&1, seat, winner))
        {state, winning_tile}
      _ ->
        state = show_error(state, "Unknown scoring method #{inspect(scoring_table["method"])}")
        {state, winning_tile}
    end

    # correct the winner's hand if the winning tile was taken from hand (for display purposes)
    state = if winning_tile == nil do
      ix = Enum.find_index(state.players[seat].hand, fn tile -> tile == new_winning_tile end)
      update_in(state.winners[seat].player, fn player -> %Player{ player | hand: List.delete_at(state.players[seat].hand, ix), draw: [new_winning_tile] } end)
    else state end

    push_message(state, [
      %{text: "Player #{seat} #{state.players[seat].nickname} called "},
      %{bold: true, text: "#{String.downcase(winning_tile_text)}"},
      %{text: " on "},
      Utils.pt(new_winning_tile),
      %{text: " with hand "}
    ] ++ Utils.ph(state.players[seat].hand |> Utils.sort_tiles())
      ++ Utils.ph(state.players[seat].calls |> Enum.flat_map(&Riichi.call_to_tiles/1))
    )

    state = if Map.has_key?(state.rules, "bloody_end") && state.rules["bloody_end"] do
      # only end the round once there are three winners; otherwise, continue
      Map.put(state, :round_result, if map_size(state.winners) == 3 do :win else :continue end)
    else state end

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
    state = Map.put(state, :timer, 10)
    state = Map.put(state, :visible_screen, :scores)
    state = update_all_players(state, fn seat, player -> %Player{ player | ready: is_pid(Map.get(state, seat)) } end)
    Debounce.apply(state.timer_debouncer)

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
    state = Map.put(state, :timer, 10)
    state = Map.put(state, :visible_screen, :scores)
    state = update_all_players(state, fn seat, player -> %Player{ player | ready: is_pid(Map.get(state, seat)) } end)
    Debounce.apply(state.timer_debouncer)

    delta_scores = Map.new(state.players, fn {seat, _player} -> {seat, 0} end)
    state = Map.put(state, :delta_scores, delta_scores)
    state = Map.put(state, :delta_scores_reason, draw_name)
    state = Map.put(state, :next_dealer, :self)
    state
  end

  defp timer_finished(state) do
    cond do
      state.visible_screen == :winner && state.winner_index + 1 < map_size(state.winners) -> # need to see next winner screen
        # show the next winner
        state = Map.update!(state, :winner_index, & &1 + 1)

        # reset timer
        state = Map.put(state, :timer, 10)
        state = update_all_players(state, fn seat, player -> %Player{ player | ready: is_pid(Map.get(state, seat)) } end)
        Debounce.apply(state.timer_debouncer)

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
        state = Map.put(state, :timer, 10)
        state = update_all_players(state, fn seat, player -> %Player{ player | ready: is_pid(Map.get(state, seat)) } end)
        Debounce.apply(state.timer_debouncer)
        
        state
      state.visible_screen == :scores -> # finished seeing the score exchange screen
        # update kyoku and honba
        state = case state.round_result do
          :win when state.next_dealer == :self ->
            state
              |> Map.update!(:honba, & &1 + 1)
              |> Map.put(:pot, 0)
              |> Map.put(:visible_screen, nil)
          :win ->
            state
              |> Map.update!(:kyoku, & &1 + 1)
              |> Map.put(:honba, 0)
              |> Map.put(:pot, 0)
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
          :continue ->
            state
          end

        # apply delta scores
        state = update_all_players(state, fn seat, player -> %Player{ player | score: player.score + state.delta_scores[seat] } end)
        state = Map.put(state, :delta_scores, nil)

        # check for tobi
        tobi = if Map.has_key?(state.rules, "score_calculation") do Map.get(state.rules["score_calculation"], "tobi", false) else false end
        state = if tobi && Enum.any?(state.players, fn {_seat, player} -> player.score < 0 end) do Map.put(state, :round_result, :end_game) else state end

        # log
        state = Log.finalize_kyoku(state)

        # finish or initialize new round if needed, otherwise continue
        state = if state.round_result != :continue do
          if state.round_result == :end_game || Map.has_key?(state.rules, "max_rounds") && state.kyoku >= state.rules["max_rounds"] do
            finalize_game(state)
          else
            initialize_new_round(state)
          end
        else 
          state = Map.put(state, :visible_screen, nil)
          state = Map.put(state, :game_active, true)

          # trigger before_continue actions
          state = if Map.has_key?(state.rules, "before_continue") do
            Actions.run_actions(state, state.rules["before_continue"]["actions"], %{seat: state.turn})
          else state end

          notify_ai(state)
          state
        end
        state
      true ->
        IO.puts("timer_finished() called; unsure what the timer was for")
        state
    end
  end

  def finalize_game(state) do
    # TODO
    IO.puts("Game concluded")
    state = Map.put(state, :visible_screen, :game_end)
    state
  end

  defp fill_empty_seats_with_ai(state) do
    shanten_definitions = %{
      win: translate_match_definitions(state, Map.get(state.rules, "win_definition", [])),
      tenpai: translate_match_definitions(state, Map.get(state.rules, "tenpai_definition", [])),
      iishanten: translate_match_definitions(state, Map.get(state.rules, "iishanten_definition", [])),
      ryanshanten: translate_match_definitions(state, Map.get(state.rules, "ryanshanten_definition", [])),
      sanshanten: translate_match_definitions(state, Map.get(state.rules, "sanshanten_definition", []))
    }
    for dir <- [:east, :south, :west, :north], Map.get(state, dir) == nil, reduce: state do
      state ->
        {:ok, ai_pid} = DynamicSupervisor.start_child(state.ai_supervisor, {RiichiAdvanced.AIPlayer, %{game_state: self(), seat: dir, player: state.players[dir], shanten_definitions: shanten_definitions}})
        IO.puts("Starting AI for #{dir}: #{inspect(ai_pid)}")
        state = Map.put(state, dir, ai_pid)

        # mark the ai as having clicked the timer, if one exists
        state = update_player(state, dir, fn player -> %Player{ player | ready: true } end)
        
        notify_ai(state)
        state
    end
  end

  def is_playable?(state, seat, tile) do
    have_unskippable_button = Enum.any?(state.players[seat].buttons, fn button_name -> state.rules["buttons"][button_name] != nil && Map.has_key?(state.rules["buttons"][button_name], "unskippable") && state.rules["buttons"][button_name]["unskippable"] end)
    not have_unskippable_button && not Utils.has_attr?(tile, ["no_discard"]) && if Map.has_key?(state.rules, "play_restrictions") do
      Enum.all?(state.rules["play_restrictions"], fn [tile_spec, cond_spec] ->
        not Riichi.tile_matches(tile_spec, %{seat: seat, tile: tile, players: state.players}) || not Conditions.check_cnf_condition(state, cond_spec, %{seat: seat, tile: tile})
      end)
    else true end
  end

  defp _reindex_hand(hand, from, to) do
    {l1, [tile | r1]} = Enum.split(hand, from)
    {l2, r2} = Enum.split(l1 ++ r1, to)
    l2 ++ [tile] ++ r2
  end

  def from_named_tile(state, tile_name) do
    cond do
      is_binary(tile_name) && tile_name in state.reserved_tiles ->
        ix = Enum.find_index(state.reserved_tiles, fn name -> name == tile_name end)
        Enum.at(state.dead_wall, -ix-1)
      is_binary(tile_name) && Utils.is_tile(tile_name) -> Utils.to_tile(tile_name)
      is_integer(tile_name) -> Enum.at(state.dead_wall, tile_name)
      is_atom(tile_name) -> tile_name
      true ->
        IO.puts("Unknown tile name #{inspect(tile_name)}")
        tile_name
    end
  end

  # TODO replace these calls
  def notify_ai(_state) do
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
            translated_groups = for group <- groups, do: (if Map.has_key?(set_definitions, group) do set_definitions[group] else group end)
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
              translate_sets_in_match_definitions(state.rules[name], set_definitions)
            else
              GenServer.cast(self(), {:show_error, "Could not find match definition \"#{name}\" in the rules."})
              []
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
    for tile_spec <- state.revealed_tiles do
      cond do
        is_integer(tile_spec)    -> Enum.at(state.dead_wall, tile_spec, :"1x")
        Utils.is_tile(tile_spec) -> Utils.to_tile(tile_spec)
        true                     ->
          GenServer.cast(self(), {:show_error, "Unknown revealed tile spec: #{inspect(tile_spec)}"})
          state
      end
    end
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

  def get_visible_waits(state, seat, index) do
    hand = state.players[seat].hand ++ state.players[seat].draw
    hand = if index != nil do
      List.delete_at(hand, index)
    else hand end
    calls = state.players[seat].calls
    win_definitions = translate_match_definitions(state, Map.get(state.rules["show_waits"], "win_definitions", []))
    ordering = state.players[seat].tile_ordering
    ordering_r = state.players[seat].tile_ordering_r
    tile_aliases = state.players[seat].tile_aliases
    # construct all visible tiles
    visible_ponds = Enum.flat_map(state.players, fn {_seat, player} -> player.pond end)
    visible_calls = Enum.flat_map(state.players, fn {_seat, player} -> player.calls end)
    visible_tiles = hand ++ visible_ponds ++ Enum.flat_map(visible_calls, &Riichi.call_to_tiles/1)
    Riichi.get_waits_and_ukeire(state.all_tiles, visible_tiles, hand, calls, win_definitions, ordering, ordering_r, tile_aliases)
  end

  def push_message(state, message) do
    for {_seat, messages_state} <- state.messages_states, messages_state != nil do
      # IO.puts("Sending to #{inspect(messages_state)} the message #{inspect(message)}")
      GenServer.cast(messages_state, {:add_message, message})
    end
  end

  def push_messages(state, messages) do
    for {_seat, messages_state} <- state.messages_states, messages_state != nil do
      # IO.puts("Sending to #{inspect(messages_state)} the messages #{inspect(messages)}")
      GenServer.cast(messages_state, {:add_messages, messages})
    end
  end

  def broadcast_state_change(state) do
    # IO.puts("broadcast_state_change called")
    RiichiAdvancedWeb.Endpoint.broadcast(state.ruleset <> ":" <> state.session_id, "state_updated", %{"state" => state})
    # reset anim
    state = update_all_players(state, fn _seat, player -> %Player{ player | last_discard: nil } end)
    state
  end

  def play_sound(state, path, seat \\ nil) do
    RiichiAdvancedWeb.Endpoint.broadcast(state.ruleset <> ":" <> state.session_id, "play_sound", %{"seat" => seat, "path" => path})
  end
  
  def handle_call({:new_player, socket}, _from, state) do
    {seat, spectator} = cond do
      Map.has_key?(socket.assigns, :seat_param) && socket.assigns.seat_param == "east"  && (Map.get(state, :east)  == nil || is_pid(Map.get(state, :east)))  -> {:east, false}
      Map.has_key?(socket.assigns, :seat_param) && socket.assigns.seat_param == "south" && (Map.get(state, :south) == nil || is_pid(Map.get(state, :south))) -> {:south, false}
      Map.has_key?(socket.assigns, :seat_param) && socket.assigns.seat_param == "west"  && (Map.get(state, :west)  == nil || is_pid(Map.get(state, :west)))  -> {:west, false}
      Map.has_key?(socket.assigns, :seat_param) && socket.assigns.seat_param == "north" && (Map.get(state, :north) == nil || is_pid(Map.get(state, :north))) -> {:north, false}
      Map.get(state, :east) == nil  || is_pid(Map.get(state, :east))  -> {:east, false}
      Map.get(state, :south) == nil || is_pid(Map.get(state, :south)) -> {:south, false}
      Map.get(state, :west) == nil  || is_pid(Map.get(state, :west))  -> {:west, false}
      Map.get(state, :north) == nil || is_pid(Map.get(state, :north)) -> {:north, false}
      true                                          -> {:east, true}
    end

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

      # for players with no seats, initialize an ai
      state = fill_empty_seats_with_ai(state)
      state = broadcast_state_change(state)
      state
    else state end

    {:reply, [state] ++ Utils.rotate_4([:east, :south, :west, :north], seat) ++ [spectator], state}
  end

  def handle_call({:delete_player, seat}, _from, state) do
    state = Map.put(state, seat, nil)
    state = put_in(state.messages_states[seat], nil)
    state = update_player(state, seat, &%Player{ &1 | nickname: nil })
    IO.puts("Player #{seat} exited")

    # tell everyone else
    push_message(state, %{text: "Player #{seat} #{state.players[seat].nickname} exited"})

    state = if Enum.all?([:east, :south, :west, :north], fn dir -> Map.get(state, dir) == nil || is_pid(Map.get(state, dir)) end) do
      # all players have left, shutdown
      IO.puts("Stopping game #{state.session_id}")
      DynamicSupervisor.terminate_child(RiichiAdvanced.GameSessionSupervisor, state.supervisor)
      state
    else
      state = fill_empty_seats_with_ai(state)
      state = broadcast_state_change(state)
      state
    end
    {:reply, :ok, state}
  end

  def handle_call({:is_playable, seat, tile}, _from, state), do: {:reply, is_playable?(state, seat, tile), state}
  def handle_call({:get_button_display_name, button_name}, _from, state), do: {:reply, if button_name == "skip" do "Skip" else state.rules["buttons"][button_name]["display_name"] end, state}
  def handle_call({:get_auto_button_display_name, button_name}, _from, state), do: {:reply, state.rules["auto_buttons"][button_name]["display_name"], state}
  def handle_call(:get_revealed_tiles, _from, state), do: {:reply, get_revealed_tiles(state), state}

  def handle_call({:get_visible_waits, seat, index}, _from, state) do
    if index == nil do
      {:reply, get_visible_waits(state, seat, nil), state}
    else
      tile = Enum.at(state.players[seat].hand ++ state.players[seat].draw, index)
      playable = is_playable?(state, seat, tile)
      if not playable || not Map.has_key?(state.rules, "show_waits") do
        {:reply, %{}, state}
      else
        {:reply, get_visible_waits(state, seat, index), state}
      end
    end
  end

  # the AI calls these to figure out if it's allowed to play
  # (this is since they operate on a delay, so state may have changed between when they were
  # notified and when they decide to act)
  def handle_call({:can_discard, seat}, _from, state) do
    our_turn = seat == state.turn
    last_discard_action = get_last_discard_action(state)
    turn_just_discarded = last_discard_action != nil && last_discard_action.seat == state.turn
    extra_turn = "extra_turn_taken" in state.players[state.turn].status
    {:reply, our_turn && (not turn_just_discarded || extra_turn), state}
  end

  # marking calls
  def handle_call({:needs_marking?, seat}, _from, state), do: {:reply, Marking.needs_marking?(state, seat), state}
  def handle_call({:is_marked?, marking_player, seat, index, source}, _from, state), do: {:reply, Marking.is_marked?(state, marking_player, seat, index, source), state}
  def handle_call({:can_mark?, marking_player, seat, index, source}, _from, state), do: {:reply, Marking.can_mark?(state, marking_player, seat, index, source), state}

  # debugging only
  def handle_call(:get_log, _from, state) do
    log = Log.output(state)
    {:reply, log, state}
  end
  # debugging only
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
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
    state = Actions.run_actions(state, actions, context)
    state = broadcast_state_change(state)
    notify_ai(state)
    {:noreply, state}
  end

  def handle_cast({:reindex_hand, seat, from, to}, state) do
    state = Actions.temp_disable_play_tile(state, seat)
    # IO.puts("#{seat} moved tile from #{from} to #{to}")
    state = update_player(state, seat, &%Player{ &1 | :hand => _reindex_hand(&1.hand, from, to) })
    state = broadcast_state_change(state)
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

  def handle_cast({:play_tile, seat, index}, state) do
    tile = Enum.at(state.players[seat].hand ++ state.players[seat].draw, index)
    playable = is_playable?(state, seat, tile)
    if not playable do
      IO.puts("#{seat} tried to play an unplayable tile: #{inspect{tile}}")
    end
    state = if state.turn == seat && playable && state.play_tile_debounce[seat] == false do
      state = Actions.temp_disable_play_tile(state, seat)
      # assume we're skipping our button choices
      state = update_player(state, seat, &%Player{ &1 | buttons: [], button_choices: %{}, call_buttons: %{}, call_name: "" })
      actions = [["play_tile", tile, index], ["check_discard_passed"], ["advance_turn"]]
      state = Actions.submit_actions(state, seat, "play_tile", actions)
      state = broadcast_state_change(state)
      state
    else state end
    {:noreply, state}
  end

  def handle_cast({:press_button, seat, button_name}, state) do
    {:noreply, Buttons.press_button(state, seat, button_name)}
  end

  def handle_cast({:trigger_auto_button, seat, auto_button_name}, state) do
    state = Actions.run_actions(state, state.rules["auto_buttons"][auto_button_name]["actions"], %{seat: seat, auto: true})
    state = broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast({:toggle_auto_button, seat, auto_button_name, enabled}, state) do
    # Keyword.put screws up ordering, so we need to use Enum.map
    state = update_player(state, seat, fn player -> %Player{ player | auto_buttons: Enum.map(player.auto_buttons, fn {name, on} ->
      if auto_button_name == name do {name, enabled} else {name, on} end
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
    # IO.puts("Notifying ai")
    # IO.inspect(Process.info(self(), :current_stacktrace))
    if state.game_active do
      # if there are any new buttons for any AI players, notify them
      # otherwise, just tell the current player it's their turn
      if Buttons.no_buttons_remaining?(state) do
        if is_pid(Map.get(state, state.turn)) do
          # IO.puts("Notifying #{state.turn} AI that it's their turn")
          send(Map.get(state, state.turn), {:your_turn, %{player: state.players[state.turn]}})
        end
      else
        Enum.each([:east, :south, :west, :north], fn seat ->
          has_buttons = not Enum.empty?(state.players[seat].buttons)
          has_call_buttons = not Enum.empty?(state.players[seat].call_buttons)
          has_marking_ui = not Enum.empty?(state.marking[seat])
          if is_pid(Map.get(state, seat)) && has_buttons && not has_call_buttons && not has_marking_ui do
            # IO.puts("Notifying #{seat} AI about their buttons: #{inspect(state.players[seat].buttons)}")
            send(Map.get(state, seat), {:buttons, %{player: state.players[seat]}})
          end
        end)
      end
    else
      :timer.apply_after(1000, GenServer, :cast, [self(), :notify_ai])
    end
    {:noreply, state}
  end

  def handle_cast({:notify_ai_marking, seat}, state) do
    if state.game_active do
      if is_pid(Map.get(state, seat)) && Marking.needs_marking?(state, seat) do
        # IO.puts("Notifying #{seat} AI about marking")
        send(Map.get(state, seat), {:mark_tiles, %{player: state.players[seat], players: state.players, revealed_tiles: get_revealed_tiles(state), wall: Enum.drop(state.wall, state.wall_index), marked_objects: state.marking[seat]}})
      end
    else
      :timer.apply_after(1000, GenServer, :cast, [self(), {:notify_ai_marking, seat}])
    end
    {:noreply, state}
  end

  def handle_cast({:notify_ai_call_buttons, seat}, state) do
    if state.game_active do
      call_choices = state.players[seat].call_buttons
      if is_pid(Map.get(state, seat)) && not Enum.empty?(call_choices) && not Enum.empty?(call_choices |> Map.values() |> Enum.concat()) do
        # IO.puts("Notifying #{seat} AI about their call buttons: #{inspect(state.players[seat].call_buttons)}")
        send(Map.get(state, seat), {:call_buttons, %{player: state.players[seat]}})
      end
    else
      :timer.apply_after(1000, GenServer, :cast, [self(), {:notify_ai_call_buttons, seat}])
    end
    {:noreply, state}
  end

  def handle_cast({:notify_ai_declare_yaku, seat}, state) do
    if state.game_active do
      if is_pid(Map.get(state, seat)) do
        send(Map.get(state, seat), {:declare_yaku, %{player: state.players[seat]}})
      end
    else
      :timer.apply_after(1000, GenServer, :cast, [self(), {:notify_ai_declare_yaku, seat}])
    end
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
    if state.timer <= 0 || Enum.all?(state.players, fn {_seat, player} -> player.ready end) do
      state = Map.put(state, :timer, 0)
      state = timer_finished(state)
      state = broadcast_state_change(state)
      {:noreply, state}
    else
      Debounce.apply(state.timer_debouncer)
      state = Map.put(state, :timer, state.timer - 1)
      state = broadcast_state_change(state)
      {:noreply, state}
    end
  end

  def handle_cast({:show_error, message}, state) do
    state = show_error(state, message)
    {:noreply, state}
  end

  # marking calls
  def handle_cast({:mark_tile, marking_player, seat, index, source}, state) do
    state = Marking.mark_tile(state, marking_player, seat, index, source)
    state = if not Marking.needs_marking?(state, marking_player) do
      state = Actions.run_deferred_actions(state, %{seat: marking_player})
      # only reset marking if the mark action states that it is done
      state = if Marking.is_done?(state, seat) do
        Marking.reset_marking(state, marking_player)
      else state end

      # if we're still going, run deferred actions for everyone and then notify ai
      state = if state.game_active do
        state = Actions.resume_deferred_actions(state)
        # TODO for some reason it doesn't work if we notify immediately
        # notify_ai(state)
        # situation is tsujigaito satoha's swap after chii; chii ai player doesn't resume play
        :timer.apply_after(200, GenServer, :cast, [self(), :notify_ai])
        state
      else state end

      state
    else state end
    notify_ai_marking(state, marking_player)
    state = broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast({:clear_marked_objects, marking_player}, state) do
    state = Marking.clear_marked_objects(state, marking_player)
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

  def handle_cast({:declare_yaku, seat, yakus}, state) do
    state = update_player(state, seat, &%Player{ &1 | declared_yaku: yakus })
    prefix = %{text: "Player #{seat} #{state.players[seat].nickname} declared that they will win with at least the following yaku:"}
    yaku_string = Enum.map(yakus, fn yaku -> %{bold: true, text: yaku} end)
    suffix = %{text: "(Shimizudani Ryuuka)"}
    push_message(state, [prefix] ++ yaku_string ++ [suffix])
    state = Buttons.recalculate_buttons(state)
    state = broadcast_state_change(state)
    {:noreply, state}
  end
end
