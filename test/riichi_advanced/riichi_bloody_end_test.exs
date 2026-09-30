defmodule RiichiAdvanced.RiichiBloodyEnd do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "riichi - bloody end three winners" do
    TestUtils.test_yaku_advanced("riichi", ["bloody_end"], [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "4m", "5m", "6m", "7p", "7p", "7p", "8s", "8s", "8s", "6p"],
        "south": ["1m", "2m", "3m", "4m", "5m", "6m", "7m", "8m", "9m", "5z", "5z", "4z", "4z"],
        "west": ["1p", "2p", "3p", "4p", "5p", "6p", "7p", "8p", "9p", "2m", "3m", "3z", "3z"],
        "north": ["1s", "2s", "3s", "4s", "5s", "6s", "7s", "8s", "9s", "2z", "2z", "6z", "6z"]
      },
      "starting_draws": ["1z", "6p", "6z", "6z", "7z", "5z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "riichi"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "6z", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "ron"}]},
      %{"type" => "discard", "tile" => "6z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7z", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "tsumo"}, nil, nil]},
    ], %{
      east: %{
        yaku: [{"Double Riichi", [2, "Han"]}, {"Ippatsu", [1, "Han"]}, {"Tanyao", [1, "Han"]}],
        minipoints: 40
      },
      south: %{
        yaku: [{"Haku", [1, "Han"]}, {"Honitsu", [3, "Han"]}, {"Ittsuu", [2, "Han"]}, {"Tsumo", [1, "Han"]}],
        minipoints: 30
      },
      north: %{
        yaku: [{"Renhou", [1, "★"]}],
        minipoints: 40
      },
    })
  end

  test "riichi - bloody end chankan doesn't cancel kan" do
    TestUtils.test_yaku_advanced("riichi", ["bloody_end"], [], """
    {
      "starting_hand": {
        "east": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "south": ["2m", "3m", "4m", "6m", "7m", "8m", "1s", "2s", "3s", "5p", "1z", "3z", "3z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "2z", "3z", "4z"],
        "north": ["7p", "7p", "1m", "2m", "3m", "4m", "5m", "6m", "7m", "8m", "9m", "5z", "7z"]
      },
      "starting_draws": ["7p", "1z", "6p", "2z", "7p", "6s", "7s", "7z"],
      "starting_dead_wall": ["5s"]
    }
    """, [
      %{"type" => "discard", "tile" => "7p", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "pon"}]},
      %{"type" => "discard", "tile" => "5z", "player" => 3, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 1, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "2z", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "kakan"}]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "chankan"}, nil, nil]},
      %{"type" => "discard", "tile" => "5s", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6s", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7s", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "tsumo"}]},
    ], %{
      south: %{
        yaku: [{"Chankan", [1, "Han"]}, {"Pinfu", [1, "Han"]}],
        minipoints: 30
      },
      north: %{
        yaku: [{"Ittsuu", [1, "Han"]}],
        minipoints: 40
      }
    })
  end

end
