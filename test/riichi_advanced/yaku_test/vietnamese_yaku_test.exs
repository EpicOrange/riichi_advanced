defmodule RiichiAdvanced.YakuTest.VietnameseYaku do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "vietnamese - discarded flower acts as joker for tenpai players" do
    TestUtils.test_yaku_advanced("vietnamese", [], """
    {
      "starting_hand": {
        "east": ["2m", "0j", "4m", "4m", "5m", "6m", "7p", "7p", "7p", "0z", "0z", "1z", "1z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "0z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "0z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2z", "1f"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "2z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "1f", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [
          {"Prevalent Wind", [1, "Phán"]},
          {"Seat Wind", [1, "Phán"]},
          {"Win on Discarded Flower", [1, "Mủn"]}
        ],
      }
    })
  end

  test "vietnamese - true nfnl" do
    TestUtils.test_yaku_advanced("vietnamese", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "4m", "5m", "6m", "7p", "7p", "7p", "5s", "5s", "6s", "6s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2z", "6s"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "2z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "nfnl0"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"True No Flowers, No Leaves", [2, "Mủn"]}],
      }
    })
  end

  test "vietnamese - true nfnl cannot win on flower" do
    TestUtils.test_yaku_advanced("vietnamese", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "4m", "5m", "6m", "7p", "7p", "7p", "5s", "5s", "6s", "6s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2z", "1f"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "2z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "1f", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]},
    ], %{
      east: %{
        yaku: [{"Win on Discarded Flower", [1, "Mủn"]}],
      }
    })
  end

  test "vietnamese - true nfnl scores first 2 discarded jokers" do
    TestUtils.test_yaku_advanced("vietnamese", [], """
    {
      "starting_hand": {
        "east": ["0j", "3m", "4m", "4m", "5m", "6m", "7p", "7p", "7p", "5s", "5s", "6s", "6s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2m", "1p", "1p", "1p", "2j", "3p", "6s"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "0j", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "1p", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1p", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2j", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6s", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "nfnl0"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [
          {"True No Flowers, No Leaves", [2, "Mủn"]},
          {"Tổng (縂)", [3, "Phán"]},
          {"Hợp (合)", [1, "Phán"]},
        ],
      }
    })
  end

  test "vietnamese - true nfnl doesn't score with throwing jokers" do
    TestUtils.test_yaku_advanced("vietnamese", [], """
    {
      "starting_hand": {
        "east": ["0j", "3m", "4m", "4m", "5m", "6m", "7p", "7p", "7p", "5s", "5s", "6s", "6s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2m", "1p", "1p", "1p", "2j", "3p", "3p", "3p", "2f", "6s"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "0j", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "1p", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1p", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2j", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2f", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "nfnl0"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [
          {"True No Flowers, No Leaves", [2, "Mủn"]},
          {"Tổng (縂)", [3, "Phán"]},
          {"Hợp (合)", [1, "Phán"]},
        ],
      }
    })
  end
  
  test "vietnamese - true nfnl chankan" do
    TestUtils.test_yaku_advanced("vietnamese", [], """
    {
      "starting_hand": {
        "east": ["0j", "3m", "4m", "4m", "5m", "6m", "7p", "7p", "7p", "5s", "6s", "6s", "6s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "4s", "4s"]
      },
      "starting_draws": ["2m", "4s", "2j", "3p", "1p", "1p", "1z", "1p", "1p", "4s"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "0j", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "4s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "pon"}]},
      %{"type" => "discard", "tile" => "2z", "player" => 3, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "2j", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1p", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1p", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1p", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "kakan"}]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "nfnl0"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [
          {"Hợp (合)", [1, "Phán"]},
          {"Robbing a Quad", [1, "Phán"]},
          {"True No Flowers, No Leaves", [2, "Mủn"]},
          {"Tổng (縂)", [3, "Phán"]}
        ],
      }
    })
  end

  test "vietnamese - true nfnl early tsumo" do
    TestUtils.test_yaku_advanced("vietnamese", [], """
    {
      "starting_hand": {
        "east": ["0j", "3m", "4m", "4m", "5m", "6m", "7p", "7p", "7p", "5s", "6s", "6s", "6s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "4s", "4s"]
      },
      "starting_draws": ["2m", "4s", "2s", "3p", "4s"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "0j", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "4s", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "nfnl0"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [
          {"Fully Closed Hand", [1, "Phán"]},
          {"True No Flowers, No Leaves", [2, "Mủn"]},
          {"Tổng (縂)", [3, "Phán"]},
        ],
      }
    })
  end
  test "vietnamese - true nfnl not invalidated by forced number tile discard" do
    TestUtils.test_yaku_advanced("vietnamese", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "4m", "4m", "5m", "6m", "7p", "7p", "7p", "5s", "6s", "6s", "6s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "4s", "4s"]
      },
      "starting_draws": ["2m", "4s", "2s", "3p", "4s"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "3m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "4s", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "nfnl0"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [
          {"Fully Closed Hand", [1, "Phán"]},
          {"True No Flowers, No Leaves", [2, "Mủn"]},
        ],
      }
    })
  end

  test "vietnamese - true nfnl is invalidated by unforced number tile discard" do
    TestUtils.test_yaku_advanced("vietnamese", [], """
    {
      "starting_hand": {
        "east": ["0j", "3m", "4m", "4m", "5m", "6m", "7p", "7p", "7p", "5s", "6s", "6s", "6s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "4s", "4s"]
      },
      "starting_draws": ["1p", "4s", "2s", "3p", "2m", "4s"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4s", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "0j", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "4s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"No Jokers Mosquito Hand", [1, "Mủn"]}],
      }
    })
  end

  test "vietnamese - true nfnl cannot have honors" do
    TestUtils.test_yaku_advanced("vietnamese", [], """
    {
      "starting_hand": {
        "east": ["0j", "3m", "4m", "4m", "5m", "6m", "7z", "7z", "7z", "5s", "6s", "6s", "6s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "4s", "4s"]
      },
      "starting_draws": ["1f", "4s", "2s", "3p", "2m", "4s"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1f", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4s", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "0j", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "4s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Red Dragon", [1, "Phán"]}],
      }
    })
  end

  test "vietnamese - throwing flowers/jokers" do
    TestUtils.test_yaku_advanced("vietnamese", [], """
    {
      "starting_hand": {
        "east": ["0j", "3m", "4m", "4m", "5m", "9m", "7p", "7p", "7p", "5s", "6s", "6s", "6s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "4s", "4s"]
      },
      "starting_draws": ["1f", "4s", "2s", "3p", "2m", "4s", "5s", "5s", "2f", "8s"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1f", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4s", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "0j", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "4s", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2f", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "nfnl1"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Throwing Flowers/Jokers", [1, "Mủn"]}],
      }
    })
  end

  test "vietnamese - throwing flowers can start with a single flower if dealer" do
    TestUtils.test_yaku_advanced("vietnamese", [], """
    {
      "starting_hand": {
        "east": ["1g", "3m", "4m", "4m", "5m", "9m", "7p", "7p", "7p", "5s", "6s", "6s", "6s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "4s", "4s"]
      },
      "starting_draws": ["2m", "4s", "2s", "3p", "0j", "4s", "5s", "5s", "2f", "8s"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1g", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4s", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "0j", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4s", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2f", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "nfnl1"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Throwing Flowers/Jokers", [1, "Mủn"]}],
      }
    })
  end

  test "vietnamese - throwing flowers/jokers doesn't award extra points for 1 extra flower/joker" do
    TestUtils.test_yaku_advanced("vietnamese", [], """
    {
      "starting_hand": {
        "east": ["0j", "3m", "4m", "4m", "2j", "9m", "7p", "7p", "7p", "5s", "6s", "6s", "6s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "4s", "4s"]
      },
      "starting_draws": ["1f", "4s", "2s", "3p", "2f", "4s", "5s", "5s", "2m", "8s", "8s", "8s", "9m", "9m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1f", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4s", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "0j", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "4s", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2f", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "8s", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8s", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2j", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "9m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "nfnl1"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Throwing Flowers/Jokers", [1, "Mủn"]}],
      }
    })
  end

  test "vietnamese - throwing flowers/jokers awards extra points for 2 extra flower/jokers" do
    TestUtils.test_yaku_advanced("vietnamese", [], """
    {
      "starting_hand": {
        "east": ["0j", "3m", "4m", "4m", "2j", "9m", "7p", "7p", "6j", "5s", "6s", "6s", "6s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "4s", "4s"]
      },
      "starting_draws": ["1f", "4s", "2s", "3p", "2f", "4s", "5s", "5s", "2m", "8s", "8s", "8s", "9m", "9m", "0z", "0z", "7p", "9p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1f", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4s", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "0j", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "4s", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2f", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "8s", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8s", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2j", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "9m", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "0z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "0z", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6j", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "9p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "nfnl1"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Throwing Flowers/Jokers", [2, "Mủn"]}],
      }
    })
  end

  test "vietnamese - throwing flowers" do
    TestUtils.test_yaku_advanced("vietnamese", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "4m", "7m", "9m", "7p", "7p", "4s", "5s", "6s", "6s", "6s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "4s", "5s"]
      },
      "starting_draws": ["1f", "4s", "2s", "3p", "2f", "4s", "5s", "5s", "3f"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1f", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4s", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2f", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4s", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3f", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "nfnl2"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Throwing Flowers", [1, "Mủn"]}],
      }
    })
  end

  test "vietnamese - throwing flowers cancelled by discarding something else after declining win" do
    TestUtils.test_yaku_advanced("vietnamese", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "4m", "7m", "9m", "7p", "7p", "4s", "5s", "6s", "6s", "6s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "4s", "5s"]
      },
      "starting_draws": ["1f", "4s", "2s", "3p", "2f", "4s", "5s", "5s", "3f", "8s", "8s", "8s", "9m", "9m", "0z", "0z", "4g", "9p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1f", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4s", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2f", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4s", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3f", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8s", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8s", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "9m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "9m", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "0z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "0z", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4g", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "9p", "player" => 1, "tsumogiri" => true},
    ], :no_winners)
  end

  test "vietnamese - throwing blue jokers counts 2j as a blue joker" do
    TestUtils.test_yaku_advanced("vietnamese", [], """
    {
      "starting_hand": {
        "east": ["2j", "3m", "4m", "4m", "7m", "9m", "7p", "7p", "8j", "5s", "6s", "7j", "6z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "4s", "4s"]
      },
      "starting_draws": ["1p", "4s", "2s", "3p", "1p", "4s", "5s", "5s", "1p", "8s"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "2j", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "4s", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8j", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "4s", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7j", "player" => 0, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "nfnl2"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Throwing Blue Jokers", [1, "Mủn"]}],
      }
    })
  end

  test "vietnamese - progressive counting with three 3-phán hands" do
    TestUtils.test_yaku_advanced("vietnamese", [], """
    {
      "starting_hand": {
        "east": ["2m", "2m", "4m", "4m", "6m", "6m", "8m", "8m", "1z", "2z", "3z", "4z", "6z"],
        "south": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "4s", "4s"]
      },
      "starting_draws": ["2f", "2m", "4m", "6m", "8m", "6z"],
      "starting_dead_wall": ["1p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "4m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "2z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "3z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "8m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "4z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]},
    ], %{
      east: %{
        yaku: [
          {"All Called", [3, "Phán"]},
          {"All Sets", [3, "Phán"]},
          {"Half Flush", [3, "Phán"]},
          {"Progressive Counting", [3, "Phán"]},
          {"No Jokers", [2, "Phán"]},
        ],
      }
    })
  end

  test "vietnamese - progressive counting with big three dragons" do
    TestUtils.test_yaku_advanced("vietnamese", [], """
    {
      "starting_hand": {
        "east": ["0z", "0z", "0j", "6z", "6z", "6z", "7z", "7z", "7z", "1p", "1p", "2z", "2z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "1z", "8s", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "4s", "5s"]
      },
      "starting_draws": ["2f", "1p"],
      "starting_dead_wall": ["5s"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "5s", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [
          {"Big Three Dragons", [9, "Phán"]},
          {"All Terminals and Honors", [1, "Mủn"]},
          {"All Sets", [3, "Phán"]},
          {"Half Flush", [3, "Phán"]},
          {"Progressive Counting+", [2, "Mủn", 3, "Phán"]},
        ],
      }
    })
  end
  
  test "vietnamese - all runs must not have value pair" do
    TestUtils.test_yaku_advanced("vietnamese", [], """
    {
      "starting_hand": {
        "east": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "1z", "8s", "3z", "4z"],
        "south": ["1m", "2m", "3m", "5m", "6m", "7m", "3p", "4p", "5p", "1s", "2s", "3s", "5j"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "4s", "5s"]
      },
      "starting_draws": ["2z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "2z", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ron"}, nil, nil]}
    ], %{
      south: %{
        yaku: [{"Blessing of Earth", [2, "Mủn"]}],
      }
    })
  end
  
  test "vietnamese - all runs can have non-value pair" do
    TestUtils.test_yaku_advanced("vietnamese", [], """
    {
      "starting_hand": {
        "east": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "1z", "8s", "3z", "4z"],
        "south": ["1m", "2m", "3m", "5m", "6m", "7m", "3p", "4p", "5p", "1s", "2s", "3s", "5j"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "4s", "5s"]
      },
      "starting_draws": ["3z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "3z", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ron"}, nil, nil]}
    ], %{
      south: %{
        yaku: [{"All Runs", [1, "Phán"]}, {"Blessing of Earth", [2, "Mủn"]}],
      }
    })
  end
  
end
