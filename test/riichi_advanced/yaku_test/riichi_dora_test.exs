defmodule RiichiAdvanced.YakuTest.RiichiDoraTest do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "riichi - dora 3" do
    TestUtils.test_yaku_advanced("riichi", [%{name: "yaku/riichi", config: %{"bet" => 1000, "drawless" => false}}, %{name: "dora", config: %{"start_indicators" => 1}}], """
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
    TestUtils.test_yaku_advanced("riichi", [%{name: "yaku/riichi", config: %{"bet" => 1000, "drawless" => false}}, %{name: "dora", config: %{"start_indicators" => 1}}, "jokers/vietnamese"], """
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
    TestUtils.test_yaku_advanced("riichi", [%{name: "yaku/riichi", config: %{"bet" => 1000, "drawless" => false}}, %{name: "aka", config: %{"man" => 1, "pin" => 1, "sou" => 1}}, "jokers/vietnamese"], """
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

  test "riichi - it's all aka is also dora" do
    TestUtils.test_yaku_advanced("riichi", [%{name: "yaku/riichi", config: %{"bet" => 1000, "drawless" => false}}, %{name: "dora", config: %{"start_indicators" => 1}}, %{name: "aka", config: %{"man" => 1, "pin" => 1, "sou" => 1}}, "its_all_aka"], """
    {
      "starting_hand": {
        "east": ["02m", "03m", "04m", "04m", "05m", "06m", "07p", "07p", "07p", "08s", "08s", "08s", "06p"],
        "south": ["01m", "02m", "07m", "02p", "05p", "08p", "03s", "06s", "09s", "01z", "02z", "03z", "04z"],
        "west": ["01m", "02m", "07m", "02p", "05p", "08p", "03s", "06s", "09s", "01z", "02z", "03z", "04z"],
        "north": ["01m", "02m", "07m", "02p", "05p", "08p", "03s", "06s", "09s", "01z", "02z", "03z", "04z"]
      },
      "starting_draws": ["01z", "06p"],
      "starting_dead_wall": ["07z", "02z", "03z", "04z", "05z", "04m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "riichi"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "01z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "06p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Double Riichi", 2}, {"Tanyao", 1}, {"Dora", 1}, {"Aka", 14}],
        yaku2: [],
        minipoints: 40
      }
    })
  end

  test "riichi - ura 2 with aka and jokers" do
    TestUtils.test_yaku_advanced("riichi", [%{name: "yaku/riichi", config: %{"bet" => 1000, "drawless" => false}}, %{name: "dora", config: %{"start_indicators" => 1}}, %{name: "aka", config: %{"man" => 1, "pin" => 1, "sou" => 1}}, "ura", "jokers/vietnamese"], """
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

  test "riichi - aka is also dora" do
    TestUtils.test_yaku_advanced("riichi", [%{name: "yaku/riichi", config: %{"bet" => 1000, "drawless" => false}}, %{name: "dora", config: %{"start_indicators" => 1}}, %{name: "aka", config: %{"man" => 1, "pin" => 1, "sou" => 1}}], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "4m", "0m", "6m", "7p", "7p", "7p", "8s", "8s", "8s", "0p"],
        "south": ["1m", "2m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "2m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "2m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6p"],
      "starting_dead_wall": ["7z", "2z", "3z", "4z", "5z", "4m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "riichi"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Double Riichi", 2}, {"Tanyao", 1}, {"Dora", 1}, {"Aka", 2}],
        yaku2: [],
        minipoints: 40
      }
    })
  end

  test "galaxy - no dora" do
    TestUtils.test_yaku_advanced("riichi", ["galaxy", %{name: "dora", config: %{"start_indicators" => 1}}], """
    {
      "starting_hand": {
        "east": ["3p", "4p", "4p", "4p", "5p", "16p", "6s", "17p", "7s", "8s", "13p", "11z", "2z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1p", "2p", "5p", "7p", "13z"],
      "starting_dead_wall": ["1z", "2z", "3z", "4z", "5z", "4z"]
    }
    """, [
      %{"type" => "discard", "tile" => "1p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2p", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7p", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "skip"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Tsumo", 1}],
        yaku2: [],
        minipoints: 40
      }
    })
  end

end
