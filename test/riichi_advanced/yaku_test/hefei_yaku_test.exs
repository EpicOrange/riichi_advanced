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
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil]}
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
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil]}
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
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil]}
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
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil]}
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
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil]}
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
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil]},
      %{"type" => "discard", "tile" => "5p", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil]}
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
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "daiminkan"}, nil, nil]},
      %{"type" => "discard", "tile" => "5p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil]}
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
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil]}
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
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil]}
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
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil]}
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
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"Four Concealed Pungs", 100}],
        score: 2000
      }
    })
  end

  # TODO
  # - double sequences (+2 each, +4 if concealed)
  # - two suits only (+2)
  # - concealed kong (+4 each, should it also count as a concealed triplet?)
  # - four of a kind bonus (+4 each)
  # and the following are yaku2 wins (which override everything above)
  # - seven pairs (+10)
  # - sea floor win (+15)
  # - luxury seven pairs (+50 if you have a 4 of a kind)
  # - double luxury seven pairs (+100 if you have two 4 of a kinds), probably doesn't stack with above
  # - pure suit (+100 for chinitsu)
  # - three consecutive concealed pungs (+100)
  # - four consecutive concealed pungs (+100), probably stacks with the above
  # - ten identical tiles (+100)
  # - double concealed double sequences (+100)
  # - heavenly win (+200)
  # - earthly win (+150)


end
