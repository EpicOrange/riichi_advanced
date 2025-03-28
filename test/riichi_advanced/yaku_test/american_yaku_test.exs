defmodule RiichiAdvanced.YakuTest.AmericanYaku do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  @nmjl_2024 ["american/no_charleston"]
  @nmjl_2025 ["american/no_charleston", "american/am_card_nmjl_2025"]
  @card_free ["american/no_charleston", "american/am_card_free"]

  setup do
    {:ok,
      nmjl_2024: TestUtils.get_rules!("american", @nmjl_2024),
      nmjl_2025: TestUtils.get_rules!("american", @nmjl_2025)
    }
  end

  test "american - uniqueness check with too few tile kinds" do
    TestUtils.test_no_win("american", @card_free, hand: "222222p2222s7777z")
  end

  test "american - does card-free work?" do
    TestUtils.test_win("american", @card_free, hand: "22m2222p2222s7777z",
      win_button: "mahjong_draw", yaku: [{"Base Value", 25}, {"Concealed", 10}])
  end

  test "american - nmjl 2024 - 2024 #1", %{nmjl_2024: rules_ref} do
    TestUtils.assert_winning_hand(rules_ref, "win", "222m000z2222s4444s")
    TestUtils.assert_winning_hand(rules_ref, "win", "222m000z2222s", "am_kong:4444s")
  end

end
