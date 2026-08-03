defmodule RiichiAdvanced.YakuTest.ZanYaku do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "zan - open double riichi is 3 han if dealt in by a riichi player" do
    TestUtils.test_yaku_advanced("zan", [], [], """
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
        yaku: [{"Open Double Riichi", [3, "Han"]}, {"Ippatsu", [1, "Han", 1, "⛀"]}]
      }
    })
  end

  test "zan - open double riichi is yakuman if dealt in by a non-riichi player" do
    TestUtils.test_yaku_advanced("zan", [], [], """
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
        yaku: [{"Open Riichi ", [1, "★"]}]
      }
    })
  end

  test "zan - sanrenkou" do
    TestUtils.test_yaku_advanced("zan", [], [], """
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
        yaku: [{"Aka", [3, "Han", 3, "⛀"]}, {"Sanankou", [2, "Han"]}, {"Sanrenkou", [2, "Han"]}, {"Toitoi", [2, "Han"]}]
      }
    })
  end

  test "zan - sanpuukou" do
    TestUtils.test_yaku_advanced("zan", [], [], """
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
        yaku: [{"Honitsu", [3, "Han"]}, {"North Wind", [1, "Han"]}, {"Sanankou", [2, "Han"]}, {"Sanpuukou", [2, "Han"]}, {"Toitoi", [2, "Han"]}]
      }
    })
  end

  test "zan - suurenkou" do
    TestUtils.test_yaku_advanced("zan", [], [], """
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
        yaku: [{"Aka", [3, "⛀"]}, {"Suurenkou", [1, "★"]}]
      }
    })
  end
  
  test "zan - renhou suurenkou" do
    TestUtils.test_yaku_advanced("zan", [], [], """
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
        yaku: [{"Aka", [3, "⛀"]}, {"Renhou", [1, "★"]}, {"Suurenkou", [1, "★"]}]
      }
    })
  end

  test "zan - pinfu" do
    TestUtils.test_yaku_advanced("zan", [], [], """
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
        yaku: [{"Double Riichi", [2, "Han"]}, {"Ippatsu", [1, "Han", 1, "⛀"]}, {"Pinfu", [1, "Han"]}]
      }
    })
  end

  test "zan - north wind pair denies pinfu" do
    TestUtils.test_yaku_advanced("zan", [], [], """
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
        yaku: [{"Double Riichi", [2, "Han"]}, {"Ippatsu", [1, "Han", 1, "⛀"]}]
      }
    })
  end

  test "zan - shousharin" do
    TestUtils.test_yaku_advanced("zan", [], [], """
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
        yaku: [{"Shousharin", [6, "Han"]}, {"Aka", [2, "Han", 2, "⛀"]}]
      }
    })
  end

  test "zan - daisharin" do
    TestUtils.test_yaku_advanced("zan", [], [], """
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
        yaku: [{"Aka", [2, "⛀"]}, {"Daisharin", [1, "★"]}]
      }
    })
  end

  test "zan - manzu honitsu" do
    TestUtils.test_yaku_advanced("zan", [], [], """
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
        yaku: [{"Manzu Honitsu", [1, "★"]}]
      }
    })
  end

end
