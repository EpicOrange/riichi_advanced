defmodule RiichiAdvanced.YakuTest.SanmaYaku do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "sanma - chankan pei awards ippatsu" do
    TestUtils.test_yaku_advanced("sanma", [%{name: "yaku/riichi", config: %{"bet" => 1000, "drawless" => false}}, "yaku/ippatsu"], """
    {
      "starting_hand": {
        "east": ["2p", "3p", "4p", "4p", "5p", "6p", "7z", "7z", "7z", "8s", "8s", "8s", "4z"],
        "south": ["1p", "4p", "7p", "2s", "3s", "5s", "6s", "7s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1p", "4p", "7p", "2s", "3s", "5s", "6s", "7s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "5z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "riichi"}, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chankan"}, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Double Riichi", 2}, {"Ippatsu", 1}, {"Chun", 1}],
        yaku2: [],
        minipoints: 50
      }
    })
  end

  test "sanma - pei breaks ippatsu" do
    TestUtils.test_yaku_advanced("sanma", [%{name: "yaku/riichi", config: %{"bet" => 1000, "drawless" => false}}, "yaku/ippatsu"], """
    {
      "starting_hand": {
        "east": ["2p", "3p", "4p", "4p", "5p", "6p", "7z", "7z", "7z", "8s", "8s", "8s", "5z"],
        "south": ["1p", "4p", "7p", "2s", "3s", "5s", "6s", "7s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1p", "4p", "7p", "2s", "3s", "5s", "6s", "7s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "5z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "riichi"}, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "flower"}, nil]},
      %{"type" => "discard", "tile" => "5z", "player" => 1, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Double Riichi", 2}, {"Chun", 1}],
        yaku2: [],
        minipoints: 50
      }
    })
  end

  test "sanma - manzu triplet gives fu" do
    TestUtils.test_yaku_advanced("sanma", [%{name: "yaku/riichi", config: %{"bet" => 1000, "drawless" => false}}, "yaku/ippatsu"], """
    {
      "starting_hand": {
        "east": ["9m", "9m", "9m", "2p", "3p", "9p", "9p", "1s", "2s", "3s", "7s", "8s", "9s"],
        "south": ["1m", "2p", "4p", "5p", "7p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "2p", "4p", "5p", "7p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "1p"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Junchan", 3}],
        yaku2: [],
        minipoints: 40
      }
    })
  end

  test "sanma - fu calculation works" do
    TestUtils.test_yaku_advanced("sanma", [%{name: "yaku/riichi", config: %{"bet" => 1000, "drawless" => false}}, "yaku/ippatsu"], """
    {
      "starting_hand": {
        "east": ["1m", "1m", "1m", "3p", "5p", "9p", "9p", "1s", "2s", "3s", "7s", "8s", "9s"],
        "south": ["2m", "2p", "3p", "4p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["2m", "2p", "3p", "4p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["4z", "4p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "riichi"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "4z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Double Riichi", 2}, {"Ippatsu", 1}],
        yaku2: [],
        minipoints: 40
      }
    })
  end

  test "sanma - fu calculation ignores pei calls" do
    TestUtils.test_yaku_advanced("sanma", [%{name: "yaku/riichi", config: %{"bet" => 1000, "drawless" => false}}, "yaku/ippatsu"], """
    {
      "starting_hand": {
        "east": ["1m", "1m", "1m", "3p", "5p", "9p", "9p", "1s", "2s", "3s", "7s", "8s", "9s"],
        "south": ["9m", "2p", "4p", "5p", "6p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["9m", "2p", "4p", "5p", "6p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["4z", "4p"],
      "starting_dead_wall": ["1z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "riichi"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Riichi", 1}, {"Ippatsu", 1}, {"Pei", 1}],
        yaku2: [],
        minipoints: 40
      }
    })
  end

end
