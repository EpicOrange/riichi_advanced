defmodule RiichiAdvanced.YakuTest.KansaiYaku do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  @kansai_mods [
    "kan",
    %{name: "honba", config: %{"value" => 100}},
    %{name: "yaku/riichi", config: %{"bet" => 1000, "drawless" => false}},
    "kansai_draw",
    "kansai_flowers",
    "kansai_yaku",
    "nagashi_yakuman",
    "kansai_no_100_sticks",
    "kansai_30_fu",
    %{name: "nagashi", config: %{"is" => "Mangan"}},
    %{name: "tobi", config: %{"below" => 1}},
    %{
     name: "uma",
     config: %{"_1st" => 10, "_2nd" => 5, "_3rd" => -5, "_4th" => -10}
    },
    "agarirenchan",
    "tenpairenchan",
    "kuikae_nashi",
    "double_wind_4_fu",
    "pao",
    "kokushi_chankan",
    "sanma_no_tsumo_loss",
    "suukaikan",
    "kyuushu_kyuuhai",
    # %{name: "dora", config: %{"start_indicators" => 1}},
    # "ura",
    # "kandora",
    %{name: "yaku/renhou", config: %{"is" => "Yakuman"}},
    "show_waits",
    "kansai_no_furiten_riichi",
    %{name: "min_han", config: %{"min" => 1}},
    "yaku/ippatsu",
    %{name: "aka", config: %{"man" => 1, "pin" => 1, "sou" => 1}},
    %{name: "ao", config: %{"man" => 1, "pin" => 1, "sou" => 1}},
    %{name: "kin", config: %{"man" => 1, "pin" => 1, "sou" => 1}}
  ]

  test "kansai - ao doesn't break half flush" do
    TestUtils.test_yaku_advanced("kansai", @kansai_mods, """
    {
      "starting_hand": {
        "east": ["2p", "3p", "4p", "4p", "25p", "6p", "7p", "4z", "4z", "4z", "2z", "2z", "2z"],
        "south": ["1p", "4p", "6p", "7p", "2s", "3s", "6s", "7s", "9s", "1z", "3z", "5z", "6z"],
        "west": ["1p", "4p", "6p", "7p", "2s", "3s", "6s", "7s", "9s", "1z", "3z", "5z", "6z"]
      },
      "starting_draws": ["1z", "1p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "riichi"}, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Ao", 2}, {"Double Riichi", 2}, {"Honitsu", 3}, {"Ippatsu", 1}, {"North Wind", 1}],
        yaku2: [],
        minipoints: 50
      }
    })
  end

  test "kansai - ippatsu still works" do
    TestUtils.test_yaku_advanced("kansai", @kansai_mods, """
    {
      "starting_hand": {
        "east": ["2p", "3p", "4p", "4p", "5p", "6p", "7p", "7p", "7p", "8s", "8s", "8s", "6p"],
        "south": ["1p", "2p", "4p", "2s", "6s", "7s", "9s", "1z", "2z", "3z", "4z", "5z", "6z"],
        "west": ["1p", "2p", "4p", "2s", "6s", "7s", "9s", "1z", "2z", "3z", "4z", "5z", "6z"]
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

end
