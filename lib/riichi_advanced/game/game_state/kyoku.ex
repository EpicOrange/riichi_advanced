
defmodule RiichiAdvanced.GameState.Kyoku do
  alias RiichiAdvanced.GameState.Actions, as: Actions
  alias RiichiAdvanced.GameState.American, as: American
  alias RiichiAdvanced.GameState.Buttons, as: Buttons
  alias RiichiAdvanced.GameState.Log, as: Log
  alias RiichiAdvanced.GameState.Payment, as: Payment
  alias RiichiAdvanced.GameState.Rules, as: Rules
  alias RiichiAdvanced.GameState.Scoring, as: Scoring
  alias RiichiAdvanced.GameState.ScoringOld, as: ScoringOld
  alias RiichiAdvanced.GameState.TileBehavior, as: TileBehavior
  alias RiichiAdvanced.GameState.JokerSolver, as: JokerSolver
  alias RiichiAdvanced.Riichi, as: Riichi
  alias RiichiAdvanced.Utils, as: Utils
  alias RiichiAdvanced.Types, as: Types
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

    # run before_win actions
    state = Actions.trigger_event(state, "before_win", %{seat: seat, win_source: win_source})

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

    # run after_win actions
    state = Actions.trigger_event(state, "after_win", %{seat: seat, win_source: win_source})

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



  # rearrange the winner's hand for display on the yaku display screen
  def rearrange_winner_hand(state, seat, joker_assignment, winning_tile, american_yaku \\ nil) do
    # t = System.system_time(:millisecond)

    score_rules = Rules.get(state.rules_ref, "score_calculation", %{})

    # annotate the original hand with joker assignment indices
    # this is because later we want to match on this hand,
    # and these indices help match use this joker assignment rather than any assignment
    orig_hand = state.players[seat].hand
    |> Enum.with_index()
    |> Enum.map(fn {tile, i} -> Utils.add_attr(tile, ["hand#{i}"]) end)
    orig_calls = state.players[seat].calls
    tile_behavior = state.players[seat].tile_behavior
    arrange_american_yaku = Map.get(score_rules, "arrange_american_yaku", false)
    if arrange_american_yaku and american_yaku != nil do
      {yaku_name, _value} = Enum.at(american_yaku, 0)
      # look for this yaku in the yaku list, and get arrangement from the match condition
      am_yakus = Rules.get(state.rules_ref, "yaku", [])
      |> Enum.filter(fn y -> y["display_name"] == yaku_name end)
      am_yaku_match_conds = Enum.at(am_yakus, 0)["when"] |> Enum.filter(fn condition -> is_map(condition) and condition["name"] == "match" end)
      am_match_definitions = Enum.at(Enum.at(am_yaku_match_conds, 0)["opts"], 1)
      winning_tile = Utils.strip_attrs(winning_tile, :salient)
      arranged_hand = American.arrange_american_hand(am_match_definitions, Utils.strip_attrs(orig_hand, :salient) ++ [winning_tile], orig_calls, tile_behavior)
      {arranged_hand, arranged_calls} = if arranged_hand != nil do
        arranged_hand = arranged_hand
        |> Enum.intersperse([:"3x"])
        |> Enum.concat()
        |> Enum.reverse()
        |> then(& &1 -- [winning_tile])
        |> Enum.reverse()
        {arranged_hand, []}
      else {orig_hand, orig_calls} end
      %{ hand: arranged_hand, separated_hand: arranged_hand, calls: arranged_calls }
    else
      # otherwise, sort jokers into the hand
      arranged_hand = Utils.sort_tiles(orig_hand, joker_assignment)
      arranged_calls = orig_calls

      # get smt hand for the next steps
      smt_hand = orig_hand ++ if winning_tile != nil do [winning_tile] else [] end
      smt_calls = state.players[seat].calls
      |> Enum.reject(fn {call_name, _call} -> call_name in Riichi.flower_names() end)
      |> Enum.map(&Utils.call_to_tiles/1)

      # create an alternate separated_hand where sets are separated
      win_definitions = Rules.translate_match_definitions(state.rules_ref, ["win"])
      assigned_tile_behavior = TileBehavior.from_joker_assignment(tile_behavior, smt_hand ++ Enum.concat(smt_calls), joker_assignment)
      separated_hands = [arranged_hand]
      |> Riichi.prepend_group_all(orig_calls, [winning_tile], [0, 0, 0, 1, 1, 1, 2, 2, 2], win_definitions, assigned_tile_behavior)
      |> Riichi.prepend_group_all(orig_calls, [winning_tile], [0, 0, 1, 1, 2, 2], win_definitions, assigned_tile_behavior)
      |> Riichi.prepend_group_all(orig_calls, [winning_tile], [0, 1, 2], win_definitions, assigned_tile_behavior)
      |> Riichi.prepend_group_all(orig_calls, [winning_tile], [0, 0, 0], win_definitions, assigned_tile_behavior)
      # kontsu/knitted
      separated_hands2 = separated_hands
      |> Riichi.prepend_group_all(orig_calls, [winning_tile], [0, 10, 20], win_definitions, assigned_tile_behavior)
      |> Riichi.prepend_group_all(orig_calls, [winning_tile], [0, 11, 21], win_definitions, assigned_tile_behavior)
      # only split pairs if knitted did not match
      separated_hands = if separated_hands == separated_hands2 do
        Riichi.prepend_group_all(separated_hands, orig_calls, [winning_tile], [0, 0], win_definitions, assigned_tile_behavior)
      else separated_hands2 end
      # result should look like [shuntsu, koutsu, kontsu, toitsu, ungrouped] with each set separated by :separator
      # rearrange those groups to be as close to the original hand as possible
      separated_hand = Enum.at(separated_hands, 0, arranged_hand)
      groups = Utils.split_on(separated_hand, :separator)
      {groups, [ungrouped]} = Enum.split(groups, -1)
      {separated_hand, _, _} = for _ <- groups, reduce: {[], groups, arranged_hand -- ungrouped} do
        {result, groups, [tile | hand]} ->
          case Enum.find_index(groups, & Enum.at(&1, 0) == tile) do
            nil -> {result, groups, hand}
            ix  ->
              {group, groups} = List.pop_at(groups, ix)
              {[group | result], groups, [tile | hand] -- group}
          end
        acc -> acc
      end
      # append the ungrouped part
      # then replace the resulting spacing markers with actual spaces
      separated_hand = [ungrouped | separated_hand]
      |> Enum.reverse()
      |> Enum.intersperse([:"7x"])
      |> Enum.concat()  

      # push message saying which joker maps to what, excluding obvious jokers
      obvious_joker_assignment = JokerSolver.get_obvious_joker_assignment(tile_behavior, smt_hand, smt_calls)
      non_obvious_joker_assignment = Map.drop(joker_assignment, Map.keys(obvious_joker_assignment))
      |> Enum.map(fn {joker_ix, tile} -> {Enum.at(smt_hand ++ Enum.concat(smt_calls), joker_ix), tile} end)
      if not Enum.empty?(non_obvious_joker_assignment) do
        joker_assignment_message = non_obvious_joker_assignment
        |> Enum.map_intersperse([%{text: ","}], fn {joker_tile, tile} -> [Utils.pt(joker_tile), %{text: "→"}, Utils.pt(tile)] end)
        |> Enum.concat()
        push_message(state, [%{text: "Using joker assignment"}] ++ joker_assignment_message)
      end

      %{ hand: arranged_hand, separated_hand: separated_hand, calls: arranged_calls }
    end
  end

  @spec calculate_winner_details_v2(any(), seat(), :best_draw | :call | :discard | :draw | :second_discard | :worst_discard, binary() | nil) :: any()
  def calculate_winner_details_v2(state, seat, win_source, scoring_key) do
    # push a message if it takes more than 0.5 seconds to return
    notify_task = Task.async(fn -> :timer.sleep(500); push_message(state, [%{text: "Running joker solver..."}]) end)

    # 5 step plan:
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

    # save orig hand
    orig_hand = state.players[seat].hand
    orig_calls = state.players[seat].calls

    # place an empty winner object first, so that modify_winner works as intended later on
    state = Map.update!(state, :winners, &Map.put(&1, seat, %{}))
    state = Map.update!(state, :winner_seats, & &1 ++ [seat])

    {state, cxt} = for {smt_hand, smt_calls} <- JokerSolver.get_smt_hand_calls(state, seat, winning_tile) do
      # temporarily replace hand with given smt hand and calls
      state = update_player(state, seat, &%{ &1 | hand: Enum.drop(smt_hand, -1), calls: smt_calls })

      # save this hand for the win screen
      winning_hand = smt_hand ++ smt_calls
      state = update_player(state, seat, &%{ &1 | cache: %{ &1.cache | winning_hand: winning_hand } })

      # run before_scoring
      state = Actions.trigger_event(state, "before_scoring", %{seat: seat, win_source: win_source})

      # now calculate joker assignments
      # and find the maximum score obtainable across all joker assignments
      cxt = %{
        seat: seat,
        win_source: win_source,
        smt_hand: smt_hand,
        smt_calls: smt_calls,
        winning_tile: winning_tile,
        winning_hand: winning_hand,
        is_dealer: is_dealer,
        scoring_key: scoring_key,
        rules_ref: state.rules_ref,
      }

      # this is a stream of joker assignments
      joker_assignments = JokerSolver.solve_for_jokers(smt_hand, smt_calls, state.smt_solver, state.rules_ref, state.players[seat].tile_behavior)

      # evaluate every joker assignment
      # this turns jokers into normal tiles (via the assignment) and returns the best scoring one
      # returns cxt, which will contain `joker_assignment`, `yaku`, `yaku2`, and `minipoints`
      # note this captures (read: copies) `state` and returns it (read: copies again)
      # TODO avoid this by only capturing and returning the important information
      Task.async_stream(joker_assignments, fn joker_assignment ->
        cxt = try do
          JokerSolver.evaluate_joker_assignment(state, cxt, joker_assignment)
        rescue
          err -> 
            Logger.error(Exception.format(:error, err, __STACKTRACE__))
            cxt
        end
        # make a new txn in state.txns by running scoring_logic
        # this might run the modify_winner action, which is why we place a fake winner object first
        state = Payment.run_scoring_logic(state, cxt)
        {state, cxt}
      end, timeout: :infinity, ordered: false)
      |> Stream.map(fn {:ok, state_cxt} -> state_cxt end)
      |> Payment.get_highest_scoring_txn(win_source == :worst_discard)
      |> case do
        # no joker assignments returned by smt (this should not happen)
        nil -> Logger.error("[ERROR] no joker assignments returned by smt for hand #{smt_hand} #{smt_calls}")
        r -> r
      end
    end
    |> Payment.get_highest_scoring_txn(win_source == :worst_discard)

    # kill the 0.5s timer if it's still sleeping
    if Task.yield(notify_task, 0) == nil do
      Task.shutdown(notify_task, :brutal_kill)
    end

    # rearrange the winner's hand for display purposes
    %{
      hand: arranged_hand,
      separated_hand: separated_hand,
      calls: arranged_calls
    } = rearrange_winner_hand(state, seat, cxt.joker_assignment, winning_tile)

    # restore original hand/calls
    state = update_player(state, seat, &%{ &1 | hand: orig_hand, calls: orig_calls })

    # create a winner object since the liveview requires it
    score_rules = Rules.get(state.rules_ref, "score_calculation", %{})
    # payer = case win_source do
    #   :draw           -> nil
    #   :best_draw      -> nil
    #   :second_discard -> get_last_discard_action(state).seat
    #   :worst_discard  -> get_last_discard_action(state).seat
    #   :discard        -> get_last_discard_action(state).seat
    #   :call           -> get_last_call_action(state).seat
    # end
    score = if Map.get(cxt, :scoring_key) != nil do
      state.txns |> Enum.filter(& &1.to == seat) |> Payment.consolidate_txns() |> Map.get(seat) |> Payment.get_txn_result()
    else
      {score, _points, _points2, _score_name} = ScoringOld.score_yaku(state, seat, cxt.yaku, cxt.yaku2, is_dealer, win_source == :draw, cxt.minipoints)
      score
    end
    winner = Map.merge(cxt,
      %{
        player: %{ state.players[seat] | hand: arranged_hand, calls: arranged_calls },
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
          :best_draw      -> Map.get(score_rules, "win_by_draw_label", "")
          :second_discard -> Map.get(score_rules, "win_by_discard_label", "")
          :worst_discard  -> Map.get(score_rules, "win_by_discard_label", "")
          :discard        -> Map.get(score_rules, "win_by_discard_label", "")
          :call           -> Map.get(score_rules, "win_by_discard_label", "")
        end,
        opponents: opponents,
        separated_hand: separated_hand,
        arranged_hand: arranged_hand,
        arranged_calls: arranged_calls,
      })
    state = Map.update!(state, :winners, &Map.put(&1, seat, Map.merge(winner, &1[seat])))

    state
  end
end
