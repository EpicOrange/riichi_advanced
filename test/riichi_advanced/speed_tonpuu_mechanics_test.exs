defmodule RiichiAdvanced.YakuTest.SpeedTonpuuMechanics do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "speed tonpuu - aka dora" do
    TestUtils.test_yaku_advanced("speed_tonpuu", [%{name: "yaku/riichi", config: %{"bet" => 1000, "drawless" => false}}, %{name: "dora", config: %{"start_indicators" => 1}}], """
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
        yaku: [{"Double Riichi", [2, "Han"]}, {"Tanyao", [1, "Han"]}, {"Dora", [1, "Han"]}, {"Aka", [2, "Han", 2, "⛀"]}],
        minipoints: 40
      },
    }, %{shuugi: [102, 98, 100, 100]})
  end

  test "speed tonpuu - ao dora" do
    TestUtils.test_yaku_advanced("speed_tonpuu", [%{name: "yaku/riichi", config: %{"bet" => 1000, "drawless" => false}}, %{name: "dora", config: %{"start_indicators" => 1}}], """
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
        yaku: [{"Double Riichi", [2, "Han"]}, {"Tanyao", [1, "Han"]}, {"Dora", [1, "Han"]}, {"Ao", [1, "Han", 2, "⛀"]}],
        minipoints: 40
      },
    }, %{shuugi: [102, 98, 100, 100]})
  end

  test "speed tonpuu - kin dora" do
    TestUtils.test_yaku_advanced("speed_tonpuu", [%{name: "yaku/riichi", config: %{"bet" => 1000, "drawless" => false}}, %{name: "dora", config: %{"start_indicators" => 1}}], """
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
        yaku: [{"Double Riichi", [2, "Han"]}, {"Tanyao", [1, "Han"]}, {"Dora", [1, "Han"]}, {"Kin", [1, "Han", 1, "⛀"]}],
        minipoints: 40
      },
    }, %{shuugi: [101, 99, 100, 100]})
  end

  test "speed tonpuu - ura dora" do
    TestUtils.test_yaku_advanced("speed_tonpuu", [%{name: "yaku/riichi", config: %{"bet" => 1000, "drawless" => false}}, %{name: "dora", config: %{"start_indicators" => 1}}, "ura"], """
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
        yaku: [{"Double Riichi", [2, "Han"]}, {"Tanyao", [1, "Han"]}, {"Dora", [1, "Han"]}, {"Ura", [1, "Han", 1, "⛀"]}],
        minipoints: 40
      },
    }, %{shuugi: [101, 99, 100, 100]})
  end

  test "speed tonpuu - kin dora is sole yaku" do
    TestUtils.test_yaku_advanced("speed_tonpuu", [%{name: "yaku/riichi", config: %{"bet" => 1000, "drawless" => false}}, %{name: "dora", config: %{"start_indicators" => 1}}], """
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
        yaku: [{"Kin", [1, "Han", 1, "⛀"]}],
        minipoints: 40
      },
    }, %{shuugi: [101, 99, 100, 100]})
  end

  test "speed tonpuu - ultimate all stars" do
    TestUtils.test_yaku_advanced("speed_tonpuu", [], """
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
        yaku: [{"Ultimate All-Stars", [1, "★"]}],
        minipoints: 40
      },
    }, %{shuugi: [110, 90, 100, 100]})
  end

  test "speed tonpuu - kazoe" do
    TestUtils.test_yaku_advanced("speed_tonpuu", [%{name: "yaku/riichi", config: %{bet: 1000, drawless: false}}, "yaku/ippatsu", %{name: "min_han", config: %{min: 1, han: "Han"}}], """
    {
      "starting_hand": {
        "east": ["2p", "2p", "3p", "3p", "4p", "4p", "5p", "5p", "6p", "6p", "7p", "7p", "8p"],
        "south": ["1m", "2m", "3m", "4m", "5m", "7m", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "2m", "3m", "4m", "5m", "7m", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "2m", "3m", "4m", "5m", "7m", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["3z", "8p"]
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
    TestUtils.test_yaku_advanced("speed_tonpuu", [], """
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
    TestUtils.test_yaku_advanced("speed_tonpuu", [], """
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
        yaku: [{"Ao", [2, "⛀"]}, {"Daisuushii", [2, "★"]}, {"Suukantsu", [2, "★"]}]
      }
    }, %{shuugi: [166, 78, 78, 78]})
  end

  test "speed tonpuu - suukantsu rinshan miss is scored specially" do
    TestUtils.test_yaku_advanced("speed_tonpuu", [], """
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
    }, %{shuugi: [160, 80, 80, 80]})
  end

  test "speed tonpuu - white dragon pocchi" do
    TestUtils.test_yaku_advanced("speed_tonpuu", [%{name: "yaku/riichi", config: %{"bet" => 1000, "drawless" => false}}, "yaku/ippatsu"], """
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
    TestUtils.test_yaku_advanced("speed_tonpuu", [%{name: "yaku/riichi", config: %{"bet" => 1000, "drawless" => false}}, "yaku/ippatsu"], """
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
    TestUtils.test_yaku_advanced("speed_tonpuu", [], """
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
        yaku: [{"Kin", [1, "Han", 1, "⛀"]}, {"Shiro Pocchi", [1, "⛀"]}],
        minipoints: 40
      }
    }, %{shuugi: [106, 98, 98, 98]})
  end

  test "speed tonpuu - white/red pocchi is unskippable" do
    TestUtils.test_yaku_advanced("speed_tonpuu", [%{name: "yaku/riichi", config: %{"bet" => 1000, "drawless" => false}}, "yaku/ippatsu"], """
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
    TestUtils.test_yaku_advanced("speed_tonpuu", [], """
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

end
