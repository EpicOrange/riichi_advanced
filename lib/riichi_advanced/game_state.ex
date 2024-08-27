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
    auto_buttons: [],
    call_buttons: %{},
    call_name: "",
    tile_aliases: %{},
    choice: nil,
    chosen_actions: nil,
    deferred_actions: [],
    big_text: "",
    status: [],
    riichi_stick: false,
    hand_revealed: false,
    last_discard: nil, # for animation purposes only
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
    # pids
    supervisor: nil,
    mutex: nil,
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

    # working game state (reset on new round)
    turn: :east,
    wall_index: 0,
    actions: [],
    dead_wall: [],
    reversed_turn_order: false,
    reserved_tiles: [],
    revealed_tiles: [],
    max_revealed_tiles: 0,
    drawn_reserved_tiles: []
  ]
  use Accessible
end

defmodule RiichiAdvanced.GameState do
  alias RiichiAdvanced.GameState.Actions, as: Actions
  alias RiichiAdvanced.GameState.Buttons, as: Buttons
  alias RiichiAdvanced.GameState.Debug, as: Debug
  alias RiichiAdvanced.GameState.Saki, as: Saki
  alias RiichiAdvanced.GameState.Scoring, as: Scoring
  use GenServer

  def start_link(init_data) do
    IO.puts("Supervisor PID is #{inspect(self())}")
    GenServer.start_link(
      __MODULE__,
      %{session_id: Keyword.get(init_data, :session_id),
        ruleset: Keyword.get(init_data, :ruleset)},
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
    ruleset_json = case File.read(Application.app_dir(:riichi_advanced, "/priv/static/rulesets/#{state.ruleset <> ".json"}")) do
      {:ok, ruleset_json} -> ruleset_json
      {:error, _err}      -> nil
    end

    # put params, debouncers, and process ids into state
    state = Map.merge(state, %Game{
      ruleset: state.ruleset,
      session_id: state.session_id,
      ruleset_json: ruleset_json,
      supervisor: supervisor,
      mutex: mutex,
      ai_supervisor: ai_supervisor,
      exit_monitor: exit_monitor,
      play_tile_debounce: %{:east => false, :south => false, :west => false, :north => false},
      play_tile_debouncers: play_tile_debouncers,
      big_text_debouncers: big_text_debouncers,
      timer_debouncer: timer_debouncer
    })

    # decode the rules json
    {state, rules} = try do
      case Jason.decode(ruleset_json) do
        {:ok, rules} -> {state, rules}
        {:error, err} ->
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

    if not Map.has_key?(rules, "wall") do
      show_error(state, """
      Expected rules file to have key \"wall\".

      This should be an array listing out all the tiles contained in the
      wall. Each tile is a string, like "3m". See the documentation for
      more info.
      """)
    else
      wall = Enum.map(rules["wall"], &Utils.to_tile(&1))
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
      state = if Map.has_key?(rules, "reserved_tiles") do
        reserved_tile_names = rules["reserved_tiles"]
        {wall, dead_wall} = Enum.split(wall, -length(reserved_tile_names))
        reserved_tiles = Enum.zip(reserved_tile_names, dead_wall)
        revealed_tiles = if Map.has_key?(rules, "revealed_tiles") do rules["revealed_tiles"] else [] end
        max_revealed_tiles = if Map.has_key?(rules, "max_revealed_tiles") do rules["max_revealed_tiles"] else 0 end
        state 
        |> Map.put(:wall, wall)
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

      # initialize auto buttons
      initial_auto_buttons = for {name, auto_button} <- Map.get(rules, "auto_buttons", []) do
        {name, auto_button["enabled_at_start"]}
      end

      # statuses to keep between rounds
      persistent_statuses = if Map.has_key?(rules, "persistent_statuses") do rules["persistent_statuses"] else [] end
      IO.inspect(persistent_statuses)

      state = state
       |> Map.put(:wall_index, starting_tiles*4)
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
  end

  def win(state, seat, winning_tile, win_source) do
    state = Map.put(state, :round_result, :win)

    # run before_win actions
    state = if Map.has_key?(state.rules, "before_win") do
      Actions.run_actions(state, state.rules["before_win"]["actions"], %{seat: seat, winning_tile: winning_tile, win_source: win_source})
    else state end

    state = update_all_players(state, fn _seat, player -> %Player{ player | last_discard: nil } end)
    state = Map.put(state, :game_active, false)
    state = Map.put(state, :timer, 10)
    state = Map.put(state, :visible_screen, :winner)
    state = update_all_players(state, fn seat, player -> %Player{ player | ready: is_pid(Map.get(state, seat)) } end)
    Debounce.apply(state.timer_debouncer)

    call_tiles = Enum.flat_map(state.players[seat].calls, &Riichi.call_to_tiles/1)
    winning_hand = state.players[seat].hand ++ call_tiles ++ [winning_tile]
    # add this to the state so yaku conditions can refer to the winner
    winner = %{
      seat: seat,
      player: state.players[seat],
      winning_hand: winning_hand,
      winning_tile: winning_tile,
      win_source: win_source,
      point_name: state.rules["point_name"]
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
    state = case scoring_table["method"] do
      "riichi" ->
        wraps = "wrapping_fu_calculation" in state.players[seat].status
        minipoints = Riichi.calculate_fu(state.players[seat].hand, state.players[seat].calls, winning_tile, win_source, Riichi.get_seat_wind(state.kyoku, seat), Riichi.get_round_wind(state.kyoku), state.players[seat].tile_aliases, wraps)
        yaku = Scoring.get_yaku(state, state.rules["yaku"] ++ state.rules["extra_yaku"], seat, winning_tile, win_source, minipoints)
        {minipoints, yaku} = if Map.has_key?(state, :saki) && win_source == :draw && :draw in Enum.concat(Map.values(state.players[seat].tile_aliases)) do
          # if :draw maps to some other tiles, use :draw instead as our winning tile to calculate fu/yaku
          winning_tile = :draw
          minipoints = Riichi.calculate_fu(state.players[seat].hand, state.players[seat].calls, winning_tile, win_source, Riichi.get_seat_wind(state.kyoku, seat), Riichi.get_round_wind(state.kyoku), state.players[seat].tile_aliases, wraps)
          state2 = update_player(state, seat, &%Player{ &1 | draw: [:draw] })
          yaku = Scoring.get_yaku(state2, state.rules["yaku"] ++ state.rules["extra_yaku"], seat, winning_tile, win_source, minipoints)
          {minipoints, yaku}
        else {minipoints, yaku} end
        yaku = if Map.has_key?(state.rules, "meta_yaku") do
          Scoring.get_yaku(state, state.rules["meta_yaku"], seat, winning_tile, win_source, minipoints, yaku)
        else yaku end
        yakuman = Scoring.get_yaku(state, state.rules["yakuman"], seat, winning_tile, win_source, minipoints)
        {score, points, yakuman_mult} = Scoring.score_yaku(state, seat, yaku, yakuman, win_source == :draw, minipoints)
        IO.puts("won by #{win_source}; hand: #{inspect(winning_hand)}, yaku: #{inspect(yaku)}")
        han = Integer.to_string(points)
        score_name = Map.get(scoring_table["limit_hand_names"], han, scoring_table["limit_hand_names"]["max"])
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
          yaku: yaku,
          yakuman: yakuman,
          points: points,
          yakuman_mult: yakuman_mult,
          score: score,
          score_name: score_name,
          minipoints: minipoints,
          payer: payer,
          pao_seat: pao_seat
        })
        state = Map.update!(state, :winners, &Map.put(&1, seat, winner))
        state
      "hk" ->
        yaku = Scoring.get_yaku(state, state.rules["yaku"], seat, winning_tile, win_source)
        {score, points, _} = Scoring.score_yaku(state, seat, yaku, [], win_source == :draw)
        payer = case win_source do
          :draw    -> nil
          :discard -> get_last_discard_action(state).seat
          :call    -> get_last_call_action(state).seat
        end
        winner = Map.merge(winner, %{
          yaku: yaku,
          points: points,
          score: score,
          payer: payer
        })
        state = Map.update!(state, :winners, &Map.put(&1, seat, winner))
        state
      "sichuan" ->
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
          points: points,
          score: score,
          payer: payer
        })
        state = Map.update!(state, :winners, &Map.put(&1, seat, winner))

        # only end the round once there are three winners; otherwise, continue
        state = Map.put(state, :round_result, if map_size(state.winners) == 3 do :win else :continue end)
        state
      _ ->
        state = show_error(state, "Unknown scoring method #{inspect(scoring_table["method"])}")
        state
    end

    state
  end

  def exhaustive_draw(state) do
    state = Map.put(state, :round_result, :draw)

    # run before_exhaustive_draw actions
    state = if Map.has_key?(state.rules, "before_exhaustive_draw") do
      Actions.run_actions(state, state.rules["before_exhaustive_draw"]["actions"], %{seat: state.turn})
    else state end

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

        # finish or initialize new round if needed, otherwise continue
        state = if state.round_result != :continue do
          if Map.has_key?(state.rules, "max_rounds") && state.kyoku >= state.rules["max_rounds"] do
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
          IO.inspect({tile_name, Enum.find_index(state.reserved_tiles, fn {name, _tile} -> name == tile_name end), length(state.reserved_tiles)})
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
      if is_pid(Map.get(state, seat)) && Map.has_key?(state, :saki) && Saki.needs_marking?(state, seat) do
        # IO.puts("Notifying #{seat} AI about marking")
        send(Map.get(state, seat), {:mark_tiles, %{player: state.players[seat], marked_objects: state.saki.marked_objects}})
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
          if is_pid(Map.get(state, seat)) && has_buttons do
            # IO.puts("Notifying #{seat} AI about their buttons: #{inspect(state.players[seat].buttons)}")
            send(Map.get(state, seat), {:buttons, %{player: state.players[seat]}})
          end
        end)
      end
    end
  end

  defp get_hand_definition(state, name) do
    # TODO deprecated
    if Map.has_key?(state.rules, "set_definitions") do
      translate_hand_definition(state.rules[name], state.rules["set_definitions"])
    else
      state.rules[name]
    end
  end

  defp translate_hand_definition(hand_definitions, set_definitions) do
    # TODO deprecated
    for hand_def <- hand_definitions do
      for [groups, num] <- hand_def do
        translated_groups = for group <- groups, do: (if Map.has_key?(set_definitions, group) do set_definitions[group] else group end)
        [translated_groups, num]
      end
    end
  end

  defp translate_sets_in_match_definitions(match_definitions, set_definitions) do
    for match_definition <- match_definitions do
      for [groups, num] <- match_definition do
        translated_groups = for group <- groups, do: (if Map.has_key?(set_definitions, group) do set_definitions[group] else group end)
        [translated_groups, num]
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
  # Named sets can be found in the key "set_definitions".
  # This function simply swaps out all names for their respective definitions.
  # 
  # Example of a list of match definitions representing a winning hand:
  # [
  #   [[["shuntsu", "koutsu"], 4], [["pair"], 1]],
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
    result = case cond_spec do
      "true"                        -> true
      "false"                       -> false
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
      "call_available"              -> last_action != nil && last_action.action == :discard && Riichi.can_call?(context.calls_spec, state.players[context.seat].hand, [last_action.tile], context.call_wraps)
      "self_call_available"         -> Riichi.can_call?(context.calls_spec, state.players[context.seat].hand ++ state.players[context.seat].draw)
      "can_upgrade_call"            -> state.players[context.seat].calls
        |> Enum.filter(fn {name, _call} -> name == context.upgrade_name end)
        |> Enum.any?(fn {_name, call} ->
          call_tiles = Enum.map(call, fn {tile, _sideways} -> tile end)
          Riichi.can_call?(context.calls_spec, call_tiles, state.players[context.seat].hand ++ state.players[context.seat].draw)
        end)
      "has_draw"                 -> not Enum.empty?(state.players[context.seat].draw)
      "furiten"                  -> false
      # TODO consolidate these
      "has_yaku_with_hand"       -> if not Enum.empty?(state.players[context.seat].draw) do
          winning_tile = Enum.at(state.players[context.seat].draw, 0)
          wraps = "wrapping_fu_calculation" in state.players[context.seat].status
          minipoints = Riichi.calculate_fu(state.players[context.seat].hand, state.players[context.seat].calls, winning_tile, :draw, Riichi.get_seat_wind(state.kyoku, context.seat), Riichi.get_round_wind(state.kyoku), state.players[context.seat].tile_aliases, wraps)
          Enum.any?(state.rules["yaku"], fn yaku -> not Enum.empty?(Scoring.get_yaku(state, [yaku], context.seat, winning_tile, :draw, minipoints)) end)
        else false end
      "has_yaku_with_discard"    -> if last_action.action == :discard do
          winning_tile = last_action.tile
          wraps = "wrapping_fu_calculation" in state.players[context.seat].status
          minipoints = Riichi.calculate_fu(state.players[context.seat].hand, state.players[context.seat].calls, winning_tile, :discard, Riichi.get_seat_wind(state.kyoku, context.seat), Riichi.get_round_wind(state.kyoku), state.players[context.seat].tile_aliases, wraps)
          Enum.any?(state.rules["yaku"], fn yaku -> not Enum.empty?(Scoring.get_yaku(state, [yaku], context.seat, winning_tile, :discard, minipoints)) end)
        else false end
      "has_yaku_with_call"       -> if last_action.action == :call do
          winning_tile = last_action.tile
          wraps = "wrapping_fu_calculation" in state.players[context.seat].status
          minipoints = Riichi.calculate_fu(state.players[context.seat].hand, state.players[context.seat].calls, winning_tile, :discard, Riichi.get_seat_wind(state.kyoku, context.seat), Riichi.get_round_wind(state.kyoku), state.players[context.seat].tile_aliases, wraps)
          Enum.any?(state.rules["yaku"], fn yaku -> not Enum.empty?(Scoring.get_yaku(state, [yaku], context.seat, winning_tile, :discard, minipoints)) end)
        else false end
      "has_yakuman_with_hand"    -> if not Enum.empty?(state.players[context.seat].draw) do
          winning_tile = Enum.at(state.players[context.seat].draw, 0)
          wraps = "wrapping_fu_calculation" in state.players[context.seat].status
          minipoints = Riichi.calculate_fu(state.players[context.seat].hand, state.players[context.seat].calls, winning_tile, :draw, Riichi.get_seat_wind(state.kyoku, context.seat), Riichi.get_round_wind(state.kyoku), state.players[context.seat].tile_aliases, wraps)
          Enum.any?(state.rules["yakuman"], fn yaku -> not Enum.empty?(Scoring.get_yaku(state, [yaku], context.seat, winning_tile, :draw, minipoints)) end)
        else false end
      "has_yakuman_with_discard" -> if last_action.action == :discard do
          winning_tile = last_action.tile
          wraps = "wrapping_fu_calculation" in state.players[context.seat].status
          minipoints = Riichi.calculate_fu(state.players[context.seat].hand, state.players[context.seat].calls, winning_tile, :discard, Riichi.get_seat_wind(state.kyoku, context.seat), Riichi.get_round_wind(state.kyoku), state.players[context.seat].tile_aliases, wraps)
          Enum.any?(state.rules["yakuman"], fn yaku -> not Enum.empty?(Scoring.get_yaku(state, [yaku], context.seat, winning_tile, :discard, minipoints)) end)
        else false end
      "has_yakuman_with_call"    -> if last_action.action == :call do
          winning_tile = last_action.tile
          wraps = "wrapping_fu_calculation" in state.players[context.seat].status
          minipoints = Riichi.calculate_fu(state.players[context.seat].hand, state.players[context.seat].calls, winning_tile, :discard, Riichi.get_seat_wind(state.kyoku, context.seat), Riichi.get_round_wind(state.kyoku), state.players[context.seat].tile_aliases, wraps)
          Enum.any?(state.rules["yakuman"], fn yaku -> not Enum.empty?(Scoring.get_yaku(state, [yaku], context.seat, winning_tile, :discard, minipoints)) end)
        else false end
      "last_discard_matches"     -> last_discard_action != nil && Riichi.tile_matches(opts, %{tile: last_discard_action.tile, tile2: context.tile})
      "last_called_tile_matches" -> last_action.action == :call && Riichi.tile_matches(opts, %{tile: last_action.called_tile, tile2: context.tile, call: last_call_action})
      "unneeded_for_hand"        -> Enum.any?(opts, fn name -> Riichi.not_needed_for_hand(state.players[context.seat].hand ++ state.players[context.seat].draw, state.players[context.seat].calls, context.tile, get_hand_definition(state, name <> "_definition"), state.players[context.seat].tile_aliases, false) end)
      "unneeded_for_hand_wraps"  -> Enum.any?(opts, fn name -> Riichi.not_needed_for_hand(state.players[context.seat].hand ++ state.players[context.seat].draw, state.players[context.seat].calls, context.tile, get_hand_definition(state, name <> "_definition"), state.players[context.seat].tile_aliases, true) end)
      "has_calls"                -> not Enum.empty?(state.players[context.seat].calls)
      "no_calls"                 -> Enum.empty?(state.players[context.seat].calls)
      "has_call_named"           -> Enum.all?(state.players[context.seat].calls, fn {name, _call} -> name in opts end)
      "has_no_call_named"        -> Enum.all?(state.players[context.seat].calls, fn {name, _call} -> name not in opts end)
      "won_by_call"              -> context.win_source == :call
      "won_by_draw"              -> context.win_source == :draw
      "won_by_discard"           -> context.win_source == :discard
      "status"                   -> Enum.all?(opts, fn st -> st in state.players[context.seat].status end)
      "status_missing"           -> Enum.all?(opts, fn st -> st not in state.players[context.seat].status end)
      "discarder_status"         -> last_action.action == :discard && Enum.all?(opts, fn st -> st in state.players[last_action.seat].status end)
      "shimocha_status"          -> Enum.all?(opts, fn st -> st in state.players[Utils.get_seat(context.seat, :shimocha)].status end)
      "toimen_status"            -> Enum.all?(opts, fn st -> st in state.players[Utils.get_seat(context.seat, :toimen)].status end)
      "kamicha_status"           -> Enum.all?(opts, fn st -> st in state.players[Utils.get_seat(context.seat, :kamicha)].status end)
      "others_status"            -> Enum.any?(state.players, fn {seat, player} -> Enum.all?(opts, fn st -> seat != context.seat && st in player.status end) end)
      "anyone_status"            -> Enum.any?(state.players, fn {_seat, player} -> Enum.all?(opts, fn st -> st in player.status end) end)
      "is_drawn_tile"            -> context.tile_source == :draw
      "buttons_include"          -> Enum.all?(opts, fn button_name -> button_name in state.players[context.seat].buttons end)
      "buttons_exclude"          -> Enum.all?(opts, fn button_name -> button_name not in state.players[context.seat].buttons end)
      "tile_drawn"               -> Enum.all?(opts, fn tile -> tile in state.drawn_reserved_tiles end)
      "tile_not_drawn"           -> Enum.all?(opts, fn tile -> tile not in state.drawn_reserved_tiles end)
      "tile_revealed"            -> Enum.all?(opts, fn tile -> tile in state.revealed_tiles end)
      "tile_not_revealed"        -> Enum.all?(opts, fn tile -> tile not in state.revealed_tiles end)
      "no_tiles_remaining"       -> length(state.wall) - length(state.drawn_reserved_tiles) - state.wall_index <= 0
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
      "winning_dora_count"       -> Enum.count(Riichi.normalize_red_fives(state.winners[context.seat].winning_hand), fn tile -> tile == Riichi.dora(from_tile_name(state, Enum.at(opts, 0, :"1m"))) end) == Enum.at(opts, 1, 1)
      "fu_equals"                -> context.minipoints == Enum.at(opts, 0, 20)
      "match"                    -> 
        hand_calls = get_hand_calls_spec(state, context, Enum.at(opts, 0, []))
        match_definitions = translate_match_definitions(state, Enum.at(opts, 1, []))
        tile_aliases = state.players[context.seat].tile_aliases
        Enum.any?(hand_calls, fn {hand, calls} -> Riichi.match_hand(hand, calls, match_definitions, tile_aliases) end)
      "match_simple"         -> 
        hand_calls = get_hand_calls_spec(state, context, Enum.at(opts, 0, []))
        match_definitions = translate_match_definitions(state, Enum.at(opts, 1, []))
        tile_aliases = state.players[context.seat].tile_aliases
        Enum.any?(hand_calls, fn {hand, calls} -> Riichi.match_hand_simple(hand, calls, match_definitions, tile_aliases) end)
      "match_wrapping"       -> 
        hand_calls = get_hand_calls_spec(state, context, Enum.at(opts, 0, []))
        match_definitions = translate_match_definitions(state, Enum.at(opts, 1, []))
        tile_aliases = state.players[context.seat].tile_aliases
        Enum.any?(hand_calls, fn {hand, calls} -> Riichi.match_hand(hand, calls, match_definitions, tile_aliases, true) end)
      "winning_hand_consists_of" ->
        tiles = Enum.map(opts, &Utils.to_tile/1)
        winning_hand = state.players[context.seat].hand ++ Enum.flat_map(state.players[context.seat].calls, &Riichi.call_to_tiles/1)
        Enum.all?(winning_hand, fn tile -> tile in tiles end)
      "winning_hand_and_tile_consists_of" ->
        tiles = Enum.map(opts, &Utils.to_tile/1)
        winning_hand = state.players[context.seat].hand ++ Enum.flat_map(state.players[context.seat].calls, &Riichi.call_to_tiles/1)
        winning_tile = if Map.has_key?(context, :winning_tile) do context.winning_tile else state.winners[context.seat].winning_tile end
        Enum.all?(winning_hand ++ [winning_tile], fn tile -> tile in tiles end)
      "all_saki_cards_drafted"   -> Map.has_key?(state, :saki) && state.saki.all_drafted
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
          tile = Riichi.normalize_red_five(last_discard_action.tile)
          discards = state.players[last_discard_action.seat].discards |> Riichi.normalize_red_fives() |> Enum.drop(-1)
          tile in discards
        else false end
      "called_tile_matches_any_discard" -> last_call_action != nil && Riichi.normalize_red_five(last_call_action.called_tile) in Riichi.normalize_red_fives(Enum.flat_map(state.players, fn {_seat, player} -> player.pond end))
      "last_discard_exists" ->
        last_discard_action != nil && last_discard_action.tile == Enum.at(state.players[last_discard_action.seat].pond, -1)
      "first_time_finished_second_row_discards" -> state.saki.just_finished_second_row_discards
      "call_would_change_waits" ->
        win_definitions = translate_match_definitions(state, opts)
        tile_aliases = state.players[context.seat].tile_aliases
        hand = state.players[context.seat].hand
        draw = state.players[context.seat].draw
        calls = state.players[context.seat].calls
        waits = Riichi.get_waits(hand, calls, win_definitions, tile_aliases, false)
        IO.inspect(Riichi.make_calls(context.calls_spec, hand ++ draw))
        Enum.all?(Riichi.make_calls(context.calls_spec, hand ++ draw), fn {called_tile, call_choices} ->
          Enum.all?(call_choices, fn call_choice ->
            call_tiles = [called_tile | call_choice]
            call = {context.call_name, Enum.map(call_tiles, fn tile -> {tile, false} end)}
            waits_after_call = Riichi.get_waits((hand ++ draw) -- call_tiles, calls ++ [call], win_definitions, tile_aliases, false)
            # IO.puts("call: #{inspect(call)}")
            # IO.puts("waits: #{inspect(waits)}")
            # IO.puts("waits after call: #{inspect(waits_after_call)}")
            Enum.sort(waits) != Enum.sort(waits_after_call)
          end)
        end)
        # %{seat: seat, calls_spec: calls_spec, upgrade_name: upgrades, call_wraps: call_wraps})
      "call_changes_waits" ->
        win_definitions = translate_match_definitions(state, opts)
        tile_aliases = state.players[context.seat].tile_aliases
        hand = state.players[context.seat].hand
        draw = state.players[context.seat].draw
        calls = state.players[context.seat].calls
        call_tiles = [context.called_tile | context.call_choice]
        call = {context.call_name, Enum.map(call_tiles, fn tile -> {tile, false} end)}
        waits = Riichi.get_waits(hand, calls, win_definitions, tile_aliases, false)
        waits_after_call = Riichi.get_waits((hand ++ draw) -- call_tiles, calls ++ [call], win_definitions, tile_aliases, false)
        # IO.puts("call: #{inspect(call)}")
        # IO.puts("waits: #{inspect(waits)}")
        # IO.puts("waits after call: #{inspect(waits_after_call)}")
        Enum.sort(waits) != Enum.sort(waits_after_call)
      "wait_count_at_least" ->
        number = Enum.at(opts, 0, 1)
        win_definitions = translate_match_definitions(state, Enum.at(opts, 1, []))
        tile_aliases = state.players[context.seat].tile_aliases
        hand = state.players[context.seat].hand
        calls = state.players[context.seat].calls
        waits = Riichi.get_waits(hand, calls, win_definitions, tile_aliases, false)
        length(waits) >= number
      "wait_count_at_most" ->
        number = Enum.at(opts, 0, 1)
        win_definitions = translate_match_definitions(state, Enum.at(opts, 1, []))
        tile_aliases = state.players[context.seat].tile_aliases
        hand = state.players[context.seat].hand
        calls = state.players[context.seat].calls
        waits = Riichi.get_waits(hand, calls, win_definitions, tile_aliases, false)
        length(waits) <= number
      "tagged"              ->
        tag = Enum.at(opts, 0, "missing_tag")
        tagged_tile = state.tags[tag]
        Riichi.normalize_red_five(context.tile) == Riichi.normalize_red_five(tagged_tile)
      "has_hell_pair_wait" ->
        hand = state.players[context.seat].hand
        calls = state.players[context.seat].calls
        pair_wait_definitions = translate_match_definitions(state, opts)
        tile_aliases = state.players[context.seat].tile_aliases
        pair_waits = Enum.flat_map(pair_wait_definitions, fn definition -> Riichi.remove_hand_definition(hand, calls, definition, tile_aliases, false) end)
        |> Enum.flat_map(fn {hand, _calls} -> hand end)
        visible_ponds = Enum.flat_map(state.players, fn {_seat, player} -> player.pond end)
        visible_calls = Enum.flat_map(state.players, fn {_seat, player} -> player.calls end)
        ukeire = Riichi.count_ukeire(pair_waits, hand, visible_ponds, visible_calls, context.winning_tile)
        # IO.puts("Pair waits: #{inspect(pair_waits)}, ukeire: #{inspect(ukeire)}")
        ukeire == 1
      "third_row_discard"   -> length(state.players[context.seat].pond) >= 12
      "tiles_in_hand"       -> length(state.players[context.seat].hand ++ state.players[context.seat].draw) == Enum.at(opts, 0, 0)
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

  def broadcast_state_change(state) do
    # IO.puts("broadcast_state_change called")
    RiichiAdvancedWeb.Endpoint.broadcast(state.ruleset <> ":" <> state.session_id, "state_updated", %{"state" => state})
    # reset anim
    state = update_all_players(state, fn _seat, player -> %Player{ player | last_discard: nil } end)
    state
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

      state = Map.put(state, seat, socket.id)
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
    state = update_player(state, seat, &%Player{ &1 | nickname: nil })
    IO.puts("Player #{seat} exited")
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
    {:reply, our_turn && not turn_just_discarded, state}
  end

  # saki calls
  def handle_call({:needs_marking?, seat}, _from, state), do: {:reply, Saki.needs_marking?(state, seat), state}
  def handle_call({:is_marked, seat, index, tile_source}, _from, state), do: {:reply, Saki.is_marked(state, seat, index, tile_source), state}
  def handle_call({:can_mark, seat, index, tile_source}, _from, state), do: {:reply, Saki.can_mark(state, seat, index, tile_source), state}

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
      state = update_player(state, seat, &%Player{ &1 | buttons: [], call_buttons: %{}, call_name: "" })
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

  # def handle_cast({:cancel_call_buttons, seat}, state) do
  #   state = update_all_players(state, fn seat, player -> %Player{ player | call_buttons: [] } end)

  #   # go back to button clicking phase
  #   state = Buttons.recalculate_buttons(state)
  #   state = update_player(state, seat, fn player -> %Player{ player | deferred_actions: [] } end)
  #   notify_ai(state)

  #   state = broadcast_state_change(state)
  #   {:noreply, state}
  # end

  # clicking the compass will send this
  # ai also sends this once they initialize
  def handle_cast(:notify_ai, state) do
    state = Buttons.recalculate_buttons(state)
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

  # saki calls
  def handle_cast({:mark_tile, seat, index, tile_source}, state) do
    state = Saki.mark_tile(state, seat, index, tile_source)
    state = if not Saki.needs_marking?(state, state.saki.marking_player) do
      state = Actions.run_deferred_actions(state, %{seat: state.saki.marking_player, marked_objects: state.saki.marked_objects})
      state = Saki.reset_marking(state)

      # if we're still going, run deferred actions for everyone and then notify ai
      state = if state.game_active do
        state = for {seat, _player} <- state.players, reduce: state do
          state -> Actions.run_deferred_actions(state, %{seat: seat})
        end
        notify_ai(state)
        state
      else state end

      state
    else state end
    state = broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast(:clear_marked_objects, state) do
    state = Saki.clear_marked_objects(state)
    state = broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast({:reset_marking, seat}, state) do
    state = Saki.reset_marking(state)

    # go back to button clicking phase
    state = Buttons.recalculate_buttons(state)
    state = update_player(state, seat, fn player -> %Player{ player | deferred_actions: [] } end)
    notify_ai(state)

    state = broadcast_state_change(state)
    {:noreply, state}
  end
end
