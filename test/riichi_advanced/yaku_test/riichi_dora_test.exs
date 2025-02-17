defmodule RiichiAdvanced.YakuTest.RiichiYaku do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "riichi - dora 3" do
    TestUtils.test_yaku_advanced("riichi", ["yaku/riichi", "dora"], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "4m", "5m", "6m", "7p", "7p", "7p", "8s", "8s", "8s", "6p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6p"],
      "starting_dead_wall": ["1z", "2z", "3z", "4z", "5z", "6p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "riichi"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Double Riichi", 2}, {"Tanyao", 1}, {"Dora", 3}],
        yaku2: [],
        minipoints: 40
      }
    })
  end

  test "riichi - dora 3 with jokers" do
    TestUtils.test_yaku_advanced("riichi", ["yaku/riichi", "dora", "jokers/vietnamese"], """
    {
      "starting_hand": {
        "east": ["0j", "3m", "4m", "4m", "5m", "6m", "7p", "7p", "7p", "8s", "8s", "8s", "5p"],
        "south": ["1m", "2m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "2m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "2m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6p"],
      "starting_dead_wall": ["7z", "2z", "3z", "4z", "5z", "6p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "riichi"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Double Riichi", 2}, {"Tanyao", 1}, {"Dora", 3}],
        yaku2: [],
        minipoints: 40
      }
    })
  end

  test "riichi - aka 2 with jokers" do
    TestUtils.test_yaku_advanced("riichi", ["yaku/riichi", "aka", "jokers/vietnamese"], """
    {
      "starting_hand": {
        "east": ["0j", "3m", "4m", "4m", "0m", "6m", "7p", "7p", "7p", "8s", "8s", "8s", "0p"],
        "south": ["1m", "2m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "2m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "2m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6p"],
      "starting_dead_wall": ["7z", "2z", "3z", "4z", "5z", "6p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "riichi"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Double Riichi", 2}, {"Tanyao", 1}, {"Aka", 2}],
        yaku2: [],
        minipoints: 40
      }
    })
  end

  test "riichi - ura 2 with aka and jokers" do
    TestUtils.test_yaku_advanced("riichi", ["yaku/riichi", "dora", "aka", "ura", "jokers/vietnamese"], """
    {
      "starting_hand": {
        "east": ["0j", "3m", "4m", "4m", "0m", "6m", "7p", "7p", "7p", "8s", "8s", "8s", "0p"],
        "south": ["1m", "2m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "2m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "2m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6p"],
      "starting_dead_wall": ["7z", "2z", "3z", "4z", "4m", "5z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "riichi"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Double Riichi", 2}, {"Tanyao", 1}, {"Aka", 2}, {"Ura", 2}],
        yaku2: [],
        minipoints: 40
      }
    })
  end

end
