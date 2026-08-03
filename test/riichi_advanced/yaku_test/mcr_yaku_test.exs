defmodule RiichiAdvanced.YakuTest.MCRYaku do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "mcr - not outside hand" do
    TestUtils.test_yaku_advanced("mcr", [], """
    {
      "starting_hand": {
        "east": ["8m", "9m", "1p", "2p", "3p", "6p", "6p", "7p", "8p", "9p", "4s", "5s", "6s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "7m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"All Chows", [2, "Fan"]}, {"Concealed Hand", [2, "Fan"]}, {"Edge Wait", [1, "Fan"]}, {"Mixed Double Chow", [1, "Fan"]}, {"Mixed Straight", [8, "Fan"]}, {"Two Terminal Chows", [0, "Fan"]}]
      }
    })
  end

  test "mcr - knitted straight" do
    TestUtils.test_yaku_advanced("mcr", [], """
    {
      "starting_hand": {
        "east": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "7z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"All Types", [6, "Fan"]}, {"Fully Concealed Hand", [4, "Fan"]}, {"Knitted Straight", [12, "Fan"]}],
      }
    })
  end

# # 88
# "Big Four Winds"
# "Big Three Dragons"
# "All Green"
# "Nine Gates"
# "Four Kongs"
# "Seven Shifted Pairs"
# "Thirteen Orphans"
# # 64
# "All Terminals"
# "Little Four Winds"
# "Little Three Dragons"
# "All Honors"
# "Four Concealed Pungs"
# "Pure Terminal Chows"
# # 48
# "Quadruple Chow"
# "Four Pure Shifted Pungs"
# # 32
# "Four Pure Shifted Chows"
# "Three Kongs"
# "All Terminals and Honors"
# # 24
# "Seven Pairs"
# "Greater Honors and Knitted Tiles"
# "All Even Pungs"
# "Full Flush"
# "Pure Triple Chow"
# "Pure Shifted Pungs"
# "Upper Tiles"
# "Middle Tiles"
# "Lower Tiles"
# # 16
# "Pure Straight"
# "Three-Suited Terminal Chows"
# "Pure Shifted Chows"
# "All Fives"
# "Triple Pung"
# "Three Concealed Pungs"
# # 12
# "Lesser Honors and Knitted Tiles"
# "Knitted Straight"
# "Upper Four"
# "Lower Four"
# "Big Three Winds"
# # 8
# "Mixed Straight"
# "Reversible Tiles"
# "Mixed Triple Chow"
# "Mixed Shifted Pungs"
# "Last Tile Draw"
# "Last Tile Claim"
# "Out with Replacement Tile"
# "Robbing The Kong"
# "Two Concealed Kongs"
# # 6
# "All Pungs"
# "Half Flush"
# "Mixed Shifted Chows"
# "All Types"
# "Melded Hand"
# "Two Dragon Pungs"
# "Two Kongs"
# # 4
# "Outside Hand"
# "Fully Concealed Hand"
# "Two Melded Kongs"
# "Last Tile"
# # 2
# "White Dragon"
# "Green Dragon"
# "Red Dragon"
# "Prevalent Wind"
# "Seat Wind"
# "Concealed Hand"
# "All Chows"
# "Tile Hog"
# "Double Pung"
# "Two Concealed Pungs"
# "Concealed Kong"
# "All Simples"
# # 1
# "Pure Double Chow"
# "Mixed Double Chow"
# "Short Straight"
# "Two Terminal Chows"
# "Pungs of Terminals"
# "Pung of Terminals"
# "Pungs of Honors"
# "Pung of Honors"
# "Melded Kong"
# "One Voided Suit"
# "No Honors"
# "Self-Drawn"
# "Edge Wait"
# "Closed Wait"
# "Single Wait"

end
