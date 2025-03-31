defmodule RiichiAdvanced.CosmicScoring do
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

  test "cosmic - 18 han is haneyakuman" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["2m", "2m", "2m", "4p", "4p", "4p", "1z", "1z", "1z", "3z", "3z", "6z", "6z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "5z", "2z", "7z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "5z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "5z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z"],
      "starting_dead_wall": ["6z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Hatsu", 1}, {"Rinshan", 1}, {"Round Wind", 1}, {"Seat Wind", 1}, {"Suuankou", 13}, {"Tsumo", 1}],
        yaku2: [],
        minipoints: 70,
        score: 72000
      }
    })
  end

  test "cosmic - 17 han is just yakuman" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["2m", "2m", "2m", "4p", "4p", "4p", "1z", "1z", "1z", "3z", "3z", "4z", "4z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "5z", "2z", "6z", "7z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "5z", "2z", "6z", "7z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "5z", "2z", "6z", "7z"]
      },
      "starting_draws": ["1z"],
      "starting_dead_wall": ["4z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Rinshan", 1}, {"Round Wind", 1}, {"Seat Wind", 1}, {"Suuankou", 13}, {"Tsumo", 1}],
        yaku2: [],
        minipoints: 70,
        score: 48000
      }
    })
  end

  # TODO: fu tests

end
