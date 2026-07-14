defmodule RiichiAdvanced.YakuTest.MCRYaku do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "mcr - not outside hand" do
    TestUtils.test_yaku_advanced("mcr", [], """
    {
      "starting_hand": {
        "east": ["8m", "9m", "1p", "2p", "3p", "6p", "6p", "7p", "8p", "9p", "4s", "5s", "6s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "7m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"All Chows", [2, "Fan"]}, {"Concealed Hand", [2, "Fan"]}, {"Edge Wait", [1, "Fan"]}, {"Mixed Double Chow", [1, "Fan"]}, {"Mixed Straight", [8, "Fan"]}, {"Two Terminal Chows", [0, "Fan"]}]
      }
    })
  end

end
