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
        yaku: [],
        yaku2: []
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
        "south": ["2m", "4m", "6m", "7m", "2p", "3p", "4p", "6p", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "6m", "7m", "2p", "3p", "4p", "6p", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "6m", "7m", "2p", "3p", "4p", "6p", "4s", "5s", "6s", "7s", "8s"]
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
        "south": ["2m", "4m", "7m", "2p", "3p", "5p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
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

  test "hefei - seven pairs" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "5m", "5m", "6m", "6m", "8m", "8m", "6p", "6p", "7p", "7p", "3s"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "5p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "5p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "5p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["2s", "3s"]
    }
    """, [
      %{"type" => "discard", "tile" => "2s", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"Seven Pairs", 10}]
      }
    })
  end

  test "hefei - luxury seven pairs" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "5m", "5m", "6m", "6m", "6m", "6m", "6p", "6p", "7p", "7p", "3s"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "5p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "5p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "5p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["2s", "3s"]
    }
    """, [
      %{"type" => "discard", "tile" => "2s", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"Luxury Seven Pairs", 50}]
      }
    })
  end

  test "hefei - double luxury seven pairs" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "3m", "6m", "6m", "6m", "6m", "6p", "6p", "7p", "7p", "3s"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "5p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "5p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "5p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["2s", "3s"]
    }
    """, [
      %{"type" => "discard", "tile" => "2s", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"Double Luxury Seven Pairs", 100}]
      }
    })
  end

  test "hefei - pure suit" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "4m", "4m", "4m", "5m", "6m", "6m", "6m", "6m", "7m", "8m"],
        "south": ["2p", "3p", "4p", "6p", "7p", "8p", "2s", "3s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2p", "3p", "4p", "6p", "7p", "8p", "2s", "3s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2p", "3p", "4p", "6p", "7p", "8p", "2s", "3s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["8p", "7m"]
    }
    """, [
      %{"type" => "discard", "tile" => "8p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"Pure Suit", 100}]
      }
    })
  end

  test "hefei - three consecutive pungs" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["6m", "6m", "6m", "7m", "7m", "7m", "8m", "8m", "8m", "3s", "4p", "5p", "6p"],
        "south": ["2m", "4m", "5m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "5m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "5m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["8p", "3s"]
    }
    """, [
      %{"type" => "discard", "tile" => "8p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"Three Consecutive Pungs", 100}]
      }
    })
  end

  test "hefei - three consecutive pungs must be closed" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["6m", "6m", "6m", "7m", "7m", "7m", "8m", "8m", "3s", "3s", "4p", "5p", "6p"],
        "south": ["2m", "4m", "5m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "5m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "5m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["8p", "8m"]
    }
    """, [
      %{"type" => "discard", "tile" => "8p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Concealed Double Sequences", 4}, {"Concealed Pungs", 2}, {"Same Number Bonus", 1}, {"Suit Bonus", 1}],
        yaku2: []
      }
    })
  end

  test "hefei - three consecutive pungs via tsumo" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["6m", "6m", "6m", "7m", "7m", "7m", "8m", "8m", "3s", "3s", "4p", "5p", "6p"],
        "south": ["2m", "4m", "5m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "5m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "5m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["8p", "7p", "8p", "7p", "8m"]
    }
    """, [
      %{"type" => "discard", "tile" => "8p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7p", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7p", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"Three Consecutive Pungs", 100}]
      }
    })
  end

  test "hefei - 10 identical tiles" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "3m", "4m", "5m", "8m", "8m", "3p", "3p", "3s", "3s", "3s"],
        "south": ["2m", "4m", "7m", "2p", "4p", "6p", "7p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "4p", "6p", "7p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "4p", "6p", "7p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["8p", "8p", "8p", "8p", "3p"]
    }
    """, [
      %{"type" => "discard", "tile" => "8p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8p", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8p", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"Ten Identical Tiles", 100}]
      }
    })
  end

  test "hefei - 11 identical tiles is more than enough" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "3m", "4m", "5m", "8m", "8m", "3p", "3p", "3s", "3s", "3s"],
        "south": ["2m", "4m", "7m", "2p", "4p", "6p", "7p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "4p", "6p", "7p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "4p", "6p", "7p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["3s", "8p", "8p", "8p", "3p"],
      "starting_dead_wall": ["8p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan", "call_choice" => ["3s", "3s", "3s"], "called_tile" => "3s"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "8p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8p", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8p", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"Ten Identical Tiles", 100}]
      }
    })
  end

  test "hefei - 9 identical tiles is not enough" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "4m", "5m", "6m", "8m", "8m", "3p", "3p", "3s", "3s", "3s"],
        "south": ["2m", "4m", "7m", "2p", "4p", "6p", "7p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "4p", "6p", "7p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "4p", "6p", "7p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["8p", "8p", "8p", "8p", "3p"]
    }
    """, [
      %{"type" => "discard", "tile" => "8p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8p", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8p", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Concealed Pungs", 3}, {"Same Number Bonus", 6}],
        yaku2: []
      }
    })
  end

  test "hefei - heavenly win" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "6m", "7m", "8m", "8m", "3s", "4s", "4p", "5p", "6p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["5s"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"Heavenly Win", 200}]
      }
    })
  end

  test "hefei - earthly win" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "south": ["2m", "3m", "4m", "5m", "6m", "7m", "8m", "8m", "3s", "4s", "4p", "5p", "6p"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["8p", "5s"]
    }
    """, [
      %{"type" => "discard", "tile" => "8p", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "tsumo"}, nil, nil]}
    ], %{
      south: %{
        yaku: [],
        yaku2: [{"Earthly Win", 150}]
      }
    })
  end

  test "hefei - ankan invalidates heavenly win" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "5m", "5m", "8m", "8m", "3s", "4s", "4p", "5p", "6p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["5m"],
      "starting_dead_wall": ["5s"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Concealed Kong", 4}, {"Concealed Pung", 1}, {"Same Number Bonus", 2}, {"Suit Bonus", 1}],
        yaku2: []
      }
    })
  end

  test "hefei - others' calls don't invalidate earthly win" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["2m", "4m", "7m", "8p", "8p", "8p", "8p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "south": ["2m", "3m", "4m", "5m", "6m", "7m", "8m", "8m", "3s", "4s", "4p", "5p", "6p"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["3s", "5s"],
      "starting_dead_wall": ["7p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "7p", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "tsumo"}, nil, nil]}
    ], %{
      south: %{
        yaku: [],
        yaku2: [{"Earthly Win", 150}]
      }
    })
  end

  test "hefei - renhou is earthly win" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["2m", "4m", "7m", "8p", "8p", "8p", "8p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "south": ["2m", "3m", "4m", "5m", "6m", "7m", "8m", "8m", "3s", "4s", "4p", "5p", "6p"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["3s", "7p", "7p", "5s"],
      "starting_dead_wall": ["7p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "7p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7p", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ron"}, nil, nil]}
    ], %{
      south: %{
        yaku: [],
        yaku2: [{"Earthly Win", 150}]
      }
    })
  end

  test "hefei - after first round is not renhou" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["2m", "4m", "7m", "8p", "8p", "8p", "8p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "south": ["2m", "3m", "4m", "5m", "6m", "7m", "8m", "8m", "3s", "4s", "4p", "5p", "6p"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["3s", "7p", "7p", "7p", "5s"],
      "starting_dead_wall": ["7p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "7p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7p", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7p", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ron"}, nil, nil]}
    ], %{
      south: %{
        yaku: [],
        yaku2: []
      }
    })
  end

  test "hefei - sea floor (first draw as east)" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["7s","6s","4s","2p","6p","5p","2m","5s","2p","6s","4s","2p","8s"],
        "south": ["4p","4m","3m","6m","2m","8s","2s","3p","6p","3m","3p","5m","5m"],
        "west": ["6m","4m","5m","4m","2m","5s","7m","7m","4p","6p","8s","2s","6s"],
        "north": ["6p","3s","2p","2m","4p","8m","8p","3s","7p","4s","3p","8m","7p"]
      },
      "starting_draws": ["8m","7s","4s","3p","5s","8s","8p","5s","8m","2s","4p","5p","4m","3m","5m","7p","2s","6m","5p","5p","7p","3s","8p","7m","3m","7m","6s","8p","3s","7s","6m","7s"],
      "starting_round": 0,
      "starting_honba": 0
    }
    """, [
      %{"player" => 0, "tile" => "8m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "8s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 2, "tile" => "2s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 3, "tile" => "2p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "2m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "8s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "8p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "2m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "8m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "2s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "8s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 3, "tile" => "8m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "4m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "2m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 2, "tile" => "2m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 3, "tile" => "8m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "2p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "3p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 2, "tile" => "5p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "8p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "2s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "7s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 2, "tile" => "8p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "7m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "3m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "3m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 2, "tile" => "4p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 3, "tile" => "8p", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [%{"button" => "tsumo"}, nil, nil, nil], "type" => "buttons_pressed"}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"Sea Floor", 15}]
      }
    })
  end

  test "hefei - sea floor (last draw as east)" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["7s","5s","3m","6p","7p","5p","4s","3s","7p","7m","2p","6p","2s"],
        "south": ["3s","2p","6p","2s","5m","2p","8m","3m","3p","6s","5s","6s","7m"],
        "west": ["4m","2p","5p","3p","2s","3p","3s","8p","4m","6m","4s","8p","8s"],
        "north": ["8m","8s","8s","6m","7m","6s","4p","3m","6m","4p","7p","4p","5p"]
      },
      "starting_draws": ["7s","8m","3m","6p","3s","5m","8p","5m","6m","7p","2s","2m","6s","5s","5s","2m","4p","4m","5m","7m","8p","2m","8s","7s","4m","2m","4s","8m","5p","3p","4s","7s"],
      "starting_round": 0,
      "starting_honba": 0
    }
    """, [
      %{"player" => 0, "tile" => "3m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "6p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 2, "tile" => "2p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 3, "tile" => "8m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "7m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "5m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "8s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 3, "tile" => "8s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "6m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "7p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "8p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 3, "tile" => "8s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "2p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "5s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "8p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 3, "tile" => "7p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "6p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "4m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "8p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 3, "tile" => "2m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "8p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "2m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "3p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 3, "tile" => "7s", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [%{"button" => "pon", "call_choice" => ["7s", "7s"], "called_tile" => "7s"}, nil, nil, nil], "type" => "buttons_pressed"},
      %{"player" => 0, "tile" => "3s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "4m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "2m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "4p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "8m", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [nil, %{"button" => "sea_floor_no_win"}, nil, nil], "type" => "buttons_pressed"},
      %{"buttons" => [nil, nil, %{"button" => "sea_floor_no_win"}, nil], "type" => "buttons_pressed"},
      %{"buttons" => [nil, nil, nil, %{"button" => "sea_floor_no_win"}], "type" => "buttons_pressed"},
      %{"buttons" => [%{"button" => "tsumo"}, nil, nil, nil], "type" => "buttons_pressed"}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"Sea Floor", 15}]
      }
    })
  end

  test "hefei - sea floor (last draw as north)" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["2m","8m","4m","4s","5m","8p","8p","4s","5s","2s","8p","3s","8m"],
        "south": ["6s","2m","5p","8s","6p","5p","3p","6p","7m","6m","8s","3p","6s"],
        "west": ["3m","8s","7m","4p","4p","2p","7m","3m","5m","2s","2m","7m","2m"],
        "north": ["7p","7s","6p","5s","8p","3p","3m","5s","5p","2s","7s","7s","5m"]
      },
      "starting_draws": ["2p","4m","6m","6p","2p","3s","5p","4p","7p","5m","4s","2s","6s","8s","3p","4m","7s","8m","3s","8m","4m","6m","5s","3m","4p","4s","7p","6m","7p","3s","6s"],
      "starting_dead_wall": ["2p"],
      "starting_round": 1,
      "starting_honba": 0
    }
    """, [
      %{"player" => 1, "tile" => "6m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 2, "tile" => "2p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 3, "tile" => "8p", "tsumogiri" => false, "type" => "discard"},
      %{"buttons" => [%{"button" => "daiminkan", "call_choice" => ["8p", "8p", "8p"], "called_tile" => "8p"}, nil, nil, nil], "type" => "buttons_pressed"},
      %{"player" => 0, "tile" => "2p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "2p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 2, "tile" => "2m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 3, "tile" => "7p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "5p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "8s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 2, "tile" => "8s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 3, "tile" => "3p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "2m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "8s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 2, "tile" => "2p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 3, "tile" => "8s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "4m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "2m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 2, "tile" => "2m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 3, "tile" => "8m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "5m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "8m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "2s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 3, "tile" => "3m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "3p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "2s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 2, "tile" => "7s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 3, "tile" => "2s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "7p", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [nil, %{"button" => "sea_floor_no_win"}, nil, nil], "type" => "buttons_pressed"},
      %{"buttons" => [nil, nil, %{"button" => "sea_floor_no_win"}, nil], "type" => "buttons_pressed"},
      %{"buttons" => [nil, nil, nil, %{"button" => "sea_floor_no_win"}], "type" => "buttons_pressed"},
      %{"buttons" => [%{"button" => "tsumo"}, nil, nil, nil], "type" => "buttons_pressed"}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"Sea Floor", 15}]
      }
    })
  end

  test "hefei - winning right before sea floor doesn't give sea floor" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["5p","6p","8p","4m","5m","6m","3s","2p","6s","7p","7s","8s","6s"],
        "south": ["7m","4p","2s","3m","5s","2p","8s","3s","5s","7m","2s","3m","2p"],
        "west": ["7p","3m","4m","6s","8m","2s","5s","8m","2m","7p","7p","8p","7s"],
        "north": ["5p","5p","4s","2s","7s","6m","3s","3s","5m","5s","8s","2m","6m"]
      },
      "starting_draws": ["4p","7m","7m","4m","6p","8s","5m","3m","3p","4p","2p","4s","3p","8p","8m","4p","8m","6p","7s","6s","6m","3p","2m","4s","3p","5p","6p","4s","5m","4m","8p","2m"],
      "starting_dead_wall": [],
      "starting_round": 0,
      "starting_honba": 0
    }
    """, [
      %{"player" => 0, "tile" => "7s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "2p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 2, "tile" => "8p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 3, "tile" => "2m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "8s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "2p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 2, "tile" => "2s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 3, "tile" => "5p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "2p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "8s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 2, "tile" => "2p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "5p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "8p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "8p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "8m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "4p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "8m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "7m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 2, "tile" => "7p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 3, "tile" => "6m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "3s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "7m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 2, "tile" => "2m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "3m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "3p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "7m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 2, "tile" => "7s", "tsumogiri" => false, "type" => "discard"},
      %{"buttons" => [nil, nil, nil, %{"button" => "tsumo"}], "type" => "buttons_pressed"}
    ], %{
      north: %{
        yaku: [{"Four of a Kind", 4}, {"Same Number Bonus", 2}, {"Single Wait", 1}, {"Suit Bonus", 3}, {"Two Suits Only", 2}],
        yaku2: []
      }
    })
  end

  test "hefei - one dealer repeat dealer win" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "6m", "7m", "8m", "8m", "3s", "4s", "4p", "5p", "6p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["8p", "5s"],
      "starting_honba": 1
    }
    """, [
      %{"type" => "discard", "tile" => "8p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Dealer Repeat", 4}],
        yaku2: []
      }
    })
  end

  test "hefei - one dealer repeat nondealer win" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "6m", "7m", "8m", "8m", "3s", "4s", "4p", "5p", "6p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["8p", "8p", "8p", "8p", "5s"],
      "starting_round": 3,
      "starting_honba": 1
    }
    """, [
      %{"type" => "discard", "tile" => "8p", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8p", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Dealer Repeat", 4}],
        yaku2: []
      }
    })
  end

  test "hefei - seven pairs with dealer repeat" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "5m", "5m", "6m", "6m", "8m", "8m", "6p", "6p", "7p", "7p", "3s"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "5p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "5p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "5p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["2s", "3s"],
      "starting_honba": 3
    }
    """, [
      %{"type" => "discard", "tile" => "2s", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"Seven Pairs", 10}, {"Dealer Repeats", 12}]
      }
    })
  end

  test "hefei - multiple dealer repeats" do
    TestUtils.test_yaku_advanced("hefei", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "6m", "7m", "8m", "8m", "3s", "4s", "4p", "5p", "6p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["8p", "5s"],
      "starting_honba": 5
    }
    """, [
      %{"type" => "discard", "tile" => "8p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Dealer Repeats", 20}],
        yaku2: []
      }
    })
  end

end
