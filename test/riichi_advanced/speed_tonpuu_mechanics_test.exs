defmodule RiichiAdvanced.YakuTest.SpeedTonpuuMechanics do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  @speed_tonpuu_mods [
    %{name: "honba", config: %{value: 100}},
    %{name: "yaku/riichi", config: %{bet: 1000, drawless: false}},
    "yaku/ippatsu",
    "kuikae_nashi",
    %{name: "min_han", config: %{min: 1, han: "Han"}},
    "double_wind_4_fu",
    %{name: "oka", config: %{ante: 4}},
    %{name: "uma", config: %{_1st: 10, _2nd: 4, _3rd: -4, _4th: -10}},
    %{name: "nagashi", config: %{is: "Haneman", counts_as: "tsumo"}},
    %{name: "suufon_renda", config: %{name: "Suufon Renda"}},
    "suucha_riichi",
    %{name: "kyuushu_kyuuhai", config: %{name: "Kyuushu Kyuuhai"}},
    "agarirenchan",
    "tenpairenchan",
    %{name: "agariyame", config: %{first_place_only: false, may_choose: true, round: "every"}},
    %{name: "tenpaiyame", config: %{first_place_only: false, may_choose: true, round: "every"}},
    "kiriage_mangan",
    "double_round_wind",
    "yaku/open_riichi",
    "yaku/kansai_chiitoitsu",
    "kokushi_ankan_chankan",
    %{name: "yaku/sanrenkou", config: %{
      san_list: "yaku", san_name: "Sanrenkou", san_value: 2, san_han: "Han",
      suu_list: "yakuman", suu_name: "Suurenkou", suu_value: 1, suu_han: "★"
    }},
    "yaku/shiisanpuutaa",
    "yaku/shiisanuushi",
    # "pao",
    # "pao_suukantsu", # note: affects the test 'suukantsu rinshan is scored as normal tsumo scoring shuugi'
    # "pao_rinshan",
    %{name: "yaku/riichi_renhou", config: %{is: "Yakuman"}},
    %{name: "shuugi", config: %{worth: 5000, starting_shuugi: 100, pao_pays_all: true}},
    %{name: "shuugi/ippatsu", config: %{chips: 1}},
    %{name: "shuugi/ura", config: %{chips: 1}},
    %{name: "shuugi/yakuman", config: %{ron_chips: 10, tsumo_chips: 5, per_yakuman: true, allow_kazoe: true}},
    %{name: "shuugi/aka", config: %{chips: 1, closed_only: false}},
    %{name: "shuugi/ao", config: %{chips: 2, closed_only: false}},
    %{name: "shuugi/kin", config: %{chips: 1, closed_only: false}},
    "shuugi/placement_only_battle",
  ]

  test "speed tonpuu - aka dora" do
    TestUtils.test_yaku_advanced("speed_tonpuu", @speed_tonpuu_mods, """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "4m", "05m", "6m", "7p", "7p", "7p", "8s", "8s", "8s", "05p"],
        "south": ["1m", "2m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "2m", "7m", "2p", "6p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "2m", "7m", "2p", "6p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6p"],
      "starting_dead_wall": ["2z", "7z", "4z", "3z", "4m", "5z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "riichi"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Double Riichi", [2, "Han"]}, {"Ippatsu", [1, "Han", 1, "⛀"]}, {"Tanyao", [1, "Han"]}, {"Red Five", [2, "Han", 2, "⛀"]}],
        minipoints: 40
      },
    }, %{shuugi: [103, 97, 100, 100]})
  end

  test "speed tonpuu - ao dora" do
    TestUtils.test_yaku_advanced("speed_tonpuu", @speed_tonpuu_mods, """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "4m", "5m", "6m", "27p", "7p", "7p", "8s", "8s", "8s", "5p"],
        "south": ["1m", "2m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "2m", "7m", "2p", "6p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "2m", "7m", "2p", "6p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6p"],
      "starting_dead_wall": ["2z", "7z", "4z", "3z", "4m", "5z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "riichi"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Double Riichi", [2, "Han"]}, {"Ippatsu", [1, "Han", 1, "⛀"]}, {"Tanyao", [1, "Han"]}, {"Blue Seven", [1, "Han", 2, "⛀"]}],
        minipoints: 40
      },
    }, %{shuugi: [103, 97, 100, 100]})
  end

  test "speed tonpuu - kin dora" do
    TestUtils.test_yaku_advanced("speed_tonpuu", @speed_tonpuu_mods, """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "4m", "5m", "6m", "7p", "7p", "7p", "8s", "8s", "8s", "35p"],
        "south": ["1m", "2m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "2m", "7m", "2p", "6p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "2m", "7m", "2p", "6p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6p"],
      "starting_dead_wall": ["2z", "7z", "4z", "3z", "4m", "5z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "riichi"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Double Riichi", [2, "Han"]}, {"Ippatsu", [1, "Han", 1, "⛀"]}, {"Tanyao", [1, "Han"]}, {"Gold Five", [1, "Han", 1, "⛀"]}],
        minipoints: 40
      },
    }, %{shuugi: [102, 98, 100, 100]})
  end

  test "speed tonpuu - ura dora" do
    TestUtils.test_yaku_advanced("speed_tonpuu", [%{name: "dora", config: %{start_indicators: 1}}, "ura"] ++ @speed_tonpuu_mods, """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "4m", "5m", "6m", "7p", "7p", "7p", "8s", "8s", "8s", "5p"],
        "south": ["1m", "2m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "2m", "7m", "2p", "6p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "2m", "7m", "2p", "6p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6p"],
      "starting_dead_wall": ["2z", "7z", "4z", "3z", "4m", "5m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "riichi"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Double Riichi", [2, "Han"]}, {"Ippatsu", [1, "Han", 1, "⛀"]}, {"Tanyao", [1, "Han"]}, {"Dora", [1, "Han"]}, {"Ura", [1, "Han", 1, "⛀"]}],
        minipoints: 40
      },
    }, %{shuugi: [102, 98, 100, 100]})
  end

  test "speed tonpuu - kin dora is sole yaku" do
    TestUtils.test_yaku_advanced("speed_tonpuu", @speed_tonpuu_mods, """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "4m", "5m", "6m", "35p", "7p", "7p", "7p", "1z", "1z", "2z"],
        "south": ["1m", "2m", "7m", "2p", "6p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "2m", "7m", "2p", "6p", "8p", "3s", "6s", "9s", "5z", "2z", "3z", "4z"],
        "north": ["1m", "2m", "7m", "2p", "6p", "8p", "3s", "6s", "9s", "5z", "6z", "3z", "7z"]
      },
      "starting_draws": ["5p", "5p"],
      "starting_dead_wall": ["2z", "7z", "4z", "3z", "7z", "5z"]
    }
    """, [
      %{"type" => "discard", "tile" => "2z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Gold Five", [1, "Han", 1, "⛀"]}],
        minipoints: 40
      },
    }, %{shuugi: [101, 99, 100, 100]})
  end

  test "speed tonpuu - ultimate all stars" do
    TestUtils.test_yaku_advanced("speed_tonpuu", @speed_tonpuu_mods, """
    {
      "starting_hand": {
        "east": ["05m", "6m", "27m", "27p", "8p", "9p", "05s", "6s", "27s", "05p", "35p", "1z", "1z"],
        "south": ["1m", "2m", "7m", "2p", "6p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "2m", "7m", "2p", "6p", "8p", "3s", "6s", "9s", "5z", "2z", "3z", "4z"],
        "north": ["1m", "2m", "7m", "2p", "6p", "8p", "3s", "6s", "9s", "5z", "6z", "3z", "7z"]
      },
      "starting_draws": ["2z", "5p"],
      "starting_dead_wall": ["2z", "7z", "4z", "3z", "7z", "5z"]
    }
    """, [
      %{"type" => "discard", "tile" => "2z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Red Five", [3, "⛀"]}, {"Blue Seven", [6, "⛀"]}, {"Gold Five", [1, "⛀"]}, {"Ultimate All-Stars", [1, "★"]}],
        minipoints: 40
      },
    }, %{shuugi: [120, 80, 100, 100]})
  end

  test "speed tonpuu - kazoe" do
    TestUtils.test_yaku_advanced("speed_tonpuu", @speed_tonpuu_mods, """
    {
      "starting_hand": {
        "east": ["2p", "2p", "3p", "3p", "4p", "4p", "5p", "5p", "6p", "6p", "7p", "7p", "8p"],
        "south": ["1m", "2m", "3m", "4m", "5m", "7m", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "2m", "3m", "4m", "5m", "7m", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "2m", "3m", "4m", "5m", "7m", "3s", "6s", "9s", "1z", "2z", "7z", "4z"]
      },
      "starting_draws": ["3z", "8p"],
      "starting_dead_wall": ["2z", "7z", "4z", "3z", "7z", "5z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "riichi"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "3z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Double Riichi", [2, "Han"]}, {"Ippatsu", [1, "Han", 1, "⛀"]}, {"Pinfu", [1, "Han"]}, {"Tanyao", [1, "Han"]}, {"Ryanpeikou", [3, "Han"]}, {"Chinitsu", [6, "Han"]}],
        minipoints: 30,
        score: 48000
      }
    }, %{shuugi: [111, 89, 100, 100]})
  end

  test "speed tonpuu - shuugi per yakuman count" do
    TestUtils.test_yaku_advanced("speed_tonpuu", @speed_tonpuu_mods, """
    {
      "starting_hand": {
        "east": ["5m", "5m", "5m", "7m", "7m", "7m", "2p", "2p", "7s", "7s", "1s", "1s", "1s"],
        "south": ["1m", "4m", "8m", "3p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "8m", "3p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "8m", "3p", "6p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Tenhou", [1, "★"]}, {"Suuankou Tanki", [2, "★"]}]
      }
    }, %{shuugi: [145, 85, 85, 85]})
  end

  test "speed tonpuu - suukantsu rinshan is scored as normal tsumo scoring shuugi" do
    TestUtils.test_yaku_advanced("speed_tonpuu", @speed_tonpuu_mods, """
    {
      "starting_hand": {
        "east": ["1z", "1z", "1z", "2z", "2z", "2z", "3z", "3z", "3z", "4z", "4z", "6m", "27p"],
        "south": ["1m", "9m", "1p", "9p", "1s", "2s", "3s", "9s", "5z", "6z", "7z", "7z", "7z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "4s", "5s", "6s", "7s", "8s", "9s"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "4s", "5s", "6s", "7s", "8s", "9s"]
      },
      "starting_draws": ["1z", "2z", "3z", "4z", "2m", "3m", "4m", "4z"],
      "starting_dead_wall": ["5m", "5m", "5m", "7p"]
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
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "2m", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3m", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4m", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "kakan"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Blue Seven", [2, "⛀"]}, {"Daisuushii", [2, "★"]}, {"Suukantsu", [2, "★"]}]
      }
    }, %{shuugi: [166, 78, 78, 78]})
  end

  test "speed tonpuu - suukantsu rinshan miss is scored specially" do
    TestUtils.test_yaku_advanced("speed_tonpuu", @speed_tonpuu_mods, """
    {
      "starting_hand": {
        "east": ["1z", "1z", "1z", "2z", "2z", "2z", "3z", "3z", "3z", "4z", "4z", "6m", "27p"],
        "south": ["1m", "9m", "1p", "9p", "1s", "2s", "3s", "9s", "5z", "6z", "7z", "7z", "7z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "4s", "5s", "6s", "7s", "8s", "9s"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "4s", "5s", "6s", "7s", "8s", "9s"]
      },
      "starting_draws": ["1z", "2z", "3z", "4z", "2m", "3m", "4m", "4z"],
      "starting_dead_wall": ["5m", "5m", "5m", "6p"]
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
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "2m", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3m", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4m", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "kakan"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "suukantsu"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Suukantsu ", [2, "★"]}]
      }
    }, %{shuugi: [130, 90, 90, 90]})
  end

  test "speed tonpuu - white dragon pocchi" do
    TestUtils.test_yaku_advanced("speed_tonpuu", @speed_tonpuu_mods, """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "4m", "5m", "6m", "7p", "7p", "7p", "8s", "8s", "8s", "1z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "4p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "4p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["3p", "6p", "6p", "6p", "9z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "riichi"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "3p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Double Riichi", [2, "Han"]}, {"Ippatsu", [1, "Han", 1, "⛀"]}, {"Tsumo", [1, "Han"]}, {"Shiro Pocchi", [1, "⛀"]}],
        minipoints: 40
      }
    }, %{shuugi: [106, 98, 98, 98]})
  end

  test "speed tonpuu - red dragon pocchi" do
    TestUtils.test_yaku_advanced("speed_tonpuu", @speed_tonpuu_mods, """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "4m", "5m", "6m", "7p", "7p", "7p", "8s", "8s", "8s", "1z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "4p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "4p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["3p", "6p", "6p", "6p", "07z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "riichi"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "3p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Double Riichi", [2, "Han"]}, {"Ippatsu", [1, "Han", 1, "⛀"]}, {"Tsumo", [1, "Han"]}, {"Shiro Pocchi", [1, "⛀"]}],
        minipoints: 40
      }
    }, %{shuugi: [106, 98, 98, 98]})
  end

  test "speed tonpuu - green dragon pocchi" do
    TestUtils.test_yaku_advanced("speed_tonpuu", @speed_tonpuu_mods, """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "4m", "5m", "6m", "35p", "5p", "1p", "8s", "8s", "8s", "7z"],
        "south": ["1m", "4m", "7m", "2p", "4p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "4p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "4p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["3p", "5p", "1p", "1p", "1p", ["56z", "green"]]
    }
    """, [
      %{"type" => "discard", "tile" => "3p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1p", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "1p", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1p", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Gold Five", [1, "Han", 1, "⛀"]}, {"Shiro Pocchi", [1, "⛀"]}],
        minipoints: 40
      }
    }, %{shuugi: [106, 98, 98, 98]})
  end

  test "speed tonpuu - white/red pocchi is unskippable" do
    TestUtils.test_yaku_advanced("speed_tonpuu", @speed_tonpuu_mods, """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "4m", "5m", "6m", "7p", "7p", "7p", "8s", "8s", "8s", "1z"],
        "south": ["1m", "9m", "1p", "9p", "1s", "9s", "1z", "2z", "3z", "4z", "5z", "6z", "7z"],
        "west": ["1m", "4m", "7m", "2p", "4p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "4p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["3p", "6p", "6p", "6p", "07z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "riichi"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "3p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "07z", "player" => 0, "tsumogiri" => true}, # should fail
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Double Riichi", [2, "Han"]}, {"Ippatsu", [1, "Han", 1, "⛀"]}, {"Shiro Pocchi", [1, "⛀"]}, {"Tsumo", [1, "Han"]}],
        minipoints: 40
      }
    }, %{shuugi: [106, 98, 98, 98]})
  end

  test "speed tonpuu - green pocchi is skippable" do
    TestUtils.test_yaku_advanced("speed_tonpuu", @speed_tonpuu_mods, """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "4m", "5m", "6m", "35p", "5p", "1p", "8s", "8s", "8s", "7z"],
        "south": ["1m", "9m", "1p", "9p", "1s", "9s", "1z", "2z", "3z", "4z", "5z", "7z", "7z"],
        "west": ["1m", "4m", "7m", "2p", "4p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "4p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["3p", "5p", "1p", "1p", "2p", ["56z", "green"]]
    }
    """, [
      %{"type" => "discard", "tile" => "3p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1p", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "1p", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2p", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "56z", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ron"}, nil, nil]}
    ], %{
      south: %{
        yaku: [{"Kokushi Musou", [1, "★"]}, {"Shiro Pocchi", [1, "⛀"]}],
        minipoints: 40
      }
    }, %{shuugi: [89, 111, 100, 100]})
  end

  test "speed tonpuu - red 5p matches gold 5p" do
    TestUtils.test_yaku_advanced("speed_tonpuu", @speed_tonpuu_mods, """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "4m", "5m", "6m", "05p", "35p", "1p", "8s", "8s", "8s", "2p"],
        "south": ["1m", "4m", "7m", "2p", "4p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "4p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "4p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1p", "3p"]
    }
    """, [
      %{"type" => "discard", "tile" => "1p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]},
    ], %{
      east: %{
        yaku: [{"Gold Five", [1, "Han", 1, "⛀"]}, {"Red Five", [1, "Han", 1, "⛀"]}],
        minipoints: 40
      }
    }, %{shuugi: [102, 98, 100, 100]})
  end

  test "speed tonpuu - waiting on blue seven" do
    TestUtils.test_yaku_advanced("speed_tonpuu", @speed_tonpuu_mods, """
    {
      "starting_hand": {
        "east": ["3m", "3m", "4m", "4m", "1p", "1p", "05p", "35p", "27p", "8s", "8s", "2p", "2p"],
        "south": ["1m", "4m", "7m", "2p", "4p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "4p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "3p", "4p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1p", "7p"]
    }
    """, [
      %{"type" => "discard", "tile" => "1p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]},
    ], %{
      east: %{
        yaku: [{"Chiitoitsu", [2, "Han"]}, {"Gold Five", [1, "Han", 1, "⛀"]}, {"Red Five", [1, "Han", 1, "⛀"]}, {"Blue Seven", [1, "Han", 2, "⛀"]}],
        minipoints: 25
      }
    }, %{shuugi: [104, 96, 100, 100]})
  end

end
