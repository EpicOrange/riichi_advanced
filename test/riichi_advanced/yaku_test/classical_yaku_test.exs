defmodule RiichiAdvanced.YakuTest.ClassicalYaku do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "classical - chicken hand" do
    TestUtils.test_yaku_advanced("classical", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "5m", "5m", "5m", "7m", "8m", "9m", "8s", "8s", "8s", "6p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [],
        minipoints: 40, # 30 closed ron + 2 tanki wait + 2x4 closed triplet = 40
        score: 80 # dealer x2
      }
    })
  end

  test "classical - pure straight" do
    TestUtils.test_yaku_advanced("classical", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "4m", "5m", "6m", "7m", "8m", "9m", "8s", "8s", "8s", "6p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Pure Straight", 1}],
        yaku2: [],
        minipoints: 36, # 30 closed ron + 2 tanki wait + 4 closed triplet = 36
        score: 144 # 1 doubling, dealer x2
      }
    })
  end

  test "classical - all triplets, three concealed" do
    TestUtils.test_yaku_advanced("classical", [], """
    {
      "starting_hand": {
        "east": ["2m", "2m", "2m", "5m", "5m", "5m", "9m", "9m", "9m", "8s", "8s", "6p", "6p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"All Triplets", 1}, {"Three Concealed Triplets", 1}],
        yaku2: [],
        minipoints: 48, # 30 closed ron + 2x4 closed triplet + 8 closed terminal triplet + 2 open triplet = 48
        score: 384 # 2 doublings, dealer x2
      }
    })
  end

  test "classical - four concealed triplets" do
    TestUtils.test_yaku_advanced("classical", [], """
    {
      "starting_hand": {
        "east": ["2m", "2m", "2m", "5m", "5m", "5m", "8m", "8m", "8m", "8s", "8s", "8s", "6p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"Four Concealed Triplets", 1}],
        minipoints: 48, # 30 closed ron + 2 tanki wait + 4x4 closed triplet = 48
        score: 500 # limit
      }
    })
  end

  test "classical - white dragon" do
    TestUtils.test_yaku_advanced("classical", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "5m", "5m", "5m", "7m", "8m", "9m", "0z", "0z", "0z", "6p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"White Dragon", 1}],
        yaku2: [],
        minipoints: 44, # 30 closed ron + 2 tanki wait + 4 closed triplet + 8 closed honor triplet = 44
        score: 176 # 1 doubling, dealer x2
      }
    })
  end

  test "classical - green dragon" do
    TestUtils.test_yaku_advanced("classical", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "5m", "5m", "5m", "7m", "8m", "9m", "6z", "6z", "6z", "6p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Green Dragon", 1}],
        yaku2: [],
        minipoints: 44, # 30 closed ron + 2 tanki wait + 4 closed triplet + 8 closed honor triplet = 44
        score: 176 # 1 doubling, dealer x2
      }
    })
  end

  test "classical - red dragon" do
    TestUtils.test_yaku_advanced("classical", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "5m", "5m", "5m", "7m", "8m", "9m", "7z", "7z", "7z", "6p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Red Dragon", 1}],
        yaku2: [],
        minipoints: 44, # 30 closed ron + 2 tanki wait + 4 closed triplet + 8 closed honor triplet = 44
        score: 176 # 1 doubling, dealer x2
      }
    })
  end

  test "classical - little three dragons" do
    TestUtils.test_yaku_advanced("classical", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "4p", "4p", "4p", "0z", "0z", "0z", "6z", "6z", "7z", "7z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"White Dragon", 1}, {"Green Dragon", 1}, {"Little Three Dragons", 3}],
        yaku2: [],
        minipoints: 48, # 30 closed ron + 2 yakuhai pair + 8 closed honor triplet + 4 closed triplet + 4 open honor triplet = 48
        score: 500 # 5 doublings, dealer x2
      }
    })
  end

  test "classical - all simples" do
    TestUtils.test_yaku_advanced("classical", [], """
    {
      "starting_hand": {
        "east": ["2m", "3m", "4m", "5m", "6m", "7m", "2p", "3p", "4p", "8s", "8s", "8s", "6p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"All Simples", 1}],
        yaku2: [],
        minipoints: 36, # 30 closed ron + 2 tanki wait + 4 closed triplet = 36
        score: 144 # 1 doubling, dealer x2
      }
    })
  end

  test "classical - prevalent and seat wind" do
    TestUtils.test_yaku_advanced("classical", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "5m", "5m", "5m", "7m", "8m", "9m", "1z", "1z", "1z", "6p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "7z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "7z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "7z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2z", "6p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "2z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Prevalent Wind", 1}, {"Seat Wind", 1}],
        yaku2: [],
        minipoints: 44, # 30 closed ron + 2 tanki wait + 4 closed triplet + 8 closed honor triplet = 44
        score: 352 # 2 doublings, dealer x2
      }
    })
  end
  
  test "classical - non-prevalent or seat wind" do
    TestUtils.test_yaku_advanced("classical", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "2z", "2z", "2z", "3z", "3z", "3z", "4z", "4z", "6p", "6p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "0z", "6z", "7z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "0z", "6z", "7z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "0z", "6z", "7z"]
      },
      "starting_draws": ["2z", "4z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "2z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "4z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [],
        minipoints: 50, # 30 closed ron + 2x8 closed honor triplet + 4 open honor triplet = 50
        score: 100 # dealer x2
      }
    })
  end
  
  test "classical - outside hand" do
    TestUtils.test_yaku_advanced("classical", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "7p", "8p", "9p", "3z", "3z", "3z", "4z", "4z", "0z", "0z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "6z", "7z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "6z", "7z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "6z", "7z"]
      },
      "starting_draws": ["2z", "4z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "2z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "4z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Outside Hand", 1}],
        yaku2: [],
        minipoints: 44, # 30 closed ron + 8 closed honor triplet + 4 open honor triplet + 2 yakuhai pair = 44
        score: 176 # 1 doubling, dealer x2
      }
    })
  end
  
  test "classical - all terminals and honors" do
    TestUtils.test_yaku_advanced("classical", [], """
    {
      "starting_hand": {
        "east": ["1m", "1m", "1m", "9p", "9p", "9p", "3z", "3z", "3z", "4z", "4z", "1z", "1z"],
        "south": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "0z", "6z", "7z"],
        "west": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "0z", "6z", "7z"],
        "north": ["2m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "0z", "6z", "7z"]
      },
      "starting_draws": ["2z", "4z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "2z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "4z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Outside Hand", 1}, {"All Triplets", 1}, {"All Terminals and Honors", 1}, {"Three Concealed Triplets", 1}],
        yaku2: [],
        minipoints: 62, # 30 closed ron + 3x8 closed honor/terminal triplet + 4 open honor triplet + 4 double yakuhai pair = 62
        score: 500 # 4 doublings, dealer x2
      }
    })
  end
  
  test "classical - half flush" do
    TestUtils.test_yaku_advanced("classical", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "6m", "7m", "8m", "3z", "3z", "3z", "4z", "4z", "1z", "1z"],
        "south": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "0z", "6z", "7z"],
        "west": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "0z", "6z", "7z"],
        "north": ["2m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "0z", "6z", "7z"]
      },
      "starting_draws": ["2z", "4z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "2z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "4z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Half Flush", 1}],
        yaku2: [],
        minipoints: 46, # 30 closed ron + 8 closed honor triplet + 4 open honor triplet + 4 double yakuhai pair = 46
        score: 184 # 1 doubling, dealer x2
      }
    })
  end

  test "classical - full flush" do
    TestUtils.test_yaku_advanced("classical", [], """
    {
      "starting_hand": {
        "east": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "0z", "6z", "7z"],
        "south": ["1m", "2m", "2m", "3m", "3m", "3m", "4m", "4m", "5m", "7m", "7m", "7m", "8m"],
        "west": ["4m", "8m", "2p", "3p", "5p", "8p", "3s", "6s", "9s", "2z", "0z", "6z", "7z"],
        "north": ["2m", "3m", "8m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "0z", "6z", "7z"]
      },
      "starting_draws": ["6m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 0, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ron"}, nil, nil]}
    ], %{
      south: %{
        yaku: [{"Full Flush", 4}],
        yaku2: [],
        minipoints: 30, # 30 closed ron = 30
        score: 480 # 4 doublings
      }
    })
  end

  test "classical - out on a replacement and concealed hand" do
    TestUtils.test_yaku_advanced("classical", [], """
    {
      "starting_hand": {
        "east": ["1m", "1m", "1m", "6m", "7m", "8m", "3z", "3z", "3z", "4z", "4z", "1z", "1z"],
        "south": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "0z", "6z", "7z"],
        "west": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "0z", "6z", "7z"],
        "north": ["2m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "0z", "6z", "7z"]
      },
      "starting_draws": ["1m"],
      "starting_dead_wall": ["4z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Concealed Hand", 1}, {"Half Flush", 1}, {"Out on a Replacement", 1}, {"Three Concealed Triplets", 1}],
        yaku2: [],
        minipoints: 84, # 32 closed tsumo + 32 closed honor kan + 2x8 closed honor triplet + 4 double yakuhai pair = 84
        score: 500 # 4 doublings, dealer x2
      }
    })
  end
  
  test "classical - robbing the kong" do
    TestUtils.test_yaku_advanced("classical", [], """
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
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "9m", "player" => 0, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "pon"}, nil, nil]},
      %{"type" => "discard", "tile" => "3m", "player" => 1, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "kakan"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chankan"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Robbing the Kong", 1}],
        yaku2: [],
        minipoints: 26, # 20 open ron + 2 open triplet + 4 closed triplet = 26
        score: 104 # 1 doubling, dealer x2
      }
    })
  end
  
  test "classical - seat flower and season" do
    TestUtils.test_yaku_advanced("classical", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "5m", "5m", "5m", "7m", "8m", "9m", "8s", "8s", "8s", "6p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1f", "6p"],
      "starting_dead_wall": ["1g", "2f", "2g", "1z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Seat Flower", 1}, {"Seat Season", 1}],
        yaku2: [],
        minipoints: 56, # 30 closed ron + 2 tanki wait + 2x4 closed triplet + 4x4 flowers = 56
        score: 448 # 2 doublings, dealer x2
      }
    })
  end

  test "classical - all flowers" do
    TestUtils.test_yaku_advanced("classical", [], """
    {
      "starting_hand": {
        "east": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "south": ["1m", "2m", "3m", "5m", "5m", "5m", "7m", "8m", "9m", "8s", "8s", "8s", "6p"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "1f", "6p"],
      "starting_dead_wall": ["2f", "3f", "4f", "2z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "flower"}, nil, nil]},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ron"}, nil, nil]}
    ], %{
      south: %{
        yaku: [{"All Flowers", 4}, {"Seat Flower", 1}],
        yaku2: [],
        minipoints: 56, # 30 closed ron + 2 tanki wait + 2x4 closed triplet + 4x4 flowers = 56
        score: 500 # 6 doublings
      }
    })
  end

  test "classical - all seasons" do
    TestUtils.test_yaku_advanced("classical", [], """
    {
      "starting_hand": {
        "east": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "south": ["1m", "2m", "3m", "5m", "5m", "5m", "7m", "8m", "9m", "8s", "8s", "8s", "6p"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "1g", "6p"],
      "starting_dead_wall": ["2g", "3g", "4g", "2z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "flower"}, nil, nil]},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 2, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ron"}, nil, nil]}
    ], %{
      south: %{
        yaku: [{"All Seasons", 4}, {"Seat Season", 1}],
        yaku2: [],
        minipoints: 56, # 30 closed ron + 2 tanki wait + 2x4 closed triplet + 4x4 flowers = 56
        score: 500 # 6 doublings
      }
    })
  end

  test "classical - blessing of heaven" do
    TestUtils.test_yaku_advanced("classical", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "5m", "5m", "5m", "7m", "8m", "9m", "8s", "8s", "8s", "6p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"Blessing of Heaven", 1}],
        minipoints: 42, # 32 closed tsumo + 2 tanki wait + 2x4 closed triplet = 42
        score: 500 # limit
      }
    })
  end

  test "classical - blessing of earth" do
    TestUtils.test_yaku_advanced("classical", [], """
    {
      "starting_hand": {
        "east": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "south": ["1m", "2m", "3m", "5m", "5m", "5m", "7m", "8m", "9m", "8s", "8s", "8s", "6p"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "tsumo"}, nil, nil]}
    ], %{
      south: %{
        yaku: [],
        yaku2: [{"Blessing of Earth", 1}],
        minipoints: 42, # 32 closed tsumo + 2 tanki wait + 2x4 closed triplet = 42
        score: 500 # limit
      }
    })
  end

  test "classical - chousuushii" do
    TestUtils.test_yaku_advanced("classical", [], """
    {
      "starting_hand": {
        "east": ["1z", "1z", "1z", "2z", "2z", "2z", "3z", "3z", "3z", "4z", "4z", "5m", "1p"],
        "south": ["1m", "9m", "1p", "9p", "1s", "2s", "3s", "9s", "0z", "6z", "7z", "7z", "7z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "4s", "5s", "6s", "7s", "8s", "9s"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "4s", "5s", "6s", "7s", "8s", "9s"]
      },
      "starting_draws": ["1z", "2z", "3z", "4z", "2m", "3m", "4m", "4z"],
      "starting_dead_wall": ["5m", "5m", "5m", "1p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "5m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "daiminkan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "5m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "daiminkan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "5m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "5m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "2m", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3m", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4m", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "kakan"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"Big Four Winds", 1}, {"Four Kongs", 1}],
        minipoints: 104, # 22 open tsumo + 2 tanki wait + 3x16 open honors kan + 32 closed honors kan = 104
        score: 500 # limit
      }
    })
  end

  test "classical - chinroutou" do
    TestUtils.test_yaku_advanced("classical", [], """
    {
      "starting_hand": {
        "east": ["1m", "1m", "1m", "1p", "1p", "1p", "9p", "9p", "9s", "9s", "1s", "1s", "7z"],
        "south": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "2z", "3z", "4z"],
        "west": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "2z", "3z", "4z"],
        "north": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "1s", "9s"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "1s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "7z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "9s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"All Terminals", 1}],
        minipoints: 44, # 20 open ron + 2x8 closed terminal triplet + 2x4 open triplet = 44
        score: 500 # limit
      }
    })
  end

  test "classical - daisangen tsuuiisou suuankou" do
    TestUtils.test_yaku_advanced("classical", [], """
    {
      "starting_hand": {
        "east": ["0z", "0z", "0z", "6z", "6z", "6z", "2z", "2z", "3z", "3z", "7z", "7z", "7z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "7s", "8s", "9s", "1z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "7s", "8s", "9s", "1z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "7s", "8s", "9s", "1z", "4z"]
      },
      "starting_draws": ["7z"],
      "starting_dead_wall": ["2z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"All Honors", 1}, {"Big Three Dragons", 1}, {"Four Concealed Triplets", 1}],
        minipoints: 88, # 32 closed tsumo + 32 closed honor kan + 3x8 closed honor triplet = 88
        score: 500 # limit
      }
    })
  end

  test "classical - kokushi tenhou with starting flower" do
    TestUtils.test_yaku_advanced("classical", [], """
    {
      "starting_hand": {
        "east": ["1m", "9m", "1p", "9p", "1s", "9s", "1z", "1z", "3z", "4z", "0z", "6z", "7z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "2z", "3z", "4z", "0z"]
      },
      "starting_draws": ["1f"],
      "starting_dead_wall": ["2z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"Blessing of Heaven", 1}, {"Thirteen Orphans", 1}],
        minipoints: 0, # we don't calculate fu for kokushi
        score: 500 # limit
      }
    })
  end

  test "classical - chuurenpoutou chiihou with starting flower" do
    TestUtils.test_yaku_advanced("classical", [], """
    {
      "starting_hand": {
        "east": ["2m", "4m", "8m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "south": ["1m", "1m", "1m", "2m", "3m", "4m", "5m", "7m", "1f", "8m", "9m", "9m", "9m"],
        "west": ["2m", "4m", "8m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["2m", "4m", "8m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6m"],
      "starting_dead_wall": ["7m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "tsumo"}, nil, nil]}
    ], %{
      south: %{
        yaku: [],
        yaku2: [{"Blessing of Earth", 1}, {"Nine Gates", 1}],
        minipoints: 46, # 32 closed tsumo + 2 closed wait + 8 closed terminal triplet + 4 flower = 46
        score: 500 # limit
      }
    })
  end

  test "classical - twofold fortune" do
    TestUtils.test_yaku_advanced("classical", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "5m", "5m", "5m", "8m", "9m", "8s", "8s", "8s", "9s", "9s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "7s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "7s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "7s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["5m"],
      "starting_dead_wall": ["8s", "7m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"Two-Fold Fortune", 1}],
        minipoints: 66, # 32 closed tsumo + 2 edge wait + 2x16 closed kan = 66
        score: 500 # limit
      }
    })
  end

  test "classical - uupin kaihou" do
    TestUtils.test_yaku_advanced("classical", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "7m", "8m", "9m", "4p", "6p", "8s", "8s", "8s", "9s", "9s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "7s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "7s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "7s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["8s"],
      "starting_dead_wall": ["5p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "tsumo"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"Gathering the Plum Blossom from the Roof", 1}],
        minipoints: 50, # 32 closed tsumo + 2 middle wait + 16 closed kan = 50
        score: 500 # limit
      }
    })
  end

  test "classical - ryanzou chankan" do
    TestUtils.test_yaku_advanced("classical", [], """
    {
      "starting_hand": {
        "east": ["2m", "2m", "2m", "3m", "3m", "4m", "4m", "7p", "8p", "9p", "3s", "4s", "1m"],
        "south": ["2s", "2s", "3m", "2p", "5p", "6p", "3s", "6s", "8s", "1s", "4s", "5s", "7s"],
        "west": ["1m", "4m", "7m", "2p", "5p", "6p", "3s", "6s", "8s", "1s", "4s", "5s", "7s"],
        "north": ["1m", "4m", "7m", "2p", "5p", "6p", "3s", "6s", "8s", "1s", "9s", "9s", "9s"]
      },
      "starting_draws": ["2s", "2s"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "2s", "player" => 0, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "pon"}, nil, nil]},
      %{"type" => "discard", "tile" => "3m", "player" => 1, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1m", "player" => 0, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "kakan"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chankan"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"Scratching a Carrying-Pole", 1}],
        minipoints: 26, # 20 open ron + 2 open triplet + 4 closed triplet = 26
        score: 500 # 1 doubling, dealer x2
      }
    })
  end

  test "classical - dealer's 13 consecutive win" do
    TestUtils.test_yaku_advanced("classical", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "5m", "5m", "5m", "7m", "8m", "9m", "8s", "8s", "8s", "6p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6p"],
      "starting_honba": 12
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"Dealer's 13 Consecutive Win", 1}],
        minipoints: 40, # 30 closed ron + 2 tanki wait + 2x4 closed triplet = 40
        score: 500 # dealer x2
      }
    })
  end
  
  test "classical - dealer's 12th consecutive win is not awarded" do
    TestUtils.test_yaku_advanced("classical", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "5m", "5m", "5m", "7m", "8m", "9m", "8s", "8s", "8s", "6p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "6p"],
      "starting_honba": 11
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil]},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [],
        minipoints: 40, # 30 closed ron + 2 tanki wait + 2x4 closed triplet = 40
        score: 80 # dealer x2
      }
    })
  end

  test "classical - haitei" do
    TestUtils.test_yaku_advanced("classical", [], """
    {
      "starting_hand": {
        "east": ["5m","8m","4z","8p","2p","4s","6m","7p","2s","6s","5p","7s","1s"],
        "south": ["1s","8s","7z","5m","5m","3s","2m","1p","2p","4p","7z","1z","3z"],
        "west": ["4z","2p","7s","0z","4z","0z","4s","6z","8p","3s","8s","8p","1s"],
        "north": ["2s","6p","2m","5p","2s","0z","3s","8m","4p","3z","9p","4s","3z"]
      },
      "starting_draws": ["7m","8p","9s","1m","3m","4m","9s","5p","7s","2f","2p","3m","5s","4m","3p","8s","1p","2z","6z","7p","5s","2z","3p","1g","2z","1m","8m","7p","7m","7z","1f","9p","8m","6m","0z","7z","3g","2m","5p","1p","6z","7p","6z","4m","3p","1m","8s","9s","1z","3m","4s","3p","4z","3f","9s","1z","6s","2g","7m","6p","4p","9m","6s","9m","4f","4p","9m","4m","6m","7s","2z","3s","6p","2m","9m","5m","6p","6s","7m","2s","5s","4g","9p","3z"],
      "starting_dead_wall": ["1m","1s","6m","5s","9p","3m","1z","1p"],
      "starting_round": 0,
      "starting_honba": 0
    }
    """, [
      %{"buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil], "type" => "buttons_pressed"},
      %{"buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil], "type" => "buttons_pressed"},
      %{"buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil], "type" => "buttons_pressed"},
      %{"buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}], "type" => "buttons_pressed"},
      %{"player" => 0, "tile" => "4z", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "8p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "9s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "0z", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "3m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "4m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "9s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "9p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "7s", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [nil, %{"button" => "flower", "call_choice" => ["2f"], "called_tile" => nil}, nil, nil], "type" => "buttons_pressed"},
      %{"player" => 1, "tile" => "1m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "2p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "8m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "5s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "4m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "3p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "8s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "1p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "2z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "6z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "2s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "5s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "2z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "3p", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [nil, nil, nil, %{"button" => "flower", "call_choice" => ["1g"], "called_tile" => nil}], "type" => "buttons_pressed"},
      %{"player" => 3, "tile" => "1s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "2z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "1m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "8m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "7p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "7m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "7z", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [nil, nil, %{"button" => "flower", "call_choice" => ["1f"], "called_tile" => nil}, nil], "type" => "buttons_pressed"},
      %{"player" => 2, "tile" => "6m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "9p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "8m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "6m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "0z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "7z", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [%{"button" => "flower", "call_choice" => ["3g"], "called_tile" => nil}, nil, nil, nil], "type" => "buttons_pressed"},
      %{"player" => 0, "tile" => "5s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "2m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "5p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "1p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "6z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "7p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "6z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "4m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "3p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "1m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "8s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "9s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "1z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "3m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "4s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "3z", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "4z", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [nil, %{"button" => "flower", "call_choice" => ["3f"], "called_tile" => nil}, nil, nil], "type" => "buttons_pressed"},
      %{"player" => 1, "tile" => "9p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "9s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "1z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "6s", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [nil, %{"button" => "flower", "call_choice" => ["2g"], "called_tile" => nil}, nil, nil], "type" => "buttons_pressed"},
      %{"player" => 1, "tile" => "3m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "7m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "6p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "4p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "9m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "6s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "9m", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [%{"button" => "flower", "call_choice" => ["4f"], "called_tile" => nil}, nil, nil, nil], "type" => "buttons_pressed"},
      %{"player" => 0, "tile" => "1z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "4p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "9m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "4m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "6m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "7s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "2z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "3s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "6p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "2m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "9m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "5m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "6p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "6s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "7m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "2s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "5s", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [nil, %{"button" => "flower", "call_choice" => ["4g"], "called_tile" => nil}, nil, nil], "type" => "buttons_pressed"},
      %{"player" => 1, "tile" => "1p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "9p", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [nil, nil, nil, %{"button" => "tsumo"}], "type" => "buttons_pressed"},
    ], %{
      north: %{
        yaku: [{"Concealed Hand", 1},{"Last Tile Draw", 1}],
        yaku2: [],
        minipoints: 38, # 32 closed ron + 2 tanki wait + 4 flower
        score: 152 # 2 doublings
      }
    })
  end

  test "classical - houtei" do
    TestUtils.test_yaku_advanced("classical", [], """
    {
      "starting_hand": {
        "east": ["6z","2f","9s","3s","4p","4s","3s","7p","6p","2p","8s","8p","1p"],
        "south": ["8m","3m","6z","1p","1z","1p","8s","7m","4s","8s","2s","6m","4m"],
        "west": ["2m","4s","4m","2g","1s","7z","3m","3g","4g","4p","9m","2z","9p"],
        "north": ["6m","7m","5m","2p","9m","5m","3z","6s","7z","3p","4m","2s","9p"]
      },
      "starting_draws": ["5p","1f","4z","1s","1z","4z","9s","6m","7m","2m","3s","9s","8p","4m","9s","9m","4p","3z","3p","4f","5m","7p","1s","8m","2p","2s","2z","5s","2p","9p","7s","1m","7z","9p","5m","5p","7s","1s","5s","6p","5s","7p","1m","0z","5p","8m","3z","6z","1z","8p","1m","7s","0z","7p","7s","6s","4s","2m","9m","2s","8p","6z","0z","3m","3p","2z","3p","5p","1g","4z","5s","8s","1p","1z","8m","7z","3m","2m","7m","2z","6m","4p","6p","3f"],
      "starting_dead_wall": ["0z","6s","1m","4z","6s","6p","3z","3s"],
      "starting_round": 0,
      "starting_honba": 0
    }
    """, [
      %{"buttons" => [%{"button" => "start_flower", "call_choice" => ["2f"], "called_tile" => nil}, nil, nil, nil], "type" => "buttons_pressed"},
      %{"buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil], "type" => "buttons_pressed"},
      %{"buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil], "type" => "buttons_pressed"},
      %{"buttons" => [nil, nil, %{"button" => "start_flower", "call_choice" => ["4g"], "called_tile" => nil}, nil], "type" => "buttons_pressed"},
      %{"buttons" => [nil, nil, %{"button" => "flower", "call_choice" => ["2g"], "called_tile" => nil}, nil], "type" => "buttons_pressed"},
      %{"buttons" => [nil, nil, %{"button" => "flower", "call_choice" => ["3g"], "called_tile" => nil}, nil], "type" => "buttons_pressed"},
      %{"buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil], "type" => "buttons_pressed"},
      %{"buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}], "type" => "buttons_pressed"},
      %{"player" => 0, "tile" => "0z", "tsumogiri" => false, "type" => "discard"},
      %{"buttons" => [nil, %{"button" => "flower", "call_choice" => ["1f"], "called_tile" => nil}, nil, nil], "type" => "buttons_pressed"},
      %{"player" => 1, "tile" => "6s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "4z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "1s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "6z", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "4z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "9s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "6m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "1z", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "2m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "3s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "9s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "7m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "4m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "9s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "9m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "4p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "3z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "3p", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [nil, nil, nil, %{"button" => "flower", "call_choice" => ["4f"], "called_tile" => nil}], "type" => "buttons_pressed"},
      %{"player" => 3, "tile" => "6p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "9s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "7p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "1s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "8m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "8s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "2s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "2z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "5s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "1p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "9p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "7s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "1m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "7z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "9p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "5m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "5p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "7s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "1s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "5s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "6p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "3s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "7p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "1m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "0z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "5m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "8m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "3z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "6z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "1z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "8p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "1m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "7s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "0z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "7p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "7s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "6s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "4s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "2m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "9m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "2s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "8p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "6z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "0z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "3m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "3s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "2z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "3p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "5p", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [%{"button" => "flower", "call_choice" => ["1g"], "called_tile" => nil}, nil, nil, nil], "type" => "buttons_pressed"},
      %{"player" => 0, "tile" => "3z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "4z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "5s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "8s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "1p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "1z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "8m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "7z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "3m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "2m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "7m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "2z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "6m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "4p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "6p", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [nil, nil, nil, %{"button" => "flower", "call_choice" => ["3f"], "called_tile" => nil}], "type" => "buttons_pressed"},
      %{"player" => 3, "tile" => "3s", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [%{"button" => "ron"}, nil, nil, nil], "type" => "buttons_pressed"}
    ], %{
      east: %{
        yaku: [{"All Simples", 1}, {"Last Tile Discard", 1}, {"Seat Season", 1}],
        yaku2: [],
        minipoints: 42, # 30 closed ron + 4 closed triplet + 2x4 flower
        score: 500 # 3 doublings, dealer x2
      }
    })
  end

  test "classical - iipin mouyue" do
    TestUtils.test_yaku_advanced("classical", [], """
    {
      "starting_hand": {
        "east": ["7p","2m","3z","2s","8m","9p","8s","7m","9m","6m","6z","8s","7p"],
        "south": ["2z","8p","7s","3s","6p","5s","3p","2m","1m","5m","5s","2p","4p"],
        "west": ["6s","4m","4m","8m","6z","9m","7p","4s","4z","7s","5m","0z","9m"],
        "north": ["1z","8s","9s","9s","1g","6z","9m","1f","9s","8p","2s","5p","3z"]
      },
      "starting_draws": ["9p","3s","4p","1p","2s","5s","7p","8m","2z","1z","5p","2m","7z","3f","7s","7z","6p","6s","3z","7s","6m","5p","3s","4g","5s","9p","1z","0z","6p","7m","3m","9s","9p","3p","2z","1p","2p","4m","4s","3z","5m","8p","2z","3p","3m","7m","1m","7m","4s","6m","4m","0z","2p","6z","6p","2p","1s","4p","1z","2m","6m","7z","2f","4s","5m","1m","4p","8m","2g","7z","6s","4z","3m","2s","8s","3s","1s","6s","4f","3g","1s","0z","3p","1p"],
      "starting_dead_wall": ["5p","3m","4z","4z","1s","1m","8p","1p"],
      "starting_round": 0,
      "starting_honba": 0
    }
    """, [
      %{"buttons" => [%{"button" => "start_no_flower"}, nil, nil, nil], "type" => "buttons_pressed"},
      %{"buttons" => [nil, %{"button" => "start_no_flower"}, nil, nil], "type" => "buttons_pressed"},
      %{"buttons" => [nil, nil, %{"button" => "start_no_flower"}, nil], "type" => "buttons_pressed"},
      %{"buttons" => [nil, nil, nil, %{"button" => "start_flower", "call_choice" => ["1f"], "called_tile" => nil}], "type" => "buttons_pressed"},
      %{"buttons" => [nil, nil, nil, %{"button" => "start_flower", "call_choice" => ["1g"], "called_tile" => nil}], "type" => "buttons_pressed"},
      %{"buttons" => [nil, nil, nil, %{"button" => "start_no_flower"}], "type" => "buttons_pressed"},
      %{"player" => 0, "tile" => "6z", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 1, "tile" => "3s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "4p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "6z", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "2s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "5s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "7p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "3z", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "2z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "1z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "5p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "1z", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "7z", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [nil, %{"button" => "flower", "call_choice" => ["3f"], "called_tile" => nil}, nil, nil], "type" => "buttons_pressed"},
      %{"player" => 1, "tile" => "4z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "7s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "7z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "6p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "6s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "3z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "2s", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "6m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "5p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "3s", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [nil, nil, nil, %{"button" => "flower", "call_choice" => ["4g"], "called_tile" => nil}], "type" => "buttons_pressed"},
      %{"player" => 3, "tile" => "4z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "5s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "9p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "1z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "0z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "6p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "7m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "3m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "8p", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "9p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "3p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "2z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "9m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "2p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "4m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "4s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "3z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "5m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "8p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "2z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "8m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "3m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "7m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "1m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "7m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "4s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "6m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "4m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "0z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "2p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "6z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "6p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "3m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "1s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "4p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "1z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "2m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "6m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "7z", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [nil, nil, %{"button" => "flower", "call_choice" => ["2f"], "called_tile" => nil}, nil], "type" => "buttons_pressed"},
      %{"player" => 2, "tile" => "1s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "4s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "5m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "1m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "4p", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "8m", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [%{"button" => "flower", "call_choice" => ["2g"], "called_tile" => nil}, nil, nil, nil], "type" => "buttons_pressed"},
      %{"player" => 0, "tile" => "1m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "7z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "6s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "2m", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "3m", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "2s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "8s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 3, "tile" => "3s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 0, "tile" => "1s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "6s", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [nil, nil, %{"button" => "flower", "call_choice" => ["4f"], "called_tile" => nil}, nil], "type" => "buttons_pressed"},
      %{"player" => 2, "tile" => "8p", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [nil, nil, nil, %{"button" => "flower", "call_choice" => ["3g"], "called_tile" => nil}], "type" => "buttons_pressed"},
      %{"player" => 3, "tile" => "4z", "tsumogiri" => false, "type" => "discard"},
      %{"player" => 0, "tile" => "1s", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 1, "tile" => "0z", "tsumogiri" => true, "type" => "discard"},
      %{"player" => 2, "tile" => "3p", "tsumogiri" => true, "type" => "discard"},
      %{"buttons" => [nil, nil, nil, %{"button" => "tsumo"}], "type" => "buttons_pressed"},
    ], %{
      north: %{
        yaku: [],
        yaku2: [{"Plucking the Moon from the Bottom of the Sea", 1}],
        minipoints: 64, # 32 closed tsumo + 2x8 closed terminal triplet + 4x4 flowers
        score: 500
      }
    })
  end

end
