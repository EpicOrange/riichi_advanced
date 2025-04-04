defmodule RiichiAdvanced.YakuTest.NingboYaku do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "ningbo - chicken hand can't win" do
    TestUtils.test_yaku_advanced("ningbo", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "8m", "3s", "4s", "4p", "5p", "6p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"]
      },
      "starting_draws": ["6m", "5s"],
      "starting_dead_wall": ["9m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true}
    ], :no_winners)
  end

  test "ningbo - 3 tai can't win" do
    # all triplets and no baida
    TestUtils.test_yaku_advanced("ningbo", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "5m", "5m", "8m", "8m", "8m", "4s", "4s", "5s", "5s"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "5s", "6s"]
      },
      "starting_draws": ["6m", "5s"],
      "starting_dead_wall": ["9m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true}
    ], :no_winners)
  end

  test "ningbo - self draw single wait all triplets" do
    # all triplets and single wait
    TestUtils.test_yaku_advanced("ningbo", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "5m", "5m", "8m", "8m", "8m", "4s", "4s", "5s", "5s"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "5s", "6s"]
      },
      "starting_draws": ["6m", "6m", "6m", "6m", "5s"],
      "starting_dead_wall": ["9m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6m", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6m", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6m", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"All Triplets", 2}, {"No Baida", 1}, {"Self Draw", 1}],
        yaku2: []
      }
    })
  end

  test "ningbo - single wait no baida" do
    TestUtils.test_yaku_advanced("ningbo", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "5m", "5m", "8m", "8m", "8m", "4s", "4s", "4s", "5s"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "5s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "5s", "6s"]
      },
      "starting_draws": ["6m", "5s"],
      "starting_dead_wall": ["9m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"All Triplets", 2}, {"No Baida", 1}, {"Single Wait", 1}],
        yaku2: []
      }
    })
  end

  test "ningbo - closed wait no baida" do
    TestUtils.test_yaku_advanced("ningbo", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "5m", "5m", "8m", "8m", "8m", "1z", "1z", "4m", "6m"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"]
      },
      "starting_draws": ["6m", "5m"],
      "starting_dead_wall": ["9m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Half Flush", 2}, {"No Baida", 1}, {"Closed Wait", 1}],
        yaku2: []
      }
    })
  end

  test "ningbo - edge wait no baida" do
    TestUtils.test_yaku_advanced("ningbo", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "5m", "5m", "8m", "8m", "8m", "1z", "1z", "1m", "2m"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"]
      },
      "starting_draws": ["6m", "3m"],
      "starting_dead_wall": ["9s"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "3m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Half Flush", 2}, {"No Baida", 1}, {"Edge Wait", 1}],
        yaku2: []
      }
    })
  end

  test "ningbo - single wait win on baida" do
    TestUtils.test_yaku_advanced("ningbo", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "5m", "5m", "8m", "8m", "8m", "4s", "4s", "4s", "5s"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "5s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "5s", "6s"]
      },
      "starting_draws": ["6m", "8s"],
      "starting_dead_wall": ["7s"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "8s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"All Triplets", 2}, {"Win On Baida", 1}, {"Single Wait", 1}],
        yaku2: []
      }
    })
  end

  test "ningbo - closed wait win on baida" do
    TestUtils.test_yaku_advanced("ningbo", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "5m", "5m", "8m", "8m", "8m", "1z", "1z", "4m", "6m"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"]
      },
      "starting_draws": ["6m", "8s"],
      "starting_dead_wall": ["7s"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "8s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Half Flush", 2}, {"Win On Baida", 1}, {"Closed Wait", 1}],
        yaku2: []
      }
    })
  end

  test "ningbo - edge wait win on baida" do
    TestUtils.test_yaku_advanced("ningbo", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "5m", "5m", "8m", "8m", "8m", "1z", "1z", "8m", "9m"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"]
      },
      "starting_draws": ["6m", "8s"],
      "starting_dead_wall": ["7s"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "8s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Half Flush", 2}, {"Win On Baida", 1}, {"Edge Wait", 1}],
        yaku2: []
      }
    })
  end

  test "ningbo - round and seat winds" do
    TestUtils.test_yaku_advanced("ningbo", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "5m", "5m", "8m", "8m", "8m", "1z", "1z", "1m", "2m"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"]
      },
      "starting_draws": ["6m", "8s"],
      "starting_dead_wall": ["7s"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "8s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Half Flush", 2}, {"Win On Baida", 1}, {"Round Wind", 1}, {"Seat Wind", 1}],
        yaku2: []
      }
    })
  end

  test "ningbo - white dragon" do
    TestUtils.test_yaku_advanced("ningbo", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "5m", "5m", "0z", "0z", "0z", "4s", "4s", "5s", "5s"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "5s", "6s"]
      },
      "starting_draws": ["6m", "5s"],
      "starting_dead_wall": ["9m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"All Triplets", 2}, {"No Baida", 1}, {"White Dragon", 1}],
        yaku2: []
      }
    })
  end

  test "ningbo - half flush" do
    TestUtils.test_yaku_advanced("ningbo", [], """
    {
      "starting_hand": {
        "east": ["1m", "1m", "3m", "3m", "3m", "5m", "5m", "5m", "8m", "8m", "8m", "7z", "7z"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"]
      },
      "starting_draws": ["6m", "1m"],
      "starting_dead_wall": ["1z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "1m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"All Triplets", 2}, {"No Baida", 1}, {"Half Flush", 2}],
        yaku2: []
      }
    })
  end

  test "ningbo - pure flush" do
    TestUtils.test_yaku_advanced("ningbo", [], """
    {
      "starting_hand": {
        "east": ["1m", "1m", "3m", "3m", "3m", "5m", "5m", "5m", "8m", "8m", "8m", "9m", "9m"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"]
      },
      "starting_draws": ["6m", "1m"],
      "starting_dead_wall": ["1z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "1m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"All Triplets", 2}, {"No Baida", 1}, {"Pure Flush", 4}],
        yaku2: []
      }
    })
  end

  test "ningbo - after a kong" do
    TestUtils.test_yaku_advanced("ningbo", [], """
    {
      "starting_hand": {
        "east": ["6m", "7m", "8m", "5p", "6p", "7p", "8p", "9p", "9p", "9p", "2m", "2m", "2m"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "2m"],
      "starting_dead_wall": ["6z", "7p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "2m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "daiminkan"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"After a Kong", 1}, {"Edge Wait", 1}, {"No Baida", 1}, {"Self Draw", 1}],
        yaku2: [{"After a Kong", 2}]
      }
    })
  end

  test "ningbo - after a kong baida reuse" do
    TestUtils.test_yaku_advanced("ningbo", [], """
    {
      "starting_hand": {
        "east": ["6m", "7m", "8m", "8p", "9p", "9p", "9p", "5s", "6s", "7s", "2m", "2m", "2m"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "2m"],
      "starting_dead_wall": ["6p", "7p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "2m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "daiminkan"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"After a Kong", 1}, {"Edge Wait", 1}, {"Self Draw", 1}, {"Win On Baida", 1}, {"Baida Reuse", 1}],
        yaku2: [{"After a Kong", 2}]
      }
    })
  end

  test "ningbo - baida pair win" do
    TestUtils.test_yaku_advanced("ningbo", [], """
    {
      "starting_hand": {
        "east": ["6m", "7m", "8m", "7p", "9p", "9p", "9p", "5s", "6s", "7s", "2m", "2m", "2m"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "2z", "3z", "4z", "6p"],
      "starting_dead_wall": ["6p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4z", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Single Wait", 1}, {"Self Draw", 1}, {"Win On Baida", 1}, {"Baida Reuse", 1}, {"Baida Pair Win", 1}],
        yaku2: []
      }
    })
  end

  test "ningbo - baida reuse counts towards 4 han minimum" do
    TestUtils.test_yaku_advanced("ningbo", [], """
    {
      "starting_hand": {
        "east": ["6m", "7m", "8m", "7p", "9p", "9p", "9p", "5s", "6s", "7s", "2m", "2m", "2m"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "2z", "3z", "4z", "8p"],
      "starting_dead_wall": ["6m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4z", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Closed Wait", 1}, {"Self Draw", 1}, {"Baida Reuse", 2}],
        yaku2: []
      }
    })
  end

  test "ningbo - all honours" do
    TestUtils.test_yaku_advanced("ningbo", [], """
    {
      "starting_hand": {
        "east": ["1z", "1z", "1z", "2z", "2z", "0z", "0z", "0z", "6z", "6z", "6z", "7z", "7z"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"]
      },
      "starting_draws": ["6m", "7z"],
      "starting_dead_wall": ["9m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "7z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"No Baida", 1}, {"All Honours", 10}, {"Round Wind", 1}, {"Seat Wind", 1}, {"White Dragon", 1}, {"Green Dragon", 1}, {"Red Dragon", 1}],
        yaku2: []
      }
    })
  end

  test "ningbo - blessing of heaven" do
    TestUtils.test_yaku_advanced("ningbo", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "8m", "3s", "4s", "4p", "5p", "6p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"]
      },
      "starting_draws": ["5s"],
      "starting_dead_wall": ["9m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Blessing of Heaven", 10}, {"Closed Wait", 1}, {"No Baida", 1}],
        yaku2: []
      }
    })
  end

  test "ningbo - blessing of earth" do
    TestUtils.test_yaku_advanced("ningbo", [], """
    {
      "starting_hand": {
        "east": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "south": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "8m", "3s", "4s", "4p", "5p", "6p"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"]
      },
      "starting_draws": ["5s"],
      "starting_dead_wall": ["9m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "5s", "player" => 0, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ron"}, nil, nil]}
    ], %{
      south: %{
        yaku: [{"Blessing of Earth", 10}, {"No Baida", 1}],
        yaku2: []
      }
    })
  end

  test "ningbo - robbing a kong" do
    TestUtils.test_yaku_advanced("ningbo", [], """
    {
      "starting_hand": {
        "east": ["6m", "7m", "8m", "1z", "6p", "7p", "8p", "9p", "9p", "9p", "2m", "2m", "2m"],
        "south": ["1m", "4m", "7m", "2p", "4p", "8p", "3s", "6s", "9s", "1z", "2m", "5p", "5p"],
        "west": ["1m", "4m", "7m", "2p", "4p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "4p", "9p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["5p", "5p"],
      "starting_dead_wall": ["7z", "8p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "5p", "player" => 0, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "pon"}, nil, nil]},
      %{"type" => "discard", "tile" => "2m", "player" => 1, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "daiminkan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "kakan"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chankan"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"No Baida", 1}, {"Robbing a Kong", 0}],
        yaku2: [{"Robbing a Kong", 5}]
      }
    })
  end

  test "ningbo - three meld penalty" do
    TestUtils.test_yaku_advanced("ningbo", [], """
    {
      "starting_hand": {
        "east": ["6m", "6m", "8m", "8m", "6p", "6p", "8p", "2z", "3z", "4z", "2m", "2m", "2m"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2m", "5p", "5p"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5s", "8s", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6m", "8m", "6p", "6z", "8p"],
      "starting_dead_wall": ["7z", "6p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "2z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "8m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "3z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "2m", "player" => 1, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "daiminkan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "4z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8p", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"All Triplets", 2}, {"No Baida", 1}, {"Single Wait", 1}],
        yaku2: [{"Three Meld Penalty", 5}]
      }
    }, %{delta_scores: [20, -20, 0, 0]})
  end

  test "ningbo - eight flowers" do
    TestUtils.test_yaku_advanced("ningbo", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "8m", "3s", "4s", "4p", "5p", "6p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"]
      },
      "starting_draws": ["1f", "5s"],
      "starting_dead_wall": ["9m", "2f", "3f", "4f", "1g", "2g", "3g", "4g", "1z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Eight Flowers", 10}, {"No Baida", 1}],
        yaku2: []
      }
    })
  end

  test "ningbo - last tile" do
    TestUtils.test_yaku_advanced("ningbo", ["show_waits"], """
    {
      "starting_hand": {
        "east": ["6m","3m","1z","3m","0z","1g","7p","2m","2p","5s","3p","9m","8s"],
        "south": ["1z","4p","1p","5m","7z","7z","8m","2p","4z","6m","7m","6p","1f"],
        "west": ["1z","9s","2z","5p","2m","0z","2z","9p","6p","6p","2p","2z","1m"],
        "north": ["2s","9m","5m","2s","4m","5s","5p","3s","1p","3z","7s","1s","4p"]
      },
      "starting_draws": ["6s","3p","3s","1s","4f","5p","6z","4m","7p","7s","1m","9p","6p","1z","2s","6z","3s","3z","6z","8m","4p","7p","1p","9m","8s","4p","3p","4m","6s","1p","4z","3s","5s","4z","9p","4s","9s","8m","1s","3p","8m","6s","3z","7s","6s","2z","7p","8p","8p","5m","2p","9m","3m","5s","0z","1s","3m","4g","4s","5p","2m","0z","7m","7z","4s","4m","8p","9s","2g","6m","2m","5m","7z","9p","6z","3g","8s","1m"],
      "starting_dead_wall": ["1m","3z","4s","7m","8s","2s","8p","9s","2f","4z","7s","3f","6m","7m"],
      "starting_round": 0,
      "starting_honba": 0
    }
    """, [
      %{"buttons" => [%{"button" => "start_flower", "call_choice" => ["1g"], "called_tile" => nil}, nil, nil, nil], "type" => "buttons_pressed"},
      %{"buttons" => [%{"button" => "start_no_flower"}, %{"button" => "start_flower", "call_choice" => ["1f"], "called_tile" => nil}, nil, nil], "type" => "buttons_pressed"},
      %{"buttons" => [nil, %{"button" => "start_no_flower"}, %{"button" => "start_no_flower"}, %{"button" => "start_no_flower"}], "type" => "buttons_pressed"},
      %{"player" => 0, "tile" => "0z", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "4z", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 2, "tile" => "3s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "1s", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [%{"button" => "flower", "call_choice" => ["4f"], "called_tile" => nil}, nil, nil, nil], "type" => "buttons_pressed"},
      %{"player" => 0, "tile" => "7m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "1z", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 2, "tile" => "6z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "4m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "7p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "4s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 2, "tile" => "1m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "9p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "6p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "7s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 2, "tile" => "2s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "6z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "3s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "1z", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 2, "tile" => "6z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "8m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "4p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "3z", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 2, "tile" => "1p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "9m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "8s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "8m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 2, "tile" => "3p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "4m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "6s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "4p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 2, "tile" => "4z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "3s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "5s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "4z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "9p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "4s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "9s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "8m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "1s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "3p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "8m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "6s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "3z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "7s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "6s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "2z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "7p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "8p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "8p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "5m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "2p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "9m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "3m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "5s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "0z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "1s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "3m", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [nil, %{"button" => "flower", "call_choice" => ["4g"], "called_tile" => nil}, nil, nil], "type" => "buttons_pressed"},
      %{"player" => 1, "tile" => "8s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "4s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "5p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "2m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "0z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "7m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "7z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "4s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "4m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "8p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "9s", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [%{"button" => "flower", "call_choice" => ["2g"], "called_tile" => nil}, nil, nil, nil], "type" => "buttons_pressed"},
      %{"player" => 0, "tile" => "2s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "6m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "2m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "5m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "7z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "9p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "6z", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [nil, nil, nil, %{"button" => "flower", "call_choice" => ["3g"], "called_tile" => nil}], "type" => "buttons_pressed"},
      %{"player" => 3, "tile" => "8p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "8s", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [nil, %{"button" => "tsumo"}, nil, nil], "type" => "buttons_pressed"}
    ], %{
      south: %{
        yaku: [{"Win On Baida", 1}, {"Last Tile", 1}, {"Self Draw", 1}, {"Red Dragon", 1}],
        yaku2: []
      }
    })
  end

end
