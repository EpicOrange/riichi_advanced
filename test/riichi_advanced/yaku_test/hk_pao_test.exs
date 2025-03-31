defmodule RiichiAdvanced.YakuTest.HKOSPaoTest do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "hk - daisangen pao ron no split" do
    TestUtils.test_yaku_advanced("hk", ["remove_flowers", "pao_12_tile"], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "4m", "5m", "6m", "7m", "0z", "0z", "6z", "6z", "7z", "7z"],
        "south": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "0z", "6z", "7z", "2m", "1m"],
      "starting_honba": 1
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "0z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "7m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "7z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "5m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "2m", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1m", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Big Three Dragons", 8}, {"Half Flush", 3}]
      }
    }, %{delta_scores: [384, -384, 0, 0]})
  end

  test "hk - daisangen pao with 12 tile pao tsumo" do
    TestUtils.test_yaku_advanced("hk", ["remove_flowers", "pao_12_tile"], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "4m", "4m", "5m", "6m", "7m", "0z", "0z", "6z", "6z", "7z", "7z"],
        "south": ["2m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "2z", "3z", "4z"],
        "west": ["2m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "2z", "3z", "4z"],
        "north": ["3m", "5m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "0z", "6z", "7z", "2m", "4m", "4m", "5m", "6m", "1m"],
      "starting_honba": 1
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "0z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "7m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "7z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "5m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "2m", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4m", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "2m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "4m", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5m", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6m", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"All Triplets", 3}, {"Big Three Dragons", 8}, {"Half Flush", 3}, {"Self Draw", 1}]
      }
    }, %{delta_scores: [768, -384, -384, 0]})
  end

end
