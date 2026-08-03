defmodule RiichiAdvanced.CosmicMechanicsTest do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "cosmic - sequences wrap" do
    TestUtils.test_yaku_advanced("cosmic", [], [], """
    {
      "starting_hand": {
        "east": ["9m", "1m", "2m", "8p", "9p", "1p", "1s", "2s", "3s", "7z", "7z", "7z", "6p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "6p"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Chun", [1, "Han"]}],
        minipoints: 40
      }
    })
  end

  test "cosmic - mini-sangen is not enough han" do
    TestUtils.test_yaku_advanced("cosmic", [], [], """
    {
      "starting_hand": {
        "east": ["9m", "1m", "2m", "8p", "9p", "1p", "1s", "2s", "3s", "5z", "6z", "7z", "6p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "6p"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true}
    ], :no_winners)
  end

end
