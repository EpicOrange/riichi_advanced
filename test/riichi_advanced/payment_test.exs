defmodule RiichiAdvanced.PaymentTest do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.Payment, as: Payment
  alias RiichiAdvanced.Payment.WinInfo, as: WinInfo
  alias RiichiAdvanced.Utils, as: Utils
  alias RiichiAdvanced.GameState.TileBehavior, as: TileBehavior

  # mix test test/riichi_advanced/payment_test.exs
  test "determine_responsibilities" do

    Payment.determine_responsibilities([%WinInfo{
      seat: :east,
      won_by: {:discard, :south},
      yaku: [{"Tanyao", 1}, {"Honitsu", 2}, {"Toitoi", 2}, {"Dora", 2}],
      minipoints: 70,
      pao_map: %{},
      available_seats: [:east, :south, :west, :north],
      modifiers: [],
    }], :south)
    |> IO.inspect(label: "Responsibility")
    |> Enum.map(&Payment.calculate_payment(&1, "han_fu"))
    |> IO.inspect(label: "Payment")

  end

end
