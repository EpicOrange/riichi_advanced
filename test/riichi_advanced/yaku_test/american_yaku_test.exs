defmodule RiichiAdvanced.YakuTest.AmericanYaku do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  @nmjl_2024 ["american/no_charleston"]
  @nmjl_2025 ["american/no_charleston", "american/am_card_nmjl_2025"]
  @card_free ["american/no_charleston", "american/am_card_free"]
  @am_aliases %{
    any: %{[] => MapSet.new([:"1j"])},
    "1f": %{[] => MapSet.new([:"1g", :"2f", :"2g", :"3f", :"3g", :"4f", :"4g"])}
  }

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
    TestUtils.assert_winning_hand(rules_ref, "win", "222m000z2222s4444s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "222m000z2222s", "am_kong:4444s", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "22m00z222s111j", "am_kong:4444s", @am_aliases)
  end

  test "american - nmjl 2024 - 2024 #2", %{nmjl_2024: rules_ref} do
    TestUtils.assert_winning_hand(rules_ref, "win", "13f24g2222p0000z24m")
    TestUtils.assert_winning_hand(rules_ref, "win", "13f24g0000z24m", "am_kong:2222p", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "1f2g0000z24m11j", "am_kong:2222p", @am_aliases)
    TestUtils.refute_winning_hand(rules_ref, "win", "1f2g0000z2m111j", "am_kong:2222p", @am_aliases)
  end

  test "american - nmjl 2024 - 2024 #3", %{nmjl_2024: rules_ref} do
    TestUtils.assert_winning_hand(rules_ref, "win", "13f224p0z2222m2222s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "13f224p0z", "am_kong:2222m am_kong:2222s", @am_aliases)
    TestUtils.refute_winning_hand(rules_ref, "win", "1f224p0z1j", "am_kong:2222m am_kong:2222s", @am_aliases)
    TestUtils.refute_winning_hand(rules_ref, "win", "13f224p1j", "am_kong:2222m am_kong:2222s", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "13f224p0z222m1j", "am_kong:2222s", @am_aliases)
  end

  test "american - nmjl 2024 - 2024 #4", %{nmjl_2024: rules_ref} do
    TestUtils.assert_winning_hand(rules_ref, "win", "11122333440z224p", "", @am_aliases)
    TestUtils.refute_winning_hand(rules_ref, "open_win", "22333446z224p", "am_pung:111z", @am_aliases)
  end

end
