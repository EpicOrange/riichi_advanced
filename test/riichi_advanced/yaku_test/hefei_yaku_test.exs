defmodule RiichiAdvanced.YakuTest.HefeiYaku do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "hefei - chicken hand" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "6m", "7m", "8m", "8m", "3s", "4s", "4p", "5p", "6p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["8p", "5s"]
    }
    """, [
      %{"type" => "discard", "tile" => "8p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: []
      }
    })
  end

  test "hefei - penchan awards single wait" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "6m", "7m", "8m", "8m", "2s", "3s", "4p", "5p", "6p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["8p", "4s"]
    }
    """, [
      %{"type" => "discard", "tile" => "8p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Single Wait", 1}]
      }
    })
  end

  test "hefei - kanchan awards single wait" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "6m", "7m", "8m", "8m", "2s", "4s", "4p", "5p", "6p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["8p", "3s"]
    }
    """, [
      %{"type" => "discard", "tile" => "8p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Single Wait", 1}]
      }
    })
  end

  test "hefei - tanki awards single wait" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "4m", "5m", "6m", "8m", "2s", "3s", "4s", "5p", "6p", "7p"],
        "south": ["2m", "3m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["8p", "8m"]
    }
    """, [
      %{"type" => "discard", "tile" => "8p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Single Wait", 1}]
      }
    })
  end

  test "hefei - extended tanki doesn't award single wait" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "6m", "7m", "8m", "2s", "3s", "4s", "4p", "5p", "6p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["8p", "8m"]
    }
    """, [
      %{"type" => "discard", "tile" => "8p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: []
      }
    })
  end

  test "hefei - suit bonus" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "6m", "7m", "8m", "8m", "3s", "4s", "5p", "5p", "5p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["8p", "8m", "5s"]
    }
    """, [
      %{"type" => "discard", "tile" => "8p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "5p", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Suit Bonus", 1}]
      }
    })
  end

  test "hefei - kans count 4 towards suit and number bonuses" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "6m", "7m", "8m", "8m", "8m", "3s", "4s", "5p", "5p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["8p", "8m", "5s"],
      "starting_dead_wall": ["5p"]
    }
    """, [
      %{"type" => "discard", "tile" => "8p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "daiminkan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "5p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Same Number Bonus", 1}, {"Suit Bonus", 2}]
      }
    })
  end

  test "hefei - one concealed triplet" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "5m", "5m", "8m", "8m", "3s", "4s", "4p", "5p", "6p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["8p", "5s"]
    }
    """, [
      %{"type" => "discard", "tile" => "8p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Concealed Pung", 1}, {"Same Number Bonus", 1}]
      }
    })
  end

  test "hefei - two concealed triplets" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "5m", "5m", "8m", "8m", "3s", "4s", "4p", "5p", "6p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["8p", "5s"]
    }
    """, [
      %{"type" => "discard", "tile" => "8p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Concealed Pungs", 2}, {"Same Number Bonus", 2}]
      }
    })
  end

  test "hefei - three concealed triplets" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "5m", "5m", "8m", "8m", "3s", "4s", "7p", "7p", "7p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["8p", "5s"]
    }
    """, [
      %{"type" => "discard", "tile" => "8p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Concealed Pungs", 3}, {"Same Number Bonus", 1}]
      }
    })
  end

  test "hefei - four concealed triplets" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "5m", "5m", "8m", "8m", "2s", "2s", "7p", "7p", "7p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "8p", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "8p", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "8p", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["8p", "5s", "5p", "8p", "2s"]
    }
    """, [
      %{"type" => "discard", "tile" => "8p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8p", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"Four Concealed Pungs", 100}],
        score: 2000
      }
    })
  end

  test "hefei - open double sequences" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "5m", "5m", "6m", "6m", "7m", "2s", "3s", "4s", "4p", "5p", "6p"],
        "south": ["2m", "4m", "8m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "8m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "8m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["8p", "7m"]
    }
    """, [
      %{"type" => "discard", "tile" => "8p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Double Sequences", 2}]
      }
    })
  end

  test "hefei - closed double sequences" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "5m", "5m", "6m", "6m", "7m", "7m", "3s", "4s", "4p", "5p", "6p"],
        "south": ["2m", "4m", "8m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "8m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "8m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["8p", "5s"]
    }
    """, [
      %{"type" => "discard", "tile" => "8p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Concealed Double Sequences", 4}]
      }
    })
  end

  test "hefei - open double sequences x2 is seven pairs" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "5m", "5m", "6m", "6m", "7m", "7m", "6p", "6p", "7p", "7p", "8p"],
        "south": ["2m", "4m", "8m", "2p", "3p", "4p", "5p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "8m", "2p", "3p", "4p", "5p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "8m", "2p", "3p", "4p", "5p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["2s", "8p"]
    }
    """, [
      %{"type" => "discard", "tile" => "2s", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"Seven Pairs", 10}]
      }
    })
  end

  test "hefei - open/closed double sequences x2" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "5m", "5m", "6m", "6m", "7m", "6p", "6p", "7p", "7p", "8p", "8p"],
        "south": ["2m", "4m", "8m", "2p", "3p", "4p", "5p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "8m", "2p", "3p", "4p", "5p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "8m", "2p", "3p", "4p", "5p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["2s", "7m"]
    }
    """, [
      %{"type" => "discard", "tile" => "2s", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"Seven Pairs", 10}]
      }
    })
  end

  test "hefei - self drawn double sequences x1 is closed" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "5m", "5m", "6m", "6m", "7m", "5p", "6p", "7p", "2s", "3s", "4s"],
        "south": ["2m", "4m", "8m", "2p", "3p", "4p", "5p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "8m", "2p", "3p", "4p", "5p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "8m", "2p", "3p", "4p", "5p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["2p", "3p", "4p", "3s", "7m"]
    }
    """, [
      %{"type" => "discard", "tile" => "2p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3s", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Concealed Double Sequences", 4}]
      }
    })
  end

  test "hefei - self drawn double sequences x2 is closed" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "5m", "5m", "6m", "6m", "7m", "6p", "6p", "7p", "7p", "8p", "8p"],
        "south": ["2m", "4m", "8m", "2p", "3p", "4p", "5p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "8m", "2p", "3p", "4p", "5p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "8m", "2p", "3p", "4p", "5p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["2p", "3p", "4p", "5p", "7m"]
    }
    """, [
      %{"type" => "discard", "tile" => "2p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5p", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"Double Concealed Double Sequences", 100}]
      }
    })
  end

  test "hefei - closed double sequences x2" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["3m", "5m", "5m", "6m", "6m", "7m", "7m", "6p", "6p", "7p", "7p", "8p", "8p"],
        "south": ["2m", "4m", "8m", "2p", "3p", "4p", "5p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "8m", "2p", "3p", "4p", "5p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "8m", "2p", "3p", "4p", "5p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["2s", "3m"]
    }
    """, [
      %{"type" => "discard", "tile" => "2s", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"Double Concealed Double Sequences", 100}]
      }
    })
  end

  test "hefei - two suits" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "6m", "7m", "8m", "8m", "3p", "4p", "4p", "5p", "6p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["8p", "5p"]
    }
    """, [
      %{"type" => "discard", "tile" => "8p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Two Suits Only", 2}]
      }
    })
  end

  test "hefei - concealed kong" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "6m", "7m", "8m", "8m", "3s", "3s", "5p", "5p", "5p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["5p", "6s", "7s", "8s", "3s"],
      "starting_dead_wall": ["8m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "8m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6s", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8s", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Concealed Kong", 4}, {"Concealed Pungs", 2}, {"Same Number Bonus", 3}]
      }
    })
  end

  test "hefei - two concealed kongs" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "8m", "3s", "3s", "5p", "5p", "5p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["5p", "6s", "7s", "8s", "3s"],
      "starting_dead_wall": ["3m", "8m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "8m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6s", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8s", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Concealed Kongs", 8}, {"Concealed Pungs", 3}, {"Same Number Bonus", 6}, {"Suit Bonus", 1}]
      }
    })
  end

  test "hefei - four of a kind" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "3m", "3m", "3m", "4m", "8m", "8m", "3s", "4s", "4p", "5p", "6p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["8p", "5s"]
    }
    """, [
      %{"type" => "discard", "tile" => "8p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Concealed Pung", 1}, {"Same Number Bonus", 2}, {"Four of a Kind", 4}]
      }
    })
  end

  test "hefei - four of a kind using pair" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["3m", "4m", "5m", "5m", "5m", "5m", "6m", "7m", "3s", "4s", "4p", "5p", "6p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["8p", "5s"]
    }
    """, [
      %{"type" => "discard", "tile" => "8p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Same Number Bonus", 2}, {"Four of a Kind", 4}]
      }
    })
  end

  test "hefei - double four of a kind treated as single" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "3m", "3m", "3m", "4m", "8m", "8m", "3s", "3s", "3s", "3s", "4s"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["8p", "5s"]
    }
    """, [
      %{"type" => "discard", "tile" => "8p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Concealed Pungs", 2}, {"Same Number Bonus", 5}, {"Four of a Kind", 4}, {"Two Suits Only", 2}]
      }
    })
  end

end
