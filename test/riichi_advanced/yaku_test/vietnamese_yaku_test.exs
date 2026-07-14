defmodule RiichiAdvanced.YakuTest.VietnameseYaku do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "vietnamese - discarded flower acts as joker" do
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
        yaku: [{"Prevalent Wind", [1, "Phán"]}, {"Seat Wind", [1, "Phán"]}],
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
        yaku: [{"True No Flowers, No Leaves", [2, "Mủn"]}],
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
      "starting_draws": ["2m", "1p", "1p", "1p", "2j", "3p", "1f"]
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
      %{"type" => "discard", "tile" => "1f", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
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

  test "vietnamese - true throwing jokers nfnl doesn't score first 2 discarded jokers" do
    TestUtils.test_yaku_advanced("vietnamese", [], """
    {
      "starting_hand": {
        "east": ["0j", "3m", "4m", "4m", "5m", "6m", "7p", "7p", "7p", "5s", "5s", "6s", "6s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "0z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "7s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2m", "1p", "1p", "1p", "2j", "3p", "3p", "3p", "2f", "1f"]
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
      %{"type" => "discard", "tile" => "1f", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [
          {"True No Flowers, No Leaves", [2, "Mủn"]},
          {"Throwing Flowers/Jokers", [1, "Mủn"]},
        ],
      }
    })
  end
  
end
