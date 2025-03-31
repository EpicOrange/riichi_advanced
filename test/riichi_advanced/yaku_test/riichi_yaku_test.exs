defmodule RiichiAdvanced.YakuTest.RiichiYaku do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "riichi - double riichi ippatsu" do
    TestUtils.test_yaku_advanced("riichi", [%{name: "yaku/riichi", config: %{"bet" => 1000, "drawless" => false}}, "yaku/ippatsu"], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "4m", "5m", "6m", "7p", "7p", "7p", "8s", "8s", "8s", "6p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "riichi"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Double Riichi", 2}, {"Ippatsu", 1}, {"Tanyao", 1}],
        yaku2: [],
        minipoints: 40
      }
    })
  end

  test "riichi - double riichi ippatsu tsumo" do
    TestUtils.test_yaku_advanced("riichi", [%{name: "yaku/riichi", config: %{"bet" => 1000, "drawless" => false}}, "yaku/ippatsu"], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "4m", "5m", "6m", "7p", "7p", "7p", "8s", "8s", "8s", "6p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "2z", "3z", "4z", "6p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "riichi"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4z", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Double Riichi", 2}, {"Ippatsu", 1}, {"Tsumo", 1}, {"Tanyao", 1}],
        yaku2: [],
        minipoints: 40
      }
    })
  end
 
  test "riichi - ippatsu shouldn't be awarded if riichi tile gets called" do
    TestUtils.test_yaku_advanced("riichi", [%{name: "yaku/riichi", config: %{"bet" => 1000, "drawless" => false}}, "yaku/ippatsu"], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "4m", "5m", "6m", "7p", "7p", "7p", "8s", "8s", "8s", "6p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "5z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "5z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "1z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "riichi"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "pon"}]},
      %{"type" => "discard", "tile" => "3z", "player" => 3, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Double Riichi", 2}, {"Tsumo", 1}, {"Tanyao", 1}],
        yaku2: [],
        minipoints: 40
      }
    })
  end

  test "riichi - tanyao nomi" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "4m", "5m", "6m", "7p", "7p", "7p", "8s", "8s", "8s", "6p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6p"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Tanyao", 1}],
        yaku2: [],
        minipoints: 40
      }
    })
  end

  test "riichi - open tanyao sanshoku" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "2s", "3s", "4s", "2p", "3p", "4p", "7m", "5m", "5m", "1z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "8m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "5m", "7m"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "7m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Tanyao", 1}, {"Sanshoku", 1}],
        yaku2: [],
        minipoints: 30
      }
    })
  end

  test "riichi - non-pinfu closed tsumo sanshoku" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "2s", "3s", "4s", "2p", "3p", "4p", "7m", "7m", "8m", "9m"],
        "south": ["1m", "4m", "8m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "8m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "8m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "2z", "3z", "4z", "7m"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4z", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Tsumo", 1}, {"Sanshoku", 2}],
        yaku2: [],
        minipoints: 30
      }
    })
  end

  test "riichi - pinfu tsumo" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "2s", "3s", "4s", "2p", "3p", "4p", "7m", "8m", "9m", "9m"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "2z", "3z", "4z", "9m"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4z", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Tsumo", 1}, {"Pinfu", 1}, {"Sanshoku", 2}],
        yaku2: [],
        minipoints: 20
      }
    })
  end

  test "riichi - pinfu chankan" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "south": ["2m", "3m", "4m", "6m", "7m", "8m", "1s", "2s", "3s", "5p", "1z", "3z", "3z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "2z", "3z", "4z"],
        "north": ["7p", "7p", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "5z", "5z", "7z", "7z"]
      },
      "starting_draws": ["7p", "1z", "6p", "2z", "7p"]
    }
    """, [
      %{"type" => "discard", "tile" => "7p", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "pon"}]},
      %{"type" => "discard", "tile" => "5z", "player" => 3, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 1, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "2z", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "kakan"}]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "chankan"}, nil, nil]}
    ], %{
      south: %{
        yaku: [{"Chankan", 1}, {"Pinfu", 1}],
        yaku2: [],
        minipoints: 30
      }
    })
  end

  test "riichi - kokushi chankan" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "3z", "3z", "5z"],
        "south": ["1m", "9m", "1p", "9p", "1s", "9s", "2z", "2z", "3z", "4z", "5z", "6z", "7z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "4z", "4z", "4z"],
        "north": ["1z", "1z", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "5z", "5z", "7z", "7z"]
      },
      "starting_draws": ["1z", "5m", "6p", "6p", "1z"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "pon"}]},
      %{"type" => "discard", "tile" => "5z", "player" => 3, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "kakan"}]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "chankan"}, nil, nil]}
    ], %{
      south: %{
        yaku: [],
        yaku2: [{"Kokushi Musou", 1}],
        minipoints: 40
      }
    })
  end

  test "riichi - kokushi ankan chankan" do
    TestUtils.test_yaku_advanced("riichi", ["kokushi_ankan_chankan"], """
    {
      "starting_hand": {
        "east": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "3z", "3z", "5z"],
        "south": ["1m", "9m", "1p", "9p", "1s", "9s", "2z", "2z", "3z", "4z", "5z", "6z", "7z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "4z", "4z", "4z"],
        "north": ["1z", "1z", "1z", "2p", "5p", "8p", "3s", "6s", "9s", "5z", "5z", "7z", "7z"]
      },
      "starting_draws": ["5m", "6p", "6p", "1z"]
    }
    """, [
      %{"type" => "discard", "tile" => "5m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "ankan"}]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "chankan"}, nil, nil]}
    ], %{
      south: %{
        yaku: [],
        yaku2: [{"Kokushi Musou", 1}],
        minipoints: 40
      }
    })
  end

  test "riichi - rinshan" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["6m", "7m", "8m", "5p", "6p", "7p", "8p", "9p", "9p", "9p", "2m", "2m", "2m"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "2m"],
      "starting_dead_wall": ["7p"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "daiminkan"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Rinshan", 1}],
        yaku2: [],
        minipoints: 40
      }
    })
  end

  test "riichi - double east" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "1z", "1z", "1z", "5p", "5p", "7p", "8p", "2p", "3p", "4z"],
        "south": ["2m", "4m", "7m", "2p", "6p", "8p", "3s", "6s", "9s", "2z", "4z", "5z", "7z"],
        "west": ["2m", "4m", "7m", "2p", "6p", "8p", "3s", "6s", "9s", "2z", "4z", "5z", "7z"],
        "north": ["2m", "4m", "7m", "2p", "6p", "8p", "3s", "6s", "9s", "2z", "4z", "5z", "7z"]
      },
      "starting_draws": ["3z", "3z", "3z", "4p", "6p"]
    }
    """, [
      %{"type" => "discard", "tile" => "3z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4p", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii", "call_choice" => ["2p", "3p"], "called_tile" => "4p"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "4z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Round Wind", 1}, {"Seat Wind", 1}],
        yaku2: [],
        minipoints: 30
      }
    })
  end

  test "riichi - south round east wind" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "1z", "1z", "1z", "5p", "5p", "7p", "8p", "2p", "3p", "4z"],
        "south": ["1m", "4m", "7m", "2p", "6p", "8p", "3s", "6s", "9s", "2z", "4z", "5z", "6z"],
        "west": ["1m", "4m", "7m", "2p", "6p", "8p", "3s", "6s", "9s", "2z", "4z", "5z", "6z"],
        "north": ["1m", "4m", "7m", "2p", "6p", "8p", "3s", "6s", "9s", "2z", "4z", "5z", "6z"]
      },
      "starting_draws": ["3z", "3z", "3z", "4p", "6p"],
      "starting_round": 4
    }
    """, [
      %{"type" => "discard", "tile" => "3z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4p", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii", "call_choice" => ["2p", "3p"], "called_tile" => "4p"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "4z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Seat Wind", 1}],
        yaku2: [],
        minipoints: 30
      }
    })
  end

  test "riichi - south round double south" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["2m", "4m", "7m", "2p", "6p", "8p", "3s", "6s", "9s", "1z", "4z", "5z", "6z"],
        "south": ["1m", "2m", "3m", "2z", "2z", "2z", "5p", "5p", "7p", "8p", "2p", "3p", "4z"],
        "west": ["2m", "4m", "7m", "2p", "6p", "8p", "3s", "6s", "9s", "1z", "4z", "5z", "6z"],
        "north": ["2m", "4m", "7m", "2p", "6p", "8p", "3s", "6s", "9s", "1z", "4z", "5z", "6z"]
      },
      "starting_draws": ["3z", "3z", "3z", "3z", "4p", "6p"],
      "starting_round": 4
    }
    """, [
      %{"type" => "discard", "tile" => "3z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4p", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "chii", "call_choice" => ["2p", "3p"], "called_tile" => "4p"}, nil, nil]},
      %{"type" => "discard", "tile" => "4z", "player" => 1, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6p", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ron"}, nil, nil]}
    ], %{
      south: %{
        yaku: [{"Round Wind", 1}, {"Seat Wind", 1}],
        yaku2: [],
        minipoints: 30
      }
    })
  end

  test "riichi - open iipeikou chun" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["4m", "8m", "1p", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "4z", "5z"],
        "south": ["7z", "7z", "7z", "1m", "1m", "2m", "2m", "3m", "7m", "7m", "2p", "3p", "4z"],
        "west": ["4m", "8m", "1p", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "4z", "5z"],
        "north": ["4m", "8m", "1p", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "4z", "5z"]
      },
      "starting_draws": ["3z", "3z", "3z", "3z", "4p", "3m"]
    }
    """, [
      %{"type" => "discard", "tile" => "3z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4p", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "chii"}, nil, nil]},
      %{"type" => "discard", "tile" => "4z", "player" => 1, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "3m", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ron"}, nil, nil]}
    ], %{
      south: %{
        yaku: [{"Chun", 1}],
        yaku2: [],
        minipoints: 30
      }
    })
  end

  test "riichi - closed iipeikou chun" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["7z", "7z", "7z", "1m", "1m", "2m", "2m", "3m", "7m", "7m", "2p", "3p", "4p"],
        "south": ["4m", "8m", "1p", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["4m", "8m", "1p", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["4m", "8m", "1p", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["3z", "3m"]
    }
    """, [
      %{"type" => "discard", "tile" => "3z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Iipeikou", 1}, {"Chun", 1}],
        yaku2: [],
        minipoints: 40
      }
    })
  end

  test "riichi - chiitoitsu" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["1m", "1m", "4m", "4m", "5m", "5m", "2p", "2p", "4p", "6s", "6s", "1z", "1z"],
        "south": ["2m", "3m", "7m", "3p", "5p", "8p", "3s", "7s", "9s", "2z", "3z", "4z", "5z"],
        "west": ["2m", "3m", "7m", "3p", "5p", "8p", "3s", "7s", "9s", "2z", "3z", "4z", "5z"],
        "north": ["2m", "3m", "7m", "3p", "5p", "8p", "3s", "7s", "9s", "2z", "3z", "4z", "5z"]
      },
      "starting_draws": ["3z", "4p"]
    }
    """, [
      %{"type" => "discard", "tile" => "3z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Chiitoitsu", 2}],
        yaku2: [],
        minipoints: 25
      }
    })
  end

  test "riichi - ryanpeikou with quad" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["1m", "1m", "2m", "2m", "3m", "3m", "3m", "4m", "4m", "5m", "5m", "1s", "1s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["2m", "5m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["2m", "5m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["3z", "3m"]
    }
    """, [
      %{"type" => "discard", "tile" => "3z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Pinfu", 1}, {"Ryanpeikou", 3}],
        yaku2: [],
        minipoints: 30
      }
    })
  end

  test "riichi - ryanpeikou with closed quad" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["1m", "1m", "2m", "2m", "3m", "3m", "3m", "3m", "4m", "5m", "5m", "1s", "1s"],
        "south": ["7m", "2p", "5p", "8p", "2s", "3s", "4s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["7m", "2p", "5p", "8p", "2s", "3s", "4s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["7m", "2p", "5p", "8p", "2s", "3s", "4s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["3z", "4m"]
    }
    """, [
      %{"type" => "discard", "tile" => "3z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Ryanpeikou", 3}],
        yaku2: [],
        minipoints: 40
      }
    })
  end

  test "riichi - daisharin" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["2p", "2p", "3p", "3p", "4p", "4p", "5p", "5p", "6p", "6p", "7p", "7p", "8p"],
        "south": ["1m", "2m", "3m", "4m", "5m", "7m", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "2m", "3m", "4m", "5m", "7m", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "2m", "3m", "4m", "5m", "7m", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["3z", "8p"]
    }
    """, [
      %{"type" => "discard", "tile" => "3z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Pinfu", 1}, {"Tanyao", 1}, {"Ryanpeikou", 3}, {"Chinitsu", 6}],
        yaku2: [],
        minipoints: 30
      }
    })
  end

  test "riichi - open chanta sanshoku" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["1p", "2p", "3p", "1s", "2s", "3s", "7p", "8p", "2z", "2z", "1m", "2m", "1z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "3z", "4z", "5z", "6z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "3z", "4z", "5z", "6z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "3z", "4z", "5z", "6z"]
      },
      "starting_draws": ["1z", "1z", "1z", "3m", "9p"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3m", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "9p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Chanta", 1}, {"Sanshoku", 1}],
        yaku2: [],
        minipoints: 30
      }
    })
  end

  test "riichi - closed chanta" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["1p", "2p", "3p", "1s", "2s", "3s", "7p", "8p", "9s", "9s", "9s", "2z", "2z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "3z", "4z", "5z"]
      },
      "starting_draws": ["1z", "9p"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "9p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Chanta", 2}],
        yaku2: [],
        minipoints: 40
      }
    })
  end

  test "riichi - chanta/junchan should consider all possibilities" do
    # basically it shouldn't remove 111s before 123s
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "1z", "7m", "8m", "9m", "7p", "8p", "9p", "1s", "1s", "1s", "3s"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "7s"]
      },
      "starting_draws": ["6m", "2z", "3z", "3m", "2s"]
    }
    """, [
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3m", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "2s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Junchan", 2}]
      }
    })
  end

  test "riichi - open junchan" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["1m", "1m", "1s", "2s", "3s", "7p", "8p", "9s", "9s", "9s", "1p", "2p", "1z"],
        "south": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "2z", "3z", "4z", "5z"],
        "west": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "2z", "3z", "4z", "5z"],
        "north": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "2z", "3z", "4z", "5z"]
      },
      "starting_draws": ["1z", "1z", "1z", "3p", "9p"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "9p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Junchan", 2}],
        yaku2: [],
        minipoints: 30
      }
    })
  end

  test "riichi - closed junchan" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["1m", "1m", "1p", "2p", "3p", "1s", "2s", "3s", "7p", "8p", "9s", "9s", "9s"],
        "south": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "2z", "3z", "4z"],
        "west": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "2z", "3z", "4z"],
        "north": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "9p"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "9p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Junchan", 3}],
        yaku2: [],
        minipoints: 40
      }
    })
  end

  test "riichi - open ittsu" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["1m", "1m", "1p", "2p", "4p", "5p", "6p", "7p", "8p", "8p", "9p", "1z", "2z"],
        "south": ["2m", "4m", "7m", "2p", "5p", "9p", "3s", "6s", "9s", "3z", "4z", "5z", "7z"],
        "west": ["2m", "4m", "7m", "2p", "5p", "9p", "3s", "6s", "9s", "3z", "4z", "5z", "7z"],
        "north": ["2m", "4m", "7m", "2p", "5p", "9p", "3s", "6s", "9s", "3z", "4z", "5z", "7z"]
      },
      "starting_draws": ["1z", "2z", "3z", "3p", "1z", "1z", "7p", "6p"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii", "call_choice" => ["1p", "2p"], "called_tile" => "3p"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "1z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7p", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii", "call_choice" => ["8p", "9p"], "called_tile" => "7p"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "2z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Ittsu", 1}],
        yaku2: [],
        minipoints: 30
      }
    })
  end

  test "riichi - closed ittsu" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "4m", "5m", "6m", "7m", "8m", "7p", "8p", "9p", "9s", "9s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "9m"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "9m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Pinfu", 1}, {"Ittsu", 2}],
        yaku2: [],
        minipoints: 30
      }
    })
  end

  test "riichi - sanshoku doukou" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["2m", "2m", "2m", "8p", "9p", "9s", "9s", "2p", "2p", "1z", "2s", "2s", "2z"],
        "south": ["1m", "4m", "7m", "3p", "5p", "8p", "3s", "6s", "8s", "2z", "3z", "4z", "5z"],
        "west": ["1m", "4m", "7m", "3p", "5p", "8p", "3s", "6s", "8s", "2z", "3z", "4z", "5z"],
        "north": ["1m", "4m", "7m", "3p", "5p", "8p", "3s", "6s", "8s", "2z", "3z", "4z", "5z"]
      },
      "starting_draws": ["1z", "2p", "2s", "7p"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "2s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "2z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "7p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Sanshoku Doukou", 2}],
        yaku2: [],
        minipoints: 30
      }
    })
  end

  test "riichi - sankantsu" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["8p", "9p", "9s", "9s", "2p", "2p", "2p", "2m", "2m", "1z", "7z", "7z", "7z"],
        "south": ["1m", "4m", "7m", "3p", "5p", "8p", "3s", "6s", "9s", "2z", "3z", "4z", "5z"],
        "west": ["1m", "4m", "7m", "3p", "5p", "8p", "3s", "6s", "9s", "2z", "3z", "4z", "5z"],
        "north": ["1m", "4m", "7m", "3p", "5p", "8p", "3s", "6s", "8s", "2z", "3z", "4z", "5z"]
      },
      "starting_draws": ["7z", "2p", "2m", "2z", "3z", "4z", "2m", "7p"],
      "starting_dead_wall": ["6z", "6z", "1z", "1z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "daiminkan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4z", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "kakan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Chun", 1}, {"Sankantsu", 2}],
        yaku2: [],
        minipoints: 70
      }
    })
  end

  test "riichi - open toitoi shousangen honitsu" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["7p", "7p", "9s", "9s", "9s", "6z", "6z", "5z", "5z", "5z", "7z", "7z", "1z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "1s", "3s", "6s", "8s", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "1s", "3s", "6s", "8s", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "1s", "3s", "6s", "8s", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "5z", "7z", "7p"],
      "starting_dead_wall": ["1z"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "daiminkan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "7p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Haku", 1}, {"Chun", 1}, {"Toitoi", 2}, {"Shousangen", 2}],
        yaku2: [],
        minipoints: 60
      }
    })
  end

  test "riichi - closed honitsu honroutou" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["1m", "1m", "1m", "9m", "9m", "9m", "2z", "2z", "2z", "3z", "3z", "5z", "5z"],
        "south": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "4z", "6z", "7z"],
        "west": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "4z", "6z", "7z"],
        "north": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "4z", "6z", "7z"]
      },
      "starting_draws": ["1z", "5z"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Haku", 1}, {"Toitoi", 2}, {"Sanankou", 2}, {"Honroutou", 2}, {"Honitsu", 3}],
        yaku2: [],
        minipoints: 60
      }
    })
  end

  test "riichi - sanankou open one pon" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["1m", "1m", "1m", "7s", "7s", "7s", "3z", "3z", "5z", "5z", "2p", "2p", "1z"],
        "south": ["2m", "4m", "7m", "3p", "5p", "8p", "3s", "6s", "8s", "9s", "4z", "6z", "7z"],
        "west": ["2m", "4m", "7m", "3p", "5p", "8p", "3s", "6s", "8s", "9s", "4z", "6z", "7z"],
        "north": ["2m", "4m", "7m", "3p", "5p", "8p", "3s", "6s", "8s", "9s", "4z", "6z", "7z"]
      },
      "starting_draws": ["1z", "2p", "2z", "3z", "4z", "3z"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4z", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Toitoi", 2}, {"Sanankou", 2}],
        yaku2: [],
        minipoints: 50
      }
    })
  end

  test "riichi - sanankou open one chii" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["1m", "1m", "1m", "7s", "7s", "7s", "3z", "3z", "5z", "5z", "2p", "3p", "1z"],
        "south": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "9s", "4z", "6z", "7z"],
        "west": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "9s", "4z", "6z", "7z"],
        "north": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "9s", "4z", "6z", "7z"]
      },
      "starting_draws": ["1z", "2z", "3z", "4p", "2z", "2z", "1p", "3z"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4p", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1p", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Sanankou", 2}],
        yaku2: [],
        minipoints: 50
      }
    })
  end

  test "riichi - sanankou after completing sequence" do
    # tsumo = 22 fu
    # ankan 2p = 16 fu
    # closed 1m = 8 fu
    # closed 3z = 8 fu
    # yakuhai 5z pair = 2 fu
    # total 56 = 60 fu
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["1m", "1m", "1m", "7s", "8s", "3z", "3z", "3z", "5z", "5z", "2p", "2p", "2p"],
        "south": ["1m", "4m", "7m", "3p", "5p", "8p", "3s", "6s", "9s", "2z", "4z", "6z", "7z"],
        "west": ["2m", "4m", "7m", "3p", "5p", "8p", "3s", "6s", "9s", "2z", "4z", "6z", "7z"],
        "north": ["2m", "4m", "7m", "3p", "5p", "8p", "3s", "6s", "9s", "2z", "4z", "6z", "7z"]
      },
      "starting_draws": ["2p", "1z", "1z", "1z", "9s"],
      "starting_dead_wall": ["1z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Tsumo", 1}, {"Sanankou", 2}],
        yaku2: [],
        minipoints: 60
      }
    })
  end

  test "riichi - haitei" do
    draws = List.duplicate("5p", 70) |> List.replace_at(1, "4s") |> List.replace_at(69, "3z")
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["4m", "4m", "4m", "6m", "7m", "8m", "1p", "1p", "3z", "3z", "4s", "4s", "1z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": [#{draws |> Enum.map(&"\"" <> &1 <> "\"") |> Enum.intersperse(", ") |> Enum.join()}]
    }
    """, [
      %{"type" => "discard", "tile" => "5p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false}
    ] ++ Enum.take(Stream.cycle([
      %{"type" => "discard", "tile" => "5p", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5p", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5p", "player" => 0, "tsumogiri" => true}
    ]), 67) ++ [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Haitei", 1}],
        yaku2: [],
        minipoints: 40
      }
    })
  end

  test "riichi - houtei" do
    draws = List.duplicate("5p", 70) |> List.replace_at(3, "4s") |> List.replace_at(69, "3z")
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["4m", "4m", "4m", "6m", "7m", "8m", "1p", "1p", "3z", "3z", "2s", "3s", "1z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": [#{draws |> Enum.map(&"\"" <> &1 <> "\"") |> Enum.intersperse(", ") |> Enum.join()}]
    }
    """, [
      %{"type" => "discard", "tile" => "5p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5p", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4s", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false}
    ] ++ Enum.take(Stream.cycle([
      %{"type" => "discard", "tile" => "5p", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5p", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5p", "player" => 0, "tsumogiri" => true}
    ]), 65) ++ [
      %{"type" => "discard", "tile" => "3z", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Houtei", 1}],
        yaku2: [],
        minipoints: 30
      }
    })
  end

  test "riichi - daisangen tsuuiisou suuankou" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["5z", "5z", "5z", "6z", "6z", "6z", "2z", "2z", "3z", "3z", "7z", "7z", "7z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "7s", "8s", "9s", "1z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "7s", "8s", "9s", "1z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "7s", "8s", "9s", "1z", "4z"]
      },
      "starting_draws": ["7z"],
      "starting_dead_wall": ["2z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku2: [{"Daisangen", 1}, {"Suuankou", 1}, {"Tsuuiisou", 1}]
      }
    })
  end

  test "riichi - suuankou with tenhou (upgrades into tanki)" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["5m", "5m", "5m", "7m", "7m", "7m", "2p", "2p", "7s", "7s", "1s", "1s", "1s"],
        "south": ["1m", "4m", "8m", "3p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "8m", "3p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "8m", "3p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku2: [{"Tenhou", 1}, {"Suuankou Tanki", 2}]
      }
    })
  end

  test "riichi - suuankou with chiihou (no upgrade)" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["1m", "4m", "8m", "3p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "south": ["5m", "5m", "5m", "7m", "7m", "7m", "2p", "2p", "7s", "7s", "1s", "1s", "1s"],
        "west": ["1m", "4m", "8m", "3p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "8m", "3p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "2p"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "tsumo"}, nil, nil]}
    ], %{
      south: %{
        yaku2: [{"Chiihou", 1}, {"Suuankou", 1}]
      }
    })
  end

  test "riichi - typical open ryuuiisou" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["2s", "2s", "3s", "3s", "3s", "4s", "4s", "4s", "6z", "6z", "6s", "6s", "7z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "5s", "7s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "5s", "7s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "5s", "7s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6s", "2s"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "7z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "2s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku2: [{"Ryuuiisou", 1}]
      }
    })
  end

  test "riichi - open chinroutou" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["1m", "1m", "1m", "1p", "1p", "1p", "9p", "9p", "9s", "9s", "1s", "1s", "7z"],
        "south": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "2z", "3z", "4z"],
        "west": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "2z", "3z", "4z"],
        "north": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "1s", "9s"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "7z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "9s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku2: [{"Chinroutou", 1}]
      }
    })
  end

  test "riichi - closed chuurenpoutou" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["1m", "1m", "1m", "2m", "3m", "4m", "5m", "7m", "7m", "8m", "9m", "9m", "9m"],
        "south": ["2m", "4m", "8m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["2m", "4m", "8m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["2m", "4m", "8m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6m"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku2: [{"Chuurenpoutou", 1}]
      }
    })
  end

  test "riichi - junsei chuurenpoutou" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["1m", "1m", "1m", "2m", "3m", "4m", "5m", "6m", "7m", "8m", "9m", "9m", "9m"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6m"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku2: [{"Junsei Chuurenpoutou", 2}]
      }
    })
  end

  test "riichi - chuurenpoutou with tenhou (upgrades into junsei)" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["1m", "1m", "1m", "2m", "3m", "4m", "5m", "7m", "7m", "8m", "9m", "9m", "9m"],
        "south": ["2m", "4m", "8m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["2m", "4m", "8m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["2m", "4m", "8m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku2: [{"Tenhou", 1}, {"Junsei Chuurenpoutou", 2}]
      }
    })
  end

  test "riichi - chuurenpoutou with chiihou (no upgrade)" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["2m", "4m", "8m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "south": ["1m", "1m", "1m", "2m", "3m", "4m", "5m", "7m", "7m", "8m", "9m", "9m", "9m"],
        "west": ["2m", "4m", "8m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["2m", "4m", "8m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6m"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "tsumo"}, nil, nil]}
    ], %{
      south: %{
        yaku2: [{"Chiihou", 1}, {"Chuurenpoutou", 1}]
      }
    })
  end

  test "riichi - juusan kokushi" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "south": ["1m", "9m", "1p", "9p", "1s", "9s", "1z", "2z", "3z", "4z", "5z", "6z", "7z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "3z", "4z", "5z"]
      },
      "starting_draws": ["1z"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ron"}, nil, nil]}
    ], %{
      south: %{
        yaku2: [{"Kokushi Musou Juusan Menmachi", 2}]
      }
    })
  end

  test "riichi - kokushi with tenhou (upgrades into juusan)" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["1m", "9m", "1p", "9p", "1s", "9s", "1z", "1z", "3z", "4z", "5z", "6z", "7z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "3z", "4z", "5z"]
      },
      "starting_draws": ["2z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku2: [{"Tenhou", 1}, {"Kokushi Musou Juusan Menmachi", 2}]
      }
    })
  end

  test "riichi - kokushi with chiihou (no upgrade)" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "3z", "4z", "5z"],
        "south": ["1m", "9m", "1p", "9p", "1s", "9s", "1z", "1z", "3z", "4z", "5z", "6z", "7z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "3z", "4z", "5z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "3z", "4z", "5z"]
      },
      "starting_draws": ["5m", "2z"]
    }
    """, [
      %{"type" => "discard", "tile" => "5m", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "tsumo"}, nil, nil]}
    ], %{
      south: %{
        yaku2: [{"Chiihou", 1}, {"Kokushi Musou", 1}]
      }
    })
  end

  test "riichi - daisuushii suukantsu" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["1z", "1z", "1z", "2z", "2z", "2z", "3z", "3z", "3z", "4z", "4z", "5m", "1p"],
        "south": ["1m", "9m", "1p", "9p", "1s", "2s", "3s", "9s", "5z", "6z", "7z", "7z", "7z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "4s", "5s", "6s", "7s", "8s", "9s"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "4s", "5s", "6s", "7s", "8s", "9s"]
      },
      "starting_draws": ["1z", "2z", "3z", "4z", "2m", "3m", "4m", "4z"],
      "starting_dead_wall": ["5m", "5m", "5m", "1p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "5m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "daiminkan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "5m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "daiminkan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "5m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "5m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "2m", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3m", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4m", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "kakan"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku2: [{"Daisuushii", 2}, {"Suukantsu", 1}]
      }
    })
  end

  test "riichi - shousuushii tsuuiisou" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["1z", "1z", "1z", "2z", "2z", "2z", "3z", "3z", "4z", "4z", "4z", "5z", "5z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "4s", "5s", "6s", "7s", "8s", "9s"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "4s", "5s", "6s", "7s", "8s", "9s"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "4s", "5s", "6s", "7s", "8s", "9s"]
      },
      "starting_draws": ["5m", "5z"]
    }
    """, [
      %{"type" => "discard", "tile" => "5m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku2: [{"Tsuuiisou", 1}, {"Shousuushii", 1}]
      }
    })
  end

  test "riichi - dragons triple ron" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["6m", "7m", "8m", "7p", "9p", "9p", "9p", "5s", "6s", "7s", "2m", "2m", "2m"],
        "south": ["1m", "2m", "3m", "4m", "5m", "6m", "7m", "8m", "9m", "1z", "6z", "5z", "5z"],
        "west": ["1p", "2p", "3p", "4p", "5p", "6p", "7p", "8p", "9p", "1z", "7z", "6z", "6z"],
        "north": ["1s", "2s", "3s", "4s", "5s", "6s", "7s", "8s", "9s", "1z", "2z", "7z", "7z"]
      },
      "starting_draws": ["5z", "1z"],
      "starting_dead_wall": ["1p"]
    }
    """, [
      %{"type" => "discard", "tile" => "5z", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "pon"}, nil, nil]},
      %{"type" => "discard", "tile" => "6z", "player" => 1, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "pon"}, nil]},
      %{"type" => "discard", "tile" => "7z", "player" => 2, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "pon"}]},
      %{"type" => "discard", "tile" => "2z", "player" => 3, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ron"}, %{"button" => "ron"}, %{"button" => "ron"}]}
    ], %{
      south: %{
        yaku: [{"Honitsu", 2}, {"Ittsu", 1}, {"Haku", 1}]
      },
      west: %{
        yaku: [{"Honitsu", 2}, {"Ittsu", 1}, {"Hatsu", 1}]
      },
      north: %{
        yaku: [{"Honitsu", 2}, {"Ittsu", 1}, {"Chun", 1}]
      }
    })
  end

  test "riichi - yakuless closed" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "2s", "2s", "2s", "7s", "8s", "9s", "4p", "5p", "6p", "6p", "6p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "4s", "5s", "6s", "7s", "8s", "9s"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "4s", "5s", "6s", "7s", "8s", "9s"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "4s", "5s", "6s", "7s", "8s", "9s"]
      },
      "starting_draws": ["5m", "1m"]
    }
    """, [
      %{"type" => "discard", "tile" => "5m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [],
        minipoints: 40
      }
    })
  end

  test "riichi - yakuless open pinfu" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "6m", "7m", "8m", "5p", "5p", "7p", "8p", "2p", "3p", "1z"],
        "south": ["1m", "4m", "7m", "2p", "3p", "8p", "3s", "4s", "5s", "6s", "7s", "8s", "9s"],
        "west": ["1m", "4m", "7m", "2p", "3p", "8p", "3s", "4s", "5s", "6s", "7s", "8s", "9s"],
        "north": ["1m", "4m", "7m", "2p", "3p", "8p", "3s", "4s", "5s", "6s", "7s", "8s", "9s"]
      },
      "starting_draws": ["1z", "2z", "3z", "4p", "6p"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4p", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii", "call_choice" => ["2p", "3p"], "called_tile" => "4p"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [],
        minipoints: 30
      }
    })
  end

  test "riichi - south round wrong winds" do
    # south round wrong winds
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "4s", "5s", "6s", "7s", "8s", "9s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "4s", "5s", "6s", "7s", "8s", "9s"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "4s", "5s", "6s", "7s", "8s", "9s"],
        "north": ["3z", "3z", "3z", "1z", "1z", "1z", "5m", "5m", "7m", "8m", "2p", "3p", "1z"]
      },
      "starting_draws": ["1z", "2z", "4p", "6m"],
      "starting_round": 4
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4p", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "chii"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 3, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "ron"}]}
    ], %{
      north: %{
        yaku: [],
        yaku2: [],
        minipoints: 40
      }
    })
  end

  test "riichi - invalid chiitoitsu with quad" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["1m", "1m", "4m", "4m", "4m", "4m", "2p", "2p", "4p", "6s", "6s", "1z", "1z"],
        "south": ["1m", "3m", "7m", "3p", "5p", "8p", "3s", "4s", "5s", "6s", "7s", "8s", "9s"],
        "west": ["1m", "3m", "7m", "3p", "5p", "8p", "3s", "4s", "5s", "6s", "7s", "8s", "9s"],
        "north": ["3z", "3z", "3z", "2z", "2z", "2z", "5m", "5m", "7m", "8m", "2p", "3p", "1z"]
      },
      "starting_draws": ["1z", "4p"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4p", "player" => 1, "tsumogiri" => true}
    ], :no_winners)
  end

  test "riichi - false ittsu" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["1m", "1m", "3p", "4p", "5p", "6p", "7p", "1p", "2p", "8p", "9p", "2z", "3z"],
        "south": ["2m", "4m", "7m", "2p", "4p", "8p", "3s", "4s", "5s", "6s", "7s", "8s", "9s"],
        "west": ["2m", "4m", "7m", "2p", "4p", "8p", "3s", "4s", "5s", "6s", "7s", "8s", "9s"],
        "north": ["2m", "4m", "7m", "2p", "4p", "8p", "3s", "4s", "5s", "6s", "7s", "8s", "9s"]
      },
      "starting_draws": ["1z", "2z", "3z", "3p", "4z", "1z", "7p", "5p"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii", "call_choice" => ["1p", "2p"], "called_tile" => ["3p"]}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "2z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "4z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7p", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii", "call_choice" => ["8p", "9p"], "called_tile" => ["7p"]}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "3z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [],
        minipoints: 30
      }
    })
  end

  test "riichi - no sanankou one pon" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["1m", "1m", "1m", "7s", "8s", "9s", "3z", "3z", "5z", "5z", "2p", "2p", "1z"],
        "south": ["2m", "4m", "7m", "1p", "5p", "8p", "3s", "4s", "5s", "6s", "7s", "8s", "9s"],
        "west": ["2m", "4m", "7m", "1p", "5p", "8p", "3s", "4s", "5s", "6s", "7s", "8s", "9s"],
        "north": ["2m", "4m", "7m", "1p", "5p", "8p", "3s", "4s", "5s", "6s", "7s", "8s", "9s"]
      },
      "starting_draws": ["1z", "2p", "2z", "1z", "4z", "3z"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4z", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [],
        minipoints: 50
      }
    })
  end

  test "riichi - open chuurenpoutou" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["1m", "1m", "1m", "2m", "3m", "4m", "5m", "6m", "7m", "8m", "9m", "9m", "2z"],
        "south": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "4s", "5s", "6s", "7s", "8s", "9s"],
        "west": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "4s", "5s", "6s", "7s", "8s", "9s"],
        "north": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "4s", "5s", "6s", "7s", "8s", "9s"]
      },
      "starting_draws": ["1z", "9m", "9m"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "9m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "2z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "9m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Chinitsu", 5}, {"Ittsu", 1}],
        yaku2: [],
        minipoints: 30
      }
    })
  end

end
