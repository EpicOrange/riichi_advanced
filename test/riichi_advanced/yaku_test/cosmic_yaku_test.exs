defmodule RiichiAdvanced.YakuTest.CosmicYaku do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  @cosmic_mods [
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
    "kokushi_ankan_chankan",
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
    %{name: "yaku/riichi_renhou", config: %{is: "Yakuman"}},
    "yaku/isshoku_yonjun",
    "show_waits",
    %{name: "min_han", config: %{min: 1}},
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

  test "cosmic - mini-sangen x2 should give ryandoukon instead of iipeikou" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["9m", "1m", "2m", "8p", "9p", "1p", "5z", "6z", "7z", "5z", "6z", "7z", "6p"],
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
        yaku: [{"Mini-Sangen", 1}, {"Ryandoukon", 1}],
        yaku2: [],
        minipoints: 40 # 30 closed ron + 2 tanki wait + 2x4 closed honor kontsu = 40
      }
    })
  end

  test "cosmic - mixed winds as east with 123z" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["9m", "1m", "2m", "8p", "9p", "1p", "7z", "7z", "7z", "1z", "2z", "3z", "6p"],
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
        yaku: [{"Chun", 1}, {"Mixed Winds", 0.5}],
        yaku2: [],
        minipoints: 50 # 30 closed ron + 2 tanki wait + 8 closed honor triplet + 4 closed honor kontsu = 44
      }
    })
  end

  test "cosmic - mixed winds as east with 124z" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["9m", "1m", "2m", "8p", "9p", "1p", "7z", "7z", "7z", "1z", "2z", "4z", "6p"],
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
        yaku: [{"Chun", 1}, {"Mixed Winds", 0.5}],
        yaku2: [],
        minipoints: 50 # 30 closed ron + 2 tanki wait + 8 closed honor triplet + 4 closed honor kontsu = 44
      }
    })
  end

  test "cosmic - mixed winds as east with 134z" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["9m", "1m", "2m", "8p", "9p", "1p", "7z", "7z", "7z", "1z", "3z", "4z", "6p"],
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
        yaku: [{"Chun", 1}, {"Mixed Winds", 0.5}],
        yaku2: [],
        minipoints: 50 # 30 closed ron + 2 tanki wait + 8 closed honor triplet + 4 closed honor kontsu = 44
      }
    })
  end

  test "cosmic - mixed winds as east with 234z" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["9m", "1m", "2m", "8p", "9p", "1p", "7z", "7z", "7z", "2z", "3z", "4z", "6p"],
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
        minipoints: 50 # 30 closed ron + 2 tanki wait + 8 closed honor triplet + 4 closed honor kontsu = 44
      }
    })
  end

  test "cosmic - mixed winds as north with 123z" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["9m", "1m", "2m", "8p", "9p", "1p", "7z", "7z", "7z", "1z", "2z", "3z", "6p"]
      },
      "starting_draws": ["6z", "1p", "3p", "4p", "6p"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1p", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4p", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "ron"}]}
    ], %{
      north: %{
        yaku: [{"Chun", 1}],
        yaku2: [],
        minipoints: 50 # 30 closed ron + 2 tanki wait + 8 closed honor triplet + 4 closed honor kontsu = 44
      }
    })
  end

  test "cosmic - mixed winds as north with 124z" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["9m", "1m", "2m", "8p", "9p", "1p", "7z", "7z", "7z", "1z", "2z", "4z", "6p"]
      },
      "starting_draws": ["6z", "1p", "3p", "4p", "6p"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1p", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4p", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "ron"}]}
    ], %{
      north: %{
        yaku: [{"Chun", 1}, {"Mixed Winds", 0.5}],
        yaku2: [],
        minipoints: 50 # 30 closed ron + 2 tanki wait + 8 closed honor triplet + 4 closed honor kontsu = 44
      }
    })
  end

  test "cosmic - mixed winds as north with 134z" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["9m", "1m", "2m", "8p", "9p", "1p", "7z", "7z", "7z", "1z", "3z", "4z", "6p"]
      },
      "starting_draws": ["6z", "1p", "3p", "4p", "6p"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1p", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4p", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "ron"}]}
    ], %{
      north: %{
        yaku: [{"Chun", 1}, {"Mixed Winds", 0.5}],
        yaku2: [],
        minipoints: 50 # 30 closed ron + 2 tanki wait + 8 closed honor triplet + 4 closed honor kontsu = 44
      }
    })
  end

  test "cosmic - mixed winds as north with 234z" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["9m", "1m", "2m", "8p", "9p", "1p", "7z", "7z", "7z", "2z", "3z", "4z", "6p"]
      },
      "starting_draws": ["6z", "1p", "3p", "4p", "6p"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1p", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4p", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "ron"}]}
    ], %{
      north: %{
        yaku: [{"Chun", 1}],
        yaku2: [],
        minipoints: 50 # 30 closed ron + 2 tanki wait + 8 closed honor triplet + 4 closed honor kontsu = 44
      }
    })
  end

  test "cosmic - fuun should only count as one mixed wind, and is eligible for ryandoukon" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "5z", "6z", "3z", "7z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["9m", "1m", "2m", "8p", "9p", "1p", "1z", "2z", "4z", "1z", "2z", "3z", "6p"]
      },
      "starting_draws": ["6z", "1p", "3p", "4z", "4p", "6p"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1p", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "anfuun", "call_choice" => ["1z", "2z", "3z"], "called_tile" => "4z"}]},
      %{"type" => "discard", "tile" => "4p", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "ron"}]}
    ], %{
      north: %{
        yaku: [{"Mixed Winds", 1}, {"Ryandoukon", 1}],
        yaku2: [],
        minipoints: 60 # 30 closed ron + 2 tanki wait + 4 closed honor kontsu + 16 anfuun = 52
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
        minipoints: 40 # 30 closed ron + 8 closed honor triplet = 38
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
        minipoints: 40 # 22 tsumo + 16 closed fuun + 2 tanki wait = 40
      }
    })
  end

  test "cosmic - open chiitoitsu" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["1m", "1m", "4m", "4m", "5m", "5m", "2p", "2p", "4p", "6s", "6s", "1z", "2z"],
        "south": ["2m", "4m", "7m", "3p", "5p", "8p", "3s", "7s", "9s", "2z", "3z", "4z", "5z"],
        "west": ["2m", "4m", "7m", "3p", "5p", "8p", "3s", "7s", "9s", "2z", "3z", "4z", "5z"],
        "north": ["2m", "3m", "7m", "3p", "5p", "8p", "3s", "7s", "9s", "2z", "3z", "4z", "5z"]
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
        minipoints: 25 # 25 chiitoitsu
      }
    })
  end

  test "cosmic - closed chiitoitsu" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["1m", "1m", "4m", "4m", "5m", "5m", "2p", "2p", "4p", "6s", "6s", "1z", "1z"],
        "south": ["2m", "4m", "7m", "3p", "5p", "8p", "3s", "7s", "9s", "2z", "2z", "3z", "4z"],
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
        minipoints: 25 # 25 chiitoitsu
      }
    })
  end

  test "cosmic - open ryanpeikou is always better than open chiitoitsu" do
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
        minipoints: 30 # 30 open pinfu
      }
    })
  end

  test "cosmic - closed ryanpeikou" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["1m", "1m", "2m", "2m", "2m", "3m", "3m", "4m", "4m", "9m", "9m", "1s", "1s"],
        "south": ["4m", "7m", "2p", "4p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["5m", "7m", "2p", "4p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["5m", "7m", "2p", "4p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
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
        minipoints: 30 # 30 closed ron = 30
      }
    })
  end

  test "cosmic - chankan on kakakan" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "4m", "4m", "1z", "1z", "2z", "3z", "3z", "4z", "6z", "7z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "5z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "5m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "4z", "6z", "7z"]
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
        minipoints: 30 # 20 open ron + 2x4 open honor triplet + 2 tanki wait = 30
      }
    })
  end

  test "cosmic - toikon closed" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["1m", "1p", "1s", "5m", "5p", "5s", "5z", "6z", "7z", "2z", "3z", "4z", "6p"],
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
        yaku: [{"Toikon", 2}, {"Mini-Sangen", 0.5}],
        yaku2: [],
        minipoints: 50 # 30 closed ron + 2 concealed kontsu + 4 concealed terminal kontsu + 2x4 concealed honor kontsu + 2 tanki wait = 46
      }
    })
  end

  test "cosmic - toikon open" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["1m", "1p", "1s", "5m", "5p", "5s", "5z", "6z", "1z", "2z", "3z", "4z", "6p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "7z", "6p"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chon_honors"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Toikon", 1}, {"Mini-Sangen", 0.5}],
        yaku2: [],
        minipoints: 40 # 20 closed ron + 2 concealed kontsu + 4 concealed terminal kontsu + 2 open honor kontsu + 4 concealed honor kontsu + 2 tanki wait = 34
      }
    })
  end

  test "cosmic - ryandoukon closed" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["1m", "1p", "1s", "1m", "1p", "1s", "7z", "7z", "7z", "1z", "3z", "4z", "6p"],
        "south": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
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
        yaku: [{"Ryandoukon", 1}, {"Mixed Winds", 0.5}, {"Chun", 1}],
        yaku2: [],
        minipoints: 60 # 30 closed ron + 8 concealed honor triplet + 2x4 concealed terminal kontsu + 4 concealed honor kontsu + 2 tanki wait = 52
      }
    })
  end

  test "cosmic - no ryandoukon if open" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["1m", "1p", "1s", "1m", "1p", "1s", "7z", "7z", "1z", "1z", "3z", "4z", "6p"],
        "south": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "7z", "6p"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Mixed Winds", 0.5}, {"Chun", 1}],
        yaku2: [],
        minipoints: 40 # 20 open ron + 4 open honor triplet + 2x4 concealed terminal kontsu + 4 concealed honor kontsu + 2 tanki wait = 38
      }
    })
  end

  test "cosmic - ryandoukon honors closed" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["1z", "2z", "3z", "1z", "2z", "3z", "5m", "5m", "5m", "1z", "3z", "4z", "6p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "7s", "8s", "5z", "6z", "7z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "7s", "8s", "5z", "6z", "7z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "7s", "8s", "5z", "6z", "7z"]
      },
      "starting_draws": ["6z", "6p"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Ryandoukon", 1}, {"Mixed Winds", 1.5}],
        yaku2: [],
        minipoints: 50 # 30 closed ron + 4 closed triplet + 3x4 concealed honor kontsu + 2 tanki wait = 48
      }
    })
  end

  test "cosmic - no ryandoukon honors open" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["1z", "2z", "3z", "1z", "2z", "3z", "5m", "5m", "1z", "1z", "3z", "4z", "6p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "7s", "8s", "5z", "6z", "7z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "7s", "8s", "5z", "6z", "7z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "7s", "8s", "5z", "6z", "7z"]
      },
      "starting_draws": ["6z", "5m", "6p"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Mixed Winds", 1.5}],
        yaku2: [],
        minipoints: 40 # 20 open ron + 2 open triplet + 3x4 concealed honor kontsu + 2 tanki wait = 36
      }
    })
  end

  test "cosmic - most concealed sandoukon is actually sanshoku doukou + sanankou" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["1m", "1p", "1s", "1m", "1p", "1s", "1m", "1p", "1s", "7z", "7z", "5p", "7p"],
        "south": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["2m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "6p"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Sanshoku Doukou", 2}, {"Sanankou", 2}],
        yaku2: [],
        minipoints: 60 # 30 closed ron + 3x8 concealed terminal/honor triplet + 2 yakuhai pair + 2 closed wait = 58
      }
    })
  end

  test "cosmic - sandoukon open" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["1m", "1p", "1s", "1m", "1p", "1s", "1m", "1p", "1z", "7z", "7z", "7z", "6p"],
        "south": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["2m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "1s", "6p"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Sandoukon", 2}, {"Chun", 1}],
        yaku2: [],
        minipoints: 40 # 20 open ron + 2 open terminal kontsu + 2x4 concealed terminal kontsu + 8 concealed honor triplet + 2 tanki wait = 40
      }
    })
  end

  test "cosmic - concealed sandoukon requires anfuun" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["1z", "2z", "3z", "1z", "2z", "3z", "1z", "2z", "3z", "4z", "4s", "4s", "6p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "7s", "8s", "5z", "6z", "7z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "7s", "8s", "5z", "6z", "7z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "7s", "8s", "5z", "6z", "7z"]
      },
      "starting_draws": ["4s", "6z", "6p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "anfuun"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Mixed Winds", 1.5}, {"Sandoukon", 3}],
        yaku2: [],
        minipoints: 60 # 30 closed ron + 4 concealed triplet + 16 anfuun + 2x4 concealed honor kontsu + 2 tanki wait = 60
      }
    })
  end

  test "cosmic - anfuun is the only way to get concealed sandoukon" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["1z", "2z", "3z", "1z", "2z", "3z", "1z", "2z", "3z", "4z", "4s", "4s", "6p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "7s", "8s", "5z", "6z", "7z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "7s", "8s", "5z", "6z", "7z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "7s", "8s", "5z", "6z", "7z"]
      },
      "starting_draws": ["4s", "6p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "anfuun"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Rinshan", 1}, {"Tsumo", 1}, {"Mixed Winds", 1.5}, {"Sandoukon", 3}],
        yaku2: [],
        minipoints: 60 # 22 tsumo + 4 concealed triplet + 16 anfuun + 3x4 concealed honor kontsu + 2 tanki wait = 56
      }
    })
  end

  test "cosmic - closed ron honors yondoukon is scored using kontsu only" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["1z", "2z", "3z", "1z", "2z", "3z", "1z", "2z", "3z", "1z", "2z", "3z", "6p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "1s", "2s", "3s", "5s", "7s", "8s", "9s"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "1s", "2s", "3s", "5s", "7s", "8s", "9s"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "1s", "2s", "3s", "5s", "7s", "8s", "9s"]
      },
      "starting_draws": ["5z", "6p"]
    }
    """, [
      %{"type" => "discard", "tile" => "5z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        # two ways to score this:
        # - kontsu: {"Honitsu", 3}, {"Mixed Winds", 2}, {"Toikon", 2}, {"Yondoukon", 13}
        # - triplet: {"Honitsu", 3}, {"Mixed Winds", 0.5}, {"Round Wind", 1}, {"Sanankou", 2}, {"Seat Wind", 1}
        # since we have yondoukon, thus must be a kontsu hand
        # so this actually just tests if we score kontsu hands correctly
        yaku: [{"Yondoukon", 13}, {"Toikon", 2}, {"Mixed Winds", 2}, {"Honitsu", 3}],
        yaku2: [],
        minipoints: 50 # 30 closed ron + 4x4 concealed honor kontsu + 2 tanki wait = 48
      }
    })
  end

  test "cosmic - closed tsumo honors yondoukon is scored using kontsu only" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["1z", "2z", "3z", "1z", "2z", "3z", "1z", "2z", "3z", "1z", "2z", "3z", "6p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "1s", "2s", "3s", "5s", "7s", "8s", "9s"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "1s", "2s", "3s", "5s", "7s", "8s", "9s"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "1s", "2s", "3s", "5s", "7s", "8s", "9s"]
      },
      "starting_draws": ["5z", "5z", "5z", "5z", "6p"]
    }
    """, [
      %{"type" => "discard", "tile" => "5z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5z", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Yondoukon", 13}, {"Tsumo", 1}, {"Toikon", 2}, {"Mixed Winds", 2}, {"Honitsu", 3}],
        yaku2: [],
        minipoints: 40 # 22 tsumo + 4x4 concealed honor kontsu + 2 tanki wait = 40
      }
    })
  end

  test "cosmic - closed ron non-honors yondoukon is scored using kontsu only" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["2m", "2p", "2s", "2m", "2p", "2s", "2m", "2p", "2s", "2m", "2p", "2s", "1p"],
        "south": ["1m", "4m", "7m", "3p", "5p", "8p", "1s", "3s", "4s", "5s", "7s", "8s", "9s"],
        "west": ["1m", "4m", "7m", "3p", "5p", "8p", "1s", "3s", "4s", "5s", "7s", "8s", "9s"],
        "north": ["1m", "3m", "7m", "3p", "5p", "8p", "1s", "3s", "4s", "5s", "7s", "8s", "9s"]
      },
      "starting_draws": ["5z", "1p"]
    }
    """, [
      %{"type" => "discard", "tile" => "5z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Yondoukon", 13}, {"Toikon", 2}],
        yaku2: [],
        minipoints: 40 # 30 closed ron + 4x2 concealed kontsu + 2 tanki wait = 40
      }
    })
  end

  test "cosmic - tsumo non-honors yondoukon is scored using kontsu only" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["2m", "2p", "2s", "2m", "2p", "2s", "2m", "2p", "2s", "2m", "2p", "2s", "1p"],
        "south": ["1m", "4m", "7m", "3p", "5p", "8p", "1s", "3s", "4s", "5s", "7s", "8s", "9s"],
        "west": ["1m", "4m", "7m", "3p", "5p", "8p", "1s", "3s", "4s", "5s", "7s", "8s", "9s"],
        "north": ["1m", "3m", "7m", "3p", "5p", "8p", "1s", "3s", "4s", "5s", "7s", "8s", "9s"]
      },
      "starting_draws": ["5z", "5z", "5z", "5z", "1p"]
    }
    """, [
      %{"type" => "discard", "tile" => "5z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5z", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Yondoukon", 13}, {"Tsumo", 1}, {"Toikon", 2}],
        yaku2: [],
        minipoints: 40 # 22 tsumo + 4x2 concealed kontsu + 2 tanki wait = 32
      }
    })
  end

  test "cosmic - open yondoukon is scored using kontsu only" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["2m", "2p", "2s", "2m", "2p", "2s", "2m", "2p", "2s", "2m", "2p", "1z", "1p"],
        "south": ["1m", "4m", "7m", "3p", "5p", "8p", "1s", "3s", "4s", "5s", "7s", "8s", "9s"],
        "west": ["1m", "4m", "7m", "3p", "5p", "8p", "1s", "3s", "4s", "5s", "7s", "8s", "9s"],
        "north": ["1m", "3m", "7m", "3p", "5p", "8p", "1s", "3s", "4s", "5s", "7s", "8s", "9s"]
      },
      "starting_draws": ["5z", "2s", "1p"]
    }
    """, [
      %{"type" => "discard", "tile" => "5z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "1p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Yondoukon", 13}, {"Toikon", 1}],
        yaku2: [],
        minipoints: 30 # 20 open ron + 1 open kontsu + 3x2 concealed kontsu + 2 tanki wait = 29
      }
    })
  end

  test "cosmic - closed sandoukon wins over doukou if 4th group is kontsu" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["2m", "2p", "2s", "3m", "3m", "3m", "3p", "3p", "3p", "3s", "3s", "3s", "1p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "1s", "2s", "4s", "5s", "7s", "8s", "9s"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "1s", "2s", "4s", "5s", "7s", "8s", "9s"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "1s", "2s", "4s", "5s", "7s", "8s", "9s"]
      },
      "starting_draws": ["5z", "1p"]
    }
    """, [
      %{"type" => "discard", "tile" => "5z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Sandoukon", 3}, {"Toikon", 2}],
        yaku2: [],
        minipoints: 40 # 30 closed ron + 4x2 concealed kontsu + 2 tanki wait = 40
      }
    })
  end

  test "cosmic - doukou wins over open sandoukon" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["2m", "2p", "1z", "3m", "3m", "3m", "3p", "3p", "3p", "3s", "3s", "3s", "1p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "1s", "2s", "4s", "5s", "7s", "8s", "9s"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "1s", "2s", "4s", "5s", "7s", "8s", "9s"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "1s", "2s", "4s", "5s", "7s", "8s", "9s"]
      },
      "starting_draws": ["5z", "2s", "1p"]
    }
    """, [
      %{"type" => "discard", "tile" => "5z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "1p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Sanshoku Doukou", 2}, {"Sanankou", 2}],
        yaku2: [],
        minipoints: 40 # 20 open ron + 1 open kontsu + 3x4 concealed triplets + 2 tanki wait = 35
      }
    })
  end

  test "cosmic - doukou wins over sandoukon if 4th group is triplet" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["2m", "2m", "1z", "3m", "3m", "3m", "3p", "3p", "3p", "3s", "3s", "3s", "1p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "1s", "2s", "4s", "5s", "7s", "8s", "9s"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "1s", "2s", "4s", "5s", "7s", "8s", "9s"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "1s", "2s", "4s", "5s", "7s", "8s", "9s"]
      },
      "starting_draws": ["5z", "2m", "1p"]
    }
    """, [
      %{"type" => "discard", "tile" => "5z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "1p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Sanshoku Doukou", 2}, {"Toitoi", 2}, {"Sanankou", 2}],
        yaku2: [],
        minipoints: 40 # 20 open ron + 2 open triplet + 3x4 concealed triplets + 2 tanki wait = 36
      }
    })
  end

  test "cosmic - open uumensai" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["1m", "1z", "3m", "5p", "5p", "5p", "4s", "4s", "4s", "2z", "2z", "7z", "7z"],
        "south": ["1m", "4m", "7m", "2p", "6p", "8p", "1s", "2s", "3s", "5s", "7s", "8s", "9s"],
        "west": ["1m", "4m", "7m", "2p", "6p", "8p", "1s", "2s", "3s", "5s", "7s", "8s", "9s"],
        "north": ["1m", "3m", "7m", "2p", "6p", "8p", "1s", "2s", "3s", "5s", "7s", "8s", "9s"]
      },
      "starting_draws": ["5z", "2m", "2z"]
    }
    """, [
      %{"type" => "discard", "tile" => "5z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Uumensai", 2}],
        yaku2: [],
        minipoints: 40 # 20 open ron + 2 open triplet + 2x4 concealed triplets + 4 tanki yakuhai wait = 34
      }
    })
  end

  test "cosmic - kontsu doesn't contribute to uumensai" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["2s", "2p", "1z", "5p", "5p", "5p", "4s", "4s", "4s", "2z", "2z", "7z", "7z"],
        "south": ["1m", "4m", "7m", "2p", "6p", "8p", "1s", "2s", "3s", "5s", "7s", "8s", "9s"],
        "west": ["1m", "4m", "7m", "2p", "6p", "8p", "1s", "2s", "3s", "5s", "7s", "8s", "9s"],
        "north": ["1m", "3m", "7m", "2p", "6p", "8p", "1s", "2s", "3s", "5s", "7s", "8s", "9s"]
      },
      "starting_draws": ["5z", "2m", "7z"]
    }
    """, [
      %{"type" => "discard", "tile" => "5z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "7z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Chun", 1}],
        yaku2: [],
        minipoints: 40 # 20 open ron + 1 open kontsu + 4 open honors triplet + 2x4 concealed triplets + 2 tanki wait = 35
      }
    })
  end

  test "cosmic - cosmic uumensai" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["2s", "2p", "1z", "5p", "5p", "5p", "4s", "1z", "2z", "3z", "4z", "7z", "7z"],
        "south": ["1m", "4m", "7m", "2p", "6p", "8p", "1s", "2s", "3s", "5s", "7s", "8s", "9s"],
        "west": ["1m", "4m", "7m", "2p", "6p", "8p", "1s", "2s", "3s", "5s", "7s", "8s", "9s"],
        "north": ["1m", "3m", "7m", "2p", "6p", "8p", "1s", "2s", "3s", "5s", "7s", "8s", "9s"]
      },
      "starting_draws": ["5s", "5z", "2m", "6s"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "anfuun"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "5z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Uumensai", 2}, {"Mixed Winds", 0.5}],
        yaku2: [],
        minipoints: 50 # 20 open ron + 1 open kontsu + 16 anfuun + 4 concealed triplets + 2 yakuhai pair = 43
      }
    })
  end

end
