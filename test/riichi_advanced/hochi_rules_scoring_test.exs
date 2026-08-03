defmodule RiichiAdvanced.YakuTest.HochiRulesScoringTest do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  @hochi_mods [
    "lib/yaku/menzentsumo",
    %{name: "lib/yaku/riichi", config: %{bet: 1000, drawless: true, double_value: 2}},
    "lib/yaku/chankan",
    %{name: "lib/yaku/rinshan", config: %{value: 1}},
    %{name: "lib/yaku/haitei", config: %{haitei_value: 1, houtei_value: 1} },
    %{name: "lib/yaku/pinfu", config: %{value: 1}},
    %{name: "lib/yaku/tanyao", config: %{closed_only: false}},
    %{name: "lib/yaku/yakuhai", config: %{white_name: "Haku", green_name: "Hatsu", red_name: "Chun"}},
    %{name: "lib/yaku/chiitoitsu", config: %{kansai: false, name: "Chiitoitsu", value: 2} },
    %{name: "lib/yaku/chanta", config: %{chanta_value: 1, closed_bonus: 1, junchan_value: 2} },
    %{name: "lib/yaku/ittsuu", config: %{closed_bonus: 1}},
    %{name: "lib/yaku/sanshoku_doujun", config: %{closed_bonus: 1, value: 1} },
    %{name: "lib/yaku/sanshoku_doukou", config: %{value: 2}},
    %{name: "lib/yaku/sankantsu", config: %{value: 2}},
    %{name: "lib/yaku/toitoi", config: %{value: 2}},
    %{name: "lib/yaku/sanankou", config: %{san_value: 2, suu_han: "★", suu_list: "yakuman", suu_tanki_value: 2, suu_value: 1 } },
    %{name: "lib/yaku/shousangen", config: %{dai_han: "★", dai_list: "yakuman", dai_value: 1, shou_value: 2 } },
    %{name: "lib/yaku/honitsu", config: %{hon_value: 2, chin_value: 1, chin_han: "★", closed_bonus: 1}},
    %{name: "lib/yaku/honroutou", config: %{hon_value: 1, hon_han: "★", chin_value: 1.5, chin_han: "★"}},
    %{name: "lib/yaku/isshoku_sanjun", config: %{san_value: 2, yon_value: 1, yon_han: "★", closed_bonus: 1}},
    %{name: "lib/yaku/tenhou", config: %{chiihou_is_tsumo: true, chiihou_list: "yakuman", chiihou_value: 1, chiihou_han: "★", tenhou_list: "yakuman", tenhou_value: 1, tenhou_han: "★" } },
    %{name: "lib/yaku/riichi_renhou", config: %{is: "Shoumangan"}},
    %{name: "lib/yaku/tsuuiisou", config: %{han: "★"}},
    %{name: "lib/yaku/chuurenpoutou", config: %{han: "★", junsei_han: "★", junsei_list: "yakuman", junsei_value: 2, list: "yakuman", value: 1 } },
    %{name: "lib/yaku/kokushi", config: %{han: "★", juusan_han: "★", juusan_list: "yakuman", juusan_value: 2, list: "yakuman", value: 1 } },
    %{name: "lib/yaku/shousuushii", config: %{dai_han: "★", dai_list: "yakuman", dai_value: 2, shou_han: "★", shou_list: "yakuman", shou_value: 1 } },
    %{name: "lib/yaku/suukantsu", config: %{han: "★", value: 1}},
    %{name: "lib/min_han", config: %{han: "Han", min: 1}},
    "no_riichi_ankan",
    "lib/agarirenchan", 
    "double_wind_4_fu",
  ]

  test "hochi - furiten doesn't prevent winning on other waits" do
    TestUtils.test_yaku_advanced("hochi_rules", @hochi_mods, """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "5m", "6m", "7m", "6p", "7p", "8p", "8s", "8s", "8s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2m", "8m"]
    }
    """, [
      %{"type" => "discard", "tile" => "2m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Tanyao", [1, "Han"]}],
        minipoints: 34 # 20 + 10 (closed ron) + 4 (closed 888s)
      }
    })
  end

  test "hochi - furiten does prevent winning on same wait" do
    TestUtils.test_yaku_advanced("hochi_rules", @hochi_mods, """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "5m", "6m", "7m", "6p", "7p", "8p", "8s", "8s", "8s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2m", "2m"]
    }
    """, [
      %{"type" => "discard", "tile" => "2m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2m", "player" => 1, "tsumogiri" => true},
    ], :no_winners)
  end

  test "hochi - no minimum han if 0 honba" do
    TestUtils.test_yaku_advanced("hochi_rules", @hochi_mods, """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "5m", "6m", "7m", "6p", "7p", "8p", "9s", "9s", "9s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2m", "8m"]
    }
    """, [
      %{"type" => "discard", "tile" => "2m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        minipoints: 38 # 20 + 10 (closed ron) + 8 (closed 999s)
      }
    })
  end

  test "hochi - 1 minimum han if 1+ honba" do
    TestUtils.test_yaku_advanced("hochi_rules", @hochi_mods, """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "5m", "6m", "7m", "6p", "7p", "8p", "9s", "9s", "9s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2m", "8m"],
      "starting_honba": 1
    }
    """, [
      %{"type" => "discard", "tile" => "2m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8m", "player" => 1, "tsumogiri" => true},
    ], :no_winners)
  end

  test "hochi - closed pinfu ron is 30 fu" do
    TestUtils.test_yaku_advanced("hochi_rules", @hochi_mods, """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "5m", "6m", "7m", "6p", "7p", "8p", "7s", "8s", "9s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2m", "8m"]
    }
    """, [
      %{"type" => "discard", "tile" => "2m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]},
    ], %{
      east: %{
        yaku: [],
        minipoints: 30
      }
    })
  end

  test "hochi - closed pinfu tsumo is 22 fu, but awards pinfu" do
    TestUtils.test_yaku_advanced("hochi_rules", @hochi_mods, """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "5m", "6m", "7m", "6p", "7p", "8p", "7s", "8s", "9s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2m", "2m", "3p", "3p", "8m"]
    }
    """, [
      %{"type" => "discard", "tile" => "2m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2m", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]},
    ], %{
      east: %{
        yaku: [{"Pinfu", [1, "Han"]}, {"Tsumo", [1, "Han"]}],
        minipoints: 22
      }
    })
  end

  test "hochi - open pinfu ron is 20 fu" do
    TestUtils.test_yaku_advanced("hochi_rules", @hochi_mods, """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "5m", "6m", "7m", "6p", "7p", "8p", "1z", "8s", "9s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2m", "2m", "3p", "7s", "8m"]
    }
    """, [
      %{"type" => "discard", "tile" => "2m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2m", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7s", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "8m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]},
    ], %{
      east: %{
        yaku: [{"Pinfu", [1, "Han"]}],
        minipoints: 20
      }
    })
  end

  test "hochi - open pinfu tsumo is 22 fu, but awards pinfu" do
    TestUtils.test_yaku_advanced("hochi_rules", @hochi_mods, """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "5m", "6m", "7m", "6p", "7p", "8p", "1z", "8s", "9s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2m", "2m", "3p", "7s", "3p", "4p", "4p", "8m"]
    }
    """, [
      %{"type" => "discard", "tile" => "2m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2m", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7s", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "3p", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4p", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]},
    ], %{
      east: %{
        yaku: [{"Pinfu", [1, "Han"]}],
        minipoints: 22
      }
    })
  end

  test "hochi - kuikae is ok" do
    TestUtils.test_yaku_advanced("hochi_rules", @hochi_mods, """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "5m", "6m", "7m", "6p", "7p", "8p", "7s", "8s", "9s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2m", "2m", "3p", "7s", "8m"]
    }
    """, [
      %{"type" => "discard", "tile" => "2m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2m", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7s", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "7s", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "8m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]},
    ], %{
      east: %{
        yaku: [{"Pinfu", [1, "Han"]}],
        minipoints: 20
      }
    })
  end

  test "hochi - double ron no riichi or honba" do
    TestUtils.test_yaku_advanced("hochi_rules", @hochi_mods, """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "5m", "6m", "7m", "6p", "7p", "8p", "8s", "8s", "8s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["2m", "3m", "4m", "5m", "5m", "6m", "7m", "6p", "7p", "8p", "7s", "7s", "7s"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "8m"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, %{"button" => "ron"}, nil]},
    ], %{
      east: %{
        yaku: [{"Tanyao", [1, "Han"]}],
        minipoints: 34
      },
      west: %{
        yaku: [{"Renhou", [1, "★"]}],
        minipoints: 34
      }
    }, %{delta_scores: [200, -4200, 4000, 0]})
    # dealer scores 408 normally, half is 204, round to 200
    # nondealer scores 4000
  end

  test "hochi - double ron takes back riichi bets" do
    TestUtils.test_yaku_advanced("hochi_rules", @hochi_mods, """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "5m", "6m", "7m", "6p", "7p", "8p", "8s", "8s", "8s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["2m", "3m", "4m", "5m", "5m", "6m", "7m", "6p", "7p", "8p", "7s", "7s", "7s"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "1z", "2z", "2z", "3z", "8m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "riichi"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "riichi"}, nil]},
      %{"type" => "discard", "tile" => "2z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, %{"button" => "ron"}, nil]},
    ], %{
      east: %{
        yaku: [{"Double Riichi", [2, "Han"]}, {"Tanyao", [1, "Han"]}],
        minipoints: 34
      },
      west: %{
        yaku: [{"Double Riichi", [2, "Han"]}, {"Tanyao", [1, "Han"]}],
        minipoints: 34
      }
    }, %{delta_scores: [1120, -1910, 1390, 0]})
    # dealer scores 1632 normally, half is 816, round to 820, plus riichi bet is 1120
    # nondealer scores 1088 normally, round to 1090, plus riichi bet is 1390
  end

  test "hochi - double ron takes back riichi bets and splits any remainder" do
    TestUtils.test_yaku_advanced("hochi_rules", @hochi_mods, """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "5m", "6m", "7m", "6p", "7p", "8p", "8s", "8s", "8s"],
        "south": ["1m", "2m", "3m", "2p", "3p", "4p", "3s", "4s", "5s", "6s", "7s", "8s", "4z"],
        "west": ["2m", "3m", "4m", "5m", "5m", "6m", "7m", "6p", "7p", "8p", "7s", "7s", "7s"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "1z", "2z", "2z", "3z", "8m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "riichi"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "riichi"}, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "riichi"}, nil]},
      %{"type" => "discard", "tile" => "2z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, %{"button" => "ron"}, nil]},
    ], %{
      east: %{
        yaku: [{"Double Riichi", [2, "Han"]}, {"Tanyao", [1, "Han"]}],
        minipoints: 34
      },
      west: %{
        yaku: [{"Double Riichi", [2, "Han"]}, {"Tanyao", [1, "Han"]}],
        minipoints: 34
      }
    }, %{delta_scores: [1270, -1910, 1540, 0]})
    # dealer scores 1632 normally, half is 816, round to 820, plus 1.5 riichi bets is 1270
    # nondealer scores 1088 normally, round to 1090, plus 1.5 riichi bets is 1540
  end

end