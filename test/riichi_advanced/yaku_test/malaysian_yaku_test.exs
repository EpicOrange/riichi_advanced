defmodule RiichiAdvanced.YakuTest.MalaysianYaku do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  @malaysian_mods [
    "malaysian_five_point_minimum",
    "malaysian_stackable_limit",
    "malaysian_half_flush",
    "malaysian_4_fei_win",
  ]

  test "malaysian - single flowers work" do
    TestUtils.test_yaku_advanced("malaysian", @malaysian_mods, """
    {
      "starting_hand": {
        "east": ["1p", "2p", "3p", "5p", "5p", "5p", "7p", "8p", "9p", "8z", "8z", "8z", "1p"],
        "south": ["1p", "4p", "7p", "2p", "7p", "8p", "3p", "6p", "9p", "1z", "2z", "3z", "4z"],
        "west": ["2p", "4p", "7p", "2p", "8p", "8p", "3p", "6p", "9p", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "2z", "3z", "1g", "1p"],
      "starting_dead_wall": ["1f", "4f", "4g", "3a", "1y", "1z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "1p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil]}
    ], %{
      east: %{
        yaku: [
          {"Face Tiles", [1, "Fan"]},
          {"Animal Tiles", [1, "Fan"]},
          {"Half Flush", [1, "Fan"]},
          {"Seat Flower", [1, "Fan"]},
          {"Fourth Flower", [1, "Fan"]},
          {"Fourth Season", [1, "Fan"]},
          {"Seat Season", [1, "Fan"]},
          {"White Dragon", [1, "Fan"]}
        ],
        score: 3 * 8 * 20,
      }
    })
  end

  test "malaysian - all flowers override fan from individual flowers" do
    TestUtils.test_yaku_advanced("malaysian", @malaysian_mods, """
    {
      "starting_hand": {
        "east": ["1a", "2p", "3p", "5p", "5p", "5p", "7p", "8p", "9p", "8z", "8z", "8z", "1p"],
        "south": ["1p", "4p", "7p", "2p", "7p", "8p", "3p", "6p", "9p", "1z", "2z", "3z", "4z"],
        "west": ["2p", "4p", "7p", "2p", "8p", "8p", "3p", "6p", "9p", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "2z", "3z", "1f", "1p"],
      "starting_dead_wall": ["1p", "2f", "3f", "4f", "1z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil]}
    ], %{
      east: %{
        yaku: [
          {"All Flowers", [4, "Fan"]},
          {"Animal Tiles", [1, "Fan"]},
          {"Half Flush", [1, "Fan"]},
          {"White Dragon", [1, "Fan"]}
        ],
        score: 3 * 7 * 20,
      }
    })
  end

  test "malaysian - every single flower at start" do
    TestUtils.test_yaku_advanced("malaysian", @malaysian_mods, """
    {
      "starting_hand": {
        "east": ["1p", "2p", "3p", "5p", "5p", "5p", "7p", "8p", "9p", "8z", "8z", "8z", "1p"],
        "south": ["1p", "4p", "7p", "2p", "7p", "8p", "3p", "6p", "9p", "1z", "2z", "3z", "4z"],
        "west": ["2p", "4p", "7p", "2p", "8p", "8p", "3p", "6p", "9p", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1f", "2z", "3z", "4z", "1p"],
      "starting_dead_wall": ["2f", "3f", "4f", "1g", "2g", "3g", "4g", "1a", "2a", "3a", "4a", "1y", "1y", "1y", "1y", "1z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil]}
    ], %{
      east: %{
        yaku: [
          {"All Flowers", [4, "Fan"]},
          {"All Seasons", [4, "Fan"]},
          {"All Animals", [5, "Fan"]},
          {"All Faces", [5, "Fan"]},
          {"Half Flush", [1, "Fan"]},
          {"White Dragon", [1, "Fan"]}
        ],
        score: 3 * 10 * 20,
      }
    })
  end

  test "malaysian - 4 fei win" do
    TestUtils.test_yaku_advanced("malaysian", @malaysian_mods, """
    {
      "starting_hand": {
        "east": ["1p", "2p", "3p", "5p", "5p", "5p", "7p", "8p", "9p", "8z", "8z", "8z", "1p"],
        "south": ["1p", "4p", "7p", "2p", "7p", "8p", "3p", "6p", "9p", "1z", "2z", "3z", "4z"],
        "west": ["2p", "4p", "7p", "2p", "8p", "8p", "3p", "6p", "9p", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2y"],
      "starting_dead_wall": ["2y", "2y", "2y"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_joker"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_joker"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_joker"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "four_fei"}, nil, nil]}
    ], %{
      east: %{
        yaku: [
          {"Four Fei", [1, "Limit"]},
        ],
        score: 4 * 10 * 20,
      }
    })
  end

  test "malaysian - kokushi" do
    TestUtils.test_yaku_advanced("malaysian", @malaysian_mods, """
    {
      "starting_hand": {
        "east": ["1a", "9p", "2y", "2y", "2y", "2y", "1z", "2z", "3z", "4z", "8z", "6z", "7z"],
        "south": ["1p", "4p", "7p", "2p", "7p", "8p", "3p", "6p", "9p", "1z", "2z", "3z", "4z"],
        "west": ["2p", "4p", "7p", "2p", "8p", "8p", "3p", "6p", "9p", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2p", "1p"],
      "starting_dead_wall": ["1p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "2p", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "1p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil]}
    ], %{
      east: %{
        yaku: [
          {"Thirteen Orphans", [1, "Limit"]},
        ],
        score: 3 * 10 * 20,
      }
    })
  end

  test "malaysian - white dragon via fei joker" do
    TestUtils.test_yaku_advanced("malaysian", @malaysian_mods, """
    {
      "starting_hand": {
        "east": ["2p", "3p", "4p", "5p", "5p", "5p", "6p", "7p", "7p", "8p", "9p", "8z", "2y"],
        "south": ["1p", "4p", "7p", "2p", "5p", "8p", "3p", "6p", "9p", "1z", "2z", "3z", "4z"],
        "west": ["2p", "4p", "7p", "2p", "8p", "8p", "3p", "6p", "9p", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1f", "4p", "8z"],
      "starting_dead_wall": ["1y", "1a", "3p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "3p", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "4p", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8z", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil]}
    ], %{
      east: %{
        yaku: [
          {"Half Flush", [1, "Fan"]},
          {"Animal Tiles", [1, "Fan"]},
          {"Face Tiles", [1, "Fan"]},
          {"Seat Flower", [1, "Fan"]},
          {"White Dragon", [1, "Fan"]}
        ],
        score: 3 * 5 * 20,
      }
    })
  end

  test "malaysian - winds" do
    TestUtils.test_yaku_advanced("malaysian", @malaysian_mods, """
    {
      "starting_hand": {
        "east": ["1p", "4p", "7p", "2p", "7p", "8p", "3p", "6p", "9p", "6z", "6z", "7z", "7z"],
        "south": ["1a", "1z", "1z", "2z", "2z", "2z", "4z", "4z", "4z", "1p", "1p", "4p", "5p"],
        "west": ["2p", "4p", "7p", "2p", "8p", "8p", "3p", "6p", "9p", "6z", "6z", "7z", "7z"]
      },
      "starting_draws": ["3p", "3p", "6p"],
      "starting_dead_wall": ["1z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "3p", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "3p", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ron"}, nil]}
    ], %{
      south: %{
        yaku: [
          {"Animal Tiles", [1, "Fan"]},
          {"East Wind", [1, "Fan"]},
          {"North Wind", [1, "Fan"]},
          {"Seat Wind", [1, "Fan"]},
          {"Half Flush", [1, "Fan"]},
        ],
        score: 3 * 5 * 20,
      }
    })
  end

  # TODO: all the other yaku, plus different mods

end
