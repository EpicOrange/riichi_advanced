defmodule RiichiAdvanced.YakuTest.AmericanYaku do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "american - does card-free work?" do
    TestUtils.test_yaku_advanced("american", ["american/no_charleston", "american/am_card_free"], """
    {
      "starting_hand": {
        "east": ["2m", "2m", "2p", "2p", "2p", "2p", "2s", "2s", "2s", "2s", "7z", "7z", "7z"],
        "south": ["6m", "6m", "1p", "3p", "4p", "1z", "2z", "3z", "4z", "2s", "6s", "7s", "8s"],
        "west": ["1m", "4m", "8m", "1p", "3p", "4p", "1z", "2z", "3z", "4z", "2s", "6s", "7s"],
        "north": ["1m", "7m", "7m", "1p", "3p", "4p", "1z", "2z", "3z", "4z", "2s", "6s", "7s"]
      },
      "starting_draws": ["7z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "mahjong_draw"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Base Value", 25}, {"Concealed", 10}]
      }
    }, %{delta_scores: [420, -140, -140, -140]})
  end

  test "american - uniqueness check with too few tile kinds" do
    TestUtils.test_yaku_advanced("american", ["american/no_charleston", "american/am_card_free"], """
    {
      "starting_hand": {
        "east": ["2p", "2p", "2p", "2p", "2p", "2p", "2s", "2s", "2s", "2s", "7z", "7z", "7z"],
        "south": ["6m", "6m", "1p", "3p", "4p", "1z", "2z", "3z", "4z", "2s", "6s", "7s", "8s"],
        "west": ["1m", "4m", "8m", "1p", "3p", "4p", "1z", "2z", "3z", "4z", "2s", "6s", "7s"],
        "north": ["1m", "7m", "7m", "1p", "3p", "4p", "1z", "2z", "3z", "4z", "2s", "6s", "7s"]
      },
      "starting_draws": ["7z"]
    }
    """, [], :no_winners)
  end

end
