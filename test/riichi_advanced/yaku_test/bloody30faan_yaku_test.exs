defmodule RiichiAdvanced.YakuTest.Bloody30FaanYaku do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  @typical_yaku [{"Concealed Hand", [1, "Faan"]}, {"Within Seven Tiles", [8, "Faan"]}]
  @typical_yaku_flower [{"Flower", [1, "Faan"]}, {"Concealed Hand", [1, "Faan"]}, {"Within Seven Tiles", [8, "Faan"]}]

  test "b30fj - flower" do
    TestUtils.test_yaku_advanced("bloody30faan", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "5m", "6m", "7m", "16j", "7p", "8p", "4s", "4s", "4s", "1z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["18j", "3m"],
      "starting_dead_wall": ["2m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "joker", "call_choice" => ["18j"]}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "2m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 1, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Flower", [1, "Faan"]} | @typical_yaku]
      }
    })
  end

  test "b30fj - no honors or flowers" do
    TestUtils.test_yaku_advanced("bloody30faan", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "5m", "6m", "7m", "6j", "7p", "8p", "4s", "4s", "4s", "17j"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2m", "9s"]
    }
    """, [
      %{"type" => "discard", "tile" => "2m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "9s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"No Honors or Flowers", [2, "Faan"]} | @typical_yaku]
      }
    })
  end

  test "b30fj - one voided suit" do
    TestUtils.test_yaku_advanced("bloody30faan", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "5m", "6m", "3p", "3p", "5p", "5p", "6j", "7p", "8p", "9p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["18j", "7m"],
      "starting_dead_wall": ["2m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "joker", "call_choice" => ["18j"]}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "2m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"One Voided Suit", [2, "Faan"]} | @typical_yaku_flower]
      }
    })
  end

end
