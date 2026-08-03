defmodule RiichiAdvanced.YakuTest.FuzhouMechanicsTest do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  @base {"Base Points", [10, ""]}

  test "fuzhou - tenpai is not win (0 jin)" do
    TestUtils.test_yaku_advanced("fuzhou", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "9m", "3s", "4s", "4p", "5p", "6p", "7p", "8p", "9p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "1m", "9p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["6m", "5s"],
      "starting_dead_wall": ["1m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
    ], :no_winners)
  end

  test "fuzhou - iishanten is not win (1 jin)" do
    TestUtils.test_yaku_advanced("fuzhou", [], """
    {
      "starting_hand": {
        "east": ["1m", "3m", "3m", "5m", "6m", "7m", "8m", "9m", "3s", "4s", "4p", "5p", "6p", "7p", "8p", "9p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "1m", "9p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["6m", "5s"],
      "starting_dead_wall": ["9m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
    ], :no_winners)
  end

  test "fuzhou - ryanshanten is not win (2 jin)" do
    TestUtils.test_yaku_advanced("fuzhou", [], """
    {
      "starting_hand": {
        "east": ["1m", "3m", "3m", "5m", "6m", "7m", "9m", "9m", "3s", "4s", "4p", "5p", "6p", "7p", "8p", "8p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "1m", "9p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["6m", "5s"],
      "starting_dead_wall": ["9m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
    ], :no_winners)
  end

  test "fuzhou - sanshanten is not win (3 jin)" do
    TestUtils.test_yaku_advanced("fuzhou", [], """
    {
      "starting_hand": {
        "east": ["1m", "3m", "3m", "5m", "6m", "9m", "9m", "9m", "3s", "4s", "4p", "5p", "6p", "7p", "8p", "8p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "1m", "9p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["6m", "5s"],
      "starting_dead_wall": ["9m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
    ], :no_winners)
  end

  test "fuzhou - win is win (0 jin)" do
    TestUtils.test_yaku_advanced("fuzhou", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "8m", "3s", "4s", "4p", "5p", "6p", "7p", "8p", "9p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "1m", "9p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["6m", "5s"],
      "starting_dead_wall": ["1m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]},
    ], %{
      east: %{
        yaku: [@base]
      }
    })
  end

  test "fuzhou - tenpai is win (1 jin)" do
    TestUtils.test_yaku_advanced("fuzhou", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "3m", "6m", "7m", "8m", "9m", "3s", "4s", "4p", "5p", "6p", "7p", "8p", "9p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "1m", "9p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["6m", "5s"],
      "starting_dead_wall": ["9m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]},
    ], %{
      east: %{
        yaku: [@base, {"Gold", [2, ""]}]
      }
    })
  end

  test "fuzhou - iishanten is win (2 jin)" do
    TestUtils.test_yaku_advanced("fuzhou", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "6m", "7m", "9m", "9m", "3s", "4s", "4p", "5p", "6p", "7p", "8p", "8p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "1m", "9p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["6m", "5s"],
      "starting_dead_wall": ["9m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]},
    ], %{
      east: %{
        yaku: [@base, {"Gold", [4, ""]}]
      }
    })
  end

  test "fuzhou - ryanshanten is win (3 jin)" do
    TestUtils.test_yaku_advanced("fuzhou", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "6m", "9m", "9m", "9m", "3s", "4s", "4p", "5p", "6p", "7p", "8p", "8p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "1m", "9p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["6m", "5s"],
      "starting_dead_wall": ["9m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]},
    ], %{
      east: %{
        yaku: [@base, {"Three Gold Knockdown", [30, ""]}]
      }
    })
  end

end
