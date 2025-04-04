defmodule RiichiAdvanced.YakuTest.ZungJungYaku do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "zung jung - chicken hand" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "9m", "5s", "5s", "7p", "8p", "9p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"]
      },
      "starting_draws": ["6m", "5s", "6m"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "5m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Chicken Hand", 1}]
      }
    }, %{delta_scores: [3, -1, -1, -1]})
  end

  test "zung jung - concealed hand" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "8m", "3s", "4s", "7p", "8p", "9p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s"]
      },
      "starting_draws": ["6m", "5s"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Concealed Hand", 5}]
      }
    }, %{delta_scores: [15, -5, -5, -5]})
  end

  test "zung jung - ankan preserves concealed hand" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "8m", "3s", "4s", "7p", "8p", "9p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s"]
      },
      "starting_draws": ["3m", "6m", "5s"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Concealed Hand", 5}, {"One Kong", 5}]
      }
    }, %{delta_scores: [30, -10, -10, -10]})
  end

  test "zung jung - all sequences" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "9m", "5s", "6s", "7p", "8p", "9p"],
        "south": ["2m", "4m", "1p", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s"],
        "west": ["2m", "4m", "1p", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s"],
        "north": ["2m", "4m", "1p", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s"]
      },
      "starting_draws": ["6m", "1z", "2z", "7s", "7m"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7s", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "3m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "7m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"All Sequences", 5}]
      }
    }, %{delta_scores: [15, -5, -5, -5]})
  end

  test "zung jung - all sequences concealed" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "5m", "6m", "7m", "8m", "8m", "3s", "4s", "7p", "8p", "9p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s"]
      },
      "starting_draws": ["6m", "5s"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"All Sequences", 5}, {"Concealed Hand", 5}]
      }
    }, %{delta_scores: [30, -10, -10, -10]})
  end

  test "zung jung - no terminals" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "1z", "5m", "6m", "7m", "8m", "4s", "5s", "6s", "3p", "4p", "5p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s"]
      },
      "starting_draws": ["1z", "2z", "3z", "3m", "8m"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3m", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "8m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"No Terminals", 5}]
      }
    }, %{delta_scores: [15, -5, -5, -5]})
  end

  test "zung jung - mixed one suit" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "1z", "5m", "6m", "7m", "8m", "4m", "5m", "6m", "4z", "4z", "4z"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s"]
      },
      "starting_draws": ["1z", "2z", "3z", "3m", "8m"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3m", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "8m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Mixed One-Suit", 40}]
      }
    }, %{delta_scores: [120, -70, -25, -25]})
  end

  test "zung jung - pure one suit" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "1z", "5m", "6m", "7m", "8m", "4m", "5m", "6m", "7m", "8m", "9m"],
        "south": ["2m", "4m", "1p", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s"],
        "west": ["2m", "4m", "1p", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s"],
        "north": ["2m", "4m", "1p", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s"]
      },
      "starting_draws": ["1z", "2z", "3z", "3m", "8m"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3m", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "8m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Pure One-Suit", 80}]
      }
    }, %{delta_scores: [240, -190, -25, -25]})
  end

  test "zung jung - not nine gates" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["1m", "1m", "1m", "2m", "3m", "4m", "4m", "6m", "7m", "8m", "9m", "9m", "9m"],
        "south": ["2m", "1p", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "1s", "2s", "4s", "7s"],
        "west": ["2m", "1p", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "1s", "2s", "4s", "7s"],
        "north": ["2m", "1p", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "1s", "2s", "4s", "7s"]
      },
      "starting_draws": ["6m", "5m"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Concealed Hand", 5}, {"Pure One-Suit", 80}],
        yaku2: []
      }
    }, %{delta_scores: [255, -205, -25, -25]})
  end

  test "zung jung - nine gates" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["1m", "1m", "1m", "2m", "3m", "4m", "5m", "6m", "7m", "8m", "9m", "9m", "9m"],
        "south": ["2m", "1p", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "1s", "2s", "4s", "7s"],
        "west": ["2m", "1p", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "1s", "2s", "4s", "7s"],
        "north": ["2m", "1p", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "1s", "2s", "4s", "7s"]
      },
      "starting_draws": ["6m", "5m"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"Nine Gates", 480}]
      }
    }, %{delta_scores: [1440, -1390, -25, -25]})
  end

  test "zung jung - haku" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "9m", "5s", "5s", "0z", "0z", "0z"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"]
      },
      "starting_draws": ["6m", "5s", "6m"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "5m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Value Honor", 10}]
      }
    }, %{delta_scores: [30, -10, -10, -10]})
  end

  test "zung jung - hatsu" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "9m", "5s", "5s", "6z", "6z", "6z"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"]
      },
      "starting_draws": ["6m", "5s", "6m"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "5m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Value Honor", 10}]
      }
    }, %{delta_scores: [30, -10, -10, -10]})
  end

  test "zung jung - chun" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "9m", "5s", "5s", "7z", "7z", "7z"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"]
      },
      "starting_draws": ["6m", "5s", "6m"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "5m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Value Honor", 10}]
      }
    }, %{delta_scores: [30, -10, -10, -10]})
  end

  test "zung jung - seat wind" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "9m", "5s", "5s", "1z", "1z", "1z"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"]
      },
      "starting_draws": ["6m", "5s", "6m"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "5m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Value Honor", 10}]
      }
    }, %{delta_scores: [30, -10, -10, -10]})
  end

  test "zung jung - value honors stack" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["0z", "0z", "0z", "5m", "6m", "7m", "8m", "9m", "5s", "5s", "1z", "1z", "1z"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"]
      },
      "starting_draws": ["6m", "5s", "6m"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "5m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Value Honor", 20}]
      }
    }, %{delta_scores: [60, -20, -20, -20]})
  end

  test "zung jung - small three dragons" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["0z", "0z", "1m", "5m", "6m", "7p", "8p", "9p", "6z", "6z", "7z", "7z", "7z"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"]
      },
      "starting_draws": ["6m", "0z", "4m"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "0z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "4m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Small Three Dragons", 40}, {"Value Honor", 20}]
      }
    }, %{delta_scores: [180, -130, -25, -25]})
  end

  test "zung jung - big three dragons" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["0z", "0z", "1m", "5m", "6p", "7p", "8p", "6z", "6z", "1m", "7z", "7z", "7z"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"]
      },
      "starting_draws": ["6m", "0z", "6z", "5m"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "0z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Big Three Dragons", 130}, {"Value Honor", 30}]
      }
    }, %{delta_scores: [480, -430, -25, -25]})
  end

  test "zung jung - small three winds" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["2z", "2z", "1m", "5m", "6m", "7p", "8p", "9p", "3z", "3z", "4z", "4z", "4z"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"]
      },
      "starting_draws": ["6m", "2z", "4m"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "4m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Small Three Winds", 30}]
      }
    }, %{delta_scores: [90, -40, -25, -25]})
  end

  test "zung jung - big three winds" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["2z", "2z", "1m", "5m", "6p", "7p", "8p", "3z", "3z", "1z", "4z", "4z", "4z"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"]
      },
      "starting_draws": ["6m", "2z", "3z", "5m"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "3z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Big Three Winds", 120}]
      }
    }, %{delta_scores: [360, -310, -25, -25]})
  end

  test "zung jung - small four winds" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["1z", "1z", "1m", "5m", "6m", "2z", "2z", "2z", "3z", "3z", "4z", "4z", "4z"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"]
      },
      "starting_draws": ["6m", "1z", "4m"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "4m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"Small Four Winds", 320}]
      }
    }, %{delta_scores: [960, -910, -25, -25]})
  end

  test "zung jung - big four winds" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["1z", "1z", "1m", "5m", "2z", "2z", "2z", "3z", "3z", "3z", "4z", "4z", "4z"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"]
      },
      "starting_draws": ["6m", "1z", "5m"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"Big Four Winds", 400}]
      }
    }, %{delta_scores: [1200, -1150, -25, -25]})
  end


  test "zung jung - all triplets" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["9m", "9m", "9m", "5m", "1m", "2p", "2p", "1m", "3s", "3s", "1m", "4s", "4s"],
        "south": ["2m", "4m", "7m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s"],
        "west": ["2m", "4m", "7m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s"],
        "north": ["2m", "4m", "7m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s"]
      },
      "starting_draws": ["6m", "2p", "3s", "4s", "5m"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "3s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "4s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"All Triplets", 30}]
      }
    }, %{delta_scores: [90, -40, -25, -25]})
  end

  test "zung jung - two concealed triplets" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["1m", "9m", "9m", "5m", "1p", "2p", "3p", "3s", "3s", "3s", "4s", "4s", "4s"],
        "south": ["2m", "4m", "7m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s"],
        "west": ["2m", "4m", "7m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s"],
        "north": ["2m", "4m", "7m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s"]
      },
      "starting_draws": ["6m", "9m", "5m"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "9m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Two Concealed Triplets", 5}]
      }
    }, %{delta_scores: [15, -5, -5, -5]})
  end

  test "zung jung - ankan counts as concealed triplet" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "5m", "5m", "8m", "8m", "3s", "4s", "7p", "8p", "9p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s"]
      },
      "starting_draws": ["3m", "6m", "5s"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Concealed Hand", 5}, {"One Kong", 5}, {"Two Concealed Triplets", 5}]
      }
    }, %{delta_scores: [45, -15, -15, -15]})
  end

  test "zung jung - three concealed triplets" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["1m", "7m", "8m", "5m", "2p", "2p", "2p", "3s", "3s", "3s", "4s", "4s", "4s"],
        "south": ["2m", "4m", "7m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s"],
        "west": ["2m", "4m", "7m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s"],
        "north": ["2m", "4m", "7m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s"]
      },
      "starting_draws": ["6m", "1z", "1z", "9m", "5m"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "9m", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Three Concealed Triplets", 30}]
      }
    }, %{delta_scores: [90, -40, -25, -25]})
  end

  test "zung jung - four concealed triplets" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["9m", "9m", "9m", "5m", "2p", "2p", "2p", "3s", "3s", "3s", "4s", "4s", "4s"],
        "south": ["2m", "4m", "7m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s"],
        "west": ["2m", "4m", "7m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s"],
        "north": ["2m", "4m", "7m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s"]
      },
      "starting_draws": ["6m", "5m"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"All Triplets", 30}, {"Concealed Hand", 5}, {"Four Concealed Triplets", 125}]
      }
    }, %{delta_scores: [480, -430, -25, -25]})
  end

  test "zung jung - one kong" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["6m", "7m", "8m", "5m", "2p", "2p", "2p", "3s", "4s", "5s", "4z", "4z", "4z"],
        "south": ["2m", "4m", "7m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s"],
        "west": ["2m", "4m", "7m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s"],
        "north": ["2m", "4m", "7m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s"]
      },
      "starting_draws": ["6m", "2p", "1m", "5m"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "daiminkan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"One Kong", 5}]
      }
    }, %{delta_scores: [15, -5, -5, -5]})
  end

  test "zung jung - two kong" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["6m", "7m", "8m", "5m", "2p", "2p", "2p", "3s", "4s", "5s", "4z", "4z", "4z"],
        "south": ["2m", "4m", "7m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s"],
        "west": ["2m", "4m", "7m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s"],
        "north": ["2m", "4m", "7m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s"]
      },
      "starting_draws": ["6m", "2p", "1m", "4z", "1m", "5m"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "daiminkan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "daiminkan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Two Kong", 20}]
      }
    }, %{delta_scores: [60, -20, -20, -20]})
  end

  test "zung jung - three kong" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["9m", "9m", "9m", "5m", "2p", "2p", "2p", "3s", "4s", "5s", "4z", "4z", "4z"],
        "south": ["2m", "4m", "7m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s"],
        "west": ["2m", "4m", "7m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s"],
        "north": ["2m", "4m", "7m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s"]
      },
      "starting_draws": ["6m", "2p", "1m", "4z", "1m", "9m", "1m", "5m"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "daiminkan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "daiminkan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "9m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "daiminkan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Three Kong", 120}]
      }
    }, %{delta_scores: [360, -310, -25, -25]})
  end

  test "zung jung - four kong" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["9m", "9m", "9m", "5m", "2p", "2p", "2p", "3s", "3s", "3s", "4z", "4z", "4z"],
        "south": ["2m", "4m", "7m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s"],
        "west": ["2m", "4m", "7m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s"],
        "north": ["2m", "4m", "7m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s"]
      },
      "starting_draws": ["6m", "2p", "1m", "4z", "1m", "9m", "1m", "3s", "1m", "5m"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "daiminkan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "daiminkan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "9m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "daiminkan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "daiminkan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"Four Kong", 480}]
      }
    }, %{delta_scores: [1440, -1390, -25, -25]})
  end

  test "zung jung - open two identical sequences" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "6m", "7m", "7m", "8m", "8m", "9m", "4s", "5s", "6s"],
        "south": ["2m", "4m", "1p", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s"],
        "west": ["2m", "4m", "1p", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s"],
        "north": ["2m", "4m", "1p", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s"]
      },
      "starting_draws": ["6m", "1z", "2z", "9m", "5m"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "9m", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Two Identical Sequences", 10}]
      }
    }, %{delta_scores: [30, -10, -10, -10]})
  end

  test "zung jung - open three identical sequences" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["5p", "5p", "5p", "5m", "6m", "7m", "7m", "7m", "8m", "8m", "8m", "9m", "9m"],
        "south": ["2m", "4m", "1p", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s"],
        "west": ["2m", "4m", "1p", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s"],
        "north": ["2m", "4m", "1p", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s"]
      },
      "starting_draws": ["6m", "1z", "2z", "9m", "5m"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "9m", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Three Identical Sequences", 120}]
      }
    }, %{delta_scores: [360, -310, -25, -25]})
  end

  test "zung jung - open four identical sequences" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["5m", "6m", "7m", "7m", "7m", "7m", "8m", "8m", "8m", "8m", "9m", "9m", "9m"],
        "south": ["2m", "4m", "1p", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s"],
        "west": ["2m", "4m", "1p", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s"],
        "north": ["2m", "4m", "1p", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s"]
      },
      "starting_draws": ["6m", "1z", "2z", "9m", "5m"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "9m", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"Four Identical Sequences", 480}]
      }
    }, %{delta_scores: [1440, -1390, -25, -25]})
  end

  test "zung jung - open three similar sequences" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["5p", "5p", "5p", "5m", "6m", "7m", "7p", "7s", "8m", "8p", "8s", "9p", "9s"],
        "south": ["2m", "4m", "1p", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s"],
        "west": ["2m", "4m", "1p", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s"],
        "north": ["2m", "4m", "1p", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s"]
      },
      "starting_draws": ["6m", "1z", "2z", "9m", "5m"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "9m", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Three Similar Sequences", 35}]
      }
    }, %{delta_scores: [105, -55, -25, -25]})
  end

  test "zung jung - open small three similar triplets" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["1p", "2p", "3p", "5m", "6m", "6m", "7m", "7m", "7m", "7p", "7p", "7s", "7s"],
        "south": ["2m", "4m", "1p", "2p", "3p", "4p", "6p", "8p", "9p", "2s", "4s", "5s", "6s"],
        "west": ["2m", "4m", "1p", "2p", "3p", "4p", "6p", "8p", "9p", "2s", "4s", "5s", "6s"],
        "north": ["2m", "4m", "1p", "2p", "3p", "4p", "6p", "8p", "9p", "2s", "4s", "5s", "6s"]
      },
      "starting_draws": ["6m", "7s", "4m"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "4m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Small Three Similar Triplets", 30}]
      }
    }, %{delta_scores: [90, -40, -25, -25]})
  end

  test "zung jung - open three similar triplets" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["1p", "2p", "3p", "5m", "6m", "6m", "7m", "7m", "7m", "7p", "7p", "7s", "7s"],
        "south": ["2m", "4m", "1p", "2p", "3p", "4p", "6p", "8p", "9p", "2s", "4s", "5s", "6s"],
        "west": ["2m", "4m", "1p", "2p", "3p", "4p", "6p", "8p", "9p", "2s", "4s", "5s", "6s"],
        "north": ["2m", "4m", "1p", "2p", "3p", "4p", "6p", "8p", "9p", "2s", "4s", "5s", "6s"]
      },
      "starting_draws": ["6m", "7s", "7p", "5m"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "7p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Three Similar Triplets", 120}]
      }
    }, %{delta_scores: [360, -310, -25, -25]})
  end

  test "zung jung - open ittsu" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["1m", "1m", "1p", "2p", "4p", "5p", "6p", "6p", "6p", "8p", "9p", "1z", "2z"],
        "south": ["2m", "4m", "7m", "2p", "5p", "9p", "3s", "6s", "9s", "3z", "4z", "0z", "7z"],
        "west": ["2m", "4m", "7m", "2p", "5p", "9p", "3s", "6s", "9s", "3z", "4z", "0z", "7z"],
        "north": ["2m", "4m", "7m", "2p", "5p", "9p", "3s", "6s", "9s", "3z", "4z", "0z", "7z"]
      },
      "starting_draws": ["1z", "2z", "3z", "3p", "1z", "1z", "7p", "6p"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii", "call_choice" => ["1p", "2p"], "called_tile" => "3p"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "1z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7p", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii", "call_choice" => ["8p", "9p"], "called_tile" => "7p"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "2z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Nine-Tile Straight", 40}],
      }
    }, %{delta_scores: [120, -70, -25, -25]})
  end

  test "zung jung - closed ittsu" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "4m", "5m", "6m", "7m", "8m", "7p", "8p", "9p", "9s", "9s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "9m"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "9m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"All Sequences", 5}, {"Concealed Hand", 5}, {"Nine-Tile Straight", 40}],
      }
    }, %{delta_scores: [150, -100, -25, -25]})
  end

  test "zung jung - open three consecutive triplets" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["1p", "2p", "3p", "5m", "6m", "6m", "7m", "7m", "7m", "8m", "8m", "7s", "7s"],
        "south": ["2m", "4m", "1p", "2p", "3p", "4p", "6p", "8p", "9p", "2s", "4s", "5s", "6s"],
        "west": ["2m", "4m", "1p", "2p", "3p", "4p", "6p", "8p", "9p", "2s", "4s", "5s", "6s"],
        "north": ["2m", "4m", "1p", "2p", "3p", "4p", "6p", "8p", "9p", "2s", "4s", "5s", "6s"]
      },
      "starting_draws": ["1z", "6m", "8m", "5m"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "7s", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "8m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "7s", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Three Consecutive Triplets", 100}]
      }
    }, %{delta_scores: [300, -250, -25, -25]})
  end

  test "zung jung - open four consecutive triplets" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["5p", "6m", "6m", "7m", "7m", "8m", "8m", "9m", "9m", "9m", "7s", "8s", "9s"],
        "south": ["2m", "4m", "1p", "2p", "3p", "4p", "6p", "8p", "9p", "2s", "4s", "5s", "6s"],
        "west": ["2m", "4m", "1p", "2p", "3p", "4p", "6p", "8p", "9p", "2s", "4s", "5s", "6s"],
        "north": ["2m", "4m", "1p", "2p", "3p", "4p", "6p", "8p", "9p", "2s", "4s", "5s", "6s"]
      },
      "starting_draws": ["1z", "6m", "8m", "7m", "5p"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "7s", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "8m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "8s", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "7m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "9s", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"All Triplets", 30}, {"Four Consecutive Triplets", 200}]
      }
    }, %{delta_scores: [690, -640, -25, -25]})
  end

  test "zung jung - mixed lesser terminals" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "1z", "2z", "2z", "2z", "7p", "8p", "9p", "1s", "1s", "1s", "3s"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"]
      },
      "starting_draws": ["6m", "2z", "3z", "3m", "2s"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3m", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "2s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Mixed Lesser Terminals", 40}]
      }
    }, %{delta_scores: [120, -70, -25, -25]})
  end

  test "zung jung - pure lesser terminals" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "1z", "9m", "9m", "9m", "7p", "8p", "9p", "1s", "1s", "1s", "3s"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"]
      },
      "starting_draws": ["6m", "2z", "3z", "3m", "2s"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3m", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "2s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Pure Lesser Terminals", 50}]
      }
    }, %{delta_scores: [150, -100, -25, -25]})
  end

  test "zung jung - mixed greater terminals" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["1m", "1m", "1z", "1p", "1p", "2z", "9p", "9p", "3z", "0z", "0z", "9s", "9s"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "2s", "4s", "5s", "7s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "2s", "4s", "5s", "7s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "2s", "4s", "5s", "7s"]
      },
      "starting_draws": ["6m", "2z", "3z", "1m", "1p", "9p", "9s"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1m", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "1p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "2z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "9p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "3z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "9s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"All Triplets", 30}, {"Mixed Greater Terminals", 100}]
      }
    }, %{delta_scores: [390, -340, -25, -25]})
  end

  test "zung jung - pure greater terminals" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["1m", "1m", "1z", "9m", "9m", "9m", "9p", "9p", "9p", "1s", "1s", "1s", "9s"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "2s", "4s", "5s", "7s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "2s", "4s", "5s", "7s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "2s", "4s", "5s", "7s"]
      },
      "starting_draws": ["6m", "2z", "3z", "1m", "9s"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1m", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "9s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"Pure Greater Terminals", 400}]
      }
    }, %{delta_scores: [1200, -1150, -25, -25]})
  end

  test "zung jung - win on kong" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["6m", "7m", "8m", "5m", "2p", "2p", "2p", "3s", "4s", "5s", "4z", "4z", "4z"],
        "south": ["2m", "4m", "7m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s"],
        "west": ["2m", "4m", "7m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s"],
        "north": ["2m", "4m", "7m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s"]
      },
      "starting_draws": ["6m", "2p", "5m"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "daiminkan"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"One Kong", 5}, {"Win on Kong", 10}]
      }
    }, %{delta_scores: [45, -15, -15, -15]})
  end

  test "zung jung - robbing a kong" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "5m", "7m", "2p", "2p", "3s", "4s", "5s", "4z", "4z", "1z"],
        "south": ["6m", "6m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s", "4z"],
        "west": ["2m", "4m", "8m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s"],
        "north": ["2m", "7m", "7m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s"]
      },
      "starting_draws": ["6m", "6m"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "pon"}, nil, nil]},
      %{"type" => "discard", "tile" => "4z", "player" => 1, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "kakan"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chankan"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Robbing a Kong", 10}]
      }
    }, %{delta_scores: [30, -10, -10, -10]})
  end

  test "zung jung - blessing of heaven" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "5m", "7m", "2p", "2p", "3s", "4s", "5s", "4z", "4z", "4z"],
        "south": ["6m", "6m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "8m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s"],
        "north": ["2m", "7m", "7m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s"]
      },
      "starting_draws": ["6m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Concealed Hand", 5}, {"Blessing of Heaven", 155}]
      }
    }, %{delta_scores: [480, -160, -160, -160]})
  end

  test "zung jung - calls invalidate blessing of heaven" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "5m", "7m", "2p", "2p", "3s", "4s", "5s", "4z", "4z", "4z"],
        "south": ["6m", "6m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "8m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s"],
        "north": ["2m", "7m", "7m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s"]
      },
      "starting_draws": ["4z", "6m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Concealed Hand", 5}, {"One Kong", 5}, {"Win on Kong", 10}]
      }
    }, %{delta_scores: [60, -20, -20, -20]})
  end

  test "zung jung - blessing of earth" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["6m", "6m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s", "8s"],
        "south": ["1m", "2m", "3m", "5m", "7m", "2p", "2p", "3s", "4s", "5s", "4z", "4z", "4z"],
        "west": ["2m", "4m", "8m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s"],
        "north": ["2m", "7m", "7m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s"]
      },
      "starting_draws": ["6m"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ron"}, nil, nil]}
    ], %{
      south: %{
        yaku: [{"Concealed Hand", 5}, {"Blessing of Earth", 155}]
      }
    }, %{delta_scores: [-430, 480, -25, -25]})
  end

  test "zung jung - calls invalidate blessing of earth" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["6m", "6m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "8s", "8s", "8s"],
        "south": ["1m", "2m", "3m", "5m", "7m", "2p", "2p", "3s", "4s", "5s", "4z", "4z", "4z"],
        "west": ["2m", "4m", "8m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s"],
        "north": ["2m", "7m", "7m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "6s", "7s"]
      },
      "starting_draws": ["8s", "6m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ron"}, nil, nil]}
    ], %{
      south: %{
        yaku: [{"Concealed Hand", 5}]
      }
    }, %{delta_scores: [-5, 15, -5, -5]})
  end

  test "zung jung - non-juusan kokushi" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "3p", "3p", "3p", "4z"],
        "south": ["1m", "9m", "1p", "9p", "1s", "1s", "9s", "2z", "3z", "4z", "0z", "6z", "7z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "3z", "4z", "0z"]
      },
      "starting_draws": ["3p", "1z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ron"}, nil, nil]}
    ], %{
      south: %{
        yaku: [{"Thirteen Terminals", 160}]
      }
    }, %{delta_scores: [-430, 480, -25, -25]})
  end

  test "zung jung - juusan kokushi" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "3p", "3p", "3p", "4z"],
        "south": ["1m", "9m", "1p", "9p", "1s", "9s", "1z", "2z", "3z", "4z", "0z", "6z", "7z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "3z", "4z", "0z"]
      },
      "starting_draws": ["3p", "1z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ron"}, nil, nil]}
    ], %{
      south: %{
        yaku: [{"Thirteen Terminals", 160}]
      }
    }, %{delta_scores: [-430, 480, -25, -25]})
  end

  test "zung jung - seven pairs" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "3p", "3p", "3p", "4z"],
        "south": ["2m", "2m", "3m", "3m", "5m", "5m", "6m", "6m", "8m", "8m", "1p", "1p", "1z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "3z", "4z", "0z"]
      },
      "starting_draws": ["3p", "1z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ron"}, nil, nil]}
    ], %{
      south: %{
        yaku: [{"Seven Pairs", 30}]
      }
    }, %{delta_scores: [-40, 90, -25, -25]})
  end

  test "zung jung - seven pairs with duplicate" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "3p", "3p", "3p", "4z"],
        "south": ["3m", "3m", "3m", "3m", "5m", "5m", "6m", "6m", "8m", "8m", "1p", "1p", "1z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "3z", "4z", "0z"]
      },
      "starting_draws": ["3p", "1z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ron"}, nil, nil]}
    ], %{
      south: %{
        yaku: [{"Seven Pairs", 30}]
      }
    }, %{delta_scores: [-40, 90, -25, -25]})
  end

  test "zung jung - two kong is not seven pairs" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "5m", "5m", "6m", "6m", "8m", "8m", "1z", "1z", "2z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "3p", "3p", "3p", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "9s", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "3z", "4z", "0z"]
      },
      "starting_draws": ["3m", "5m", "3z", "2z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "3z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
    ], :no_winners)
  end

  test "zung jung - all honours" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["1z", "1z", "2z", "2z", "3z", "3z", "4z", "4z", "0z", "0z", "6z", "6z", "7z"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"]
      },
      "starting_draws": ["6m", "7z"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"All Honours", 320}]
      }
    }, %{delta_scores: [960, -910, -25, -25]})
  end

  test "zung jung - final discard" do
    # kyoku 0:
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["6m","6z","5p","1m","5p","6p","1p","2p","1p","6p","1m","2s","3m"],
        "south": ["6z","1s","5m","4s","4s","2z","4p","7m","9p","9p","9s","3s","7s"],
        "west": ["2s","3m","4z","2s","8p","3z","7m","4s","2m","8p","2z","6m","9m"],
        "north": ["6p","5s","1z","9s","4m","8s","9m","4p","3s","8p","9p","2m","7p"]
      },
      "starting_draws": ["8m","3p","5s","7z","6s","4z","5m","7p","3z","1z","2p","3s","1z","3p","4p","1s","6s","7m","4m","9m","8s","3p","8m","4m","1p","0z","1s","3m","8p","7p","6s","0z","1z","2m","1m","2z","7s","4m","8m","4p","2m","7z","7z","0z","7s","9s","1s","3z","3p","2p","8s","0z","8s","6z","4s","1p","6s","6m","5s","2z","7z","5m","8m","3s","6p","3z","7p","5p"],
      "starting_dead_wall": ["9s","9m","7m","9p","6z","3m","4z","7s","2p","6m","5m","2s","5p","5s"]
    }
    """, [
      %{"player" => 0, "tile" => "6z", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "3p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "5s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "7z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "2s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "4z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "5m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "7p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "3z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "1z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "2p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "3s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "1z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "3p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "4p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "1s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "3m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "7m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "4m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "9m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "8s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "3p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "8m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "4m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "8m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "0z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "1s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "3m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "8p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "7p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "6s", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [%{"button" => "pon", "call_choice" => ["6s", "6s"], "called_tile" => "6s"}, nil, nil, nil], "type" => "buttons_pressed"},
      %{"player" => 0, "tile" => "6m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "0z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "1z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "2m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "2p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "2z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "7s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "4m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "8m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "4p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "2m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "7z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "7z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "0z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "7s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "9s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "1s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "3z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "3p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "2p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "8s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "0z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "8s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "6z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "4s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "1p", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [%{"button" => "daiminkan", "call_choice" => ["1p", "1p", "1p"], "called_tile" => "1p"}, nil, nil, nil], "type" => "buttons_pressed"},
      %{"buttons" => [%{"button" => "kakan", "call_choice" => ["6s", "6s", "6s"], "called_tile" => "6s"}, nil, nil, nil], "type" => "buttons_pressed"},
      %{"player" => 0, "tile" => "6m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "5s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "2z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "7z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "5m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "8m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "3s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "6p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "3z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "7p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "5p", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [%{"button" => "ron"}, nil, nil, nil], "type" => "buttons_pressed"}
    ], %{
      east: %{
        yaku: [{"All Triplets", 30}, {"Final Discard", 10}, {"Two Kong", 20}]
      }
    }, %{delta_scores: [180, -25, -130, -25]})
  end

  test "zung jung - final draw" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["7m","8m","1z","9m","4s","4z","1s","1p","2s","3z","9s","4p","4s"],
        "south": ["6m","2p","0z","4s","2z","2p","5p","5p","6s","6z","9m","3p","3p"],
        "west": ["7m","8p","5s","9s","7s","6s","3s","6m","7z","2p","8p","8s","8s"],
        "north": ["9p","4p","4s","6p","8s","7p","3m","4p","6p","9s","6p","1m","1z"]
      },
      "starting_draws": ["4z","3p","6p","6z","1s","1p","1s","2m","7p","4z","8m","8p","9m","9m","5s","1m","3m","3z","2s","4m","6s","0z","9p","6s","7s","2p","7m","3z","6z","4m","2m","1p","2z","1m","2z","7p","2z","5p","5m","2m","3m","4m","4m","5m","2s","3p","3s","8m","1s","3s","3z","3m","7m","7z","5m","7s","6m","2m","1z","6z","8s","9s","4z","0z","3s","6m","8p","5s","7s","0z"],
      "starting_dead_wall": ["7p","5m","9p","7z","1z","2s","1p","5s","9p","1m","4p","7z","5p","8m"],
      "starting_round": 0,
      "starting_honba": 0
    }
    """, [
      %{"player" => 0, "tile" => "4z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "9m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 2, "tile" => "6p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "6z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "1s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "6m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 2, "tile" => "1s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "2m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "7p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "6s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 2, "tile" => "8m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "8p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "9m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "4s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 2, "tile" => "5s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "1m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "3m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "9m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 2, "tile" => "2s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "4m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "6s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "6z", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 2, "tile" => "9p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "6s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "7s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "4z", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 2, "tile" => "7m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "3z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "6z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "4m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "2m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "1p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "2z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "1m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "2z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "7p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "2z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "3z", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 2, "tile" => "5m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "2m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "3m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "2z", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 2, "tile" => "4m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "5m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "2s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "4m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 2, "tile" => "3s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "8m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "1s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "3s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "3z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "3m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "7m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "7z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "5m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "7s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "6m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "2m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "1z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "6z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "8s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "9s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "4z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "0z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "3s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "6m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "8p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "5s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "7s", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [nil, %{"button" => "tsumo"}, nil, nil], "type" => "buttons_pressed"}
    ], %{
      south: %{
        yaku: [{"Concealed Hand", 5}, {"Final Draw", 10}, {"Mixed One-Suit", 40}, {"Value Honor", 10}]
      }
    }, %{delta_scores: [-65, 195, -65, -65]})
  end

end
