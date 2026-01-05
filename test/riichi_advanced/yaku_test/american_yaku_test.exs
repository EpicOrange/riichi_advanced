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
      nmjl_2025: TestUtils.get_rules!("american", @nmjl_2025),
      card_free: TestUtils.get_rules!("american", @card_free),
    }
  end

  test "american - uniqueness check with too few tile kinds" do
    TestUtils.test_no_win("american", @card_free, hand: "222222p2222s7777z")
  end

  test "american - does card-free work?" do
    TestUtils.test_win("american", @card_free, hand: "22m2222p2222s7777z",
      win_button: "mahjong_discard", yaku: [{"Base Value", 25}, {"Concealed", 10}])
    TestUtils.test_win("american", @card_free, hand: "555p666m77p88s66z1j7p",
      win_button: "mahjong_draw", yaku: [{"Base Value", 25}, {"Concealed", 10}])
  end

  test "american - card-free - any like numbers", %{card_free: rules_ref} do
    TestUtils.assert_winning_hand(rules_ref, "any_like_numbers_true", "22m2222p2222s7777z", "", @am_aliases)
    TestUtils.refute_winning_hand(rules_ref, "any_like_numbers_false", "22m2222p2222s7777z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "blocks_1", "22m2222p2222s7777z", "", @am_aliases)
  end
  
  test "american - card-free - consecutive run 4", %{card_free: rules_ref} do
    TestUtils.assert_winning_hand(rules_ref, "consecutive_run_34_true", "555p666m77p88s66z1j7p", "", @am_aliases)
    TestUtils.refute_winning_hand(rules_ref, "consecutive_run_34_false", "555p666m77p88s66z1j7p", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "blocks_4", "555p666m77p88s66z1j7p", "", @am_aliases)
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

  test "american - nmjl 2024 - all hands", %{nmjl_2024: rules_ref} do
    # 222a 000 2222b 4444b
    TestUtils.assert_winning_hand(rules_ref, "win", "222p22224444s000z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "22224444m222p000z", "", @am_aliases)
    # FFFF 2222a 0000 24b
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f2222p24s0000z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f24m2222p0000z", "", @am_aliases)
    # FF 2024a 2222b 2222c
    TestUtils.assert_winning_hand(rules_ref, "win", "12f2222m224p2222s0z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f2222m224p2222s0z", "", @am_aliases)
    # FF 2024a 4444b 4444c
    TestUtils.assert_winning_hand(rules_ref, "win", "12f4444m224p4444s0z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f4444m224p4444s0z", "", @am_aliases)
    # NN EEE 2024a WWW SS
    TestUtils.assert_winning_hand(rules_ref, "win", "224p11122333440z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "224p11122333440z", "", @am_aliases)
    # 222a 444a 6666a 8888a
    TestUtils.assert_winning_hand(rules_ref, "win", "22244466668888p", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "22244466668888p", "", @am_aliases)
    # 222a 444a 6666b 8888b
    TestUtils.assert_winning_hand(rules_ref, "win", "222444p66668888s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "66668888m222444p", "", @am_aliases)
    # 22a 444a 44b 666b 8888c
    TestUtils.assert_winning_hand(rules_ref, "win", "8888m22444p44666s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "44666m22444p8888s", "", @am_aliases)
    # 22a 44a 666a 888a DDDDa
    TestUtils.assert_winning_hand(rules_ref, "win", "2244666888p0000z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "2244666888p0000z", "", @am_aliases)
    # FFFF 4444a 6666b 24c
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f24m4444p6666s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f6666m4444p24s", "", @am_aliases)
    # FFFF 6666a 8888b 48c
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f48m6666p8888s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f8888m6666p48s", "", @am_aliases)
    # FF 2222a 44a 66a 8888a
    TestUtils.assert_winning_hand(rules_ref, "win", "12f222244668888p", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f222244668888p", "", @am_aliases)
    # FF 2222a 44b 66b 8888a
    TestUtils.assert_winning_hand(rules_ref, "win", "12f22228888p4466s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f4466m22228888p", "", @am_aliases)
    # FF 222a 44a 666a 88b 88c
    TestUtils.assert_winning_hand(rules_ref, "win", "12f88m22244666p88s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f88m22244666p88s", "", @am_aliases)
    # FFFF XXX0a XXXX0b XXX0c
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f111m111p1111s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f1111m111p111s", "", @am_aliases)
    # XX0a DDDa XX0b DDDb XXXX0c
    TestUtils.assert_winning_hand(rules_ref, "win", "1111m11p11s000666z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "11m11p1111s000777z", "", @am_aliases)
    # FF XXXX0a NEWS XXXX0b
    TestUtils.assert_winning_hand(rules_ref, "win", "12f1111p1111s1234z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f1111m1111p1234z", "", @am_aliases)
    # FF 1111a 6666a 7777a
    TestUtils.assert_winning_hand(rules_ref, "win", "12f111166667777p", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f111166667777p", "", @am_aliases)
    # FF 2222a 5555a 7777a
    TestUtils.assert_winning_hand(rules_ref, "win", "12f222255557777p", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f222255557777p", "", @am_aliases)
    # FF 3333a 4444a 7777a
    TestUtils.assert_winning_hand(rules_ref, "win", "12f333344447777p", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f333344447777p", "", @am_aliases)
    # NNNN EEE WWW SSSS
    TestUtils.assert_winning_hand(rules_ref, "win", "11122223334444z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "11122223334444z", "", @am_aliases)
    # NNN EEEE WWWW SSS
    TestUtils.assert_winning_hand(rules_ref, "win", "11112223333444z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "11112223333444z", "", @am_aliases)
    # FFFF DDDa DDDDb DDDc
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f0006666777z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f0006667777z", "", @am_aliases)
    # NNN SSS XXXX0a XXXX1b
    TestUtils.assert_winning_hand(rules_ref, "win", "1111p2222s222444z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "2222m1111p222444z", "", @am_aliases)
    # EEE WWW XXXX0a XXXX1b
    TestUtils.assert_winning_hand(rules_ref, "win", "1111p2222s111333z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "2222m1111p111333z", "", @am_aliases)
    # FF NN EEE WWW SSSS
    TestUtils.assert_winning_hand(rules_ref, "win", "12f111222233344z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f111222233344z", "", @am_aliases)
    # NNNN XX0a XX1a XX2a SSSS
    TestUtils.assert_winning_hand(rules_ref, "win", "112233p22224444z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "112233p22224444z", "", @am_aliases)
    # EEEE XX0a XX1a XX2a WWWW
    TestUtils.assert_winning_hand(rules_ref, "win", "112233p11113333z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "112233p11113333z", "", @am_aliases)
    # FF DDDDa NEWS DDDDb
    TestUtils.assert_winning_hand(rules_ref, "win", "12f123400006666z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f123400007777z", "", @am_aliases)
    # NNN EW SSS XXX0a XXX0b
    TestUtils.assert_winning_hand(rules_ref, "win", "111p111s12223444z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "111m111p12223444z", "", @am_aliases)
    # 333a 666a 6666b 9999b
    TestUtils.assert_winning_hand(rules_ref, "win", "333666p66669999s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "66669999m333666p", "", @am_aliases)
    # 333a 666a 6666b 9999c
    TestUtils.assert_winning_hand(rules_ref, "win", "9999m333666p6666s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "6666m333666p9999s", "", @am_aliases)
    # FF 3a 66a 999a 333b 333c
    TestUtils.assert_winning_hand(rules_ref, "win", "12f333m366999p333s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f333m366999p333s", "", @am_aliases)
    # FF 3a 66a 999a 666b 666c
    TestUtils.assert_winning_hand(rules_ref, "win", "12f666m366999p666s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f666m366999p666s", "", @am_aliases)
    # FF 3a 66a 999a 999b 999c
    TestUtils.assert_winning_hand(rules_ref, "win", "12f999m366999p999s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f999m366999p999s", "", @am_aliases)
    # FF 3333a 6666a 9999a
    TestUtils.assert_winning_hand(rules_ref, "win", "12f333366669999p", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f333366669999p", "", @am_aliases)
    # FF 3333a 6666b 9999c
    TestUtils.assert_winning_hand(rules_ref, "win", "12f9999m3333p6666s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f6666m3333p9999s", "", @am_aliases)
    # 333a DDDDa 333b DDDDb
    TestUtils.assert_winning_hand(rules_ref, "win", "333p333s00006666z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "333m333p00007777z", "", @am_aliases)
    # 666a DDDDa 666b DDDDb
    TestUtils.assert_winning_hand(rules_ref, "win", "666p666s00006666z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "666m666p00007777z", "", @am_aliases)
    # 999a DDDDa 999b DDDDb
    TestUtils.assert_winning_hand(rules_ref, "win", "999p999s00006666z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "999m999p00007777z", "", @am_aliases)
    # 3333a 66a 66b 66c 9999a
    TestUtils.assert_winning_hand(rules_ref, "win", "66m3333669999p66s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "66m3333669999p66s", "", @am_aliases)
    # FFFF 33a 66a 999a DDDb
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f3366999p666z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f3366999p777z", "", @am_aliases)
    # 333a 666a 333b 666b 99c
    TestUtils.assert_winning_hand(rules_ref, "win", "99m333666p333666s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "333666m333666p99s", "", @am_aliases)
    # FF 22a 46a 88a 22b 46b 88b
    TestUtils.assert_winning_hand(rules_ref, "win", "12f224688p224688s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f224688m224688p", "", @am_aliases)
    # FF 11a 33a 55a 55b 77b 99b
    TestUtils.assert_winning_hand(rules_ref, "win", "12f113355p557799s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f557799m113355p", "", @am_aliases)
    # 112a 11223b 112233c
    TestUtils.assert_winning_hand(rules_ref, "win", "112233m112p11223s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "11223m112p112233s", "", @am_aliases)
    # 998a 99887b 998877c
    TestUtils.assert_winning_hand(rules_ref, "win", "778899m899p78899s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "78899m899p778899s", "", @am_aliases)
    # FF 33a 66a 99a 369b 369c
    TestUtils.assert_winning_hand(rules_ref, "win", "12f369m336699p369s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f369m336699p369s", "", @am_aliases)
    # XX0a XX1a XX2a XX3a XX4a DDb DDc
    TestUtils.assert_winning_hand(rules_ref, "win", "1122334455p6677z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "1122334455p6677z", "", @am_aliases)
    # 2024a NN EW SS 2024b
    TestUtils.assert_winning_hand(rules_ref, "win", "224p224s12234400z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "224m224p12234400z", "", @am_aliases)
    # FF XXXXX0a XX1a XXXXX2a
    TestUtils.assert_winning_hand(rules_ref, "win", "12f111112233333p", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f111112233333p", "", @am_aliases)
    # XXXXX0a ZZZZ XXXXX1b|XXXXX2b|XXXXX3b|XXXXX4b|XXXXX5b|XXXXX6b|XXXXX7b|XXXXX8b
    TestUtils.assert_winning_hand(rules_ref, "win", "11111p22222s1111z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "22222m11111p1111z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "11111p33333s1111z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "33333m11111p1111z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "11111p44444s1111z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "44444m11111p1111z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "11111p55555s1111z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "55555m11111p1111z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "11111p66666s1111z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "66666m11111p1111z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "11111p77777s1111z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "77777m11111p1111z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "11111p88888s1111z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "88888m11111p1111z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "11111p99999s1111z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "99999m11111p1111z", "", @am_aliases)
    # XX0a XXXXX1a XX0b XXXXX1b
    TestUtils.assert_winning_hand(rules_ref, "win", "1122222p1122222s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "1122222m1122222p", "", @am_aliases)
    # FFFFF DDDDa XXXXX0b
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f1g11111s0000z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f1g11111m0000z", "", @am_aliases)
    # 111a 22a 3333a 44a 555a
    TestUtils.assert_winning_hand(rules_ref, "win", "11122333344555p", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "11122333344555p", "", @am_aliases)
    # 555a 66a 7777a 88a 999a
    TestUtils.assert_winning_hand(rules_ref, "win", "55566777788999p", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "55566777788999p", "", @am_aliases)
    # XX0a XXX1a DDDDb XXX2a XX3a
    TestUtils.assert_winning_hand(rules_ref, "win", "1122233344p6666z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "1122233344p7777z", "", @am_aliases)
    # FF XXXX0a XXXX1a XXXX2a
    TestUtils.assert_winning_hand(rules_ref, "win", "12f111122223333p", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f111122223333p", "", @am_aliases)
    # FF XXXX0a XXXX1b XXXX2c
    TestUtils.assert_winning_hand(rules_ref, "win", "12f3333m1111p2222s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f2222m1111p3333s", "", @am_aliases)
    # X0a XX1a XXXX2a X0b XX1b XXXX2b
    TestUtils.assert_winning_hand(rules_ref, "win", "1223333p1223333s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "1223333m1223333p", "", @am_aliases)
    # XX0a XX1a XXX2a XXX3a DDDDa
    TestUtils.assert_winning_hand(rules_ref, "win", "1122333444p0000z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "1122333444p0000z", "", @am_aliases)
    # FFFFF X0a X1a X2a XXX3b XXX3c
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f1g444m123p444s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f1g444m123p444s", "", @am_aliases)
    # XXX0a XXX1a XXXX2a XXXX3a
    TestUtils.assert_winning_hand(rules_ref, "win", "11122233334444p", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "11122233334444p", "", @am_aliases)
    # XXX0a XXX1a XXXX2b XXXX3b
    TestUtils.assert_winning_hand(rules_ref, "win", "111222p33334444s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "33334444m111222p", "", @am_aliases)
    # XXX0a XXX1a XXX0b XXX1b XX2c
    TestUtils.assert_winning_hand(rules_ref, "win", "33m111222p111222s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "111222m111222p33s", "", @am_aliases)
    # 111a 33a 5555a 77a 999a
    TestUtils.assert_winning_hand(rules_ref, "win", "11133555577999p", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "11133555577999p", "", @am_aliases)
    # 111a 33a 5555b 77c 999c
    TestUtils.assert_winning_hand(rules_ref, "win", "77999m11133p5555s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "5555m11133p77999s", "", @am_aliases)
    # 111a 333a 3333b 5555b
    TestUtils.assert_winning_hand(rules_ref, "win", "111333p33335555s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "33335555m111333p", "", @am_aliases)
    # 555a 777a 7777b 9999b
    TestUtils.assert_winning_hand(rules_ref, "win", "555777p77779999s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "77779999m555777p", "", @am_aliases)
    # FF 11a 333a 5555a DDDa
    TestUtils.assert_winning_hand(rules_ref, "win", "12f113335555p000z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f113335555p000z", "", @am_aliases)
    # FF 55a 777a 9999a DDDa
    TestUtils.assert_winning_hand(rules_ref, "win", "12f557779999p000z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f557779999p000z", "", @am_aliases)
    # 11a 33a 55a 7777b 9999c
    TestUtils.assert_winning_hand(rules_ref, "win", "9999m113355p7777s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "7777m113355p9999s", "", @am_aliases)
    # FFFF 3333a 5555b 15c
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f15m3333p5555s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f5555m3333p15s", "", @am_aliases)
    # FFFF 5555a 7777b 35c
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f35m5555p7777s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f7777m5555p35s", "", @am_aliases)
    # 11a 33a 333b 555b DDDDc
    TestUtils.assert_winning_hand(rules_ref, "win", "1133p333555s7777z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "333555m1133p6666z", "", @am_aliases)
    # 55a 77a 777b 999b DDDDc
    TestUtils.assert_winning_hand(rules_ref, "win", "5577p777999s7777z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "777999m5577p6666z", "", @am_aliases)
    # 111a 33a 555a 333b 333c
    TestUtils.assert_winning_hand(rules_ref, "win", "333m11133555p333s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "333m11133555p333s", "", @am_aliases)
    # 555a 77a 999a 777b 777c
    TestUtils.assert_winning_hand(rules_ref, "win", "777m55577999p777s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "777m55577999p777s", "", @am_aliases)
  end

  test "american - nmjl 2025 - all hands", %{nmjl_2025: rules_ref} do
    # FFFF 2025a 222b 222c
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f222m225p222s0z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f222m225p222s0z", "", @am_aliases)
    # FFFF 2025a 555b 555c
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f555m225p555s0z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f555m225p555s0z", "", @am_aliases)
    # 222a 0000 222c 5555c
    TestUtils.assert_winning_hand(rules_ref, "win", "2225555m222p0000z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "222p2225555s0000z", "", @am_aliases)
    # 2025a 222b 555b DDDDc
    TestUtils.assert_winning_hand(rules_ref, "win", "225p222555s07777z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "222555m225p06666z", "", @am_aliases)
    # FF 222a 000 222b 555c
    TestUtils.assert_winning_hand(rules_ref, "win", "12f555m222p222s000z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f222m222p555s000z", "", @am_aliases)
    # 222a 4444a 666a 8888a
    TestUtils.assert_winning_hand(rules_ref, "win", "22244446668888p", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "22244446668888p", "", @am_aliases)
    # 222a 4444a 666b 8888b
    TestUtils.assert_winning_hand(rules_ref, "win", "2224444p6668888s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "6668888m2224444p", "", @am_aliases)
    # FF 2222a 4444b 6666c
    TestUtils.assert_winning_hand(rules_ref, "win", "12f6666m2222p4444s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f4444m2222p6666s", "", @am_aliases)
    # FF 2222a 6666b 8888c
    TestUtils.assert_winning_hand(rules_ref, "win", "12f8888m2222p6666s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f6666m2222p8888s", "", @am_aliases)
    # 22a 444a 66a 888a DDDDa
    TestUtils.assert_winning_hand(rules_ref, "win", "2244466888p0000z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "2244466888p0000z", "", @am_aliases)
    # FFFF 2468a 222b 222c
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f222m2468p222s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f222m2468p222s", "", @am_aliases)
    # FFFF 2468a 444b 444c
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f444m2468p444s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f444m2468p444s", "", @am_aliases)
    # FFFF 2468a 666b 666c
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f666m2468p666s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f666m2468p666s", "", @am_aliases)
    # FFFF 2468a 888b 888c
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f888m2468p888s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f888m2468p888s", "", @am_aliases)
    # FFF 22a 44a 666a 8888a
    TestUtils.assert_winning_hand(rules_ref, "win", "123f22446668888p", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "123f22446668888p", "", @am_aliases)
    # 222a 4444a 666a 88b 88c
    TestUtils.assert_winning_hand(rules_ref, "win", "88m2224444666p88s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "88m2224444666p88s", "", @am_aliases)
    # FF 2222a DDDDb 2222c
    TestUtils.assert_winning_hand(rules_ref, "win", "12f2222m2222p6666z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f2222p2222s7777z", "", @am_aliases)
    # FF 4444a DDDDb 4444c
    TestUtils.assert_winning_hand(rules_ref, "win", "12f4444m4444p6666z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f4444p4444s7777z", "", @am_aliases)
    # FF 6666a DDDDb 6666c
    TestUtils.assert_winning_hand(rules_ref, "win", "12f6666m6666p6666z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f6666p6666s7777z", "", @am_aliases)
    # FF 8888a DDDDb 8888c
    TestUtils.assert_winning_hand(rules_ref, "win", "12f8888m8888p6666z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f8888p8888s7777z", "", @am_aliases)
    # 22a 44a 66a 88a 222b 222c
    TestUtils.assert_winning_hand(rules_ref, "win", "222m22446688p222s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "222m22446688p222s", "", @am_aliases)
    # 22a 44a 66a 88a 444b 444c
    TestUtils.assert_winning_hand(rules_ref, "win", "444m22446688p444s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "444m22446688p444s", "", @am_aliases)
    # 22a 44a 66a 88a 666b 666c
    TestUtils.assert_winning_hand(rules_ref, "win", "666m22446688p666s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "666m22446688p666s", "", @am_aliases)
    # 22a 44a 66a 88a 888b 888c
    TestUtils.assert_winning_hand(rules_ref, "win", "888m22446688p888s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "888m22446688p888s", "", @am_aliases)
    # FF XXXX0a Da XXXX0b Db XX0c
    TestUtils.assert_winning_hand(rules_ref, "win", "12f11m1111p1111s06z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f1111m1111p11s07z", "", @am_aliases)
    # FFFF XX0a XXX0b XXX0c XX0a
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f111m1111p111s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f111m1111p111s", "", @am_aliases)
    # FF XXX0a XXX0b XXX0c DDDa
    TestUtils.assert_winning_hand(rules_ref, "win", "12f111m111p111s000z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f111m111p111s000z", "", @am_aliases)
    # FF XXX0a XXXX1b XXXXX2c
    TestUtils.assert_winning_hand(rules_ref, "win", "12f33333m111p2222s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f2222m111p33333s", "", @am_aliases)
    # XXXXX0a ZZZZ XXXXX1a
    TestUtils.assert_winning_hand(rules_ref, "win", "1111122222p1111z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "1111122222p1111z", "", @am_aliases)
    # FF XXXXX0a XX0b XXXXX0c
    TestUtils.assert_winning_hand(rules_ref, "win", "12f11111m11111p11s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f11m11111p11111s", "", @am_aliases)
    # 11a 222a 3333a 444a 55a
    TestUtils.assert_winning_hand(rules_ref, "win", "11222333344455p", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "11222333344455p", "", @am_aliases)
    # 55a 666a 7777a 888a 99a
    TestUtils.assert_winning_hand(rules_ref, "win", "55666777788899p", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "55666777788899p", "", @am_aliases)
    # XXX0a XXXX1a XXX2a XXXX3a
    TestUtils.assert_winning_hand(rules_ref, "win", "11122223334444p", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "11122223334444p", "", @am_aliases)
    # XXX0a XXXX1a XXX2b XXXX3b
    TestUtils.assert_winning_hand(rules_ref, "win", "1112222p3334444s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "3334444m1112222p", "", @am_aliases)
    # FFFF XXXX0a XX1a XXXX2a
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f1111223333p", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f1111223333p", "", @am_aliases)
    # FFFF XXXX0a XX1b XXXX2c
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f3333m1111p22s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f22m1111p3333s", "", @am_aliases)
    # FFF X0a X1a X2a XXXX3b XXXX4c
    TestUtils.assert_winning_hand(rules_ref, "win", "123f5555m123p4444s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "123f4444m123p5555s", "", @am_aliases)
    # FF XX0a XXX1a XXXX2a DDDa
    TestUtils.assert_winning_hand(rules_ref, "win", "12f112223333p000z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f112223333p000z", "", @am_aliases)
    # XXX0a XXX1a XXXX2a DDb DDc
    TestUtils.assert_winning_hand(rules_ref, "win", "1112223333p6677z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "1112223333p6677z", "", @am_aliases)
    # XX0a X1a X2a X3a X4a XXXX0b XXXX0c
    TestUtils.assert_winning_hand(rules_ref, "win", "1111m112345p1111s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "1111m112345p1111s", "", @am_aliases)
    # X0a XX1a X2a X3a X4a XXXX1b XXXX1c
    TestUtils.assert_winning_hand(rules_ref, "win", "2222m122345p2222s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "2222m122345p2222s", "", @am_aliases)
    # X0a X1a XX2a X3a X4a XXXX2b XXXX2c
    TestUtils.assert_winning_hand(rules_ref, "win", "3333m123345p3333s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "3333m123345p3333s", "", @am_aliases)
    # X0a X1a X2a XX3a X4a XXXX3b XXXX3c
    TestUtils.assert_winning_hand(rules_ref, "win", "4444m123445p4444s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "4444m123445p4444s", "", @am_aliases)
    # X0a X1a X2a X3a XX4a XXXX4b XXXX4c
    TestUtils.assert_winning_hand(rules_ref, "win", "5555m123455p5555s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "5555m123455p5555s", "", @am_aliases)
    # FF X0a XX1a XXX2a X0b XX1b XXX2b
    TestUtils.assert_winning_hand(rules_ref, "win", "12f122333p122333s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f122333m122333p", "", @am_aliases)
    # 11a 333a 5555a 777a 99a
    TestUtils.assert_winning_hand(rules_ref, "win", "11333555577799p", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "11333555577799p", "", @am_aliases)
    # 11a 333a 5555b 777c 99c
    TestUtils.assert_winning_hand(rules_ref, "win", "77799m11333p5555s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "5555m11333p77799s", "", @am_aliases)
    # 111a 3333a 333b 5555b
    TestUtils.assert_winning_hand(rules_ref, "win", "1113333p3335555s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "3335555m1113333p", "", @am_aliases)
    # 555a 7777a 777b 9999b
    TestUtils.assert_winning_hand(rules_ref, "win", "5557777p7779999s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "7779999m5557777p", "", @am_aliases)
    # 1111a 333a 5555a DDDa
    TestUtils.assert_winning_hand(rules_ref, "win", "11113335555p000z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "11113335555p000z", "", @am_aliases)
    # 5555a 777a 9999a DDDa
    TestUtils.assert_winning_hand(rules_ref, "win", "55557779999p000z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "55557779999p000z", "", @am_aliases)
    # FFFF 1111a 9999a 10b
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f11119999p1s0z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f1m11119999p0z", "", @am_aliases)
    # FFF 135a 7777a 9999a
    TestUtils.assert_winning_hand(rules_ref, "win", "123f13577779999p", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "123f13577779999p", "", @am_aliases)
    # FFF 135a 7777b 9999b
    TestUtils.assert_winning_hand(rules_ref, "win", "123f135p77779999s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "123f77779999m135p", "", @am_aliases)
    # 111a 333a 5555a DDb DDc
    TestUtils.assert_winning_hand(rules_ref, "win", "1113335555p6677z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "1113335555p6677z", "", @am_aliases)
    # 555a 777a 9999a DDb DDc
    TestUtils.assert_winning_hand(rules_ref, "win", "5557779999p6677z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "5557779999p6677z", "", @am_aliases)
    # 11a 333a NEWS 333b 55b
    TestUtils.assert_winning_hand(rules_ref, "win", "11333p33355s1234z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "33355m11333p1234z", "", @am_aliases)
    # 55a 777a NEWS 777b 99b
    TestUtils.assert_winning_hand(rules_ref, "win", "55777p77799s1234z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "77799m55777p1234z", "", @am_aliases)
    # 1111a 33b 55b 77b 9999a
    TestUtils.assert_winning_hand(rules_ref, "win", "11119999p335577s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "335577m11119999p", "", @am_aliases)
    # FF 11a 33a 111b 333b 55c
    TestUtils.assert_winning_hand(rules_ref, "win", "12f55m1133p111333s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f111333m1133p55s", "", @am_aliases)
    # FF 55a 77a 555b 777b 99c
    TestUtils.assert_winning_hand(rules_ref, "win", "12f99m5577p555777s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f555777m5577p99s", "", @am_aliases)
    # NNNN EEE WWW SSSS
    TestUtils.assert_winning_hand(rules_ref, "win", "11122223334444z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "11122223334444z", "", @am_aliases)
    # NNN EEEE WWWW SSS
    TestUtils.assert_winning_hand(rules_ref, "win", "11112223333444z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "11112223333444z", "", @am_aliases)
    # FF X0a X1a X2a DDb DDDc DDDDa
    TestUtils.assert_winning_hand(rules_ref, "win", "12f123p000066777z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f234p000066677z", "", @am_aliases)
    # FF X0a X1a X2a DDa DDDb DDDDc
    TestUtils.assert_winning_hand(rules_ref, "win", "12f123p006666777z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f234p006667777z", "", @am_aliases)
    # FF X0a X1a X2a DDc DDDa DDDDb
    TestUtils.assert_winning_hand(rules_ref, "win", "12f123p000667777z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f234p000666677z", "", @am_aliases)
    # FFF NN EE WWW SSSS
    TestUtils.assert_winning_hand(rules_ref, "win", "123f11222233344z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "123f11222233344z", "", @am_aliases)
    # FFFF DDDa NEWS DDDb
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f1234000666z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "1234f1234000777z", "", @am_aliases)
    # NNNN 1a 11b 111c SSSS
    TestUtils.assert_winning_hand(rules_ref, "win", "111m1p11s22224444z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "11m1p111s22224444z", "", @am_aliases)
    # NNNN 3a 33b 333c SSSS
    TestUtils.assert_winning_hand(rules_ref, "win", "333m3p33s22224444z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "33m3p333s22224444z", "", @am_aliases)
    # NNNN 5a 55b 555c SSSS
    TestUtils.assert_winning_hand(rules_ref, "win", "555m5p55s22224444z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "55m5p555s22224444z", "", @am_aliases)
    # NNNN 7a 77b 777c SSSS
    TestUtils.assert_winning_hand(rules_ref, "win", "777m7p77s22224444z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "77m7p777s22224444z", "", @am_aliases)
    # NNNN 9a 99b 999c SSSS
    TestUtils.assert_winning_hand(rules_ref, "win", "999m9p99s22224444z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "99m9p999s22224444z", "", @am_aliases)
    # EEEE 2a 22b 222c WWWW
    TestUtils.assert_winning_hand(rules_ref, "win", "222m2p22s11113333z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "22m2p222s11113333z", "", @am_aliases)
    # EEEE 4a 44b 444c WWWW
    TestUtils.assert_winning_hand(rules_ref, "win", "444m4p44s11113333z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "44m4p444s11113333z", "", @am_aliases)
    # EEEE 6a 66b 666c WWWW
    TestUtils.assert_winning_hand(rules_ref, "win", "666m6p66s11113333z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "66m6p666s11113333z", "", @am_aliases)
    # EEEE 8a 88b 888c WWWW
    TestUtils.assert_winning_hand(rules_ref, "win", "888m8p88s11113333z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "88m8p888s11113333z", "", @am_aliases)
    # NN EEE WWW SS 2025a
    TestUtils.assert_winning_hand(rules_ref, "win", "225p11122333440z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "225p11122333440z", "", @am_aliases)
    # NNN EE WW SSS 2025a
    TestUtils.assert_winning_hand(rules_ref, "win", "225p11222334440z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "225p11222334440z", "", @am_aliases)
    # NN EE WWW SSS DDDDa
    TestUtils.assert_winning_hand(rules_ref, "win", "11222333440000z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "11222333440000z", "", @am_aliases)
    # 333a 6666a 666b 9999b
    TestUtils.assert_winning_hand(rules_ref, "win", "3336666p6669999s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "6669999m3336666p", "", @am_aliases)
    # 333a 6666a 666b 9999c
    TestUtils.assert_winning_hand(rules_ref, "win", "9999m3336666p666s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "666m3336666p9999s", "", @am_aliases)
    # FF 3333a 6666a 9999a
    TestUtils.assert_winning_hand(rules_ref, "win", "12f333366669999p", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f333366669999p", "", @am_aliases)
    # FF 3333a 6666b 9999c
    TestUtils.assert_winning_hand(rules_ref, "win", "12f9999m3333p6666s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f6666m3333p9999s", "", @am_aliases)
    # 3333a DDDa 3333b DDDb
    TestUtils.assert_winning_hand(rules_ref, "win", "3333p3333s000666z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "3333m3333p000777z", "", @am_aliases)
    # 6666a DDDa 6666b DDDb
    TestUtils.assert_winning_hand(rules_ref, "win", "6666p6666s000666z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "6666m6666p000777z", "", @am_aliases)
    # 9999a DDDa 9999b DDDb
    TestUtils.assert_winning_hand(rules_ref, "win", "9999p9999s000666z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "9999m9999p000777z", "", @am_aliases)
    # FFF 3333a 369b 9999a
    TestUtils.assert_winning_hand(rules_ref, "win", "123f33339999p369s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "123f369m33339999p", "", @am_aliases)
    # 33a 66a 99a 3333b 3333c
    TestUtils.assert_winning_hand(rules_ref, "win", "3333m336699p3333s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "3333m336699p3333s", "", @am_aliases)
    # 33a 66a 99a 6666b 6666c
    TestUtils.assert_winning_hand(rules_ref, "win", "6666m336699p6666s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "6666m336699p6666s", "", @am_aliases)
    # 33a 66a 99a 9999b 9999c
    TestUtils.assert_winning_hand(rules_ref, "win", "9999m336699p9999s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "9999m336699p9999s", "", @am_aliases)
    # FF 333a Da 666b Db 999c Dc
    TestUtils.assert_winning_hand(rules_ref, "win", "12f999m333p666s067z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f666m333p999s067z", "", @am_aliases)
    # NN EW SS XX0a XX1a XX2a XX3a
    TestUtils.assert_winning_hand(rules_ref, "win", "11223344p122344z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "11223344p122344z", "", @am_aliases)
    # FF 2468a DDa 2468b DDb
    TestUtils.assert_winning_hand(rules_ref, "win", "12f2468p2468s0066z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f2468m2468p0077z", "", @am_aliases)
    # 336699a 336699b 33c
    TestUtils.assert_winning_hand(rules_ref, "win", "336699m336699p33s", "", @am_aliases)
    # 336699a 336699b 66c
    TestUtils.assert_winning_hand(rules_ref, "win", "66m336699p336699s", "", @am_aliases)
    # 336699a 336699b 99c
    TestUtils.assert_winning_hand(rules_ref, "win", "336699m99p336699s", "", @am_aliases)
    # FF XX0a XX1a XX0b XX1b XX0c XX1c
    TestUtils.assert_winning_hand(rules_ref, "win", "12f1122m1122p1122s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f1122m1122p1122s", "", @am_aliases)
    # 11a 33a 55a 77a 99a 11b 11c
    TestUtils.assert_winning_hand(rules_ref, "win", "11m1133557799p11s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "11m1133557799p11s", "", @am_aliases)
    # 11a 33a 55a 77a 99a 33b 33c
    TestUtils.assert_winning_hand(rules_ref, "win", "33m1133557799p33s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "33m1133557799p33s", "", @am_aliases)
    # 11a 33a 55a 77a 99a 55b 55c
    TestUtils.assert_winning_hand(rules_ref, "win", "55m1133557799p55s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "55m1133557799p55s", "", @am_aliases)
    # 11a 33a 55a 77a 99a 77b 77c
    TestUtils.assert_winning_hand(rules_ref, "win", "77m1133557799p77s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "77m1133557799p77s", "", @am_aliases)
    # 11a 33a 55a 77a 99a 99b 99c
    TestUtils.assert_winning_hand(rules_ref, "win", "99m1133557799p99s", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "99m1133557799p99s", "", @am_aliases)
    # FF 2025a 2025b 2025c
    TestUtils.assert_winning_hand(rules_ref, "win", "12f225m225p225s000z", "", @am_aliases)
    TestUtils.assert_winning_hand(rules_ref, "win", "12f225m225p225s000z", "", @am_aliases)
  end
end
