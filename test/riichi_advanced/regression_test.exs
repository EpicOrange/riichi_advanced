defmodule RiichiAdvanced.RegressionTest do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils

  # this file is just random uncategorized tests for specific bugs that came up

  test "vietnamese - simultaneous joker pung prioritizes non-joker call" do
    TestUtils.test_yaku_advanced("vietnamese", [], [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "3p", "5p", "8p", "9s", "9p", "9p", "9p", "3z", "3z", "3z"],
        "south": ["1m", "2m", "3m", "5s", "5s", "6s", "7s", "8s", "1z", "1z", "1z", "0z", "7z"],
        "west": ["2m", "4m", "7m", "5s", "6s", "7j", "3s", "6s", "9s", "2z", "4z", "6z", "7z"],
        "north": ["2m", "4m", "7m", "3p", "5p", "8p", "3s", "6s", "9s", "2z", "4z", "6z", "7z"]
      },
      "starting_draws": ["5s", "0z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "5s", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "pon"}, %{"button" => "pon"}, nil]},
      %{"type" => "discard", "tile" => "7z", "player" => 1, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "0z", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ron"}, nil, nil]},
    ], %{
      south: %{
        yaku: [{"Prevalent Wind", [1, "Phán"]}],
      }
    })
  end

  test "vietnamese - can't keep flowers if one has been discarded" do
    TestUtils.test_yaku_advanced("vietnamese", [], [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "3p", "5p", "8p", "9s", "9p", "9p", "9p", "3z", "3z", "1f"],
        "south": ["1m", "2m", "3m", "5s", "5s", "6s", "7s", "8s", "1z", "1z", "1z", "7z", "7z"],
        "west": ["2m", "4m", "7m", "5s", "6s", "7j", "4s", "6s", "9s", "2z", "4z", "6z", "7z"],
        "north": ["2m", "4m", "7m", "3p", "5p", "8p", "3s", "3s", "9s", "2z", "4z", "0z", "0z"]
      },
      "starting_draws": ["5s", "0z", "2f", "7z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1f", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "0z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "pon"}]},
      %{"type" => "discard", "tile" => "4z", "player" => 3, "tsumogiri" => false},
      # should not go through, need to discard drawn 2f
      %{"type" => "discard", "tile" => "3z", "player" => 0, "tsumogiri" => false},
      # if it does go through, south would win by drawing 7z, failing this test
    ], :no_winners)
  end

end
