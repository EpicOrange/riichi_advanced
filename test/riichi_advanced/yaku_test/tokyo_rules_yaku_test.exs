defmodule RiichiAdvanced.YakuTest.TokyoRulesYaku do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "tokyo - shiiaru raotai" do
    TestUtils.test_yaku_advanced("tokyo_rules", [], [], """
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
        minipoints: 28,
        score: 340
      }
    })
  end

  test "tokyo - ketsupaihou" do
    TestUtils.test_yaku_advanced("tokyo_rules", [], [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "7p", "7p", "7p", "2s", "2s", "2s", "4p", "6z", "5m", "5m"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["2m", "4m", "8m", "5p", "8p", "9p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2p", "3p", "3p", "3p", "2p", "3p"]
    }
    """, [
      %{"type" => "discard", "tile" => "2p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "3p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Sanankou", [2, "Han"]}, {"Tanyao", [1, "Han"]}, {"Ketsupaihou", [1, "Han"]}],
        minipoints: 44,
        score: 4220
      }
    })
  end

  test "tokyo - sanshoku ittsuu" do
    TestUtils.test_yaku_advanced("tokyo_rules", [], [], """
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
        minipoints: 38,
        score: 1820
      }
    })
  end

  test "tokyo - shiisanpuutaa" do
    TestUtils.test_yaku_advanced("tokyo_rules", [], [], """
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
        yaku: [{"Shiisanpuutaa", [3, "Han"]}],
        minipoints: 30,
        score: 1440
      }
    })
  end

  test "tokyo - isshoku sanjun open" do
    TestUtils.test_yaku_advanced("tokyo_rules", [], [], """
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
        yaku: [{"Isshoku Sanjun", [3, "Han"]}],
        minipoints: 24,
        score: 1150
      }
    })
  end

  test "tokyo - isshoku sanjun closed pinfu tsumo not sanrenkou" do
    TestUtils.test_yaku_advanced("tokyo_rules", [], [], """
    {
      "starting_hand": {
        "east": ["2m", "2m", "2m", "3m", "3m", "3m", "4m", "4m", "4m", "2p", "3p", "5p", "5p"],
        "south": ["1m", "6m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["2m", "6m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["5m", "6m", "8m", "5p", "8p", "9p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "6z", "6z", "6z", "1p"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6z", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]},
    ], %{
      east: %{
        yaku: [{"Isshoku Sanjun", [4, "Han"]}, {"Pinfu", [1, "Han"]}, {"Tsumo", [1, "Han"]}],
        minipoints: 22,
        score: 6000
      }
    })
  end

  test "tokyo - sanrenkou open" do
    TestUtils.test_yaku_advanced("tokyo_rules", [], [], """
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
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5z", "player" => 1, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]},
    ], %{
      east: %{
        yaku: [{"Sanrenkou", [3, "Han"]}],
        minipoints: 34,
        score: 1630
      }
    })
  end

  test "tokyo - renkaihou" do
    TestUtils.test_yaku_advanced("tokyo_rules", [], [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "4m", "4m", "4m", "1p", "2p", "2p", "4p", "4p", "2z", "5z"],
        "south": ["1m", "6m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["2m", "6m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["5m", "6m", "8m", "5p", "8p", "9p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "4p", "2s", "2s", "2s", "3p", "4m"],
      "starting_dead_wall": ["4p", "5z"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "2z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "2s", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2s", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2p", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "4m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "daiminkan"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "kakan"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]},
    ], %{
      east: %{
        yaku: [{"Renkaihou", [3, "Han"]}],
        minipoints: 42,
        score: 2010
      }
    })
  end

  test "tokyo - choupaikou" do
    TestUtils.test_yaku_advanced("tokyo_rules", [], [], """
    {
      "starting_hand": {
        "east": ["2m", "2m", "2m", "4m", "4m", "4m", "6m", "6m", "9m", "1p", "3p", "2z", "2z"],
        "south": ["1m", "6m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["2m", "6m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["5m", "6m", "8m", "5p", "8p", "9p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "6m", "2p"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "9m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "2p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]},
    ], %{
      east: %{
        yaku: [{"Choupaikou", [3, "Han"]}],
        minipoints: 32,
        score: 1540
      }
    })
  end

  test "tokyo - sujipaikou" do
    TestUtils.test_yaku_advanced("tokyo_rules", [], [], """
    {
      "starting_hand": {
        "east": ["1m", "1m", "1m", "4m", "4m", "4m", "7m", "7m", "9m", "1p", "3p", "2z", "2z"],
        "south": ["1m", "6m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["2m", "6m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["5m", "6m", "8m", "5p", "8p", "9p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "7m", "2p"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "9m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "2p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]},
    ], %{
      east: %{
        yaku: [{"Sujipaikou", [3, "Han"]}],
        minipoints: 36,
        score: 1730
      }
    })
  end

  test "tokyo - chousankou" do
    TestUtils.test_yaku_advanced("tokyo_rules", [], [], """
    {
      "starting_hand": {
        "east": ["1m", "1m", "1m", "5m", "5m", "5m", "7m", "9m", "9m", "1p", "3p", "2z", "2z"],
        "south": ["1m", "6m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["2m", "6m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["5m", "6m", "8m", "5p", "8p", "9p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "9m", "2p"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "9m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "7m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "2p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]},
    ], %{
      east: %{
        yaku: [{"Chousankou", [3, "Han"]}],
        minipoints: 38,
        score: 1820
      }
    })
  end

  test "tokyo - no sanshoku choupaikou" do
    TestUtils.test_yaku_advanced("tokyo_rules", [], [], """
    {
      "starting_hand": {
        "east": ["2m", "2m", "2m", "4p", "4p", "4p", "6s", "6s", "9s", "2p", "2p", "2z", "2z"],
        "south": ["1m", "6m", "7m", "2p", "5p", "8p", "3s", "5s", "8s", "1z", "2z", "3z", "4z"],
        "west": ["2m", "6m", "7m", "2p", "5p", "8p", "3s", "5s", "8s", "1z", "2z", "3z", "4z"],
        "north": ["5m", "6m", "8m", "5p", "8p", "9p", "3s", "5s", "8s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "6s", "2p"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "9s", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "2p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]},
    ], %{
      east: %{
        yaku: [{"Toitoi", [2, "Han"]}],
        minipoints: 32,
        score: 770
      }
    })
  end

  test "tokyo - otakaze sankou" do
    TestUtils.test_yaku_advanced("tokyo_rules", [], [], """
    {
      "starting_hand": {
        "east": ["2m", "2m", "3p", "4p", "5p", "2z", "2z", "3z", "3z", "3z", "4z", "4z", "4z"],
        "south": ["1m", "6m", "7m", "2p", "5p", "8p", "3s", "5s", "7s", "8s", "9s", "3m", "4m"],
        "west": ["1m", "6m", "7m", "2p", "5p", "8p", "3s", "5s", "7s", "8s", "9s", "3m", "4m"],
        "north": ["5m", "6m", "8m", "4p", "8p", "9p", "3s", "5s", "7s", "8s", "9s", "3m", "4m"]
      },
      "starting_draws": ["6z", "2z"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]},
    ], %{
      east: %{
        yaku: [{"Otakaze Sankou", [3, "Han"]}],
        minipoints: 50,
        score: 2400
      }
    })
  end

  test "tokyo - no otakaze sankou if seat wind" do
    TestUtils.test_yaku_advanced("tokyo_rules", [], [], """
    {
      "starting_hand": {
        "east": ["1m", "6m", "7m", "2p", "5p", "8p", "3s", "5s", "7s", "8s", "9s", "3m", "4m"],
        "south": ["1m", "1m", "3p", "4p", "5p", "2z", "2z", "3z", "3z", "3z", "4z", "4z", "4z"],
        "west": ["1m", "6m", "7m", "2p", "5p", "8p", "3s", "5s", "7s", "8s", "9s", "3m", "4m"],
        "north": ["5m", "6m", "8m", "4p", "8p", "9p", "3s", "5s", "7s", "8s", "9s", "3m", "4m"]
      },
      "starting_draws": ["6z", "6z", "2z"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ron"}, nil, nil]},
    ], %{
      south: %{
        yaku: [{"Seat Wind", [1, "Han"]}],
        minipoints: 50,
        score: 400
      }
    })
  end

  test "tokyo - no otakaze sankou if round wind" do
    TestUtils.test_yaku_advanced("tokyo_rules", [], [], """
    {
      "starting_hand": {
        "east": ["1m", "6m", "7m", "2p", "5p", "8p", "3s", "5s", "7s", "8s", "9s", "3m", "4m"],
        "south": ["1m", "1m", "3p", "4p", "5p", "1z", "1z", "3z", "3z", "3z", "4z", "4z", "4z"],
        "west": ["1m", "6m", "7m", "2p", "5p", "8p", "3s", "5s", "7s", "8s", "9s", "3m", "4m"],
        "north": ["5m", "6m", "8m", "4p", "8p", "9p", "3s", "5s", "7s", "8s", "9s", "3m", "4m"]
      },
      "starting_draws": ["6z", "6z", "1z"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ron"}, nil, nil]},
    ], %{
      south: %{
        yaku: [{"Round Wind", [1, "Han"]}],
        minipoints: 50,
        score: 400
      }
    })
  end

  test "tokyo - otakaze sankou with double round wind not possible" do
    TestUtils.test_yaku_advanced("tokyo_rules", ["lib/double_round_wind"], [], """
    {
      "starting_hand": {
        "east": ["2m", "2m", "3p", "4p", "5p", "2z", "2z", "3z", "3z", "3z", "4z", "4z", "4z"],
        "south": ["1m", "6m", "7m", "2p", "5p", "8p", "3s", "5s", "7s", "8s", "9s", "3m", "4m"],
        "west": ["1m", "6m", "7m", "2p", "5p", "8p", "3s", "5s", "7s", "8s", "9s", "3m", "4m"],
        "north": ["5m", "6m", "8m", "4p", "8p", "9p", "3s", "5s", "7s", "8s", "9s", "3m", "4m"]
      },
      "starting_draws": ["6z", "2z"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]},
    ], %{
      east: %{
        yaku: [{"Round Wind", [1, "Han"]}],
        minipoints: 50,
        score: 600
      }
    })
  end

end