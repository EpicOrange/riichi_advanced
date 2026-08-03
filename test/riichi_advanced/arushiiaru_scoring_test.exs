defmodule RiichiAdvanced.YakuTest.ArushiiaruScoringTest do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "arushiiaru - furiten doesn't prevent winning on other waits" do
    TestUtils.test_yaku_advanced("arushiiaru", [], """
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
        minipoints: 40
      }
    })
  end

  test "arushiiaru - furiten does prevent winning on same wait" do
    TestUtils.test_yaku_advanced("arushiiaru", [], """
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

  test "arushiiaru - no minimum han" do
    TestUtils.test_yaku_advanced("arushiiaru", [], """
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
        minipoints: 40
      }
    })
  end

  test "arushiiaru - closed pinfu ron is 30 fu" do
    TestUtils.test_yaku_advanced("arushiiaru", [], """
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

  test "arushiiaru - closed pinfu tsumo is 22 fu (= 30 fu)" do
    TestUtils.test_yaku_advanced("arushiiaru", [], """
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
        yaku: [],
        minipoints: 30
      }
    })
  end

  test "arushiiaru - open pinfu ron is 20 fu" do
    TestUtils.test_yaku_advanced("arushiiaru", [], """
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

  test "arushiiaru - open pinfu tsumo is 22 fu (= 30 fu)" do
    TestUtils.test_yaku_advanced("arushiiaru", [], """
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
        yaku: [],
        minipoints: 30
      }
    })
  end

  test "arushiiaru - kuikae is ok" do
    TestUtils.test_yaku_advanced("arushiiaru", [], """
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

end