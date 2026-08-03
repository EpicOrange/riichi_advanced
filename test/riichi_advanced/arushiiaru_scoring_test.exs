defmodule RiichiAdvanced.YakuTest.ArushiiaruScoringTest do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  @arushiiaru_mods [ 
    %{name: "lib/yaku/riichi", config: %{"bet" => 1000, "drawless" => true}},
    "double_wind_4_fu",
    "lib/yaku/chankan",
    %{name: "lib/yaku/rinshan", config: %{"value" => 1}},
    %{name: "lib/yaku/haitei", config: %{"haitei_value" => 1, "houtei_value" => 1}},
    %{name: "lib/yaku/pinfu", config: %{"value" => 1}},
    %{name: "lib/yaku/tanyao", config: %{"closed_only" => false}},
    %{name: "lib/yaku/iipeikou", config: %{"ii_value" => 1, "ryan_value" => 3}},
    %{name: "lib/yaku/yakuhai", config: %{"green_name" => "Hatsu", "red_name" => "Chun", "white_name" => "Haku"}},
    %{name: "lib/yaku/chiitoitsu", config: %{"kansai" => false, "name" => "Chiitoitsu", "value" => 2}},
    %{name: "lib/yaku/chanta", config: %{"chanta_value" => 1}},
    %{name: "lib/yaku/ittsuu", config: %{"value" => 1}},
    %{name: "lib/yaku/sanshoku_doujun", config: %{"closed_bonus" => 1, "value" => 1}},
    %{name: "lib/yaku/sanshoku_doukou", config: %{"value" => 2}},
    %{name: "lib/yaku/sankantsu", config: %{"value" => 2}},
    %{name: "lib/yaku/toitoi", config: %{"value" => 1}},
    %{name: "lib/yaku/sanankou", config: %{"san_value" => 1, "suu_han" => "★", "suu_list" => "yakuman", "suu_value" => 1}},
    %{name: "lib/yaku/shousangen", config: %{"value" => 1}},
    %{name: "lib/yaku/honroutou", config: %{"chin_han" => "★", "chin_list" => "yakuman", "chin_value" => 1, "hon_value" => 2}},
    %{name: "lib/yaku/honitsu", config: %{"chin_value" => 3, "hon_value" => 1}},
    %{name: "lib/yaku/tenhou", config: %{"chiihou_han" => "★", "chiihou_is_tsumo" => true, "chiihou_list" => "yakuman", "chiihou_value" => 1, "tenhou_han" => "★", "tenhou_list" => "yakuman", "tenhou_value" => 1}},
    %{name: "lib/yaku/tsuuiisou", config: %{"han" => "★"}},
    %{name: "lib/yaku/ryuuiisou", config: %{"han" => "★"}},
    %{name: "lib/yaku/chuurenpoutou", config: %{"han" => "★", "value" => 1}},
    %{name: "lib/yaku/kokushi", config: %{"han" => "★", "value" => 1}},
    %{name: "lib/yaku/shousuushii", config: %{"dai_han" => "★", "dai_value" => 1, "shou_han" => "★", "shou_value" => 1}},
    %{name: "lib/yaku/suukantsu", config: %{"han" => "★", "value" => 1}},
    "lib/partial_furiten",
    "lib/arushiiaru_scoring"
  ]

  test "arushiiaru - furiten doesn't prevent winning on other waits" do
    TestUtils.test_yaku_advanced("arushiiaru", @arushiiaru_mods, """
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
        minipoints: 40
      }
    })
  end

  test "arushiiaru - furiten does prevent winning on same wait" do
    TestUtils.test_yaku_advanced("arushiiaru", @arushiiaru_mods, """
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

  test "arushiiaru - no minimum han" do
    TestUtils.test_yaku_advanced("arushiiaru", @arushiiaru_mods, """
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
        minipoints: 40
      }
    })
  end

  test "arushiiaru - closed pinfu ron is 30 fu" do
    TestUtils.test_yaku_advanced("arushiiaru", @arushiiaru_mods, """
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
        yaku: [{"Pinfu", [1, "Han"]}],
        minipoints: 30
      }
    })
  end

  test "arushiiaru - closed pinfu tsumo is 22 fu (= 30 fu)" do
    TestUtils.test_yaku_advanced("arushiiaru", @arushiiaru_mods, """
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
        yaku: [],
        minipoints: 30
      }
    })
  end

  test "arushiiaru - open pinfu ron is 20 fu" do
    TestUtils.test_yaku_advanced("arushiiaru", @arushiiaru_mods, """
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

  test "arushiiaru - open pinfu tsumo is 22 fu (= 30 fu)" do
    TestUtils.test_yaku_advanced("arushiiaru", @arushiiaru_mods, """
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
        yaku: [],
        minipoints: 30
      }
    })
  end

  test "arushiiaru - kuikae is ok" do
    TestUtils.test_yaku_advanced("arushiiaru", @arushiiaru_mods, """
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

end