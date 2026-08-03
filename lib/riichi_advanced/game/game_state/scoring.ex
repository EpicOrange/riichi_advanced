defmodule RiichiAdvanced.GameState.Scoring do
  alias RiichiAdvanced.GameState.Actions, as: Actions
  alias RiichiAdvanced.GameState.Conditions, as: Conditions
  alias RiichiAdvanced.GameState.Debug, as: Debug
  alias RiichiAdvanced.GameState.JokerSolver, as: JokerSolver
  alias RiichiAdvanced.GameState.Payment, as: Payment
  alias RiichiAdvanced.GameState.Rules, as: Rules
  alias RiichiAdvanced.GameState.Scoring, as: Scoring
  alias RiichiAdvanced.GameState.ScoringOld, as: ScoringOld
  alias RiichiAdvanced.Utils, as: Utils
  import RiichiAdvanced.GameState
  use Nebulex.Caching

  def add_yaku_values(value1, value2) do
    # fallback: get the first unit of the first side that has a unit attached
    unit = if is_list(value1) do Enum.at(value1, 1) else if is_list(value2) do Enum.at(value2, 1) else "" end end
    # coerce both to list form
    value1 = if is_list(value1) do value1 else [value1, unit] end
    value2 = if is_list(value2) do value2 else [value2, unit] end
    for [amt, type] <- Enum.chunk_every(value1, 2) ++ Enum.chunk_every(value2, 2), reduce: %{} do
      ret -> Map.update(ret, type, amt, &amt + &1)
    end
    |> Enum.flat_map(fn {type, amt} -> [Utils.try_integer(amt), type] end)
  end

  def update_yaku_amount(yaku, unit, new_amount) do
    case Enum.find_index(yaku, & &1 == unit) do
      nil -> yaku
      i when rem(i, 2) == 1 -> List.replace_at(yaku, i - 1, new_amount)
    end
  end
  def update_yaku_unit(yaku, unit, new_unit) do
    case Enum.find_index(yaku, & &1 == unit) do
      nil -> yaku
      i when rem(i, 2) == 1 -> List.replace_at(yaku, i, new_unit)
    end
  end

  def dedup_yaku(yaku) do
    {acc, order} = for {name, value} <- yaku, reduce: {%{}, []} do
      {acc, order} -> {Map.update(acc, name, value, &add_yaku_values(&1, value)), [name | order]}
    end
    order
    |> Enum.reverse()
    |> Enum.map(&{&1, Map.get(acc, &1)})
  end



  # returns {yaku, minipoints}
  def get_yaku(state, seat, winning_tile, win_source, exclude_extra_yaku? \\ false) do
    minipoints = Map.get(state.players[seat].counters, "fu", 0)
    yaku = _get_yaku(state, seat, winning_tile, win_source, minipoints, exclude_extra_yaku?)
    {yaku, minipoints}
    # |> IO.inspect(label: inspect(winning_tile))
  end

  defp _get_yaku(state, seat, winning_tile, win_source, minipoints, exclude_extra_yaku?) do
    yakus = Rules.get(state.rules_ref, :yaku, [])
    if Debug.debug_yaku() do
      IO.puts("Checking yaku in the following order: #{inspect(Enum.map(yakus, & &1["display_name"]), limit: :infinity)}")
    end
    context = %{
      seat: seat,
      winning_tile: winning_tile,
      win_source: win_source,
      minipoints: minipoints,
      existing_yaku: []
    }
    yaku_skip_map = Rules.get(state.rules_ref, :yaku_skip_map, [])
    excluded_lists = if exclude_extra_yaku? do
      Rules.get(state.rules_ref, "score_calculation", %{})
      |> Map.get("extra_yaku_lists", [])
    else [] end
    {acc, existing_yaku, _skips, _clause_cache} = for yaku <- yakus, reduce: {[], [], MapSet.new(), %{}} do
      {acc, existing_yaku, skips, clause_cache} ->
        if yaku.key not in skips and yaku.list_name not in excluded_lists do
          if Debug.debug_yaku_precedence() do
            IO.puts("Evaluating yaku #{yaku["display_name"]}")
          end
          context = Map.put(context, :existing_yaku, existing_yaku)
          {result, clause_cache} = Conditions.cached_check_cnf_condition(state, yaku["when"], context, clause_cache)
          if result do
            new_skips = MapSet.union(skips, Map.get(yaku_skip_map, yaku.key, MapSet.new()))
            %{"display_name" => name, "value" => value} = yaku
            if name in Debug.debug_specific_yaku() do IO.puts("Yaku #{inspect(yaku.key)}: passed all checks") end
            if yaku.key in new_skips do
              {acc, existing_yaku, new_skips, clause_cache} # we override ourselves
            else
              value = value
              |> Enum.chunk_every(2)
              |> Enum.flat_map(fn [amt, type] -> [Actions.interpret_amount(state, context, amt) |> Utils.try_integer(), type] end)
              {[yaku | acc], [{name, value} | existing_yaku], new_skips, clause_cache}
            end
          else
            if yaku["display_name"] in Debug.debug_specific_yaku() do
              IO.inspect(clause_cache, label: "Yaku #{inspect(yaku.key)}: failed check, clause cache", limit: :infinity)
            end
            {acc, existing_yaku, skips, clause_cache}
          end
        else
          if yaku["display_name"] in Debug.debug_specific_yaku() or Debug.debug_yaku_precedence() do
            IO.puts("Yaku #{inspect(yaku.key)}: skipped due to precedence (current yaku: #{Enum.map_join(acc, ",", &Map.get(&1, "display_name"))})")
          end
          {acc, existing_yaku, skips, clause_cache}
        end
    end
    # since the graph might contain cycles, we need to do a second removal pass
    all_skipped_keys = Enum.flat_map(acc, &Map.get(yaku_skip_map, &1.key, [])) |> MapSet.new()
    acc
    |> Enum.zip(existing_yaku)
    |> Enum.reject(fn {yaku, _ret} -> yaku.key in all_skipped_keys end)
    |> Enum.sort_by(fn {yaku, _ret} -> yaku.ix end)
    |> Enum.map(fn {_yaku, ret} -> ret end)
  end

  def seat_scores_points(state, point_name, min_points, min_minipoints, seat, winning_tiles, win_source) do
    score_yaku(state, seat, winning_tiles, win_source, true)
    |> Enum.any?(fn {yaku, minipoints} ->
      minipoints >= min_minipoints && case min_points do
        :declared ->
          names = Enum.map(yaku, fn {name, _value} -> name end)
          Enum.all?(state.players[seat].declared_yaku, fn yaku -> yaku in names end)
        _ ->
          points = Enum.map(yaku, fn {_name, value} -> value end) |> Enum.reduce([], &Scoring.add_yaku_values/2)
          |> Utils.get_from_points_list(point_name)
          # |> IO.inspect(label: inspect(yaku))
          points >= min_points
      end
    end)
  end

  def score_yaku(state, seat, winning_tiles, win_source, exclude_extra_yaku? \\ false) do
    lazy_map_state_cxts(state, seat, winning_tiles, win_source, fn state, cxt ->
      get_yaku(state, seat, cxt.assigned_winning_tile, win_source, exclude_extra_yaku?)
    end)
  end

  # for every joker assignment and winning tile, call:
  #   f.(state, cxt)
  # returns a stream of results
  # note: the given state will have already called "before_win" and "before_scoring"
  # note: the given state has replaced the state's hand/calls/winning tile
  def lazy_map_state_cxts(state, seat, winning_tiles, win_source, f) do
    %{hand: hand, tile_behavior: tile_behavior} = state.players[seat]
    is_tenhou? = winning_tiles == nil or winning_tiles == [nil]
    if is_tenhou? do hand else winning_tiles end
    |> Enum.uniq()
    |> Enum.map(fn winning_tile ->
      # first, if this was tenhou, we need to remove the winning tile from hand
      hand = if is_tenhou? do
        # delete the winning tile that is rightmost in hand
        hand
        |> Enum.reverse()
        |> List.delete(winning_tile)
        |> Enum.reverse()
      else hand end

      # then update hand
      state = update_player(state, seat, &%{ &1 | hand: hand })

      # we need to let before_win actions know about the winning tile
      #   so we store it in state.winners
      state = Map.update!(state, :winners, &Map.update(&1, seat, %{winning_tile: winning_tile}, fn winner -> Map.put(winner, :winning_tile, winning_tile) end))
      state = update_winning_tile(state, seat, win_source, fn _ -> winning_tile end)

      # trigger before_win before solving for jokers
      state = Actions.trigger_event(state, "before_win", %{seat: seat, win_source: win_source, winning_tile: winning_tile, silent: true})

      # it's possible the winning tile was modified by before_win, so fetch it again
      winning_tile = case get_winning_tile(state, seat, win_source) do
        nil          -> winning_tile # this was tenhou, and we were assigned a winning tile
        winning_tile -> winning_tile
      end

      # obtain smt_hand and smt_calls after before_win runs
      #   because we may have run actions to modify the hand (e.g. by adding attributes)
      {smt_hand, smt_calls} = JokerSolver.get_smt_hand_calls(state.players[seat].hand, state.players[seat].calls, winning_tile)
      # |> IO.inspect(label: inspect(win_source), limit: :infinity)

      # now calculate joker assignments
      # and see if any of them result in a score at least min_points and min_minipoints
      JokerSolver.solve_for_jokers(state.mutex, smt_hand, smt_calls, state.smt_solver, state.rules_ref, tile_behavior)
      |> Task.async_stream(fn {obvious_joker_assignment, nonobvious_joker_assignment} ->
        joker_assignment = Map.merge(obvious_joker_assignment, nonobvious_joker_assignment)
        # apply joker assignments
        {assigned_hand, assigned_calls, _assigned_winning_hand, assigned_winning_tile} = JokerSolver.apply_joker_assignment(state.players[seat].hand, state.players[seat].calls, winning_tile, joker_assignment)
        # IO.inspect({smt_calls, assigned_calls, state.players[seat].calls}, label: inspect(joker_assignment), limit: :infinity)
        # replace the winner's hand/calls temporarily (for yaku evaluation)
        state = update_player(state, seat, &%{ &1 | hand: assigned_hand, calls: assigned_calls, cache: %{ &1.cache | orig_hand: &1.hand, orig_calls: &1.calls, orig_winning_tile: winning_tile } })

        # also replace the actual winning tile within state
        state = if assigned_winning_tile != nil do
          update_winning_tile(state, seat, win_source, fn _ -> assigned_winning_tile end)
        else
          IO.puts("[WARNING] lazy_map_state_cxts: no assigned_winning_tile for a win! hand: #{inspect(smt_hand)}, joker_assignment: #{inspect(joker_assignment)}")
          state
        end

        assigned_winning_hand = assigned_hand ++ Enum.flat_map(assigned_calls, &Utils.call_to_tiles/1) ++ [assigned_winning_tile]
        cxt = %{
          seat: seat,
          win_source: win_source,
          smt_hand: smt_hand,
          smt_calls: smt_calls,
          winning_tile: winning_tile,
          obvious_joker_assignment: obvious_joker_assignment,
          nonobvious_joker_assignment: nonobvious_joker_assignment,
          joker_assignment: joker_assignment,
          assigned_hand: assigned_hand,
          assigned_calls: assigned_calls,
          assigned_winning_tile: assigned_winning_tile,
          assigned_winning_hand: assigned_winning_hand,
        }

        # run before_scoring
        # this is because before_scoring might add attributes to hand, which will be used for yaku calculation
        # also you need non-joker tiles in order to calculate fu and such here
        state = Actions.trigger_event(state, "before_scoring", cxt)

        # fetch the new hand, calls, and winning tile
        %{hand: assigned_hand, calls: assigned_calls} = state.players[seat]
        assigned_winning_tile = get_winning_tile(state, seat, win_source)
        if assigned_winning_tile == nil do
          IO.puts("[WARNING] lazy_map_state_cxts: the winning tile must exist, but got nil")
        end

        assigned_winning_hand = assigned_hand ++ Enum.flat_map(assigned_calls, &Utils.call_to_tiles/1) ++ [assigned_winning_tile]
        cxt = %{ cxt |
          assigned_hand: assigned_hand,
          assigned_calls: assigned_calls,
          assigned_winning_tile: assigned_winning_tile,
          assigned_winning_hand: assigned_winning_hand,
        }

        f.(state, cxt)
      end, timeout: :infinity, ordered: false)
    end)
    |> Stream.concat()
    |> Stream.map(fn {:ok, ret} -> ret end)
    # |> Enum.to_list() |> IO.inspect(label: inspect(win_source))
  end
  
  def evaluate_state_cxt(state, cxt) do
    %{
      seat: seat,
      win_source: win_source,
      winning_tile: winning_tile,
      assigned_winning_tile: assigned_winning_tile,
    } = cxt
    score_rules = Rules.get(state.rules_ref, "score_calculation", %{})

    # obtain yaku and minipoints from this state
    {yaku, minipoints} = Scoring.get_yaku(state, seat, assigned_winning_tile, win_source)
    if Debug.print_wins() do
      assigned_winning_hand = state.players[seat].cache.winning_hand
      IO.puts("checking assignment, hand: #{inspect(assigned_winning_hand)}, tile: #{inspect(winning_tile)}, yaku: #{inspect(yaku)}")
    end

    highest_scoring_yaku_only = Map.get(score_rules, "highest_scoring_yaku_only", false)
    yaku = if not Enum.empty?(yaku) and highest_scoring_yaku_only do [Enum.max_by(yaku, fn {_name, value} -> value end)] else yaku end
    yaku = Enum.map(yaku, fn {name, value} -> {translate(state, name), value} end) |> Scoring.dedup_yaku()
    points = Enum.map(yaku, fn {_name, value} -> value end) |> Enum.reduce([], &Scoring.add_yaku_values/2)

    # put back hand/calls/winning tile
    state = state
    |> update_player(seat, &%{ &1 | hand: &1.cache.orig_hand, calls: &1.cache.orig_calls })
    |> update_winning_tile(seat, win_source, fn _ -> winning_tile end)

    cxt = Map.merge(cxt, %{
      yaku: yaku,
      minipoints: minipoints,
      points: Utils.get_from_points_list(points, score_rules["point_name"]),
      points2: Utils.get_from_points_list(points, score_rules["point2_name"]),
      shuugi: Utils.get_from_points_list(points, score_rules["shuugi_name"]),
      total_points: points,
    })
    {state, cxt}
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
    # TODO replace with after_win stuff
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
        if Rules.get(state.rules_ref, "scoring_logic", nil) == nil do
          # old method
          IO.puts("WARNING: using old scoring method to calculate delta scores")
          for {_seat, deltas} <- ScoringOld.calculate_delta_scores_per_player(state, winners), reduce: delta_scores do
            delta_scores_acc -> Map.new(delta_scores_acc, fn {seat, delta} -> {seat, delta + deltas[seat]} end)
          end
        else Map.new(state.players, fn {seat, _player} -> {seat, 0} end) end
      end
      
    # multiply by delta_score_multiplier counter, if it exists
    delta_scores = Map.new(delta_scores, fn {seat, delta} -> {seat, delta * Map.get(state.players[seat].counters, "delta_score_multiplier", 1)} end)

    # add delta_score counter, if it exists
    delta_scores = Map.new(delta_scores, fn {seat, delta} -> {seat, delta + Map.get(state.players[seat].counters, "delta_score", 0)} end)

    is_tsumo = Enum.any?(winners, fn {_seat, winner} -> winner.win_source == :draw end)
    is_pao = Enum.any?(winners, fn {_seat, winner} -> "pao" in winner.player.status end)

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

    {state, delta_scores, delta_scores_reason}
  end

  def adjudicate_draw_scoring(state) do
    score_rules = Rules.get(state.rules_ref, "score_calculation", %{})
    delta_scores = Map.new(state.players, fn {seat, _player} -> {seat, 0} end)

    delta_scores =
      if not Enum.empty?(state.txns) do
        # obtain delta scores through state.txns
        totals_by_seat = Payment.consolidate_txns(state.txns) |> Map.new(fn {seat, txn} -> {seat, Payment.get_txn_result(txn)} end)
        for seat <- state.available_seats, into: %{} do
          {seat, Map.get(totals_by_seat, seat, 0)}
        end
      else delta_scores end

    # handle hanada kirame's scoring quirk
    {state, delta_scores} = hanada_kirame_score_protection(state, delta_scores)

    delta_scores_reason = Map.get(score_rules, "exhaustive_draw_name", "Draw")

    {state, delta_scores, delta_scores_reason}
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
  