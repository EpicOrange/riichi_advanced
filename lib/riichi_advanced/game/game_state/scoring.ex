
defmodule RiichiAdvanced.GameState.Scoring do
  alias RiichiAdvanced.GameState.American, as: American
  alias RiichiAdvanced.GameState.Conditions, as: Conditions
  alias RiichiAdvanced.GameState.Debug, as: Debug
  alias RiichiAdvanced.GameState.Player, as: Player
  alias RiichiAdvanced.GameState.PlayerCache, as: PlayerCache
  alias RiichiAdvanced.GameState.TileBehavior, as: TileBehavior
  alias RiichiAdvanced.Riichi, as: Riichi
  alias RiichiAdvanced.Utils, as: Utils
  import RiichiAdvanced.GameState

  defp _get_yaku(state, yaku_list, seat, winning_tile, win_source, minipoints, existing_yaku) do
    context = %{
      seat: seat,
      winning_tile: winning_tile,
      win_source: win_source,
      minipoints: minipoints,
      existing_yaku: existing_yaku
    }
    eligible_yaku = yaku_list
      |> Enum.filter(fn %{"display_name" => _name, "value" => _value, "when" => cond_spec} -> Conditions.check_cnf_condition(state, cond_spec, context) end)
      |> Enum.map(fn %{"display_name" => name, "value" => value, "when" => _cond_spec} -> {name, if is_number(value) do value else Map.get(state.players[seat].counters, value, 0) end} end)
    eligible_yaku = existing_yaku ++ eligible_yaku
    yaku_map = Enum.reduce(eligible_yaku, %{}, fn {name, value}, acc -> Map.update(acc, name, value, & &1 + value) end)
    eligible_yaku = eligible_yaku
      |> Enum.map(fn {name, _value} -> name end)
      |> Enum.uniq()
      |> Enum.map(fn name -> {name, yaku_map[name]} end)
    eligible_yaku = if Map.has_key?(state.rules, "yaku_precedence") do
      excluded_yaku = Enum.flat_map(eligible_yaku, fn {name, _value} -> Map.get(state.rules["yaku_precedence"], name, []) end)
      Enum.reject(eligible_yaku, fn {name, value} -> name in excluded_yaku or value in excluded_yaku end)
    else eligible_yaku end
    eligible_yaku
  end

  defp get_yaku(state, yaku_list, seat, winning_tile, win_source, minipoints, existing_yaku) do
    yaku_names = Enum.map(yaku_list, & &1["display_name"])
    existing_yaku_names = Enum.map(existing_yaku, fn {name, _value} -> name end)
    case RiichiAdvanced.ETSCache.get({:get_yaku, state, state.players[seat].hand, state.players[seat].calls, TileBehavior.hash(state.players[seat].tile_behavior), winning_tile, win_source, yaku_names, existing_yaku_names}) do
      [] -> 
        result = _get_yaku(state, yaku_list, seat, winning_tile, win_source, minipoints, existing_yaku)
        RiichiAdvanced.ETSCache.put({:get_yaku, state, state.players[seat].hand, state.players[seat].calls, TileBehavior.hash(state.players[seat].tile_behavior), winning_tile, win_source, yaku_names, existing_yaku_names}, result)
        result
      [result] -> result
    end
  end

  def get_yakuhai(state, seat) do
    dragons = [:"5z", :"6z", :"7z"]
    seat_wind = case Riichi.get_seat_wind(state.kyoku, seat, state.available_seats) do
      :east -> :"1z"
      :south -> :"2z"
      :west -> :"3z"
      :north -> :"4z"
    end
    round_wind = case Riichi.get_round_wind(state.kyoku, length(state.available_seats)) do
      :east -> :"1z"
      :south -> :"2z"
      :west -> :"3z"
      :north -> :"4z"
    end
    north_wind = if Map.get(state.rules["score_calculation"], "north_wind_yakuhai", false) do [:"4z"] else [] end
    if Map.get(state.rules["score_calculation"], "double_wind_4_fu", false) do
      dragons ++ [seat_wind, round_wind] ++ north_wind
    else
      dragons ++ Enum.dedup([seat_wind, round_wind]) ++ north_wind
    end
  end

  def get_minipoints(state, seat, winning_tile, win_source) do
    counter_fu = Map.get(state.players[seat].counters, "fu", 0)
    if counter_fu > 0 do
      counter_fu
    else
      score_rules = state.rules["score_calculation"]
      enable_kontsu_fu = Map.get(score_rules, "enable_kontsu_fu", false)
      Riichi.calculate_fu(state.players[seat].hand, state.players[seat].calls, winning_tile, win_source, get_yakuhai(state, seat), state.players[seat].tile_behavior, enable_kontsu_fu)
    end
  end

  def get_yaku_advanced(state, yaku_list, seat, winning_tiles, win_source, existing_yaku \\ []) do
    # returns a map %{winning_tile => {minipoints, yakus}}
    if winning_tiles == nil or winning_tiles == [nil] or Enum.empty?(winning_tiles) do
      # try every possible winning tile from hand
      for {winning_tile, i} <- Enum.with_index(state.players[seat].hand), winning_tile != nil, into: %{} do
        state2 = update_player(state, seat, &%Player{ &1 | hand: List.delete_at(&1.hand, i), draw: [Utils.add_attr(winning_tile, ["draw"])] })
        minipoints = get_minipoints(state2, seat, winning_tile, win_source)
        yakus = get_yaku(state2, yaku_list, seat, winning_tile, win_source, minipoints, existing_yaku)
        {winning_tile, {minipoints, yakus}}
      end
    else
      for winning_tile <- winning_tiles, into: %{} do
        minipoints = get_minipoints(state, seat, winning_tile, win_source)
        yakus = get_yaku(state, yaku_list, seat, winning_tile, win_source, minipoints, existing_yaku)
        {winning_tile, {minipoints, yakus}}
      end
    end
  end

  def get_best_yaku_and_winning_tile(state, yaku_list, seat, winning_tiles, win_source, existing_yaku \\ []) do
    # returns {winning_tile, best_minipoints, best_yakus}
    get_yaku_advanced(state, yaku_list, seat, winning_tiles, win_source, existing_yaku)
    |> Enum.max_by(fn {_winning_tile, {_minipoints, possible_yaku}} -> Enum.reduce(possible_yaku, 0, fn {_name, value}, acc -> acc + value end) end)
  end

  def get_best_yaku(state, yaku_list, seat, winning_tiles, win_source, existing_yaku \\ []) do
    {_winning_tile, {_minipoints, best_yaku}} = get_best_yaku_and_winning_tile(state, yaku_list, seat, winning_tiles, win_source, existing_yaku)
    best_yaku
  end

  def get_best_yaku_from_lists(state, yaku_list_names, seat, winning_tiles, win_source) do
    # returns {yaku, minipoints, new_winning_tile}
    declare_only_yaku_list_names = Map.get(state.rules["score_calculation"], "declare_only_yaku_lists", [])
    for yaku_list_name <- yaku_list_names, reduce: {[], 0, nil} do
      {yaku, minipoints, new_winning_tile} ->
        if Map.has_key?(state.rules, yaku_list_name) do
          yaku_list = if yaku_list_name in declare_only_yaku_list_names do
            declared_yaku = state.players[seat].declared_yaku
            Enum.filter(state.rules[yaku_list_name], fn yaku_obj -> yaku_obj["display_name"] in declared_yaku end)
          else state.rules[yaku_list_name] end
          {new_winning_tile, {minipoints, yaku}} = get_best_yaku_and_winning_tile(state, yaku_list, seat, winning_tiles, win_source, yaku)
          {yaku, minipoints, new_winning_tile}
        else
          {yaku, minipoints, new_winning_tile}
        end
    end
  end

  def apply_joker_assignment(state, seat, joker_assignment, winning_tile \\ nil) do
    tile_aliases = state.players[seat].tile_behavior.aliases
    # the joker assignment only maps base tiles (no attrs)
    # look at the actual aliases that match, and add the appropriate attrs
    replace_joker = fn joker, i ->
      for {tile, attrs_aliases} <- tile_aliases,
          tile == joker_assignment[i],
          {attrs, aliases} <- attrs_aliases,
          Utils.has_matching_tile?([joker], aliases) do
        Utils.add_attr(tile, attrs)
      end
      |> Enum.at(0, joker)
    end
    orig_hand = state.players[seat].hand
    {flower_calls, non_flower_calls} = Enum.split_with(state.players[seat].calls, fn {call_name, _call} -> call_name in Riichi.flower_names() end)
    assigned_hand = orig_hand |> Enum.with_index() |> Enum.map(fn {tile, ix} -> if joker_assignment[ix] != nil do replace_joker.(tile, ix) else tile end end)
    assigned_non_flower_calls = non_flower_calls
    |> Enum.with_index()
    |> Enum.map(fn {{call_name, call}, i} ->
      call = call
      |> Enum.with_index()
      |> Enum.map(fn {tile, ix} -> replace_joker.(tile, length(orig_hand) + 1 + 3*i + ix) end)
      {call_name, call}
    end)
    assigned_calls = flower_calls ++ assigned_non_flower_calls
    # length(orig_hand) is where the solver puts the winning tile
    # if the winning tile is a joker, the following gets its assignment
    assigned_winning_tile = replace_joker.(winning_tile, length(orig_hand))
    assigned_winning_hand = assigned_hand ++ Enum.flat_map(assigned_calls, &Utils.call_to_tiles/1) ++ if assigned_winning_tile != nil do [assigned_winning_tile] else [] end
    state = update_player(state, seat, &%Player{ &1 | hand: assigned_hand, calls: assigned_calls, cache: %PlayerCache{ &1.cache | winning_hand: assigned_winning_hand } })
    {state, assigned_winning_tile}
  end

  def seat_scores_points(state, yaku_list_names, min_points, min_minipoints, seat, winning_tile, win_source) do
    # t = System.system_time(:millisecond)
    score_rules = state.rules["score_calculation"]
    use_smt = Map.get(score_rules, "use_smt", true)
    joker_assignments = if not use_smt or Enum.empty?(state.players[seat].tile_behavior.aliases) do [%{}] else
      smt_hand = state.players[seat].hand ++ if winning_tile != nil do [winning_tile] else [] end
      RiichiAdvanced.SMT.match_hand_smt_v2(state.smt_solver, smt_hand, state.players[seat].calls, state.all_tiles, translate_match_definitions(state, ["win"]), state.players[seat].tile_behavior)
    end
    # IO.puts("seat_scores_points SMT time: #{inspect(System.system_time(:millisecond) - t)} ms")
    # IO.inspect(Process.info(self(), :current_stacktrace))

    if Debug.print_wins() do
      IO.puts("Joker assignments (seat_scores_points): #{inspect(joker_assignments)}")
    end
    joker_assignments = if Enum.empty?(joker_assignments) do [%{}] else joker_assignments end
    Enum.any?(joker_assignments, fn joker_assignment ->
      {state, assigned_winning_tile} = apply_joker_assignment(state, seat, joker_assignment, winning_tile)
      {yaku, minipoints, _winning_tile} = get_best_yaku_from_lists(state, yaku_list_names, seat, [assigned_winning_tile], win_source)
      minipoints >= min_minipoints && case min_points do
        :declared ->
          names = Enum.map(yaku, fn {name, _value} -> name end)
          Enum.all?(state.players[seat].declared_yaku, fn yaku -> yaku in names end)
        _ ->
          points = Enum.map(yaku, fn {_name, value} -> value end) |> Enum.sum()
          points >= min_points
      end
    end)
  end

  def score_yaku(state, seat, yaku, yaku2, is_dealer, is_self_draw, minipoints \\ 0) do
    score_rules = state.rules["score_calculation"]
    yaku_2_overrides = not Enum.empty?(yaku2) and Map.get(score_rules, "yaku2_overrides_yaku1", false)

    scoring_method = score_rules["scoring_method"]
    {yaku, scoring_method} = if is_list(scoring_method) do
      if yaku_2_overrides do
        {yaku2, Enum.at(scoring_method, 1)}
      else
        {yaku, Enum.at(scoring_method, 0)}
      end
    else {yaku, scoring_method} end

    {score, points, points2, name} = case scoring_method do
      "multiplier" ->
        points = Enum.reduce(yaku, 0, fn {_name, value}, acc -> acc + value end)
        points2 = Enum.reduce(yaku2, 1, fn {_name, value}, acc -> acc * value end)
        score_multiplier = case Map.get(score_rules, "score_multiplier", 1) do
          "points2"        -> points2
          score_multiplier -> score_multiplier
        end
        score = points * score_multiplier
        score_name = Map.get(score_rules, "score_name", "")
        {score, points, points2, score_name}
      "score_table" ->
        points = Enum.reduce(yaku, 0, fn {_name, value}, acc -> acc + value end)
        score = Map.get(score_rules["score_table"], Integer.to_string(points), score_rules["score_table"]["max"])
        score_name = Map.get(score_rules, "score_name", "")
        {score, points, 0, score_name}
      "vietnamese" ->
        phan = Enum.reduce(yaku, 0, fn {_name, value}, acc -> acc + value end)
        mun = Enum.reduce(yaku2, 0, fn {_name, value}, acc -> acc + value end)
        mun = mun + Integer.floor_div(phan, 6)
        phan = rem(phan, 6)
        score = if mun == 0 do score_rules["score_table"][Integer.to_string(phan)] else mun * score_rules["score_table"]["max"] end
        score_name = Map.get(score_rules, "score_name", "")
        {score, phan, mun, score_name}
      "han_fu_formula" ->
        points = Enum.reduce(yaku, 0, fn {_name, value}, acc -> acc + value end)
        minipoints = Map.get(score_rules, "fixed_fu", minipoints)
        han_fu_multiplier = Map.get(score_rules, "han_fu_multiplier", 4)
        han_fu_rounding_factor = Map.get(score_rules, "han_fu_rounding_factor", 100)
        dealer_multiplier = Map.get(score_rules, "dealer_multiplier", 1)

        # handle limit scores
        limit_thresholds = Map.get(score_rules, "limit_thresholds", []) |> Enum.reverse()
        limit_scores = Map.get(score_rules, "limit_scores", []) |> Enum.reverse()
        limit_names = Map.get(score_rules, "limit_names", []) |> Enum.reverse()
        limit_index = Enum.find_index(limit_thresholds, fn [han, fu] -> points >= han and minipoints >= fu end)
        {score, name} = if limit_index != nil do
          # handle ryuumonbuchi touka's scoring quirk
          limit_index = if "score_limit_one_tier_higher" in state.players[seat].status do
            case Enum.find_index(limit_scores, fn score -> score > Enum.at(limit_scores, limit_index) end) do
              nil         -> limit_index
              limit_index -> limit_index
            end
          else limit_index end
          score = Enum.at(limit_scores, limit_index) * if is_dealer do dealer_multiplier else 1 end
          {score, Enum.at(limit_names, limit_index)}
        else
          # calculate score using formula
          base_score = han_fu_multiplier * minipoints * 2 ** (2 + points)
          score = base_score * if is_dealer do dealer_multiplier else 1 end
          # round up (to nearest 100, by default)
          score = trunc(Float.ceil(score / han_fu_rounding_factor)) * han_fu_rounding_factor
          {score, nil}
        end

        score = score * if "double_score" in state.players[seat].status do 2 else 1 end

        {score, points, 0, name}
      _ ->
        GenServer.cast(self(), {:show_error, "Unknown scoring method #{inspect(scoring_method)}"})
        {0, 0, 0, ""}
    end

    min_score = Map.get(score_rules, "min_score", 0)
    score = max(score, min_score)

    dealer_multiplier = if scoring_method == "han_fu_formula" do 1 else Map.get(score_rules, "dealer_multiplier", 1) end
    self_draw_bonus = Map.get(score_rules, "self_draw_bonus", 0)
    score = score * if is_dealer do dealer_multiplier else 1 end |> Utils.try_integer()
    score = score + if is_self_draw do self_draw_bonus else 0 end

    # apply tsumo loss (sanma only)
    tsumo_loss = Map.get(score_rules, "tsumo_loss", false)
    score = cond do
      length(state.available_seats) != 3 -> score
      (is_self_draw and tsumo_loss == true) or tsumo_loss == "ron_loss" ->
        han_fu_rounding_factor = Map.get(score_rules, "han_fu_rounding_factor", 100)
        {ko_payment, oya_payment} = Riichi.calc_ko_oya_points(score, is_dealer, 4, han_fu_rounding_factor)
        if is_dealer do ko_payment * 2 else oya_payment + ko_payment end
      tsumo_loss == "add_1000" -> score + 2000
      tsumo_loss == "double_collection" -> score * 2
      true -> score
    end

    max_score = Map.get(score_rules, "max_score", :infinity)
    score = min(score, max_score)

    score = Utils.try_integer(score)
    points = Utils.try_integer(points)
    points2 = Utils.try_integer(points2)
    {score, points, points2, name}
  end
  
  def hanada_kirame_score_protection(state, delta_scores) do
    case Enum.find(state.players, fn {_seat, player} -> "hanada-kirame" in player.status end) do
      {hanada_kirame_seat, hanada_kirame} ->
        if "hanada_kirame_score_protection" in hanada_kirame.status and hanada_kirame.score + delta_scores[hanada_kirame_seat] < 0 do
          push_message(state, [%{text: "Player #{player_name(state, hanada_kirame_seat)} stays at zero points, and receives 8000 points from first place (Hanada Kirame)"}])
          scores = Enum.map(state.players, fn {seat, player} -> {seat, player.score + delta_scores[seat]} end)
          {first_seat, _} = Enum.max_by(scores, fn {_seat, score} -> score end)
          state = update_player(state, hanada_kirame_seat, fn player -> %Player{ player | status: player.status ++ ["hanada-kirame_exhausted"] } end)
          delta_scores = delta_scores
          |> Map.put(hanada_kirame_seat, 8000 - hanada_kirame.score)
          |> Map.update!(first_seat, & &1 - 8000)
          {state, delta_scores}
        else {state, delta_scores} end
      _ -> {state, delta_scores}
    end
  end

  defp calculate_delta_scores_for_single_winner(state, winner, collect_sticks) do
    score_rules = state.rules["score_calculation"]
    delta_scores = Map.new(state.players, fn {seat, _player} -> {seat, 0} end)

    # determine dealer
    is_dealer = Riichi.get_east_player_seat(state.kyoku, state.available_seats) == winner.seat
    # handle ryuumonbuchi touka's scoring quirk
    is_dealer = is_dealer or "score_as_dealer" in state.players[winner.seat].status

    pao_triggered = Map.get(winner, :pao_seat, nil) != nil
    pao_eligible_yaku = Map.get(score_rules, "pao_eligible_yaku", [])
    {pao_yaku, non_pao_yaku} = if Map.get(score_rules, "pao_pays_all", false) do
      {winner.yaku ++ winner.yaku2, []}
    else
      Enum.split_with(winner.yaku ++ winner.yaku2, fn {name, _value} -> name in pao_eligible_yaku end)
    end
    if pao_triggered and length(pao_yaku) > 0 and length(non_pao_yaku) > 0 do
      # if we have both pao and non-pao yaku, we need to calculate them separately and add them up
      {basic_score_pao, _, _, _} = score_yaku(state, winner.seat, [], pao_yaku, is_dealer, winner.win_source == :draw, winner.minipoints)
      {basic_score_non_pao, _, _, _} = score_yaku(state, winner.seat, [], non_pao_yaku, is_dealer, winner.win_source == :draw, winner.minipoints)
      delta_scores_pao = calculate_delta_scores_for_single_winner(state, %{ winner | score: basic_score_pao, yaku: pao_yaku, yaku2: [] }, collect_sticks)
      delta_scores_non_pao = calculate_delta_scores_for_single_winner(state, %{ winner | score: basic_score_non_pao, yaku: non_pao_yaku, yaku2: [] }, collect_sticks)
      delta_scores = Map.new(delta_scores_pao, fn {seat, delta} -> {seat, delta + delta_scores_non_pao[seat]} end)
      delta_scores
    else
      # get riichi and honba payment
      {riichi_payment, honba_payment} = if collect_sticks do {state.pot, Map.get(score_rules, "honba_value", 0) * state.honba} else {0, 0} end
      honba_payment = if "multiply_honba_with_han" in state.players[winner.seat].status do honba_payment * winner.points else honba_payment end

      basic_score = winner.score
      
      basic_score = if "wareme" in state.players[winner.seat].status do
        push_message(state, [%{text: "Player #{player_name(state, winner.seat)} gains double points for wareme"}])
        basic_score * 2
      else basic_score end
      
      # calculate some parameters that change if pao exists
      {delta_scores, basic_score, payer, direct_hit} =
        # due to the way we handle mixed pao-and-not-pao yaku earlier,
        # we're guaranteed either all of the yaku are pao, or none of them are
        if pao_triggered and length(pao_yaku) > 0 do
          # if pao, then payer becomes the pao seat,
          # and a ron payment is split in half
          if winner.payer != nil and Map.get(score_rules, "split_pao_ron", true) do # ron
            # the deal-in player is not responsible for honba payments,
            # so we take care of their share of payment right here
            basic_score = Utils.try_integer(basic_score / 2)
            delta_scores = Map.put(delta_scores, winner.payer, -basic_score)
            delta_scores = Map.put(delta_scores, winner.seat, basic_score)
            {delta_scores, basic_score, winner.pao_seat, true}
          else
            # otherwise the responsibility of the payment is entirely on the pao seat
            {delta_scores, basic_score, winner.pao_seat, true}
          end
        else
          {delta_scores, basic_score, winner.payer, winner.payer != nil}
        end

      delta_scores = if direct_hit do # either ron, or tsumo pao, or remaining ron pao payment
        payment = basic_score + honba_payment * (length(state.available_seats) - 1)
        payment = if "megan_davin_double_payment" in state.players[winner.seat].status and "megan_davin_double_payment" in state.players[payer].status do
          push_message(state, [%{text: "Player #{player_name(state, payer)} pays double to their duelist (Megan Davin)"}])
          payment * 2
        else payment end
        payment = if "double_payment" in state.players[payer].status do
          push_message(state, [%{text: "Player #{player_name(state, payer)} pays double (Yae Kobashiri)"}])
          payment * 2
        else payment end
        payment = if "kanbara_satomi_double_loss" in state.players[payer].status do
          push_message(state, [%{text: "Player #{player_name(state, payer)} pays double since the wall ends on their side (Kanbara Satomi)"}])
          payment * 2
        else payment end
        payment = if "tsujigaito_satoha_double_score" in state.players[winner.seat].status do
          push_message(state, [%{text: "Player #{player_name(state, winner.seat)} gets double points for winning under someone else's ippatsu (Tsujigaito Satoha)"}])
          payment * 2
        else payment end
        manzu = "yoshitome_miharu_manzu" in state.players[payer].status and Utils.has_matching_tile?([winner.winning_tile], [:"1m",:"2m",:"3m",:"4m",:"5m",:"6m",:"7m",:"8m",:"9m"])
        pinzu = "yoshitome_miharu_pinzu" in state.players[payer].status and Utils.has_matching_tile?([winner.winning_tile], [:"1p",:"2p",:"3p",:"4p",:"5p",:"6p",:"7p",:"8p",:"9p"])
        souzu = "yoshitome_miharu_souzu" in state.players[payer].status and Utils.has_matching_tile?([winner.winning_tile], [:"1s",:"2s",:"3s",:"4s",:"5s",:"6s",:"7s",:"8s",:"9s"])
        payment = if pao_triggered and (manzu or pinzu or souzu) do
          push_message(state, [%{text: "Player #{player_name(state, payer)} pays half due to dealing in with their voided suit (Yoshitome Miharu)"}])
          Utils.half_score_rounded_up(payment)
        else payment end

        discarder_multiplier = Map.get(score_rules, "discarder_multiplier", 1)
        discarder_penalty = Map.get(score_rules, "discarder_penalty", 0)
        non_discarder_multiplier = Map.get(score_rules, "non_discarder_multiplier", 0)
        non_discarder_penalty = Map.get(score_rules, "non_discarder_penalty", 0)
        for paying_seat <- winner.opponents, reduce: delta_scores do
          delta_scores ->
            multiplier = if paying_seat == payer do discarder_multiplier else non_discarder_multiplier end
            penalty = if paying_seat == payer do discarder_penalty else non_discarder_penalty end
            delta_scores
            |> Map.update!(paying_seat, & &1 - (payment * multiplier) - penalty)
            |> Map.update!(winner.seat, & &1 + (payment * multiplier) + penalty)
        end
      else # tsumo
        # for riichi, reverse-calculate the ko and oya parts of the total points
        split_oya_ko_payment = Map.get(score_rules, "split_oya_ko_payment", false)
        num_players = length(state.available_seats)
        # calculate ko and oya payment from basic_score
        # (if dealer tsumo, oya payment is unused)
        {ko_payment, oya_payment} = if split_oya_ko_payment and num_players >= 3 do
          han_fu_rounding_factor = Map.get(score_rules, "han_fu_rounding_factor", 100)
          tsumo_loss = Map.get(score_rules, "tsumo_loss", false)
          {ko_payment, oya_payment} = Riichi.calc_ko_oya_points(basic_score, is_dealer, num_players, han_fu_rounding_factor)
          cond do
            num_players == 4 or tsumo_loss in [true, "ron_loss"] -> {ko_payment, oya_payment}
            tsumo_loss == "add_1000" ->
              {ko_payment, oya_payment} = Riichi.calc_ko_oya_points(basic_score - 2000, is_dealer, 4, han_fu_rounding_factor)
              {1000 + ko_payment, 1000 + oya_payment}
            tsumo_loss == "unequal_split" -> {ko_payment, oya_payment}
            tsumo_loss == "north_to_oya" and not is_dealer ->
              {ko_payment, oya_payment} = Riichi.calc_ko_oya_points(basic_score, is_dealer, 4, han_fu_rounding_factor)
              {ko_payment, oya_payment + ko_payment}
            tsumo_loss in [false, "north_split", "north_to_oya"] ->
              {ko_payment, oya_payment} = Riichi.calc_ko_oya_points(basic_score, is_dealer, 4, han_fu_rounding_factor)
              half_ko_payment = Utils.try_integer(ko_payment / 2)
              {ko_payment + half_ko_payment, oya_payment + half_ko_payment}
            tsumo_loss in ["equal_split", "double_collection"] ->
              payment = Utils.try_integer(basic_score / 2)
              {payment, payment}
            true ->
              IO.puts("Invalid tsumo_loss value (defaults to true): #{inspect(tsumo_loss)}")
              {ko_payment, oya_payment}
          end
        else
          self_draw_multiplier = Map.get(score_rules, "self_draw_multiplier", 1)
          self_draw_penalty = Map.get(score_rules, "self_draw_penalty", 0)
          {self_draw_multiplier * basic_score + self_draw_penalty, self_draw_multiplier * basic_score + self_draw_penalty}
        end

        # handle motouchi naruka's scoring quirk
        motouchi_naruka_delta = 100 * Integer.floor_div(state.pot, max(1, Map.get(score_rules, "riichi_value", 1000)))
        {ko_payment, oya_payment} = if "motouchi_naruka_increase_tsumo_payment" in state.players[winner.seat].status do
          push_message(state, [%{text: "Player #{player_name(state, winner.seat)} has tsumo payments increased by 300 per 1000 bet (#{3 * motouchi_naruka_delta}) (Motouchi Naruka)"}])
          {ko_payment + motouchi_naruka_delta, oya_payment + motouchi_naruka_delta}
        else {ko_payment, oya_payment} end
        {ko_payment, oya_payment} = if "motouchi_naruka_decrease_tsumo_payment" in state.players[winner.seat].status do
          push_message(state, [%{text: "Player #{player_name(state, winner.seat)} has tsumo payments decreased by 300 per 1000 bet (#{3 * motouchi_naruka_delta}) (Motouchi Naruka)"}])
          {max(0, ko_payment - motouchi_naruka_delta), max(0, oya_payment - motouchi_naruka_delta)}
        else {ko_payment, oya_payment} end

        # have each payer pay their allotted share
        dealer_seat = Riichi.get_east_player_seat(state.kyoku, state.available_seats)
        for payer <- winner.opponents, reduce: delta_scores do
          delta_scores ->
            payment = if payer == dealer_seat do oya_payment else ko_payment end
            payment = if "atago_hiroe_no_tsumo_payment" in state.players[payer].status do
              push_message(state, [%{text: "Player #{player_name(state, payer)} is damaten, and immune to tsumo payments (Atago Hiroe)"}])
              0
            else payment end
            payment = if "double_tsumo_payment" in state.players[payer].status do
              push_message(state, [%{text: "Player #{player_name(state, payer)} pays double for tsumo (Maya Yukiko)"}])
              payment * 2
            else payment end
            payment = if "double_payment" in state.players[payer].status do
              push_message(state, [%{text: "Player #{player_name(state, payer)} pays double (Yae Kobashiri)"}])
              payment * 2
            else payment end
            payment = if "megan_davin_double_payment" in state.players[winner.seat].status and "megan_davin_double_payment" in state.players[payer].status do
              push_message(state, [%{text: "Player #{player_name(state, payer)} pays double to their duelist (Megan Davin)"}])
              payment * 2
            else payment end
            payment = if "kanbara_satomi_double_loss" in state.players[payer].status do
              push_message(state, [%{text: "Player #{player_name(state, payer)} pays double since the wall ends on their side (Kanbara Satomi)"}])
              payment * 2
            else payment end
            payment = if "tsujigaito_satoha_double_score" in state.players[winner.seat].status do
              push_message(state, [%{text: "Player #{player_name(state, winner.seat)} gets double points for winning under someone else's ippatsu (Tsujigaito Satoha)"}])
              payment * 2
            else payment end
            payment = if "wareme" in state.players[payer].status do
              push_message(state, [%{text: "Player #{player_name(state, payer)} loses double points for wareme"}])
              payment * 2
            else payment end
            delta_scores = Map.update!(delta_scores, payer, & &1 - payment - honba_payment)
            delta_scores = Map.update!(delta_scores, winner.seat, & &1 + payment + honba_payment)
            delta_scores
        end
      end

      # award riichi sticks
      delta_scores = Map.update!(delta_scores, winner.seat, & &1 + riichi_payment)

      # handle iwadate yuan's scoring quirk
      delta_scores = if Map.has_key?(state.players[winner.seat].counters, "iwadate_yuan_payment") do
        amount = state.players[winner.seat].counters["iwadate_yuan_payment"]
        push_message(state, [%{text: "Every payer pays 1000 additional points (#{amount}) to #{winner.seat} #{state.players[winner.seat].nickname} for each chun used as five, each ura, each aka, and ippatsu (Iwadate Yuan)"}])
        for {seat, delta} <- delta_scores, delta < 0, reduce: delta_scores do
          delta_scores -> delta_scores |> Map.update!(winner.seat, & &1 + amount) |> Map.update!(seat, & &1 - amount)
        end
      else delta_scores end

      # handle arakawa kei's scoring quirk
      delta_scores = if "use_arakawa_kei_scoring" in winner.player.status do
        win_definitions = translate_match_definitions(state, ["win"])
        visible_tiles = get_visible_tiles(state, winner.seat)
        waits = Riichi.get_waits_and_ukeire(winner.player.hand, winner.player.calls, win_definitions, state.wall ++ state.dead_wall, visible_tiles, winner.tile_behavior)
        if "arakawa-kei" in winner.player.status do
          # everyone pays winner 100 points per live out
          ukeire = waits |> Map.values() |> Enum.sum()
          push_message(state, [%{text: "Everybody pays player #{winner.seat} #{state.players[winner.seat].nickname} #{100 * ukeire} for #{ukeire} live out(s) (Arakawa Kei)"}])
          delta_scores
          |> Map.new(fn {seat, score} -> {seat, score - 100 * ukeire} end)
          |> Map.update!(winner.seat, & &1 + 400 * ukeire)
        else
          # winner pays arakawa kei 1000 points per waiting tile in her hand
          {arakawa_kei_seat, arakawa_kei} = Enum.find(state.players, fn {_seat, player} -> "arakawa-kei" in player.status end)
          waiting_tiles = Map.keys(waits)
          num = Utils.count_tiles(arakawa_kei.hand, waiting_tiles)
          push_message(state, [%{text: "Winner pays player #{arakawa_kei_seat} #{arakawa_kei.nickname} #{1000 * num} for having #{num} wait(s) in hand (Arakawa Kei)"}])
          delta_scores
          |> Map.update!(winner.seat, & &1 - 1000 * num)
          |> Map.update!(arakawa_kei_seat, & &1 + 1000 * num)
        end
      else delta_scores end

      delta_scores
    end
  end

  defp calculate_delta_scores_per_player(state, winners) do
    score_rules = state.rules["score_calculation"]

    # determine the closest winner (the one who receives riichi sticks and honba)
    
    {_seat, some_winner} = Enum.at(winners, 0)
    payer = some_winner.payer
    closest_winner = if payer == nil do some_winner.seat else
      next_seat_1 = if state.reversed_turn_order do Utils.prev_turn(payer) else Utils.next_turn(payer) end
      next_seat_2 = if state.reversed_turn_order do Utils.prev_turn(next_seat_1) else Utils.next_turn(next_seat_1) end
      next_seat_3 = if state.reversed_turn_order do Utils.prev_turn(next_seat_2) else Utils.next_turn(next_seat_2) end
      next_seat_4 = if state.reversed_turn_order do Utils.prev_turn(next_seat_3) else Utils.next_turn(next_seat_3) end
      cond do
        Map.has_key?(winners, next_seat_1) -> next_seat_1
        Map.has_key?(winners, next_seat_2) -> next_seat_2
        Map.has_key?(winners, next_seat_3) -> next_seat_3
        Map.has_key?(winners, next_seat_4) -> next_seat_4
      end
    end

    # get the individual delta scores for each winner
    delta_scores_map = Map.new(winners, fn {seat, winner} -> {seat, calculate_delta_scores_for_single_winner(state, winner, seat == closest_winner)} end)

    # handle ezaki hitomi's scoring quirk
    is_tsumo = Enum.any?(winners, fn {_seat, winner} -> winner.payer == nil end)
    delta_scores_map = if not is_tsumo do
      for {winner_seat, delta_scores} <- delta_scores_map, into: %{} do
        delta_scores = for {seat, player} <- state.players, reduce: delta_scores do
          delta_scores ->
            if delta_scores[seat] < 0 and "ezaki_hitomi_reflect" in player.status do
              # calculate possible waits
              win_definitions = translate_match_definitions(state, ["win"])
              waits = Riichi.get_waits(player.hand, player.calls, win_definitions, state.all_tiles, player.tile_behavior) ++ [:"2x"]
              if not Enum.empty?(waits) do
                # calculate the worst yaku we can get
                winner = calculate_winner_details(state, seat, waits, :discard, true)
                worst_yaku = if Enum.empty?(winner.yaku2) do winner.yaku else winner.yaku2 end

                # add honba
                score = winner.score + (score_rules["honba_value"] * state.honba)

                if not Enum.empty?(worst_yaku) do
                  push_message(state, [
                    %{text: "Player #{player_name(state, seat)} dealt in while tenpai with hand"},
                  ] ++ Utils.ph(player.hand |> Utils.sort_tiles())
                    ++ Utils.ph(player.calls |> Enum.flat_map(&Utils.call_to_tiles/1))
                    ++ [
                    %{text: " which, if won on "},
                    Utils.pt(winner.winning_tile),
                    %{text: " scores a minimum value of"},
                    %{bold: true, text: "#{score}"},
                    %{text: " via the following yaku: "},
                    %{text: worst_yaku |> Enum.map(fn {name, value} -> "#{name} (#{value})" end) |> Enum.join(", ")},
                    %{text: "(Ezaki Hitomi)"}
                  ])

                  # compare score with the amount we will pay out
                  payment = -delta_scores[seat]
                  if payment < score do
                    # reflect the payment
                    push_message(state, [%{text: "Player #{player_name(state, seat)} has greater tenpai value than their deal-in value, and therefore reverses the payment, not including riichi sticks (Ezaki Hitomi)"}])
                    delta_scores
                    |> Map.put(seat, payment)
                    |> Map.update!(winner_seat, & &1 - 2 * payment)
                  else
                    push_message(state, [%{text: "Player #{player_name(state, seat)} has less or equal tenpai value than their deal-in value, and therefore the payment proceeds as normal (Ezaki Hitomi)"}])
                    delta_scores
                  end
                else delta_scores end
              else delta_scores end
            else delta_scores end
        end
        {winner_seat, delta_scores}
      end
    else delta_scores_map end

    delta_scores_map
  end
  
  def adjudicate_win_scoring(state) do
    score_rules = state.rules["score_calculation"]
    delta_scores = Map.new(state.players, fn {seat, _player} -> {seat, 0} end)

    # handle nelly virsaladze's scoring quirk
    {state, delta_scores} = for {seat, player} <- state.players, reduce: {state, delta_scores} do
      {state, delta_scores} ->
        if "nelly_virsaladze_take_bets" in player.status do
          push_message(state, [%{text: "Player #{player_name(state, seat)} takes all bets on the table (#{state.pot}) and is paid 1500 by every player (Nelly Virsaladze)"}])
          delta_scores = Map.update!(delta_scores, seat, & &1 + state.pot + 4500)
          delta_scores = for {dir, _player} <- state.placeyers, dir != seat, reduce: delta_scores do
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
    delta_scores = for {_seat, deltas} <- calculate_delta_scores_per_player(state, winners), reduce: delta_scores do
      delta_scores_acc -> Map.new(delta_scores_acc, fn {seat, delta} -> {seat, delta + deltas[seat]} end)
    end

    # multiply by delta_score_multiplier counter, if it exists
    delta_scores = Map.new(delta_scores, fn {seat, delta} -> {seat, delta * Map.get(state.players[seat].counters, "delta_score_multiplier", 1)} end)

    # add delta_score counter, if it exists
    delta_scores = Map.new(delta_scores, fn {seat, delta} -> {seat, delta + Map.get(state.players[seat].counters, "delta_score", 0)} end)

    is_tsumo = Enum.any?(winners, fn {_seat, winner} -> winner.payer == nil end)
    pao_eligible_yaku = Map.get(score_rules, "pao_eligible_yaku", [])
    is_pao = Enum.any?(winners, fn {_seat, winner} -> Map.get(winner, :pao_seat, nil) != nil and Enum.any?(winner.yaku ++ winner.yaku2, fn {name, _value} -> name in pao_eligible_yaku end) end)

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
            push_message(state, [%{text: "Player #{player_name(state, seat)} bets their tsumo payment instead of paying out (Ezaki Hitomi)"}])
            state = Map.put(state, :pot, payment)

            {state, delta_scores}
          else {state, delta_scores} end
      end
    else {state, delta_scores} end

    # handle hanada kirame's scoring quirk
    {state, delta_scores} = hanada_kirame_score_protection(state, delta_scores)

    # get delta scores reason
    delta_scores_reason = cond do
      state.round_result == :draw  -> Map.get(score_rules, "exhaustive_draw_name", "Draw")
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
          state.round_result == :draw -> dealer_seat # if there is no first winner, dealer stays the same
          map_size(winners) == 1      -> winner.seat # otherwise, the first winner becomes the next dealer
          true                        -> winner.payer # if there are multiple first winners, the payer becomes the next dealer instead
        end
        Utils.get_relative_seat(dealer_seat, new_dealer_seat)
      agarirenchan and Riichi.get_east_player_seat(state.kyoku, state.available_seats) in state.winner_seats -> :self
      true -> :shimocha
    end

    {state, delta_scores, delta_scores_reason, next_dealer}
  end

  def adjudicate_draw_scoring(state) do
    score_rules = state.rules["score_calculation"]
    draw_tenpai_payments = Map.get(score_rules, "draw_tenpai_payments", nil)
    draw_nagashi_payments = Map.get(score_rules, "draw_nagashi_payments", nil)
    tenpai = Map.new(state.players, fn {seat, player} -> {seat, "tenpai" in player.status} end)
    nagashi = Map.new(state.players, fn {seat, player} -> {seat, "nagashi" in player.status} end)
    num_tenpai = tenpai |> Map.values() |> Enum.count(& &1)
    num_nagashi = nagashi |> Map.values() |> Enum.count(& &1)
    delta_scores = Map.new(state.players, fn {seat, _player} -> {seat, 0} end)

    {state, delta_scores} = cond do
      # handle sichuan style scoring best hands at draw (if any non-winner is tenpai)
      Map.get(score_rules, "score_best_hand_at_draw", false) and map_size(state.winners) < 3 and Enum.any?(tenpai, fn {seat, tenpai?} -> tenpai? and seat not in state.winner_seats end) ->
        # declare tenpai players as winners, as if they won from non-tenpai people (opponents)
        opponents = Enum.flat_map(tenpai, fn {seat, tenpai?} -> if not tenpai? do [seat] else [] end end)
        # for each tenpai player who hasn't won, find the highest point hand they could get
        win_definitions = translate_match_definitions(state, ["win"])
        winners_before = state.winner_seats
        state = for {seat, tenpai?} <- tenpai, tenpai?, seat not in winners_before, reduce: state do
          state ->
            # calculate possible waits
            winner = state.players[seat]
            waits = Riichi.get_waits(winner.player.hand, winner.player.calls, win_definitions, state.all_tiles, winner.tile_behavior)

            # display nothing if waits are empty
            # shouldn't happen under normal conditions, since tenpai implies nonempty waits
            waits = if Enum.empty?(waits) do MapSet.new([:"2x"]) else waits end

            # calculate new winner object
            state2 = Map.put(state, :wall_index, 0) # use this so haitei isn't scored
            winner = calculate_winner_details(state2, seat, waits, :draw)
            |> Map.put(:opponents, opponents)
            |> Map.put(:best_hand_at_draw, true)

            # add winner to state
            state
            |> Map.update!(:winners, &Map.put(&1, seat, winner))
            |> Map.update!(:winner_seats, & &1 ++ [seat])
        end

        next_screen = if Enum.any?(state.winners, fn {_seat, winner} -> not Map.has_key?(winner, :processed) end) do :winner else :scores end
        state = state
        |> Map.put(:visible_screen, next_screen)
        |> Map.put(:round_result, :draw)
        |> update_all_players(fn _seat, player -> %Player{ player | hand_revealed: true } end)

        {state, delta_scores}
      # handle nagashi
      draw_nagashi_payments && num_nagashi > 0 -> 
        # do nagashi payments
        # the way we do it kind of sucks: we modify the state and calculate the delta scores based on the total modification
        # TODO refactor to calculate the delta scores first, then apply it to the state
        [pay_ko, pay_oya] = draw_nagashi_payments
        scores_before = Map.new(state.players, fn {seat, player} -> {seat, player.score} end)
        state = for {seat, nagashi?} <- nagashi, nagashi?, payer <- state.available_seats -- [seat], reduce: state do
          state ->
            oya_payment = pay_oya
            ko_payment = if Riichi.get_east_player_seat(state.kyoku, state.available_seats) == seat do pay_oya else pay_ko end
            payment = if Riichi.get_east_player_seat(state.kyoku, state.available_seats) == payer do oya_payment else ko_payment end

            # handle kanbara satomi's scoring quirk
            payment = if "kanbara_satomi_double_loss" in state.players[payer].status do
              push_message(state, [%{text: "Player #{player_name(state, payer)} pays double since the wall ends on their side (Kanbara Satomi)"}])
              payment * 2
            else payment end

            state
            |> update_player(seat, &%Player{ &1 | score: &1.score + payment })
            |> update_player(payer, &%Player{ &1 | score: &1.score - payment })
        end
        delta_scores = Map.new(state.players, fn {seat, player} -> {seat, player.score - scores_before[seat]} end)
        {state, delta_scores}
      draw_tenpai_payments != nil ->
        [pay1, pay2, pay3] = draw_tenpai_payments
        # do tenpai payments
        delta_scores = case length(state.available_seats) do
          3 -> case num_tenpai do
            0 -> Map.new(tenpai, fn {seat, _tenpai} -> {seat, 0} end)
            1 -> Map.new(tenpai, fn {seat, tenpai} -> {seat, if tenpai do 2 * pay1 else -pay1 end} end)
            2 -> Map.new(tenpai, fn {seat, tenpai} -> {seat, if tenpai do Utils.try_integer(pay2 / 2) else -pay2 end} end)
            3 -> Map.new(tenpai, fn {seat, _tenpai} -> {seat, 0} end)
          end
          4 -> case num_tenpai do
            0 -> Map.new(tenpai, fn {seat, _tenpai} -> {seat, 0} end)
            1 -> Map.new(tenpai, fn {seat, tenpai} -> {seat, if tenpai do 3 * pay1 else -pay1 end} end)
            2 -> Map.new(tenpai, fn {seat, tenpai} -> {seat, if tenpai do pay2 else -pay2 end} end)
            3 -> Map.new(tenpai, fn {seat, tenpai} -> {seat, if tenpai do Utils.try_integer(pay3 / 3) else -pay3 end} end)
            4 -> Map.new(tenpai, fn {seat, _tenpai} -> {seat, 0} end)
          end
          _ -> Map.new(state.available_seats, fn seat -> {seat, 0} end)
        end

        # handle kanbara satomi's scoring quirk
        # (the reason it's long is because doubling 1500 payments is a special case)
        delta_scores = case Enum.find(state.players, fn {_seat, player} -> "kanbara_satomi_double_loss" in player.status end) do
          nil -> delta_scores
          {payer, _payer_player} ->
            delta = delta_scores[payer]
            if delta < 0 do
              payment = -delta
              push_message(state, [%{text: "Player #{player_name(state, payer)} pays double since the wall ends on their side (Kanbara Satomi)"}])
              delta_scores = Map.put(delta_scores, payer, delta * 2)
              case num_tenpai do
                2 -> 
                  # player who gets the doubled payment is predetermined:
                  # always pay to your right, unless right is also paying
                  recipient = Utils.next_turn(payer)
                  recipient = if delta_scores[recipient] < 0 do Utils.prev_turn(payer) else recipient end
                  Map.put(delta_scores, recipient, delta_scores[recipient] * 2)
                _ -> Map.new(tenpai, fn {seat, tenpai} -> {seat, delta_scores[seat] + if tenpai do Integer.floor_div(payment, num_tenpai) else 0 end} end)
              end
            else delta_scores end
        end

        # handle ikeda kana's scoring quirk
        delta_scores = if Enum.any?(state.players, fn {_seat, player} -> "triple_noten_payments" in player.status end) do
          push_message(state, [%{text: "Noten payments are tripled (Ikeda Kana)"}])
          Map.new(delta_scores, fn {seat, delta} -> {seat, delta * 3} end)
        else delta_scores end

        # reveal hand for those players that are tenpai
        state = update_all_players(state, fn seat, player -> %Player{ player | hand_revealed: player.hand_revealed or tenpai[seat] } end)

        {state, delta_scores}
      true -> {state, delta_scores}
    end

    # handle hanada kirame's scoring quirk
    {state, delta_scores} = hanada_kirame_score_protection(state, delta_scores)

    delta_scores_reason = if draw_nagashi_payments && num_nagashi > 0 do
      Map.get(score_rules, "nagashi_name", "Nagashi Mangan")
    else
      Map.get(score_rules, "exhaustive_draw_name", "Draw")
    end

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
    if Map.has_key?(state.rules, "score_calculation") do
      if Map.has_key?(state.rules["score_calculation"], "scoring_method") do
        state
      else
        show_error(state, "\"score_calculation\" object lacks \"scoring_method\" key!")
      end
    else
      show_error(state, "\"score_calculation\" key is missing from rules!")
    end
  end

  # rearrange the winner's hand for display on the yaku display screen
  def rearrange_winner_hand(state, seat, yaku, joker_assignment, winning_tile, new_winning_tile) do
    score_rules = state.rules["score_calculation"]

    orig_hand = state.players[seat].hand
    orig_draw = state.players[seat].draw
    orig_calls = state.players[seat].calls
    tile_behavior = state.players[seat].tile_behavior
    arrange_american_yaku = Map.get(score_rules, "arrange_american_yaku", false)
    arrange_shuntsu = Map.get(score_rules, "arrange_shuntsu", false)
    arrange_koutsu = Map.get(score_rules, "arrange_koutsu", false)
    arrange_kontsu = Map.get(score_rules, "arrange_kontsu", false)
    {arranged_hand, arranged_calls} = if arrange_american_yaku do
      {yaku_name, _value} = Enum.at(yaku, 0)
      # look for this yaku in the yaku list, and get arrangement from the match condition
      am_yakus = Enum.filter(state.rules["yaku"], fn y -> y["display_name"] == yaku_name end)
      am_yaku_match_conds = Enum.at(am_yakus, 0)["when"] |> Enum.filter(fn condition -> is_map(condition) and condition["name"] == "match" end)
      am_match_definitions = Enum.at(Enum.at(am_yaku_match_conds, 0)["opts"], 1)
      new_winning_tile = Utils.strip_attrs(new_winning_tile)
      arranged_hand = American.arrange_american_hand(am_match_definitions, Utils.strip_attrs(orig_hand) ++ [new_winning_tile], orig_calls, tile_behavior)
      if arranged_hand != nil do
        arranged_hand = arranged_hand
        |> Enum.intersperse([:"3x"])
        |> Enum.concat()
        |> Enum.reverse()
        |> then(& &1 -- [new_winning_tile])
        |> Enum.reverse()
        {arranged_hand, []}
      else {orig_hand, orig_calls} end
    else
      # otherwise, sort jokers into the hand
      arranged_hand = Utils.sort_tiles(orig_hand, joker_assignment)
      {arranged_hand, orig_calls}
    end

    # correct the hand if the winning tile was taken from hand (for display purposes)
    {arranged_hand, arranged_draw} = if winning_tile == nil do
      ix = Enum.find_index(arranged_hand, &Utils.same_tile(&1, new_winning_tile))
      {List.delete_at(arranged_hand, ix), [new_winning_tile]}
    else {arranged_hand, orig_draw} end

    win_definitions = translate_match_definitions(state, ["win"])
    arranged_hand = if arrange_kontsu do
      # sort kontsu out of the hand (append kontsu to the right)
      Riichi.arrange_kontsu(arranged_hand, orig_calls, [winning_tile || new_winning_tile], win_definitions, tile_behavior)
    else arranged_hand end
    arranged_hand = if arrange_shuntsu do
      # sort shuntsu out of the hand (append shuntsu to the left, after kontsu are sorted out)
      Riichi.arrange_shuntsu(arranged_hand, orig_calls, [winning_tile || new_winning_tile], win_definitions, tile_behavior)
    else arranged_hand end
    arranged_hand = if arrange_koutsu do
      # sort koutsu out of the hand (append koutsu after shuntsu, after shuntsu and kontsu are sorted out)
      Riichi.arrange_koutsu(arranged_hand, orig_calls, [winning_tile || new_winning_tile], win_definitions, tile_behavior)
    else arranged_hand end
    # result should look like [shuntsu, koutsu, pair, kontsu]
    # replace the resulting spacing markers with actual spaces
    arranged_hand = Enum.map(arranged_hand, &if &1 in [:shuntsu, :koutsu, :kontsu] do :"7x" else &1 end)

    # push message
    orig_call_tiles = orig_calls
    |> Enum.reject(fn {call_name, _call} -> call_name in Riichi.flower_names() end)
    |> Enum.flat_map(fn call -> Enum.take(Utils.call_to_tiles(call), 3) end) # ignore kans
    smt_hand = orig_hand ++ if winning_tile != nil do [winning_tile] else [] end ++ orig_call_tiles
    joker_assignment = joker_assignment
    |> Enum.map(fn {joker_ix, tile} -> {Enum.at(smt_hand, joker_ix), tile} end)
    |> Enum.reject(fn {joker_tile, _tile} -> Riichi.is_aka?(joker_tile) end)
    |> Map.new()
    if not Enum.empty?(joker_assignment) do
      joker_assignment_message = joker_assignment
      |> Enum.map_intersperse([%{text: ","}], fn {joker_tile, tile} -> [Utils.pt(joker_tile), %{text: "→"}, Utils.pt(tile)] end)
      |> Enum.concat()
      push_message(state, [%{text: "Using joker assignment"}] ++ joker_assignment_message)
    end

    %{ hand: arranged_hand, draw: arranged_draw, calls: arranged_calls }
  end

  # generate a winner object for a given seat
  def calculate_winner_details(state, seat, possible_winning_tiles, win_source, get_worst_yaku \\ false) do
    score_rules = state.rules["score_calculation"]

    # add winning hand to the winner player (yaku conditions often check this)
    winning_tile = Enum.at(possible_winning_tiles, 0, nil)
    call_tiles = Enum.flat_map(state.players[seat].calls, &Utils.call_to_tiles/1)
    winning_hand = state.players[seat].hand ++ call_tiles ++ if winning_tile != nil do [winning_tile] else [] end
    state = update_player(state, seat, &%Player{ &1 | cache: %PlayerCache{ &1.cache | winning_hand: winning_hand } })

    # deal with jokers
    use_smt = Map.get(score_rules, "use_smt", true)
    joker_assignments = if not use_smt or Enum.empty?(state.players[seat].tile_behavior.aliases) do [%{}] else
      smt_hand = state.players[seat].hand ++ if winning_tile != nil do [winning_tile] else [] end
      if Enum.any?(smt_hand ++ call_tiles, &TileBehavior.is_joker?(&1, state.players[seat].tile_behavior)) do
        # run smt, but push a message if it takes more than 0.5 seconds
        smt_task = Task.async(fn -> RiichiAdvanced.SMT.match_hand_smt_v2(state.smt_solver, smt_hand, state.players[seat].calls, state.all_tiles, translate_match_definitions(state, ["win"]), state.players[seat].tile_behavior) end)
        notify_task = Task.async(fn ->
          :timer.sleep(500)
          push_message(state, [%{text: "Running joker solver..."}])
        end)
        res = Task.await(smt_task, :infinity)
        if Task.yield(notify_task, 0) == nil do
          Task.shutdown(notify_task, :brutal_kill)
        end
        res
      else [%{}] end
    end
    if Debug.print_wins() do
      IO.puts("Joker assignments (calculate_winner_details): #{inspect(joker_assignments)}")
    end
    joker_assignments = if Enum.empty?(joker_assignments) do [%{}] else joker_assignments end

    # check if we're dealer
    is_dealer = Riichi.get_east_player_seat(state.kyoku, state.available_seats) == seat
    # handle ryuumonbuchi touka's scoring quirk
    score_as_dealer = "score_as_dealer" in state.players[seat].status
    if score_as_dealer do
      push_message(state, [%{text: "Player #{player_name(state, seat)} is treated as a dealer for scoring purposes (Ryuumonbuchi Touka)"}])
    end
    is_dealer = is_dealer or score_as_dealer
    
    # if we're playing bloody end, record our opponents
    bloody_end = Map.get(state.rules, "bloody_end", false)
    opponents = if bloody_end do
      Enum.reject(state.available_seats, fn dir -> Map.has_key?(state.winners, dir) or dir == seat end)
    else state.available_seats -- [seat] end

    # find the maximum score obtainable across all joker assignments
    highest_scoring_yaku_only = Map.get(score_rules, "highest_scoring_yaku_only", false)
    {joker_assignment, assigned_hand, yaku, yaku2, minipoints, new_winning_tile, score, points, points2, score_name} = for joker_assignment <- joker_assignments do
      Task.async(fn ->
        # replace 5z in joker assignment with 0z if 0z is present in the wall
        joker_assignment = if Utils.has_matching_tile?(state.all_tiles, [:"0z"]) do
          Map.new(joker_assignment, fn {ix, tile} -> {ix, if tile == :"5z" do :"0z" else tile end} end)
        else joker_assignment end

        # replace winner's hand with joker assignment to determine yaku
        {state, assigned_winning_tile} = apply_joker_assignment(state, seat, joker_assignment, winning_tile)
        assigned_hand = state.players[seat].cache.winning_hand

        # obtain yaku and minipoints
        winning_tiles = if winning_tile != nil do [assigned_winning_tile] else possible_winning_tiles end
        {yaku, minipoints, new_winning_tile} = get_best_yaku_from_lists(state, score_rules["yaku_lists"], seat, winning_tiles, win_source)
        {yaku2, _minipoints, _new_winning_tile} = if Map.has_key?(score_rules, "yaku2_lists") do
          get_best_yaku_from_lists(state, score_rules["yaku2_lists"], seat, winning_tiles, win_source)
        else {[], minipoints, new_winning_tile} end
        if Debug.print_wins() do
          IO.puts("won by #{win_source}; hand: #{inspect(assigned_hand)}, yaku: #{inspect(yaku)}, yaku2: #{inspect(yaku2)}")
        end

        # if you win with 14 tiles all in hand (no draw), then take the given winning tile
        new_winning_tile = if winning_tile == nil do new_winning_tile else winning_tile end

        # score yaku
        yaku = if highest_scoring_yaku_only do [Enum.max_by(yaku, fn {_name, value} -> value end)] else yaku end
        {score, points, points2, score_name} = score_yaku(state, seat, yaku, yaku2, is_dealer, win_source == :draw, minipoints)
        if Debug.print_wins() do
          IO.puts("score: #{inspect(score)}, points: #{inspect(points)}, points2: #{inspect(points2)}, minipoints: #{inspect(minipoints)}, score_name: #{inspect(score_name)}")
        end
        {joker_assignment, assigned_hand, yaku, yaku2, minipoints, new_winning_tile, score, points, points2, score_name}
      end)
    end
    |> Task.yield_many(timeout: :infinity)
    |> Enum.map(fn {_task, {:ok, res}} -> res end)
    |> Enum.max_by(fn {_, _, _, _, _, _, score, points, points2, _} -> {score, points, points2} end, if get_worst_yaku do &<=/2 else &>=/2 end, fn -> 0 end)

    # rearrange their hand
    %{hand: arranged_hand, draw: arranged_draw, calls: arranged_calls} = rearrange_winner_hand(state, seat, yaku, joker_assignment, winning_tile, new_winning_tile)

    # return the complete winner object
    yaku_2_overrides = not Enum.empty?(yaku2) and Map.get(score_rules, "yaku2_overrides_yaku1", false)
    %{
      seat: seat,
      player: %Player{ state.players[seat] | hand: arranged_hand, draw: arranged_draw, calls: arranged_calls },
      win_source: win_source,
      yaku: if yaku_2_overrides do [] else yaku end |> Enum.map(fn {name, value} -> {translate(state, name), value} end),
      yaku2: yaku2 |> Enum.map(fn {name, value} -> {translate(state, name), value} end),
      points: points,
      points2: points2,
      score: score,
      score_name: score_name,
      score_denomination: Map.get(score_rules, "score_denomination", ""),
      point_name: Map.get(score_rules, if yaku_2_overrides do "point2_name" else "point_name" end, ""),
      point2_name: Map.get(score_rules, "point2_name", ""),
      minipoint_name: Map.get(score_rules, "minipoint_name", ""),
      minipoints: minipoints,
      payer: case win_source do
        :draw    -> nil
        :discard -> get_last_discard_action(state).seat
        :call    -> get_last_call_action(state).seat
      end,
      winning_tile: new_winning_tile,
      right_display: cond do
        not Map.has_key?(score_rules, "right_display") -> nil
        score_rules["right_display"] == "points"       -> points
        score_rules["right_display"] == "points2"      -> points2
        score_rules["right_display"] == "minipoints"   -> minipoints
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
        :draw    -> Map.get(score_rules, "win_by_draw_label", "")
        :discard -> Map.get(score_rules, "win_by_discard_label", "")
        :call    -> Map.get(score_rules, "win_by_discard_label", "")
      end,
      opponents: opponents,
      winning_hand: winning_hand,
      assigned_hand: assigned_hand,
      arranged_hand: arranged_hand ++ arranged_draw,
      arranged_calls: arranged_calls,
    }
  end

  def update_winner_pao(state, winner) do
    Map.put(winner, :pao_seat, Enum.find(state.available_seats, fn seat -> seat != winner.payer and "pao" in state.players[seat].status end))
  end

end
