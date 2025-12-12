defmodule RiichiAdvanced.TianjinPaymentsTest do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "tianjin - dealer mult but x2 win" do
    TestUtils.test_yaku_advanced("tianjin", [], """
    {
      "starting_hand": {
        "east": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "south": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "8m", "3s", "5s", "4p", "5p", "6p"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"]
      },
      "starting_draws": ["6m", "4s"],
      "starting_dead_wall": ["9m", "9m", "9m"],
      "die1": 1,
      "die2": 1
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_pass"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_challenge_dealer"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_pass"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_pass"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "tsumo"}, nil, nil]}
    ], %{
      south: %{
        yaku: [{"Earthly Hand", 1}, {"Pure Hand", 2}, {"Different Patterns", 1}],
        yaku2: [{"Earthly Hand", 4}]
      }
    }, %{delta_scores: [-32, 64, -16, -16]})
  end

  test "tianjin - dealer mult but someone else won" do
    TestUtils.test_yaku_advanced("tianjin", [], """
    {
      "starting_hand": {
        "east": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "south": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "8m", "3s", "5s", "4p", "5p", "6p"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"]
      },
      "starting_draws": ["6m", "4s"],
      "starting_dead_wall": ["9m", "9m", "9m"],
      "die1": 1,
      "die2": 1
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_pass"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_pass"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_challenge_dealer"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_pass"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "tsumo"}, nil, nil]}
    ], %{
      south: %{
        yaku: [{"Earthly Hand", 1}, {"Pure Hand", 2}, {"Different Patterns", 1}],
        yaku2: [{"Earthly Hand", 4}]
      }
    }, %{delta_scores: [-16, 48, -16, -16]})
  end

  test "tianjin - dealer mult with double down but someone else won" do
    TestUtils.test_yaku_advanced("tianjin", [], """
    {
      "starting_hand": {
        "east": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "south": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "8m", "3s", "5s", "4p", "5p", "6p"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"]
      },
      "starting_draws": ["6m", "4s"],
      "starting_dead_wall": ["9m", "9m", "9m"],
      "die1": 1,
      "die2": 1
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_double_down"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_pass"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_challenge_dealer"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_pass"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "tsumo"}, nil, nil]}
    ], %{
      south: %{
        yaku: [{"Earthly Hand", 1}, {"Pure Hand", 2}, {"Different Patterns", 1}],
        yaku2: [{"Earthly Hand", 4}]
      }
    }, %{delta_scores: [-32, 64, -16, -16]})
  end

  test "tianjin - dealer mult but x4 win" do
    TestUtils.test_yaku_advanced("tianjin", [], """
    {
      "starting_hand": {
        "east": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "south": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "8m", "3s", "5s", "4p", "5p", "6p"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"]
      },
      "starting_draws": ["6m", "4s"],
      "starting_dead_wall": ["9m", "9m", "9m"],
      "die1": 1,
      "die2": 1
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_pass"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_challenge_dealer_twice"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_pass"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_pass"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "tsumo"}, nil, nil]}
    ], %{
      south: %{
        yaku: [{"Earthly Hand", 1}, {"Pure Hand", 2}, {"Different Patterns", 1}],
        yaku2: [{"Earthly Hand", 4}]
      }
    }, %{delta_scores: [-64, 96, -16, -16]})
  end

  test "tianjin - dealer mult but x8 win" do
    TestUtils.test_yaku_advanced("tianjin", [], """
    {
      "starting_hand": {
        "east": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "south": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "8m", "3s", "5s", "4p", "5p", "6p"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"]
      },
      "starting_draws": ["6m", "4s"],
      "starting_dead_wall": ["9m", "9m", "9m"],
      "die1": 1,
      "die2": 1
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_double_down"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_challenge_dealer_twice"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_pass"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_pass"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "tsumo"}, nil, nil]}
    ], %{
      south: %{
        yaku: [{"Earthly Hand", 1}, {"Pure Hand", 2}, {"Different Patterns", 1}],
        yaku2: [{"Earthly Hand", 4}]
      }
    }, %{delta_scores: [-128, 160, -16, -16]})
  end

  test "tianjin - double down doubles win payments" do
    TestUtils.test_yaku_advanced("tianjin", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "8m", "3s", "5s", "4p", "5p", "6p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"]
      },
      "starting_draws": ["4s"],
      "starting_dead_wall": ["9m", "9m", "9m"],
      "die1": 1,
      "die2": 1
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_double_down"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_pass"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_pass"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_pass"}]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Heavenly Hand", 1}, {"Pure Hand", 2}, {"Different Patterns", 1}],
        yaku2: [{"Heavenly Hand", 6}]
      }
    }, %{delta_scores: [144, -48, -48, -48]})
  end

  test "tianjin - double down with additional challenges" do
    TestUtils.test_yaku_advanced("tianjin", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "8m", "3s", "5s", "4p", "5p", "6p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"]
      },
      "starting_draws": ["4s"],
      "starting_dead_wall": ["9m", "9m", "9m"],
      "die1": 1,
      "die2": 1
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_double_down"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_challenge_dealer"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_challenge_dealer_twice"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_pass"}]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Heavenly Hand", 1}, {"Pure Hand", 2}, {"Different Patterns", 1}],
        yaku2: [{"Heavenly Hand", 6}]
      }
    }, %{delta_scores: [336, -96, -192, -48]})
  end

  test "tianjin - daiminkan payment" do
    TestUtils.test_yaku_advanced("tianjin", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "1p", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "5s", "5s", "5s"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"]
      },
      "starting_draws": ["6m", "5s", "5p"],
      "starting_dead_wall": ["9m", "9m", "9m"],
      "die1": 1,
      "die2": 1
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_pass"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_pass"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_pass"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_pass"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "daiminkan"}, nil, nil, nil]},
    ], %{}, %{scores: [51, 49, 50, 50]})
  end

  test "tianjin - ankan payment" do
    TestUtils.test_yaku_advanced("tianjin", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "1p", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "5s", "5s", "5s"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"]
      },
      "starting_draws": ["5s"],
      "starting_dead_wall": ["9m", "9m", "9m"],
      "die1": 1,
      "die2": 1
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_pass"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_pass"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_pass"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_pass"}]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]}
    ], %{}, %{scores: [56, 48, 48, 48]})
  end

  test "tianjin - kakan payment" do
    TestUtils.test_yaku_advanced("tianjin", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "1p", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "5s", "5s", "5s"],
        "south": ["2m", "4m", "6m", "6m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"]
      },
      "starting_draws": ["6m", "7s", "7s", "7s", "6m"],
      "starting_dead_wall": ["9m", "9m", "9m"],
      "die1": 1,
      "die2": 1
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_pass"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_pass"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_pass"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_pass"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "pon"}, nil, nil]},
      %{"type" => "discard", "tile" => "2s", "player" => 1, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "7s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7s", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7s", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "kakan"}, nil, nil]}
    ], %{}, %{scores: [49, 53, 49, 49]})
  end

  test "tianjin - double down daiminkan payment" do
    TestUtils.test_yaku_advanced("tianjin", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "1p", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "5s", "5s", "5s"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"]
      },
      "starting_draws": ["6m", "5s", "5p"],
      "starting_dead_wall": ["9m", "9m", "9m"],
      "die1": 1,
      "die2": 1
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_double_down"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_pass"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_pass"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_pass"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "daiminkan"}, nil, nil, nil]}
    ], %{}, %{scores: [52, 48, 50, 50]})
  end

  test "tianjin - double down ankan payment" do
    TestUtils.test_yaku_advanced("tianjin", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "1p", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "5s", "5s", "5s"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"]
      },
      "starting_draws": ["5s"],
      "starting_dead_wall": ["9m", "9m", "9m"],
      "die1": 1,
      "die2": 1
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_double_down"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_pass"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_pass"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_pass"}]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]}
    ], %{}, %{scores: [62, 46, 46, 46]})
  end

  test "tianjin - double down kakan payment" do
    TestUtils.test_yaku_advanced("tianjin", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "1p", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "5s", "5s", "5s"],
        "south": ["2m", "4m", "6m", "6m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"]
      },
      "starting_draws": ["6m", "7s", "7s", "7s", "6m"],
      "starting_dead_wall": ["9m", "9m", "9m"],
      "die1": 1,
      "die2": 1
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_double_down"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_pass"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_pass"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_pass"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "pon"}, nil, nil]},
      %{"type" => "discard", "tile" => "2s", "player" => 1, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "7s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7s", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7s", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "kakan"}, nil, nil]}
    ], %{}, %{scores: [48, 56, 48, 48]})
  end

  test "tianjin - chasing the dealer" do
    TestUtils.test_yaku_advanced("tianjin", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "1p", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "5s", "5s", "5s"],
        "south": ["2m", "4m", "6m", "6m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"]
      },
      "starting_draws": ["7s", "7s", "7s", "7s", "8s"],
      "starting_dead_wall": ["9m", "9m", "9m"],
      "die1": 1,
      "die2": 1
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_pass"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_pass"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_pass"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_pass"}]},
      %{"type" => "discard", "tile" => "7s", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7s", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7s", "player" => 3, "tsumogiri" => true}
    ], %{}, %{scores: [47, 51, 51, 51]})
  end

  test "tianjin - double down chasing the dealer" do
    TestUtils.test_yaku_advanced("tianjin", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "1p", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "5s", "5s", "5s"],
        "south": ["2m", "4m", "6m", "6m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"]
      },
      "starting_draws": ["7s", "7s", "7s", "7s", "8s"],
      "starting_dead_wall": ["9m", "9m", "9m"],
      "die1": 1,
      "die2": 1
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_double_down"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_pass"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_pass"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_pass"}]},
      %{"type" => "discard", "tile" => "7s", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7s", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7s", "player" => 3, "tsumogiri" => true}
    ], %{}, %{scores: [44, 52, 52, 52]})
  end

end
