defmodule RiichiAdvanced.GameState.Payment do
  alias RiichiAdvanced.GameState.Actions, as: Actions
  alias RiichiAdvanced.GameState.Payment, as: Payment
  alias RiichiAdvanced.GameState.Rules, as: Rules
  alias RiichiAdvanced.GameState.TileBehavior, as: TileBehavior
  alias RiichiAdvanced.Riichi, as: Riichi
  alias RiichiAdvanced.Utils, as: Utils
  alias RiichiAdvanced.Types, as: Types
  alias RiichiAdvanced.Types.Responsibility, as: Responsibility
  alias RiichiAdvanced.Types.Transaction, as: Transaction
  alias RiichiAdvanced.Types.WinInfo, as: WinInfo
  # alias RiichiAdvanced.Types.DrawInfo, as: DrawInfo

  @type seat() :: Types.seat()
  @type line_item() :: Types.line_item()
  @type modifier() :: Types.modifier()

  @spec order_seats_from(list(seat()), seat()) :: list(seat())
  def order_seats_from(seats, starting_seat) do
    seats
    |> Enum.sort_by(fn seat -> Utils.get_relative_seat(starting_seat, seat)
      |> case do :shimocha -> 1; :toimen -> 2; :kamicha -> 3; _ -> 0; end
    end)
  end

  @spec seat_to_str(seat: seat()) :: binary()
  def seat_to_str(nil), do: "pot"
  def seat_to_str(seat), do: Atom.to_string(seat) |> String.capitalize()

  # TODO this is only for han_fu
  @spec determine_responsibilities(list(WinInfo.t()), %{
    dealer_seat: seat(),
    pot: number(),
    honba: number(),
    honba_value: number(),
    modifiers: list(modifier()),
  }) :: list(Responsibility.t())
  def determine_responsibilities(winners, opts) do
    ret = for win_info <- winners, reduce: [] do
      ret ->
        is_dealer? = win_info.seat == opts.dealer_seat
        is_pao? = not Enum.empty?(win_info.pao_map)
        case win_info.won_by do
          {:discard, discarder_seat} ->
            # process all the pao yaku first (if any)
            {all_pao_yaku, ret} = if is_pao? do
              # we start from winner and go in turn order
              # note: if there are 2 pao players for the same yaku, both still pay half
              # (also note this cannot occur in standard riichi)
              {all_pao_yaku, ret} = for seat <- order_seats_from(win_info.available_seats, win_info.seat), reduce: {win_info.yaku, ret} do
                {all_pao_yaku, ret} -> case win_info.pao_map[seat] do
                  nil -> {all_pao_yaku, ret}
                  {pao_seat, pao_yaku_names} ->
                    pao_yaku = Enum.filter(win_info.yaku, fn {name, _value} -> name in pao_yaku_names end)
                    pao_yaku2 = Enum.filter(win_info.yaku2, fn {name, _value} -> name in pao_yaku_names end)
                    pao_win_info = %WinInfo{ win_info | won_by: {:discard, pao_seat}, yaku: pao_yaku, yaku2: pao_yaku2, pao_map: %{}, modifiers: [{:/, 2, "Pao ron halving"}] }
                    first = Enum.empty?(ret)
                    ret = determine_responsibilities([pao_win_info], %{opts | pot: 0, honba: if first do opts.honba else 0 end}) ++ ret
                    {pao_yaku ++ pao_yaku2 ++ all_pao_yaku, ret}
                end
              end
              # process pao yaku for discarder
              discarder_win_info = %WinInfo{ win_info | yaku: all_pao_yaku, pao_map: %{} }
              ret = determine_responsibilities([discarder_win_info], %{opts | pot: 0, honba: 0}) ++ ret
              {all_pao_yaku, ret}
            else {[], []} end

            # then process non-pao yaku for discarder
            modifiers = opts.modifiers ++
              if is_dealer? do [{:*, 6, "Dealer ron"}] else [{:*, 4, "Nondealer ron"}] end ++
              if is_pao? do [{:/, 2, "Pao ron halving"}] else [] end ++
              [{:round_up, 100, "Round up"}] ++
              if is_pao? or opts.honba === 0 do [] else [{:+, 3 * opts.honba_value * opts.honba, "Honba"}] end
            ret = [%Responsibility{
              from: discarder_seat,
              to: win_info.seat,
              yaku: win_info.yaku -- all_pao_yaku,
              yaku2: win_info.yaku2 -- all_pao_yaku,
              minipoints: win_info.minipoints,
              modifiers: modifiers
            } | ret]

            ret
          {:draw, _seat} ->
            # if it's pao, it's the same as a direct hit ron but only for the pao yaku
            # if multiple players are pao, they all pay a full direct hit ron :)
            # (only first one pays honba though)
            {all_pao_yaku, ret} = if is_pao? do
              for seat <- order_seats_from(win_info.available_seats, win_info.seat), reduce: {win_info.yaku, ret} do
                {all_pao_yaku, ret} -> case win_info.pao_map[seat] do
                  nil -> {all_pao_yaku, ret}
                  {pao_seat, pao_yaku_names} -> 
                    pao_yaku = Enum.filter(win_info.yaku, fn {name, _value} -> name in pao_yaku_names end)
                    pao_yaku2 = Enum.filter(win_info.yaku2, fn {name, _value} -> name in pao_yaku_names end)
                    pao_win_info = %WinInfo{ win_info | won_by: {:discard, pao_seat}, yaku: pao_yaku, yaku2: pao_yaku2, pao_map: %{}, modifiers: [] }
                    first = Enum.empty?(ret)
                    ret = determine_responsibilities([pao_win_info], %{opts | pot: 0, honba: if first do opts.honba else 0 end}) ++ ret
                    {pao_yaku ++ all_pao_yaku, ret}
                end
              end
            else {[], []} end

            # regular tsumo payment for all the non-pao yaku
            ret = for seat <- win_info.available_seats -- [win_info.seat], reduce: ret do
              ret ->
                dealer_bonus = if is_dealer? or seat === opts.dealer_seat do [{:*, 2, "Dealer tsumo"}] else [{:*, 1, "Nondealer tsumo"}] end
                modifiers = dealer_bonus ++ if Enum.empty?(win_info.yaku2) do [{:round_up, 100, "Round up"}] else [] end
                modifiers = modifiers ++ if opts.honba === 0 do [] else [{:+, opts.honba_value * opts.honba, "Honba"}] end
                [%Responsibility {
                  from: seat,
                  to: win_info.seat,
                  yaku: win_info.yaku -- all_pao_yaku,
                  yaku2: win_info.yaku2 -- all_pao_yaku,
                  minipoints: win_info.minipoints,
                  modifiers: modifiers,
                } | ret]
            end
            ret
          {:call, caller_seat} ->
            # exactly the same as win by discard
            discard_win_info = %{ win_info | won_by: {:discard, caller_seat} }
            ret = determine_responsibilities([discard_win_info], %{opts | pot: 0}) ++ ret
            ret
      end
    end

    # first winner takes pot
    ret = if opts.pot > 0 do
      first_winner = Enum.map(winners, & &1.seat) |> order_seats_from(opts.dealer_seat) |> Enum.at(0)
      [%Responsibility{
        from: nil,
        to: first_winner,
        yaku: [],
        minipoints: 0,
        modifiers: [{:+, opts.pot, "Riichi sticks"}],
      } | ret]
    else ret end
    ret
  end

  def apply_op(l, op, r) do
    case op do
      :+          -> l + r
      :-          -> l - r
      :*          -> l * r
      :/          -> l / r
      :round_up   -> ceil(l / r) * r
      :round_down -> floor(l / r) * r
    end
    |> Utils.try_integer()
  end

  @spec apply_modifiers({number(), list(line_item())}, list(modifier())) :: {number(), list(line_item())}
  def apply_modifiers({base, line_items}, modifiers) do
    # apply all modifiers and include them as line items
    {total, line_items} = for {op, value, reason} <- modifiers, reduce: {base, line_items} do
      {acc, line_items} ->
        acc = apply_op(acc, op, value)
        line_items = [%{op: op, amount: value, result: acc, reason: reason} | line_items]
        {acc, line_items}
    end
    line_items = [%{op: :=, amount: nil, result: total, reason: "Total"} | line_items]
    {total, line_items}
  end

  @spec calculate_txn(Responsibility.t(), %{binary() => any()}) :: Transaction.t()
  def calculate_txn(resp, score_rules) do
    yaku2_overrides_yaku1 = Map.get(score_rules, "yaku2_overrides_yaku1", false)
    scoring_method = Map.get(score_rules, "scoring_method", "multiplier")
    case scoring_method do
      [method1, method2] when yaku2_overrides_yaku1 ->
        if Enum.empty?(resp.yaku2) do
          calculate_txn(resp, score_rules, method1)
        else
          calculate_txn(%{resp | yaku: resp.yaku2}, %{score_rules | "point_name" => score_rules["point2_name"]}, method2)
        end
      [method1, method2] ->
        calculate_txn(resp, score_rules, method1)
        calculate_txn(resp, score_rules, method2)
      method -> calculate_txn(resp, score_rules, method)
    end
  end

  @spec calculate_txn(Responsibility.t(), %{binary() => any()}) :: Transaction.t()
  @spec calculate_txn(Responsibility.t(), %{binary() => any()}, binary()) :: Transaction.t()
  def calculate_txn(resp, score_rules, "multiplier") do
    %{"score_multiplier" => score_multiplier} = score_rules

    points = resp.yaku
    |> Enum.map(fn {_yaku, value} -> value end)
    |> Enum.sum()
    line_items = [%{op: nil, amount: nil, result: points, reason: score_rules["point_name"]}]
    base = score_multiplier * points
    line_items = [%{op: :*, amount: score_multiplier, result: base, reason: "Base"} | line_items]
    {_total, line_items} = apply_modifiers({base, line_items}, resp.modifiers)

    %Transaction{
      name: "#{seat_to_str(resp.from)} → #{seat_to_str(resp.to)}",
      from: resp.from,
      to: resp.to,
      line_items: line_items,
    }
  end
  def calculate_txn(resp, score_rules, "han_fu_formula") do
    %{"limit_thresholds" => limit_thresholds, "limit_scores" => limit_scores, "limit_names" => limit_names} = score_rules

    # han is just the sum of all yaku values
    han = resp.yaku
    |> Enum.map(fn {_yaku, value} -> value end)
    |> Enum.sum()
    fu = resp.minipoints
    line_items = [%{op: nil, amount: nil, result: han, reason: "Han"}]
    # check limit hands to see if we need to fix base to some number
    limit_index = Enum.find_index(limit_thresholds, fn [han_limit, fu_limit] -> han >= han_limit and fu >= fu_limit end)

    # remove round_up from modifiers if it's a limit hand
    modifiers = if limit_index == nil do resp.modifiers else Enum.filter(resp.modifiers, fn {op, _, _} -> op != :round_up end) end

    {_total, line_items} = if limit_index != nil do
      base = Enum.at(limit_scores, limit_index, 0)
      name = Enum.at(limit_names, limit_index, "")
      line_items = [%{op: nil, amount: nil, result: fu, reason: "Fu"} | line_items]
      line_items = [%{op: :=, amount: nil, result: base, reason: "#{name} base"} | line_items]
      {base, line_items}
    else
      mult = 4 * (2 ** han)
      base = mult * fu
      line_items = [%{op: nil, amount: nil, result: mult, reason: "Han mult."} | line_items]
      line_items = [%{op: nil, amount: nil, result: fu, reason: "Fu"} | line_items]
      line_items = [%{op: :*, amount: mult, result: base, reason: "Base"} | line_items]
      {base, line_items}
    end
    |> apply_modifiers(modifiers)

    %Transaction{
      name: "#{seat_to_str(resp.from)} → #{seat_to_str(resp.to)}",
      from: resp.from,
      to: resp.to,
      line_items: line_items,
    }
  end

  # just adds a blank line item that flips the sign of the result
  def invert_txn(txn) do
    %{txn | line_items: [%{op: :*, amount: -1, result: -get_txn_result(txn), reason: ""} | txn.line_items]}
  end

  # result of a transaction is just the value of its final (index 0) line item
  def get_txn_result(txn) do
    if Enum.empty?(txn.line_items) do 0 else Enum.at(txn.line_items, 0).result end
  end
  # applies the line items in txn2 on the result of txn1, obtaining a new result
  # assumes `from`, `to` are the same
  def sequence_txns(txn1, txn2) do
    for %{op: op, amount: amount} = line_item <- Enum.reverse(txn2.line_items), reduce: txn1 do
      ret ->
        total = apply_op(ret.total, op, amount)
        %{ret | line_items: [%{line_item | total: total} | ret.line_items]}
    end
  end
  # sum all txns, resulting in a summary txn
  # assumes `from`, `to` are the same across all txns
  def sum_txns(txns) do
    for txn <- txns, reduce: %Transaction{} do
      ret ->
        acc = get_txn_result(ret)
        amount = get_txn_result(txn)
        result = acc + amount
        %{ret | line_items: [%{op: :+, amount: amount, result: result, reason: txn.name} | ret.line_items]}
    end
  end

  # merge all txns into one big txn for every player whose score changed
  @spec consolidate_txns(txns: list(Transaction.t())) :: %{seat() => Transaction.t()}
  def consolidate_txns(txns) do
    for %{from: from, to: to} = txn <- txns, reduce: %{} do
      ledger ->
        txn2 = invert_txn(txn)
        ledger
        |> Map.update(to, [txn], &[txn | &1])
        |> Map.update(from, [txn2], &[txn2 | &1])
    end
    |> Utils.map_over_values(&sum_txns/1)
  end
  
  # populates a new entry in state.txns using scoring_logic
  def run_scoring_logic(state, cxt, payers) do
    # for each entry in pao_map, make a txn, and populate it by running scoring_logic
    for {payer, player} <- state.players,
        {seat, _yaku_spec} <- player.pao_map,
        seat == cxt.seat,
        reduce: state do
      state ->
        # create an empty txn
        txn_name = "#{seat_to_str(payer)} → #{seat_to_str(seat)}"
        txn = %Transaction{name: txn_name, from: payer, to: seat, line_items: []}
        state = update_in(state.txns, &[txn | &1])

        # run scoring_logic to populate this new txn with line items
        scoring_logic_actions = Rules.get(state.rules_ref, "scoring_logic", %{}) |> Map.get(cxt.scoring_key, nil)
        state = if scoring_logic_actions != nil do
          Actions.run_actions(state, scoring_logic_actions, cxt)
        else
          IO.puts("[WARNING] scoring_logic[#{inspect(cxt.scoring_key)}] is empty!")
          state
        end

        state
    end
  end

  def get_highest_scoring_txn(state_cxts, get_worst_instead \\ false) do
    Enum.max_by(state_cxts, fn {state, cxt} -> state.txns |> Enum.filter(& &1.to == cxt.seat) |> sum_txns() |> Payment.get_txn_result() end,
      if get_worst_instead do &<=/2 else &>=/2 end,
      fn -> nil end # empty stream
    )
  end
