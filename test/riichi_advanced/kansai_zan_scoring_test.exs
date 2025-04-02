defmodule RiichiAdvanced.KansaiZanScoring do
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
    "kansai_draw",
    "zan_scoring",
    "kansai_no_furiten_riichi"
  ]

  test "kansai - 1 han dealer tsumo" do
    TestUtils.test_yaku_advanced("kansai", @zan_mods, """
    {
      "starting_hand": {
        "east": ["2p", "3p", "4p", "7p", "8p", "9p", "1s", "2s", "3s", "4z", "4z", "6s", "7s"],
        "south": ["1s", "2s", "3p", "2p", "3p", "4p", "3s", "4s", "0s", "1z", "1z", "1z", "4z"],
        "west": ["1p", "2p", "7p", "2p", "0p", "8p", "3s", "6s", "9s", "5z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "6z", "7z", "8s"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7z", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Tsumo", 1}],
        yaku2: []
      }
    }, %{delta_scores: [2000, -1000, -1000], shuugi: [0, 0, 0]})
  end

  test "kansai - 2 han dealer tsumo" do
    TestUtils.test_yaku_advanced("kansai", @zan_mods, """
    {
      "starting_hand": {
        "east": ["2p", "3p", "4p", "7p", "8p", "9p", "1s", "2s", "3s", "3z", "3z", "6s", "7s"],
        "south": ["1s", "2s", "3p", "2p", "3p", "4p", "3s", "4s", "0s", "1z", "1z", "1z", "4z"],
        "west": ["1p", "2p", "7p", "2p", "0p", "8p", "3s", "6s", "9s", "5z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "6z", "7z", "8s"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7z", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Tsumo", 1}, {"Pinfu", 1}],
        yaku2: []
      }
    }, %{delta_scores: [4000, -2000, -2000], shuugi: [0, 0, 0]})
  end

  test "kansai - 3 han dealer tsumo" do
    TestUtils.test_yaku_advanced("kansai", @zan_mods, """
    {
      "starting_hand": {
        "east": ["3p", "4p", "0p", "7p", "8p", "9p", "1s", "2s", "3s", "3z", "3z", "6s", "7s"],
        "south": ["1s", "2s", "3p", "2p", "3p", "4p", "3s", "4s", "0s", "1z", "1z", "1z", "4z"],
        "west": ["1p", "2p", "7p", "2p", "0p", "8p", "3s", "6s", "9s", "5z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "6z", "7z", "8s"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7z", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Tsumo", 1}, {"Pinfu", 1}, {"Aka", 1}],
        yaku2: []
      }
    }, %{delta_scores: [6000, -3000, -3000], shuugi: [2, -1, -1]})
  end

  test "kansai - 4 han dealer tsumo" do
    TestUtils.test_yaku_advanced("kansai", @zan_mods, """
    {
      "starting_hand": {
        "east": ["3p", "4p", "0p", "0p", "6p", "7p", "1s", "2s", "3s", "3z", "3z", "6s", "7s"],
        "south": ["1s", "2s", "3p", "2p", "3p", "4p", "3s", "4s", "0s", "1z", "1z", "1z", "4z"],
        "west": ["1p", "2p", "7p", "2p", "0p", "8p", "3s", "6s", "9s", "5z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "6z", "7z", "8s"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7z", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Tsumo", 1}, {"Pinfu", 1}, {"Aka", 2}],
        yaku2: []
      }
    }, %{delta_scores: [12000, -6000, -6000], shuugi: [4, -2, -2]})
  end

  test "kansai - 1 han dealer ron" do
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
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Pinfu", 1}],
        yaku2: []
      }
    }, %{delta_scores: [2000, -2000, 0], shuugi: [0, 0, 0]})
  end

  test "kansai - 2 han dealer ron" do
    TestUtils.test_yaku_advanced("kansai", @zan_mods, """
    {
      "starting_hand": {
        "east": ["3p", "4p", "0p", "7p", "8p", "9p", "1s", "2s", "3s", "3z", "3z", "6s", "7s"],
        "south": ["1s", "2s", "3p", "2p", "3p", "4p", "3s", "4s", "0s", "1z", "1z", "1z", "4z"],
        "west": ["1p", "2p", "7p", "2p", "0p", "8p", "3s", "6s", "9s", "5z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "8s"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Aka", 1}, {"Pinfu", 1}],
        yaku2: []
      }
    }, %{delta_scores: [3000, -3000, 0], shuugi: [1, -1, 0]})
  end

  test "kansai - 3 han dealer ron" do
    TestUtils.test_yaku_advanced("kansai", @zan_mods, """
    {
      "starting_hand": {
        "east": ["3p", "4p", "0p", "6p", "7p", "8p", "2s", "3s", "4s", "6s", "7s", "8s", "8s"],
        "south": ["1s", "2s", "3p", "2p", "3p", "4p", "3s", "4s", "0s", "1z", "1z", "1z", "4z"],
        "west": ["1p", "2p", "7p", "2p", "0p", "8p", "3s", "6s", "9s", "5z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "8s"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Aka", 1}, {"Tanyao", 1}, {"Pinfu", 1}],
        yaku2: []
      }
    }, %{delta_scores: [6000, -6000, 0], shuugi: [1, -1, 0]})
  end

  test "kansai - 4 han dealer ron" do
    TestUtils.test_yaku_advanced("kansai", @zan_mods, """
    {
      "starting_hand": {
        "east": ["3p", "4p", "0p", "0p", "6p", "7p", "2s", "3s", "4s", "6s", "7s", "8s", "8s"],
        "south": ["1s", "2s", "3p", "2p", "3p", "4p", "3s", "4s", "0s", "1z", "1z", "1z", "4z"],
        "west": ["1p", "2p", "7p", "2p", "0p", "8p", "3s", "6s", "9s", "5z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "8s"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Aka", 2}, {"Tanyao", 1}, {"Pinfu", 1}],
        yaku2: []
      }
    }, %{delta_scores: [12000, -12000, 0], shuugi: [2, -2, 0]})
  end

  test "kansai - 1 han nondealer tsumo" do
    TestUtils.test_yaku_advanced("kansai", @zan_mods, """
    {
      "starting_hand": {
        "east": ["1s", "2s", "3p", "2p", "3p", "4p", "3s", "4s", "0s", "1z", "1z", "1z", "4z"],
        "south": ["2p", "3p", "4p", "7p", "8p", "9p", "1s", "2s", "3s", "4z", "4z", "6s", "7s"],
        "west": ["1p", "2p", "7p", "2p", "0p", "8p", "3s", "6s", "9s", "5z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "6z", "6z", "7z", "8s"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7z", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "tsumo"}, nil]}
    ], %{
      south: %{
        yaku: [{"Tsumo", 1}],
        yaku2: []
      }
    }, %{delta_scores: [-1000, 2000, -1000], shuugi: [0, 0, 0]})
  end

  test "kansai - 2 han nondealer tsumo" do
    TestUtils.test_yaku_advanced("kansai", @zan_mods, """
    {
      "starting_hand": {
        "east": ["1s", "2s", "3p", "2p", "3p", "4p", "3s", "4s", "0s", "1z", "1z", "1z", "4z"],
        "south": ["2p", "3p", "4p", "7p", "8p", "9p", "1s", "2s", "3s", "3z", "3z", "6s", "7s"],
        "west": ["1p", "2p", "7p", "2p", "0p", "8p", "3s", "6s", "9s", "5z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "6z", "6z", "7z", "8s"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7z", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "tsumo"}, nil]}
    ], %{
      south: %{
        yaku: [{"Tsumo", 1}, {"Pinfu", 1}],
        yaku2: []
      }
    }, %{delta_scores: [-1000, 2000, -1000], shuugi: [0, 0, 0]})
  end

  test "kansai - 3 han nondealer tsumo" do
    TestUtils.test_yaku_advanced("kansai", @zan_mods, """
    {
      "starting_hand": {
        "east": ["1s", "2s", "3p", "2p", "3p", "4p", "3s", "4s", "0s", "1z", "1z", "1z", "4z"],
        "south": ["3p", "4p", "0p", "7p", "8p", "9p", "1s", "2s", "3s", "3z", "3z", "6s", "7s"],
        "west": ["1p", "2p", "7p", "2p", "0p", "8p", "3s", "6s", "9s", "5z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "6z", "6z", "7z", "8s"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7z", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "tsumo"}, nil]}
    ], %{
      south: %{
        yaku: [{"Tsumo", 1}, {"Pinfu", 1}, {"Aka", 1}],
        yaku2: []
      }
    }, %{delta_scores: [-3000, 4000, -1000], shuugi: [-1, 2, -1]})
  end

  test "kansai - 4 han nondealer tsumo" do
    TestUtils.test_yaku_advanced("kansai", @zan_mods, """
    {
      "starting_hand": {
        "east": ["1s", "2s", "3p", "2p", "3p", "4p", "3s", "4s", "0s", "1z", "1z", "1z", "4z"],
        "south": ["3p", "4p", "0p", "0p", "6p", "7p", "1s", "2s", "3s", "3z", "3z", "6s", "7s"],
        "west": ["1p", "2p", "7p", "2p", "0p", "8p", "3s", "6s", "9s", "5z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "6z", "6z", "7z", "8s"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7z", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "tsumo"}, nil]}
    ], %{
      south: %{
        yaku: [{"Tsumo", 1}, {"Pinfu", 1}, {"Aka", 2}],
        yaku2: []
      }
    }, %{delta_scores: [-5000, 8000, -3000], shuugi: [-2, 4, -2]})
  end

  test "kansai - 1 han nondealer ron" do
    TestUtils.test_yaku_advanced("kansai", @zan_mods, """
    {
      "starting_hand": {
        "east": ["1s", "2s", "3p", "2p", "3p", "4p", "3s", "4s", "0s", "1z", "1z", "1z", "4z"],
        "south": ["2p", "3p", "4p", "7p", "8p", "9p", "1s", "2s", "3s", "3z", "3z", "6s", "7s"],
        "west": ["1p", "2p", "7p", "2p", "0p", "8p", "3s", "6s", "9s", "5z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "6z", "8s"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8s", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ron"}, nil]}
    ], %{
      south: %{
        yaku: [{"Pinfu", 1}],
        yaku2: []
      }
    }, %{delta_scores: [0, 1000, -1000], shuugi: [0, 0, 0]})
  end

  test "kansai - 2 han nondealer ron" do
    TestUtils.test_yaku_advanced("kansai", @zan_mods, """
    {
      "starting_hand": {
        "east": ["1s", "2s", "3p", "2p", "3p", "4p", "3s", "4s", "0s", "1z", "1z", "1z", "4z"],
        "south": ["3p", "4p", "0p", "7p", "8p", "9p", "1s", "2s", "3s", "3z", "3z", "6s", "7s"],
        "west": ["1p", "2p", "7p", "2p", "0p", "8p", "3s", "6s", "9s", "5z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "6z", "8s"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8s", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ron"}, nil]}
    ], %{
      south: %{
        yaku: [{"Aka", 1}, {"Pinfu", 1}],
        yaku2: []
      }
    }, %{delta_scores: [0, 2000, -2000], shuugi: [0, 1, -1]})
  end

  test "kansai - 3 han nondealer ron" do
    TestUtils.test_yaku_advanced("kansai", @zan_mods, """
    {
      "starting_hand": {
        "east": ["1s", "2s", "3p", "2p", "3p", "4p", "3s", "4s", "0s", "1z", "1z", "1z", "4z"],
        "south": ["3p", "4p", "0p", "6p", "7p", "8p", "2s", "3s", "4s", "6s", "7s", "8s", "8s"],
        "west": ["1p", "2p", "7p", "2p", "0p", "8p", "3s", "6s", "9s", "5z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "6z", "8s"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8s", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ron"}, nil]}
    ], %{
      south: %{
        yaku: [{"Aka", 1}, {"Tanyao", 1}, {"Pinfu", 1}],
        yaku2: []
      }
    }, %{delta_scores: [0, 4000, -4000], shuugi: [0, 1, -1]})
  end

  test "kansai - 4 han nondealer ron" do
    TestUtils.test_yaku_advanced("kansai", @zan_mods, """
    {
      "starting_hand": {
        "east": ["1s", "2s", "3p", "2p", "3p", "4p", "3s", "4s", "0s", "1z", "1z", "1z", "4z"],
        "south": ["3p", "4p", "0p", "0p", "6p", "7p", "2s", "3s", "4s", "6s", "7s", "8s", "8s"],
        "west": ["1p", "2p", "7p", "2p", "0p", "8p", "3s", "6s", "9s", "5z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "6z", "8s"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8s", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ron"}, nil]}
    ], %{
      south: %{
        yaku: [{"Aka", 2}, {"Tanyao", 1}, {"Pinfu", 1}],
        yaku2: []
      }
    }, %{delta_scores: [0, 8000, -8000], shuugi: [0, 2, -2]})
  end

  test "kansai - ippatsu awards shuugi" do
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
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "riichi"}, nil, nil]},
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Double Riichi", 2}, {"Ippatsu", 1}, {"Pinfu", 1}],
        yaku2: []
      }
    }, %{delta_scores: [13000, -12000, 0], shuugi: [1, -1, 0]})
  end


  test "kansai - yakuman tsumo awards shuugi" do
    TestUtils.test_yaku_advanced("kansai", @zan_mods, """
    {
      "starting_hand": {
        "east": ["2p", "3p", "4p", "7p", "8p", "9p", "1s", "2s", "3s", "3z", "3z", "6s", "7s"],
        "south": ["1s", "2s", "3p", "2p", "3p", "4p", "3s", "4s", "0s", "1z", "1z", "1z", "4z"],
        "west": ["1p", "2p", "7p", "2p", "0p", "8p", "3s", "6s", "9s", "5z", "2z", "3z", "4z"]
      },
      "starting_draws": ["8s"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"Tenhou", 1}]
      }
    }, %{delta_scores: [48000, -24000, -24000], shuugi: [10, -5, -5]})
  end

  test "kansai - yakuman ron awards shuugi" do
    TestUtils.test_yaku_advanced("kansai", @zan_mods, """
    {
      "starting_hand": {
        "east": ["1s", "2s", "3p", "2p", "3p", "4p", "3s", "4s", "0s", "1z", "1z", "1z", "4z"],
        "south": ["2p", "3p", "4p", "7p", "8p", "9p", "1s", "2s", "3s", "3z", "3z", "6s", "7s"],
        "west": ["1p", "2p", "7p", "2p", "0p", "8p", "3s", "6s", "9s", "5z", "2z", "3z", "4z"]
      },
      "starting_draws": ["8s"]
    }
    """, [
      %{"type" => "discard", "tile" => "8s", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ron"}, nil]}
    ], %{
      south: %{
        yaku: [],
        yaku2: [{"Renhou", 1}]
      }
    }, %{delta_scores: [-32000, 32000, 0], shuugi: [-10, 10, 0]})
  end

  test "kansai - end of game shuugi payments" do
    TestUtils.test_yaku_advanced("kansai", @zan_mods ++ [%{name: "dora", config: %{start_indicators: 1}}], """
    {
      "starting_hand": {
        "east": ["1s", "2s", "3p", "2p", "3p", "4p", "3s", "4s", "0s", "2s", "3s", "4s", "4z"],
        "south": ["2p", "3p", "4p", "6p", "7p", "8p", "1z", "1z", "1z", "6s", "7s", "8s", "8s"],
        "west": ["1p", "2p", "7p", "2p", "0p", "8p", "3s", "6s", "9s", "5z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "6z", "8s"],
      "starting_dead_wall": ["5z", "5z", "6z", "6z", "2z", "2z", "3z", "3z", "4z", "4z"],
      "max_rounds": 0
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8s", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ron"}, nil]}
    ], %{
      south: %{
        yaku: [{"Dora", 3}, {"Round Wind", 1}],
        yaku2: []
      }
      # finishing at 50000/58000/42000 means 0/8/-8 chips
    }, %{delta_scores: [0, 8000, -8000], shuugi: [0, 8, -8]})
  end
  
end
