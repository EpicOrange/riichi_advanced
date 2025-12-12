defmodule RiichiAdvanced.YakuTest.TianjinYaku do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "tianjin - pure hand" do
    TestUtils.test_yaku_advanced("tianjin", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "8m", "3s", "4s", "4p", "5p", "6p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"]
      },
      "starting_draws": ["6m", "6m", "1p", "1p", "5s"],
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
      %{"type" => "discard", "tile" => "6m", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1p", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Pure Hand", 2}, {"Different Patterns", 1}],
        yaku2: []
      }
    })
  end

  test "tianjin - not pure hand can't win" do
    TestUtils.test_yaku_advanced("tianjin", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "8m", "3s", "4s", "4p", "5p", "6p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"]
      },
      "starting_draws": ["6m", "6m", "1p", "1p", "5s"],
      "starting_dead_wall": ["9m", "9m", "2s"],
      "die1": 1,
      "die2": 1
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_pass"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_pass"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_pass"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_pass"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6m", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1p", "player" => 3, "tsumogiri" => true}
    ], :no_winners)
  end

  test "tianjin - wild card single wait" do
    TestUtils.test_yaku_advanced("tianjin", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "8m", "8m", "4s", "4p", "5p", "6p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"]
      },
      "starting_draws": ["6m", "6m", "1p", "1p", "1m"],
      "starting_dead_wall": ["9m", "9m", "3s"],
      "die1": 1,
      "die2": 1
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_pass"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_pass"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_pass"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_pass"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6m", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1p", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Wild Card Single Wait", 2}, {"Different Patterns", 1}],
        yaku2: []
      }
    })
  end

  test "tianjin - double wild card set wait" do
    TestUtils.test_yaku_advanced("tianjin", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "8m", "3s", "4s", "4p", "5p", "6p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"]
      },
      "starting_draws": ["6m", "6m", "1p", "1p", "1m"],
      "starting_dead_wall": ["9m", "9m", "3s"],
      "die1": 1,
      "die2": 1
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_pass"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_pass"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_pass"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_pass"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6m", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1p", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Double Wild Card Set Wait", 2}, {"Different Patterns", 1}],
        yaku2: []
      }
    })
  end

  test "tianjin - capturing the five" do
    TestUtils.test_yaku_advanced("tianjin", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "4m", "6m", "6m", "7m", "8m", "8m", "8m", "4p", "5p", "6p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"]
      },
      "starting_draws": ["6m", "6m", "1p", "1p", "5m"],
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
      %{"type" => "discard", "tile" => "6m", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1p", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Capturing the Five", 3}, {"Pure Hand", 2}, {"Different Patterns", 2}],
        yaku2: []
      }
    })
  end

  test "tianjin - dragon" do
    TestUtils.test_yaku_advanced("tianjin", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "1p", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "4s", "5s", "6s"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"]
      },
      "starting_draws": ["6m", "6m", "1p", "1p", "5p"],
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
      %{"type" => "discard", "tile" => "6m", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1p", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Dragon", 4}, {"Pure Hand", 2}, {"Different Patterns", 2}],
        yaku2: []
      }
    })
  end

  test "tianjin - dragon after daiminkan" do
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
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Dragon", 4}, {"Kong Blossom", 1}, {"Pure Hand", 2}, {"Different Patterns", 3}],
        yaku2: [{"Kong Blossom", 2}]
      }
    }, %{delta_scores: [60, -20, -20, -20]})
  end

  test "tianjin - dragon after ankan" do
    TestUtils.test_yaku_advanced("tianjin", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "1p", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "5s", "5s", "5s"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"]
      },
      "starting_draws": ["6m", "6m", "1p", "1p", "5s", "5p"],
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
      %{"type" => "discard", "tile" => "6m", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1p", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Dragon", 4}, {"Kong Blossom", 2}, {"Pure Hand", 2}, {"Different Patterns", 3}],
        yaku2: [{"Kong Blossom", 2}]
      }
    }, %{delta_scores: [66, -22, -22, -22]})
  end

  test "tianjin - heavenly hand with wild" do
    TestUtils.test_yaku_advanced("tianjin", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "8m", "3s", "5s", "4p", "5p", "6p"],
        "south": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"]
      },
      "starting_draws": ["7s"],
      "starting_dead_wall": ["9m", "9m", "2s"],
      "die1": 1,
      "die2": 1
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_pass"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_pass"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_pass"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_pass"}]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Heavenly Hand", 1}],
        yaku2: [{"Heavenly Hand", 6}]
      }
    }, %{delta_scores: [18, -6, -6, -6]})
  end

  test "tianjin - heavenly hand without wild" do
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
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_pass"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_pass"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_pass"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_pass"}]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Heavenly Hand", 1}, {"Pure Hand", 2}, {"Different Patterns", 1}],
        yaku2: [{"Heavenly Hand", 6}]
      }
    }, %{delta_scores: [72, -24, -24, -24]})
  end

  test "tianjin - earthly hand with wild" do
    TestUtils.test_yaku_advanced("tianjin", [], """
    {
      "starting_hand": {
        "east": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "south": ["3m", "3m", "3m", "5m", "6m", "7m", "8m", "8m", "3s", "5s", "4p", "5p", "6p"],
        "west": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"],
        "north": ["2m", "4m", "7m", "2p", "3p", "4p", "6p", "7p", "8p", "9p", "2s", "4s", "6s"]
      },
      "starting_draws": ["6m", "7s"],
      "starting_dead_wall": ["9m", "9m", "2s"],
      "die1": 1,
      "die2": 1
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_pass"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_pass"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_pass"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_pass"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "tsumo"}, nil, nil]}
    ], %{
      south: %{
        yaku: [{"Earthly Hand", 1}],
        yaku2: [{"Earthly Hand", 4}]
      }
    }, %{delta_scores: [-4, 12, -4, -4]})
  end

  test "tianjin - earthly hand without wild" do
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
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_pass"}, nil]},
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

end