end

# more fleshed out implementation notes
# 
# each win has some easy things to calculate, and some hard things. easy things:
# - seat that won (the one with the winning hand)
# - won_by: :discard, :draw, or :call
# - pao_map
# - available_seats
# - dealer_seat
# - pot, honba
# - score_rules
# hard things:
# - yaku and yaku2 (requires evaluating jokers)
# - minipoints (is its own thing)

# these are currently handled by Scoring.calculate_winner_details.
# this function is extremely stateful, and does:
# - [OK] using passed in win_source, determines which tile was used to win (winning tile)
# - [NO] sets global winning_hand variable to (hand + calls + winning tile)
# - [OK] check if we're dealer (also handle ryuumonbuchi touka "i score as if i'm dealer" power)
# - [OK] for bloody end, save all opponents, to know from whom payments are coming from
# - [OK] launch smt solver async to get all possible joker assignments. if none was found, then just leave in the jokers
# - [OK] otherwise, replace jokers with their assigned identities, and score the hand
# - [NO] run before_scoring (also very stateful), saving hand and calls before doing so
# - [OK] output all the information ever into a huge object, the winner object, and return it

# the [NO] lines cannot be copypasted over, since they are stateful, but most things can be done here
# in particular, we can make a function that does all the stuff between the two NO lines
# 
# this means we need to make a function that:
# - is passed in %WinSpec{winning_seat, win_source, winning_tile, the hand and calls, dealer seat, bloody end opponents
# - launches smt solver if needed
# - does a joker replacement
# - scores the hand
# - returns the {score, etc} of the ideal joker assignment



