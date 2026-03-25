defmodule RiichiAdvanced.GameState.Kyoku do
  alias RiichiAdvanced.GameState.Actions, as: Actions
  alias RiichiAdvanced.GameState.American, as: American
  alias RiichiAdvanced.GameState.Buttons, as: Buttons
  alias RiichiAdvanced.GameState.JokerSolver, as: JokerSolver
  alias RiichiAdvanced.GameState.Log, as: Log
  alias RiichiAdvanced.GameState.Payment, as: Payment
  alias RiichiAdvanced.GameState.Rules, as: Rules
  alias RiichiAdvanced.GameState.Scoring, as: Scoring
  alias RiichiAdvanced.GameState.ScoringOld, as: ScoringOld
  alias RiichiAdvanced.GameState.TileBehavior, as: TileBehavior
  alias RiichiAdvanced.Riichi, as: Riichi
  alias RiichiAdvanced.Utils, as: Utils
  alias RiichiAdvanced.Types, as: Types
  alias RiichiAdvanced.Types.Transaction, as: Transaction
  import RiichiAdvanced.GameState
  require Logger

  @type seat() :: Types.seat()

  defp start_timer(state) do
    state = Map.put(state, :timer, Rules.get(state.rules_ref, "win_timer", 30))
    state = update_all_players(state, fn seat, player -> %{ player | ready: is_pid(Map.get(state, seat)) } end)
    
    if state.log_loading_mode do
      GenServer.cast(self(), :tick_timer)
    else
      Debounce.apply(state.timer_debouncer)
    end
    state
  end

  def timer_finished(state) do
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
          state = update_all_players(state, fn _seat, player -> %{ player | last_discard: nil } end)

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
        state = update_all_players(state, fn seat, player -> %{ player | score: player.score + state.delta_scores[seat] } end)

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
            if is_number(Map.get(score_calculation, "tobi")) do
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
              state = update_all_players(state, fn _seat, player -> %{ player | start_score: player.score } end)
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
          state = Map.put(state, :txns, [])

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

  @spec win(any(), :east | :south | :west | :north, :discard | :draw | :call | :second_discard, binary() | nil) :: any()
  def win(state, seat, win_source, scoring_key) do
    state = Map.put(state, :round_result, :win)

    # reset animation (and allow discarding again, in bloody end rules)
    state = update_all_players(state, fn _seat, player -> %{ player | last_discard: nil } end)

    state = Map.put(state, :game_active, false)
    state = Map.put(state, :visible_screen, :winner)
    state = start_timer(state)

    # populate state.winners
    state = calculate_winner_details_v2(state, seat, win_source, scoring_key)

    hand = (state.players[seat].hand ++ Enum.flat_map(state.players[seat].calls, &Utils.call_to_tiles/1))
    |> Utils.sort_tiles()

    winner = state.winners[seat]
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

    # run after_win actions, using the winner as the context
    winner = state.winners[seat]
    state = Actions.trigger_event(state, "after_win", %{winner | seat: winner.winner_seat})

    # Push message about yaku and score
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
    state = update_all_players(state, fn _seat, player -> %{ player | last_discard: nil } end)

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
    state = update_all_players(state, fn _seat, player -> %{ player | last_discard: nil } end)

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

  defp separate_american_winner_hand(orig_hand, orig_calls, tile_behavior, winning_tile, american_yaku, all_am_yakus) do
    {yaku_name, _value} = Enum.at(american_yaku, 0)
    # look for this yaku in the yaku list, and get arrangement from the match condition
    am_match_definitions = for yaku <- Enum.filter(all_am_yakus, & &1["display_name"] == yaku_name) do
      yaku["when"]
      |> Enum.filter(fn condition -> is_map(condition) and condition["name"] == "match" end)
      |> Enum.at(0)
      |> Map.get("opts")
      |> Enum.at(1)
      |> List.wrap()
    end |> Enum.concat()
    winning_tile = Utils.strip_attrs(winning_tile, :salient)
    arranged_hand = American.arrange_american_hand(am_match_definitions, Utils.strip_attrs(orig_hand, :salient) ++ [winning_tile], orig_calls, tile_behavior)
    if arranged_hand != nil do
      arranged_hand
      |> Enum.intersperse([:"3x"])
      |> Enum.concat()
      |> Enum.reverse()
      |> then(& &1 -- [winning_tile])
      |> Enum.reverse()
    else orig_hand end
  end

  defp separate_standard_winner_hand(smt_hand, smt_calls, calls, tile_behavior, joker_assignment, win_definitions) do
    # replace all hand jokers with their assigned values
    assigned_hand = smt_hand
    |> Enum.with_index()
    |> Enum.map(fn {tile, i} -> case Map.get(joker_assignment, i, nil) do
      nil -> tile
      ret -> ret |> Utils.add_attr(["joker#{i}"])
    end end)
    # make a reverse joker_assignment so we can recover the orig tiles
    # guaranteed to be injective due to the joker#{i} attr we just added
    undo_joker_map = Map.new(joker_assignment, fn {i, _tile} when i < length(smt_hand) ->
      {Enum.at(assigned_hand, i), Enum.at(smt_hand, i)}
    end)
    # restrict aliases to be exactly the joker assignment
    tile_behavior = TileBehavior.from_joker_assignment(tile_behavior, smt_hand ++ Enum.concat(smt_calls), joker_assignment)

    # check if the win definition ever mentions offsets of at least 10
    # e.g. [["exhaustive", [[[0, 0]], 1], [[[0, 10, 20], [0, 1, 2], [0, 0, 0]], 4]]]
    use_kontsu_knitted =
      for win_definition <- win_definitions,
          [groups, _count] <- win_definition,
          group <- groups,
          is_list(group),
          offset <- group,
          is_number(offset),
          offset >= 10,
          reduce: false do
        _ -> true
      end

    # separate sets in this hand
    {winning_tile, input_hand} = List.pop_at(assigned_hand, -1)
    separated_hands = [input_hand ++ [winning_tile]]
    |> Riichi.prepend_group_all(calls, [0, 0, 0, 1, 1, 1, 2, 2, 2], win_definitions, tile_behavior)
    |> Riichi.prepend_group_all(calls, [0, 0, 1, 1, 2, 2], win_definitions, tile_behavior) # TODO not correct for 7 pair hands
    |> Riichi.prepend_group_all(calls, [0, 1, 2], win_definitions, tile_behavior)
    |> Riichi.prepend_group_all(calls, [0, 0, 0], win_definitions, tile_behavior)
    separated_hands = if use_kontsu_knitted do
      separated_hands
      |> Riichi.prepend_group_all(calls, [0, 10, 20], win_definitions, tile_behavior)
      |> Riichi.prepend_group_all(calls, [0, 11, 21], win_definitions, tile_behavior)
    else
      separated_hands
      |> Riichi.prepend_group_all(calls, [0, 0], win_definitions, tile_behavior)
    end
    # result should look like [shuntsu, koutsu, kontsu, toitsu, ungrouped] with each set separated by :separator
    # we could return that, but here we rearrange the order of those groups
    #   to be as close to the original hand as possible

    # take the first hand
    separated_hand = Enum.at(separated_hands, 0, input_hand)
    # delete last instance of winning tile
    |> Enum.reverse()
    |> List.delete(winning_tile)
    |> Enum.reverse()
    groups = Utils.split_on(separated_hand, :separator)
    |> Enum.map(&Utils.sort_tiles/1)
    {groups, [ungrouped]} = Enum.split(groups, -1)
    num_sets = length(groups) + length(calls)
    ordered_hand = Utils.sort_tiles(assigned_hand -- ungrouped, joker_assignment)
    {separated_hand, _leftover_groups, leftover_tiles} =
      for _ <- 1..num_sets, reduce: {[], groups, ordered_hand} do
        {result, groups, [tile | hand]} ->
          case Enum.find_index(groups, &Enum.at(&1, 0) == tile) do
            nil -> {result, groups, hand}
            ix  ->
              {group, groups} = List.pop_at(groups, ix)
              {[group | result], groups, [tile | hand] -- group}
          end
        acc -> acc
      end
    # append the ungrouped part
    # then replace the resulting spacing markers with actual spaces
    separated_hand = [
      Utils.sort_tiles(leftover_tiles -- [winning_tile], joker_assignment),
      Utils.sort_tiles(ungrouped, joker_assignment)
      | separated_hand
    ]
    |> Enum.reverse()
    |> Enum.reject(&Enum.empty?/1)
    |> Enum.intersperse([:"7x"])
    |> Enum.concat()
    # then use the reverse joker mapping, to get the original jokers in this rearrangement
    |> Enum.map(&Map.get(undo_joker_map, &1, &1))

    separated_hand
  end

  @spec calculate_winner_details_v2(any(), seat(), :call | :discard | :draw | :second_discard | :worst_discard, binary() | nil) :: any()
  def calculate_winner_details_v2(state, seat, win_source, scoring_key) do
    # 3 step plan:
    # - calculate all possible joker assignments. for each assignment:
    #   - calculate yaku
    #   - score the yaku (according to scoring_logic)
    #   - obtain a set of txns
    # - take the set of txns that has the highest total score
    # - return that txn set instead of a winner object

    # check if we're dealer
    # handle ryuumonbuchi touka's scoring quirk
    score_as_dealer = "score_as_dealer" in state.players[seat].status
    if score_as_dealer do push_message(state, player_prefix(state, seat) ++ [%{text: "is treated as a dealer for scoring purposes (Ryuumonbuchi Touka)"}]) end
    is_dealer = score_as_dealer or Riichi.is_dealer?(seat, state.kyoku, state.available_seats)
    
    # if we're playing bloody end, record our opponents
    opponents = if Rules.get(state.rules_ref, "bloody_end", false) do
      Enum.reject(state.available_seats, fn dir -> Map.has_key?(state.winners, dir) or dir == seat end)
    else state.available_seats -- [seat] end

    winning_tile = get_winning_tile(state, seat, win_source)
    is_tenhou? = winning_tile == nil

    # push a message if it takes more than 0.5 seconds to return
    # (tenhou solver and joker solver are the same thing)
    # (but it wouldn't do to say "joker solver" when solving tenhou, and vice versa)
    notify_text = if is_tenhou? do "Running tenhou solver..." else "Running joker solver..." end
    notify_task = Task.async(fn -> :timer.sleep(500); push_message(state, [%{text: notify_text}]) end)

    # save original hand to restore later
    %{hand: orig_hand, draw: orig_draw, calls: orig_calls} = state.players[seat]

    # if this is tenhou, we instead create a bunch of possibilities for the winning tile
    hand_calls_tile = if is_tenhou? do
      hand = orig_hand ++ orig_draw
      calls = state.players[seat].calls
      # try each tile, starting from the rightmost
      for winning_tile <- Enum.reverse(Enum.uniq(hand)) do
        {List.delete(hand, winning_tile), calls, winning_tile}
      end
    else [{orig_hand, orig_calls, winning_tile}] end

    # place an empty winner object first, so that modify_winner actions work as intended later on
    state = Map.update!(state, :winners, &Map.put(&1, seat, %{}))
    state = Map.update!(state, :winner_seats, & &1 ++ [seat])

    tile_behavior = state.players[seat].tile_behavior
    {state, cxt} = for {hand, calls, winning_tile} <- hand_calls_tile do
      state = if is_tenhou? do
        # replace hand and draw
        update_player(state, seat, &%{ &1 | hand: hand, draw: [winning_tile] })
      else state end

      # we need to let before_win actions know about the winning tile
      #   so we store it in state.winners
      state = Map.update!(state, :winners, &Map.put(&1, seat, %{winning_tile: winning_tile}))

      # save winning_hand
      # (Q: does anyone actually use this?)
      # (A: ningbo does, like once. should probably rewrite that TODO)
      winning_hand = hand ++ calls ++ [winning_tile]
      state = update_player(state, seat, &%{ &1 | cache: %{ &1.cache | winning_hand: winning_hand } })

      # trigger before_win before solving for jokers
      state = Actions.trigger_event(state, "before_win", %{seat: seat, winner_seat: seat, win_source: win_source, winning_tile: winning_tile})

      # obtain smt_hand and smt_calls after before_win runs
      #   because we may have run actions to modify the hand (e.g. by adding attributes)
      {smt_hand, smt_calls} = JokerSolver.get_smt_hand_calls(state.players[seat].hand, state.players[seat].calls, winning_tile)

      # now calculate joker assignments
      # and find the maximum score obtainable across all joker assignments

      # this is a stream of joker assignments
      joker_assignments = JokerSolver.solve_for_jokers(state.mutex, smt_hand, smt_calls, state.smt_solver, state.rules_ref, tile_behavior)

      # evaluate every joker assignment
      # this turns jokers into normal tiles (via the assignment) and returns the best scoring one
      # returns cxt, which will contain `joker_assignment`, `yaku`, `yaku2`, and `minipoints`
      # note this captures (read: copies) `state` and returns it (read: copies again)
      # TODO avoid this by only capturing and returning the important information
      cxt = %{
        seat: seat,
        winner_seat: seat,
        win_source: win_source,
        smt_hand: smt_hand,
        smt_calls: smt_calls,
        winning_tile: winning_tile,
        winning_hand: winning_hand,
        is_dealer: is_dealer,
        scoring_key: scoring_key,
        rules_ref: state.rules_ref,
      }
      Task.async_stream(joker_assignments, fn joker_assignment ->
        {state, cxt} = try do
          JokerSolver.evaluate_joker_assignment(state, cxt, joker_assignment)
        rescue
          err -> 
            Logger.error(Exception.format(:error, err, __STACKTRACE__))
            nil # should crash
        end
        # make a new txn in state.txns by running scoring_logic
        # this might run the modify_winner action, which is why we place a fake winner object first
        state = Payment.run_scoring_logic(state, cxt)
        {state, cxt}
      end, timeout: :infinity, ordered: false)
      |> Stream.map(fn {:ok, state_cxt} -> state_cxt end)
      |> Payment.get_highest_scoring_txn(win_source == :worst_discard)
      |> case do
        nil ->
          # nil = no joker assignments returned by smt
          # (this happens for hands the solver doesn't support, like milky way)
          {state, cxt} = JokerSolver.evaluate_joker_assignment(state, cxt, %{})
          state = Payment.run_scoring_logic(state, cxt)
          {state, cxt}
        r   -> r
      end
    end
    |> Payment.get_highest_scoring_txn(win_source == :worst_discard)

    # kill the 0.5s timer if it's still sleeping
    if Task.yield(notify_task, 0) == nil do
      Task.shutdown(notify_task, :brutal_kill)
    end

    # restore original hand state
    # this only matters for tenhou, where we run before_scoring on possible tenhou hands
    state = update_player(state, seat, &%{ &1 | hand: orig_hand, draw: orig_draw, calls: orig_calls })

    # push message saying which joker maps to what, excluding obvious jokers
    smt_hand_calls = cxt.smt_hand ++ Enum.concat(cxt.smt_calls)
    obvious_joker_assignment = JokerSolver.get_obvious_joker_assignment(tile_behavior, cxt.smt_hand, cxt.smt_calls)
    non_obvious_joker_assignment = Map.drop(cxt.joker_assignment, Map.keys(obvious_joker_assignment))
    |> Enum.map(fn {joker_ix, tile} -> {Enum.at(smt_hand_calls, joker_ix), tile} end)
    if not Enum.empty?(non_obvious_joker_assignment) do
      joker_assignment_message = non_obvious_joker_assignment
      |> Enum.map_intersperse([%{text: ","}], fn {joker_tile, tile} -> [Utils.pt(joker_tile), %{text: "→"}, Utils.pt(tile)] end)
      |> Enum.concat()
      push_message(state, [%{text: "Using joker assignment"}] ++ joker_assignment_message)
    end

    # create a winner object
    score_rules = Rules.get(state.rules_ref, "score_calculation", %{})
    score = if Rules.get(state.rules_ref, "scoring_logic", nil) != nil do
      state.txns |> Enum.filter(& &1.to == seat) |> Payment.consolidate_txns(true) |> Map.get(seat, %Transaction{}) |> Payment.get_txn_result()
    else
      {score, _points, _points2, _score_name} = ScoringOld.score_yaku(state, seat, cxt.yaku, cxt.yaku2, is_dealer, win_source == :draw, cxt.minipoints)
      score
    end

    # # get assigned_hand and assigned_calls
    # # need to use smt_hand since it might be different from orig_hand in the case of tenhou
    # # still need to pass orig_calls in order to filter out flowers
    # {assigned_hand, assigned_calls, _, _} = JokerSolver.apply_joker_assignment(cxt.smt_hand, orig_calls, cxt.winning_tile, cxt.joker_assignment)

    # arrange the hand for display on yaku screen
    arranged_hand = Utils.sort_tiles(orig_hand -- [cxt.winning_tile], cxt.joker_assignment)

    # arrange the hand more nicely when you hover over it
    separated_hand = if state.ruleset == "american" do
      arrange_american_yaku = Map.get(score_rules, "arrange_american_yaku", false)
      if arrange_american_yaku do
        separate_american_winner_hand(
          orig_hand, orig_calls, tile_behavior, cxt.winning_tile,
          cxt.yaku, Rules.get(state.rules_ref, "yaku", []))
      else arranged_hand end
    else
      separate_standard_winner_hand(
        cxt.smt_hand, cxt.smt_calls, orig_calls, tile_behavior, cxt.joker_assignment,
        Rules.translate_match_definitions(state.rules_ref, ["win"]))
    end

    # player = state.players[seatt]
    winner = Map.merge(cxt,
      %{
        # player: update_in(player.cache, &%{ &1 | assigned_hand: assigned_hand, assigned_calls: assigned_calls }),
        player: state.players[seat],
        existing_yaku: cxt.yaku ++ cxt.yaku2,
        score: score,
        displayed_score: score,
        score_denomination: Map.get(score_rules, "score_denomination", ""),
        point_name: Map.get(score_rules, "point_name", ""),
        point2_name: Map.get(score_rules, "point2_name", ""),
        minipoint_name: Map.get(score_rules, "minipoint_name", ""),
        right_display: cond do
          not Map.has_key?(score_rules, "right_display") -> nil
          score_rules["right_display"] == "points"       -> cxt.points
          score_rules["right_display"] == "points2"      -> cxt.points2
          score_rules["right_display"] == "minipoints"   -> cxt.minipoints
          true                                           -> nil
        end,
        right_display_name: cond do
          not Map.has_key?(score_rules, "right_display") -> nil
          score_rules["right_display"] == "points"       -> Map.get(score_rules, "point_name", "")
          score_rules["right_display"] == "points2"      -> Map.get(score_rules, "point2_name", "")
          score_rules["right_display"] == "minipoints"   -> Map.get(score_rules, "minipoint_name", "")
          true                                           -> nil
        end,
        winning_tile_text: case win_source do
          :draw           -> Map.get(score_rules, "win_by_draw_label", "")
          :second_discard -> Map.get(score_rules, "win_by_discard_label", "")
          :worst_discard  -> Map.get(score_rules, "win_by_discard_label", "")
          :discard        -> Map.get(score_rules, "win_by_discard_label", "")
          :call           -> Map.get(score_rules, "win_by_discard_label", "")
        end,
        opponents: opponents,
        arranged_hand: arranged_hand, # hand to show in the yaku screen
        arranged_calls: orig_calls,
        separated_hand: separated_hand, # hand to show on hover in the yaku screen
      })
    state = Map.update!(state, :winners, &Map.put(&1, seat, Map.merge(winner, &1[seat])))

    state
  end
end
