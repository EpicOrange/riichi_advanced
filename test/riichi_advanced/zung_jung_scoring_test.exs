defmodule RiichiAdvanced.ZungJungScoringTest do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "zung jung - head bump" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "3p", "3p", "3p", "4z"],
        "south": ["1m", "9m", "1p", "9p", "1s", "9s", "0z", "2z", "3z", "4z", "0z", "6z", "7z"],
        "west": ["1m", "9m", "1p", "9p", "1s", "9s", "6z", "2z", "3z", "4z", "0z", "6z", "7z"],
        "north": ["1m", "9m", "1p", "9p", "1s", "9s", "7z", "2z", "3z", "4z", "0z", "6z", "7z"]
      },
      "starting_draws": ["3p", "1z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "ron"}]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "ron"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ron"}, nil, nil]}
    ], %{
      south: %{
        yaku: [{"Thirteen Terminals", 160}]
      }
    }, %{delta_scores: [-430, 480, -25, -25]})
  end

  test "zung jung - shimocha is responsible for toimen's deal-in" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "3p", "3p", "3p", "4z"],
        "south": ["1m", "9m", "1p", "9p", "1s", "9s", "7z", "2z", "3z", "4z", "0z", "6z", "7z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "4z", "0z", "6z", "7z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "4z", "0z", "6z", "7z"]
      },
      "starting_draws": ["3p", "2z", "2z", "1z", "1z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "2z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ron"}, nil, nil]}
    ], %{
      south: %{
        yaku: [{"Thirteen Terminals", 160}]
      }
    }, %{delta_scores: [-25, 480, -430, -25]})
  end

  test "zung jung - shimocha is responsible for kamicha's deal-in" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "3p", "3p", "3p", "4z"],
        "south": ["1m", "9m", "1p", "9p", "1s", "9s", "7z", "2z", "3z", "4z", "0z", "6z", "7z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "4z", "0z", "6z", "7z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "4z", "0z", "6z", "7z"]
      },
      "starting_draws": ["3p", "2z", "2z", "1z", "1z", "1z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "2z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ron"}, nil, nil]}
    ], %{
      south: %{
        yaku: [{"Thirteen Terminals", 160}]
      }
    }, %{delta_scores: [-25, 480, -430, -25]})
  end

  test "zung jung - toimen is responsible for kamicha's deal-in" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "3p", "3p", "3p", "4z"],
        "south": ["1m", "9m", "1p", "9p", "1s", "9s", "7z", "2z", "3z", "4z", "0z", "6z", "7z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "4z", "0z", "6z", "7z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "4z", "0z", "6z", "7z"]
      },
      "starting_draws": ["3p", "2z", "2z", "2z", "1z", "1z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "2z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ron"}, nil, nil]}
    ], %{
      south: %{
        yaku: [{"Thirteen Terminals", 160}]
      }
    }, %{delta_scores: [-25, 480, -25, -430]})
  end

  test "zung jung - no one is responsible for kamicha's deal-in" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "3p", "3p", "3p", "4z"],
        "south": ["1m", "9m", "1p", "9p", "1s", "9s", "2z", "2z", "3z", "4z", "0z", "6z", "7z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "4z", "0z", "6z", "7z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "4z", "0z", "6z", "7z"]
      },
      "starting_draws": ["3p", "2z", "1z", "1z", "1z", "1z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "2z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ron"}, nil, nil]}
    ], %{
      south: %{
        yaku: [{"Thirteen Terminals", 160}]
      }
    }, %{delta_scores: [-160, 480, -160, -160]})
  end

  test "zung jung - compound limit hand cap at 320 points" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["6p", "6p", "6p", "7p", "7p", "7p", "8p", "8p", "8p", "9p", "9p", "9p", "5p"],
        "south": ["6m", "6m", "1p", "3p", "4p", "1z", "2z", "3z", "4z", "2s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "8m", "1p", "3p", "4p", "1z", "2z", "3z", "4z", "2s", "6s", "7s"],
        "north": ["2m", "7m", "7m", "1p", "3p", "4p", "1z", "2z", "3z", "4z", "2s", "6s", "7s"]
      },
      "starting_draws": ["5p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [
          {"All Triplets", 30},
          {"Blessing of Heaven", 155},
          {"Concealed Hand", 5},
          {"Four Concealed Triplets", 125},
          {"Four Consecutive Triplets", 200},
          {"Pure One-Suit", 80}
        ],
        displayed_score: 320
      }
    }, %{delta_scores: [960, -320, -320, -320]})
  end

  test "zung jung - responsibility with different waits" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "3p", "3p", "3p", "4z"],
        "south": ["1m", "9m", "1p", "9p", "1s", "9s", "1z", "2z", "3z", "4z", "0z", "6z", "7z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "4z", "3z", "3z", "7z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "4z", "0z", "6z", "7z"]
      },
      "starting_draws": ["3p", "3z", "2m", "1z", "3z", "0z", "3z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "3z", "player" => 0, "tsumogiri" => true}, # east responsible for 3z!
      %{"type" => "discard", "tile" => "2m", "player" => 1, "tsumogiri" => true}, # east no longer responsible for 3z
      %{"type" => "discard", "tile" => "1z", "player" => 2, "tsumogiri" => true}, # west responsible for 1z!
      %{"type" => "discard", "tile" => "3z", "player" => 3, "tsumogiri" => true}, # north responsible for 3z!
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "pon"}, nil]},
      %{"type" => "discard", "tile" => "7z", "player" => 2, "tsumogiri" => false}, # west responsible for 1z,7z!
      %{"type" => "discard", "tile" => "0z", "player" => 3, "tsumogiri" => true}, # north responsible for 3z,0z!
      %{"type" => "discard", "tile" => "3z", "player" => 0, "tsumogiri" => true}, # east not responsible for 3z
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ron"}, nil, nil]} # east deals in, north responsible
    ], %{
      south: %{
        yaku: [{"Thirteen Terminals", 160}]
      }
    }, %{delta_scores: [-25, 480, -25, -430]})
  end

end
