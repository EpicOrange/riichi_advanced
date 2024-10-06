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
    big_text: "",
    status: [],
    riichi_stick: false,
    hand_revealed: false,
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
    wall: [],
    kyoku: 0,
    honba: 0,
    riichi_sticks: 0,
    tags: %{},
    log_state: %{},

    # working game state (reset on new round)
    # (these are all reset manually, so if you add a new one go to initialize_new_round to reset it)
    turn: :east,
    wall_index: 0,
    dead_wall_index: 0,
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

    initial_score = if Map.has_key?(rules, "initial_score") do rules["initial_score"] else 0 end

    state = update_players(state, &%Player{ &1 | score: initial_score })
    state = initialize_new_round(state)

    Scoring.run_yaku_tests(state)

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

    wall = Enum.map(Map.get(rules, "wall", []), &Utils.to_tile(&1))
    
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

    # reserve some tiles (dead wall)
    state = if Map.has_key?(rules, "reserved_tiles") and length(rules["reserved_tiles"]) > 0 do
      reserved_tile_names = rules["reserved_tiles"]
      {wall, dead_wall} = Enum.split(wall, -length(reserved_tile_names))
      reserved_tiles = Enum.zip(reserved_tile_names, dead_wall)
      revealed_tiles = if Map.has_key?(rules, "revealed_tiles") do rules["revealed_tiles"] else [] end
      max_revealed_tiles = if Map.has_key?(rules, "max_revealed_tiles") do rules["max_revealed_tiles"] else 0 end
      state 
      |> Map.put(:wall, wall)
      |> Map.put(:haipai, hands)
      |> Map.put(:dead_wall, dead_wall)
      |> Map.put(:reserved_tiles, reserved_tiles)
      |> Map.put(:revealed_tiles, revealed_tiles)
      |> Map.put(:max_revealed_tiles, max_revealed_tiles)
      |> Map.put(:drawn_reserved_tiles, [])
    else
      state
      |> Map.put(:wall, wall)
      |> Map.put(:dead_wall, [])
      |> Map.put(:reserved_tiles, [])
      |> Map.put(:revealed_tiles, [])
      |> Map.put(:max_revealed_tiles, 0)
      |> Map.put(:drawn_reserved_tiles, [])
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

    state = state
     |> Map.put(:wall_index, starting_tiles*4)
     |> Map.put(:dead_wall_index, 0)
     |> update_all_players(&%Player{
          score: &2.score,
          nickname: &2.nickname,
          hand: hands[&1],
          auto_buttons: initial_auto_buttons,
          status: Enum.filter(&2.status, fn status -> status in persistent_statuses end)
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
    state = update_player(state, seat, fn player -> %Player{ player | winning_hand: state.players[seat].hand ++ call_tiles ++ [winning_tile] } end)
    # add this to the state so yaku conditions can refer to the winner
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
      winning_tile: winning_tile, # for display use only
      winning_tile_text: winning_tile_text, # for display use only
      win_source: win_source,
      point_name: Map.get(state.rules, "point_name", ""),
      limit_point_name: Map.get(state.rules, "limit_point_name", ""),
      minipoint_name: Map.get(state.rules, "minipoint_name", ""),
    }
    state = Map.update!(state, :winners, &Map.put(&1, seat, winner))

    state = push_message(state, [
      %{text: "Player #{seat} #{state.players[seat].nickname} called "},
      %{bold: true, text: "#{String.downcase(winning_tile_text)}"},
      %{text: " on "},
      Utils.pt(winning_tile),
      %{text: " with hand "}
    ] ++ Utils.ph(Utils.sort_tiles(state.players[seat].hand)))

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
      RiichiAdvanced.SMT.match_hand_smt_v2(state.smt_solver, state.players[seat].hand ++ [winning_tile], state.players[seat].calls, translate_match_definitions(state, ["win"]), state.players[seat].tile_ordering, state.players[seat].tile_mappings)
    end
    IO.puts("Joker assignments: #{inspect(joker_assignments)}")
    joker_assignments = if Enum.empty?(joker_assignments) do [%{}] else joker_assignments end
    state = case scoring_table["method"] do
      "riichi" ->
        # find the maximum yaku obtainable across all joker assignments
        {joker_assignment, yaku, yakuman, minipoints, score, points, yakuman_mult, score_name} = for joker_assignment <- joker_assignments do
          # temporarily replace winner's hand with joker assignment to determine yaku
          {state, assigned_winning_tile} = Scoring.apply_joker_assignment(state, seat, joker_assignment, winning_tile)
          minipoints = Riichi.calculate_fu(state.players[seat].hand, state.players[seat].calls, assigned_winning_tile, win_source, Riichi.get_seat_wind(state.kyoku, seat), Riichi.get_round_wind(state.kyoku), state.players[seat].tile_ordering, state.players[seat].tile_ordering_r, state.players[seat].tile_aliases)
          if minipoints == 0 do
            IO.inspect("Warning: 0 minipoints translates into nil score")
          end
          yaku = Scoring.get_yaku(state, state.rules["yaku"] ++ state.rules["extra_yaku"], seat, assigned_winning_tile, win_source, minipoints)
          yaku = if Map.has_key?(state.rules, "meta_yaku") do
            Scoring.get_yaku(state, state.rules["meta_yaku"], seat, assigned_winning_tile, win_source, minipoints, yaku)
          else yaku end
          yakuman = Scoring.get_yaku(state, state.rules["yakuman"], seat, assigned_winning_tile, win_source, minipoints)
          {score, points, yakuman_mult} = Scoring.score_yaku(state, seat, yaku, yakuman, win_source == :draw, minipoints)
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
          {joker_assignment, yaku, yakuman, minipoints, score, points, yakuman_mult, score_name}
        end |> Enum.sort_by(fn {_, _, _, _, score, _, _, _} -> score end) |> Enum.at(-1)

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
          pao_seat: pao_seat
        })
        state = Map.update!(state, :winners, &Map.put(&1, seat, winner))
        state
      "hk" ->
        # find the maximum yaku obtainable across all joker assignments
        {joker_assignment, yaku, score, fan} = for joker_assignment <- joker_assignments do
          # replace 5z with 0z
          joker_assignment = Map.new(joker_assignment, fn {ix, tile} -> if tile == :"5z" do {ix, :"0z"} else {ix, tile} end end)

          # temporarily replace winner's hand with joker assignment to determine yaku
          {state, assigned_winning_tile} = Scoring.apply_joker_assignment(state, seat, joker_assignment, winning_tile)
          yaku = Scoring.get_yaku(state, state.rules["yaku"], seat, assigned_winning_tile, win_source)
          yaku = if Map.has_key?(state.rules, "meta_yaku") do
            Scoring.get_yaku(state, state.rules["meta_yaku"], seat, assigned_winning_tile, win_source, 0, yaku)
          else yaku end
          {score, fan, _} = Scoring.score_yaku(state, seat, yaku, [], win_source == :draw)

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
        state
      "sichuan" -> # TODO this is same as hk
        # add a winner
        yaku = Scoring.get_yaku(state, state.rules["yaku"], seat, winning_tile, win_source)
        {score, points, _} = Scoring.score_yaku(state, seat, yaku, [], win_source == :draw)
        payer = case win_source do
          :draw    -> nil
          :discard -> get_last_discard_action(state).seat
          :call    -> get_last_call_action(state).seat
        end
        winner = Map.merge(winner, %{
          yaku: yaku,
          yakuman: [],
          points: points,
          score: score,
          payer: payer
        })
        state = Map.update!(state, :winners, &Map.put(&1, seat, winner))
        state
      "vietnamese" ->
        # find the maximum yaku obtainable across all joker assignments
        {joker_assignment, phan_yaku, mun_yaku, score, phan, mun} = for joker_assignment <- joker_assignments do
          # replace 5z with 0z
          joker_assignment = Map.new(joker_assignment, fn {ix, tile} -> if tile == :"5z" do {ix, :"0z"} else {ix, tile} end end)

          # temporarily replace winner's hand with joker assignment to determine yaku
          {state, assigned_winning_tile} = Scoring.apply_joker_assignment(state, seat, joker_assignment, winning_tile)
          phan_yaku = Scoring.get_yaku(state, state.rules["yaku"], seat, assigned_winning_tile, win_source)
          mun_yaku = Scoring.get_yaku(state, state.rules["yakuman"], seat, assigned_winning_tile, win_source)
          phan_yaku = if Map.has_key?(state.rules, "meta_yaku") do
            Scoring.get_yaku(state, state.rules["meta_yaku"], seat, assigned_winning_tile, win_source, 0, mun_yaku ++ phan_yaku)
          else phan_yaku end -- mun_yaku
          {score, phan, mun} = Scoring.score_yaku(state, seat, phan_yaku, mun_yaku, win_source == :draw)

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
        state
      _ ->
        state = show_error(state, "Unknown scoring method #{inspect(scoring_table["method"])}")
        state
    end

    state = if Map.has_key?(state.rules, "bloody_end") && state.rules["bloody_end"] do
      # only end the round once there are three winners; otherwise, continue
      Map.put(state, :round_result, if map_size(state.winners) == 3 do :win else :continue end)
    else state end

    state
  end

  def exhaustive_draw(state) do
    state = Map.put(state, :round_result, :draw)

    state = push_message(state, [%{text: "Game ended by exhaustive draw"}])

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

    state = push_message(state, [%{text: "Game ended by abortive draw (#{draw_name})"}])

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
              |> Map.put(:riichi_sticks, 0)
              |> Map.put(:visible_screen, nil)
          :win ->
            state
              |> Map.update!(:kyoku, & &1 + 1)
              |> Map.put(:honba, 0)
              |> Map.put(:riichi_sticks, 0)
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
    for dir <- [:east, :south, :west, :north], Map.get(state, dir) == nil, reduce: state do
      state ->
        {:ok, ai_pid} = DynamicSupervisor.start_child(state.ai_supervisor, {RiichiAdvanced.AIPlayer, %{game_state: self(), seat: dir, player: state.players[dir]}})
        IO.puts("Starting AI for #{dir}: #{inspect(ai_pid)}")
        state = Map.put(state, dir, ai_pid)

        # mark the ai as having clicked the timer, if one exists
        state = update_player(state, dir, fn player -> %Player{ player | ready: true } end)
        
        notify_ai(state)
        state
    end
  end

  def is_playable?(state, seat, tile, tile_source) do
    have_unskippable_button = Enum.any?(state.players[seat].buttons, fn button_name -> state.rules["buttons"][button_name] != nil && Map.has_key?(state.rules["buttons"][button_name], "unskippable") && state.rules["buttons"][button_name]["unskippable"] end)
    not have_unskippable_button && if Map.has_key?(state.rules, "play_restrictions") do
      Enum.all?(state.rules["play_restrictions"], fn [tile_spec, cond_spec] ->
        # if Riichi.tile_matches(tile_spec, %{tile: tile}) do
        #   IO.inspect({tile, cond_spec, check_cnf_condition(state, cond_spec, %{seat: seat, tile: tile, tile_source: tile_source})})
        # end
        not Riichi.tile_matches(tile_spec, %{tile: tile}) || check_cnf_condition(state, cond_spec, %{seat: seat, tile: tile, tile_source: tile_source})
      end)
    else true end
  end

  defp _reindex_hand(hand, from, to) do
    {l1, [tile | r1]} = Enum.split(hand, from)
    {l2, r2} = Enum.split(l1 ++ r1, to)
    l2 ++ [tile] ++ r2
  end

  def from_tile_name(state, tile_name) do
    cond do
      is_binary(tile_name) && List.keymember?(state.reserved_tiles, tile_name, 0) ->
        if String.ends_with?(tile_name, "_lazy") do
          # draw from dead wall, which might change over the course of the game
          reverse_ix = Enum.find_index(state.reserved_tiles, fn {name, _tile} -> name == tile_name end) - length(state.reserved_tiles)
          # IO.inspect({tile_name, Enum.find_index(state.reserved_tiles, fn {name, _tile} -> name == tile_name end), length(state.reserved_tiles)})
          Enum.at(state.dead_wall, reverse_ix)
        else
          {_, tile} = List.keyfind(state.reserved_tiles, tile_name, 0)
          tile
        end
      is_atom(tile_name) -> tile_name
      true ->
        IO.puts("Unknown tile name #{inspect(tile_name)}")
        tile_name
    end
  end

  def notify_ai_call_buttons(state, seat) do
    if state.game_active do
      call_choices = state.players[seat].call_buttons
      if is_pid(Map.get(state, seat)) && not Enum.empty?(call_choices) && not Enum.empty?(call_choices |> Map.values() |> Enum.concat()) do
        # IO.puts("Notifying #{seat} AI about their call buttons: #{inspect(state.players[seat].call_buttons)}")
        send(Map.get(state, seat), {:call_buttons, %{player: state.players[seat]}})
      end
    end
  end

  def notify_ai_marking(state, seat) do
    if state.game_active do
      if is_pid(Map.get(state, seat)) && Marking.needs_marking?(state, seat) do
        # IO.puts("Notifying #{seat} AI about marking")
        send(Map.get(state, seat), {:mark_tiles, %{player: state.players[seat], marked_objects: state.marking[seat]}})
      end
    end
  end

  def notify_ai(state) do
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
    end
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

  def get_hand_calls_spec(state, context, hand_calls_spec) do
    last_call_action = get_last_call_action(state)
    last_discard_action = get_last_discard_action(state)
    for item <- hand_calls_spec, reduce: [{[], []}] do
      hand_calls -> for {hand, calls} <- hand_calls do
        case item do
          "hand" -> [{hand ++ state.players[context.seat].hand, calls}]
          "draw" -> [{hand ++ state.players[context.seat].draw, calls}]
          "pond" -> [{hand ++ state.players[context.seat].pond, calls}]
          "calls" -> [{hand, calls ++ state.players[context.seat].calls}]
          "flowers" -> [{hand, calls ++ Enum.filter(state.players[context.seat].calls, fn {call_name, _call} -> call_name in ["flower", "start_flower"] end)}]
          "start_flowers" -> [{hand, calls ++ Enum.filter(state.players[context.seat].calls, fn {call_name, _call} -> call_name == "start_flower" end)}]
          "jokers" -> [{hand, calls ++ Enum.filter(state.players[context.seat].calls, fn {call_name, _call} -> call_name in ["joker", "start_joker"] end)}]
          "start_jokers" -> [{hand, calls ++ Enum.filter(state.players[context.seat].calls, fn {call_name, _call} -> call_name == "start_joker" end)}]
          "call_tiles" -> [{hand ++ Enum.flat_map(state.players[context.seat].calls, &Riichi.call_to_tiles/1), calls}]
          "last_call" -> [{hand, calls ++ [context.call]}]
          "last_called_tile" -> if last_call_action != nil do [{hand ++ [last_call_action.called_tile], calls}] else [] end
          "last_discard" -> if last_discard_action != nil do [{hand ++ [last_discard_action.tile], calls}] else [] end
          "winning_tile" ->
            winning_tile = if Map.has_key?(context, :winning_tile) do context.winning_tile else state.winners[context.seat].winning_tile end
            [{hand ++ [winning_tile], calls}]
          "any_discard" -> Enum.map(state.players[context.seat].discards, fn discard -> {hand ++ [discard], calls} end)
          "all_discards" -> [{hand ++ Enum.flat_map(state.players, fn {_seat, player} -> player.pond end), calls}]
        end
      end |> Enum.concat()
    end
  end

  def check_condition(state, cond_spec, context \\ %{}, opts \\ []) do
    negated = String.starts_with?(cond_spec, "not_")
    cond_spec = if negated do String.slice(cond_spec, 4..-1//1) else cond_spec end
    last_action = get_last_action(state)
    last_call_action = get_last_call_action(state)
    last_discard_action = get_last_discard_action(state)
    cxt_player = if Map.has_key?(context, :seat) do state.players[context.seat] else nil end
    result = case cond_spec do
      "true"                        -> true
      "false"                       -> false
      "print"                       ->
        IO.inspect(opts)
        true
      "print_context"               ->
        IO.inspect(context)
        true
      "our_turn"                    -> state.turn == context.seat
      "our_turn_is_next"            -> state.turn == if state.reversed_turn_order do Utils.next_turn(context.seat) else Utils.prev_turn(context.seat) end
      "our_turn_is_not_next"        -> state.turn != if state.reversed_turn_order do Utils.next_turn(context.seat) else Utils.prev_turn(context.seat) end
      "our_turn_is_prev"            -> state.turn == if state.reversed_turn_order do Utils.prev_turn(context.seat) else Utils.next_turn(context.seat) end
      "our_turn_is_not_prev"        -> state.turn != if state.reversed_turn_order do Utils.prev_turn(context.seat) else Utils.next_turn(context.seat) end
      "game_start"                  -> last_action == nil
      "no_discards_yet"             -> last_discard_action == nil
      "no_calls_yet"                -> last_call_action == nil
      "last_call_is"                -> last_call_action != nil && last_call_action.call_name == Enum.at(opts, 0, "kakan")
      "kamicha_discarded"           -> last_action != nil && last_action.action == :discard && last_action.seat == state.turn && state.turn == Utils.prev_turn(context.seat)
      "someone_else_just_discarded" -> last_action != nil && last_action.action == :discard && last_action.seat == state.turn && state.turn != context.seat
      "just_discarded"              -> last_action != nil && last_action.action == :discard && last_action.seat == state.turn && state.turn == context.seat
      "just_called"                 -> last_action != nil && last_action.action == :call
      "call_available"              -> last_action != nil && last_action.action == :discard && Riichi.can_call?(context.calls_spec, cxt_player.hand, cxt_player.tile_ordering, cxt_player.tile_ordering_r, [last_action.tile], cxt_player.tile_aliases, cxt_player.tile_mappings)
      "self_call_available"         -> Riichi.can_call?(context.calls_spec, cxt_player.hand ++ cxt_player.draw, cxt_player.tile_ordering, cxt_player.tile_ordering_r, [], cxt_player.tile_aliases, cxt_player.tile_mappings)
      "can_upgrade_call"            -> cxt_player.calls
        |> Enum.filter(fn {name, _call} -> name == context.upgrade_name end)
        |> Enum.any?(fn {_name, call} ->
          call_tiles = Enum.map(call, fn {tile, _sideways} -> tile end)
          Riichi.can_call?(context.calls_spec, call_tiles, cxt_player.tile_ordering, cxt_player.tile_ordering_r, cxt_player.hand ++ cxt_player.draw, cxt_player.tile_aliases, cxt_player.tile_mappings)
        end)
      "has_draw"                 -> not Enum.empty?(cxt_player.draw)
      "has_aside"                -> not Enum.empty?(cxt_player.aside)
      "has_han_with_hand"        -> not Enum.empty?(cxt_player.draw) && Scoring.seat_scores_points(state, state.rules["yaku"], Enum.at(opts, 0, 1), context.seat, Enum.at(cxt_player.draw, 0), :draw)
      "has_han_with_discard"     -> last_action.action == :discard && Scoring.seat_scores_points(state, state.rules["yaku"], Enum.at(opts, 0, 1), context.seat, last_action.tile, :discard)
      "has_han_with_call"        -> last_action.action == :call && Scoring.seat_scores_points(state, state.rules["yaku"], Enum.at(opts, 0, 1), context.seat, last_action.tile, :call)
      "has_extra_han_with_hand"    -> not Enum.empty?(cxt_player.draw) && Scoring.seat_scores_points(state, state.rules["yaku"] ++ state.rules["extra_yaku"], Enum.at(opts, 0, 1), context.seat, Enum.at(cxt_player.draw, 0), :draw)
      "has_extra_han_with_discard" -> last_action.action == :discard && Scoring.seat_scores_points(state, state.rules["yaku"] ++ state.rules["extra_yaku"], Enum.at(opts, 0, 1), context.seat, last_action.tile, :discard)
      "has_extra_han_with_call"    -> last_action.action == :call && Scoring.seat_scores_points(state, state.rules["yaku"] ++ state.rules["extra_yaku"], Enum.at(opts, 0, 1), context.seat, last_action.tile, :call)
      "has_yakuman_with_hand"    -> not Enum.empty?(cxt_player.draw) && Scoring.seat_scores_points(state, state.rules["yakuman"], 1, context.seat, Enum.at(cxt_player.draw, 0), :draw)
      "has_yakuman_with_discard" -> last_action.action == :discard && Scoring.seat_scores_points(state, state.rules["yakuman"], 1, context.seat, last_action.tile, :discard)
      "has_yakuman_with_call"    -> last_action.action == :call && Scoring.seat_scores_points(state, state.rules["yakuman"], 1, context.seat, last_action.tile, :call)
      "last_discard_matches"     -> last_discard_action != nil && Riichi.tile_matches(opts, %{tile: last_discard_action.tile, tile2: context.tile, ordering: state.players[context.seat].tile_ordering, ordering_r: state.players[context.seat].tile_ordering_r, tile_aliases: state.players[context.seat].tile_aliases})
      "last_called_tile_matches" -> last_action.action == :call && Riichi.tile_matches(opts, %{tile: last_action.called_tile, tile2: context.tile, ordering: state.players[context.seat].tile_ordering, ordering_r: state.players[context.seat].tile_ordering_r, tile_aliases: state.players[context.seat].tile_aliases, call: last_call_action})
      "unneeded_for_hand"        -> Riichi.not_needed_for_hand(cxt_player.hand ++ cxt_player.draw, cxt_player.calls, context.tile, translate_match_definitions(state, opts), cxt_player.tile_ordering, cxt_player.tile_ordering_r, cxt_player.tile_aliases)
      "has_calls"                -> not Enum.empty?(cxt_player.calls)
      "no_calls"                 -> Enum.empty?(cxt_player.calls)
      "has_call_named"           -> Enum.all?(cxt_player.calls, fn {name, _call} -> name in opts end)
      "has_no_call_named"        -> Enum.all?(cxt_player.calls, fn {name, _call} -> name not in opts end)
      "won_by_call"              -> context.win_source == :call
      "won_by_draw"              -> context.win_source == :draw
      "won_by_discard"           -> context.win_source == :discard
      "status"                   -> Enum.all?(opts, fn st -> st in cxt_player.status end)
      "status_missing"           -> Enum.all?(opts, fn st -> st not in cxt_player.status end)
      "discarder_status"         -> last_action.action == :discard && Enum.all?(opts, fn st -> st in state.players[last_action.seat].status end)
      "shimocha_status"          -> Enum.all?(opts, fn st -> st in state.players[Utils.get_seat(context.seat, :shimocha)].status end)
      "toimen_status"            -> Enum.all?(opts, fn st -> st in state.players[Utils.get_seat(context.seat, :toimen)].status end)
      "kamicha_status"           -> Enum.all?(opts, fn st -> st in state.players[Utils.get_seat(context.seat, :kamicha)].status end)
      "others_status"            -> Enum.any?(state.players, fn {seat, player} -> Enum.all?(opts, fn st -> seat != context.seat && st in player.status end) end)
      "anyone_status"            -> Enum.any?(state.players, fn {_seat, player} -> Enum.all?(opts, fn st -> st in player.status end) end)
      "everyone_status"          -> Enum.all?(state.players, fn {_seat, player} -> Enum.all?(opts, fn st -> st in player.status end) end)
      "is_drawn_tile"            -> context.tile_source == :draw
      "buttons_include"          -> Enum.all?(opts, fn button_name -> button_name in cxt_player.buttons end)
      "buttons_exclude"          -> Enum.all?(opts, fn button_name -> button_name not in cxt_player.buttons end)
      "tile_drawn"               -> Enum.all?(opts, fn tile -> tile in state.drawn_reserved_tiles end)
      "tile_not_drawn"           -> Enum.all?(opts, fn tile -> tile not in state.drawn_reserved_tiles end)
      "tile_revealed"            -> Enum.all?(opts, fn tile -> tile in state.revealed_tiles end)
      "tile_not_revealed"        -> Enum.all?(opts, fn tile -> tile not in state.revealed_tiles end)
      "no_tiles_remaining"       -> length(state.wall) - length(state.drawn_reserved_tiles) - state.wall_index - state.dead_wall_index <= 0
      "tiles_remaining"          -> length(state.wall) - length(state.drawn_reserved_tiles) - state.wall_index - state.dead_wall_index >= Enum.at(opts, 0, 0)
      "has_score"                -> state.players[context.seat].score >= Enum.at(opts, 0, 0)
      "next_draw_possible"       ->
        draws_left = length(state.wall) - length(state.drawn_reserved_tiles) - state.wall_index
        case Utils.get_relative_seat(context.seat, state.turn) do
          :shimocha -> draws_left >= 3
          :toimen   -> draws_left >= 2
          :kamicha  -> draws_left >= 1
          :self     -> draws_left >= 4
        end
      "round_wind_is"            ->
        round_wind = Riichi.get_round_wind(state.kyoku)
        case Enum.at(opts, 0, "east") do
          "east"  -> round_wind == :east
          "south" -> round_wind == :south
          "west"  -> round_wind == :west
          "north" -> round_wind == :north
          _       ->
            IO.puts("Unknown round wind #{inspect(Enum.at(opts, 0, "east"))}")
            false
        end
      "seat_is"                  ->
        seat_wind = Riichi.get_seat_wind(state.kyoku, context.seat)
        case Enum.at(opts, 0, "east") do
          "east"  -> seat_wind == :east
          "south" -> seat_wind == :south
          "west"  -> seat_wind == :west
          "north" -> seat_wind == :north
          _       ->
            IO.puts("Unknown seat wind #{inspect(Enum.at(opts, 0, "east"))}")
            false
        end
      "winning_dora_count"       ->
        dora_indicator = from_tile_name(state, Enum.at(opts, 0, :"1m"))
        num = Enum.at(opts, 1, 1)
        dora = Map.get(state.rules["dora_indicators"], Atom.to_string(dora_indicator), [])
        Enum.count(cxt_player.winning_hand, fn tile -> Atom.to_string(tile) in dora end) == num
      "fu_equals"                -> context.minipoints == Enum.at(opts, 0, 20)
      "match"                    -> 
        hand_calls = get_hand_calls_spec(state, context, Enum.at(opts, 0, []))
        match_definitions = translate_match_definitions(state, Enum.at(opts, 1, []))
        ordering = cxt_player.tile_ordering
        ordering_r = cxt_player.tile_ordering_r
        tile_aliases = cxt_player.tile_aliases
        Enum.any?(hand_calls, fn {hand, calls} -> Riichi.match_hand(hand, calls, match_definitions, ordering, ordering_r, tile_aliases) end)
      "winning_hand_consists_of" ->
        tile_mappings = cxt_player.tile_mappings
        tiles = Enum.map(opts, &Utils.to_tile/1)
        winning_hand = cxt_player.hand ++ Enum.flat_map(cxt_player.calls, &Riichi.call_to_tiles/1)
        Enum.all?(winning_hand, fn tile -> Enum.any?([tile] ++ Map.get(tile_mappings, tile, []), fn t -> t in tiles end) end)
      "winning_hand_and_tile_consists_of" ->
        tile_mappings = cxt_player.tile_mappings
        tiles = Enum.map(opts, &Utils.to_tile/1)
        winning_hand = cxt_player.hand ++ Enum.flat_map(cxt_player.calls, &Riichi.call_to_tiles/1)
        winning_tile = if Map.has_key?(context, :winning_tile) do context.winning_tile else state.winners[context.seat].winning_tile end
        Enum.all?(winning_hand ++ [winning_tile], fn tile -> Enum.any?([tile] ++ Map.get(tile_mappings, tile, []), fn t -> t in tiles end) end)
      "all_saki_cards_drafted"   -> Map.has_key?(state, :saki) && Saki.check_if_all_drafted(state)
      "has_existing_yaku"        -> Enum.all?(opts, fn opt -> case opt do
          [name, value] -> Enum.any?(context.existing_yaku, fn {name2, value2} -> name == name2 && value == value2 end)
          name          -> Enum.any?(context.existing_yaku, fn {name2, _value} -> name == name2 end)
        end end)
      "has_no_yaku"             -> Enum.empty?(context.existing_yaku)
      "placement"               ->
        placements = state.players
        |> Enum.sort_by(fn {seat, player} -> -player.score - Riichi.get_seat_scoring_offset(state.kyoku, seat) end)
        |> Enum.map(fn {seat, _player} -> seat end)
        Enum.at(placements, Enum.at(opts, 0, 1) - 1) == context.seat
      "last_discard_matches_existing" -> 
        if last_discard_action != nil do
          tile = last_discard_action.tile
          discards = state.players[last_discard_action.seat].discards |> Enum.drop(-1)
          tile_aliases = state.players[last_discard_action.seat].tile_aliases
          Enum.any?(discards, fn discard -> Utils.same_tile(tile, discard, tile_aliases) end)
        else false end
      "called_tile_matches_any_discard" ->
        if last_call_action != nil do
          tile = last_call_action.called_tile
          discards = Enum.flat_map(state.players, fn {_seat, player} -> player.pond end)
          tile_aliases = state.players[context.seat].tile_aliases
          Enum.any?(discards, fn discard -> Utils.same_tile(tile, discard, tile_aliases) end)
        else false end
      "last_discard_exists" ->
        last_discard_action != nil && last_discard_action.tile == Enum.at(state.players[last_discard_action.seat].pond, -1)
      "first_time_finished_second_row_discards" -> state.saki.just_finished_second_row_discards
      "call_would_change_waits" ->
        win_definitions = translate_match_definitions(state, opts)
        hand = cxt_player.hand
        draw = cxt_player.draw
        calls = cxt_player.calls
        ordering = cxt_player.tile_ordering
        ordering_r = cxt_player.tile_ordering_r
        tile_aliases = cxt_player.tile_aliases
        tile_mappings = cxt_player.tile_mappings
        waits = Riichi.get_waits(hand, calls, win_definitions, ordering, ordering_r, tile_aliases)
        Enum.all?(Riichi.make_calls(context.calls_spec, hand ++ draw, ordering, ordering_r, [], tile_aliases, tile_mappings), fn {called_tile, call_choices} ->
          Enum.all?(call_choices, fn call_choice ->
            call_tiles = [called_tile | call_choice]
            call = {context.call_name, Enum.map(call_tiles, fn tile -> {tile, false} end)}
            waits_after_call = Riichi.get_waits((hand ++ draw) -- call_tiles, calls ++ [call], win_definitions, ordering, ordering_r, tile_aliases)
            # IO.puts("call: #{inspect(call)}")
            # IO.puts("waits: #{inspect(waits)}")
            # IO.puts("waits after call: #{inspect(waits_after_call)}")
            Enum.sort(waits) != Enum.sort(waits_after_call)
          end)
        end)
        # %{seat: seat, calls_spec: calls_spec, upgrade_name: upgrades, call_wraps: call_wraps})
      "call_changes_waits" ->
        win_definitions = translate_match_definitions(state, opts)
        ordering = cxt_player.tile_ordering
        ordering_r = cxt_player.tile_ordering_r
        tile_aliases = cxt_player.tile_aliases
        hand = cxt_player.hand
        draw = cxt_player.draw
        calls = cxt_player.calls
        call_tiles = [context.called_tile | context.call_choice]
        call = {context.call_name, Enum.map(call_tiles, fn tile -> {tile, false} end)}
        waits = Riichi.get_waits(hand, calls, win_definitions, ordering, ordering_r, tile_aliases)
        waits_after_call = Riichi.get_waits((hand ++ draw) -- call_tiles, calls ++ [call], win_definitions, ordering, ordering_r, tile_aliases)
        # IO.puts("call: #{inspect(call)}")
        # IO.puts("waits: #{inspect(waits)}")
        # IO.puts("waits after call: #{inspect(waits_after_call)}")
        Enum.sort(waits) != Enum.sort(waits_after_call)
      "wait_count_at_least" ->
        number = Enum.at(opts, 0, 1)
        win_definitions = translate_match_definitions(state, Enum.at(opts, 1, []))
        ordering = cxt_player.tile_ordering
        ordering_r = cxt_player.tile_ordering_r
        tile_aliases = cxt_player.tile_aliases
        hand = cxt_player.hand
        calls = cxt_player.calls
        waits = Riichi.get_waits(hand, calls, win_definitions, ordering, ordering_r, tile_aliases)
        length(waits) >= number
      "wait_count_at_most" ->
        number = Enum.at(opts, 0, 1)
        win_definitions = translate_match_definitions(state, Enum.at(opts, 1, []))
        ordering = cxt_player.tile_ordering
        ordering_r = cxt_player.tile_ordering_r
        tile_aliases = cxt_player.tile_aliases
        hand = cxt_player.hand
        calls = cxt_player.calls
        waits = Riichi.get_waits(hand, calls, win_definitions, ordering, ordering_r, tile_aliases)
        length(waits) <= number
      "call_contains" ->
        tiles = Enum.at(opts, 0, []) |> Enum.map(&Utils.to_tile(&1))
        count = Enum.at(opts, 1, 1)
        called_tiles = [context.called_tile] ++ context.call_choice
        Enum.count(called_tiles, fn tile -> tile in tiles end) >= count
      "called_tile_contains" ->
        tiles = Enum.at(opts, 0, []) |> Enum.map(&Utils.to_tile(&1))
        count = Enum.at(opts, 1, 1)
        called_tiles = [context.called_tile]
        Enum.count(called_tiles, fn tile -> tile in tiles end) >= count
      "call_choice_contains" ->
        tiles = Enum.at(opts, 0, []) |> Enum.map(&Utils.to_tile(&1))
        count = Enum.at(opts, 1, 1)
        called_tiles = context.call_choice
        Enum.count(called_tiles, fn tile -> tile in tiles end) >= count
      "tagged"              ->
        targets = case Enum.at(opts, 0, "tile") do
          "last_discard" -> if last_discard_action != nil do [last_discard_action.tile] else [] end
          _ -> [context.tile]
        end
        tag = Enum.at(opts, 1, "missing_tag")
        tagged_tile = state.tags[tag]
        tile_aliases = state.players[context.seat].tile_aliases
        Enum.any?(targets, fn target -> Utils.same_tile(target, tagged_tile, tile_aliases) end)
      "has_hell_wait" ->
        hand = cxt_player.hand
        calls = cxt_player.calls
        wait_definitions = translate_match_definitions(state, opts)
        ordering = cxt_player.tile_ordering
        ordering_r = cxt_player.tile_ordering_r
        tile_aliases = cxt_player.tile_aliases
        pair_waits = Enum.flat_map(wait_definitions, fn definition -> Riichi.remove_match_definition(hand, calls, definition, ordering, ordering_r, tile_aliases) end)
        |> Enum.flat_map(fn {hand, _calls} -> hand end)
        visible_ponds = Enum.flat_map(state.players, fn {_seat, player} -> player.pond end)
        visible_calls = Enum.flat_map(state.players, fn {_seat, player} -> player.calls end)
        ukeire = Riichi.count_ukeire(pair_waits, hand, visible_ponds, visible_calls, context.winning_tile, tile_aliases)
        # IO.puts("Pair waits: #{inspect(pair_waits)}, ukeire: #{inspect(ukeire)}")
        ukeire == 1
      "third_row_discard"   -> length(cxt_player.pond) >= 12
      "tiles_in_hand"       -> length(cxt_player.hand ++ cxt_player.draw) == Enum.at(opts, 0, 0)
      "anyone"              -> Enum.any?(state.players, fn {seat, _player} -> check_cnf_condition(state, opts, %{seat: seat}) end)
      _                     ->
        IO.puts "Unhandled condition #{inspect(cond_spec)}"
        false
    end
    # if Map.has_key?(context, :tile) do
    #   IO.puts("#{context.tile}, #{if negated do "not" else "" end} #{inspect(cond_spec)} => #{result}")
    # end
    # IO.puts("#{inspect(context)}, #{if negated do "not" else "" end} #{inspect(cond_spec)} => #{result}")
    if negated do not result else result end
  end

  def check_dnf_condition(state, cond_spec, context \\ %{}) do
    cond do
      is_binary(cond_spec) -> check_condition(state, cond_spec, context)
      is_map(cond_spec)    -> check_condition(state, cond_spec["name"], context, cond_spec["opts"])
      is_list(cond_spec)   -> Enum.any?(cond_spec, &check_cnf_condition(state, &1, context))
      true                 ->
        IO.puts "Unhandled condition clause #{inspect(cond_spec)}"
        true
    end
  end

  def check_cnf_condition(state, cond_spec, context \\ %{}) do
    cond do
      is_binary(cond_spec) -> check_condition(state, cond_spec, context)
      is_map(cond_spec)    -> check_condition(state, cond_spec["name"], context, cond_spec["opts"])
      is_list(cond_spec)   -> Enum.all?(cond_spec, &check_dnf_condition(state, &1, context))
      true                 ->
        IO.puts "Unhandled condition clause #{inspect(cond_spec)}"
        true
    end
  end

  def push_message(state, message) do
    for {_seat, messages_state} <- state.messages_states, messages_state != nil do
      # IO.puts("Sending to #{inspect(messages_state)} the message #{inspect(message)}")
      GenServer.cast(messages_state, {:add_message, message})
    end
    state
  end

  def push_messages(state, messages) do
    for {_seat, messages_state} <- state.messages_states, messages_state != nil do
      # IO.puts("Sending to #{inspect(messages_state)} the messages #{inspect(messages)}")
      GenServer.cast(messages_state, {:add_messages, messages})
    end
    state
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
      state = push_message(state, %{text: "Player #{socket.assigns.nickname} joined as #{seat}"})

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
    state = push_message(state, %{text: "Player #{seat} #{state.players[seat].nickname} exited"})

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

  def handle_call({:is_playable, seat, tile, tile_source}, _from, state), do: {:reply, is_playable?(state, seat, tile, tile_source), state}
  def handle_call({:get_button_display_name, button_name}, _from, state), do: {:reply, if button_name == "skip" do "Skip" else state.rules["buttons"][button_name]["display_name"] end, state}
  def handle_call({:get_auto_button_display_name, button_name}, _from, state), do: {:reply, state.rules["auto_buttons"][button_name]["display_name"], state}

  # the AI calls these to figure out if it's allowed to play
  # (this is since they operate on a delay, so state may have changed between when they were
  # notified and when they decide to act)
  def handle_call({:can_discard, seat}, _from, state) do
    our_turn = seat == state.turn
    last_discard_action = get_last_discard_action(state)
    turn_just_discarded = last_discard_action != nil && last_discard_action.seat == state.turn
    extra_turn = "extra_turn" in state.players[state.turn].status
    {:reply, our_turn && (not turn_just_discarded || extra_turn), state}
  end

  # marking calls
  def handle_call({:needs_marking?, seat}, _from, state), do: {:reply, Marking.needs_marking?(state, seat), state}
  def handle_call({:is_marked?, marking_player, seat, index, tile_source}, _from, state), do: {:reply, Marking.is_marked?(state, marking_player, seat, index, tile_source), state}
  def handle_call({:can_mark?, marking_player, seat, index, tile_source}, _from, state), do: {:reply, Marking.can_mark?(state, marking_player, seat, index, tile_source), state}

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
  def handle_cast({:unpause, actions, context}, state) do
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
    tile_source = if index < length(state.players[seat].hand) do :hand else :draw end
    playable = is_playable?(state, seat, tile, tile_source)
    if not playable do
      IO.puts("#{seat} tried to play an unplayable tile: #{tile} from #{tile_source}")
    end
    state = if state.turn == seat && playable && state.play_tile_debounce[seat] == false do
      state = Actions.temp_disable_play_tile(state, seat)
      # assume we're skipping our button choices
      state = update_player(state, seat, &%Player{ &1 | buttons: [], button_choices: %{}, call_buttons: %{}, call_name: "" })
      actions = [["play_tile", tile, index], ["advance_turn"]]
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
    state = update_player(state, seat, fn player -> %Player{ player | buttons: Buttons.to_buttons(state, player.button_choices), call_buttons: %{}, deferred_actions: [] } end)
    notify_ai(state)

    state = broadcast_state_change(state)
    {:noreply, state}
  end

  # clicking the compass will send this
  # ai also sends this once they initialize
  def handle_cast(:notify_ai, state) do
    notify_ai(state)
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
  def handle_cast({:mark_tile, marking_player, seat, index, tile_source}, state) do
    state = Marking.mark_tile(state, marking_player, seat, index, tile_source)
    state = if not Marking.needs_marking?(state, marking_player) do
      state = Actions.run_deferred_actions(state, %{seat: marking_player})
      # only reset marking if the mark action states that it is done
      state = if state.marking[marking_player].done do
        Marking.reset_marking(state, marking_player)
      else state end

      # if we're still going, run deferred actions for everyone and then notify ai
      state = if state.game_active do
        state = for {seat, _player} <- state.players, reduce: state do
          state ->
            state = Actions.run_deferred_actions(state, %{seat: seat})
            state = if not Enum.empty?(state.marking[seat]) && state.marking[seat].done do
              Marking.reset_marking(state, seat)
            else state end
            state
        end
        notify_ai(state)
        state
      else state end

      state
    else state end
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
    state = update_player(state, seat, fn player -> %Player{ player | deferred_actions: [] } end)
    notify_ai(state)

    state = broadcast_state_change(state)
    {:noreply, state}
  end
end
