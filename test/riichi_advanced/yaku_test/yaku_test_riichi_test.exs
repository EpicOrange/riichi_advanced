defmodule RiichiAdvanced.YakuTest.Riichi do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  # TODO local yaku lol

  test "riichi - tanyao nomi" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "4m", "5m", "6m", "7p", "7p", "7p", "8s", "8s", "8s", "6p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
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
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
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
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "1z", "1z", "1z", "7m"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 3, "tsumogiri" => true},
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
      "starting_draws": ["1z", "1z", "1z", "1z", "9m"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 3, "tsumogiri" => true},
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
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["7p", "7p", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["7p", "1z", "6p", "1z", "7p"]
    }
    """, [
      %{"type" => "discard", "tile" => "7p", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "pon"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 3, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 1, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "1z", "player" => 2, "tsumogiri" => true},
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
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
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
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
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
        "east": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "south": ["1m", "2m", "3m", "2z", "2z", "2z", "5p", "5p", "7p", "8p", "2p", "3p", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
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
        "east": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "south": ["7z", "7z", "7z", "1m", "1m", "2m", "2m", "3m", "7m", "7m", "2p", "3p", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
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
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
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
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
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
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
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
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
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
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
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
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
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



  test "riichi - old tests" do
    # closed chanta
    TestUtils.test_yaku("riichi", [], %{
      hand: [:"1p", :"2p", :"3p", :"1s", :"2s", :"3s", :"7p", :"8p", :"9s", :"9s", :"9s", :"2z", :"2z"],
      winning_tile: :"9p",
      win_source: :discard,
      yaku_lists: ["yaku", "meta_yaku"],
      expected_yaku: [{"Chanta", 2}],
      expected_minipoints: 40,
    })
    # open junchan
    TestUtils.test_yaku("riichi", [], %{
      hand: [:"1m", :"1m", :"1s", :"2s", :"3s", :"7p", :"8p", :"9s", :"9s", :"9s"],
      calls: [{"chii", [:"1p", :"2p", :"3p"]}],
      winning_tile: :"9p",
      win_source: :discard,
      yaku_lists: ["yaku", "meta_yaku"],
      expected_yaku: [{"Junchan", 2}],
      expected_minipoints: 30,
    })
    # closed junchan
    TestUtils.test_yaku("riichi", [], %{
      hand: [:"1m", :"1m", :"1p", :"2p", :"3p", :"1s", :"2s", :"3s", :"7p", :"8p", :"9s", :"9s", :"9s"],
      winning_tile: :"9p",
      win_source: :discard,
      yaku_lists: ["yaku", "meta_yaku"],
      expected_yaku: [{"Junchan", 3}],
      expected_minipoints: 40,
    })
    # open ittsu
    TestUtils.test_yaku("riichi", [], %{
      hand: [:"1m", :"1m", :"4p", :"5p", :"6p", :"7p", :"8p"],
      calls: [{"chii", [:"1p", :"2p", :"3p"]}, {"chii", [:"7p", :"8p", :"9p"]}],
      winning_tile: :"6p",
      win_source: :discard,
      yaku_lists: ["yaku", "meta_yaku"],
      expected_yaku: [{"Ittsu", 1}],
      expected_minipoints: 30,
    })
    # false open ittsu
    TestUtils.test_yaku("riichi", [], %{
      hand: [:"1m", :"1m", :"3p", :"4p", :"5p", :"6p", :"7p"],
      calls: [{"chii", [:"1p", :"2p", :"3p"]}, {"chii", [:"7p", :"8p", :"9p"]}],
      winning_tile: :"5p",
      win_source: :discard,
      yaku_lists: ["yaku", "meta_yaku"],
      expected_yaku: [],
      expected_minipoints: 30,
    })
    # closed ittsu
    TestUtils.test_yaku("riichi", [], %{
      hand: [:"1m", :"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m", :"7p", :"8p", :"9p", :"9s", :"9s"],
      winning_tile: :"9m",
      win_source: :discard,
      yaku_lists: ["yaku", "meta_yaku"],
      expected_yaku: [{"Pinfu", 1}, {"Ittsu", 2}],
      expected_minipoints: 30,
    })
    # sanshoku doukou
    TestUtils.test_yaku("riichi", [], %{
      hand: [:"2m", :"2m", :"2m", :"8p", :"9p", :"9s", :"9s"],
      calls: [{"pon", [:"2p", :"2p", :"2p"]}, {"pon", [:"2s", :"2s", :"2s"]}],
      winning_tile: :"7p",
      win_source: :discard,
      yaku_lists: ["yaku", "meta_yaku"],
      expected_yaku: [{"Sanshoku Doukou", 2}],
      expected_minipoints: 30,
    })
    # sankantsu
    TestUtils.test_yaku("riichi", [], %{
      hand: [:"8p", :"9p", :"9s", :"9s"],
      calls: [{"daiminkan", [:"2p", :"2p", :"2p", :"2p"]}, {"kakan", [:"2m", :"2m", :"2m", :"2m"]}, {"ankan", [:"7z", :"7z", :"7z"]}],
      winning_tile: :"7p",
      win_source: :discard,
      yaku_lists: ["yaku", "meta_yaku"],
      expected_yaku: [{"Chun", 1}, {"Sankantsu", 2}],
      expected_minipoints: 70,
    })
    # open toitoi shousangen honitsu
    TestUtils.test_yaku("riichi", [], %{
      hand: [:"7p", :"7p", :"9s", :"9s", :"9s", :"6z", :"6z"],
      calls: [{"daiminkan", [:"5z", :"5z", :"5z", :"5z"]}, {"pon", [:"7z", :"7z", :"7z"]}],
      winning_tile: :"7p",
      win_source: :discard,
      yaku_lists: ["yaku", "meta_yaku"],
      expected_yaku: [{"Haku", 1}, {"Chun", 1}, {"Toitoi", 2}, {"Shousangen", 2}],
      expected_minipoints: 60,
    })
    # closed honitsu honroutou
    TestUtils.test_yaku("riichi", [], %{
      hand: [:"1m", :"1m", :"1m", :"9m", :"9m", :"9m", :"2z", :"2z", :"2z", :"3z", :"3z", :"5z", :"5z"],
      winning_tile: :"5z",
      win_source: :discard,
      yaku_lists: ["yaku", "meta_yaku"],
      expected_yaku: [{"Haku", 1}, {"Toitoi", 2}, {"Sanankou", 2}, {"Honroutou", 2}, {"Honitsu", 3}],
      expected_minipoints: 60,
    })
    # sanankou open one pon
    TestUtils.test_yaku("riichi", [], %{
      hand: [:"1m", :"1m", :"1m", :"7s", :"7s", :"7s", :"3z", :"3z", :"5z", :"5z"],
      calls: [{"pon", [:"2p", :"2p", :"2p"]}],
      winning_tile: :"3z",
      win_source: :draw,
      yaku_lists: ["yaku", "meta_yaku"],
      expected_yaku: [{"Toitoi", 2}, {"Sanankou", 2}],
      expected_minipoints: 50,
    })
    # sanankou open one chii
    TestUtils.test_yaku("riichi", [], %{
      hand: [:"1m", :"1m", :"1m", :"7s", :"7s", :"7s", :"3z", :"3z", :"5z", :"5z"],
      calls: [{"chii", [:"2p", :"3p", :"4p"]}],
      winning_tile: :"3z",
      win_source: :draw,
      yaku_lists: ["yaku", "meta_yaku"],
      expected_yaku: [{"Sanankou", 2}],
      expected_minipoints: 50,
    })
    # no sanankou one pon
    TestUtils.test_yaku("riichi", [], %{
      hand: [:"1m", :"1m", :"1m", :"7s", :"8s", :"9s", :"3z", :"3z", :"5z", :"5z"],
      calls: [{"pon", [:"2p", :"2p", :"2p"]}],
      winning_tile: :"3z",
      win_source: :draw,
      yaku_lists: ["yaku", "meta_yaku"],
      expected_yaku: [],
      expected_minipoints: 50,
    })
    # sanankou after completing sequence
    TestUtils.test_yaku("riichi", [], %{
      hand: [:"1m", :"1m", :"1m", :"7s", :"8s", :"3z", :"3z", :"3z", :"5z", :"5z"],
      calls: [{"ankan", [:"2p", :"2p", :"2p", :"2p"]}],
      winning_tile: :"9s",
      win_source: :draw,
      yaku_lists: ["yaku", "meta_yaku"],
      expected_yaku: [{"Tsumo", 1}, {"Sanankou", 2}],
      expected_minipoints: 60,
    })
    # haitei
    TestUtils.test_yaku("riichi", [], %{
      hand: [:"4m", :"4m", :"4m", :"6m", :"7m", :"8m", :"1p", :"1p", :"3z", :"3z"],
      calls: [{"chii", [:"2s", :"3s", :"4s"]}],
      conditions: ["no_draws_remaining"],
      winning_tile: :"3z",
      win_source: :draw,
      yaku_lists: ["yaku", "meta_yaku"],
      expected_yaku: [{"Haitei", 1}],
      expected_minipoints: 40,
    })
    # houtei
    TestUtils.test_yaku("riichi", [], %{
      hand: [:"4m", :"4m", :"4m", :"6m", :"7m", :"8m", :"1p", :"1p", :"3z", :"3z"],
      calls: [{"chii", [:"2s", :"3s", :"4s"]}],
      conditions: ["no_draws_remaining"],
      winning_tile: :"3z",
      win_source: :discard,
      yaku_lists: ["yaku", "meta_yaku"],
      expected_yaku: [{"Houtei", 1}],
      expected_minipoints: 30,
    })
  end

  test "riichi - yakuless" do
    # yakuless closed
    TestUtils.test_yaku("riichi", [], %{
      hand: [:"2m", :"3m", :"2s", :"2s", :"2s", :"7s", :"8s", :"9s", :"4p", :"0p", :"6p", :"6p", :"6p"],
      winning_tile: :"1m",
      win_source: :discard,
      yaku_lists: ["yaku", "meta_yaku"],
      expected_yaku: [],
      expected_minipoints: 0,
    })
    # yakuless open pinfu
    TestUtils.test_yaku("riichi", [], %{
      hand: [:"1m", :"2m", :"3m", :"6m", :"7m", :"8m", :"5p", :"5p", :"7p", :"8p"],
      calls: [{"chii", [:"2p", :"3p", :"4p"]}],
      winning_tile: :"6p",
      win_source: :discard,
      yaku_lists: ["yaku", "meta_yaku"],
      expected_yaku: [],
      expected_minipoints: 30,
    })
    # south round wrong winds
    TestUtils.test_yaku("riichi", [], %{
      hand: [:"3z", :"3z", :"3z", :"1z", :"1z", :"1z", :"5m", :"5m", :"7m", :"8m"],
      calls: [{"chii", [:"2p", :"3p", :"4p"]}],
      winning_tile: :"6p",
      round: 5,
      seat: :north,
      win_source: :discard,
      yaku_lists: ["yaku", "meta_yaku"],
      expected_yaku: [],
      expected_minipoints: 0,
    })
    # invalid chiitoitsu with quad
    TestUtils.test_yaku("riichi", [], %{
      hand: [:"1m", :"1m", :"4m", :"4m", :"4m", :"4m", :"2p", :"2p", :"4p", :"6s", :"6s", :"1z", :"1z"],
      winning_tile: :"4p",
      win_source: :discard,
      yaku_lists: ["yaku", "meta_yaku"],
      expected_yaku: [],
      expected_minipoints: 25,
    })
  end

  test "riichi yakuman" do
    # daisangen tsuuiisou suuankou
    TestUtils.test_yaku("riichi", [], %{
      hand: [:"5z", :"5z", :"5z", :"6z", :"6z", :"6z", :"2z", :"2z", :"3z", :"3z"],
      calls: [{"ankan", [:"7z", :"7z", :"7z", :"7z"]}],
      conditions: ["make_discards_exist"],
      winning_tile: :"2z",
      win_source: :draw,
      yaku_lists: ["yakuman", "meta_yakuman"],
      expected_yaku: [{"Daisangen", 1}, {"Suuankou", 1}, {"Tsuuiisou", 1}],
      expected_minipoints: 80,
    })
    # suuankou with tenhou (upgrades into tanki)
    TestUtils.test_yaku("riichi", [], %{
      hand: [:"5m", :"5m", :"5m", :"7m", :"7m", :"7m", :"2p", :"2p", :"7s", :"7s"],
      calls: [{"ankan", [:"1s", :"1s", :"1s", :"1s"]}],
      winning_tile: :"2p",
      win_source: :draw,
      seat: :east,
      yaku_lists: ["yakuman", "meta_yakuman"],
      expected_yaku: [{"Tenhou", 1}, {"Suuankou Tanki", 2}],
      expected_minipoints: 70,
    })
    # suuankou with chiihou (no upgrade)
    TestUtils.test_yaku("riichi", [], %{
      hand: [:"5m", :"5m", :"5m", :"7m", :"7m", :"7m", :"2p", :"2p", :"7s", :"7s"],
      calls: [{"ankan", [:"1s", :"1s", :"1s", :"1s"]}],
      winning_tile: :"2p",
      win_source: :draw,
      seat: :south,
      yaku_lists: ["yakuman", "meta_yakuman"],
      expected_yaku: [{"Chiihou", 1}, {"Suuankou", 1}],
      expected_minipoints: 70,
    })
    # typical open ryuuiisou
    TestUtils.test_yaku("riichi", [], %{
      hand: [:"2s", :"2s", :"3s", :"3s", :"3s", :"4s", :"4s", :"4s", :"6z", :"6z"],
      calls: [{"pon", [:"6s", :"6s", :"6s"]}],
      conditions: ["make_discards_exist"],
      winning_tile: :"2s",
      win_source: :discard,
      yaku_lists: ["yakuman", "meta_yakuman"],
      expected_yaku: [{"Ryuuiisou", 1}],
      expected_minipoints: 40,
    })
    # open chinroutou
    TestUtils.test_yaku("riichi", [], %{
      hand: [:"1m", :"1m", :"1m", :"1p", :"1p", :"1p", :"9p", :"9p", :"9s", :"9s"],
      calls: [{"pon", [:"1s", :"1s", :"1s"]}],
      status: [],
      conditions: ["make_discards_exist"],
      winning_tile: :"9s",
      win_source: :discard,
      yaku_lists: ["yakuman", "meta_yakuman"],
      expected_yaku: [{"Chinroutou", 1}],
      expected_minipoints: 50,
    })
    # open chuurenpoutou
    TestUtils.test_yaku("riichi", [], %{
      hand: [:"1m", :"1m", :"1m", :"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m"],
      calls: [{"pon", [:"9m", :"9m", :"9m"]}],
      status: [],
      conditions: ["make_discards_exist"],
      winning_tile: :"9m",
      win_source: :discard,
      yaku_lists: ["yakuman", "meta_yakuman"],
      expected_yaku: [],
      expected_minipoints: 30,
    })
    # closed chuurenpoutou
    TestUtils.test_yaku("riichi", [], %{
      hand: [:"1m", :"1m", :"1m", :"2m", :"3m", :"4m", :"5m", :"7m", :"7m", :"8m", :"9m", :"9m", :"9m"],
      status: [],
      conditions: ["make_discards_exist"],
      winning_tile: :"6m",
      win_source: :discard,
      yaku_lists: ["yakuman", "meta_yakuman"],
      expected_yaku: [{"Chuurenpoutou", 1}],
      expected_minipoints: 40,
    })
    # junsei chuurenpoutou
    TestUtils.test_yaku("riichi", [], %{
      hand: [:"1m", :"1m", :"1m", :"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m", :"9m", :"9m", :"9m"],
      status: [],
      conditions: ["make_discards_exist"],
      winning_tile: :"5m",
      win_source: :discard,
      yaku_lists: ["yakuman", "meta_yakuman"],
      expected_yaku: [{"Junsei Chuurenpoutou", 2}],
      expected_minipoints: 50,
    })
    # chuurenpoutou with tenhou (upgrades into junsei)
    TestUtils.test_yaku("riichi", [], %{
      hand: [:"1m", :"1m", :"1m", :"2m", :"3m", :"4m", :"5m", :"7m", :"7m", :"8m", :"9m", :"9m", :"9m"],
      winning_tile: :"6m",
      win_source: :draw,
      yaku_lists: ["yakuman", "meta_yakuman"],
      expected_yaku: [{"Tenhou", 1}, {"Junsei Chuurenpoutou", 2}],
      expected_minipoints: 40,
    })
    # chuurenpoutou with chiihou (no upgrade)
    TestUtils.test_yaku("riichi", [], %{
      hand: [:"1m", :"1m", :"1m", :"2m", :"3m", :"4m", :"5m", :"7m", :"7m", :"8m", :"9m", :"9m", :"9m"],
      calls: [{"ankan", [:"1s", :"1s", :"1s", :"1s"]}],
      winning_tile: :"6m",
      win_source: :draw,
      seat: :south,
      yaku_lists: ["yakuman", "meta_yakuman"],
      expected_yaku: [{"Chiihou", 1}, {"Chuurenpoutou", 1}],
      expected_minipoints: 70,
    })
    # juusan kokushi
    TestUtils.test_yaku("riichi", [], %{
      hand: [:"1m", :"9m", :"1p", :"9p", :"1s", :"9s", :"1z", :"2z", :"3z", :"4z", :"5z", :"6z", :"7z"],
      status: [],
      conditions: ["make_discards_exist"],
      winning_tile: :"1z",
      win_source: :draw,
      yaku_lists: ["yakuman", "meta_yakuman"],
      expected_yaku: [{"Kokushi Musou Juusan Menmachi", 2}],
      expected_minipoints: 30,
    })
    # kokushi with tenhou (upgrades into juusan)
    TestUtils.test_yaku("riichi", [], %{
      hand: [:"1m", :"9m", :"1p", :"9p", :"1s", :"9s", :"1z", :"1z", :"3z", :"4z", :"5z", :"6z", :"7z"],
      winning_tile: :"2z",
      win_source: :draw,
      yaku_lists: ["yakuman", "meta_yakuman"],
      expected_yaku: [{"Tenhou", 1}, {"Kokushi Musou Juusan Menmachi", 2}],
      expected_minipoints: 30,
    })
    # kokushi with chiihou (no upgrade)
    TestUtils.test_yaku("riichi", [], %{
      hand: [:"1m", :"9m", :"1p", :"9p", :"1s", :"9s", :"1z", :"1z", :"3z", :"4z", :"5z", :"6z", :"7z"],
      calls: [{"ankan", [:"1s", :"1s", :"1s", :"1s"]}],
      winning_tile: :"2z",
      win_source: :draw,
      seat: :south,
      yaku_lists: ["yakuman", "meta_yakuman"],
      expected_yaku: [{"Chiihou", 1}, {"Kokushi Musou", 1}],
      expected_minipoints: 30,
    })
    # daisuushii suukantsu
    TestUtils.test_yaku("riichi", [], %{
      hand: [:"1p"],
      calls: [{"ankan", [:"1z", :"1z", :"1z", :"1z"]}, {"daiminkan", [:"2z", :"2z", :"2z", :"2z"]}, {"daiminkan", [:"3z", :"3z", :"3z", :"3z"]}, {"kakan", [:"4z", :"4z", :"4z", :"4z"]}],
      status: [],
      conditions: ["make_discards_exist"],
      winning_tile: :"1p",
      win_source: :discard,
      yaku_lists: ["yakuman", "meta_yakuman"],
      expected_yaku: [{"Daisuushii", 2}, {"Suukantsu", 1}],
      expected_minipoints: 110,
    })
    # shousuushii tsuuiisou
    TestUtils.test_yaku("riichi", [], %{
      hand: [:"1z", :"1z", :"1z", :"2z", :"2z", :"2z", :"3z", :"3z", :"4z", :"4z", :"4z", :"5z", :"5z"],
      status: [],
      conditions: ["make_discards_exist"],
      winning_tile: :"5z",
      win_source: :discard,
      yaku_lists: ["yakuman", "meta_yakuman"],
      expected_yaku: [{"Tsuuiisou", 1}, {"Shousuushii", 1}],
      expected_minipoints: 60,
    })
  end

end
