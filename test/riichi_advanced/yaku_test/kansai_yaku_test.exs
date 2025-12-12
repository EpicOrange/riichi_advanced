defmodule RiichiAdvanced.YakuTest.KansaiYaku do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  @kansai_mods [
    %{name: "honba", config: %{value: 100}},
    %{name: "nagashi", config: %{is: "Mangan"}},
    %{name: "tobi", config: %{below: 1}},
    %{name: "yaku/riichi", config: %{bet: 1000, drawless: false}},
    %{name: "uma", config: %{_1st: 10, _2nd: 5, _3rd: -5, _4th: -10}},
    "agarirenchan",
    "tenpairenchan",
    "kuikae_nashi",
    "double_wind_4_fu",
    "pao",
    "kokushi_ankan_chankan",
    "sanma_no_tsumo_loss",
    "suukaikan",
    "kyuushu_kyuuhai",
    # %{name: "dora", config: %{start_indicators: 1}},
    # "ura",
    # "kandora",
    %{name: "yaku/riichi_renhou", config: %{is: "Yakuman"}},
    "show_waits",
    %{name: "min_han", config: %{min: 1}},
    # "cancellable_riichi",
    "yaku/ippatsu",
    %{name: "aka", config: %{man: 1, pin: 1, sou: 1}},
    %{name: "ao", config: %{man: 1, pin: 1, sou: 1}},
    %{name: "kin", config: %{man: 1, pin: 1, sou: 1}},
    "kansai_flowers",
    "kansai_no_100_sticks",
    "kansai_30_fu",
    "kansai_shuugi",
    "zan_scoring",
    "kansai_draw",
    "kansai_no_furiten_riichi"
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
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "riichi"}, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Double Riichi", 2}, {"Ippatsu", 1}, {"Tanyao", 1}],
        yaku2: [],
        minipoints: 40
      }
    })
  end

  test "kansai - north wind is not a seat wind" do
    TestUtils.test_yaku_advanced("kansai", @kansai_mods, """
    {
      "starting_hand": {
        "east": ["2p", "3p", "4p", "4p", "5p", "6p", "7p", "7p", "7p", "4z", "4z", "4z", "6p"],
        "south": ["1p", "2p", "4p", "2s", "6s", "7s", "9s", "1z", "2z", "3z", "5z", "6z", "7z"],
        "west": ["1p", "2p", "4p", "2s", "6s", "7s", "9s", "1z", "2z", "3z", "5z", "6z", "7z"]
      },
      "starting_draws": ["1z", "6p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "riichi"}, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Double Riichi", 2}, {"Honitsu", 3}, {"Ippatsu", 1}, {"North Wind", 1}],
        yaku2: [],
        minipoints: 50
      }
    })
  end

  test "kansai - flower is not a yaku" do
    TestUtils.test_yaku_advanced("kansai", @kansai_mods, """
    {
      "starting_hand": {
        "east": ["2p", "3p", "4p", "4p", "5p", "6p", "7p", "7p", "7p", "9s", "9s", "9s", "1f"],
        "south": ["1p", "2p", "4p", "2s", "6s", "7s", "8s", "1z", "2z", "3z", "4z", "5z", "6z"],
        "west": ["1p", "2p", "4p", "2s", "6s", "7s", "9s", "1z", "2z", "3z", "4z", "5z", "6z"]
      },
      "starting_draws": ["1z", "6p"],
      "starting_dead_wall": ["6p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true}
    ], :no_winners)
  end

  test "kansai - seat wind still works" do
    TestUtils.test_yaku_advanced("kansai", @kansai_mods, """
    {
      "starting_hand": {
        "east": ["2p", "3p", "4p", "4p", "5p", "6p", "8s", "8s", "8s", "3z", "3z", "3z", "1f"],
        "south": ["1p", "2p", "4p", "2s", "6s", "7s", "9s", "1z", "2z", "7z", "4z", "5z", "6z"],
        "west": ["1p", "2p", "4p", "2s", "6s", "7s", "9s", "7z", "2z", "3z", "4z", "5z", "6z"]
      },
      "starting_draws": ["1z", "1z", "1z", "6p"],
      "starting_dead_wall": ["6p"],
      "starting_round": 1
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Seat Wind", 1}, {"Flower", 1}],
        yaku2: [],
        minipoints: 50
      }
    })
  end

end
