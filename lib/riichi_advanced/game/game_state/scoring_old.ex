
defmodule RiichiAdvanced.GameState.ScoringOld do
  alias RiichiAdvanced.GameState.American, as: American
  alias RiichiAdvanced.GameState.Actions, as: Actions
  alias RiichiAdvanced.GameState.Conditions, as: Conditions
  alias RiichiAdvanced.GameState.Debug, as: Debug
  alias RiichiAdvanced.GameState.Kyoku, as: Kyoku
  alias RiichiAdvanced.GameState.Player, as: Player
  alias RiichiAdvanced.GameState.PlayerCache, as: PlayerCache
  alias RiichiAdvanced.GameState.Rules, as: Rules
  alias RiichiAdvanced.GameState.Scoring, as: Scoring
  alias RiichiAdvanced.GameState.TileBehavior, as: TileBehavior
  alias RiichiAdvanced.Match, as: Match
  alias RiichiAdvanced.GameState.JokerSolver, as: JokerSolver
  alias RiichiAdvanced.GameState.Payment, as: Payment
  alias RiichiAdvanced.Riichi, as: Riichi
  alias RiichiAdvanced.Utils, as: Utils
  import RiichiAdvanced.GameState

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
        han_fu_multiplier = Map.get(score_rules, "han_fu_multiplier", 1)
        score = Utils.try_integer(points * score_multiplier * han_fu_multiplier)
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
          score = han_fu_multiplier * Enum.at(limit_scores, limit_index) * if is_dealer do dealer_multiplier else 1 end
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
        case Map.get(state.players[winner.seat].responsibilities, seat) do
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
    
    {_seat, %{seat: closest_winner}} = Enum.at(winners, 0)

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
                winner = Kyoku.calculate_winner_details(state, seat, :worst_discard)
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

end
  