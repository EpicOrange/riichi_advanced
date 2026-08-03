defmodule RiichiAdvanced.YakuTest.MCRYaku do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils
  import RiichiAdvanced.TestUtils, only: [sigil_t: 2]

  @mcr_yaku %{
    "Big Four Winds" => 88,
    "Big Three Dragons" => 88,
    "All Green" => 88,
    "Nine Gates" => 88,
    "Four Kongs" => 88,
    "Seven Shifted Pairs" => 88,
    "All Terminals" => 64,
    "Little Four Winds" => 64,
    "Little Three Dragons" => 64,
    "All Honors" => 64,
    "Four Concealed Pungs" => 64,
    "Pure Terminal Chows" => 64,
    "Quadruple Chow" => 48,
    "Four Pure Shifted Pungs" => 48,
    "Four Pure Shifted Chows" => 32,
    "Three Kongs" => 32,
    "All Terminals and Honors" => 32,
    "Greater Honors and Knitted Tiles" => 24,
    "Full Flush" => 24,
    "Pure Triple Chow" => 24,
    "Pure Shifted Pungs" => 24,
    "Upper Tiles" => 24,
    "Middle Tiles" => 24,
    "Lower Tiles" => 24,
    "Pure Straight" => 16,
    "Three-Suited Terminal Chows" => 16,
    "Pure Shifted Chows" => 16,
    "All Fives" => 16,
    "Triple Pung" => 16,
    "Three Concealed Pungs" => 16,
    "Lesser Honors and Knitted Tiles" => 12,
    "Knitted Straight" => 12,
    "Upper Four" => 12,
    "Lower Four" => 12,
    "Big Three Winds" => 12,
    "Mixed Straight" => 8,
    "Reversible Tiles" => 8,
    "Mixed Triple Chow" => 8,
    "Mixed Shifted Pungs" => 8,
    "Last Tile Draw" => 8,
    "Last Tile Claim" => 8,
    "Out with Replacement Tile" => 8,
    "Robbing The Kong" => 8,
    "Two Concealed Kongs" => 8,
    "Chicken Hand" => 8,
    "All Pungs" => 6,
    "Half Flush" => 6,
    "Mixed Shifted Chows" => 6,
    "All Types" => 6,
    "Melded Hand" => 6,
    "Two Dragon Pungs" => 6,
    "Two Kongs" => 6,
    "Outside Hand" => 4,
    "Fully Concealed Hand" => 4,
    "Two Melded Kongs" => 4,
    "Last Tile" => 4,
    "White Dragon" => 2,
    "Green Dragon" => 2,
    "Red Dragon" => 2,
    "Prevalent Wind" => 2,
    "Seat Wind" => 2,
    "Concealed Hand" => 2,
    "All Chows" => 2,
    "Tile Hog" => 2,
    "Double Pung" => 2,
    "Two Concealed Pungs" => 2,
    "Concealed Kong" => 2,
    "All Simples" => 2,
    "Pure Double Chow" => 1,
    "Mixed Double Chow" => 1,
    "Short Straight" => 1,
    "Two Terminal Chows" => 1,
    "Pung of Terminals" => 1,
    "Pung of Honors" => 1,
    "Melded Kong" => 1,
    "One Voided Suit" => 1,
    "No Honors" => 1,
    "Self-Drawn" => 1,
    "Edge Wait" => 1,
    "Closed Wait" => 1,
    "Single Wait" => 1,
    "Pungs of Terminals" => 2,
    "Pungs of Honors" => 2,
  }

  def test_mcr(test_spec) do
    test_spec = Keyword.update!(test_spec, :yaku, &Enum.map(&1, fn {name, value} -> {name, [value, "Fan"]}; name -> {name, [Map.get(@mcr_yaku, name, 0), "Fan"]} end)) ++ [pre_events: [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
    ]]
    TestUtils.test_win("mcr", ["lib/no_flowers"], test_spec)
  end

  test "mcr - big four winds" do
    test_mcr(hand: ~t"3334477z4z pon:111z pon:222z", yaku: ["Big Four Winds", "All Honors"])
    test_mcr(hand: ~t"333z44z99m4z pon:111z pon:222z", yaku: ["Big Four Winds", "All Terminals and Honors", "Half Flush"])
    test_mcr(hand: ~t"333z44z33s4z pon:111z pon:222z", yaku: ["Big Four Winds", "Half Flush"])
  end

  test "mcr - big three dragons" do
    test_mcr(hand: ~t"000z11m99p1m pon:777z pon:666z", yaku: ["Big Three Dragons", "All Terminals and Honors"])
  end








end
