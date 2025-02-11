defmodule RiichiAdvanced.RiichiTest do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.GameState.TileBehavior, as: TileBehavior
  alias RiichiAdvanced.Match, as: Match

  @riichi_win_definition [
    ["exhaustive", [[[0, 1, 2], [0, 0, 0]], 4], [[[0, 0]], 1]],
    [[[[0, 0, 0, 0]], -1], [[[0, 0]], 7]],
    [
      "unique",
      [
        ["1m", "9m", "1p", "9p", "1s", "9s", "1z", "2z", "3z", "4z", "5z", "6z",
         "7z"],
        13
      ],
      [
        ["1m", "9m", "1p", "9p", "1s", "9s", "1z", "2z", "3z", "4z", "5z", "6z",
         "7z"],
        1
      ]
    ]
  ]

  @ordering %{
    "1m": :"2m",
    "2m": :"3m",
    "3m": :"4m",
    "4m": :"5m",
    "5m": :"6m",
    "6m": :"7m",
    "7m": :"8m",
    "8m": :"9m",
    "1p": :"2p",
    "2p": :"3p",
    "3p": :"4p",
    "4p": :"5p",
    "5p": :"6p",
    "6p": :"7p",
    "7p": :"8p",
    "8p": :"9p",
    "1s": :"2s",
    "2s": :"3s",
    "3s": :"4s",
    "4s": :"5s",
    "5s": :"6s",
    "6s": :"7s",
    "7s": :"8s",
    "8s": :"9s"
  }
  @ordering_r %{
    "2m": :"1m",
    "3m": :"2m",
    "4m": :"3m",
    "5m": :"4m",
    "6m": :"5m",
    "7m": :"6m",
    "8m": :"7m",
    "9m": :"8m",
    "2p": :"1p",
    "3p": :"2p",
    "4p": :"3p",
    "5p": :"4p",
    "6p": :"5p",
    "7p": :"6p",
    "8p": :"7p",
    "9p": :"8p",
    "2s": :"1s",
    "3s": :"2s",
    "4s": :"3s",
    "5s": :"4s",
    "6s": :"5s",
    "7s": :"6s",
    "8s": :"7s",
    "9s": :"8s"
  }

  test "standard hand win" do
    hand = [:"2m", :"3m", :"4m", :"4m", :"5m", :"6m", :"7p", :"7p", :"7p", :"8s", :"8s", :"8s", :"6p", :"6p"]
    assert Match.match_hand(hand, [], @riichi_win_definition, %TileBehavior{ ordering: @ordering, ordering_r: @ordering_r })
  end

  test "tenpai is not win" do
    hand = [:"2m", :"3m", :"4m", :"4m", :"5m", :"6m", :"7p", :"7p", :"7p", :"8s", :"8s", :"8s", :"6p", :"7p"]
    assert not Match.match_hand(hand, [], @riichi_win_definition, %TileBehavior{ ordering: @ordering, ordering_r: @ordering_r })
  end

  test "seven pairs win" do
    hand = [:"1m", :"1m", :"4m", :"4m", :"6m", :"6m", :"2p", :"2p", :"7p", :"7p", :"8s", :"8s", :"3z", :"3z"]
    assert Match.match_hand(hand, [], @riichi_win_definition, %TileBehavior{ ordering: @ordering, ordering_r: @ordering_r })
  end

  test "invalid seven pairs win" do
    hand = [:"1m", :"1m", :"1m", :"1m", :"6m", :"6m", :"2p", :"2p", :"7p", :"7p", :"8s", :"8s", :"3z", :"3z"]
    assert not Match.match_hand(hand, [], @riichi_win_definition, %TileBehavior{ ordering: @ordering, ordering_r: @ordering_r })
  end

  test "kokushi win" do
    hand = [:"1m", :"9m", :"1p", :"1s", :"9s", :"1z", :"2z", :"3z", :"4z", :"5z", :"9p", :"6z", :"7z", :"7z"]
    assert Match.match_hand(hand, [], @riichi_win_definition, %TileBehavior{ ordering: @ordering, ordering_r: @ordering_r })
  end

  # need to test:
  # - can't ankan in riichi if it changes waits

end
