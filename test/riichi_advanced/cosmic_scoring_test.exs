defmodule RiichiAdvanced.CosmicScoringTest do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  @cosmic_mods [
    "lib/yaku/riichi",
    "yaku/ippatsu",
    "kontsu",
    "yaku/kontsu_yaku",
    "yaku/chanfuun",
    "yaku/fuunburi",
    "yaku/uumensai_cosmic",
    "cosmic_calls",
    "yaku/tsubame_gaeshi",
    "yaku/kanburi",
    "yaku/riichi_isshoku_sanjun",
    "yaku/riichi_isshoku_yonjun"
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
        yaku: [{"Hatsu", [1, "Han"]}, {"Rinshan", [1, "Han"]}, {"Round Wind", [1, "Han"]}, {"Seat Wind", [1, "Han"]}, {"Suuankou", [13, "Han"]}, {"Tsumo", [1, "Han"]}],
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
        yaku: [{"Rinshan", [1, "Han"]}, {"Round Wind", [1, "Han"]}, {"Seat Wind", [1, "Han"]}, {"Suuankou", [13, "Han"]}, {"Tsumo", [1, "Han"]}],
        yaku2: [],
        minipoints: 70,
        score: 48000
      }
    })
  end

  # TODO: fu tests

end
