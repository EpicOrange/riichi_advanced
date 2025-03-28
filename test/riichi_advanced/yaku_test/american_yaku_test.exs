defmodule RiichiAdvanced.YakuTest.AmericanYaku do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  @card_free ["american/no_charleston", "american/am_card_free"]

  test "american - uniqueness check with too few tile kinds" do
    TestUtils.test_no_win("american", @card_free, hand: "222222p2222s7777z")
  end

  test "american - does card-free work?" do
    TestUtils.test_win("american", @card_free, hand: "22m2222p2222s7777z",
      win_button: "mahjong_draw", yaku: [{"Base Value", 25}, {"Concealed", 10}])
  end

end
