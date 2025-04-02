defmodule RiichiAdvanced.RiichiMechanics do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "chinitsu - fifth tile tenpai" do
    TestUtils.test_yaku_advanced("chinitsu", [%{name: "yaku/riichi", config: %{bet: 1000, drawless: true}}, "no_honors"], """
    {
      "starting_hand": {
        "east": ["1s", "2s", "3s", "4s", "5s", "6s", "4s", "5s", "6s", "9s", "9s", "9s", "9s"],
        "west": ["1s", "2s", "3s", "1s", "2s", "3s", "1s", "2s", "3s", "4s", "7s", "8s", "8s"]
      },
      "starting_draws": ["4s", "5s", "5s", "6s", "6s", "7s", "7s", "7s", "8s", "8s"]
    }
    """, [
      %{"type" => "discard", "tile" => "4s", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6s", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7s", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8s", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8s", "player" => 2, "tsumogiri" => true}
    ], :no_winners, %{delta_scores: [1000, -1000]})
  end

  test "chinitsu - no fifth tile tenpai" do
    TestUtils.test_yaku_advanced("chinitsu", [%{name: "yaku/riichi", config: %{bet: 1000, drawless: true}}, "no_honors", "no_fifth_tile_tenpai"], """
    {
      "starting_hand": {
        "east": ["1s", "2s", "3s", "4s", "5s", "6s", "4s", "5s", "6s", "9s", "9s", "9s", "9s"],
        "west": ["1s", "2s", "3s", "1s", "2s", "3s", "1s", "2s", "3s", "4s", "7s", "8s", "8s"]
      },
      "starting_draws": ["4s", "5s", "5s", "6s", "6s", "7s", "7s", "7s", "8s", "8s"]
    }
    """, [
      %{"type" => "discard", "tile" => "4s", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6s", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7s", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8s", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8s", "player" => 2, "tsumogiri" => true}
    ], :no_winners, %{delta_scores: [1000, -1000]})
  end

end
