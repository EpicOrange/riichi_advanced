defmodule RiichiAdvanced.YakuTest.VietnameseScoring do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils
  
  test "vietnamese - 9 tile liability" do
    TestUtils.test_yaku_advanced("vietnamese", [], """
    {
      "starting_hand": {
        "east": ["0z", "0z", "0j", "6z", "6z", "6z", "7z", "7z", "7z", "1p", "1p", "2z", "2z"],
        "south": ["2m", "3m", "6m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "4s", "5s"],
        "west": ["2m", "4m", "6m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "3z", "4z"],
        "north": ["1m", "1z", "1m", "4m", "1z", "4m", "7m", "1z", "7m", "5m", "5m", "6m", "1z"]
      },
      "starting_draws": ["1m", "4m", "7m", "5m", "8j"],
      "starting_dead_wall": ["5s"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "pon"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 3, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "4m", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "pon"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 3, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "7m", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "pon"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 3, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5m", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "pon"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 3, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "8j", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "ron"}]},
    ], %{
      north: %{
        yaku: [
          {"All Called", [3, "Phán"]},
          {"All Sets", [3, "Phán"]},
          {"Progressive Counting", [6, "Phán"]},
          {"Full Flush", [1, "Mủn"]},
          {"Win on Discarded Joker", [1, "Mủn"]}
        ]
      }
    }, %{delta_scores: [-512, 0, 0, 512]})
  end
  
  test "vietnamese - daisangen liability" do
    TestUtils.test_yaku_advanced("vietnamese", [], """
    {
      "starting_hand": {
        "east": ["1s", "2m", "3s", "4s", "5s", "6s", "7s", "8s", "8s", "1p", "1p", "2z", "2z"],
        "south": ["2m", "3m", "6m", "2p", "5p", "8p", "3s", "7s", "9s", "4s", "9p", "4s", "5s"],
        "west": ["2m", "4m", "6m", "2p", "5p", "8p", "3s", "7s", "9s", "4s", "9p", "3z", "4z"],
        "north": ["0z", "1z", "0z", "6z", "2z", "6z", "7z", "3z", "7z", "9m", "9m", "4z", "4z"]
      },
      "starting_draws": ["0z", "6z", "7z", "5j"],
      "starting_dead_wall": ["5s"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "0z", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "pon"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 3, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "pon"}]},
      %{"type" => "discard", "tile" => "2z", "player" => 3, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "7z", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "pon"}]},
      %{"type" => "discard", "tile" => "3z", "player" => 3, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5j", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "ron"}]},
    ], %{
      north: %{
        yaku: [
          {"All Terminals and Honors", [1, "Mủn"]},
          {"Big Three Dragons", [9, "Phán"]},
          {"Half Flush", [3, "Phán"]},
          {"Progressive Counting+", [2, "Mủn", 3, "Phán"]},
          {"All Sets", [3, "Phán"]},
          {"Seat Wind", [1, "Phán"]},
          {"Win on Discarded Joker", [1, "Mủn"]},
        ]
      }
    }, %{delta_scores: [-914, 0, 0, 914]})
  end

  test "vietnamese - nfnl liability" do
    TestUtils.test_yaku_advanced("vietnamese", [], """
    {
      "starting_hand": {
        "east": ["0z", "1z", "0z", "6z", "2z", "6z", "7z", "3z", "7z", "9m", "9m", "4z", "4z"],
        "south": ["2m", "3m", "6m", "2p", "5p", "8p", "3s", "7s", "9s", "4s", "9p", "4s", "5s"],
        "west": ["2m", "4m", "6m", "2p", "5p", "8p", "3s", "7s", "9s", "4s", "9p", "3z", "4z"],
        "north": ["1s", "2s", "3s", "4s", "5s", "6s", "7s", "8s", "9s", "1p", "1p", "2z", "2z"]
      },
      "starting_draws": ["1f"],
      "starting_dead_wall": ["5s"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1f", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "ron"}]},
    ], %{
      north: %{
        yaku: [
          {"Blessing of Earth", [2, "Mủn"]},
          {"Win on Discarded Flower", [1, "Mủn"]}
        ]
      }
    }, %{delta_scores: [-384, 0, 0, 384]})
  end

  test "vietnamese - robbing a bounce" do
    TestUtils.test_yaku_advanced("vietnamese", ["yaku/viet_rob_bounce"], """
    {
      "starting_hand": {
        "east": ["8j", "2m", "3m", "4p", "5p", "6p", "7p", "8p", "9p", "1z", "1z", "2p", "7m"],
        "south": ["2m", "3m", "6m", "2p", "5p", "8p", "3s", "7s", "9s", "4s", "9p", "4s", "5s"],
        "west": ["2m", "4m", "6m", "2p", "5p", "8p", "3s", "7s", "9s", "4s", "9p", "3z", "4z"],
        "north": ["1s", "2s", "3s", "4s", "5s", "6s", "7s", "8s", "9s", "0j", "1p", "1s", "2s"]
      },
      "starting_draws": ["1p", "3p", "7m", "7m", "1p"],
      "starting_dead_wall": ["5s"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1p", "player" => 0, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "pon"}]},
      %{"type" => "discard", "tile" => "1s", "player" => 3, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "7m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "7m", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7m", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "joker_swap"}]},
      %{"type" => "mark", "player" => 3, "marking" => [
        ["done", true],
        ["hand", %{"needed" => 1, "marked" => [["1p", "north", 10]], "restrictions" => []}],
        ["calls", %{"needed" => 1, "marked" => [[["pon", [:"1p", :"0j", :"1p"]], "north", 0]], "restrictions" => []}],
      ]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "rob_bounce"}, nil, nil, nil]},
    ], %{
      east: %{
        yaku: [{"Robbing a Bounce", [1, "Phán"]}]
      }
    }, %{delta_scores: [4, -1, -1, -2]})
  end

end
