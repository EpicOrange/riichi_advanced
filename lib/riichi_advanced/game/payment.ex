defmodule RiichiAdvanced.GameState.Payment do
  alias RiichiAdvanced.GameState.Actions, as: Actions
  alias RiichiAdvanced.GameState.Payment, as: Payment
  alias RiichiAdvanced.GameState.Rules, as: Rules
  alias RiichiAdvanced.GameState.TileBehavior, as: TileBehavior
  alias RiichiAdvanced.Riichi, as: Riichi
  alias RiichiAdvanced.Utils, as: Utils
  alias RiichiAdvanced.Types, as: Types
  alias RiichiAdvanced.Types.Transaction, as: Transaction
  # alias RiichiAdvanced.Types.DrawInfo, as: DrawInfo

  @type seat() :: Types.seat()
  @type line_item() :: Types.line_item()

  @spec seat_to_str(seat: seat() | nil) :: binary()
  def seat_to_str(nil), do: "pot"
  def seat_to_str(seat), do: Atom.to_string(seat) |> String.capitalize()

  # just adds a blank line item that flips the sign of the result
  @spec invert_txn(txn: Transaction.t()) :: Transaction.t()
  def invert_txn(txn) do
    %{txn | line_items: [%{op: :*, amount: -1, result: -get_txn_result(txn), reason: ""} | txn.line_items]}
  end

  # result of a transaction is just the value of its final (index 0) line item
  @spec get_txn_result(txn: Transaction.t()) :: number()
  def get_txn_result(txn) do
    if Enum.empty?(txn.line_items) do 0 else Enum.at(txn.line_items, 0).result end
  end

  # sum all txns, resulting in a summary txn
  # assumes `from`, `to` are the same across all txns
  @spec sum_txns(txn: list(Transaction.t())) :: Transaction.t()
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
    # for each entry in responsibilities, make a txn, and populate it by running scoring_logic
    for {payer, player} <- state.players,
        {seat, _yaku_spec} <- player.responsibilities,
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
# - responsibilities
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








