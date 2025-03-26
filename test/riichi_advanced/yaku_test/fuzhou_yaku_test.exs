defmodule RiichiAdvanced.YakuTest.FuzhouYaku do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "fuzhou - chicken hand no flowers" do
    TestUtils.test_yaku_advanced("fuzhou", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "8m", "3s", "4s", "4p", "5p", "6p", "7p", "8p", "9p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"]
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
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Base Points", 10}]
      }
    })
  end

  test "fuzhou - only one flower" do
    TestUtils.test_yaku_advanced("fuzhou", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "8m", "3f", "4s", "4p", "5p", "6p", "7p", "8p", "9p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["6m", "5s"],
      "starting_dead_wall": ["9m", "3s"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Base Points", 10}, {"Flowers", 2}, {"Only One Flower", 15}]
      }
    })
  end

  test "fuzhou - flower jin as jin scores gold, not flower" do
    TestUtils.test_yaku_advanced("fuzhou", ["discardable_flowers"], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "8m", "2s", "4s", "4p", "5p", "6p", "7p", "8p", "9p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["2f", "3s"],
      "starting_dead_wall": ["1f"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "2s", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "3s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Base Points", 10}, {"Gold", 2}]
      }
    })
  end

  test "fuzhou - flower jin as flower scores both gold and flower" do
    TestUtils.test_yaku_advanced("fuzhou", ["discardable_flowers"], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "8m", "2s", "4s", "4p", "5p", "6p", "7p", "8p", "9p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["2f", "3s"],
      "starting_dead_wall": ["1f", "9s"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "9s", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Base Points", 10}, {"Flowers", 2}, {"Gold", 2}, {"Only One Flower", 15}]
      }
    })
  end

  test "fuzhou - dealer continuation" do
    TestUtils.test_yaku_advanced("fuzhou", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "8m", "3s", "4s", "4p", "5p", "6p", "7p", "8p", "9p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["6m", "5s"],
      "starting_dead_wall": ["9m"],
      "starting_honba": 1
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Base Points", 10}, {"Dealer Continuation", 2}]
      }
    })
  end

  test "fuzhou - closed kong" do
    TestUtils.test_yaku_advanced("fuzhou", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "8m", "3s", "4s", "4p", "5p", "6p", "7p", "8p", "9p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["3m", "5s"],
      "starting_dead_wall": ["9m", "6m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Base Points", 10}, {"Concealed Kong", 2}]
      }
    })
  end

  test "fuzhou - open kong" do
    TestUtils.test_yaku_advanced("fuzhou", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "8m", "3s", "4s", "4p", "5p", "6p", "7p", "8p", "9p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["6m", "3m", "5s"],
      "starting_dead_wall": ["9m", "6m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "daiminkan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Base Points", 10}, {"Open Kong", 2}]
      }
    })
  end

  test "fuzhou - open and closed kong" do
    TestUtils.test_yaku_advanced("fuzhou", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "5m", "8m", "8m", "8m", "3s", "4s", "4p", "5p", "6p", "7p", "8p", "9p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["6m", "3m", "5s"],
      "starting_dead_wall": ["9m", "8m", "6m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "daiminkan"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Base Points", 10}, {"Concealed Kong", 2}, {"Open Kong", 2}]
      }
    })
  end

  test "fuzhou - full bloom with flowers" do
    TestUtils.test_yaku_advanced("fuzhou", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "1f", "2f", "3f", "4f", "8m", "3s", "4s", "4p", "5p", "6p", "7p", "8p", "9p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["6m", "5s"],
      "starting_dead_wall": ["9m", "5m", "6m", "7m", "8m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower", "call_choice" => ["1f"]}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower", "call_choice" => ["2f"]}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower", "call_choice" => ["3f"]}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower", "call_choice" => ["4f"]}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Base Points", 10}, {"Flowers", 8}, {"Full Bloom (Flowers)", 12}]
      }
    })
  end

  test "fuzhou - full bloom with honors" do
    TestUtils.test_yaku_advanced("fuzhou", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "1z", "1z", "1z", "1z", "8m", "3s", "4s", "4p", "5p", "6p", "7p", "8p", "9p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["6m", "5s"],
      "starting_dead_wall": ["9m", "5m", "6m", "7m", "8m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Base Points", 10}, {"Flowers", 8}, {"Full Bloom (East)", 12}]
      }
    })
  end

  test "fuzhou - all sequences" do
    TestUtils.test_yaku_advanced("fuzhou", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "6m", "7m", "8m", "8m", "3s", "4s", "4p", "5p", "6p", "7p", "8p", "9p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"]
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
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Base Points", 10}, {"All Sequences", 10}]
      }
    })
  end

  test "fuzhou - golden pair" do
    TestUtils.test_yaku_advanced("fuzhou", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "8m", "3s", "4s", "4p", "5p", "6p", "7p", "8p", "9p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["6m", "5s"],
      "starting_dead_wall": ["8m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Base Points", 10}, {"Golden Pair", 20}]
      }
    })
  end

  test "fuzhou - golden dragon" do
    TestUtils.test_yaku_advanced("fuzhou", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "5m", "6m", "7m", "8m", "8m", "8m", "3s", "4s", "4p", "5p", "6p", "7p", "8p", "9p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["6m", "5s"],
      "starting_dead_wall": ["8m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: [
        %{yaku: [{"Base Points", 10}, {"Golden Dragon", 40}]},
        %{yaku: [{"All Sequences", 10}, {"Base Points", 10}, {"Three Gold Knockdown", 30}]},
      ]
    })
  end

  test "fuzhou - golden pair tanki tsumo" do
    TestUtils.test_yaku_advanced("fuzhou", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "6m", "6m", "7m", "8m", "2s", "3s", "4s", "4p", "5p", "6p", "7p", "8p", "9p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["5m", "5s", "3s", "1s", "8m"],
      "starting_dead_wall": ["8m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1s", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Base Points", 10}, {"Golden Pair", 20}]
      }
    })
  end

  test "fuzhou - golden dragon shanpon tsumo" do
    TestUtils.test_yaku_advanced("fuzhou", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "6m", "6m", "7m", "8m", "8m", "2s", "3s", "4s", "4p", "5p", "6p", "7p", "8p", "9p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["5m", "5s", "3s", "1s", "8m"],
      "starting_dead_wall": ["8m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "5m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1s", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: [
        %{yaku: [{"Base Points", 10}, {"Golden Dragon", 40}]},
        %{yaku: [{"All Sequences", 10}, {"Base Points", 10}, {"Three Gold Knockdown", 30}]},
      ]
    })
  end

  test "fuzhou - three gold knockdown" do
    TestUtils.test_yaku_advanced("fuzhou", [], """
    {
      "starting_hand": {
        "east": ["3m", "9m", "3m", "5m", "6m", "9m", "8m", "8m", "3s", "4s", "4p", "5p", "9m", "7p", "8p", "9p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"]
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
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Base Points", 10}, {"Three Gold Knockdown", 30}]
      }
    })
  end

  test "fuzhou - blessing of heaven" do
    TestUtils.test_yaku_advanced("fuzhou", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "8m", "3s", "4s", "4p", "5p", "6p", "7p", "8p", "9p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"]
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
        yaku: [{"Base Points", 10}, {"Blessing of Heaven", 50}]
      }
    })
  end

  test "fuzhou - blessing of earth" do
    TestUtils.test_yaku_advanced("fuzhou", [], """
    {
      "starting_hand": {
        "east": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "south": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "8m", "3s", "4s", "4p", "5p", "6p", "7p", "8p", "9p"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["1m", "5s"],
      "starting_dead_wall": ["9m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "tsumo"}, nil, nil]}
    ], %{
      south: %{
        yaku: [{"Base Points", 10}, {"Blessing of Earth", 40}]
      }
    })
  end

  test "fuzhou - robbing the gold" do
    TestUtils.test_yaku_advanced("fuzhou", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "8m", "3s", "4s", "4p", "5p", "6p", "7p", "8p", "9p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_dead_wall": ["2s"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "qiangjin"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Base Points", 10}, {"Robbing the Gold", 50}]
      }
    })
  end

  test "fuzhou - robbing the gold as north" do
    TestUtils.test_yaku_advanced("fuzhou", [], """
    {
      "starting_hand": {
        "east": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "8m", "3s", "4s", "4p", "5p", "6p", "7p", "8p", "9p"]
      },
      "starting_dead_wall": ["2s"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "qiangjin"}]}
    ], %{
      north: %{
        yaku: [{"Base Points", 10}, {"Robbing the Gold", 50}]
      }
    })
  end

end
