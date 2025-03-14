defmodule RiichiAdvanced.ZungJungScoringTest do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "zung jung - shimocha is responsible for toimen's deal-in" do
    TestUtils.test_yaku_advanced("zung_jung", [], """
    {
      "starting_hand": {
        "east": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "3p", "3p", "3p", "4z"],
        "south": ["1m", "9m", "1p", "9p", "1s", "9s", "1z", "2z", "3z", "4z", "0z", "6z", "7z"],
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
        "south": ["1m", "9m", "1p", "9p", "1s", "9s", "1z", "2z", "3z", "4z", "0z", "6z", "7z"],
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
        "south": ["1m", "9m", "1p", "9p", "1s", "9s", "1z", "2z", "3z", "4z", "0z", "6z", "7z"],
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
        score: 320
      }
    }, %{delta_scores: [960, -320, -320, -320]})
  end

end
