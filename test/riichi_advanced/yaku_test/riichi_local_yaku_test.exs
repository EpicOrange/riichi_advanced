defmodule RiichiAdvanced.YakuTest.RiichiLocalYaku do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "riichi - ketsupaihou" do
    TestUtils.test_yaku_advanced("riichi", ["yaku/ketsupaihou"], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "7p", "7p", "7p", "2s", "2s", "2s", "4p", "6z", "5m", "5m"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2p", "3p", "3p", "3p", "2p", "3p"]
    }
    """, [
      %{"type" => "discard", "tile" => "2p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "3p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Sanankou", 2}, {"Tanyao", 1}, {"Ketsupaihou", 1}],
        yaku2: [],
        minipoints: 50,
        score: 12000
      }
    })
  end

  test "riichi - chinchii toushii" do
    TestUtils.test_yaku_advanced("riichi", ["kan", "yaku/ketsupaihou", "yaku/chinchii_toushii"], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "7p", "7p", "7p", "2s", "2s", "2s", "4p", "6z", "5m", "5m"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["3p", "3p", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "3p", "2p", "4z", "2z", "3p"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "pon"}]},
      %{"type" => "discard", "tile" => "7m", "player" => 3, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "4z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "kakan"}]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chankan"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Sanankou", 2}, {"Tanyao", 1}, {"Chinchii Toushii", 4}],
        yaku2: [],
        minipoints: 50,
        score: 18000
      }
    })
  end

  test "riichi - rentsuu honitsu" do
    TestUtils.test_yaku_advanced("riichi", ["yaku/rentsuu_honitsu"], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "4m", "5m", "6m", "7m", "7m", "8m", "8m", "8m", "7z", "7z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["3p", "3p", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "7z"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Rentsuu Honitsu", 5}],
        yaku2: [],
        minipoints: 50,
        score: 12000
      }
    })
  end

  test "riichi - dorahairi chinroutou chiitoitsu" do
    TestUtils.test_yaku_advanced("riichi", ["dora", "yaku/dorahairi_chinroutou_chiitoitsu"], """
    {
      "starting_hand": {
        "east": ["1m", "1m", "9m", "9m", "1p", "1p", "7m", "7m", "9p", "9p", "1s", "1s", "9s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["3p", "3p", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "9s"],
      "starting_dead_wall": ["1m", "2m", "3m", "4m", "5m", "6m"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "9s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Dorahairi Chinroutou Chiitoitsu", 5}],
        yaku2: [],
        minipoints: 25,
        score: 12000
      }
    })
  end

end
