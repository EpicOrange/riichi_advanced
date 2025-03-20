defmodule RiichiAdvanced.YakuTest.GalaxyYaku do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "galaxy - galaxy jokers work" do
    TestUtils.test_yaku_advanced("galaxy", ["galaxy"], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "14s", "14p", "5m", "6m", "7p", "7p", "17m", "5z", "16z", "1z", "14z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["3p", "1z"]
    }
    """, [
      %{"type" => "discard", "tile" => "3p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Round Wind", 1}, {"Seat Wind", 1}],
        yaku2: [],
        minipoints: 40
      }
    })
  end

  test "galaxy - galaxy jokers should only give one dragon yaku" do
    TestUtils.test_yaku_advanced("galaxy", ["galaxy"], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "4m", "5m", "6m", "7p", "7p", "7p", "8s", "8s", "15z", "16z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "17z"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "17z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: [%{
        yaku: [{"Haku", 1}],
        yaku2: [],
        minipoints: 40
      }, %{
        yaku: [{"Hatsu", 1}],
        yaku2: [],
        minipoints: 40
      }, %{
        yaku: [{"Chun", 1}],
        yaku2: [],
        minipoints: 40
      }, ]
    })
  end

  test "galaxy - galaxy jokers should give the best wind yaku" do
    TestUtils.test_yaku_advanced("galaxy", ["galaxy"], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "4m", "5m", "6m", "7p", "7p", "7p", "8s", "8s", "12z", "13z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["5z", "14z"]
    }
    """, [
      %{"type" => "discard", "tile" => "5z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "14z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: [%{
        yaku: [{"Round Wind", 1}, {"Seat Wind", 1}],
        yaku2: [],
        minipoints: 40
      }]
    })
  end

  test "galaxy - furiten works" do
    TestUtils.test_yaku_advanced("galaxy", ["galaxy"], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "4m", "5m", "6m", "7p", "7p", "7p", "8s", "8s", "12z", "13z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["14z", "1z"]
    }
    """, [
      %{"type" => "discard", "tile" => "14z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 1, "tsumogiri" => true}
    ], :no_winners)
  end

  test "galaxy - milky way" do
    TestUtils.test_yaku_advanced("galaxy", ["galaxy"], """
    {
      "starting_hand": {
        "east": ["13m", "14m", "18m", "19m", "12p", "15p", "16p", "17p", "11s", "18s", "14s", "15z", "16z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["19p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: [%{
        yaku: [],
        yaku2: [{"Tenhou", 1}, {"Milky Way", 1}],
        minipoints: 30
      }]
    })
  end

end
