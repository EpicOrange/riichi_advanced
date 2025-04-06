
defmodule RiichiAdvanced.GameState.Scoring do
  alias RiichiAdvanced.GameState.American, as: American
  alias RiichiAdvanced.GameState.Actions, as: Actions
  alias RiichiAdvanced.GameState.Conditions, as: Conditions
  alias RiichiAdvanced.GameState.Debug, as: Debug
  alias RiichiAdvanced.GameState.Player, as: Player
  alias RiichiAdvanced.GameState.PlayerCache, as: PlayerCache
  alias RiichiAdvanced.GameState.Rules, as: Rules
  alias RiichiAdvanced.GameState.TileBehavior, as: TileBehavior
  alias RiichiAdvanced.Match, as: Match
  alias RiichiAdvanced.Riichi, as: Riichi
  alias RiichiAdvanced.Utils, as: Utils
  import RiichiAdvanced.GameState

  def get_yaku(state, yaku_list, seat, winning_tile, win_source, minipoints, existing_yaku) do
    context = %{
      seat: seat,
      winning_tile: winning_tile,
      win_source: win_source,
      minipoints: minipoints,
      existing_yaku: existing_yaku
    }
    eligible_yaku = yaku_list
      |> Enum.filter(fn %{"display_name" => _name, "value" => _value, "when" => cond_spec} -> Conditions.check_cnf_condition(state, cond_spec, context) end)
      |> Enum.map(fn %{"display_name" => name, "value" => value, "when" => _cond_spec} -> {name, Actions.interpret_amount(state, context, value)} end)
    eligible_yaku = existing_yaku ++ eligible_yaku
    yaku_map = Enum.reduce(eligible_yaku, %{}, fn {name, value}, acc -> Map.update(acc, name, value, & &1 + value) end)
    eligible_yaku = eligible_yaku
      |> Enum.map(fn {name, _value} -> name end)
      |> Enum.uniq()
      |> Enum.map(fn name -> {name, yaku_map[name]} end)
    eligible_yaku = case Rules.get(state.rules_ref, "yaku_precedence") do
      nil -> eligible_yaku
      yaku_precedence ->
        excluded_yaku = Enum.flat_map(eligible_yaku, fn {name, _value} -> Map.get(yaku_precedence, name, []) end)
        Enum.reject(eligible_yaku, fn {name, value} -> name in excluded_yaku or value in excluded_yaku end)
    end
    eligible_yaku
  end

  def get_yaku_advanced(state, yaku_list, seat, winning_tiles, win_source, existing_yaku \\ []) do
    # returns a map %{winning_tile => {minipoints, yakus}}
    if winning_tiles == nil or winning_tiles == [nil] or Enum.empty?(winning_tiles) do
      # try every possible winning tile from hand
      for {winning_tile, i} <- Enum.with_index(state.players[seat].hand), winning_tile != nil, into: %{} do
        state2 = update_player(state, seat, &%Player{ &1 | hand: List.delete_at(&1.hand, i), draw: [Utils.add_attr(winning_tile, ["_draw"])] })
        minipoints = Map.get(state.players[seat].counters, "fu", 0)
        yakus = get_yaku(state2, yaku_list, seat, winning_tile, win_source, minipoints, existing_yaku)
        {winning_tile, {minipoints, yakus}}
      end
    else
      for winning_tile <- winning_tiles, into: %{} do
        minipoints = Map.get(state.players[seat].counters, "fu", 0)
        yakus = get_yaku(state, yaku_list, seat, winning_tile, win_source, minipoints, existing_yaku)
        {winning_tile, {minipoints, yakus}}
      end
    end
  end

  def get_best_yaku_and_winning_tile(state, yaku_list, seat, winning_tiles, win_source, existing_yaku \\ []) do
    # returns {winning_tile, best_minipoints, best_yakus}
    # we take best in terms of total points, then least number of yaku
    get_yaku_advanced(state, yaku_list, seat, winning_tiles, win_source, existing_yaku)
    |> Enum.max_by(fn {_winning_tile, {_minipoints, possible_yaku}} -> {Enum.reduce(possible_yaku, 0, fn {_name, value}, acc -> acc + value end), -length(possible_yaku)} end)
  end

  def get_best_yaku(state, yaku_list, seat, winning_tiles, win_source, existing_yaku \\ []) do
    {_winning_tile, {_minipoints, best_yaku}} = get_best_yaku_and_winning_tile(state, yaku_list, seat, winning_tiles, win_source, existing_yaku)
    best_yaku
  end

  def get_best_yaku_from_lists(state, yaku_list_names, seat, winning_tiles, win_source) do
    # returns {yaku, minipoints, new_winning_tile}
    score_rules = Rules.get(state.rules_ref, "score_calculation", %{})
    declare_only_yaku_list_names = Map.get(score_rules, "declare_only_yaku_lists", [])
    for yaku_list_name <- yaku_list_names, reduce: {[], 0, nil} do
      {yaku, minipoints, new_winning_tile} ->
        if Rules.has_key?(state.rules_ref, yaku_list_name) do
          yaku_list = if yaku_list_name in declare_only_yaku_list_names do
            declared_yaku = state.players[seat].declared_yaku
            Enum.filter(Rules.get(state.rules_ref, yaku_list_name, []), fn yaku_obj -> yaku_obj["display_name"] in declared_yaku end)
          else Rules.get(state.rules_ref, yaku_list_name, []) end
          {new_winning_tile, {minipoints, yaku}} = get_best_yaku_and_winning_tile(state, yaku_list, seat, winning_tiles, win_source, yaku)
          {yaku, minipoints, new_winning_tile}
        else
          {yaku, minipoints, new_winning_tile}
        end
    end
  end

  def apply_joker_assignment(state, seat, joker_assignment, win_source) do
    orig_hand = state.players[seat].hand
    {flower_calls, non_flower_calls} = Enum.split_with(state.players[seat].calls, fn {call_name, _call} -> call_name in Riichi.flower_names() end)
    assigned_hand = orig_hand |> Enum.with_index() |> Enum.map(fn {tile, ix} -> Map.get(joker_assignment, ix, tile) end)
    assigned_non_flower_calls = non_flower_calls
    |> Enum.with_index()
    |> Enum.map(fn {{call_name, call}, i} ->
      call = call
      |> Enum.with_index()
      |> Enum.map(fn {tile, ix} -> Map.get(joker_assignment, length(orig_hand) + 1 + 3*i + ix, tile) end)
      {call_name, call}
    end)
    assigned_calls = flower_calls ++ assigned_non_flower_calls
    # length(orig_hand) is where the solver puts the winning tile
    # if the winning tile is a joker, the following gets its assignment
    assigned_winning_tile = Map.get(joker_assignment, length(orig_hand), nil)
    state = if assigned_winning_tile != nil do
      update_winning_tile(state, seat, win_source, fn _ -> assigned_winning_tile end)
    else state end
    assigned_winning_hand = assigned_hand ++ Enum.flat_map(assigned_calls, &Utils.call_to_tiles/1) ++ if assigned_winning_tile != nil do [assigned_winning_tile] else [] end
    state = update_player(state, seat, &%Player{ &1 | hand: assigned_hand, calls: assigned_calls, cache: %PlayerCache{ &1.cache | winning_hand: assigned_winning_hand } })
    state
  end

  def seat_scores_points(state, yaku_list_names, min_points, min_minipoints, seat, winning_tile, win_source) do
    solve_for_jokers(state, seat, winning_tile)
    |> Task.async_stream(fn joker_assignment ->
      state = apply_joker_assignment(state, seat, joker_assignment, win_source)

      # run before_win actions
      state = Actions.trigger_event(state, "before_win", %{seat: seat, win_source: win_source})
      # run before_scoring actions
      state = Actions.trigger_event(state, "before_scoring", %{seat: seat, win_source: win_source})

      # get winning tile after before_scoring does its thing
      winning_tiles = get_winning_tiles(state, seat, win_source)
      {yaku, minipoints, _winning_tile} = get_best_yaku_from_lists(state, yaku_list_names, seat, winning_tiles, win_source)
      minipoints >= min_minipoints && case min_points do
        :declared ->
          names = Enum.map(yaku, fn {name, _value} -> name end)
          Enum.all?(state.players[seat].declared_yaku, fn yaku -> yaku in names end)
        _ ->
          points = Enum.map(yaku, fn {_name, value} -> value end) |> Enum.sum()
          points >= min_points
      end
    end, timeout: :infinity, ordered: false)
    |> Enum.any?(fn {:ok, result} -> result end)
  end

  def score_yaku(state, seat, yaku, yaku2, is_dealer, is_self_draw, minipoints \\ 0) do
    score_rules = Rules.get(state.rules_ref, "score_calculation", %{})
    yaku2_overrides = not Enum.empty?(yaku2) and Map.get(score_rules, "yaku2_overrides_yaku1", false)

    scoring_method = score_rules["scoring_method"]
    # TODO generalize this
    {yaku, scoring_method} = if yaku2_overrides and not Enum.empty?(yaku2) do
      {yaku2, if is_list(scoring_method) do Enum.at(scoring_method, 1, Enum.at(scoring_method, 0)) else scoring_method end}
    else
      {yaku, if is_list(scoring_method) do Enum.at(scoring_method, 0) else scoring_method end}
    end

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
        han_fu_starting_han = Map.get(score_rules, "han_fu_starting_han", 2)
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
          base_score = han_fu_multiplier * minipoints * 2 ** (han_fu_starting_han + points)
          score = base_score * if is_dealer do dealer_multiplier else 1 end
          {score, nil}
        end

        score = score * if "double_score" in state.players[seat].status do 2 else 1 end

        {score, points, 0, name}
      _ ->
        GenServer.cast(self(), {:show_error, "Unknown scoring method #{inspect(scoring_method)}"})
        {0, 0, 0, ""}
    end

    dealer_multiplier = if scoring_method == "han_fu_formula" do 1 else Map.get(score_rules, "dealer_multiplier", 1) end
    self_draw_bonus = Map.get(score_rules, "self_draw_bonus", 0)
    score = score * if is_dealer do dealer_multiplier else 1 end |> Utils.try_integer()
    score = score + if is_self_draw do self_draw_bonus else 0 end

    # apply tsumo loss (sanma only)
    tsumo_loss = Map.get(score_rules, "tsumo_loss", true)
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

    score = if scoring_method == "han_fu_formula" do
      # round up (to nearest 100, by default)
      han_fu_rounding_factor = Map.get(score_rules, "han_fu_rounding_factor", 100)
      trunc(Float.ceil(score / han_fu_rounding_factor)) * han_fu_rounding_factor
    else score end

    min_score = Map.get(score_rules, "min_score", 0)
    score = max(score, min_score)

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
          push_message(state, player_prefix(state, hanada_kirame_seat) ++ [%{text: "stays at zero points, and receives 8000 points from first place (Hanada Kirame)"}])
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

  defp calculate_delta_scores_tsumo(state, winner, basic_score, is_dealer) do
    score_rules = Rules.get(state.rules_ref, "score_calculation", %{})
    basic_score = if "wareme" in state.players[winner.seat].status do
      push_message(state, player_prefix(state, winner.seat) ++ [%{text: "gains double points for wareme"}])
      basic_score * 2
    else basic_score end
    
    # for riichi, reverse-calculate the ko and oya parts of the total points
    split_oya_ko_payment = Map.get(score_rules, "split_oya_ko_payment", false)
    num_players = length(state.available_seats)
    # calculate ko and oya payment from basic_score
    # (if dealer tsumo, oya payment is unused)
    {ko_payment, oya_payment} = if split_oya_ko_payment and num_players >= 3 do
      han_fu_rounding_factor = Map.get(score_rules, "han_fu_rounding_factor", 100)
      tsumo_loss = Map.get(score_rules, "tsumo_loss", true)
      {ko_payment, oya_payment} = Riichi.calc_ko_oya_points(basic_score, is_dealer, num_players, han_fu_rounding_factor)
      {ko_payment, oya_payment} = cond do
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
      # round one last time
      ko_payment = trunc(Float.ceil(ko_payment / han_fu_rounding_factor)) * han_fu_rounding_factor
      oya_payment = trunc(Float.ceil(oya_payment / han_fu_rounding_factor)) * han_fu_rounding_factor
      {ko_payment, oya_payment}
    else {basic_score, basic_score} end

    # handle motouchi naruka's scoring quirk
    motouchi_naruka_delta = 100 * Integer.floor_div(state.pot, max(1, Map.get(score_rules, "riichi_value", 1000)))
    {ko_payment, oya_payment} = if "motouchi_naruka_increase_tsumo_payment" in state.players[winner.seat].status do
      push_message(state, player_prefix(state, winner.seat) ++ [%{text: "has tsumo payments increased by 300 per 1000 bet (%{delta}) (Motouchi Naruka)", vars: %{delta: 3 * motouchi_naruka_delta}}])
      {ko_payment + motouchi_naruka_delta, oya_payment + motouchi_naruka_delta}
    else {ko_payment, oya_payment} end
    {ko_payment, oya_payment} = if "motouchi_naruka_decrease_tsumo_payment" in state.players[winner.seat].status do
      push_message(state, player_prefix(state, winner.seat) ++ [%{text: "has tsumo payments decreased by 300 per 1000 bet (%{delta}) (Motouchi Naruka)", vars: %{delta: 3 * motouchi_naruka_delta}}])
      {max(0, ko_payment - motouchi_naruka_delta), max(0, oya_payment - motouchi_naruka_delta)}
    else {ko_payment, oya_payment} end

    # have each payer pay their allotted share
    dealer_seat = Riichi.get_east_player_seat(state.kyoku, state.available_seats)
    delta_scores = Map.new(state.players, fn {seat, _player} -> {seat, 0} end)
    for payer <- winner.opponents, reduce: delta_scores do
      delta_scores ->
        payment = if payer == dealer_seat do oya_payment else ko_payment end
        payment = if "atago_hiroe_no_tsumo_payment" in state.players[payer].status do
          push_message(state, player_prefix(state, payer) ++ [%{text: "is damaten, and immune to tsumo payments (Atago Hiroe)"}])
          0
        else payment end
        payment = if "double_tsumo_payment" in state.players[payer].status do
          push_message(state, player_prefix(state, payer) ++ [%{text: "pays double for tsumo (Maya Yukiko)"}])
          payment * 2
        else payment end
        payment = if "double_payment" in state.players[payer].status do
          push_message(state, player_prefix(state, payer) ++ [%{text: "pays double (Yae Kobashiri)"}])
          payment * 2
        else payment end
        payment = if "megan_davin_double_payment" in state.players[winner.seat].status and "megan_davin_double_payment" in state.players[payer].status do
          push_message(state, player_prefix(state, payer) ++ [%{text: "pays double to their duelist (Megan Davin)"}])
          payment * 2
        else payment end
        payment = if "kanbara_satomi_double_loss" in state.players[payer].status do
          push_message(state, player_prefix(state, payer) ++ [%{text: "pays double since the wall ends on their side (Kanbara Satomi)"}])
          payment * 2
        else payment end
        payment = if "tsujigaito_satoha_double_score" in state.players[winner.seat].status do
          push_message(state, player_prefix(state, winner.seat) ++ [%{text: "gets double points for winning under someone else's ippatsu (Tsujigaito Satoha)"}])
          payment * 2
        else payment end
        payment = if "wareme" in state.players[payer].status do
          push_message(state, player_prefix(state, payer) ++ [%{text: "loses double points for wareme"}])
          payment * 2
        else payment end

        dealer_self_draw_multiplier = Map.get(score_rules, "dealer_self_draw_multiplier", 1)
        dealer_seat = Riichi.get_east_player_seat(state.kyoku, state.available_seats)
        multiplier = if dealer_seat in [payer, winner.seat] do dealer_self_draw_multiplier else 1 end
        payment = payment * multiplier
        
        delta_scores = Map.update!(delta_scores, payer, & &1 - payment)
        delta_scores = Map.update!(delta_scores, winner.seat, & &1 + payment)
        delta_scores
    end
  end
  defp apply_ron_score_modifiers(state, winner, payer, basic_score) do
    payment = basic_score
    payment = if "wareme" in state.players[winner.seat].status do
      push_message(state, player_prefix(state, winner.seat) ++ [%{text: "gains double points for wareme"}])
      payment * 2
    else payment end
    payment = if "megan_davin_double_payment" in state.players[winner.seat].status and "megan_davin_double_payment" in state.players[payer].status do
      push_message(state, player_prefix(state, payer) ++ [%{text: "pays double to their duelist (Megan Davin)"}])
      payment * 2
    else payment end
    payment = if "double_payment" in state.players[payer].status do
      push_message(state, player_prefix(state, payer) ++ [%{text: "pays double (Yae Kobashiri)"}])
      payment * 2
    else payment end
    payment = if "kanbara_satomi_double_loss" in state.players[payer].status do
      push_message(state, player_prefix(state, payer) ++ [%{text: "pays double since the wall ends on their side (Kanbara Satomi)"}])
      payment * 2
    else payment end
    payment = if "tsujigaito_satoha_double_score" in state.players[winner.seat].status do
      push_message(state, player_prefix(state, winner.seat) ++ [%{text: "gets double points for winning under someone else's ippatsu (Tsujigaito Satoha)"}])
      payment * 2
    else payment end
    manzu = "yoshitome_miharu_manzu" in state.players[payer].status and Utils.has_matching_tile?([winner.winning_tile], [:"1m",:"2m",:"3m",:"4m",:"5m",:"6m",:"7m",:"8m",:"9m"])
    pinzu = "yoshitome_miharu_pinzu" in state.players[payer].status and Utils.has_matching_tile?([winner.winning_tile], [:"1p",:"2p",:"3p",:"4p",:"5p",:"6p",:"7p",:"8p",:"9p"])
    souzu = "yoshitome_miharu_souzu" in state.players[payer].status and Utils.has_matching_tile?([winner.winning_tile], [:"1s",:"2s",:"3s",:"4s",:"5s",:"6s",:"7s",:"8s",:"9s"])
    payment = if manzu or pinzu or souzu do
      push_message(state, player_prefix(state, payer) ++ [%{text: "pays half due to dealing in with their voided suit (Yoshitome Miharu)"}])
      Utils.half_score_rounded_up(payment)
    else payment end

    payment
  end

  defp calculate_delta_scores_for_single_winner(state, winner, collect_sticks) do
    score_rules = Rules.get(state.rules_ref, "score_calculation", %{})
    delta_scores = Map.new(state.players, fn {seat, _player} -> {seat, 0} end)

    # get riichi and honba payment
    {riichi_payment, honba_payment} = if collect_sticks do {state.pot, Map.get(score_rules, "honba_value", 0) * state.honba} else {0, 0} end
    honba_payment = if "multiply_honba_with_han" in state.players[winner.seat].status do honba_payment * winner.points else honba_payment end
    add_honba = fn {payer, {yaku, yaku2, shares, mult, penalty}}, honba_payment -> {payer, {yaku, yaku2, shares, mult, penalty + honba_payment}} end

    # calculate liabilities for the payer (discarder) and non-discarders

    # calculate some surprise tools that will help us later
    discarder_multiplier = Map.get(score_rules, "discarder_multiplier", 1)
    discarder_penalty = Map.get(score_rules, "discarder_penalty", 0)
    non_discarder_multiplier = Map.get(score_rules, "non_discarder_multiplier", 0)
    non_discarder_penalty = Map.get(score_rules, "non_discarder_penalty", 0)
    self_draw_multiplier = Map.get(score_rules, "self_draw_multiplier", 1)
    self_draw_penalty = Map.get(score_rules, "self_draw_penalty", 0)
    payer_liability = if winner.payer == nil do
      {winner.payer, {winner.yaku, winner.yaku2, 0, self_draw_multiplier, self_draw_penalty}}
    else
      {winner.payer, {winner.yaku, winner.yaku2, 1, discarder_multiplier, discarder_penalty}}
    end
    nonpayer_liabilities_ron = for seat <- winner.opponents -- [winner.payer] do
      {seat, {winner.yaku, winner.yaku2, 1, non_discarder_multiplier, non_discarder_penalty}}
    end
    # nonpayer_liabilities_tsumo = for seat <- winner.opponents -- [winner.payer] do
    #   {seat, {winner.yaku, winner.yaku2, self_draw_multiplier, 1, self_draw_penalty}}
    # end

    # split into several more payments if pao
    # liabilities is a list of {payer, {yaku, yaku2, shares, mult, penalty}}
    # first element of liabilities is always the original payer (from winner map)
    liabilities = for seat <- winner.opponents -- [winner.payer], reduce: [payer_liability] do
      [{payer, {yaku, yaku2, shares, mult, penalty}} | liabilities] ->
        case Map.get(state.players[winner.seat].pao_map, seat) do
          nil -> [{payer, {yaku, yaku2, shares, mult, penalty}} | liabilities]
          pao_yaku_list ->
            # take original yaku if complete pao happens
            complete_pao = "all" in pao_yaku_list
            {pao_yaku, yaku} = if complete_pao do {winner.yaku, []} else Enum.split_with(yaku, fn {name, _value} -> name in pao_yaku_list end) end
            {pao_yaku2, yaku2} = if complete_pao do {winner.yaku2, []} else Enum.split_with(yaku2, fn {name, _value} -> name in pao_yaku_list end) end
            if payer != nil and Map.get(score_rules, "split_pao_ron", true) do
              [{payer, {yaku ++ pao_yaku, yaku2 ++ pao_yaku2, shares, mult, penalty}}, {seat, {pao_yaku, pao_yaku2, 1, discarder_multiplier, penalty}} | liabilities]
            else
              [{payer, {yaku, yaku2, shares, mult, penalty}}, {seat, {pao_yaku, pao_yaku2, 1, discarder_multiplier, penalty}} | liabilities]
            end
        end
    end
    |> case do
      # zero out first liability (original payer) if no yaku and there's at least one pao player
      [{payer, {[], [], _, _, _}}, pao | rest] -> [{payer, {[], [], 0, 0, 0}}, pao | rest]
      # otherwise keep original payer liability + possible pao liabilities
      liabilities -> liabilities
    end
    # put original payer liability last while ordering pao liabilities in atamahane order
    # order is important because only the first liability pays honba
    |> Enum.sort_by(fn
      {nil, _} -> 4
      {seat, _} -> case Utils.get_relative_seat(winner.seat, seat) do
        _ when seat == winner.payer -> 4
        :shimocha -> 1
        :toimen -> 2
        :kamicha -> 3
        _ -> 4
      end
    end)
    # add honba as additional penalty
    |> case do
      # if tsumo with no pao players, add 1x honba payment
      [{nil, _} = liability] -> [add_honba.(liability, honba_payment)]
      # otherwise, for ron with no pao players, only the payer (discarder) pays (num_opponents)x honba
      [liability] -> [add_honba.(liability, length(winner.opponents) * honba_payment) | nonpayer_liabilities_ron]
      # otherwise, first pao player pays (num_opponents)x honba
      [liability | rest] -> [add_honba.(liability, length(winner.opponents) * honba_payment) | rest]
    end
    # |> IO.inspect(label: "liabilities")

    # determine dealer
    is_dealer = Riichi.get_east_player_seat(state.kyoku, state.available_seats) == winner.seat
    # handle ryuumonbuchi touka's scoring quirk
    is_dealer = is_dealer or "score_as_dealer" in state.players[winner.seat].status

    # first get the total number of shares (only applicable for ron)
    total_shares = Enum.map(liabilities, fn {_payer, {_yaku, _yaku2, shares, mult, penalty}} -> if mult != 0 or penalty != 0 do shares else 0 end end) |> Enum.sum()
    # then calculate payments individually
    delta_scores = for {payer, {yaku, yaku2, shares, mult, penalty}} <- liabilities, reduce: delta_scores do
      delta_scores when payer == nil ->
        # tsumo
        {basic_score, _, _, _} = score_yaku(state, winner.seat, yaku, yaku2, is_dealer, true, winner.minipoints)
        tsumo_delta_scores = calculate_delta_scores_tsumo(state, winner, basic_score, is_dealer)
        # apply mult and penalty to tsumo_delta_scores
        tsumo_delta_scores = for seat <- winner.opponents, reduce: tsumo_delta_scores do
          delta_scores -> delta_scores |> Map.update!(winner.seat, & (&1 * mult) + penalty) |> Map.update!(seat, & (&1 * mult) - penalty)
        end
        # add tsumo delta scores to accumulator
        delta_scores = for {seat, score} <- tsumo_delta_scores, reduce: delta_scores do
          delta_scores -> Map.update!(delta_scores, seat, &Utils.try_integer(&1 + score))
        end
        delta_scores
      delta_scores ->
        # ron or pao or single tsumo payment
        {basic_score, _, _, _} = score_yaku(state, winner.seat, yaku, yaku2, is_dealer, false, winner.minipoints)
        basic_score = if total_shares > 0 do Utils.try_integer(basic_score * (shares / total_shares)) else basic_score end

        # apply score modifiers from player statuses
        payment = apply_ron_score_modifiers(state, winner, payer, basic_score)

        # apply mult and penalty to payment
        payment = Utils.try_integer((payment * mult) + penalty)

        # apply payment to delta_scores
        delta_scores
        |> Map.update!(payer, &Utils.try_integer(&1 - payment))
        |> Map.update!(winner.seat, &Utils.try_integer(&1 + payment))
    end
    # award riichi sticks (pot)
    |> Map.update!(winner.seat, & &1 + riichi_payment)

    # handle iwadate yuan's scoring quirk
    delta_scores = if Map.has_key?(state.players[winner.seat].counters, "iwadate_yuan_payment") do
      amount = state.players[winner.seat].counters["iwadate_yuan_payment"]
      push_message(state, player_prefix(state, winner.seat) ++ [%{
        text: "is paid 1000 additional points (%{amount}) by everyone for each ura, each aka, ippatsu, and each chun used as five (Iwadate Yuan)",
        vars: %{amount: amount}
      }])
      for {seat, delta} <- delta_scores, delta < 0, reduce: delta_scores do
        delta_scores -> delta_scores |> Map.update!(winner.seat, & &1 + amount) |> Map.update!(seat, & &1 - amount)
      end
    else delta_scores end

    # handle arakawa kei's scoring quirk
    delta_scores = if "use_arakawa_kei_scoring" in winner.player.status do
      win_definitions = Rules.translate_match_definitions(state.rules_ref, ["win"])
      visible_tiles = get_visible_tiles(state, winner.seat)
      waits = Riichi.get_waits_and_ukeire(winner.player.hand, winner.player.calls, win_definitions, state.wall ++ state.dead_wall, visible_tiles, winner.tile_behavior)
      if "arakawa-kei" in winner.player.status do
        # everyone pays winner 100 points per live out
        ukeire = waits |> Map.values() |> Enum.sum()
        push_message(state, player_prefix(state, winner.seat) ++ [%{
          text: "is paid %{payment} by everyone for having %{ukeire} live out(s) (Arakawa Kei)",
          vars: %{payment: 100 * ukeire, ukeire: ukeire}
        }])
        delta_scores
        |> Map.new(fn {seat, score} -> {seat, score - 100 * ukeire} end)
        |> Map.update!(winner.seat, & &1 + 400 * ukeire)
      else
        # winner pays arakawa kei 1000 points per waiting tile in her hand
        {arakawa_kei_seat, arakawa_kei} = Enum.find(state.players, fn {_seat, player} -> "arakawa-kei" in player.status end)
        waiting_tiles = Map.keys(waits)
        num = Utils.count_tiles(arakawa_kei.hand, waiting_tiles)
        push_message(state, player_prefix(state, arakawa_kei_seat) ++ [%{
          text: "is paid %{payment} by winner for having %{num} wait(s) in hand (Arakawa Kei)",
          vars: %{payment: 1000 * num, num: num}
        }])
        delta_scores
        |> Map.update!(winner.seat, & &1 - 1000 * num)
        |> Map.update!(arakawa_kei_seat, & &1 + 1000 * num)
      end
    else delta_scores end

    delta_scores
  end

  defp calculate_delta_scores_per_player(state, winners) do
    score_rules = Rules.get(state.rules_ref, "score_calculation", %{})

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
              win_definitions = Rules.translate_match_definitions(state.rules_ref, ["win"])
              waits = Riichi.get_waits(player.hand, player.calls, win_definitions, player.tile_behavior)
              if not Enum.empty?(waits) do
                # calculate the worst yaku we can get
                winner = calculate_winner_details(state, seat, :worst_discard)
                worst_yaku = if Enum.empty?(winner.yaku2) do winner.yaku else winner.yaku2 end

                # add honba
                score = winner.score + (Map.get(score_rules, "honba_value", 0) * state.honba)

                if not Enum.empty?(worst_yaku) do
                  hand = Utils.sort_tiles(player.hand) ++ Enum.flat_map(player.calls, &Utils.call_to_tiles/1)
                  yaku = Enum.map_join(worst_yaku, ", ", fn {name, value} -> "#{name} (#{value})" end)
                  push_message(state, player_prefix(state, seat) ++ [
                    %{text: "dealt in while tenpai with hand %{hand} which, if won on %{tile} scores a minimum value of %{score} via the following yaku: %{yaku} (Ezaki Hitomi)",
                      vars: %{hand: {:hand, hand}, tile: {:tile, winner.winning_tile}, score: {:text, score, %{bold: true}}, yaku: yaku}},
                  ])

                  # compare score with the amount we will pay out
                  payment = -delta_scores[seat]
                  if payment < score do
                    # reflect the payment
                    push_message(state, player_prefix(state, seat) ++ [%{text: "has greater tenpai value than their deal-in value, and therefore reverses the payment, not including riichi sticks (Ezaki Hitomi)"}])
                    delta_scores
                    |> Map.put(seat, payment)
                    |> Map.update!(winner_seat, & &1 - 2 * payment)
                  else
                    push_message(state, player_prefix(state, seat) ++ [%{text: "has less or equal tenpai value than their deal-in value, and therefore the payment proceeds as normal (Ezaki Hitomi)"}])
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
    delta_scores = for {_seat, deltas} <- calculate_delta_scores_per_player(state, winners), reduce: delta_scores do
      delta_scores_acc -> Map.new(delta_scores_acc, fn {seat, delta} -> {seat, delta + deltas[seat]} end)
    end

    # multiply by delta_score_multiplier counter, if it exists
    delta_scores = Map.new(delta_scores, fn {seat, delta} -> {seat, delta * Map.get(state.players[seat].counters, "delta_score_multiplier", 1)} end)

    # add delta_score counter, if it exists
    delta_scores = Map.new(delta_scores, fn {seat, delta} -> {seat, delta + Map.get(state.players[seat].counters, "delta_score", 0)} end)

    is_tsumo = Enum.any?(winners, fn {_seat, winner} -> winner.payer == nil end)
    is_pao = Enum.any?(winners, fn {_seat, winner} -> not Enum.empty?(winner.player.pao_map) end)

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
          true                   -> winner.payer # if there are multiple first winners, the payer becomes the next dealer instead
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

    # handle sichuan style scoring best hands at draw (if there are 2+ non-winners and anyone is tenpai)
    score_best_hand_at_draw = Map.get(score_rules, "score_best_hand_at_draw", false)
      and map_size(state.winners) < 3
      and Enum.any?(tenpai, fn {seat, tenpai?} -> tenpai? and seat not in state.winner_seats end)
    {state, delta_scores} = if score_best_hand_at_draw do
      # declare tenpai players as winners, as if they won from non-tenpai people (opponents)
      opponents = Enum.reject(state.available_seats, &tenpai[&1])
      # for each tenpai player who hasn't won, find the highest point hand they could get
      winners_before = state.winner_seats
      state = for {seat, tenpai?} <- tenpai, tenpai?, seat not in winners_before, reduce: state do
        state ->
          # calculate new winner object
          state2 = Map.put(state, :wall_index, 0) # use this so haitei isn't scored
          winner = calculate_winner_details(state2, seat, :best_draw)
          |> Map.put(:opponents, opponents)

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
    else {state, delta_scores} end

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

  # rearrange the winner's hand for display on the yaku display screen
  def rearrange_winner_hand(state, seat, yaku, joker_assignment, winning_tile) do
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
    if arrange_american_yaku do
      {yaku_name, _value} = Enum.at(yaku, 0)
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
      obvious_joker_assignment = TileBehavior.get_obvious_joker_assignment(tile_behavior, smt_hand, smt_calls)
      non_obvious_joker_assignment = Map.drop(joker_assignment, Map.keys(obvious_joker_assignment))
      |> Enum.map(fn {joker_ix, tile} -> {Enum.at(smt_hand ++ Enum.concat(smt_calls), joker_ix), tile} end)
      if not Enum.empty?(non_obvious_joker_assignment) do
        joker_assignment_message = non_obvious_joker_assignment
        |> Enum.map_intersperse([%{text: ","}], fn {joker_tile, tile} -> [Utils.pt(joker_tile), %{text: "→"}, Utils.pt(tile)] end)
        |> Enum.concat()
        push_message(state, [%{text: "Using joker assignment"}] ++ joker_assignment_message)
      end

      # IO.puts("rearrange_winner_hand: #{inspect(System.system_time(:millisecond) - t)} ms")

      %{ hand: arranged_hand, separated_hand: separated_hand, calls: arranged_calls }
    end
  end

  defp calculate_winner_details_task(state, %{seat: seat, winning_tile: nil, win_source: :draw} = context, joker_assignment) do
    # try using each tile in hand as the draw instead
    Task.async_stream(
      state.players[seat].hand,
      fn winning_tile ->
        # move the winning tile from hand to draw
        state
        |> update_player(seat, &%Player{ &1 | hand: &1.hand -- [winning_tile], draw: [winning_tile] })
        |> calculate_winner_details_task(%{context | winning_tile: winning_tile}, joker_assignment)
      end,
      timeout: :infinity, ordered: false
    )
    |> Stream.map(fn {:ok, res} -> res end)
    |> get_best_winner_details()
  end
  defp calculate_winner_details_task(state, context, joker_assignment) do
    %{
      seat: seat,
      winning_tile: winning_tile,
      win_source: win_source,
      is_dealer: is_dealer
    } = context
    score_rules = Rules.get(state.rules_ref, "score_calculation", %{})
    tile_behavior = state.players[seat].tile_behavior
    highest_scoring_yaku_only = Map.get(score_rules, "highest_scoring_yaku_only", false)

    # replace 5z in joker assignment with 0z if 0z is present in the game
    # TODO remove this once the framed_5z mod is applied to every relevant ruleset
    # joker_assignment = if Map.has_key?(tile_behavior.tile_freqs, :"0z") do
    #   Map.new(joker_assignment, fn {ix, tile} -> {ix, if tile == :"5z" do :"0z" else tile end} end)
    # else joker_assignment end

    # temporarily replace winner's hand with joker assignment to determine yaku
    prev_hand = state.players[seat].hand
    state = apply_joker_assignment(state, seat, joker_assignment, win_source)

    # run before_scoring actions
    state = Actions.trigger_event(state, "before_scoring", %{seat: seat, win_source: win_source})

    # get winning tile after before_scoring does its thing
    winning_tiles = get_winning_tiles(state, seat, win_source)

    # obtain yaku and minipoints
    {yaku, minipoints, new_winning_tile} = get_best_yaku_from_lists(state, Map.get(score_rules, "yaku_lists", []), seat, winning_tiles, win_source)
    {yaku2, _minipoints, _new_winning_tile} = if Map.has_key?(score_rules, "yaku2_lists") do
      get_best_yaku_from_lists(state, Map.get(score_rules, "yaku2_lists", []), seat, winning_tiles, win_source)
    else {[], minipoints, new_winning_tile} end
    if Debug.print_wins() do
      assigned_winning_hand = state.players[seat].cache.winning_hand
      IO.puts("checking assignment, hand: #{inspect(assigned_winning_hand)}, tile: #{inspect(new_winning_tile)}, yaku: #{inspect(yaku)}, yaku2: #{inspect(yaku2)}")
    end

    # winning tile is nil if you won with e.g. 14 tiles in hand self draw
    # or if it's sichuan bloody rules and you won takame of your tenpai hand
    # in the first case, move winning tile from hand to draw
    # in the second case, nothing to take out, so do nothing
    winning_tile = if winning_tile == nil and new_winning_tile != nil do
      case Match.try_remove_all_tiles(prev_hand, [new_winning_tile], tile_behavior) do
        [] -> new_winning_tile
        [remainder | _] -> Enum.at(prev_hand -- remainder, 0)
      end
    else winning_tile end

    # score yaku
    yaku = if not Enum.empty?(yaku) and highest_scoring_yaku_only do [Enum.max_by(yaku, fn {_name, value} -> value end)] else yaku end
    yaku2 = if not Enum.empty?(yaku2) and highest_scoring_yaku_only do [Enum.max_by(yaku2, fn {_name, value} -> value end)] else yaku2 end
    {score, points, points2, score_name} = score_yaku(state, seat, yaku, yaku2, is_dealer, win_source == :draw, minipoints)
    if Debug.print_wins() do
      IO.puts("score: #{inspect(score)}, points: #{inspect(points)}, points2: #{inspect(points2)}, minipoints: #{inspect(minipoints)}, score_name: #{inspect(score_name)}")
    end

    %{
      joker_assignment: joker_assignment,
      winning_tile: winning_tile,
      yaku: yaku,
      yaku2: yaku2,
      score: score,
      points: points,
      points2: points2,
      minipoints: minipoints,
      score_name: score_name
    }
  end
  def get_best_winner_details(winner_details_stream, get_worst_instead \\ false) do
    Enum.max_by(winner_details_stream,
      fn %{score: score, points: points, points2: points2, minipoints: minipoints, yaku: yaku, yaku2: yaku2} -> {score, points, points2, minipoints, -length(yaku), -length(yaku2)} end,
      if get_worst_instead do &<=/2 else &>=/2 end,
      fn -> nil end # empty stream
    )
  end
  def solve_for_jokers(state, seat, winning_tile) do
    # first grab the obvious jokers (the ones that map only to one value)
    tile_behavior = state.players[seat].tile_behavior
    smt_hand = state.players[seat].hand ++ if winning_tile != nil do [winning_tile] else [] end
    smt_calls = state.players[seat].calls
    |> Enum.reject(fn {call_name, _call} -> call_name in Riichi.flower_names() end)
    |> Enum.map(&Utils.call_to_tiles/1)
    obvious_joker_assignment = TileBehavior.get_obvious_joker_assignment(tile_behavior, smt_hand, smt_calls)

    score_rules = Rules.get(state.rules_ref, "score_calculation", %{})
    use_smt = Map.get(score_rules, "use_smt", true)
    if use_smt do
      # replace smt hand/calls with obvious jokers, so the smt solver doesn't solve for those
      {[smt_hand | smt_calls], _} = for group <- [smt_hand | smt_calls], reduce: {[], 0} do
        {acc, start_ix} ->
          {acc ++ [for {tile, ix} <- Enum.with_index(group) do
            Map.get(obvious_joker_assignment, start_ix + ix, tile)
          end], start_ix + length(group)}
      end
      # then run smt, if other jokers exist
      if Enum.any?(smt_hand ++ Enum.concat(smt_calls), &TileBehavior.is_joker?(&1, tile_behavior)) do
        RiichiAdvanced.SMT.match_hand_smt_v3(state.smt_solver, smt_hand, smt_calls, Rules.translate_match_definitions(state.rules_ref, ["win"]), tile_behavior)
      else Stream.concat([[%{}]]) end
    else Stream.concat([[%{}]]) end
    |> Enum.map(&Map.merge(obvious_joker_assignment, &1))
  end

  # The main scoring calculator is calculate_winner_details/3
  # It's kind of complicated so here's a short explainer
  # 
  # - calculate_winner_details/3 is called with state, the winner's seat, and win_source
  # - win_source can be :discard, :draw, or :call (there are other values but ignore them)
  # - the point is, win_source determines where in state to look for the winning tile
  # - then it's just a matter of calling calculate_winner_details_task/3,
  #   which calculates the score given winning tile
  # 
  # problem #1: the winning tile may not exist. consider tenhou: 14 tiles are in hand, which is winning?
  # solution: call calculate_winner_details_task/3 with every tile in hand, and get the best one
  # 
  # problem #2: there are jokers in hand but we need to figure out how to assign the jokers to tiles in order to score
  # solution: when jokers exist, we call the SMT solver to get a stream of all possible joker assignments
  #           then we try each one with calculate_winner_details_task/3 to see which is the highest-scoring
  #
  # - unsurprisingly this results in a lot of calls to calculate_winner_details_task/3 in the worst case
  # - so we parallelize but that's it
  # - solving that is problem #3, which remains unsolved to this day

  # generate a winner object for a given seat
  def calculate_winner_details(state, seat, win_source) do
    score_rules = Rules.get(state.rules_ref, "score_calculation", %{})

    # add winning hand to the winner player (yaku conditions often check this)
    winning_tiles = get_winning_tiles(state, seat, win_source)
    winning_tile = if MapSet.size(winning_tiles) == 1 do Enum.at(winning_tiles, 0) else nil end
    call_tiles = Enum.flat_map(state.players[seat].calls, &Utils.call_to_tiles/1)
    winning_hand = state.players[seat].hand ++ call_tiles ++ if winning_tile != nil do [winning_tile] else [] end
    state = update_player(state, seat, &%Player{ &1 | cache: %PlayerCache{ &1.cache | winning_hand: winning_hand } })

    # check if we're dealer
    is_dealer = Riichi.get_east_player_seat(state.kyoku, state.available_seats) == seat
    # handle ryuumonbuchi touka's scoring quirk
    score_as_dealer = "score_as_dealer" in state.players[seat].status
    if score_as_dealer do
      push_message(state, player_prefix(state, seat) ++ [%{text: "is treated as a dealer for scoring purposes (Ryuumonbuchi Touka)"}])
    end
    is_dealer = is_dealer or score_as_dealer
    
    # if we're playing bloody end, record our opponents
    bloody_end = Rules.get(state.rules_ref, "bloody_end", false)
    opponents = if bloody_end do
      Enum.reject(state.available_seats, fn dir -> Map.has_key?(state.winners, dir) or dir == seat end)
    else state.available_seats -- [seat] end

    # consume the smt stream
    # but push a message if it takes more than 0.5 seconds to solve
    notify_task = Task.async(fn ->
      :timer.sleep(500)
      push_message(state, [%{text: "Running joker solver..."}])
    end)
    # find the maximum score obtainable across all joker assignments
    context = %{
      seat: seat,
      winning_tile: winning_tile,
      win_source: win_source,
      is_dealer: is_dealer
    }
    winner_details = Task.async_stream(
      solve_for_jokers(state, seat, winning_tile),
      &calculate_winner_details_task(state, context, &1),
      timeout: :infinity, ordered: false
    )
    |> Stream.map(fn {:ok, res} -> res end)
    |> get_best_winner_details(win_source == :worst_discard)
    winner_details = if winner_details == nil do
      # perhaps it's a special hand not supported by the smt solver,
      # in any case, we got no assignment from the solver,
      # so score the hand as is (with no joker assignment)
      calculate_winner_details_task(state, context, %{})
    else winner_details end

    # kill the 0.5s timer if it's still sleeping
    if Task.yield(notify_task, 0) == nil do
      Task.shutdown(notify_task, :brutal_kill)
    end

    # run before_scoring actions again with assigned hand
    # this is because we threw away the state in calculate_winner_details_task
    state = case Rules.get(state.rules_ref, "before_scoring") do
      nil -> state
      before_scoring ->
        prev_hand = state.players[seat].hand
        prev_calls = state.players[seat].calls
        state = apply_joker_assignment(state, seat, winner_details.joker_assignment, win_source)
        state = Actions.run_actions(state, before_scoring["actions"], %{seat: seat, win_source: win_source})
        state = update_player(state, seat, &%Player{ &1 | hand: prev_hand, calls: prev_calls })
        state
    end

    # now we proceed to constructing the winner object
    %{
      joker_assignment: joker_assignment,
      winning_tile: winning_tile,
      yaku: yaku,
      yaku2: yaku2,
      score: score,
      points: points,
      points2: points2,
      minipoints: minipoints,
      score_name: score_name
    } = winner_details

    # rearrange the winner's hand for display purposes
    %{
      hand: arranged_hand,
      separated_hand: separated_hand,
      calls: arranged_calls
    } = rearrange_winner_hand(state, seat, yaku, joker_assignment, winning_tile)

    # return the complete winner object
    yaku2_overrides = not Enum.empty?(yaku2) and Map.get(score_rules, "yaku2_overrides_yaku1", false)
    payer = case win_source do
      :draw           -> nil
      :best_draw      -> nil
      :second_discard -> get_last_discard_action(state).seat
      :worst_discard  -> get_last_discard_action(state).seat
      :discard        -> get_last_discard_action(state).seat
      :call           -> get_last_call_action(state).seat
    end
    yaku = if yaku2_overrides do [] else yaku end |> Enum.map(fn {name, value} -> {translate(state, name), value} end)
    yaku2 = Enum.map(yaku2, fn {name, value} -> {translate(state, name), value} end)
    %{
      seat: seat,
      player: %Player{ state.players[seat] | hand: arranged_hand, calls: arranged_calls },
      win_source: win_source,
      yaku: yaku,
      yaku2: yaku2,
      existing_yaku: yaku ++ yaku2,
      points: points,
      points2: points2,
      score: score,
      displayed_score: score,
      score_name: score_name,
      score_denomination: Map.get(score_rules, "score_denomination", ""),
      point_name: Map.get(score_rules, if yaku2_overrides do "point2_name" else "point_name" end, ""),
      point2_name: Map.get(score_rules, "point2_name", ""),
      minipoint_name: Map.get(score_rules, "minipoint_name", ""),
      minipoints: minipoints,
      payer: payer,
      winning_tile: winning_tile,
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
        :draw           -> Map.get(score_rules, "win_by_draw_label", "")
        :best_draw      -> Map.get(score_rules, "win_by_draw_label", "")
        :second_discard -> Map.get(score_rules, "win_by_discard_label", "")
        :worst_discard  -> Map.get(score_rules, "win_by_discard_label", "")
        :discard        -> Map.get(score_rules, "win_by_discard_label", "")
        :call           -> Map.get(score_rules, "win_by_discard_label", "")
      end,
      opponents: opponents,
      winning_hand: winning_hand,
      separated_hand: separated_hand,
      arranged_hand: arranged_hand,
      arranged_calls: arranged_calls,
    }
  end

end
