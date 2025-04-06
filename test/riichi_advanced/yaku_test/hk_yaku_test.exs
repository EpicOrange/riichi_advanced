defmodule RiichiAdvanced.YakuTest.HKOSYaku do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "hk - chicken hand" do
    TestUtils.test_yaku_advanced("hk", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "5m", "5m", "5m", "7m", "8m", "9m", "8s", "7p", "8p", "2f"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "7z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "7z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "7z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6z", "6z", "6p", "8s"],
      "starting_dead_wall": ["1z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "8s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: []
      }
    })
  end

  test "hk - seat flower" do
    TestUtils.test_yaku_advanced("hk", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "5m", "5m", "5m", "7m", "8m", "9m", "8s", "7p", "8p", "1f"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "7z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "7z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "7z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6z", "6z", "6p", "8s"],
      "starting_dead_wall": ["1z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "8s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Seat Flower", 1}]
      }
    })
  end

  test "hk - seat season" do
    TestUtils.test_yaku_advanced("hk", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "5m", "5m", "5m", "7m", "8m", "9m", "8s", "7p", "8p", "1g"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "7z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "7z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "7z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6z", "6z", "6p", "8s"],
      "starting_dead_wall": ["1z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "8s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Seat Season", 1}]
      }
    })
  end

  test "hk - all flowers" do
    TestUtils.test_yaku_advanced("hk", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "5m", "5m", "5m", "7m", "8m", "9m", "8s", "6p", "6p", "4f"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "7z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "7z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "1z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6p", "1f", "8s"],
      "starting_dead_wall": ["6z", "2f", "3f", "6z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "pon"}]},
      %{"type" => "discard", "tile" => "4z", "player" => 3, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Seat Flower", 1}, {"All Flowers", 2}]
      }
    })
  end
  

  test "hk - all seasons" do
    TestUtils.test_yaku_advanced("hk", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "5m", "5m", "5m", "7m", "8m", "9m", "8s", "6p", "6p", "4g"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "7z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "7z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "1z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6p", "1g", "8s"],
      "starting_dead_wall": ["6z", "2g", "3g", "6z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "pon"}]},
      %{"type" => "discard", "tile" => "4z", "player" => 3, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Seat Season", 1}, {"All Seasons", 2}]
      }
    })
  end

  test "hk - seven flowers automatically wins" do
    TestUtils.test_yaku_advanced("hk", [%{name: "seven_flower_win", config: %{win_on: "7 flowers"}}], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "5m", "5m", "5m", "7m", "8m", "9m", "8s", "6p", "6p", "4g"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "7z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "7z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "1z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6p", "5m"],
      "starting_dead_wall": ["6z", "1g", "2g", "3g", "1f", "2f", "3f"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "pon"}]},
      %{"type" => "discard", "tile" => "4z", "player" => 3, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower_win"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"After a Flower", 1}, {"All Seasons", 2}, {"Seat Flower", 1}, {"Seat Season", 1}, {"Seven Flowers", 3}, {"Self Draw", 1}]
      }
    })
  end

  test "hk - eight flowers automatically wins" do
    TestUtils.test_yaku_advanced("hk", [%{name: "seven_flower_win", config: %{win_on: "8 flowers"}}], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "5m", "5m", "5m", "7m", "8m", "9m", "8s", "6p", "6p", "4g"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "7z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "7z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "1z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6p", "5m"],
      "starting_dead_wall": ["6z", "1g", "2g", "3g", "1f", "2f", "3f", "4f"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "pon"}]},
      %{"type" => "discard", "tile" => "4z", "player" => 3, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower_win"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"After a Flower", 1}, {"All Seasons", 2}, {"Seat Flower", 1}, {"Seat Season", 1}, {"Eight Flowers", 8}, {"Self Draw", 1}]
      }
    })
  end

  test "hk - can skip seven flower win" do
    TestUtils.test_yaku_advanced("hk", [%{name: "seven_flower_win", config: %{win_on: "7 flowers"}}], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "5m", "5m", "5m", "7m", "8m", "9m", "8s", "6p", "6p", "4g"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "7z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "7z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "1z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6p", "1g", "8s"],
      "starting_dead_wall": ["6z", "2g", "3g", "1f", "2f", "3f", "6z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "pon"}]},
      %{"type" => "discard", "tile" => "4z", "player" => 3, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true}
    ], :no_winners)
  end

  test "hk - can't win with seven flowers if eight flowers is the threshold" do
    TestUtils.test_yaku_advanced("hk", [%{name: "seven_flower_win", config: %{win_on: "8 flowers"}}], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "5m", "5m", "5m", "7m", "8m", "9m", "8s", "6p", "6p", "4g"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "7z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "7z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "1z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6p", "1g", "8s"],
      "starting_dead_wall": ["6z", "2g", "3g", "1f", "2f", "3f", "6z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "pon"}]},
      %{"type" => "discard", "tile" => "4z", "player" => 3, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "flower"}, nil, nil, nil]},
    ], :no_winners)
  end

  test "hk - after a kan, half flush, self drawn concealed hand" do
    TestUtils.test_yaku_advanced("hk", [], """
    {
      "starting_hand": {
        "east": ["1m", "1m", "1m", "6m", "7m", "8m", "3z", "3z", "3z", "4z", "4z", "1z", "1z"],
        "south": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "0z", "6z", "7z"],
        "west": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "0z", "6z", "7z"],
        "north": ["2m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "0z", "6z", "7z"]
      },
      "starting_draws": ["1m"],
      "starting_dead_wall": ["4z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Concealed Hand", 1}, {"No Flowers", 1}, {"Half Flush", 3}, {"After a Kong", 1}, {"Self Draw", 1}]
      }
    })
  end

  test "hk - twofold fortune" do
    TestUtils.test_yaku_advanced("hk", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "5m", "5m", "5m", "8m", "9m", "8s", "8s", "8s", "9s", "9s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "7s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "7s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "7s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["5m"],
      "starting_dead_wall": ["8s", "7m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"After Multiple Kongs", 8}, {"Concealed Hand", 1}, {"No Flowers", 1}, {"Self Draw", 1}]
      }
    })
  end

  test "hk - chankan" do
    TestUtils.test_yaku_advanced("hk", [], """
    {
      "starting_hand": {
        "east": ["2m", "2m", "2m", "3m", "3m", "4m", "4m", "7p", "8p", "9p", "7m", "8m", "1m"],
        "south": ["9m", "9m", "3m", "2p", "5p", "6p", "3s", "6s", "8s", "2s", "4s", "5s", "7s"],
        "west": ["1m", "4m", "7m", "2p", "5p", "6p", "3s", "6s", "8s", "2s", "4s", "5s", "7s"],
        "north": ["1m", "4m", "7m", "2p", "5p", "6p", "3s", "6s", "8s", "1s", "9s", "9s", "9s"]
      },
      "starting_draws": ["9m", "9m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "9m", "player" => 0, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "pon"}, nil, nil]},
      %{"type" => "discard", "tile" => "3m", "player" => 1, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "kakan"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chankan"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"No Flowers", 1}, {"Robbing a Kong", 1}]
      }
    })
  end

  test "hk - all sequences full flush" do
    TestUtils.test_yaku_advanced("hk", [], """
    {
      "starting_hand": {
        "east": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "0z", "6z", "7z"],
        "south": ["1m", "2m", "2m", "3m", "3m", "3m", "4m", "4m", "5m", "7m", "7m", "7m", "8m"],
        "west": ["4m", "8m", "2p", "3p", "5p", "8p", "3s", "6s", "9s", "2z", "0z", "6z", "7z"],
        "north": ["2m", "3m", "8m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "0z", "6z", "7z"]
      },
      "starting_draws": ["1m", "1m", "6m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "1m", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6m", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ron"}, nil, nil]}
    ], %{
      south: %{
        yaku: [{"All Sequences", 1}, {"Concealed Hand", 1}, {"No Flowers", 1}, {"Full Flush", 7}]
      }
    })
  end

  test "hk - white dragon" do
    TestUtils.test_yaku_advanced("hk", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "5m", "5m", "5m", "7m", "8m", "9m", "0z", "0z", "0z", "6p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Concealed Hand", 1}, {"No Flowers", 1}, {"White Dragon", 1}]
      }
    })
  end

  test "hk - green dragon" do
    TestUtils.test_yaku_advanced("hk", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "5m", "5m", "5m", "7m", "8m", "9m", "6z", "6z", "6z", "6p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Concealed Hand", 1}, {"No Flowers", 1}, {"Green Dragon", 1}]
      }
    })
  end

  test "hk - red dragon" do
    TestUtils.test_yaku_advanced("hk", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "5m", "5m", "5m", "7m", "8m", "9m", "7z", "7z", "7z", "6p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Concealed Hand", 1}, {"No Flowers", 1}, {"Red Dragon", 1}]
      }
    })
  end

  test "hk - prevalent and seat wind" do
    TestUtils.test_yaku_advanced("hk", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "5m", "5m", "5m", "7m", "8m", "9m", "1z", "1z", "1z", "6p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "7z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "7z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "7z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2z", "6p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "2z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Concealed Hand", 1}, {"No Flowers", 1}, {"Prevalent Wind", 1}, {"Seat Wind", 1}]
      }
    })
  end

  test "hk - non-prevalent or seat wind" do
    TestUtils.test_yaku_advanced("hk", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "2z", "2z", "2z", "3z", "3z", "3z", "4z", "4z", "6p", "6p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "0z", "6z", "7z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "0z", "6z", "7z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "0z", "6z", "7z"]
      },
      "starting_draws": ["2z", "4z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "2z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "4z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Concealed Hand", 1}, {"No Flowers", 1}]
      }
    })
  end

  test "hk - little three dragons" do
    TestUtils.test_yaku_advanced("hk", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "4p", "4p", "4p", "0z", "0z", "0z", "6z", "6z", "7z", "7z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Concealed Hand", 1}, {"No Flowers", 1}, {"No Flowers", 1}, {"Little Three Dragons", 5}, {"Concealed Hand", 1}, {"Green Dragon", 1}, {"White Dragon", 1}]
      }
    })
  end

  test "hk - daisangen tsuuiisou suuankou" do
    TestUtils.test_yaku_advanced("hk", [], """
    {
      "starting_hand": {
        "east": ["0z", "0z", "0z", "6z", "6z", "6z", "2z", "2z", "3z", "3z", "7z", "7z", "7z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "7s", "8s", "9s", "1z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "7s", "8s", "9s", "1z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "7s", "8s", "9s", "1z", "4z"]
      },
      "starting_draws": ["7z"],
      "starting_dead_wall": ["2z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"After a Kong", 1}, {"All Honours", 10}, {"Big Three Dragons", 8}, {"Concealed Hand", 1}, {"Four Concealed Triplets", 8}, {"No Flowers", 1}, {"Self Draw", 1}]
      }
    })
  end

  test "hk - chousuushii" do
    TestUtils.test_yaku_advanced("hk", [], """
    {
      "starting_hand": {
        "east": ["1z", "1z", "1z", "2z", "2z", "2z", "3z", "3z", "3z", "4z", "4z", "5m", "1p"],
        "south": ["1m", "9m", "1p", "9p", "1s", "2s", "3s", "9s", "0z", "6z", "7z", "7z", "7z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "4s", "5s", "6s", "7s", "8s", "9s"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "4s", "5s", "6s", "7s", "8s", "9s"]
      },
      "starting_draws": ["1z", "2z", "3z", "4z", "2m", "3m", "4m", "4z"],
      "starting_dead_wall": ["5m", "5m", "5m", "1p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "5m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "daiminkan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "5m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "daiminkan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "5m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "5m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "2m", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3m", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4m", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "kakan"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"After a Kong", 1}, {"Big Four Winds", 13}, {"Four Kongs", 13}, {"Half Flush", 3}, {"Mixed Terminals", 4}, {"No Flowers", 1}, {"Self Draw", 1}]
      }
    })
  end

  test "hk - all triplets, three concealed" do
    TestUtils.test_yaku_advanced("hk", [], """
    {
      "starting_hand": {
        "east": ["2m", "2m", "2m", "5m", "5m", "5m", "9m", "9m", "9m", "8s", "8s", "6p", "6p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Concealed Hand", 1}, {"No Flowers", 1}, {"All Triplets", 3}]
      }
    })
  end

  test "hk - mixed terminals" do
    TestUtils.test_yaku_advanced("hk", [], """
    {
      "starting_hand": {
        "east": ["1m", "1m", "1m", "9p", "9p", "9p", "3z", "3z", "3z", "4z", "4z", "1z", "1z"],
        "south": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "0z", "6z", "7z"],
        "west": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "0z", "6z", "7z"],
        "north": ["2m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "0z", "6z", "7z"]
      },
      "starting_draws": ["2z", "4z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "2z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "4z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Concealed Hand", 1}, {"No Flowers", 1}, {"All Triplets", 3}, {"Mixed Terminals", 4}]
      }
    })
  end

  test "hk - chinroutou" do
    TestUtils.test_yaku_advanced("hk", [], """
    {
      "starting_hand": {
        "east": ["1m", "1m", "1m", "1p", "1p", "1p", "9p", "9p", "9s", "9s", "1s", "1s", "7z"],
        "south": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "2z", "3z", "4z"],
        "west": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "2z", "3z", "4z"],
        "north": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "1s", "9s"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "1s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "7z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "9s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"No Flowers", 1}, {"All Terminals", 13}]
      }
    })
  end 

  test "hk - tenhou kokushi" do
    TestUtils.test_yaku_advanced("hk", [], """
    {
      "starting_hand": {
        "east": ["1m", "9m", "1p", "9p", "1s", "9s", "1z", "1z", "3z", "4z", "0z", "6z", "7z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "3z", "4z", "0z"]
      },
      "starting_draws": ["2f"],
      "starting_dead_wall": ["2z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Blessing of Heaven", 13}, {"Thirteen Orphans", 13}]
      }
    })
  end

  test "hk - chuurenpoutou" do
    TestUtils.test_yaku_advanced("hk", [], """
    {
      "starting_hand": {
        "east": ["2m", "4m", "8m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "south": ["1m", "1m", "1m", "2m", "3m", "4m", "5m", "7m", "1f", "8m", "9m", "9m", "9m"],
        "west": ["2m", "4m", "8m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["2m", "4m", "8m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6m"],
      "starting_dead_wall": ["7m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "tsumo"}, nil, nil]}
    ], %{
      south: %{
        yaku: [{"Self Draw", 1}, {"Nine Gates", 13}]
      }
    })
  end

  test "hk - kokushi tenhou" do
    TestUtils.test_yaku_advanced("hk", [], """
    {
      "starting_hand": {
        "east": ["1m", "9m", "1p", "9p", "1s", "9s", "1z", "1z", "3z", "4z", "0z", "6z", "7z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "3z", "4z", "0z"]
      },
      "starting_draws": ["2z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"No Flowers", 1}, {"Blessing of Heaven", 13}, {"Thirteen Orphans", 13}]
      }
    })
  end

  test "hk - chuurenpoutou chiihou" do
    TestUtils.test_yaku_advanced("hk", [], """
    {
      "starting_hand": {
        "east": ["2m", "4m", "8m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "south": ["1m", "1m", "1m", "2m", "3m", "4m", "5m", "7m", "7m", "8m", "9m", "9m", "9m"],
        "west": ["2m", "4m", "8m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["2m", "4m", "8m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ron"}, nil, nil]}
    ], %{
      south: %{
        yaku: [{"No Flowers", 1}, {"Blessing of Earth", 13}, {"Nine Gates", 13}]
      }
    })
  end

  test "hk - shousangen renhou" do
    TestUtils.test_yaku_advanced("hk", [], """
    {
      "starting_hand": {
        "east": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "7s", "8s", "9s", "6z", "7z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "7s", "8s", "9s", "6z", "7z"],
        "west": ["1z", "1z", "1z", "2z", "2z", "2z", "3z", "3z", "4z", "4z", "2p", "3p", "4p"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "7s", "8s", "9s", "6z", "7z"]
      },
      "starting_draws": ["1p", "4z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1p", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "4z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "ron"}, nil]}
    ], %{
      west: %{
        yaku: [{"No Flowers", 1}, {"Blessing of Man", 13}, {"Little Four Winds", 6}, {"Prevalent Wind", 1}, {"Half Flush", 3}]
      }
    })
  end

  test "hk - haitei" do
    TestUtils.test_yaku_advanced("hk", [], """
    {
      "starting_hand": {
        "east": ["5m","8m","4z","8p","2p","4s","6m","7p","2s","6s","5p","7s","1s"],
        "south": ["1s","8s","7z","5m","5m","3s","2m","1p","2p","4p","7z","1z","3z"],
        "west": ["4z","2p","7s","0z","4z","0z","4s","6z","8p","3s","8s","8p","1s"],
        "north": ["2s","6p","2m","5p","2s","0z","3s","8m","4p","3z","9p","4s","3z"]
      },
      "starting_draws": ["7m","8p","9s","1m","3m","4m","9s","5p","7s","2f","2p","3m","5s","4m","3p","8s","1p","2z","6z","7p","5s","2z","3p","1g","2z","1m","8m","7p","7m","7z","1f","9p","8m","6m","0z","7z","3g","2m","5p","1p","6z","7p","6z","4m","3p","1m","8s","9s","1z","3m","4s","3p","4z","3f","9s","1z","6s","2g","7m","6p","4p","9m","6s","9m","4f","4p","9m","4m","6m","7s","2z","3s","6p","2m","9m","5m","6p","6s","7m","2s","5s","4g","9p","3z"],
      "starting_dead_wall": ["1m","1s","6m","5s","9p","3m","1z","1p"],
      "starting_round": 0,
      "starting_honba": 0
    }
    """, [
      %{"buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil], "type" => "buttons_pressed"},
      %{"buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil], "type" => "buttons_pressed"},
      %{"buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil], "type" => "buttons_pressed"},
      %{"buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}], "type" => "buttons_pressed"},
      %{"player" => 0, "tile" => "4z", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "8p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "9s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "0z", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "3m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "4m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "9s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "9p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "7s", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [nil, %{"button" => "flower", "call_choice" => ["2f"], "called_tile" => nil}, nil, nil], "type" => "buttons_pressed"},
      %{"player" => 1, "tile" => "1m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "2p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "8m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "5s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "4m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "3p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "8s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "1p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "2z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "6z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "2s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "5s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "2z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "3p", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [nil, nil, nil, %{"button" => "flower", "call_choice" => ["1g"], "called_tile" => nil}], "type" => "buttons_pressed"},
      %{"player" => 3, "tile" => "1s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "2z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "1m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "8m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "7p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "7m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "7z", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [nil, nil, %{"button" => "flower", "call_choice" => ["1f"], "called_tile" => nil}, nil], "type" => "buttons_pressed"},
      %{"player" => 2, "tile" => "6m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "9p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "8m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "6m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "0z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "7z", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [%{"button" => "flower", "call_choice" => ["3g"], "called_tile" => nil}, nil, nil, nil], "type" => "buttons_pressed"},
      %{"player" => 0, "tile" => "5s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "2m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "5p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "1p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "6z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "7p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "6z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "4m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "3p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "1m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "8s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "9s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "1z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "3m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "4s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "3z", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "4z", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [nil, %{"button" => "flower", "call_choice" => ["3f"], "called_tile" => nil}, nil, nil], "type" => "buttons_pressed"},
      %{"player" => 1, "tile" => "9p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "9s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "1z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "6s", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [nil, %{"button" => "flower", "call_choice" => ["2g"], "called_tile" => nil}, nil, nil], "type" => "buttons_pressed"},
      %{"player" => 1, "tile" => "3m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "7m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "6p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "4p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "9m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "6s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "9m", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [%{"button" => "flower", "call_choice" => ["4f"], "called_tile" => nil}, nil, nil, nil], "type" => "buttons_pressed"},
      %{"player" => 0, "tile" => "1z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "4p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "9m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "4m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "6m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "7s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "2z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "3s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "6p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "2m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "9m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "5m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "6p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "6s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "7m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "2s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "5s", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [nil, %{"button" => "flower", "call_choice" => ["4g"], "called_tile" => nil}, nil, nil], "type" => "buttons_pressed"},
      %{"player" => 1, "tile" => "1p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "9p", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [nil, nil, nil, %{"button" => "tsumo"}], "type" => "buttons_pressed"},
    ], %{
      north: %{
        yaku: [{"Concealed Hand", 1}, {"Self Draw", 1}, {"All Sequences", 1}, {"Final Tile", 1}]
      }
    })
  end

  test "hk - houtei" do
    TestUtils.test_yaku_advanced("hk", [], """
    {
      "starting_hand": {
        "east": ["6z","2f","9s","3s","4p","4s","3s","7p","6p","2p","8s","8p","1p"],
        "south": ["8m","3m","6z","1p","1z","1p","8s","7m","4s","8s","2s","6m","4m"],
        "west": ["2m","4s","4m","2g","1s","7z","3m","3g","4g","4p","9m","2z","9p"],
        "north": ["6m","7m","5m","2p","9m","5m","3z","6s","7z","3p","4m","2s","9p"]
      },
      "starting_draws": ["5p","1f","4z","1s","1z","4z","9s","6m","7m","2m","3s","9s","8p","4m","9s","9m","4p","3z","3p","4f","5m","7p","1s","8m","2p","2s","2z","5s","2p","9p","7s","1m","7z","9p","5m","5p","7s","1s","5s","6p","5s","7p","1m","0z","5p","8m","3z","6z","1z","8p","1m","7s","0z","7p","7s","6s","4s","2m","9m","2s","8p","6z","0z","3m","3p","2z","3p","5p","1g","4z","5s","8s","1p","1z","8m","7z","3m","2m","7m","2z","6m","4p","6p","3f"],
      "starting_dead_wall": ["0z","6s","1m","4z","6s","6p","3z","3s"],
      "starting_round": 0,
      "starting_honba": 0
    }
    """, [
      %{"buttons" => [%{"button" => "start_flower", "call_choice" => ["2f"], "called_tile" => nil}, nil, nil, nil], "type" => "buttons_pressed"},
      %{"buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil], "type" => "buttons_pressed"},
      %{"buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil], "type" => "buttons_pressed"},
      %{"buttons" => [nil, nil, %{"button" => "start_flower", "call_choice" => ["4g"], "called_tile" => nil}, nil], "type" => "buttons_pressed"},
      %{"buttons" => [nil, nil, %{"button" => "flower", "call_choice" => ["2g"], "called_tile" => nil}, nil], "type" => "buttons_pressed"},
      %{"buttons" => [nil, nil, %{"button" => "flower", "call_choice" => ["3g"], "called_tile" => nil}, nil], "type" => "buttons_pressed"},
      %{"buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil], "type" => "buttons_pressed"},
      %{"buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}], "type" => "buttons_pressed"},
      %{"player" => 0, "tile" => "0z", "tsumogiri" => false, "type" => "discard"},
      %{"buttons" => [nil, %{"button" => "flower", "call_choice" => ["1f"], "called_tile" => nil}, nil, nil], "type" => "buttons_pressed"},
      %{"player" => 1, "tile" => "6s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "4z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "1s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "6z", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "4z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "9s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "6m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "1z", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "2m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "3s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "9s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "7m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "4m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "9s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "9m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "4p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "3z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "3p", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [nil, nil, nil, %{"button" => "flower", "call_choice" => ["4f"], "called_tile" => nil}], "type" => "buttons_pressed"},
      %{"player" => 3, "tile" => "6p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "9s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "7p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "1s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "8m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "8s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "2s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "2z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "5s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "1p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "9p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "7s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "1m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "7z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "9p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "5m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "5p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "7s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "1s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "5s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "6p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "3s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "7p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "1m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "0z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "5m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "8m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "3z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "6z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "1z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "8p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "1m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "7s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "0z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "7p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "7s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "6s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "4s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "2m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "9m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "2s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "8p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "6z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "0z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "3m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "3s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "2z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "3p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "5p", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [%{"button" => "flower", "call_choice" => ["1g"], "called_tile" => nil}, nil, nil, nil], "type" => "buttons_pressed"},
      %{"player" => 0, "tile" => "3z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "4z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "5s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "8s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "1p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "1z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "8m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "7z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "3m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "2m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "7m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "2z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "6m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "4p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "6p", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [nil, nil, nil, %{"button" => "flower", "call_choice" => ["3f"], "called_tile" => nil}], "type" => "buttons_pressed"},
      %{"player" => 3, "tile" => "3s", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [%{"button" => "ron"}, nil, nil, nil], "type" => "buttons_pressed"}
    ], %{
      east: %{
        yaku: [{"Concealed Hand", 1}, {"Final Tile", 1}, {"Seat Season", 1}]
      }
    })
  end

end
