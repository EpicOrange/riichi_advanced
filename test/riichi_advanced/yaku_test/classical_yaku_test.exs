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
      "starting_draws": ["1z", "1f"],
      "starting_dead_wall": ["2f", "3f", "4f", "6p"]
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
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "tsumo"}, nil, nil]}
    ], %{
      south: %{
        yaku: [{"All Flowers", 4}, {"Concealed Hand", 1}, {"Out on a Replacement", 1}],
        yaku2: [],
        minipoints: 58, # 32 closed tsumo + 2 tanki wait + 2x4 closed triplet + 4x4 flowers = 58
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
      "starting_draws": ["1z", "1g"],
      "starting_dead_wall": ["2g", "3g", "4g", "6p"]
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
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "tsumo"}, nil, nil]}
    ], %{
      south: %{
        yaku: [{"All Seasons", 4}, {"Concealed Hand", 1}, {"Out on a Replacement", 1}],
        yaku2: [],
        minipoints: 58, # 32 closed tsumo + 2 tanki wait + 2x4 closed triplet + 4x4 flowers = 58
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

  # TODO:

  # "Plucking the Moon from the Bottom of the Sea"
  # "Gathering the Plum Blossom from the Roof"
  # "Scratching a Carrying-Pole"
  # "Dealer's 13 Consecutive Win"
  
  # "Last Tile Draw"
  # "Last Tile Discard"

end
