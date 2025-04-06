defmodule RiichiAdvanced.YakuTest.SichuanYaku do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "sichuan - declare void suit and win" do
    TestUtils.test_yaku_advanced("sichuan", ["sichuan_no_charleston"], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "4m", "5m", "6m", "2p", "3p", "4p", "7p", "7p", "7p", "6m"],
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
      %{"type" => "discard", "tile" => "6m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: []
      }
    })
  end

  test "sichuan - root" do
    TestUtils.test_yaku_advanced("sichuan", ["sichuan_no_charleston"], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "4m", "5m", "6m", "6p", "7p", "7p", "7p", "7p", "8p", "9p"],
        "south": ["1m", "2m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "2s", "4s", "5s", "7s"],
        "west": ["1m", "2m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "2s", "4s", "5s", "7s"],
        "north": ["1m", "2m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "1s", "9p", "9p", "9p"]
      },
      "starting_draws": ["1m", "6p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [
        %{"button" => "void_souzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_manzu"}
      ]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Root", 1}],
        yaku2: []
      }
    })
  end

  test "sichuan - root x2" do
    TestUtils.test_yaku_advanced("sichuan", ["sichuan_no_charleston"], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "3m", "3m", "3m", "4m", "5m", "7p", "7p", "7p", "7p", "8p", "9p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "2s", "4s", "5s", "7s"],
        "west": ["1m", "4m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "2s", "4s", "5s", "7s"],
        "north": ["1m", "4m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "1s", "9p", "9p", "9p"]
      },
      "starting_draws": ["1p", "1m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [
        %{"button" => "void_souzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_manzu"}
      ]},
      %{"type" => "discard", "tile" => "1p", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "1m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Root", 2}],
        yaku2: []
      }
    })
  end

  test "sichuan - root x4" do
    TestUtils.test_yaku_advanced("sichuan", ["sichuan_no_charleston"], """
    {
      "starting_hand": {
        "east": ["9m", "9m", "9m", "5m", "2s", "2s", "2s", "3s", "3s", "3s", "4s", "4s", "4s"],
        "south": ["2m", "4m", "7m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "1s", "6s", "7s"],
        "west": ["2m", "4m", "7m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "1s", "6s", "7s"],
        "north": ["2m", "4m", "7m", "1p", "3p", "4p", "6p", "7p", "8p", "9p", "1s", "6s", "7s"]
      },
      "starting_draws": ["6m", "2s", "1m", "4s", "1m", "9m", "1m", "3s", "1m", "5m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [
        %{"button" => "void_pinzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_manzu"}
      ]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "2s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "daiminkan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "daiminkan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "9m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "daiminkan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "daiminkan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Golden Single Wait", 2}, {"Root", 4}],
        yaku2: []
      }
    })
  end

  test "sichuan - all triplets" do
    TestUtils.test_yaku_advanced("sichuan", ["sichuan_no_charleston"], """
    {
      "starting_hand": {
        "east": ["2m", "2m", "2m", "3m", "3m", "3m", "7p", "7p", "7p", "8p", "8p", "8p", "9p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "2s", "4s", "5s", "7s"],
        "west": ["1m", "4m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "2s", "4s", "5s", "7s"],
        "north": ["1m", "4m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "1s", "8s", "8s", "8s"]
      },
      "starting_draws": ["1p", "9p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [
        %{"button" => "void_souzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_manzu"}
      ]},
      %{"type" => "discard", "tile" => "1p", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "9p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"All Triplets", 1}],
        yaku2: []
      }
    })
  end

  test "sichuan - full flush" do
    TestUtils.test_yaku_advanced("sichuan", ["sichuan_no_charleston"], """
    {
      "starting_hand": {
        "east": ["2m", "2m", "2m", "3m", "4m", "5m", "7m", "7m", "7m", "8m", "8m", "8m", "9m"],
        "south": ["1m", "4m", "6m", "2p", "5p", "1s", "3s", "6s", "9s", "2s", "4s", "5s", "7s"],
        "west": ["1m", "4m", "6m", "2p", "5p", "1s", "3s", "6s", "9s", "2s", "4s", "5s", "7s"],
        "north": ["1m", "4m", "6m", "2p", "5p", "1s", "3s", "6s", "9s", "1s", "9p", "9p", "9p"]
      },
      "starting_draws": ["1p", "9m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [
        %{"button" => "void_souzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_manzu"}
      ]},
      %{"type" => "discard", "tile" => "1p", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "9m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Full Flush", 2}],
        yaku2: []
      }
    })
  end

  test "sichuan - seven pairs (with repeat)" do
    TestUtils.test_yaku_advanced("sichuan", ["sichuan_no_charleston"], """
    {
      "starting_hand": {
        "east": ["2m", "2m", "2m", "2m", "3m", "3m", "5m", "5m", "7p", "7p", "8p", "8p", "9p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "2s", "4s", "5s", "7s"],
        "west": ["1m", "4m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "2s", "4s", "5s", "7s"],
        "north": ["1m", "4m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "1s", "8s", "8s", "8s"]
      },
      "starting_draws": ["1p", "9p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [
        %{"button" => "void_souzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_manzu"}
      ]},
      %{"type" => "discard", "tile" => "1p", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "9p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Root", 1}, {"Seven Pairs", 2}],
        yaku2: []
      }
    })
  end

  test "sichuan - golden single wait" do
    TestUtils.test_yaku_advanced("sichuan", ["sichuan_no_charleston"], """
    {
      "starting_hand": {
        "east": ["2m", "2m", "2m", "2m", "3m", "3m", "5m", "5m", "7p", "7p", "7p", "8p", "1p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "2s", "4s", "5s", "7s"],
        "west": ["1m", "4m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "2s", "4s", "5s", "7s"],
        "north": ["1m", "4m", "7m", "2p", "5p", "1s", "3s", "6s", "9s", "1s", "9p", "9p", "9p"]
      },
      "starting_draws": ["1p", "1p", "3m", "5m", "7p", "8p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [
        %{"button" => "void_souzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_manzu"}
      ]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1p", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "3m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1p", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1p", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "7p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "7p", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "8p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Golden Single Wait", 2}, {"Root", 1}],
        yaku2: []
      }
    })
  end

  test "sichuan - rinshan" do
    TestUtils.test_yaku_advanced("sichuan", ["sichuan_no_charleston"], """
    {
      "starting_hand": {
        "east": ["2m", "2m", "2m", "2m", "3m", "4m", "5m", "6m", "7p", "7p", "8p", "8p", "9p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "6p", "3s", "6s", "9s", "1s", "2s", "4s", "5s"],
        "west": ["1m", "4m", "7m", "2p", "5p", "6p", "3s", "6s", "9s", "1s", "2s", "4s", "5s"],
        "north": ["1m", "4m", "7m", "2p", "5p", "6p", "3s", "6s", "9s", "1s", "7s", "7s", "7s"]
      },
      "starting_draws": ["6m", "9p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [
        %{"button" => "void_souzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_manzu"}
      ]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Root", 1}, {"Win After Kong", 1}],
        yaku2: []
      }
    })
  end

  test "sichuan - chankan" do
    TestUtils.test_yaku_advanced("sichuan", ["sichuan_no_charleston"], """
    {
      "starting_hand": {
        "east": ["2m", "2m", "2m", "3m", "3m", "4m", "4m", "7p", "8p", "9p", "7m", "8m", "1m"],
        "south": ["9m", "9m", "3m", "2p", "5p", "6p", "3s", "6s", "8s", "2s", "4s", "5s", "7s"],
        "west": ["1m", "4m", "7m", "2p", "5p", "6p", "3s", "6s", "8s", "2s", "4s", "5s", "7s"],
        "north": ["1m", "4m", "7m", "2p", "5p", "6p", "3s", "6s", "8s", "1s", "9s", "9s", "9s"]
      },
      "starting_draws": ["9m", "9m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [
        %{"button" => "void_souzu"},
        %{"button" => "void_pinzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_manzu"}
      ]},
      %{"type" => "discard", "tile" => "9m", "player" => 0, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "pon"}, nil, nil]},
      %{"type" => "discard", "tile" => "3m", "player" => 1, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "kakan"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chankan"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Robbing The Kong", 1}],
        yaku2: []
      }
    })
  end

  test "sichuan - kanburi" do
    TestUtils.test_yaku_advanced("sichuan", ["sichuan_no_charleston"], """
    {
      "starting_hand": {
        "east": ["2m", "2m", "2m", "3m", "3m", "4m", "4m", "7p", "8p", "9p", "6m", "7m", "8m"],
        "south": ["9m", "9m", "9m", "9m", "5p", "6p", "3s", "6s", "8s", "2s", "4s", "5s", "7s"],
        "west": ["1m", "4m", "7m", "2p", "5p", "6p", "3s", "6s", "8s", "2s", "4s", "5s", "7s"],
        "north": ["1m", "4m", "7m", "2p", "5p", "6p", "3s", "6s", "8s", "1s", "9s", "9s", "9s"]
      },
      "starting_draws": ["1m", "3m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [
        %{"button" => "void_souzu"},
        %{"button" => "void_pinzu"},
        %{"button" => "void_manzu"},
        %{"button" => "void_manzu"}
      ]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ankan"}, nil, nil]},
      %{"type" => "discard", "tile" => "3m", "player" => 1, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Shoot After Kong", 1}],
        yaku2: []
      }
    })
  end

  test "sichuan - under the sea" do
    TestUtils.test_yaku_advanced("sichuan", ["sichuan_no_charleston"], """
    {
      "starting_hand": {
        "east": ["5p","9s","2p","5m","7p","9m","4m","4s","3p","7m","5s","9s","6s"],
        "south": ["9p","5s","4p","2s","2m","9m","1s","8m","4m","3p","7m","6p","1m"],
        "west": ["2p","3s","8s","4s","5s","8p","4p","6m","6p","1m","6s","8p","5p"],
        "north": ["8m","1p","6m","1s","8p","1p","4m","7s","8m","3s","8s","5m","6p"]
      },
      "starting_draws": ["1s","9s","5p","4s","2m","2s","2p","1p","2m","3m","7m","7p","5m","5s","2s","1m","7p","4p","6m","9m","3p","1s","1m","2s","9m","2m","7s","9s","6s","3p","4m","5p","8s","3m","9p","4p","6s","3m","8p","7p","6p","9p","6m","1p","3s","9p","7s","4s","3s","8s","5m","2p","7s","7m","3m","8m"]
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
      %{"player" => 0, "tile" => "8s", "tsumogiri" => true, "type" => "discard"},
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
      %{"buttons" => [nil, nil, nil, %{"button" => "tsumo"}], "type" => "buttons_pressed"}
    ], %{
      north: %{
        yaku: [{"Under The Sea", 1}]
      }
    })
  end

end
