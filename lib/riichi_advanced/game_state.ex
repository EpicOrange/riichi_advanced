defmodule Player do
  defstruct [
    hand: [],
    draw: [],
    pond: [],
    discards: [],
    calls: [],
    score: 0,
    buttons: [],
    auto_buttons: [],
    call_buttons: %{},
    call_name: "",
    choice: nil,
    chosen_actions: nil,
    deferred_actions: [],
    nickname: nil,
    big_text: "",
    status: [],
    riichi_stick: false,
    hand_revealed: false,
    last_discard: nil, # for animation purposes only
    ready: false
  ]
end

defmodule RiichiAdvanced.GameState do
  use GenServer

  def start_link(init_data) do
    IO.puts("Supervisor PID is #{inspect(self())}")
    GenServer.start_link(
      __MODULE__,
      %{session_id: Keyword.get(init_data, :session_id),
        ruleset: Keyword.get(init_data, :ruleset),
        ruleset_json: Keyword.get(init_data, :ruleset_json)},
      name: Keyword.get(init_data, :name))
  end

  defp debounce_worker(debouncers, delay, message, id) do
    DynamicSupervisor.start_child(debouncers, %{
      id: id,
      start: {Debounce, :start_link, [{GenServer, :cast, [self(), message]}, delay]},
      type: :worker,
      restart: :transient
    })
  end
  defp debounce_worker(debouncers, delay, message, id, seat) do
    DynamicSupervisor.start_child(debouncers, %{
      id: id,
      start: {Debounce, :start_link, [{GenServer, :cast, [self(), {message, seat}]}, delay]},
      type: :worker,
      restart: :transient
    })
  end

  def init(state) do
    IO.puts("Game state PID is #{inspect(self())}")
    play_tile_debounce = %{:east => false, :south => false, :west => false, :north => false}
    [{debouncers, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("debouncers", state.ruleset, state.session_id))
    {:ok, play_tile_debouncer_east} = debounce_worker(debouncers, 100, :reset_play_tile_debounce, :play_tile_debouncer_east, :east)
    {:ok, play_tile_debouncer_south} = debounce_worker(debouncers, 100, :reset_play_tile_debounce, :play_tile_debouncer_south, :south)
    {:ok, play_tile_debouncer_west} = debounce_worker(debouncers, 100, :reset_play_tile_debounce, :play_tile_debouncer_west, :west)
    {:ok, play_tile_debouncer_north} = debounce_worker(debouncers, 100, :reset_play_tile_debounce, :play_tile_debouncer_north, :north)
    {:ok, big_text_debouncer_east} = debounce_worker(debouncers, 1500, :reset_big_text, :big_text_debouncer_east, :east)
    {:ok, big_text_debouncer_south} = debounce_worker(debouncers, 1500, :reset_big_text, :big_text_debouncer_south, :south)
    {:ok, big_text_debouncer_west} = debounce_worker(debouncers, 1500, :reset_big_text, :big_text_debouncer_west, :west)
    {:ok, big_text_debouncer_north} = debounce_worker(debouncers, 1500, :reset_big_text, :big_text_debouncer_north, :north)
    {:ok, timer_debouncer} = debounce_worker(debouncers, 1000, :tick_timer, :timer_debouncer)
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
    [{supervisor, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("game", state.ruleset, state.session_id))
    [{mutex, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("mutex", state.ruleset, state.session_id))
    [{ai_supervisor, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("ai_supervisor", state.ruleset, state.session_id))
    [{exit_monitor, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("exit_monitor", state.ruleset, state.session_id))
    state = Map.merge(state, %{
      players: Map.new([:east, :south, :west, :north], fn seat -> {seat, %Player{}} end),
      game_active: false,
      supervisor: supervisor,
      mutex: mutex,
      ai_supervisor: ai_supervisor,
      exit_monitor: exit_monitor,
      play_tile_debounce: play_tile_debounce,
      play_tile_debouncers: play_tile_debouncers,
      big_text_debouncers: big_text_debouncers,
      timer_debouncer: timer_debouncer,
      visible_screen: nil,
      error: nil,
    })

    {state, rules} = try do
      case Jason.decode(state.ruleset_json) do
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

    state = state
     |> Map.put(:players, Map.new([:east, :south, :west, :north], fn seat -> {seat, %Player{ score: initial_score }} end))
     |> Map.put(:east, nil)
     |> Map.put(:south, nil)
     |> Map.put(:west, nil)
     |> Map.put(:north, nil)
     |> Map.put(:kyoku, 0)
     |> Map.put(:honba, 0)
     |> Map.put(:riichi_sticks, 0)
     |> Map.put(:wall, [])
     |> Map.put(:turn, :east)
     |> Map.put(:wall_index, 0)
     |> Map.put(:actions, [])
     |> Map.put(:reversed_turn_order, false)
     |> Map.put(:round_result, nil)
     |> Map.put(:winners, %{})
     |> Map.put(:winner_index, 0)
     |> Map.put(:delta_scores, nil)
     |> Map.put(:delta_scores_reason, nil)
     |> Map.put(:dealer_continuation, false)
     |> Map.put(:timer, 0)
     |> Map.put(:actions_cv, 0) # condition variable
     |> Map.put(:reserved_tiles, [])
     |> Map.put(:revealed_tiles, [])
     |> Map.put(:max_revealed_tiles, 0)
     |> Map.put(:drawn_reserved_tiles, [])
    state = initialize_new_round(state)

    {:ok, state}
  end

  def update_player(state, seat, fun), do: Map.update!(state, :players, &Map.update!(&1, seat, fun))
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

  defp temp_disable_play_tile(state, seat) do
    state = Map.update!(state, :play_tile_debounce, &Map.put(&1, seat, true))
    Debounce.apply(state.play_tile_debouncers[seat])
    state
  end

  defp temp_display_big_text(state, seat, text) do
    state = update_player(state, seat, &%Player{ &1 | big_text: text })
    Debounce.apply(state.big_text_debouncers[seat])
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
      starting_tiles = if Map.has_key?(rules, "starting_tiles") do rules["starting_tiles"] else 0 end
      hands = if starting_tiles > 0 do
        %{:east  => Enum.slice(wall, 0..(starting_tiles-1)),
          :south => Enum.slice(wall, starting_tiles..(starting_tiles*2-1)),
          :west  => Enum.slice(wall, (starting_tiles*2)..(starting_tiles*3-1)),
          :north => Enum.slice(wall, (starting_tiles*3)..(starting_tiles*4-1))}
      else Map.new([:east, :south, :west, :north], &{&1, []}) end

      # debug use only
      # wall = List.replace_at(wall, 52, :"3p") # first draw
      # wall = List.replace_at(wall, 53, :"3p")
      # wall = List.replace_at(wall, 54, :"3p")
      # wall = List.replace_at(wall, 55, :"3p")
      # wall = List.replace_at(wall, 56, :"3p") # second draw
      # wall = List.replace_at(wall, 57, :"3p")
      # wall = List.replace_at(wall, 58, :"3p")
      # wall = List.replace_at(wall, 59, :"3p")
      # wall = List.replace_at(wall, 60, :"3p")
      # wall = List.replace_at(wall, -15, :"1m") # last draw
      # wall = List.replace_at(wall, -6, :"9m") # first dora
      # wall = List.replace_at(wall, -8, :"9m") # second dora
      # wall = List.replace_at(wall, -2, :"2z") # first kan draw
      # wall = List.replace_at(wall, -1, :"3m") # second kan draw
      # wall = List.replace_at(wall, -4, :"4m") # third kan draw
      # wall = List.replace_at(wall, -3, :"6m") # fourth kan draw
      # hands = %{:east  => Utils.sort_tiles([:"1m", :"2m", :"3m", :"2p", :"2p", :"2p", :"4p", :"5p", :"3s", :"4s", :"5s", :"8s", :"8s"]),
      #           :south => Enum.slice(wall, 13..25),
      #           :west  => Enum.slice(wall, 26..38),
      #           :north => Enum.slice(wall, 39..51)}
      # hands = %{:east  => Utils.sort_tiles([:"1p", :"2p", :"3p", :"4p", :"5p", :"6p", :"7p", :"8p", :"9p", :"6z"]),
      #           :south => Utils.sort_tiles([:"1p", :"2p", :"3p", :"4p", :"5p", :"6p", :"7p", :"8p", :"9p", :"6z"]),
      #           :west  => Utils.sort_tiles([:"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z"]),
      #           :north => Utils.sort_tiles([:"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z"])}
      # hands = %{:east  => Utils.sort_tiles([:"5z", :"5z", :"6z", :"6z", :"7z", :"7z", :"5z", :"6z", :"7z", :"1z", :"1z", :"2z", :"2z"]),
      #           :south => Utils.sort_tiles([:"5z", :"5z", :"5z", :"5z", :"5z", :"5z", :"5z", :"1z", :"1z", :"1z", :"1z", :"1z", :"1z"]),
      #           :west  => Utils.sort_tiles([:"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z"]),
      #           :north => Utils.sort_tiles([:"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z"])}
      # hands = %{:east  => Utils.sort_tiles([:"5z", :"5z", :"6z", :"6z", :"7z", :"7z", :"1m", :"1m", :"1m", :"1z", :"1z", :"2z", :"2z"]),
      #           :south => Utils.sort_tiles([:"5z", :"5z", :"5z", :"5z", :"5z", :"5z", :"5z", :"1z", :"1z", :"1z", :"1z", :"1z", :"1z"]),
      #           :west  => Utils.sort_tiles([:"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z"]),
      #           :north => Utils.sort_tiles([:"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z"])}
      # hands = %{:east  => Utils.sort_tiles([:"5z", :"5z", :"6z", :"6z", :"7z", :"7z", :"4m", :"4m", :"4m", :"5m", :"5m", :"6m", :"6m"]),
      #           :south => Utils.sort_tiles([:"5z", :"5z", :"5z", :"5z", :"5z", :"5z", :"6m", :"6m", :"6m", :"6m", :"6m", :"6m", :"6m"]),
      #           :west  => Utils.sort_tiles([:"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z"]),
      #           :north => Utils.sort_tiles([:"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z"])}
      # hands = %{:east  => Utils.sort_tiles([:"2m", :"2m", :"2m", :"3m", :"3m", :"3m", :"4m", :"4m", :"4m", :"5m", :"5m", :"6m", :"6m"]),
      #           :south => Utils.sort_tiles([:"2m", :"2m", :"2m", :"3m", :"3m", :"3m", :"4m", :"4m", :"4m", :"5m", :"5m", :"6m", :"6m"]),
      #           :west  => Utils.sort_tiles([:"2m", :"2m", :"2m", :"3m", :"3m", :"3m", :"4m", :"4m", :"4m", :"5m", :"5m", :"6m", :"6m"]),
      #           :north => Utils.sort_tiles([:"2m", :"2m", :"2m", :"3m", :"3m", :"3m", :"4m", :"4m", :"4m", :"5m", :"5m", :"6m", :"6m"])}
      # hands = %{:east  => Utils.sort_tiles([:"1p", :"2p", :"3p", :"2m", :"3m", :"5m", :"5m", :"1s", :"2s", :"3s", :"4s", :"5s", :"6s"]),
      #           :south => Utils.sort_tiles([:"1m", :"4m", :"7m", :"2p", :"5p", :"8p", :"3s", :"6s", :"9s", :"1z", :"2z", :"3z", :"4z"]),
      #           :west  => Utils.sort_tiles([:"1m", :"4m", :"7m", :"2p", :"5p", :"8p", :"3s", :"6s", :"9s", :"1z", :"2z", :"3z", :"4z"]),
      #           :north => Utils.sort_tiles([:"1m", :"4m", :"7m", :"2p", :"5p", :"8p", :"3s", :"6s", :"9s", :"1z", :"2z", :"3z", :"4z"])}
                # :south => Utils.sort_tiles([:"1z", :"1z", :"6z", :"7z", :"2z", :"2z", :"3z", :"3z", :"3z", :"4z", :"4z", :"4z", :"5z"]),
                # :south => Utils.sort_tiles([:"1m", :"2m", :"3p", :"9p", :"1s", :"9s", :"1z", :"2z", :"3z", :"4z", :"5z", :"6z", :"7z"]),
                # :west  => Utils.sort_tiles([:"1m", :"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m", :"9m", :"8p", :"8p", :"4p", :"5p"]),
                # :south => Utils.sort_tiles([:"1m", :"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m", :"9m", :"8p", :"8p", :"6p", :"7p"]),
                # :west  => Utils.sort_tiles([:"1m", :"2m", :"3m", :"2p", :"0s", :"5s", :"5s", :"5s", :"5s", :"1z", :"1z", :"1z", :"1z"]),
                # :west  => Utils.sort_tiles([:"1z", :"1z", :"6z", :"7z", :"2z", :"2z", :"3z", :"3z", :"3z", :"4z", :"4z", :"4z", :"5z"]),
                # :north => Utils.sort_tiles([:"1m", :"2m", :"2m", :"5m", :"5m", :"7m", :"7m", :"9m", :"9m", :"1z", :"1z", :"2z", :"3z"])}

      # reserve some tiles (dead wall)
      {wall, state} = if Map.has_key?(rules, "reserved_tiles") do
        reserved_tile_names = rules["reserved_tiles"]
        {wall, reserved_tiles} = Enum.split(wall, -length(reserved_tile_names))
        reserved_tiles = Enum.zip(reserved_tile_names, reserved_tiles) |> Map.new()
        revealed_tiles = if Map.has_key?(rules, "revealed_tiles") do rules["revealed_tiles"] else [] end
        max_revealed_tiles = if Map.has_key?(rules, "max_revealed_tiles") do rules["max_revealed_tiles"] else 0 end
        {wall, state 
               |> Map.put(:reserved_tiles, reserved_tiles)
               |> Map.put(:revealed_tiles, revealed_tiles)
               |> Map.put(:max_revealed_tiles, max_revealed_tiles)
               |> Map.put(:drawn_reserved_tiles, [])}
      else
        {wall, state}
      end

      # initialize auto buttons
      initial_auto_buttons = if Map.has_key?(rules, "auto_buttons") do
          Enum.map(rules["auto_buttons"], fn {name, auto_button} -> {name, auto_button["enabled_at_start"]} end) |> Enum.reverse
        else
          []
        end

      state = state
       |> Map.put(:wall, wall)
       |> Map.put(:players, Map.new(state.players, fn {seat, player} -> {seat, %Player{ player |
            hand: hands[seat],
            draw: [],
            pond: [],
            discards: [],
            calls: [],
            buttons: [],
            auto_buttons: initial_auto_buttons,
            call_buttons: %{},
            call_name: "",
            choice: nil,
            chosen_actions: nil,
            deferred_actions: [],
            big_text: "",
            status: [],
            riichi_stick: false,
            hand_revealed: false,
            last_discard: nil,
            ready: false
          }} end))
       |> Map.put(:wall_index, starting_tiles*4)
       |> Map.put(:winners, %{})
       |> Map.put(:winner_index, 0)
       |> Map.put(:delta_scores, nil)
       |> Map.put(:delta_scores_reason, nil)
       |> Map.put(:dealer_continuation, false)
       |> Map.put(:game_active, true)
       |> Map.put(:turn, nil) # so that change_turn detects a turn change
      
      state = change_turn(state, Riichi.get_east_player_seat(state.kyoku))

      # run after_start actions
      state = if Map.has_key?(state.rules, "after_start") do
        run_actions(state, state.rules["after_start"]["actions"], %{seat: state.turn})
      else state end

      state = recalculate_buttons(state)

      notify_ai(state)

      state
    end
  end

  def score_yaku(state, seat, yaku, yakuman, is_self_draw, minipoints \\ 0) do
    scoring_table = state.rules["score_calculation"]
    case scoring_table["method"] do
      "riichi" ->
        is_dealer = Riichi.get_east_player_seat(state.kyoku) == seat
        points = Enum.reduce(yaku, 0, fn {_name, value}, acc -> acc + value end)
        yakuman_mult = Enum.reduce(yakuman, 0, fn {_name, value}, acc -> acc + value end)
        han = Integer.to_string(points)
        fu = Integer.to_string(minipoints)

        oya_han_table = if is_self_draw do scoring_table["score_table_dealer_draw"] else scoring_table["score_table_dealer"] end
        ko_han_table = if is_self_draw do scoring_table["score_table_nondealer_draw"] else scoring_table["score_table_nondealer"] end
        oya_fu_table = if yakuman_mult > 0 do oya_han_table["max"] else Map.get(oya_han_table, han, oya_han_table["max"]) end
        ko_fu_table = if yakuman_mult > 0 do ko_han_table["max"] else Map.get(ko_han_table, han, ko_han_table["max"]) end

        IO.inspect({han, yakuman_mult, is_self_draw, is_dealer})
        score = if yakuman_mult == 0 do
          if is_self_draw do
            if is_dealer do
              3 * Map.get(oya_fu_table, fu, oya_fu_table["max"])
            else
              Map.get(oya_fu_table, fu, oya_fu_table["max"]) + 2 * Map.get(ko_fu_table, fu, ko_fu_table["max"])
            end
          else
            if is_dealer do
              Map.get(oya_fu_table, fu, oya_fu_table["max"])
            else
              Map.get(ko_fu_table, fu, ko_fu_table["max"])
            end
          end
        else
          if is_self_draw do
            if is_dealer do
              yakuman_mult * 3 * oya_fu_table["max"]
            else
              yakuman_mult * oya_fu_table["max"] + 2 * ko_fu_table["max"]
            end
          else
            if is_dealer do
              yakuman_mult * oya_fu_table["max"]
            else
              yakuman_mult * ko_fu_table["max"]
            end
          end
        end
        {score, points, yakuman_mult}
      "hk" ->
        is_dealer = Riichi.get_east_player_seat(state.kyoku) == seat
        points = Enum.reduce(yaku, 0, fn {_name, value}, acc -> acc + value end)
        fan = Integer.to_string(points)

        dealer_fan_table = if is_self_draw do scoring_table["score_table_dealer_draw"] else scoring_table["score_table_dealer"] end
        nondealer_fan_table = if is_self_draw do scoring_table["score_table_nondealer_draw"] else scoring_table["score_table_nondealer"] end
        dealer_payment = Map.get(dealer_fan_table, fan, dealer_fan_table["max"])
        nondealer_payment = Map.get(nondealer_fan_table, fan, nondealer_fan_table["max"])
        payment = if is_dealer do dealer_payment else nondealer_payment end

        score = payment * if is_self_draw do 3 else 4 end

        {score, points, 0}
      _ ->
        GenServer.cast(self(), {:show_error, "Unknown scoring method #{inspect(scoring_table["method"])}"})
        {0, 0, 0}
    end
  end
  def calculate_delta_scores_for_single_winner(state, winner, collect_sticks) do
    scoring_table = state.rules["score_calculation"]
    delta_scores = Map.new(state.players, fn {seat, _player} -> {seat, 0} end)
    case scoring_table["method"] do
      "riichi" ->
        {pao_yakuman, non_pao_yakuman} = Enum.split_with(winner.yakuman, fn {name, _value} -> name == "Daisangen" || name == "Daisuushii" end)
        if winner.pao_seat != nil && length(pao_yakuman) > 0 && length(non_pao_yakuman) > 0 do
          # split the calculation if both pao and non-pao yakuman exist
          {basic_score_pao, _, _} = score_yaku(state, winner.seat, [], pao_yakuman, winner.win_source == :draw, winner.minipoints)
          {basic_score_non_pao, _, _} = score_yaku(state, winner.seat, [], non_pao_yakuman, winner.win_source == :draw, winner.minipoints)
          delta_scores_pao = calculate_delta_scores_for_single_winner(state, %{ winner | score: basic_score_pao, yakuman: pao_yakuman }, collect_sticks)
          delta_scores_non_pao = calculate_delta_scores_for_single_winner(state,%{ winner | score: basic_score_non_pao, yakuman: non_pao_yakuman }, collect_sticks)
          delta_scores = Map.new(delta_scores_pao, fn {seat, delta} -> {seat, delta + delta_scores_non_pao[seat]} end)
          delta_scores
        else
          {riichi_payment, honba_payment} = if collect_sticks do
            riichi_payment = scoring_table["riichi_value"] * state.riichi_sticks
            honba_payment = scoring_table["honba_value"] * state.honba
            {riichi_payment, honba_payment}
          else
            {0, 0}
          end

          # calculate some parameters that change if pao exists
          {delta_scores, basic_score, payer, direct_hit} =
            # due to the way we handle mixed pao-and-not-pao yakuman earlier,
            # we're guaranteed either all of the yakuman are pao, or none of them are
            if winner.pao_seat != nil && length(pao_yakuman) > 0 do
              # if pao, then payer becomes the pao seat,
              # and a ron payment is split in half
              if winner.payer != nil do # ron
                # the deal-in player is not responsible for honba payments,
                # so we take care of their share of payment right here
                basic_score = trunc(winner.score / 2)
                delta_scores = Map.put(delta_scores, winner.payer, -basic_score)
                delta_scores = Map.put(delta_scores, winner.seat, basic_score)
                {delta_scores, basic_score, winner.pao_seat, true}
              else
                {delta_scores, winner.score, winner.pao_seat, true}
              end
            else
              {delta_scores, winner.score, winner.payer, winner.payer != nil}
            end

          if direct_hit do
            # either ron, or tsumo pao, or remaining ron pao payment
            delta_scores = Map.update!(delta_scores, payer, & &1 - basic_score - honba_payment * 3)
            delta_scores = Map.update!(delta_scores, winner.seat, & &1 + basic_score + honba_payment * 3 + riichi_payment)
            delta_scores
          else
            # first give the winner their riichi sticks
            delta_scores = Map.update!(delta_scores, winner.seat, & &1 + riichi_payment)
            # reverse-calculate the ko and oya parts of the total points
            is_dealer = Riichi.get_east_player_seat(state.kyoku) == winner.seat
            {ko_payment, oya_payment} = Riichi.calc_ko_oya_points(basic_score, is_dealer)
            dealer_seat = Riichi.get_east_player_seat(state.kyoku)
            # have each payer pay their allotted share
            for payer <- [:east, :south, :west, :north] -- [winner.seat], reduce: delta_scores do
              delta_scores ->
                payment = if payer == dealer_seat do oya_payment else ko_payment end
                delta_scores = Map.update!(delta_scores, payer, & &1 - payment - honba_payment)
                delta_scores = Map.update!(delta_scores, winner.seat, & &1 + payment + honba_payment)
                delta_scores
            end
          end
        end
      "hk" ->
        self_pick = winner.payer == nil
        basic_score = trunc(winner.score / if self_pick do 3 else 4 end)
        payer_seat = winner.payer
        # have each payer pay their allotted share
        for payer <- [:east, :south, :west, :north] -- [winner.seat], reduce: delta_scores do
          delta_scores ->
            payment = if payer == payer_seat do 2 * basic_score else basic_score end
            delta_scores = Map.update!(delta_scores, payer, & &1 - payment)
            delta_scores = Map.update!(delta_scores, winner.seat, & &1 + payment)
            delta_scores
        end
      _ ->
        GenServer.cast(self(), {:show_error, "Unknown scoring method #{inspect(scoring_table["method"])}"})
        delta_scores
    end
  end

  def calculate_delta_scores(state) do
    # determine the closest winner (the one who receives riichi sticks and honba)
    {_seat, some_winner} = Enum.at(state.winners, 0)
    payer = some_winner.payer
    closest_winner = if payer == nil do some_winner.seat else
      next_seat_1 = if state.reversed_turn_order do Utils.next_turn(payer) else Utils.prev_turn(payer) end
      next_seat_2 = if state.reversed_turn_order do Utils.next_turn(next_seat_1) else Utils.prev_turn(next_seat_1) end
      next_seat_3 = if state.reversed_turn_order do Utils.next_turn(next_seat_2) else Utils.prev_turn(next_seat_2) end
      next_seat_4 = if state.reversed_turn_order do Utils.next_turn(next_seat_3) else Utils.prev_turn(next_seat_3) end
      cond do
        Map.has_key?(state.winners, next_seat_1) -> next_seat_1
        Map.has_key?(state.winners, next_seat_2) -> next_seat_2
        Map.has_key?(state.winners, next_seat_3) -> next_seat_3
        Map.has_key?(state.winners, next_seat_4) -> next_seat_4
      end
    end

    # sum the individual delta scores for each winner
    for {seat, winner} <- state.winners, reduce: Map.new(state.players, fn {seat, _player} -> {seat, 0} end) do
      delta_scores_acc ->
        delta_scores = calculate_delta_scores_for_single_winner(state, winner, seat == closest_winner)
        delta_scores_acc = Map.new(delta_scores_acc, fn {seat, delta} -> {seat, delta + delta_scores[seat]} end)
        delta_scores_acc
    end
  end
  
  def adjudicate_win_scoring(state) do
    scoring_table = state.rules["score_calculation"]
    {state, delta_scores, delta_scores_reason, dealer_continuation} = case scoring_table["method"] do
      "riichi" ->
        delta_scores = calculate_delta_scores(state)

        {_seat, some_winner} = Enum.at(state.winners, 0)
        delta_scores_reason = cond do
          some_winner.pao_seat != nil  -> "Sekinin Barai"
          map_size(state.winners) == 1 -> "Ron"
          map_size(state.winners) == 2 -> "Double Ron"
          map_size(state.winners) == 3 -> "Triple Ron"
        end

        dealer_continuation = Map.has_key?(state.winners, Riichi.get_east_player_seat(state.kyoku))
        {state, delta_scores, delta_scores_reason, dealer_continuation}
      "hk" ->
        delta_scores = calculate_delta_scores(state)
        delta_scores_reason = cond do
          map_size(state.winners) == 1 -> "Hu"
          map_size(state.winners) == 2 -> "Double Hu"
          map_size(state.winners) == 3 -> "Triple Hu"
        end
        {state, delta_scores, delta_scores_reason, false}
      _ ->
        GenServer.cast(self(), {:show_error, "Unknown scoring method #{inspect(scoring_table["method"])}"})
        delta_scores = Map.new(state.players, fn {seat, _player} -> {seat, 0} end)
        state = Map.update!(state, :kyoku, & &1 + 1)
        {state, delta_scores, "", false}
    end
    {state, delta_scores, delta_scores_reason, dealer_continuation}
  end

  def adjudicate_draw_scoring(state) do
    scoring_table = state.rules["score_calculation"]
    {state, delta_scores, delta_scores_reason, dealer_continuation} = case scoring_table["method"] do
      "riichi" ->
        tenpai = Map.new(state.players, fn {seat, player} -> {seat, "tenpai" in player.status} end)
        nagashi = Map.new(state.players, fn {seat, player} -> {seat, "nagashi" in player.status} end)
        num_tenpai = tenpai |> Map.values() |> Enum.count(& &1)
        num_nagashi = nagashi |> Map.values() |> Enum.count(& &1)
        {state, delta_scores} = if num_nagashi > 0 do
          scores_before = Map.new(state.players, fn {seat, player} -> {seat, player.score} end)
          state = for {seat, nagashi?} <- nagashi, nagashi?, payer <- [:east, :south, :west, :north] -- [seat], reduce: state do
            state ->
              oya_payment = 4000
              ko_payment = if Riichi.get_east_player_seat(state.kyoku) == seat do 4000 else 2000 end
              payment = if Riichi.get_east_player_seat(state.kyoku) == payer do oya_payment else ko_payment end
              state
                |> update_player(seat, &%Player{ &1 | score: &1.score + payment })
                |> update_player(payer, &%Player{ &1 | score: &1.score - payment })
          end
          delta_scores = Map.new(state.players, fn {seat, player} -> {seat, player.score - scores_before[seat]} end)
          {state, delta_scores}
        else
          delta_scores = case num_tenpai do
            0 -> Map.new(tenpai, fn {seat, _tenpai} -> {seat, 0} end)
            1 -> Map.new(tenpai, fn {seat, tenpai} -> {seat, if tenpai do 3000 else -1000 end} end)
            2 -> Map.new(tenpai, fn {seat, tenpai} -> {seat, if tenpai do 1500 else -1500 end} end)
            3 -> Map.new(tenpai, fn {seat, tenpai} -> {seat, if tenpai do 1000 else -3000 end} end)
            4 -> Map.new(tenpai, fn {seat, _tenpai} -> {seat, 0} end)
          end
          {state, delta_scores}
        end
        # reveal hand for those players that are tenpai
        state = update_all_players(state, fn seat, player -> %Player{ player | hand_revealed: tenpai[seat] } end)

        delta_scores_reason = cond do
          num_nagashi == 0 -> "Ryuukyoku"
          num_nagashi > 0  -> "Nagashi Mangan"
        end

        dealer_continuation = tenpai[Riichi.get_east_player_seat(state.kyoku)]

        {state, delta_scores, delta_scores_reason, dealer_continuation}
      _ ->
        IO.puts("Unknown scoring method #{inspect(scoring_table["method"])}")
        delta_scores = Map.new(state.players, fn {seat, _player} -> {seat, 0} end)
        state = Map.update!(state, :kyoku, & &1 + 1)
        {state, delta_scores, "", false}
    end
    {state, delta_scores, delta_scores_reason, dealer_continuation}
  end

  defp timer_finished(state) do
    cond do
      state.visible_screen == :winner && state.winner_index + 1 < map_size(state.winners) -> # need to see next winner screen
        # show the next winner
        state = Map.update!(state, :winner_index, & &1 + 1)

        # reset timer
        state = Map.put(state, :timer, 10)
        state = update_all_players(state, fn seat, player -> %Player{ player | ready: is_pid(state[seat]) } end)
        Debounce.apply(state.timer_debouncer)

        state
      state.visible_screen == :winner -> # need to see score exchange screen
        # calculate delta scores
        {state, delta_scores, delta_scores_reason, dealer_continuation} = adjudicate_win_scoring(state)
        state = Map.put(state, :delta_scores, delta_scores)
        state = Map.put(state, :delta_scores_reason, delta_scores_reason)
        state = Map.put(state, :dealer_continuation, dealer_continuation)

        # reset timer
        state = Map.put(state, :timer, 10)
        state = update_all_players(state, fn seat, player -> %Player{ player | ready: is_pid(state[seat]) } end)
        Debounce.apply(state.timer_debouncer)
        state = Map.put(state, :visible_screen, :scores)
        
        state
      state.visible_screen == :scores -> # finished seeing the score exchange screen
        # update kyoku and honba
        state = case state.round_result do
          :win when state.dealer_continuation ->
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
          :draw when state.dealer_continuation ->
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

        # finish or initialize new round if needed
        state = if state.round_result != :continue do
          if Map.has_key?(state.rules, "max_rounds") && state.kyoku >= state.rules["max_rounds"] do
            finalize_game(state)
          else
            initialize_new_round(state)
          end
        else state end
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
    for dir <- [:east, :south, :west, :north], state[dir] == nil, reduce: state do
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

  defp is_playable?(state, seat, tile, tile_source) do
    if Map.has_key?(state.rules, "play_restrictions") do
      Enum.all?(state.rules["play_restrictions"], fn [tile_spec, cond_spec] ->
        # if Riichi.tile_matches(tile_spec, %{tile: tile}) do
        #   IO.inspect({tile, cond_spec, check_cnf_condition(state, cond_spec, %{seat: seat, tile: tile, tile_source: tile_source})})
        # end
        not Riichi.tile_matches(tile_spec, %{tile: tile}) || check_cnf_condition(state, cond_spec, %{seat: seat, tile: tile, tile_source: tile_source})
      end)
    else true end
  end

  defp play_tile(state, seat, tile, index) do
    tile_source = if index < length(state.players[seat].hand) do :hand else :draw end
    if is_playable?(state, seat, tile, tile_source) do
      # IO.puts("#{seat} played tile: #{inspect(tile)} at index #{index}")
      state = update_player(state, seat, &%Player{ &1 |
        hand: List.delete_at(&1.hand ++ &1.draw, index),
        pond: &1.pond ++ [tile],
        discards: &1.discards ++ [tile],
        draw: [],
        last_discard: {tile, index}
      })
      state = update_action(state, seat, :discard, %{tile: tile})

      # trigger play effects
      if Map.has_key?(state.rules, "play_effects") do
        for [tile_spec, actions] <- state.rules["play_effects"], Riichi.tile_matches([tile_spec], %{tile: tile}), reduce: state do
          state -> run_actions(state, actions, %{seat: seat})
        end
      else state end
    else state end
  end

  defp _reindex_hand(hand, from, to) do
    {l1, [tile | r1]} = Enum.split(hand, from)
    {l2, r2} = Enum.split(l1 ++ r1, to)
    l2 ++ [tile] ++ r2
  end

  defp from_tile_name(state, tile_name) do
    cond do
      is_binary(tile_name) && Map.has_key?(state.reserved_tiles, tile_name) -> state.reserved_tiles[tile_name]
      is_atom(tile_name) -> tile_name
      true ->
        IO.puts("Unknown tile name #{inspect(tile_name)}")
        tile_name
    end
  end

  defp draw_tile(state, seat, num, tile_spec) do
    if num > 0 do
      {tile_name, wall_index} = if tile_spec != nil do {tile_spec, state.wall_index} else {Enum.at(state.wall, state.wall_index), state.wall_index + 1} end
      if tile_name == nil do
        IO.puts("Tried to draw a nil tile!")
        state
      else
        state = if is_binary(tile_name) && Map.has_key?(state.reserved_tiles, tile_name) do
            Map.update!(state, :drawn_reserved_tiles, fn tiles -> [tile_name | tiles] end)
          else state end
        tile = from_tile_name(state, tile_name)
        state = update_player(state, seat, &%Player{ &1 |
          hand: &1.hand ++ &1.draw,
          draw: [tile]
        })
        state = Map.put(state, :wall_index, wall_index)
        state = update_action(state, seat, :draw, %{tile: tile})

        # IO.puts("wall index is now #{get_state().wall_index}")
        draw_tile(state, seat, num - 1, tile_spec)
      end
    else state end
  end

  def run_on_no_valid_tiles(state, seat, gas \\ 100) do
    if gas > 0 do
      if not Enum.any?(state.players[seat].hand, fn tile -> is_playable?(state, seat, tile, :hand) end) &&
         not Enum.any?(state.players[seat].draw, fn tile -> is_playable?(state, seat, tile, :draw) end) do
        state = run_actions(state, state.rules["on_no_valid_tiles"]["actions"], %{seat: seat})
        if Map.has_key?(state.rules["on_no_valid_tiles"], "recurse") && state.rules["on_no_valid_tiles"]["recurse"] do
          run_on_no_valid_tiles(state, seat, gas - 1)
        else state end
      else state end
    else state end
  end

  defp change_turn(state, seat, via_action \\ false) do
    # get previous turn
    prev_turn = state.turn
    # IO.puts("Changing turn from #{prev_turn} to #{seat}")

    # change turn
    state = Map.put(state, :turn, seat)

    if state.game_active do
      # run on turn change, unless this turn change was triggered by an action
      state = if not via_action && prev_turn != nil && seat != prev_turn && Map.has_key?(state.rules, "before_turn_change") do
        run_actions(state, state.rules["before_turn_change"]["actions"], %{seat: prev_turn})
      else state end
      state = if not via_action && seat != prev_turn && Map.has_key?(state.rules, "after_turn_change") do
        run_actions(state, state.rules["after_turn_change"]["actions"], %{seat: seat})
      else state end

      # check if any tiles are playable for this next player
      state = if Map.has_key?(state.rules, "on_no_valid_tiles") do
        run_on_no_valid_tiles(state, seat)
      else state end

      state
    else state end
  end

  defp advance_turn(state) do
    # this action is called after playing a tile
    # it should trigger on_turn_change, so don't mark the turn change as via_action
    change_turn(state, if state.reversed_turn_order do Utils.prev_turn(state.turn) else Utils.next_turn(state.turn) end)
  end

  defp trigger_call(state, seat, call_name, call_choice, called_tile, call_source) do
    call_style = if Map.has_key?(state.rules["buttons"][call_name], "call_style") do
        state.rules["buttons"][call_name]["call_style"]
      else Map.new(["self", "kamicha", "toimen", "shimocha"], fn dir -> {dir, 0..length(call_choice)} end) end

    # style the call
    # tiles = Enum.map(call_choice, fn t -> {t, false} end)
    call = if called_tile != nil do
      style = call_style[Atom.to_string(Utils.get_relative_seat(seat, state.turn))]
      tiles = if "call" in style or "call_sideways" in style do call_choice else call_choice ++ [called_tile] end
      tiles = Utils.sort_tiles(tiles)
      for style_spec <- style, reduce: [] do
        acc ->
          tile = case style_spec do
            "call"                 -> {called_tile, false}
            "call_sideways"        -> {called_tile, true}
            ix when is_integer(ix) -> {Enum.at(tiles, ix), false}
            tile                   -> {Utils.to_tile(tile), false}
          end
          [tile | acc]
      end |> Enum.reverse()
    else
      Enum.map(call_choice, fn tile -> {tile, false} end)
    end
    call = {call_name, call}
    state = if Map.has_key?(state.rules, "before_call") do
      run_actions(state, state.rules["before_call"]["actions"], %{seat: state.turn, callee: state.turn, caller: seat, call: call})
    else state end
    state = case call_source do
      :discards -> update_player(state, state.turn, &%Player{ &1 | pond: Enum.drop(&1.pond, -1) })
      :hand     -> update_player(state, seat, &%Player{ &1 | hand: (&1.hand ++ &1.draw) -- [called_tile], draw: [] })
      _         -> IO.puts("Unhandled call_source #{inspect(call_source)}")
    end
    state = update_player(state, seat, &%Player{ &1 | hand: &1.hand -- call_choice, calls: &1.calls ++ [call] })
    state = update_action(state, seat, :call,  %{from: state.turn, called_tile: called_tile, other_tiles: call_choice, call_name: call_name})
    state = update_player(state, seat, &%Player{ &1 | call_buttons: %{}, call_name: "" })
    state = if Map.has_key?(state.rules, "after_call") do
      run_actions(state, state.rules["after_call"]["actions"], %{seat: seat, callee: state.turn, caller: seat, call: call})
    else state end
    state
  end

  defp upgrade_call(state, seat, call_name, call_choice, called_tile) do
    # find the index of the call whose tiles match call_choice
    index = state.players[seat].calls
      |> Enum.map(fn {_name, call} -> Enum.map(call, fn {tile, _sideways} -> tile end) end)
      |> Enum.find_index(fn call_tiles -> Enum.sort(call_tiles) == Enum.sort(call_choice) end)
    # upgrade that call
    {_name, call} = Enum.at(state.players[seat].calls, index)

    # find the index of the sideways tile
    sideways_index = Enum.find_index(call, fn {_tile, sideways} -> sideways end)
    sideways_index = if sideways_index == nil do -1 else sideways_index end
    upgraded_call = {call_name, List.insert_at(call, sideways_index, {called_tile, true})}
    state = update_player(state, seat, &%Player{ &1 | hand: (&1.hand ++ &1.draw) -- [called_tile], draw: [], calls: List.replace_at(state.players[seat].calls, index, upgraded_call) })
    state = update_action(state, seat, :call,  %{from: state.turn, called_tile: called_tile, other_tiles: call_choice, call_name: call_name})
    state = update_player(state, seat, &%Player{ &1 | call_buttons: %{}, call_name: "" })
    state
  end

  defp get_yaku(state, yaku_list, seat, winning_tile, win_source, minipoints \\ 0) do
    context = %{
      seat: seat,
      winning_tile: winning_tile,
      win_source: win_source,
      minipoints: minipoints
    }
    eligible_yaku = yaku_list
      |> Enum.filter(fn %{"display_name" => _name, "value" => _value, "when" => cond_spec} -> check_cnf_condition(state, cond_spec, context) end)
      |> Enum.map(fn %{"display_name" => name, "value" => value, "when" => _cond_spec} -> {name, value} end)
    yaku_map = Enum.reduce(eligible_yaku, %{}, fn {name, value}, acc -> Map.update(acc, name, value, & &1 + value) end)
    eligible_yaku
      |> Enum.map(fn {name, _value} -> name end)
      |> Enum.uniq()
      |> Enum.map(fn name -> {name, yaku_map[name]} end)
  end

  defp win(state, seat, winning_tile, win_source) do
    state = Map.put(state, :round_result, :win)

    # run before_win actions
    state = if Map.has_key?(state.rules, "before_win") do
      run_actions(state, state.rules["before_win"]["actions"], %{seat: seat})
    else state end

    state = update_all_players(state, fn _seat, player -> %Player{ player | last_discard: nil } end)
    state = Map.put(state, :game_active, false)
    state = Map.put(state, :timer, 10)
    state = Map.put(state, :visible_screen, :winner)
    state = update_all_players(state, fn seat, player -> %Player{ player | ready: is_pid(state[seat]) } end)
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
        minipoints = Riichi.calculate_fu(state.players[seat].hand, state.players[seat].calls, winning_tile, win_source, Riichi.get_seat_wind(state.kyoku, seat), Riichi.get_round_wind(state.kyoku))
        yaku = get_yaku(state, state.rules["yaku"] ++ state.rules["extra_yaku"], seat, winning_tile, win_source, minipoints)
        yakuman = get_yaku(state, state.rules["yakuman"], seat, winning_tile, win_source, minipoints)
        {score, points, yakuman_mult} = score_yaku(state, seat, yaku, yakuman, win_source == :draw, minipoints)
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
        yaku = get_yaku(state, state.rules["yaku"], seat, winning_tile, win_source)
        {score, points, _} = score_yaku(state, seat, yaku, [], win_source == :draw)
        payer = case win_source do
          :draw    -> nil
          :discard -> get_last_discard_action(state).seat
          :call    -> get_last_call_action(state).seat
        end
        winner = Map.merge(winner, %{
          yaku: yaku,
          yakuman: [],
          points: points,
          yakuman_mult: 0,
          score: score,
          score_name: "",
          minipoints: 0,
          payer: payer,
          pao_seat: nil
        })
        state = Map.update!(state, :winners, &Map.put(&1, seat, winner))
        state
      _ ->
        state = show_error(state, "Unknown scoring method #{inspect(scoring_table["method"])}")
        state
    end
    state
  end

  defp exhaustive_draw(state) do
    state = Map.put(state, :round_result, :draw)

    # run before_exhaustive_draw actions
    state = if Map.has_key?(state.rules, "before_exhaustive_draw") do
      run_actions(state, state.rules["before_exhaustive_draw"]["actions"], %{seat: state.turn})
    else state end

    state = update_all_players(state, fn _seat, player -> %Player{ player | last_discard: nil } end)
    state = Map.put(state, :game_active, false)
    state = Map.put(state, :timer, 10)
    state = Map.put(state, :visible_screen, :scores)
    state = update_all_players(state, fn seat, player -> %Player{ player | ready: is_pid(state[seat]) } end)
    Debounce.apply(state.timer_debouncer)

    {state, delta_scores, delta_scores_reason, dealer_continuation} = adjudicate_draw_scoring(state)

    state = Map.put(state, :delta_scores, delta_scores)
    state = Map.put(state, :delta_scores_reason, delta_scores_reason)
    state = Map.put(state, :dealer_continuation, dealer_continuation)
    state
  end

  defp recalculate_buttons(state) do
    if Map.has_key?(state.rules, "buttons") do
      # IO.puts("Regenerating buttons...")
      # IO.inspect(Process.info(self(), :current_stacktrace))
      new_buttons = Map.new(state.players, fn {seat, _player} ->
        if false do
          # don't regenerate buttons if we have already made a decision
          # choices are reset to nil upon choice adjudication, so by pressing skip,
          # we're declaring we ignore any buttons until the next round of choices is made
          {seat, []}
        else
          buttons = state.rules["buttons"]
            |> Enum.filter(fn {_name, button} ->
                 calls_spec = if Map.has_key?(button, "call") do button["call"] else [] end
                 upgrades = if Map.has_key?(button, "upgrades") do button["upgrades"] else [] end
                 check_cnf_condition(state, button["show_when"], %{seat: seat, calls_spec: calls_spec, upgrade_name: upgrades})
               end)
            |> Enum.map(fn {name, _button} -> name end)
          unskippable_button_exists = Enum.any?(buttons, fn button_name -> Map.has_key?(state.rules["buttons"][button_name], "unskippable") && state.rules["buttons"][button_name]["unskippable"] end)
          {seat, if not Enum.empty?(buttons) && not unskippable_button_exists do buttons ++ ["skip"] else buttons end}
        end
      end)
      # IO.puts("Updating buttons after action #{action}: #{inspect(new_buttons)}")
      update_all_players(state, fn seat, player -> %Player{ player | buttons: new_buttons[seat] } end)
    else state end
  end

  defp notify_ai_call_buttons(state, seat) do
    if state.game_active do
      call_choices = state.players[seat].call_buttons
      if is_pid(state[seat]) && not Enum.empty?(call_choices) && not Enum.empty?(call_choices |> Map.values() |> Enum.concat()) do
        # IO.puts("Notifying #{seat} AI about their call buttons: #{inspect(state.players[seat].call_buttons)}")
        send(state[seat], {:call_buttons, %{player: state.players[seat]}})
      end
    end
  end

  defp notify_ai(state) do
    # IO.puts("Notifying ai")
    # IO.inspect(Process.info(self(), :current_stacktrace))
    if state.game_active do
      # if there are any new buttons for any AI players, notify them
      # otherwise, just tell the current player it's their turn
      if no_buttons_remaining?(state) do
        if is_pid(state[state.turn]) do
          # IO.puts("Notifying #{state.turn} AI that it's their turn")
          send(state[state.turn], {:your_turn, %{player: state.players[state.turn]}})
        end
      else
        Enum.each([:east, :south, :west, :north], fn seat ->
          has_buttons = not Enum.empty?(state.players[seat].buttons)
          if is_pid(state[seat]) && has_buttons do
            # IO.puts("Notifying #{seat} AI about their buttons: #{inspect(state.players[seat].buttons)}")
            send(state[seat], {:buttons, %{player: state.players[seat]}})
          end
        end)
      end
    end
  end

  # trigger auto buttons actions for players
  defp trigger_auto_buttons(state, seats \\ [:east, :south, :west, :north]) do
    for seat <- seats,
        not is_pid(state[seat]),
        {auto_button_name, enabled} <- state.players[seat].auto_buttons,
        reduce: state do
      state -> trigger_auto_button(state, seat, auto_button_name, enabled)
    end
  end

  defp _run_actions(state, [], _context), do: {state, []}
  defp _run_actions(state, [[action | opts] | actions], context) do
    buttons_before = Enum.map(state.players, fn {seat, player} -> {seat, player.buttons} end)
    state = case action do
      "play_tile"             -> play_tile(state, context.seat, Enum.at(opts, 0, :"1m"), Enum.at(opts, 1, 0))
      "draw"                  -> draw_tile(state, context.seat, Enum.at(opts, 0, 1), Enum.at(opts, 1, nil))
      "reverse_turn_order"    -> Map.update!(state, :reversed_turn_order, &not &1)
      "call"                  -> trigger_call(state, context.seat, context.call_name, context.call_choice, context.called_tile, :discards)
      "self_call"             -> trigger_call(state, context.seat, context.call_name, context.call_choice, context.called_tile, :hand)
      "upgrade_call"          -> upgrade_call(state, context.seat, context.call_name, context.call_choice, context.called_tile)
      "flower"                -> trigger_call(state, context.seat, context.call_name, context.call_choice, nil, :hand)
      "advance_turn"          -> advance_turn(state)
      "change_turn"           -> change_turn(state, Utils.get_seat(context.seat, String.to_atom(Enum.at(opts, 0, "self"))), true)
      "win_by_discard"        -> win(state, context.seat, get_last_discard_action(state).tile, :discard)
      "win_by_call"           -> win(state, context.seat, get_last_action(state).called_tile, :call)
      "win_by_draw"           -> win(state, context.seat, Enum.at(state.players[context.seat].draw, 0), :draw)
      "set_status"            -> update_player(state, context.seat, fn player -> %Player{ player | status: Enum.uniq(player.status ++ opts) } end)
      "unset_status"          -> update_player(state, context.seat, fn player -> %Player{ player | status: Enum.uniq(player.status -- opts) } end)
      "set_status_all"        -> update_all_players(state, fn _seat, player -> %Player{ player | status: Enum.uniq(player.status ++ opts) } end)
      "unset_status_all"      -> update_all_players(state, fn _seat, player -> %Player{ player | status: Enum.uniq(player.status -- opts) } end)
      "set_callee_status"     -> update_player(state, context.callee, fn player -> %Player{ player | status: Enum.uniq(player.status ++ opts) } end)
      "unset_callee_status"   -> update_player(state, context.callee, fn player -> %Player{ player | status: Enum.uniq(player.status -- opts) } end)
      "set_caller_status"     -> update_player(state, context.caller, fn player -> %Player{ player | status: Enum.uniq(player.status ++ opts) } end)
      "unset_caller_status"   -> update_player(state, context.caller, fn player -> %Player{ player | status: Enum.uniq(player.status -- opts) } end)
      "big_text"              -> temp_display_big_text(state, context.seat, Enum.at(opts, 0, ""))
      "pause"                 -> Map.put(state, :game_active, false)
      "sort_hand"             -> update_player(state, context.seat, fn player -> %Player{ player | hand: Utils.sort_tiles(player.hand) } end)
      "reveal_tile"           -> Map.update!(state, :revealed_tiles, fn tiles -> tiles ++ [Enum.at(opts, 0, :"1m")] end)
      "add_score"             -> update_player(state, context.seat, fn player -> %Player{ player | score: player.score + Enum.at(opts, 0, 0) } end)
      "put_down_riichi_stick" -> state |> Map.update!(:riichi_sticks, & &1 + 1) |> update_player(context.seat, &%Player{ &1 | riichi_stick: true })
      "reveal_hand"           -> update_player(state, context.seat, fn player -> %Player{ player | hand_revealed: true } end)
      "ryuukyoku"             -> exhaustive_draw(state)
      "discard_draw"          ->
        # need to do this or else we might reenter adjudicate_actions
        :timer.apply_after(100, GenServer, :cast, [self(), {:play_tile, context.seat, length(state.players[context.seat].hand)}])
        state
      "press_button"          ->
        # need to do this or else we might reenter adjudicate_actions
        :timer.apply_after(100, GenServer, :cast, [self(), {:press_button, context.seat, Enum.at(opts, 0, "skip")}])
        state
      "when"                  -> if check_cnf_condition(state, Enum.at(opts, 0, []), context) do run_actions(state, Enum.at(opts, 1, []), context) else state end
      "when_anyone"           ->
        for dir <- [:east, :south, :west, :north], check_cnf_condition(state, Enum.at(opts, 0, []), %{seat: dir}), reduce: state do
          state -> run_actions(state, Enum.at(opts, 1, []), %{seat: dir})
        end
      _                       ->
        IO.puts("Unhandled action #{action}")
        state
    end

    if action == "pause" do
      # schedule an unpause after the given delay
      :timer.apply_after(Enum.at(opts, 0, 1500), GenServer, :cast, [self(), {:unpause, actions, context}])
      # IO.puts("Stopping actions due to pause: #{inspect(actions)}")
      {state, []}
    else
      # if our action updates state, then we need to recalculate buttons
      # this is so other players can react to certain actions
      if Map.has_key?(state.rules, "interruptible_actions") && action in state.rules["interruptible_actions"] do
        state = if not Enum.empty?(state.winners) do
          # if there's a winner, never display buttons
          update_all_players(state, fn _seat, player -> %Player{ player | buttons: [] } end)
        else
          recalculate_buttons(state)
        end
        buttons_after = Enum.map(state.players, fn {seat, player} -> {seat, player.buttons} end)
        # IO.puts("buttons_before: #{inspect(buttons_before)}")
        # IO.puts("buttons_after: #{inspect(buttons_after)}")
        if buttons_before == buttons_after || no_buttons_remaining?(state) do
          _run_actions(state, actions, context)
        else
          # if buttons changed, stop evaluating actions here
          # IO.puts("Stopping actions due to buttons: #{inspect(buttons_after)}")
          {state, actions}
        end
      else
        _run_actions(state, actions, context)
      end
    end
  end
  defp _run_actions(state, [action | actions], context) do
    IO.puts("Unhandled action spec #{action}")
    _run_actions(state, actions, context)
  end

  defp run_actions(state, actions, context) do
    state = Map.update!(state, :actions_cv, & &1 + 1)
    # if Enum.empty?(actions) || (actions |> Enum.at(0) |> Enum.at(0)) not in ["when", "sort_hand", "unset_status"] do
    #   IO.puts("Running actions #{inspect(actions)} in context #{inspect(context)}; cv = #{state.actions_cv}")
    # end
    # IO.puts("Running actions #{inspect(actions)} in context #{inspect(context)}; cv = #{state.actions_cv}")
    # IO.inspect(Process.info(self(), :current_stacktrace))
    {state, deferred_actions} = _run_actions(state, actions, context)
    # defer the remaining actions
    state = if not Enum.empty?(deferred_actions) do
      # IO.puts("Deferred actions for seat #{context.seat} due to pause or existing buttons / #{inspect(deferred_actions)}")
      state = schedule_actions(state, context.seat, deferred_actions)
      state
    else state end
    state = Map.update!(state, :actions_cv, & &1 - 1)
    state = if state.actions_cv == 0 do
      # notify_ai(state)
      # make our next decision for us (unless these actions were caused by auto buttons)
      state = if not Map.has_key?(context, :auto) || not context.auto do
        # IO.puts("Triggering auto buttons")
        state = trigger_auto_buttons(state)
        state
      else state end
      state
    else state end
    state
  end

  defp run_deferred_actions(state, context) do
    actions = state.players[context.seat].deferred_actions
    if state.game_active && not Enum.empty?(actions) do
      state = update_player(state, context.seat, &%Player{ &1 | deferred_actions: [] })
      # IO.puts("Running deferred actions #{inspect(actions)} in context #{inspect(context)}")
      state = run_actions(state, actions, context)
      state
    else state end
  end

  defp schedule_actions(state, seat, actions) do
    update_player(state, seat, &%Player{ &1 | deferred_actions: &1.deferred_actions ++ actions })
  end

  def get_hand_definition(state, name) do
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

  def check_condition(state, cond_spec, context \\ %{}, opts \\ []) do
    negated = String.starts_with?(cond_spec, "not_")
    cond_spec = if negated do String.slice(cond_spec, 4..-1//1) else cond_spec end
    last_action = get_last_action(state)
    last_call_action = get_last_call_action(state)
    last_discard_action = get_last_discard_action(state)
    result = case cond_spec do
      "true"                     -> true
      "false"                    -> false
      "our_turn"                 -> state.turn == context.seat
      "our_turn_is_next"         -> state.turn == if state.reversed_turn_order do Utils.next_turn(context.seat) else Utils.prev_turn(context.seat) end
      "our_turn_is_not_next"     -> state.turn != if state.reversed_turn_order do Utils.next_turn(context.seat) else Utils.prev_turn(context.seat) end
      "our_turn_is_prev"         -> state.turn == if state.reversed_turn_order do Utils.prev_turn(context.seat) else Utils.next_turn(context.seat) end
      "our_turn_is_not_prev"     -> state.turn != if state.reversed_turn_order do Utils.prev_turn(context.seat) else Utils.next_turn(context.seat) end
      "game_start"               -> last_action == nil
      "no_discards_yet"          -> last_discard_action == nil
      "no_calls_yet"             -> last_call_action == nil
      "last_call_is"             -> last_call_action != nil && last_call_action.call_name == Enum.at(opts, 0, "kakan")
      "kamicha_discarded"        -> last_action != nil && last_action.action == :discard && last_action.seat == state.turn && state.turn == Utils.prev_turn(context.seat)
      "someone_else_discarded"   -> last_action != nil && last_action.action == :discard && last_action.seat == state.turn && state.turn != context.seat
      "just_called"              -> last_action != nil && last_action.action == :call
      "call_available"           -> last_action != nil && last_action.action == :discard && Riichi.can_call?(context.calls_spec, state.players[context.seat].hand, [last_action.tile])
      "self_call_available"      -> Riichi.can_call?(context.calls_spec, state.players[context.seat].hand ++ state.players[context.seat].draw)
      "can_upgrade_call"         -> state.players[context.seat].calls
        |> Enum.filter(fn {name, _call} -> name == context.upgrade_name end)
        |> Enum.any?(fn {_name, call} ->
          call_tiles = Enum.map(call, fn {tile, _sideways} -> tile end)
          Riichi.can_call?(context.calls_spec, call_tiles, state.players[context.seat].hand ++ state.players[context.seat].draw)
        end)
      "has_draw"                 -> not Enum.empty?(state.players[context.seat].draw)
      "furiten"                  -> false
      "has_yaku_with_hand"       -> if not Enum.empty?(state.players[context.seat].draw) do
          winning_tile = Enum.at(state.players[context.seat].draw, 0)
          minipoints = Riichi.calculate_fu(state.players[context.seat].hand, state.players[context.seat].calls, winning_tile, :draw, Riichi.get_seat_wind(state.kyoku, context.seat), Riichi.get_round_wind(state.kyoku))
          Enum.any?(state.rules["yaku"], fn yaku -> not Enum.empty?(get_yaku(state, [yaku], context.seat, winning_tile, :draw, minipoints)) end)
        else false end
      "has_yaku_with_discard"    -> if last_action.action == :discard do
          winning_tile = last_action.tile
          minipoints = Riichi.calculate_fu(state.players[context.seat].hand, state.players[context.seat].calls, winning_tile, :discard, Riichi.get_seat_wind(state.kyoku, context.seat), Riichi.get_round_wind(state.kyoku))
          Enum.any?(state.rules["yaku"], fn yaku -> not Enum.empty?(get_yaku(state, [yaku], context.seat, winning_tile, :discard, minipoints)) end)
        else false end
      "last_discard_matches"     -> last_discard_action != nil && Riichi.tile_matches(opts, %{tile: last_discard_action.tile, tile2: context.tile})
      "last_called_tile_matches" -> last_action.action == :call && Riichi.tile_matches(opts, %{tile: last_action.called_tile, tile2: context.tile, call: last_call_action})
      "unneeded_for_hand"        -> Enum.any?(opts, fn name -> Riichi.not_needed_for_hand(state.players[context.seat].hand ++ state.players[context.seat].draw, state.players[context.seat].calls, context.tile, get_hand_definition(state, name <> "_definition")) end)
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
        hand_calls = for item <- Enum.at(opts, 0, []), reduce: [{[], []}] do
          hand_calls -> for {hand, calls} <- hand_calls do
            case item do
              "hand" -> [{hand ++ state.players[context.seat].hand, calls}]
              "draw" -> [{hand ++ state.players[context.seat].draw, calls}]
              "calls" -> [{hand, calls ++ state.players[context.seat].calls}]
              "call_tiles" -> [{hand ++ Enum.flat_map(state.players[context.seat].calls, &Riichi.call_to_tiles/1), calls}]
              "last_call" -> [{hand, calls ++ [context.call]}]
              "last_called_tile" -> if last_call_action != nil do [{hand ++ [last_call_action.called_tile], calls}] else [] end
              "last_discard" -> if last_discard_action != nil do [{hand ++ [last_discard_action.tile], calls}] else [] end
              "winning_tile" ->
                winning_tile = if Map.has_key?(context, :winning_tile) do context.winning_tile else state.winners[context.seat].winning_tile end
                [{hand ++ [winning_tile], calls}]
              "any_discard" -> Enum.map(state.players[context.seat].discards, fn discard -> {hand ++ [discard], calls} end)
            end
          end |> Enum.concat()
        end
        match_definitions = translate_match_definitions(state, Enum.at(opts, 1, []))
        Enum.any?(hand_calls, fn {hand, calls} -> Riichi.match_hand(hand, calls, match_definitions) end)
      "winning_hand_consists_of" ->
        tiles = Enum.map(opts, &Utils.to_tile/1)
        Enum.all?(state.players[context.seat].hand ++ Enum.flat_map(state.players[context.seat].calls, &Riichi.call_to_tiles/1), fn tile -> tile in tiles end) 
      "winning_hand_and_tile_consists_of" ->
        tiles = Enum.map(opts, &Utils.to_tile/1)
        winning_tile = if Map.has_key?(context, :winning_tile) do context.winning_tile else state.winners[context.seat].winning_tile end
        Enum.all?(state.players[context.seat].hand ++ Enum.flat_map(state.players[context.seat].calls, &Riichi.call_to_tiles/1) ++ [winning_tile], fn tile -> tile in tiles end) 
      _                          ->
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

  def adjudicate_actions(state) do
    if state.game_active do
      lock = Mutex.await(state.mutex, __MODULE__)
      # IO.puts("\nAdjudicating actions!")
      # clear last discard
      state = update_all_players(state, fn _seat, player -> %Player{ player | last_discard: nil } end)
      superceded_choices = get_superceded_choices(state)
      state = for {seat, player} <- state.players, reduce: state do
        state ->
          # only trigger choices that aren't superceded
          choice = player.choice
          actions = player.chosen_actions
          state = update_player(state, seat, fn player -> %Player{ player | choice: nil, chosen_actions: nil, deferred_actions: [] } end)
          state = if choice != nil && not Enum.member?(superceded_choices, choice) do
            # IO.puts("It's #{state.turn}'s turn, player #{seat} (choice: #{choice}) gets to run actions #{inspect(actions)}")
            # check if a call action exists, if it's a call and multiple call choices are available
            call_action_exists = Enum.any?(actions, fn [action | _opts] -> action in ["call", "self_call", "upgrade_call", "flower"] end)
            if not call_action_exists do
              # just run all button actions as normal
              state = run_actions(state, actions, %{seat: seat})
              state
            else
              # call button choices logic
              button_name = choice
              # if there is a call action, check if there are multiple call choices
              is_call = Enum.any?(actions, fn [action | _opts] -> action == "call" end)
              is_upgrade = Enum.any?(actions, fn [action | _opts] -> action == "upgrade_call" end)
              is_flower = Enum.any?(actions, fn [action | _opts] -> action == "flower" end)
              call_choices = cond do
                is_upgrade ->
                  state.players[seat].calls
                    |> Enum.filter(fn {name, _call} -> name == state.rules["buttons"][button_name]["upgrades"] end)
                    |> Enum.map(fn {_name, call} -> Enum.map(call, fn {tile, _sideways} -> tile end) end)
                    |> Enum.map(fn call_tiles ->
                       Riichi.make_calls(state.rules["buttons"][button_name]["call"], call_tiles, state.players[seat].hand ++ state.players[seat].draw)
                    end)
                    |> Enum.reduce(%{}, fn call_choices, acc -> Map.merge(call_choices, acc, fn _k, l, r -> l ++ r end) end)
                is_flower ->
                  flowers = Enum.flat_map(actions, fn [action | opts] -> if action == "flower" do opts else [] end end) |> Enum.map(&Utils.to_tile/1)
                  flowers_in_hand = Enum.filter(state.players[seat].hand ++ state.players[seat].draw, fn tile -> tile in flowers end)
                  %{nil => Enum.map(flowers_in_hand, fn tile -> [tile] end)}
                true ->
                  callable_tiles = if is_call do Enum.take(state.players[state.turn].pond, -1) else [] end
                  Riichi.make_calls(state.rules["buttons"][button_name]["call"], state.players[seat].hand ++ state.players[seat].draw, callable_tiles)
              end
              flattened_call_choices = call_choices |> Map.values() |> Enum.concat()
              if length(flattened_call_choices) == 1 do
                # if there's only one choice, automatically choose it
                {called_tile, [call_choice]} = Enum.max_by(call_choices, fn {_tile, choices} -> length(choices) end)
                state = run_actions(state, actions, %{seat: seat, call_name: button_name, call_choice: call_choice, called_tile: called_tile})
                state
              else
                # otherwise, defer all actions and display call choices
                state = schedule_actions(state, seat, actions)
                state = update_player(state, seat, fn player -> %Player{ player | call_buttons: call_choices, call_name: button_name } end)
                notify_ai_call_buttons(state, seat)
                state
              end
            end
          else state end
          state
      end
      # done with all choices
      state = recalculate_buttons(state)
      notify_ai(state)
      # state = update_all_players(state, fn _seat, player -> %Player{ player | choice: nil, chosen_actions: nil } end)
      Mutex.release(state.mutex, lock)
      # IO.puts("Done adjudicating actions!\n")
      state
    else state end
  end

  def submit_actions(state, seat, choice, actions) do
    if state.game_active && state.players[seat].choice == nil do
      # IO.puts("Submitting choice for #{seat}: #{choice}, #{inspect(actions)}")
      # IO.puts("Deferred actions for #{seat}: #{inspect(state.players[seat].deferred_actions)}")
      state = update_player(state, seat, &%Player{ &1 | choice: choice, chosen_actions: actions, deferred_actions: [] })

      # for the current turn's player, if they just acted (have deferred actions) and have no buttons, their choice is "skip"
      # for other players who have no buttons and have not made a choice yet, their choice is "skip"
      # also for other players who have made a choice, if their choice is superceded then set it to "skip"
      superceded_choices = get_superceded_choices(state)
      last_action = get_last_action(state)
      turn_just_acted = last_action != nil && not Enum.empty?(state.players[state.turn].deferred_actions) && last_action.seat == state.turn
      state = for {seat, player} <- state.players, reduce: state do
        state -> cond do
          seat == state.turn && turn_just_acted && Enum.empty?(player.buttons) && Enum.empty?(player.call_buttons) ->
            # IO.puts("Player #{seat} must skip due to having just discarded")
            update_player(state, seat, &%Player{ &1 | choice: "skip", chosen_actions: [] })
          seat != state.turn && player.choice == nil && Enum.empty?(player.buttons) && Enum.empty?(player.call_buttons) ->
            # IO.puts("Player #{seat} must skip due to having no buttons")
            update_player(state, seat, &%Player{ &1 | choice: "skip", chosen_actions: [] })
          seat != state.turn && player.choice != nil && Enum.member?(superceded_choices, player.choice) ->
            # IO.puts("Player #{seat} must skip due to having buttons superceded")
            update_player(state, seat, &%Player{ &1 | choice: "skip", chosen_actions: [] })
          true -> state
        end
      end

      # check if nobody else needs to make choices
      if Enum.all?(state.players, fn {_seat, player} -> player.choice != nil end) do
        # if every action is skip, we need to resume deferred actions for all players
        # otherwise, adjudicate actions as normal
        if Enum.all?(state.players, fn {_seat, player} -> player.choice == "skip" end) do
          if state.game_active do
            # IO.puts("All choices are no-ops, running deferred actions")
            state = for {seat, _player} <- state.players, reduce: state do
              state ->
                state = update_player(state, seat, fn player -> %Player{ player | choice: nil, chosen_actions: nil } end)
                state = run_deferred_actions(state, %{seat: seat})
                state
            end
            notify_ai(state)
            state
          else state end
        else
          adjudicate_actions(state)
        end
      else state end
    else state end
  end

  def press_button(state, seat, button_name) do
    if Enum.member?(state.players[seat].buttons, button_name) do
      # hide all buttons
      state = update_player(state, seat, fn player -> %Player{ player | buttons: [] } end)
      actions = if button_name == "skip" do [] else state.rules["buttons"][button_name]["actions"] end
      state = submit_actions(state, seat, button_name, actions)
      state = broadcast_state_change(state)
      state
    else state end
  end

  # return all button names that have no effect due to other players' button choices
  defp get_superceded_choices(state) do
    Enum.flat_map(state.players, fn {_seat, player} -> 
      if player.choice != nil && player.choice != "skip" && player.choice != "play_tile" do
        if Map.has_key?(state.rules["buttons"], player.choice) && Map.has_key?(state.rules["buttons"][player.choice], "precedence_over") do
          ["skip", "play_tile"] ++ state.rules["buttons"][player.choice]["precedence_over"]
        else
          ["skip", "play_tile"]
        end
      else
        ["skip"]
      end
    end)
  end

  # returns true if no button choices remain
  # if any of the pressed buttons takes precedence over all buttons available to a given seat,
  # then that seat is not considered to have button choices
  defp no_buttons_remaining?(state) do
    superceded_choices = get_superceded_choices(state)
    Enum.all?(state.players, fn {_seat, player} ->
      Enum.all?(player.buttons, fn name -> Enum.member?(superceded_choices, name) end)
    end)
  end

  # check that {current turn, players with buttons} have no choices left to make
  # for players with buttons, their buttons supercede playing a tile
  # buttons may also supercede other buttons
  # if a player only has buttons that are superceded by others' choices, then they have no choices
  # def no_choices_remaining?(state) do
  #   superceded_choices = get_superceded_choices(state)
  #   result = Enum.all?(state.players, fn {seat, player} ->
  #     last_action = get_last_action(state)
  #     needs_to_play_tile = seat == state.turn && not (last_action.action == :discard && last_action.seat == state.turn)
  #     needs_to_press_button = not Enum.all?(player.buttons, fn name -> Enum.member?(superceded_choices, name) end)
  #     needs_choice = needs_to_play_tile || needs_to_press_button
  #     not needs_choice || player.chosen_actions != nil
  #   end)
  #   result
  # end

  def trigger_auto_button(state, seat, auto_button_name, enabled) do
    # we must apply this after _some_ delay
    # this is because it's possible to call this during run_actions
    # which is called by adjudicate_actions
    # and submitting actions during adjudicate_actions will reenter adjudicate_actions
    # which causes deadlock due to its mutex
    if enabled do
      :timer.apply_after(100, GenServer, :cast, [self(), {:trigger_auto_button, seat, auto_button_name}])
      state
    else state end
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
      state[:east] == nil  || is_pid(state[:east])  -> {:east, false}
      state[:south] == nil || is_pid(state[:south]) -> {:south, false}
      state[:west] == nil  || is_pid(state[:west])  -> {:west, false}
      state[:north] == nil || is_pid(state[:north]) -> {:north, false}
      true                                          -> {:east, true}
    end

    state = if not spectator do
      # if we're replacing an ai, shutdown the ai
      state = if is_pid(state[seat]) do
        IO.puts("Stopping AI for #{seat}: #{inspect(state[seat])}")
        DynamicSupervisor.terminate_child(state.ai_supervisor, state[seat])
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
    state = if Enum.all?([:east, :south, :west, :north], fn dir -> state[dir] == nil || is_pid(state[dir]) end) do
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
    state = run_actions(state, actions, context)
    state = broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast({:reindex_hand, seat, from, to}, state) do
    state = temp_disable_play_tile(state, seat)
    # IO.puts("#{seat} moved tile from #{from} to #{to}")
    state = update_player(state, seat, &%Player{ &1 | :hand => _reindex_hand(&1.hand, from, to) })
    state = broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast({:run_actions, actions, context}, state) do 
    state = run_actions(state, actions, context)
    state = broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast({:run_deferred_actions, context}, state) do 
    state = run_deferred_actions(state, context)
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
      state = temp_disable_play_tile(state, seat)
      # assume we're skipping our button choices
      # TODO ensure no unskippable button exists
      # _unskippable_button_exists = Enum.any?(state.players[seat].buttons, fn button_name -> Map.has_key?(state.rules["buttons"][button_name], "unskippable") && state.rules["buttons"][button_name]["unskippable"] end)
      state = update_player(state, seat, &%Player{ &1 | buttons: [], call_buttons: %{}, call_name: "" })
      actions = [["play_tile", tile, index], ["advance_turn"]]
      state = submit_actions(state, seat, "play_tile", actions)
      state = broadcast_state_change(state)
      state
    else state end
    {:noreply, state}
  end

  def handle_cast({:press_button, seat, button_name}, state) do
    {:noreply, press_button(state, seat, button_name)}
  end

  def handle_cast({:trigger_auto_button, seat, auto_button_name}, state) do
    state = run_actions(state, state.rules["auto_buttons"][auto_button_name]["actions"], %{seat: seat, auto: true})
    state = broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast({:toggle_auto_button, seat, auto_button_name, enabled}, state) do
    # Keyword.put screws up ordering, so we need to use Enum.map
    state = update_player(state, seat, fn player -> %Player{ player | auto_buttons: Enum.map(player.auto_buttons, fn {name, on} ->
      if auto_button_name == name do {name, enabled} else {name, on} end
    end) } end)
    state = trigger_auto_button(state, seat, auto_button_name, enabled)
    state = broadcast_state_change(state)
    {:noreply, state}
  end

  # clicking the compass will send this
  def handle_cast(:notify_ai, state) do
    state = recalculate_buttons(state)
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

end
