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
        score: 1344
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
        score: 12000
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
        score: 7296
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
        score: 5760
      }
    })
  end

  test "tokyo - isshoku sanjun" do
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
        score: 4608
      }
    })
  end

end