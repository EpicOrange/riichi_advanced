defmodule RiichiAdvanced.YakuTest.RiichiLocalYaku do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "riichi - shiiaru raotai" do
    TestUtils.test_yaku_advanced("riichi", ["lib/yaku/shiiaru_raotai"], [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "7z", "3p", "3p", "7z", "2s", "2s", "7z", "4p", "4p", "7z", "5m"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["2m", "4m", "8m", "5p", "8p", "9p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2p", "3p", "4p", "3m", "3p", "2s", "4p", "5m"]
    }
    """, [
      %{"type" => "discard", "tile" => "2p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3m", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "7z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "3p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "7z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "2s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "7z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "4p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "7z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]},
    ], %{
      east: %{
        yaku: [{"Shiiaru Raotai", [1, "Han"]}],
        minipoints: 30,
        score: 1500
      }
    })
  end

  test "riichi - ketsupaihou" do
    TestUtils.test_yaku_advanced("riichi", ["lib/yaku/ketsupaihou"], [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "7p", "7p", "7p", "2s", "2s", "2s", "4p", "6z", "5m", "5m"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["2m", "4m", "8m", "5p", "8p", "9p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2p", "3p", "4p", "3p", "2p", "3p"]
    }
    """, [
      %{"type" => "discard", "tile" => "2p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "3p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Sanankou", [2, "Han"]}, {"Tanyao", [1, "Han"]}, {"Ketsupaihou", [1, "Han"]}],
        minipoints: 50,
        score: 12000
      }
    })
  end

  test "riichi - sanshoku ittsuu" do
    TestUtils.test_yaku_advanced("riichi", [%{name: "lib/yaku/sanshoku_ittsuu", config: %{value: 1, closed_bonus: 1}}], [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "4s", "5s", "7p", "8p", "9p", "6z", "6z", "6z", "5m", "5m"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["2m", "4m", "8m", "5p", "8p", "9p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2p", "6s"]
    }
    """, [
      %{"type" => "discard", "tile" => "2p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Sanshoku Ittsuu", [2, "Han"]}, {"Hatsu", [1, "Han"]}],
        minipoints: 40,
        score: 7700
      }
    })
  end

  test "riichi - shiisanpuutaa" do
    TestUtils.test_yaku_advanced("riichi", [%{name: "lib/yaku/shiisanpuutaa", config: %{list: "yakuman", value: 1, han: "★"}}], [], """
    {
      "starting_hand": {
        "east": ["2m", "5m", "3p", "6p", "9p", "9p", "2s", "5s", "1z", "2z", "4z", "5z", "6z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["2m", "4m", "8m", "5p", "8p", "9p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["7z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "shiisanpuutaa"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Shiisanpuutaa", [1, "★"]}],
        minipoints: 30,
        score: 48000
      }
    })
  end

  test "riichi - isshoku sanjun" do
    TestUtils.test_yaku_advanced("riichi", [%{name: "lib/yaku/isshoku_sanjun", config: %{san_value: 2, san_closed_bonus: 1, yon_list: "yakuman", yon_value: 1, yon_han: "★"}}], [], """
    {
      "starting_hand": {
        "east": ["2m", "2m", "3m", "3m", "3m", "4m", "4m", "4m", "2p", "3p", "4p", "5z", "6z"],
        "south": ["1m", "6m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["2m", "6m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["5m", "6m", "8m", "5p", "8p", "9p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "4z", "2z", "2m", "5z"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2m", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5z", "player" => 1, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]},
    ], %{
      east: %{
        yaku: [{"Isshoku Sanjun", [2, "Han"]}],
        minipoints: 30,
        score: 2900
      }
    })
  end

  test "riichi - chinchii toushii" do
    TestUtils.test_yaku_advanced("riichi", ["lib/yaku/ketsupaihou", "yaku/chinchii_toushii"], [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "7p", "7p", "7p", "2s", "2s", "2s", "4p", "6z", "5m", "5m"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["3p", "3p", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "3p", "2p", "4z", "2z", "3p"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "pon"}]},
      %{"type" => "discard", "tile" => "7m", "player" => 3, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "4z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "kakan"}]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chankan"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Sanankou", [2, "Han"]}, {"Tanyao", [1, "Han"]}, {"Chinchii Toushii", [4, "Han"]}],
        minipoints: 50,
        score: 18000
      }
    })
  end

  test "riichi - rentsuu honitsu" do
    TestUtils.test_yaku_advanced("riichi", ["yaku/rentsuu_honitsu"], [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "4m", "5m", "6m", "7m", "7m", "8m", "8m", "8m", "7z", "7z"],
        "south": ["1m", "4m", "6m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "6m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["3p", "3p", "6m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "7z"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Rentsuu Honitsu", [5, "Han"]}],
        minipoints: 50,
        score: 12000
      }
    })
  end

  test "riichi - dorahairi chinroutou chiitoitsu" do
    TestUtils.test_yaku_advanced("riichi", [%{name: "dora", config: %{"start_indicators" => 1}}, "yaku/dorahairi_chinroutou_chiitoitsu"], [], """
    {
      "starting_hand": {
        "east": ["1m", "1m", "9m", "9m", "1p", "1p", "7m", "7m", "9p", "9p", "1s", "1s", "9s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["3p", "3p", "8m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "9s"],
      "starting_dead_wall": ["2m", "1m", "4m", "3m", "6m", "5m"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "9s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Dorahairi Chinroutou Chiitoitsu", [5, "Han"]}],
        minipoints: 25,
        score: 12000
      }
    })
  end

end
