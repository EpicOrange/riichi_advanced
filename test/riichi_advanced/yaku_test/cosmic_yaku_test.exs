defmodule RiichiAdvanced.YakuTest.CosmicYaku do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  @cosmic_mods [
    "kan",
    %{name: "honba", config: %{value: 100}},
    %{name: "nagashi", config: %{is: "Mangan"}},
    %{name: "tobi", config: %{below: 0}},
    %{name: "yaku/riichi", config: %{bet: 1000, drawless: false}},
    %{name: "uma", config: %{_1st: 10, _2nd: 5, _3rd: -5, _4th: -10}},
    "agarirenchan",
    "tenpairenchan",
    "kuikae_nashi",
    "double_wind_4_fu",
    "pao",
    "kokushi_chankan",
    "suufon_renda",
    "suucha_riichi",
    "suukaikan",
    "kyuushu_kyuuhai",
    # %{name: "dora", config: %{start_indicators: 1}},
    # "ura",
    # "kandora",
    "yaku/tsubame_gaeshi",
    "yaku/kanburi",
    "yaku/uumensai",
    "yaku/isshoku_sanjun",
    %{name: "yaku/renhou", config: %{is: "Yakuman"}},
    "yaku/isshoku_yonjun",
    "show_waits",
    # %{name: "min_han", config: %{min: 1}},
    # "cancellable_riichi",
    "cosmic_calls",
    "yaku/ippatsu",
    "space",
    # %{name: "aka", config: %{man: 1, pin: 1, sou: 1}},
    "cosmic",
    "yaku/kontsu_yaku",
    "yaku/chanfuun",
    "yaku/fuunburi",
    "yaku/uumensai_cosmic",
    "kontsu",
    "yakuman_13_han"
  ]

  test "cosmic - sequences wrap" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["9m", "1m", "2m", "8p", "9p", "1p", "1s", "2s", "3s", "7z", "7z", "7z", "6p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "6p"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Chun", 1}],
        yaku2: [],
        minipoints: 40
      }
    })
  end

  test "cosmic - tsubame gaeshi" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["9m", "1m", "2m", "8p", "9p", "1p", "1s", "2s", "3s", "7z", "7z", "7z", "6p"],
        "south": ["9m", "1m", "2m", "8p", "9p", "1p", "1s", "2s", "3s", "6z", "6z", "6z", "5m"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6p"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "riichi"}, nil, nil]},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Chun", 1}, {"Tsubame Gaeshi", 1}],
        yaku2: [],
        minipoints: 40
      }
    }, %{delta_scores: [4900, -3900, 0, 0]})
  end

  test "cosmic - fuun gives rinshan" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["9m", "1m", "2m", "8p", "9p", "1p", "1s", "2s", "3s", "1z", "2z", "3z", "4z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6p", "6p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "anfuun"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Mixed Winds", 0.5}, {"Rinshan", 1}, {"Tsumo", 1}],
        yaku2: [],
        minipoints: 40
      }
    })
  end

  test "cosmic - open chiitoitsu" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["1m", "1m", "4m", "4m", "5m", "5m", "2p", "2p", "4p", "6s", "6s", "1z", "2z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6p", "4p", "1z"]
    }
    """, [
      %{"type" => "discard", "tile" => "6p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ton"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "2z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "1z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Chiitoitsu", 1}],
        yaku2: [],
        minipoints: 25
      }
    })
  end

  test "cosmic - closed chiitoitsu" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["1m", "1m", "4m", "4m", "5m", "5m", "2p", "2p", "4p", "6s", "6s", "1z", "1z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6p", "4p"]
    }
    """, [
      %{"type" => "discard", "tile" => "6p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Chiitoitsu", 2}],
        yaku2: [],
        minipoints: 25
      }
    })
  end

  test "riichi - open ryanpeikou" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["1m", "1m", "2m", "2m", "3m", "3m", "4m", "4m", "8m", "9m", "9m", "1s", "1z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["2m", "5m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["2m", "5m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["3z", "1s", "8m"]
    }
    """, [
      %{"type" => "discard", "tile" => "3z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ton"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "8m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Ryanpeikou", 1}],
        yaku2: [],
        minipoints: 30
      }
    })
  end

  test "riichi - closed ryanpeikou" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["1m", "1m", "2m", "2m", "2m", "3m", "3m", "4m", "4m", "9m", "9m", "1s", "1s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["2m", "5m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["2m", "5m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["3z", "2m"]
    }
    """, [
      %{"type" => "discard", "tile" => "3z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Pinfu", 1}, {"Ryanpeikou", 3}],
        yaku2: [],
        minipoints: 30
      }
    })
  end

  test "riichi - chankan on kakakan" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "4m", "4m", "1z", "1z", "2z", "3z", "3z", "4z", "6z", "7z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "5z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "7z", "5z", "5z", "5z"]
    }
    """, [
      # west discards 5z,
      # south calls 5z ton, drops 1z
      # east calls 1z pon, drops 2z
      # south calls 5z kapon, drops 3z
      # east calls 3z pon, drops 4z, is now tenpai for 5z
      # south calls 5z kakakan
      # east calls chankan
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5z", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ton"}, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 1, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "2z", "player" => 0, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "kapon"}, nil, nil]},
      %{"type" => "discard", "tile" => "3z", "player" => 1, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "4z", "player" => 0, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "kakakan"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chankan"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Chankan", 1}, {"Honitsu", 2}, {"Mini-Sangen", 0.5}, {"Round Wind", 1}, {"Seat Wind", 1}],
        yaku2: [],
        minipoints: 30
      }
    })
  end

end
