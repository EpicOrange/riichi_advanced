defmodule RiichiAdvanced.YakuTest.HochiRulesScoringTest do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "hochi - furiten doesn't prevent winning on other waits" do
    TestUtils.test_yaku_advanced("hochi_rules", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "5m", "6m", "7m", "6p", "7p", "8p", "8s", "8s", "8s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2m", "8m"]
    }
    """, [
      %{"type" => "discard", "tile" => "2m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Tanyao", [1, "Han"]}],
        minipoints: 34 # 20 + 10 (closed ron) + 4 (closed 888s)
      }
    })
  end

  test "hochi - furiten does prevent winning on same wait" do
    TestUtils.test_yaku_advanced("hochi_rules", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "5m", "6m", "7m", "6p", "7p", "8p", "8s", "8s", "8s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2m", "2m"]
    }
    """, [
      %{"type" => "discard", "tile" => "2m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2m", "player" => 1, "tsumogiri" => true},
    ], :no_winners)
  end

  test "hochi - no minimum han if 0 honba" do
    TestUtils.test_yaku_advanced("hochi_rules", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "5m", "6m", "7m", "6p", "7p", "8p", "9s", "9s", "9s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2m", "8m"]
    }
    """, [
      %{"type" => "discard", "tile" => "2m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        minipoints: 38 # 20 + 10 (closed ron) + 8 (closed 999s)
      }
    })
  end

  test "hochi - 1 minimum han if 1+ honba" do
    TestUtils.test_yaku_advanced("hochi_rules", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "5m", "6m", "7m", "6p", "7p", "8p", "9s", "9s", "9s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2m", "8m"],
      "starting_honba": 1
    }
    """, [
      %{"type" => "discard", "tile" => "2m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8m", "player" => 1, "tsumogiri" => true},
    ], :no_winners)
  end

  test "hochi - closed pinfu ron is 30 fu" do
    TestUtils.test_yaku_advanced("hochi_rules", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "5m", "6m", "7m", "6p", "7p", "8p", "7s", "8s", "9s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2m", "8m"]
    }
    """, [
      %{"type" => "discard", "tile" => "2m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]},
    ], %{
      east: %{
        yaku: [],
        minipoints: 30
      }
    })
  end

  test "hochi - closed pinfu tsumo is 22 fu, but awards pinfu" do
    TestUtils.test_yaku_advanced("hochi_rules", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "5m", "6m", "7m", "6p", "7p", "8p", "7s", "8s", "9s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2m", "2m", "3p", "3p", "8m"]
    }
    """, [
      %{"type" => "discard", "tile" => "2m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2m", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]},
    ], %{
      east: %{
        yaku: [{"Pinfu", [1, "Han"]}, {"Tsumo", [1, "Han"]}],
        minipoints: 22
      }
    })
  end

  test "hochi - open pinfu ron is 20 fu" do
    TestUtils.test_yaku_advanced("hochi_rules", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "5m", "6m", "7m", "6p", "7p", "8p", "1z", "8s", "9s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2m", "2m", "3p", "7s", "8m"]
    }
    """, [
      %{"type" => "discard", "tile" => "2m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2m", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7s", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "8m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]},
    ], %{
      east: %{
        yaku: [{"Pinfu", [1, "Han"]}],
        minipoints: 20
      }
    })
  end

  test "hochi - open pinfu tsumo is 22 fu, but awards pinfu" do
    TestUtils.test_yaku_advanced("hochi_rules", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "5m", "6m", "7m", "6p", "7p", "8p", "1z", "8s", "9s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2m", "2m", "3p", "7s", "3p", "4p", "4p", "8m"]
    }
    """, [
      %{"type" => "discard", "tile" => "2m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2m", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7s", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "3p", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4p", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]},
    ], %{
      east: %{
        yaku: [{"Pinfu", [1, "Han"]}],
        minipoints: 22
      }
    })
  end

  test "hochi - kuikae is ok" do
    TestUtils.test_yaku_advanced("hochi_rules", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "5m", "6m", "7m", "6p", "7p", "8p", "7s", "8s", "9s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2m", "2m", "3p", "7s", "8m"]
    }
    """, [
      %{"type" => "discard", "tile" => "2m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2m", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7s", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "7s", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "8m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]},
    ], %{
      east: %{
        yaku: [{"Pinfu", [1, "Han"]}],
        minipoints: 20
      }
    })
  end

  test "hochi - double ron no riichi or honba" do
    TestUtils.test_yaku_advanced("hochi_rules", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "5m", "6m", "7m", "6p", "7p", "8p", "8s", "8s", "8s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["2m", "3m", "4m", "5m", "5m", "6m", "7m", "6p", "7p", "8p", "7s", "7s", "7s"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "8m"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, %{"button" => "ron"}, nil]},
    ], %{
      east: %{
        yaku: [{"Tanyao", [1, "Han"]}],
        minipoints: 34
      },
      west: %{
        yaku: [{"Tanyao", [1, "Han"]}],
        minipoints: 34
      }
    }, %{delta_scores: [820, -1910, 1090, 0]})
    # dealer scores 1632 normally, half is 816, round to 820
    # nondealer scores 1088 normally, round to 1090
  end

  test "hochi - double ron takes back riichi bets" do
    TestUtils.test_yaku_advanced("hochi_rules", [%{name: "lib/yaku/riichi", config: %{bet: 1000, drawless: false}}], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "5m", "6m", "7m", "6p", "7p", "8p", "8s", "8s", "8s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["2m", "3m", "4m", "5m", "5m", "6m", "7m", "6p", "7p", "8p", "7s", "7s", "7s"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "1z", "2z", "2z", "3z", "8m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "riichi"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "riichi"}, nil]},
      %{"type" => "discard", "tile" => "2z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, %{"button" => "ron"}, nil]},
    ], %{
      east: %{
        yaku: [{"Double Riichi", [2, "Han"]}, {"Tanyao", [1, "Han"]}],
        minipoints: 34
      },
      west: %{
        yaku: [{"Double Riichi", [2, "Han"]}, {"Tanyao", [1, "Han"]}],
        minipoints: 34
      }
    }, %{delta_scores: [3560, -7610, 4650, 0]})
    # dealer scores 6528 normally, half is 3264, round to 3260, plus riichi bet is 3560
    # nondealer scores 4352 normally, round to 4350, plus riichi bet is 4650
  end

  test "hochi - double ron takes back riichi bets and splits any remainder" do
    TestUtils.test_yaku_advanced("hochi_rules", [%{name: "lib/yaku/riichi", config: %{bet: 1000, drawless: false}}], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "5m", "6m", "7m", "6p", "7p", "8p", "8s", "8s", "8s"],
        "south": ["1m", "2m", "3m", "2p", "3p", "4p", "3s", "4s", "5s", "6s", "7s", "8s", "4z"],
        "west": ["2m", "3m", "4m", "5m", "5m", "6m", "7m", "6p", "7p", "8p", "7s", "7s", "7s"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "1z", "2z", "2z", "3z", "8m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "riichi"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "riichi"}, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "riichi"}, nil]},
      %{"type" => "discard", "tile" => "2z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, %{"button" => "ron"}, nil]},
    ], %{
      east: %{
        yaku: [{"Double Riichi", [2, "Han"]}, {"Tanyao", [1, "Han"]}],
        minipoints: 34
      },
      west: %{
        yaku: [{"Double Riichi", [2, "Han"]}, {"Tanyao", [1, "Han"]}],
        minipoints: 34
      }
    }, %{delta_scores: [3710, -7610, 4800, 0]})
  end

end