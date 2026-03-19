defmodule RiichiAdvanced.GameState.Payment do
  alias RiichiAdvanced.GameState.Actions, as: Actions
  alias RiichiAdvanced.GameState.Payment, as: Payment
  alias RiichiAdvanced.GameState.Rules, as: Rules
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
        op = if Enum.empty?(ret.line_items) do "=" else "+" end # omit the first +
        %{ret | line_items: [%{op: op, amount: amount, result: result, reason: txn.name} | ret.line_items]}
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
  def run_scoring_logic(state, cxt) when is_map_key(cxt, :scoring_key) and cxt.scoring_key != nil do
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
  def run_scoring_logic(state, _cxt), do: state # do nothing if no scoring key

  def get_highest_scoring_txn(state_cxts, get_worst_instead \\ false) do
    Enum.max_by(state_cxts, fn {state, cxt} -> state.txns |> Enum.filter(& &1.to == cxt.seat) |> sum_txns() |> Payment.get_txn_result() end,
      if get_worst_instead do &<=/2 else &>=/2 end,
      fn -> nil end # empty stream
    )
  end
end








