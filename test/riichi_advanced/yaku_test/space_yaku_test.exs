defmodule RiichiAdvanced.YakuTest.SpaceYaku do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "space - sequences wrap" do
    TestUtils.test_yaku_advanced("space", [], """
    {
      "starting_hand": {
        "east": ["9m", "1m", "2m", "8p", "9p", "1p", "1s", "2s", "3s", "7z", "7z", "7z", "6p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "6p"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Chun", 1}],
        yaku2: [],
        minipoints: 40
      }
    })
  end

  test "space - honors form sequences" do
    TestUtils.test_yaku_advanced("space", [], """
    {
      "starting_hand": {
        "east": ["5z", "6z", "7z", "1z", "2z", "3z", "2z", "3z", "4z", "2m", "2m", "2m", "6m"],
        "south": ["1m", "4m", "5m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "5z", "7z"],
        "west": ["1m", "4m", "5m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "5z", "7z"],
        "north": ["1m", "3m", "5m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "5z", "7z"]
      },
      "starting_draws": ["6z", "6m"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Honitsu", 3}],
        yaku2: [],
        minipoints: 40
      }
    })
  end

  test "space - honors sequences wrap" do
    TestUtils.test_yaku_advanced("space", [], """
    {
      "starting_hand": {
        "east": ["5z", "6z", "7z", "1z", "2z", "4z", "5m", "5m", "5m", "2m", "2m", "2m", "6m"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "6m"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Honitsu", 3}],
        yaku2: [],
        minipoints: 40
      }
    })
  end

  test "space - chiitoitsu doesn't work" do
    TestUtils.test_yaku_advanced("space", [], """
    {
      "starting_hand": {
        "east": ["2m", "2m", "5m", "5m", "7m", "7m", "1p", "1p", "4p", "4p", "4s", "4s", "5s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "8m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "5s"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 1, "tsumogiri" => true}
    ], :no_winners)
  end

  test "space - can chii from toimen" do
    TestUtils.test_yaku_advanced("space", [], """
    {
      "starting_hand": {
        "east": ["5z", "6z", "7z", "1z", "2z", "4z", "5m", "5m", "5m", "2m", "2m", "2m", "6m"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "6m", "7m", "2p", "5p", "8p", "3s", "4s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["5s"]
    }
    """, [
      %{"type" => "discard", "tile" => "5s", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, %{"button" => "chii"}, nil]},
      %{"type" => "discard", "tile" => "6m", "player" => 2, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Honitsu", 3}],
        yaku2: [],
        minipoints: 40
      }
    })
  end

  test "space - can chii from shimocha" do
    TestUtils.test_yaku_advanced("space", [], """
    {
      "starting_hand": {
        "east": ["5z", "6z", "7z", "1z", "2z", "4z", "5m", "5m", "5m", "2m", "2m", "2m", "6m"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "6m", "7m", "2p", "5p", "8p", "3s", "4s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["5s"]
    }
    """, [
      %{"type" => "discard", "tile" => "5s", "player" => 0, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [nil, nil, nil, %{"button" => "chii"}]},
      %{"type" => "discard", "tile" => "6m", "player" => 3, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Honitsu", 3}],
        yaku2: [],
        minipoints: 40
      }
    })
  end

  test "space - open kokushi" do
    TestUtils.test_yaku_advanced("space", [], """
    {
      "starting_hand": {
        "east": ["1m", "9m", "1p", "9p", "1s", "9s", "5m", "2z", "3z", "4z", "5m", "6z", "7z"],
        "south": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["2m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["2m", "6m", "7m", "2p", "5p", "8p", "3s", "4s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["5s", "1z", "5z", "1m"]
    }
    """, [
      %{"type" => "discard", "tile" => "5s", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii", "call_choice" => ["2z", "4z"], "called_tile" => "1z"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "5m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "5m", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "1m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Honroutou", 2}, {"Open Kokushi Musou", 3}],
        yaku2: [],
        minipoints: 30
      }
    })
  end

  test "space - chanta" do
    TestUtils.test_yaku_advanced("space", [], """
    {
      "starting_hand": {
        "east": ["9m", "1m", "2m", "8p", "9p", "1p", "1s", "2s", "3s", "7z", "7z", "9s", "9s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "6m", "7m", "2p", "5p", "8p", "3s", "4s", "8s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["5s", "9s"]
    }
    """, [
      %{"type" => "discard", "tile" => "5s", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "9s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Chanta", 2}],
        yaku2: [],
        minipoints: 40
      }
    })
  end

  test "space - junchan" do
    TestUtils.test_yaku_advanced("space", [], """
    {
      "starting_hand": {
        "east": ["9m", "1m", "2m", "8p", "9p", "1p", "1s", "2s", "3s", "9p", "9p", "9s", "9s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "6m", "7m", "2p", "5p", "8p", "3s", "4s", "8s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["5s", "9s"]
    }
    """, [
      %{"type" => "discard", "tile" => "5s", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "9s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Junchan", 3}],
        yaku2: [],
        minipoints: 40
      }
    })
  end

  test "space - ten mod support" do
    TestUtils.test_yaku_advanced("riichi", ["space", "ten"], """
    {
      "starting_hand": {
        "east": ["9m", "1m", "9p", "10p", "1p", "10s", "1s", "2s", "5z", "6z", "7z", "10s", "10s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "6m", "7m", "2p", "5p", "8p", "3s", "4s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["5s", "10m"]
    }
    """, [
      %{"type" => "discard", "tile" => "5s", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "10m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Chanta", 2}],
        yaku2: [],
        minipoints: 40
      }
    })
  end

  test "space - chuuren go spinny" do
    TestUtils.test_yaku_advanced("space", [], """
    {
      "starting_hand": {
        "east": ["4m", "4m", "4m", "5m", "6m", "7m", "8m", "9m", "1m", "2m", "3m", "3m", "3m"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "6m", "7m", "2p", "5p", "8p", "3s", "4s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["5s", "5m"]
    }
    """, [
      %{"type" => "discard", "tile" => "5s", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [],
        yaku2: [{"Junsei Chuurenpoutou", 2}],
        minipoints: 40
      }
    })
  end

end
