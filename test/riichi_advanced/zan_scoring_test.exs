defmodule RiichiAdvanced.ZanScoringTest do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "zan - 1 han dealer tsumo" do
    TestUtils.test_yaku_advanced("zan", [], [], """
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
        yaku: [{"Tsumo", [1, "Han"]}]
      }
    }, %{delta_scores: [2000, -1000, -1000], shuugi: [100, 100, 100]})
  end

  test "zan - 2 han dealer tsumo" do
    TestUtils.test_yaku_advanced("zan", [], [], """
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
        yaku: [{"Tsumo", [1, "Han"]}, {"Pinfu", [1, "Han"]}]
      }
    }, %{delta_scores: [4000, -2000, -2000], shuugi: [100, 100, 100]})
  end

  test "zan - 3 han dealer tsumo" do
    TestUtils.test_yaku_advanced("zan", [], [], """
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
        yaku: [{"Tsumo", [1, "Han"]}, {"Pinfu", [1, "Han"]}, {"Aka", [1, "Han", 1, "⛀"]}]
      }
    }, %{delta_scores: [6000, -3000, -3000], shuugi: [102, 99, 99]})
  end

  test "zan - 4 han dealer tsumo" do
    TestUtils.test_yaku_advanced("zan", [], [], """
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
        yaku: [{"Tsumo", [1, "Han"]}, {"Pinfu", [1, "Han"]}, {"Aka", [2, "Han", 2, "⛀"]}]
      }
    }, %{delta_scores: [12000, -6000, -6000], shuugi: [104, 98, 98]})
  end

  test "zan - 1 han dealer ron" do
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
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Pinfu", [1, "Han"]}]
      }
    }, %{delta_scores: [2000, -2000, 0], shuugi: [100, 100, 100]})
  end

  test "zan - 2 han dealer ron" do
    TestUtils.test_yaku_advanced("zan", [], [], """
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
        yaku: [{"Aka", [1, "Han", 1, "⛀"]}, {"Pinfu", [1, "Han"]}]
      }
    }, %{delta_scores: [3000, -3000, 0], shuugi: [101, 99, 100]})
  end

  test "zan - 3 han dealer ron" do
    TestUtils.test_yaku_advanced("zan", [], [], """
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
        yaku: [{"Aka", [1, "Han", 1, "⛀"]}, {"Tanyao", [1, "Han"]}, {"Pinfu", [1, "Han"]}]
      }
    }, %{delta_scores: [6000, -6000, 0], shuugi: [101, 99, 100]})
  end

  test "zan - 4 han dealer ron" do
    TestUtils.test_yaku_advanced("zan", [], [], """
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
        yaku: [{"Aka", [2, "Han", 2, "⛀"]}, {"Tanyao", [1, "Han"]}, {"Pinfu", [1, "Han"]}]
      }
    }, %{delta_scores: [12000, -12000, 0], shuugi: [102, 98, 100]})
  end

  test "zan - 1 han nondealer tsumo" do
    TestUtils.test_yaku_advanced("zan", [], [], """
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
        yaku: [{"Tsumo", [1, "Han"]}]
      }
    }, %{delta_scores: [-1000, 2000, -1000], shuugi: [100, 100, 100]})
  end

  test "zan - 2 han nondealer tsumo" do
    TestUtils.test_yaku_advanced("zan", [], [], """
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
        yaku: [{"Tsumo", [1, "Han"]}, {"Pinfu", [1, "Han"]}]
      }
    }, %{delta_scores: [-1000, 2000, -1000], shuugi: [100, 100, 100]})
  end

  test "zan - 3 han nondealer tsumo" do
    TestUtils.test_yaku_advanced("zan", [], [], """
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
        yaku: [{"Tsumo", [1, "Han"]}, {"Pinfu", [1, "Han"]}, {"Aka", [1, "Han", 1, "⛀"]}]
      }
    }, %{delta_scores: [-3000, 4000, -1000], shuugi: [99, 102, 99]})
  end

  test "zan - 4 han nondealer tsumo" do
    TestUtils.test_yaku_advanced("zan", [], [], """
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
        yaku: [{"Tsumo", [1, "Han"]}, {"Pinfu", [1, "Han"]}, {"Aka", [2, "Han", 2, "⛀"]}]
      }
    }, %{delta_scores: [-5000, 8000, -3000], shuugi: [98, 104, 98]})
  end

  test "zan - 1 han nondealer ron" do
    TestUtils.test_yaku_advanced("zan", [], [], """
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
        yaku: [{"Pinfu", [1, "Han"]}]
      }
    }, %{delta_scores: [0, 1000, -1000], shuugi: [100, 100, 100]})
  end

  test "zan - 2 han nondealer ron" do
    TestUtils.test_yaku_advanced("zan", [], [], """
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
        yaku: [{"Aka", [1, "Han", 1, "⛀"]}, {"Pinfu", [1, "Han"]}]
      }
    }, %{delta_scores: [0, 2000, -2000], shuugi: [100, 101, 99]})
  end

  test "zan - 3 han nondealer ron" do
    TestUtils.test_yaku_advanced("zan", [], [], """
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
        yaku: [{"Aka", [1, "Han", 1, "⛀"]}, {"Tanyao", [1, "Han"]}, {"Pinfu", [1, "Han"]}]
      }
    }, %{delta_scores: [0, 4000, -4000], shuugi: [100, 101, 99]})
  end

  test "zan - 4 han nondealer ron" do
    TestUtils.test_yaku_advanced("zan", [], [], """
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
        yaku: [{"Aka", [2, "Han", 2, "⛀"]}, {"Tanyao", [1, "Han"]}, {"Pinfu", [1, "Han"]}]
      }
    }, %{delta_scores: [0, 8000, -8000], shuugi: [100, 102, 98]})
  end

  test "zan - ippatsu awards shuugi" do
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
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "riichi"}, nil, nil]},
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Double Riichi", [2, "Han"]}, {"Ippatsu", [1, "Han", 1, "⛀"]}, {"Pinfu", [1, "Han"]}]
      }
    }, %{delta_scores: [13000, -12000, 0], shuugi: [101, 99, 100]})
  end

  test "zan - yakuman tsumo awards shuugi" do
    TestUtils.test_yaku_advanced("zan", [], [], """
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
        yaku: [{"Tenhou", [1, "★"]}]
      }
    }, %{delta_scores: [48000, -24000, -24000], shuugi: [110, 95, 95]})
  end

  test "zan - yakuman ron awards shuugi" do
    TestUtils.test_yaku_advanced("zan", [], [], """
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
        yaku: [{"Renhou", [1, "★"]}]
      }
    }, %{delta_scores: [-32000, 32000, 0], shuugi: [90, 110, 100]})
  end

  test "zan - end of game shuugi payments" do
    TestUtils.test_yaku_advanced("zan", [%{name: "dora", config: %{start_indicators: 1}}], [], """
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
        yaku: [{"Dora", [3, "Han"]}, {"Round Wind", [1, "Han"]}]
      }
      # finishing at 50000/58000/42000 means 0/8/-8 chips
    }, %{delta_scores: [0, 8000, -8000], shuugi: [100, 108, 92]})
  end
  
end
