defmodule RiichiAdvanced.GameState.Payment do
  alias RiichiAdvanced.GameState.Actions, as: Actions
  alias RiichiAdvanced.GameState.Payment, as: Payment
  alias RiichiAdvanced.GameState.Rules, as: Rules
  alias RiichiAdvanced.GameState.Scoring, as: Scoring
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
        result = Utils.try_integer(acc + amount)
        op = if Enum.empty?(ret.line_items) do "=" else "+" end # omit the first +
        %{ret | line_items: [%{op: op, amount: amount, result: result, reason: txn.name} | ret.line_items]}
    end
  end

  # merge all txns into one big txn for every player whose score changed
  @spec consolidate_txns(txns: list(Transaction.t()), omit_pot_payments: boolean()) :: %{seat() => Transaction.t()}
  def consolidate_txns(txns, omit_pot_payments \\ false) do
    for %{from: from, to: to} = txn <- txns, reduce: %{} do
      ledger when omit_pot_payments and from == nil -> ledger
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
    # sort players into atamahane order
    players = Enum.sort_by(state.players, fn
      {nil, _} -> 5
      {seat, _} -> case Utils.get_relative_seat(cxt.seat, seat) do
        :shimocha -> 1
        :toimen -> 2
        :kamicha -> 3
        _ -> 4
      end
    end)

    score_rules = Rules.get(state.rules_ref, "score_calculation", %{})

    # for each player responsible for a yaku that is in cxt.yaku,
    # make an empty txn, and populate it by running scoring_logic
    all_mentioned_yaku =
      for {_seat, player} <- state.players,
          {_seat2, yakus} <- player.responsibilities,
          yaku <- yakus do yaku end |> Enum.uniq()
    unmentioned_yaku = Enum.reject(cxt.yaku, fn {name, _value} -> name in all_mentioned_yaku end)
    # IO.inspect(cxt.yaku, label: "cxt.yaku")
    # IO.inspect(all_mentioned_yaku, label: "all_mentioned_yaku")
    # IO.inspect(unmentioned_yaku, label: "unmentioned_yaku")
    state = for {payer, player} <- players,
        payer != cxt.seat,
        {seat, yakus} <- player.responsibilities,
        seat == cxt.seat,
        reduce: state do
      state ->
        # modify the points and yaku to only be for the ones payer is responsible for
        new_yaku = Enum.flat_map(yakus, &
          if &1 == "all" do
            unmentioned_yaku
          else
            Enum.find(cxt.yaku, fn {name, _value} -> name == &1 end)
            |> case do
              nil -> []
              yaku -> [yaku]
            end
          end)
        |> Enum.uniq()
        # |> IO.inspect(label: inspect(payer))
        # only make a txn if we have yaku
        state = if not Enum.empty?(new_yaku) do
          new_points = new_yaku
          |> Enum.map(fn {_name, value} -> value end)
          |> Enum.reduce([], &Scoring.add_yaku_values/2)

          # create an empty txn
          txn_name = case Utils.get_relative_seat(seat, payer) do
            :self     -> "From self"
            :shimocha -> "From right"
            :toimen   -> "From across"
            :kamicha  -> "From left"
          end
          txn = %Transaction{name: txn_name, from: payer, to: seat, line_items: []}
          state = update_in(state.txns, &[txn | &1])

          # run scoring_logic to populate this new txn with line items
          scoring_logic_actions = Rules.get(state.rules_ref, "scoring_logic", %{}) |> Map.get(cxt.scoring_key, nil)
          state = if scoring_logic_actions != nil do
            cxt = %{cxt |
              seat: payer,
              yaku: new_yaku,
              points: Utils.get_from_points_list(new_points, score_rules["point_name"]),
              points2: Utils.get_from_points_list(new_points, score_rules["point2_name"]),
            }
            # set winner object to cxt, for the purposes of evaluating scoring_logic
            state = Map.update!(state, :winners, &Map.put(&1, seat, Map.merge(cxt, &1[seat])))
            Actions.run_actions(state, scoring_logic_actions, cxt)
          else
            IO.puts("[WARNING] scoring_logic[#{inspect(cxt.scoring_key)}] is empty!")
            state
          end
          state
        else state end
        state
    end
    # then give pot to winner
    state = if state.pot > 0 do
      line_item = %{op: "+", amount: state.pot, result: state.pot, reason: "Riichi sticks"}
      pot_txn = %Transaction{name: "Riichi sticks", from: nil, to: cxt.seat, line_items: [line_item]}
      state = update_in(state.txns, &[pot_txn | &1])
      state
    else state end
    state
  end
  def run_scoring_logic(state, _cxt), do: state # do nothing if no scoring key

  def get_highest_scoring_txn(state_cxts, get_worst_instead \\ false) do
    Enum.max_by(state_cxts, fn {state, cxt} ->
        # note: this score is zero if we're not using the new scoring system
        score = state.txns |> Enum.filter(& &1.to == cxt.seat) |> sum_txns() |> Payment.get_txn_result()
        num_yaku = length(cxt.yaku)
        {score, cxt.points, cxt.points2, cxt.minipoints, -num_yaku}
        # |> IO.inspect(label: inspect(cxt.yaku))
      end,
      if get_worst_instead do &<=/2 else &>=/2 end,
      fn -> nil end # empty stream
    )
  end
end








