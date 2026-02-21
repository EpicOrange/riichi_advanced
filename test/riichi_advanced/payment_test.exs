defmodule RiichiAdvanced.PaymentTest do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.Payment, as: Payment
  alias RiichiAdvanced.Utils, as: Utils
  alias RiichiAdvanced.GameState.TileBehavior, as: TileBehavior
  alias RiichiAdvanced.Types.Responsibility, as: Responsibility
  alias RiichiAdvanced.Types.Transaction, as: Transaction
  alias RiichiAdvanced.Types.WinInfo, as: WinInfo

  # mix test test/riichi_advanced/payment_test.exs
  test "simple haneman dealer ron" do
    resps = Payment.determine_responsibilities([%WinInfo{
      seat: :east,
      won_by: {:discard, :south},
      yaku: [{"Tanyao", 1}, {"Honitsu", 2}, {"Toitoi", 2}, {"Dora", 2}],
      minipoints: 70,
      pao_map: %{},
      available_seats: [:east, :south, :west, :north],
      modifiers: [],
    }], :east)
    assert resps == [%Responsibility{
      from: :south,
      to: :east,
      yaku: [{"Tanyao", 1}, {"Honitsu", 2}, {"Toitoi", 2}, {"Dora", 2}],
      minipoints: 70,
      modifiers: [{:*, 6, "Dealer ron"}, {:round_up, 100, "Round up"}]
    }]

    txs = Enum.map(resps, &Payment.calculate_txn(&1, "han_fu"))
    assert txs == [%Transaction{
      from: :south,
      to: :east,
      total: 18000,
      line_items: [
        %{reason: "Total", op: :=, result: 18000, amount: nil},
        %{reason: "Dealer ron", op: :*, result: 18000, amount: 6},
        %{reason: "Haneman base", op: :=, result: 3000, amount: nil},
        %{reason: "Fu", op: nil, result: 70, amount: nil},
        %{reason: "Han", op: nil, result: 7, amount: nil}
      ]
    }]
  end

end
