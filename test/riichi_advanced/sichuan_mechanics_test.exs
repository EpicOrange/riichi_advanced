defmodule RiichiAdvanced.YakuTest.SichuanMechanics do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "sichuan - void suit disallows win" do
    TestUtils.test_yaku_advanced("sichuan", ["sichuan_no_charleston"], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "4m", "5m", "6m", "7p", "7p", "7p", "6m", "2s", "3s", "4s"],
        "south": ["1m", "2m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "2s", "4s", "5s", "7s"],
        "west": ["1m", "2m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "2s", "4s", "5s", "7s"],
        "north": ["1m", "2m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "1s", "9p", "9p", "9p"]
      },
      "starting_draws": ["1m", "6m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [
        %{"button" => "void_souzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_manzu"}
      ]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6m", "player" => 1, "tsumogiri" => true}
    ], :no_winners)
  end

  test "sichuan - void penalty" do
    TestUtils.test_yaku_advanced("sichuan", ["show_waits", "sichuan_no_charleston"], """
    {
      "starting_hand": {
        "east": ["5p","9s","2p","5m","7p","9m","4m","4s","3p","7m","5s","9s","6s"],
        "south": ["9p","5s","4p","2s","5m","9m","1s","8m","4m","3p","7m","6p","1m"],
        "west": ["2m","3s","8s","4s","5s","8p","4p","6m","6p","1m","6s","8p","5p"],
        "north": ["8m","1p","6m","1s","8p","1p","4m","7s","8m","3s","8s","2p","6p"]
      },
      "starting_draws": ["1s","9s","5p","4s","2m","2s","2p","1p","2m","3m","7m","7p","5m","5s","2s","1m","7p","4p","6m","9m","3p","1s","1m","2s","9m","2m","7s","9s","6s","3p","4m","5p","8m","3m","9p","4p","6s","3m","8p","7p","6p","9p","6m","1p","3s","9p","7s","4s","3s","8s","5m","2p","7s","7m","3m","8s"]
    }
    """, [
      %{"buttons" => [%{"button" => "void_manzu"}, %{"button" => "void_souzu"}, %{"button" => "void_manzu"}, %{"button" => "void_pinzu"}], "type" => "buttons_pressed"},
      %{"player" => 0, "tile" => "9m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "9s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "6m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 3, "tile" => "8p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "2m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "2s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "1m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 3, "tile" => "6p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "2m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "5s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 2, "tile" => "7m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "1p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "5m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "5s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "2s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "1p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "7m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "2s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 2, "tile" => "6m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "1p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "5m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "1s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "1m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "7p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "9m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "1s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 2, "tile" => "7s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "9m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "4m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "3p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "4m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "1m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "8m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "3m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "9p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "5p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "6s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "3m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "8p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "4p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "6p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "9p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "6m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "7p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "3s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "9p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "7s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "1p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "3s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "8s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "5m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "2p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "7s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "7m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "3m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "8s", "tsumogiri" => true, "type" => "discard"}
    ], :no_winners, %{delta_scores: [32, 32, -32, -32]})
  end

  test "sichuan - kakan from hand awards no points" do
    TestUtils.test_yaku_advanced("sichuan", ["sichuan_no_charleston"], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "6m", "9p", "6m", "7p", "7p", "7p", "6m", "2s", "3s", "4s"],
        "south": ["1m", "2m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "2s", "4s", "5s", "7s"],
        "west": ["1m", "2m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "2s", "4s", "5s", "7s"],
        "north": ["1m", "2m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "1s", "9p", "9p", "9p"]
      },
      "starting_draws": ["1m", "6m", "5m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [
        %{"button" => "void_souzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_souzu"}
      ]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "9p", "player" => 0, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "pon"}]},
      %{"type" => "discard", "tile" => "1s", "player" => 3, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "kakan"}, nil, nil, nil]}
    ], :no_winners, %{scores: [0, 0, 0, 0]})
  end

  test "sichuan - kakan awards no points until discard" do
    TestUtils.test_yaku_advanced("sichuan", ["sichuan_no_charleston"], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "4m", "9p", "6m", "7p", "7p", "7p", "6m", "2s", "3s", "4s"],
        "south": ["1m", "2m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "2s", "4s", "5s", "7s"],
        "west": ["1m", "2m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "2s", "4s", "5s", "7s"],
        "north": ["1m", "2m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "1s", "9p", "9p", "9p"]
      },
      "starting_draws": ["1m", "6m", "6m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [
        %{"button" => "void_souzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_souzu"}
      ]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "9p", "player" => 0, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "pon"}]},
      %{"type" => "discard", "tile" => "1s", "player" => 3, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "kakan"}, nil, nil, nil]}
    ], :no_winners, %{scores: [0, 0, 0, 0]})
  end

  test "sichuan - daiminkan awards no points until discard" do
    TestUtils.test_yaku_advanced("sichuan", ["sichuan_no_charleston"], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "4m", "6m", "6m", "7p", "7p", "7p", "6m", "2s", "3s", "4s"],
        "south": ["1m", "2m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "2s", "4s", "5s", "7s"],
        "west": ["1m", "2m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "2s", "4s", "5s", "7s"],
        "north": ["1m", "2m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "1s", "9p", "9p", "9p"]
      },
      "starting_draws": ["1m", "3m", "6m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [
        %{"button" => "void_souzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_souzu"}
      ]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "3m", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6m", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "daiminkan"}, nil, nil, nil]},
    ], :no_winners, %{scores: [0, 0, 0, 0]})
  end
  
  test "sichuan - ankan awards no points until discard" do
    TestUtils.test_yaku_advanced("sichuan", ["sichuan_no_charleston"], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "6m", "6m", "7p", "7p", "7p", "6m", "2s", "3s", "4s"],
        "south": ["1m", "2m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "2s", "4s", "5s", "7s"],
        "west": ["1m", "2m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "2s", "4s", "5s", "7s"],
        "north": ["1m", "2m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "1s", "9p", "9p", "9p"]
      },
      "starting_draws": ["6m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [
        %{"button" => "void_souzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_souzu"}
      ]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]}
    ], :no_winners, %{scores: [0, 0, 0, 0]})
  end

  test "sichuan - kakan awards points after discard" do
    TestUtils.test_yaku_advanced("sichuan", ["sichuan_no_charleston"], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "4m", "9p", "6m", "7p", "7p", "7p", "6m", "2s", "3s", "4s"],
        "south": ["1m", "2m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "2s", "4s", "5s", "7s"],
        "west": ["1m", "2m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "2s", "4s", "5s", "7s"],
        "north": ["1m", "2m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "1s", "9p", "9p", "9p"]
      },
      "starting_draws": ["1m", "6m", "6m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [
        %{"button" => "void_souzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_souzu"}
      ]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "9p", "player" => 0, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "pon"}]},
      %{"type" => "discard", "tile" => "1s", "player" => 3, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "kakan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "3s", "player" => 0, "tsumogiri" => false}
    ], :no_winners, %{scores: [3, -1, -1, -1]})
  end

  test "sichuan - daiminkan awards points after discard" do
    TestUtils.test_yaku_advanced("sichuan", ["sichuan_no_charleston"], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "4m", "6m", "6m", "7p", "7p", "7p", "6m", "2s", "3s", "4s"],
        "south": ["1m", "2m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "2s", "4s", "5s", "7s"],
        "west": ["1m", "2m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "2s", "4s", "5s", "7s"],
        "north": ["1m", "2m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "1s", "9p", "9p", "9p"]
      },
      "starting_draws": ["1m", "3m", "6m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [
        %{"button" => "void_souzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_souzu"}
      ]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "3m", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6m", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "daiminkan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "3s", "player" => 0, "tsumogiri" => false}
    ], :no_winners, %{scores: [2, 0, -2, 0]})
  end
  
  test "sichuan - ankan awards points after discard" do
    TestUtils.test_yaku_advanced("sichuan", ["sichuan_no_charleston"], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "6m", "6m", "7p", "7p", "7p", "6m", "2s", "3s", "4s"],
        "south": ["1m", "2m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "2s", "4s", "5s", "7s"],
        "west": ["1m", "2m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "2s", "4s", "5s", "7s"],
        "north": ["1m", "2m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "1s", "9p", "9p", "9p"]
      },
      "starting_draws": ["6m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [
        %{"button" => "void_souzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_souzu"}
      ]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "3s", "player" => 0, "tsumogiri" => false}
    ], :no_winners, %{scores: [6, -2, -2, -2]})
  end

  test "sichuan - chankan skips kakan payment" do
    TestUtils.test_yaku_advanced("sichuan", ["sichuan_no_charleston"], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "6m", "9p", "6m", "7p", "7p", "7p", "6m", "2s", "3s", "4s"],
        "south": ["1m", "2m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "2s", "4s", "5s", "7s"],
        "west": ["1m", "2m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "2s", "4s", "5s", "7s"],
        "north": ["4m", "4m", "7m", "8m", "4p", "4p", "4p", "8p", "8p", "8p", "9p", "9p", "1s"]
      },
      "starting_draws": ["1m", "6m", "5m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [
        %{"button" => "void_souzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_souzu"}
      ]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "9p", "player" => 0, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "pon"}]},
      %{"type" => "discard", "tile" => "1s", "player" => 3, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "kakan"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "chankan"}]}
    ], %{
      north: %{
        yaku: [{"Robbing The Kong", 1}],
        yaku2: []
      }
    }, %{scores: [-2, 0, 0, 2]})
  end

  test "sichuan - kanburi skips kan payment" do
    TestUtils.test_yaku_advanced("sichuan", ["sichuan_no_charleston"], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "6m", "9p", "6m", "7p", "7p", "7p", "1s", "2s", "3s", "4s"],
        "south": ["1m", "2m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "2s", "4s", "5s", "7s"],
        "west": ["1m", "2m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "2s", "4s", "5s", "7s"],
        "north": ["3m", "5m", "9m", "9m", "4p", "4p", "4p", "8p", "8p", "8p", "9p", "9p", "1s"]
      },
      "starting_draws": ["1m", "6m", "6m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [
        %{"button" => "void_souzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_souzu"}
      ]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "9p", "player" => 0, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "pon"}]},
      %{"type" => "discard", "tile" => "1s", "player" => 3, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "kakan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "4m", "player" => 0, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "ron"}]}
    ], %{
      north: %{
        yaku: [{"Shoot After Kong", 1}],
        yaku2: []
      }
    }, %{scores: [-2, 0, 0, 2]})
  end

  test "sichuan - skipped chankan no kan payment until discard" do
    TestUtils.test_yaku_advanced("sichuan", ["sichuan_no_charleston"], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "6m", "9p", "6m", "7p", "7p", "7p", "1s", "2s", "3s", "4s"],
        "south": ["1m", "2m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "2s", "4s", "5s", "7s"],
        "west": ["1m", "2m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "2s", "4s", "5s", "7s"],
        "north": ["5m", "7m", "9m", "9m", "4p", "4p", "4p", "8p", "8p", "8p", "9p", "9p", "1s"]
      },
      "starting_draws": ["1m", "6m", "6m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [
        %{"button" => "void_souzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_souzu"}
      ]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "9p", "player" => 0, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "pon"}]},
      %{"type" => "discard", "tile" => "1s", "player" => 3, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "kakan"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "skip"}]}
    ], :no_winners, %{scores: [0, 0, 0, 0]})
  end

  test "sichuan - skipped chankan allows kan payment after discard" do
    TestUtils.test_yaku_advanced("sichuan", ["sichuan_no_charleston"], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "6m", "9p", "6m", "7p", "7p", "7p", "1s", "2s", "3s", "4s"],
        "south": ["1m", "2m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "2s", "4s", "5s", "7s"],
        "west": ["1m", "2m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "2s", "4s", "5s", "7s"],
        "north": ["5m", "7m", "9m", "9m", "4p", "4p", "4p", "8p", "8p", "8p", "9p", "9p", "1s"]
      },
      "starting_draws": ["1m", "6m", "6m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [
        %{"button" => "void_souzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_souzu"}
      ]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "9p", "player" => 0, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "pon"}]},
      %{"type" => "discard", "tile" => "1s", "player" => 3, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "kakan"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "skip"}]},
      %{"type" => "discard", "tile" => "4m", "player" => 0, "tsumogiri" => false}
    ], :no_winners, %{scores: [3, -1, -1, -1]})
  end

end
