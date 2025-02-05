defmodule RiichiAdvanced.KoOyaTsumoTest do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.Riichi, as: Riichi

  def test_ko_oya_3p(score, expected) do
    assert expected == Riichi.calc_ko_oya_points(score, false, 3, 100)
  end

  def test_ko_oya_4p(score, expected) do
    assert expected == Riichi.calc_ko_oya_points(score, false, 4, 100)
  end

  test "ko oya 4p" do
    test_ko_oya_4p(1300, {400, 700}) # 2/20, 1/40
    test_ko_oya_4p(2600, {700, 1300}) # 3/20, 2/40
    test_ko_oya_4p(5200, {1300, 2600}) # 4/20, 3/40

    test_ko_oya_4p(1600, {400, 800}) # 1/50
    test_ko_oya_4p(3200, {800, 1600}) # 3/25, 2/50
    test_ko_oya_4p(6400, {1600, 3200}) # 4/25, 3/50

    test_ko_oya_4p(1000, {300, 500}) # 1/30
    test_ko_oya_4p(2000, {500, 1000}) # 2/30, 1/60
    test_ko_oya_4p(3900, {1000, 2000}) # 3/30, 2/60
    test_ko_oya_4p(7700, {2000, 3900}) # 4/30, 3/60

    test_ko_oya_4p(8000, {2000, 4000}) # mangan
    test_ko_oya_4p(12000, {3000, 6000}) # haneman
    test_ko_oya_4p(16000, {4000, 8000}) # baiman
    test_ko_oya_4p(24000, {6000, 12000}) # sanbaiman
    test_ko_oya_4p(32000, {8000, 16000}) # yakuman
  end

  test "ko oya 3p with tsumo loss" do
    test_ko_oya_3p(1100, {400, 700}) # 2/20, 1/40
    test_ko_oya_3p(2000, {700, 1300}) # 3/20, 2/40
    test_ko_oya_3p(3900, {1300, 2600}) # 4/20, 3/40

    test_ko_oya_3p(1200, {400, 800}) # 1/50
    test_ko_oya_3p(2400, {800, 1600}) # 3/25, 2/50
    test_ko_oya_3p(4800, {1600, 3200}) # 4/25, 3/50

    test_ko_oya_3p(800, {300, 500}) # 1/30
    test_ko_oya_3p(1500, {500, 1000}) # 2/30, 1/60
    test_ko_oya_3p(3000, {1000, 2000}) # 3/30, 2/60
    test_ko_oya_3p(5900, {2000, 3900}) # 4/30, 3/60

    test_ko_oya_3p(6000, {2000, 4000}) # mangan
    test_ko_oya_3p(9000, {3000, 6000}) # haneman
    test_ko_oya_3p(12000, {4000, 8000}) # baiman
    test_ko_oya_3p(18000, {6000, 12000}) # sanbaiman
    test_ko_oya_3p(24000, {8000, 16000}) # yakuman
  end

  test "ko oya 3p no tsumo loss" do
    test_ko_oya_3p(1300, {500, 900}) # 2/20, 1/40
    test_ko_oya_3p(2600, {900, 1700}) # 3/20, 2/40
    test_ko_oya_3p(5200, {1800, 3500}) # 4/20, 3/40

    test_ko_oya_3p(1600, {600, 1100}) # 1/50
    test_ko_oya_3p(3200, {1100, 2100}) # 3/25, 2/50
    test_ko_oya_3p(6400, {2200, 4300}) # 4/25, 3/50

    test_ko_oya_3p(1000, {400, 700}) # 1/30
    test_ko_oya_3p(2000, {700, 1300}) # 2/30, 1/60
    test_ko_oya_3p(3900, {1300, 2600}) # 3/30, 2/60
    test_ko_oya_3p(7700, {2600, 5100}) # 4/30, 3/60

    test_ko_oya_3p(8000, {2700, 5300}) # mangan
    test_ko_oya_3p(12000, {4000, 8000}) # haneman
    test_ko_oya_3p(16000, {5400, 10700}) # baiman
    test_ko_oya_3p(24000, {8000, 16000}) # sanbaiman
    test_ko_oya_3p(32000, {10700, 21300}) # yakuman
  end

end
