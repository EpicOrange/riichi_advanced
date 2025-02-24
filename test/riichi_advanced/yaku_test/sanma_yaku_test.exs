defmodule RiichiAdvanced.YakuTest.SanmaYaku do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "sanma - chankan pei awards ippatsu" do
    TestUtils.test_yaku_advanced("riichi", ["sanma", %{name: "yaku/riichi", config: %{"bet" => 1000, "drawless" => false}}, "yaku/ippatsu"], """
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
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "pei"}, nil]},
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
    TestUtils.test_yaku_advanced("riichi", ["sanma", %{name: "yaku/riichi", config: %{"bet" => 1000, "drawless" => false}}, "yaku/ippatsu"], """
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
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "pei"}, nil]},
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

end
