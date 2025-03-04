defmodule RiichiAdvanced.YakuTest.FuzhouYaku do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "fuzhou - chicken hand no flowers" do
    TestUtils.test_yaku_advanced("fuzhou", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "6m", "7m", "8m", "8m", "3s", "4s", "4p", "5p", "6p", "7p", "8p", "9p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["8p", "5s"],
      "starting_dead_wall": ["9m"]

    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "8p", "player" => 0, "tsumogiri" => true},
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
        "east": ["2m", "3m", "4m", "5m", "6m", "7m", "8m", "8m", "3f", "4s", "4p", "5p", "6p", "7p", "8p", "9p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "5s", "6s", "7s", "8s"]
      },
      "starting_draws": ["8p", "5s"],
      "starting_dead_wall": ["9m", "3s"]

    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "8p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Base Points", 10}, {"Flowers", 2}, {"Only One Flower", 15}]
      }
    })
  end

  test "fuzhou - flower jin scores gold, not flower" do
    TestUtils.test_yaku_advanced("fuzhou", ["discardable_flowers"], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "6m", "7m", "8m", "8m", "2s", "4s", "4p", "5p", "6p", "7p", "8p", "9p"],
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

end
