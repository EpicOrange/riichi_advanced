defmodule RiichiAdvanced.YakuTest.Sichuan do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.GameState.Log, as: Log
  alias RiichiAdvanced.TestUtils, as: TestUtils

  def mk_marking(seat, tiles, ixs) do
    Log.encode_marking([
      done: false,
      hand: %{
        needed: 3,
        marked: [
          {Enum.at(tiles, 0), seat, Enum.at(ixs, 0)},
          {Enum.at(tiles, 1), seat, Enum.at(ixs, 1)},
          {Enum.at(tiles, 2), seat, Enum.at(ixs, 2)}
        ],
        restrictions: ["self", "not_joker"]
      }
    ])
  end

  test "sichuan - declare void suit and win" do
    TestUtils.test_yaku_advanced("sichuan", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "4m", "5m", "6m", "7p", "7p", "7p", "6m", "2z", "3z", "4z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "8p", "8p", "8p"]
      },
      "starting_draws": ["1z", "6m"],
      "die1": 2,
      "die2": 4
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "charleston_left"}, %{"button" => "charleston_left"}, %{"button" => "charleston_left"}, %{"button" => "charleston_left"}]},
      %{"type" => "mark", "player" => 1, "marking" => mk_marking(:south, [:"8p", :"8p", :"8p"], [13, 12, 11])},
      %{"type" => "mark", "player" => 2, "marking" => mk_marking(:west, [:"4z", :"3z", :"2z"], [13, 12, 11])},
      %{"type" => "mark", "player" => 3, "marking" => mk_marking(:north, [:"4z", :"3z", :"2z"], [13, 12, 11])},
      %{"type" => "mark", "player" => 0, "marking" => mk_marking(:east, [:"4z", :"3z", :"2z"], [14, 13, 12])},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "void_souzu"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "void_manzu"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "void_manzu"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "void_manzu"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: []
      }
    })
  end

  test "sichuan standard yaku" do
    # root 2
    TestUtils.test_yaku("sichuan", [], %{
      hand: [:"2m", :"2m", :"2m", :"2m", :"3m", :"4m", :"7p", :"7p", :"7p", :"7p", :"8s", :"9p", :"6p"],
      winning_tile: :"6p",
      win_source: :discard,
      yaku_lists: ["yaku", "meta_yaku"],
      expected_yaku: [{"Root", 2}]
    })
    # all triplets (actually suuankou tanki)
    TestUtils.test_yaku("sichuan", [], %{
      hand: [:"2m", :"2m", :"2m", :"5m", :"5m", :"5m", :"7p", :"7p", :"7p", :"8p", :"8p", :"8p", :"6p"],
      winning_tile: :"6p",
      win_source: :discard,
      yaku_lists: ["yaku", "meta_yaku"],
      expected_yaku: [{"All Triplets", 1}]
    })
    # all triplets full flush (also suuankou tanki)
    TestUtils.test_yaku("sichuan", [], %{
      hand: [:"2p", :"2p", :"2p", :"5p", :"5p", :"5p", :"7p", :"7p", :"7p", :"8p", :"8p", :"8p", :"6p"],
      winning_tile: :"6p",
      win_source: :discard,
      yaku_lists: ["yaku", "meta_yaku"],
      expected_yaku: [{"All Triplets", 1}, {"Full Flush", 2}]
    })
    # seven pairs full flush (actually daisharin)
    TestUtils.test_yaku("sichuan", [], %{
      hand: [:"2p", :"2p", :"3p", :"3p", :"4p", :"4p", :"5p", :"5p", :"6p", :"7p", :"7p", :"8p", :"8p"],
      winning_tile: :"6p",
      win_source: :discard,
      yaku_lists: ["yaku", "meta_yaku"],
      expected_yaku: [{"Seven Pairs", 2}, {"Full Flush", 2}]
    })
    # all triplets is overridden by golden single wait
    TestUtils.test_yaku("sichuan", [], %{
      hand: [:"6p"],
      calls: [{"pon", [:"2p", :"2p", :"2p"]}, {"pon", [:"3m", :"3m", :"3m"]}, {"pon", [:"5m", :"5m", :"5m"]}, {"daiminkan", [:"7m", :"7m", :"7m", :"7m"]}],
      winning_tile: :"6p",
      win_source: :discard,
      yaku_lists: ["yaku", "meta_yaku"],
      expected_yaku: [{"Root", 1}, {"Golden Single Wait", 2}]
    })
    # win after kong
    TestUtils.test_yaku("sichuan", [], %{
      hand: [:"6p"],
      calls: [{"pon", [:"2p", :"2p", :"2p"]}, {"pon", [:"3m", :"3m", :"3m"]}, {"pon", [:"5m", :"5m", :"5m"]}, {"daiminkan", [:"7m", :"7m", :"7m", :"7m"]}],
      winning_tile: :"6p",
      status: ["kan"],
      win_source: :discard,
      yaku_lists: ["yaku", "meta_yaku"],
      expected_yaku: [{"Root", 1}, {"Golden Single Wait", 2}, {"Win After Kong", 1}]
    })
    
  end

end
