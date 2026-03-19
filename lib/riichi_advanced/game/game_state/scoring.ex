
defmodule RiichiAdvanced.GameState.Scoring do
  alias RiichiAdvanced.GameState.Actions, as: Actions
  alias RiichiAdvanced.GameState.Conditions, as: Conditions
  alias RiichiAdvanced.GameState.Debug, as: Debug
  alias RiichiAdvanced.GameState.JokerSolver, as: JokerSolver
  alias RiichiAdvanced.GameState.Payment, as: Payment
  alias RiichiAdvanced.GameState.Rules, as: Rules
  alias RiichiAdvanced.GameState.Scoring, as: Scoring
  alias RiichiAdvanced.GameState.ScoringOld, as: ScoringOld
  alias RiichiAdvanced.Riichi, as: Riichi
  alias RiichiAdvanced.Utils, as: Utils
  import RiichiAdvanced.GameState

  def add_yaku_values(value1, value2) do
    # fallback: get the first unit of the first side that has a unit attached
    unit = if is_list(value1) do Enum.at(value1, 1) else if is_list(value2) do Enum.at(value2, 1) else "" end end
    # coerce both to list form
    value1 = if is_list(value1) do value1 else [value1, unit] end
    value2 = if is_list(value2) do value2 else [value2, unit] end
    for [amt, type] <- Enum.chunk_every(value1, 2) ++ Enum.chunk_every(value2, 2), reduce: %{} do
      ret -> Map.update(ret, type, amt, &amt + &1)
    end
    |> Enum.flat_map(fn {type, amt} -> [amt, type] end)
  end

  def get_yaku(state, yaku_list, yaku_list_name, seat, winning_tile, win_source, minipoints, existing_yaku \\ []) do
    context = %{
      seat: seat,
      winning_tile: winning_tile,
      win_source: win_source,
      minipoints: minipoints,
      existing_yaku: existing_yaku
    }
    new_yaku = yaku_list
      |> Enum.filter(fn %{"when" => cond_spec} -> Conditions.check_cnf_condition(state, cond_spec, context) end)
      |> Enum.map(fn %{"display_name" => name, "value" => value} ->
        if is_list(value) do
          value = value
          |> Enum.chunk_every(2)
          |> Enum.flat_map(fn [amt, type] -> [Actions.interpret_amount(state, context, amt), type] end)
          {name, value}
        else
          value = Actions.interpret_amount(state, context, value)
          # default to point_name for the units
          score_rules = Rules.get(state.rules_ref, "score_calculation", %{})
          # for rulesets that don't specify units of points for yakuman lists, use the point name only
          unit = score_rules["point_name"]
          {name, [value, unit]}
        end
      end)
    eligible_yaku = existing_yaku ++ new_yaku
    yaku_map = for {name, value} <- eligible_yaku, reduce: %{} do
      acc -> Map.update(acc, name, value, &add_yaku_values(&1, value))
    end
    eligible_yaku = eligible_yaku
      |> Enum.map(fn {name, _value} -> name end)
      |> Enum.uniq()
      |> Enum.map(fn name -> {name, yaku_map[name]} end)
    eligible_yaku = case Rules.get(state.rules_ref, "yaku_precedence") do
      nil -> eligible_yaku
      yaku_precedence ->
        excluded_yaku = Enum.flat_map(new_yaku, fn {name, _value} -> Map.get(yaku_precedence, name, []) end)
        excluded_yaku = if Enum.empty?(new_yaku) do [] else Map.get(yaku_precedence, yaku_list_name, []) end ++ excluded_yaku
        if Debug.debug_yaku_precedence() and Enum.any?(eligible_yaku, fn {name, _value} -> name in excluded_yaku end) do
          used_precedence = Enum.filter(yaku_precedence, fn {from, _to} -> Enum.any?(eligible_yaku, fn {name, _value} -> from == name end) or from == yaku_list_name end) |> Map.new()
          IO.puts("Excluding yaku #{inspect(excluded_yaku)} from #{inspect(eligible_yaku)} due to precedence: #{inspect(used_precedence)}")
        end
        Enum.reject(eligible_yaku, fn {name, value} -> Enum.any?(excluded_yaku, &Enum.member?([name | List.wrap(value)], &1)) end)
    end
    eligible_yaku
  end

  def get_yaku_from_lists(state, yaku_list_names, seat, winning_tile, win_source) do
    # returns {yaku, minipoints}
    score_rules = Rules.get(state.rules_ref, "score_calculation", %{})
    declare_only_yaku_list_names = Map.get(score_rules, "declare_only_yaku_lists", [])
    for yaku_list_name <- yaku_list_names, reduce: {[], 0} do
      {yaku, minipoints} ->
        if Rules.has_key?(state.rules_ref, yaku_list_name) do
          yaku_list = if yaku_list_name in declare_only_yaku_list_names do
            declared_yaku = state.players[seat].declared_yaku
            Enum.filter(Rules.get(state.rules_ref, yaku_list_name, []), fn yaku_obj -> yaku_obj["display_name"] in declared_yaku end)
          else Rules.get(state.rules_ref, yaku_list_name, []) end
          minipoints = Map.get(state.players[seat].counters, "fu", 0)
          yaku = get_yaku(state, yaku_list, yaku_list_name, seat, winning_tile, win_source, minipoints, yaku)
          {yaku, minipoints}
        else
          {yaku, minipoints}
        end
    end
  end

  # TODO replace inner loop with JokerSolver.evaluate_joker_assignment?
  # this is only here bc of shortcutting
  def seat_scores_points(state, yaku_list_names, min_points, min_minipoints, seat, winning_tile, win_source) do
    for {smt_hand, smt_calls} <- JokerSolver.get_smt_hand_calls(state, seat, winning_tile) do
      JokerSolver.solve_for_jokers(
        smt_hand, smt_calls,
        state.smt_solver,
        state.rules_ref,
        state.players[seat].tile_behavior)
      |> Task.async_stream(fn joker_assignment ->
        # apply joker assignments
        {assigned_hand, assigned_calls, assigned_winning_hand, assigned_winning_tile} = JokerSolver.apply_joker_assignment(smt_hand, state.players[seat].calls, joker_assignment)
        state = update_player(state, seat, &%{ &1 | hand: assigned_hand, calls: assigned_calls, cache: %{ &1.cache | winning_hand: assigned_winning_hand } })
        state = if assigned_winning_tile != nil do
          update_winning_tile(state, seat, win_source, fn _ -> assigned_winning_tile end)
        else state end
        # run before_win actions
        state = Actions.trigger_event(state, "before_win", %{seat: seat, win_source: win_source, winning_tile: assigned_winning_tile, silent: true})
        # run before_scoring actions
        state = Actions.trigger_event(state, "before_scoring", %{seat: seat, win_source: win_source, winning_tile: assigned_winning_tile, silent: true})
        
        # get winning tile, ensure this happens after running before_scoring above
        {yaku, minipoints} = get_yaku_from_lists(state, yaku_list_names, seat, winning_tile, win_source)
        minipoints >= min_minipoints && case min_points do
          :declared ->
            names = Enum.map(yaku, fn {name, _value} -> name end)
            Enum.all?(state.players[seat].declared_yaku, fn yaku -> yaku in names end)
          _ ->
            points = Enum.map(yaku, fn {_name, value} -> value end) |> Enum.reduce([], &Scoring.add_yaku_values/2)
            points >= min_points
        end
      end, timeout: :infinity, ordered: false)
    end
    |> Enum.concat()
    |> Enum.any?(fn {:ok, result} -> result end)
  end
  
  def hanada_kirame_score_protection(state, delta_scores) do
    case Enum.find(state.players, fn {_seat, player} -> "hanada-kirame" in player.status end) do
      {hanada_kirame_seat, hanada_kirame} ->
        if "hanada_kirame_score_protection" in hanada_kirame.status and hanada_kirame.score + delta_scores[hanada_kirame_seat] < 0 do
          push_message(state, player_prefix(state, hanada_kirame_seat) ++ [%{text: "stays at zero points, and receives 8000 points from first place (Hanada Kirame)"}])
          scores = Enum.map(state.players, fn {seat, player} -> {seat, player.score + delta_scores[seat]} end)
          {first_seat, _} = Enum.max_by(scores, fn {_seat, score} -> score end)
          state = update_player(state, hanada_kirame_seat, fn player -> %{ player | status: player.status ++ ["hanada-kirame_exhausted"] } end)
          delta_scores = delta_scores
          |> Map.put(hanada_kirame_seat, 8000 - hanada_kirame.score)
          |> Map.update!(first_seat, & &1 - 8000)
          {state, delta_scores}
        else {state, delta_scores} end
      _ -> {state, delta_scores}
    end
  end
  
  def adjudicate_win_scoring(state) do
    score_rules = Rules.get(state.rules_ref, "score_calculation", %{})
    delta_scores = Map.new(state.players, fn {seat, _player} -> {seat, 0} end)

    # handle nelly virsaladze's scoring quirk
    {state, delta_scores} = for {seat, player} <- state.players, reduce: {state, delta_scores} do
      {state, delta_scores} ->
        if "nelly_virsaladze_take_bets" in player.status do
          push_message(state, player_prefix(state, seat) ++ [%{text: "takes all bets on the table (%{pot}) and is paid 1500 by every player (Nelly Virsaladze)", vars: %{pot: state.pot}}])
          delta_scores = Map.update!(delta_scores, seat, & &1 + state.pot + 4500)
          delta_scores = for {dir, _player} <- state.players, dir != seat, reduce: delta_scores do
            delta_scores -> Map.update!(delta_scores, dir, & &1 - 1500)
          end
          state = Map.put(state, :pot, 0)
          {state, delta_scores}
        else {state, delta_scores} end
    end

    # we will calculate score for winners who have not already been processed
    winners = Enum.reject(state.winners, fn {_seat, winner} -> Map.has_key?(winner, :processed) end) |> Map.new()

    # mark all winners as processed
    state = Map.update!(state, :winners, &Map.new(&1, fn {seat, winner} -> {seat, Map.put(winner, :processed, true)} end))

    # check for sanchahou; clear winners in that case
    sanchahou = Map.get(score_rules, "triple_ron_draw", false) and map_size(winners) == 3
    winners = if sanchahou do %{} else winners end

    # calculate the delta scores
    
    delta_scores =
      if not Enum.empty?(state.txns) do
        # obtain delta scores through state.txns
        totals_by_seat = Payment.consolidate_txns(state.txns) |> Map.new(fn {seat, txn} -> {seat, Payment.get_txn_result(txn)} end)
        for seat <- state.available_seats, into: %{} do
          {seat, Map.get(totals_by_seat, seat, 0)}
        end
      else
        # old method
        for {_seat, deltas} <- ScoringOld.calculate_delta_scores_per_player(state, winners), reduce: delta_scores do
          delta_scores_acc -> Map.new(delta_scores_acc, fn {seat, delta} -> {seat, delta + deltas[seat]} end)
        end
      end
      
    # multiply by delta_score_multiplier counter, if it exists
    delta_scores = Map.new(delta_scores, fn {seat, delta} -> {seat, delta * Map.get(state.players[seat].counters, "delta_score_multiplier", 1)} end)

    # add delta_score counter, if it exists
    delta_scores = Map.new(delta_scores, fn {seat, delta} -> {seat, delta + Map.get(state.players[seat].counters, "delta_score", 0)} end)

    is_tsumo = Enum.any?(winners, fn {_seat, winner} -> winner.win_source == :draw end)
    is_pao = Enum.any?(winners, fn {_seat, winner} -> not Enum.empty?(winner.player.responsibilities) end) # TODO this is wrong now

    # handle ezaki hitomi's scoring quirk
    {state, delta_scores} = if is_tsumo do
      for {seat, player} <- state.players, reduce: {state, delta_scores} do
        {state, delta_scores} ->
          if "ezaki_hitomi_bet_instead" in player.status do
            # figure out our payment
            delta = delta_scores[seat]
            payment = -delta

            # figure out who the winner is, and their payment (there is only one for tsumo)
            {winner_seat, winner_delta} = Enum.max_by(delta_scores, fn {_seat, delta} -> delta end)

            # zero the payment, so the winner wins less
            delta_scores = delta_scores
            |> Map.put(seat, 0)
            |> Map.put(winner_seat, winner_delta - payment)

            # put the payment in the pot
            push_message(state, player_prefix(state, seat) ++ [%{text: "bets their tsumo payment instead of paying out (Ezaki Hitomi)"}])
            state = Map.put(state, :pot, payment)

            {state, delta_scores}
          else {state, delta_scores} end
      end
    else {state, delta_scores} end

    # handle hanada kirame's scoring quirk
    {state, delta_scores} = hanada_kirame_score_protection(state, delta_scores)

    # multiply by delta_score_multiplier counter, if it exists
    delta_scores = Map.new(delta_scores, fn {seat, delta} -> {seat, delta * Map.get(state.players[seat].counters, "delta_score_multiplier", 1)} end)

    # add delta_score counter, if it exists
    delta_scores = Map.new(delta_scores, fn {seat, delta} -> {seat, delta + Map.get(state.players[seat].counters, "delta_score", 0)} end)

    # get delta scores reason
    is_draw = state.round_result in [:exhaustive_draw, :abortive_draw]
    delta_scores_reason = cond do
      is_draw                      -> Map.get(score_rules, "exhaustive_draw_name", "Draw")
      sanchahou                    -> Map.get(score_rules, "triple_win_draw_name", "Sanchahou")
      is_pao                       -> Map.get(score_rules, "win_with_pao_name", "Sekinin Barai")
      is_tsumo                     -> Map.get(score_rules, "win_by_draw_name", "Win by Draw")
      map_size(winners) == 1       -> Map.get(score_rules, "win_by_discard_name", "Win by Discard")
      map_size(winners) == 2       -> Map.get(score_rules, "win_by_discard_name_2", Map.get(score_rules, "win_by_discard_name", "Win by Discard"))
      map_size(winners) == 3       -> Map.get(score_rules, "win_by_discard_name_3", Map.get(score_rules, "win_by_discard_name", "Win by Discard"))
    end

    # get next dealer
    agarirenchan = Map.get(score_rules, "agarirenchan", false)
    next_dealer_is_first_winner = Map.get(score_rules, "next_dealer_is_first_winner", false)
    next_dealer = cond do
      next_dealer_is_first_winner and map_size(winners) == map_size(state.winners) ->
        {_seat, winner} = Enum.at(winners, 0)
        dealer_seat = Riichi.get_east_player_seat(state.kyoku, state.available_seats)
        new_dealer_seat = cond do
          is_draw                -> dealer_seat # if there is no first winner, dealer stays the same
          map_size(winners) == 1 -> winner.seat # otherwise, the first winner becomes the next dealer
          true                   -> get_last_discard_action(state).seat # if there are multiple first winners, the loser becomes the next dealer instead
        end
        Utils.get_relative_seat(dealer_seat, new_dealer_seat)
      agarirenchan and Riichi.get_east_player_seat(state.kyoku, state.available_seats) in state.winner_seats -> :self
      true -> :shimocha
    end

    # run before_win actions for each new winner
    state = if Rules.has_key?(state.rules_ref, "before_win") do
      for {_seat, winner} <- winners, reduce: state do
        # not sure if this is a good idea, but conveniently, winner objects can be used as a context
        state -> Actions.trigger_event(state, "before_win", winner)
      end
    else state end

    {state, delta_scores, delta_scores_reason, next_dealer}
  end

  def adjudicate_draw_scoring(state) do
    score_rules = Rules.get(state.rules_ref, "score_calculation", %{})
    tenpai = Map.new(state.players, fn {seat, player} -> {seat, "tenpai" in player.status} end)
    delta_scores = Map.new(state.players, fn {seat, _player} -> {seat, 0} end)

    # handle hanada kirame's scoring quirk
    {state, delta_scores} = hanada_kirame_score_protection(state, delta_scores)

    delta_scores_reason = Map.get(score_rules, "exhaustive_draw_name", "Draw")

    tenpairenchan = Map.get(score_rules, "tenpairenchan", false)
    notenrenchan_south = Map.get(score_rules, "notenrenchan_south", false)
    next_dealer = cond do
      tenpairenchan and tenpai[Riichi.get_east_player_seat(state.kyoku, state.available_seats)] -> :self
      notenrenchan_south and Riichi.get_round_wind(state.kyoku, length(state.available_seats)) == :south -> :self
      true -> :shimocha
    end

    {state, delta_scores, delta_scores_reason, next_dealer}
  end

  def ensure_scoring_method(state) do
    case Rules.get(state.rules_ref, "score_calculation", %{}) do
      nil -> show_error(state, "\"score_calculation\" key is missing from rules!")
      score_rules ->
        if Map.has_key?(score_rules, "scoring_method") do
          state
        else
          show_error(state, "\"score_calculation\" object lacks \"scoring_method\" key!")
        end
    end
  end


end
  