# temp implementation notes
#
#   structure for payments:
#   - each payment is from one player to another (multiple payments possible)
#   - the list of payments is determined after yaku processing (pao needs yaku knowledge)
#   - there may be multiple payments from A to B (e.g. daisangen pao + non-daisangen ron)
#   - some sakicards reverse payments, so negative payments are possible
#   - when displayed, payments should always be positive
#   - when displayed, payments should have some history attached to it
#   - the base score is calculated based on (payment relationship, minipoints, yaku)
#   - ... * some multiplier (passed in, e.g. tsumo 2x/1x vs ron 6x/4x)
#   - ... + some penalty (passed in, e.g. MCR 8 points, honba value)
#   
#   so it's a 2 phase process
#   - first phase figures out all the arrows (who pays whom) with no score attached
#     - to do this, we need to know:
#     - win_source (ron, tsumo, chankan)
#     - who dealt the last tile (last_discarder)
#     - who drew the last tile (winner)
#     - sakicards stuff (e.g. ezaki doesn't pay tsumos)
#     - the pot is also a valid target (to/from)
#     - (this calculates the multiplier + penalty, using game state and hand)
#     - payment situations once you have base score down:
#       - ron OR chankan OR tsumo pao (W <- L) = 4x base score, 6x if dealer
#       - tsumo OR hu OR nagashi (W <- LLL) = 2x base score if dealer, 1x base score if nondealer
#       - double ron/chankan (WW <- L) = 4x base score each, 6x if dealer
#       - triple ron/chankan (WWW <- L) = 4x base score each, 6x if dealer
#       - ron pao (W <- LL) = 2x base score each
#       - ryuukyoku (W <- LLL, WW <- LL, WWW <- L) = 3000/#Ls each?

#   - second phase takes in first phase DAG + yaku + minipoints, and outputs:
#     - score_yaku => delta_scores
#     - calculation history for each arrow
#       - only insert entries into this via some display_payment_step action?
#       - combine multiedge arrows into one, to be separated by <hr>








