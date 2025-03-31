defmodule RiichiAdvanced.YakuTest.KansaiZanYaku do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  @zan_mods [
    %{name: "honba", config: %{value: 1000}},
    %{name: "nagashi", config: %{is: "Yakuman"}},
    %{name: "tobi", config: %{below: 1}},
    %{name: "yaku/riichi", config: %{bet: 1000, drawless: true}},
    %{name: "uma", config: %{_1st: 30, _2nd: 10, _3rd: -10, _4th: -30}},
    "agarirenchan",
    "tenpairenchan",
    "tenpaiyame",
    "kuikae_nashi",
    "double_wind_4_fu",
    "kokushi_ankan_chankan",
    "first_gets_riichi_sticks",
    "sanma_no_tsumo_loss",
    "suufon_renda",
    "suucha_riichi",
    "sanchahou",
    "kyuushu_kyuuhai",
    # %{name: "dora", config: %{start_indicators: 1}},
    # "ura",
    # "kandora",
    "yaku/open_riichi",
    "yaku/sanrenkou",
    "yaku/sanpuukou",
    %{name: "yaku/riichi_renhou", config: %{is: "Yakuman"}},
    "yaku/suurenkou",
    "show_waits",
    %{name: "shuugi", config: %{worth: 1000}},
    %{name: "min_han", config: %{min: 1}},
    # "cancellable_riichi",
    "yaku/ippatsu",
    "shiro_pocchi",
    %{name: "aka", config: %{man: 4, pin: 4, sou: 4}},
    "shiny_dora",
    "kansai_flowers",
    "kansai_no_100_sticks",
    "kansai_40_fu",
    "kansai_shuugi",
    "zan_scoring",
    "kansai_draw",
    "kansai_no_furiten_riichi"
  ]

  test "kansai - open double riichi is 3 han if dealt in by a riichi player" do
    TestUtils.test_yaku_advanced("kansai", @zan_mods, """
    {
      "starting_hand": {
        "east": ["2p", "3p", "4p", "7p", "8p", "9p", "1s", "2s", "3s", "4z", "4z", "8s", "8s"],
        "south": ["1p", "2p", "3p", "2p", "3p", "4p", "3s", "4s", "0s", "1z", "1z", "1z", "4z"],
        "west": ["1p", "4p", "7p", "2p", "0p", "8p", "3s", "6s", "9s", "5z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "8s"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "open_riichi"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "riichi"}, nil, nil]},
      %{"type" => "discard", "tile" => "8s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Open Double Riichi", 3}, {"Ippatsu", 1}],
        yaku2: []
      }
    })
  end

  test "kansai - open double riichi is yakuman if dealt in by a non-riichi player" do
    TestUtils.test_yaku_advanced("kansai", @zan_mods, """
    {
      "starting_hand": {
        "east": ["2p", "3p", "4p", "7p", "8p", "9p", "1s", "2s", "3s", "4z", "4z", "8s", "8s"],
        "south": ["1p", "2p", "3p", "2p", "3p", "4p", "3s", "4s", "0s", "1z", "1z", "1z", "4z"],
        "west": ["1p", "4p", "7p", "2p", "0p", "8p", "3s", "6s", "9s", "5z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "8s"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "open_riichi"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"Open Riichi", 1}]
      }
    })
  end

  test "kansai - sanrenkou" do
    TestUtils.test_yaku_advanced("kansai", @zan_mods, """
    {
      "starting_hand": {
        "east": ["0p", "0p", "0p", "6p", "6p", "6p", "7p", "7p", "7p", "4z", "4z", "8s", "8s"],
        "south": ["1p", "2p", "3p", "2p", "3p", "4p", "3s", "4s", "0s", "1z", "1z", "1z", "4z"],
        "west": ["1p", "4p", "7p", "2p", "0p", "8p", "3s", "6s", "9s", "5z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "8s"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Aka", 3}, {"Sanankou", 2}, {"Sanrenkou", 2}, {"Toitoi", 2}],
        yaku2: []
      }
    })
  end

  test "kansai - sanpuukou" do
    TestUtils.test_yaku_advanced("kansai", @zan_mods, """
    {
      "starting_hand": {
        "east": ["2z", "2z", "2z", "3z", "3z", "3z", "4z", "4z", "4z", "5z", "5z", "8s", "8s"],
        "south": ["1p", "2p", "3p", "2p", "3p", "4p", "3s", "4s", "0s", "1z", "1z", "1z", "7z"],
        "west": ["1p", "4p", "7p", "2p", "0p", "8p", "3s", "6s", "9s", "5z", "2z", "3z", "7z"]
      },
      "starting_draws": ["6z", "8s"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Honitsu", 3}, {"North Wind", 1}, {"Sanankou", 2}, {"Sanpuukou", 2}, {"Toitoi", 2}],
        yaku2: []
      }
    })
  end

  test "kansai - suurenkou" do
    TestUtils.test_yaku_advanced("kansai", @zan_mods, """
    {
      "starting_hand": {
        "east": ["4p", "4p", "4p", "0p", "0p", "0p", "6p", "6p", "6p", "7p", "7p", "8s", "8s"],
        "south": ["1p", "2p", "3p", "2p", "3p", "4p", "3s", "4s", "0s", "1z", "1z", "1z", "4z"],
        "west": ["1p", "2p", "7p", "2p", "0p", "8p", "3s", "6s", "9s", "5z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "7p"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"Suurenkou", 1}]
      }
    })
  end
  
  test "kansai - renhou suurenkou" do
    TestUtils.test_yaku_advanced("kansai", @zan_mods, """
    {
      "starting_hand": {
        "east": ["1p", "2p", "3p", "2p", "3p", "4p", "3s", "4s", "0s", "1z", "1z", "1z", "4z"],
        "south": ["4p", "4p", "4p", "0p", "0p", "0p", "6p", "6p", "6p", "7p", "7p", "8s", "8s"],
        "west": ["1p", "2p", "7p", "2p", "0p", "8p", "3s", "6s", "9s", "5z", "2z", "3z", "4z"]
      },
      "starting_draws": ["7p"]
    }
    """, [
      %{"type" => "discard", "tile" => "7p", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ron"}, nil, nil]}
    ], %{
      south: %{
        yaku: [],
        yaku2: [{"Renhou", 1}, {"Suurenkou", 1}]
      }
    })
  end

  test "kansai - pinfu" do
    TestUtils.test_yaku_advanced("kansai", @zan_mods, """
    {
      "starting_hand": {
        "east": ["2p", "3p", "4p", "7p", "8p", "9p", "1s", "2s", "3s", "3z", "3z", "6s", "7s"],
        "south": ["1s", "2s", "3p", "2p", "3p", "4p", "3s", "4s", "0s", "1z", "1z", "1z", "4z"],
        "west": ["1p", "2p", "7p", "2p", "0p", "8p", "3s", "6s", "9s", "5z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "8s"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "riichi"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Double Riichi", 2}, {"Ippatsu", 1}, {"Pinfu", 1}],
        yaku2: []
      }
    })
  end

  test "kansai - north wind pair denies pinfu" do
    TestUtils.test_yaku_advanced("kansai", @zan_mods, """
    {
      "starting_hand": {
        "east": ["2p", "3p", "4p", "7p", "8p", "9p", "1s", "2s", "3s", "4z", "4z", "6s", "7s"],
        "south": ["1s", "2s", "3p", "2p", "3p", "4p", "3s", "4s", "0s", "1z", "1z", "1z", "4z"],
        "west": ["1p", "2p", "7p", "2p", "0p", "8p", "3s", "6s", "9s", "5z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "8s"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "riichi"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Double Riichi", 2}, {"Ippatsu", 1}],
        yaku2: []
      }
    })
  end

  test "kansai - shousharin" do
    TestUtils.test_yaku_advanced("kansai", @zan_mods, """
    {
      "starting_hand": {
        "east": ["3p", "3p", "4p", "4p", "0p", "0p", "6p", "6p", "7p", "7p", "7p", "7p", "1z"],
        "south": ["1s", "2s", "3p", "2p", "3p", "4p", "3s", "4s", "0s", "1z", "1z", "2z", "4z"],
        "west": ["1p", "2p", "8p", "2p", "0p", "8p", "3s", "6s", "9s", "5z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "1z"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Shousharin", 6}, {"Aka", 2}],
        yaku2: []
      }
    })
  end

  test "kansai - daisharin" do
    TestUtils.test_yaku_advanced("kansai", @zan_mods, """
    {
      "starting_hand": {
        "east": ["3p", "3p", "4p", "4p", "0p", "0p", "6p", "6p", "7p", "7p", "7p", "7p", "9p"],
        "south": ["1s", "2s", "3p", "2p", "3p", "4p", "3s", "4s", "0s", "1z", "1z", "2z", "4z"],
        "west": ["1p", "2p", "8p", "2p", "0p", "8p", "3s", "6s", "9s", "5z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "9p"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "9p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"Daisharin", 1}]
      }
    })
  end

  test "kansai - manzu honitsu" do
    TestUtils.test_yaku_advanced("kansai", @zan_mods, """
    {
      "starting_hand": {
        "east": ["1m", "1m", "1m", "1m", "9m", "9m", "9m", "9m", "1z", "1z", "2z", "2z", "3z"],
        "south": ["1s", "2s", "3p", "2p", "3p", "4p", "3s", "4s", "0s", "1z", "1z", "2z", "4z"],
        "west": ["1p", "2p", "8p", "2p", "0p", "8p", "3s", "6s", "9s", "5z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "3z"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"Manzu Honitsu", 1}]
      }
    })
  end

end
