defmodule RiichiAdvanced.YakuTest.Bloody30FaanYaku do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  @closed {"Concealed Hand", [1, "Faan"]}
  @seven {"Within Seven Tiles", [8, "Faan"]}
  @ten {"Within Ten Tiles", [5, "Faan"]}
  @no_honors {"No Honors or Flowers", [2, "Faan"]}

  test "b30fj - flower" do
    TestUtils.test_yaku_advanced("bloody30faan", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "5m", "6m", "7m", "16j", "7p", "8p", "4s", "4s", "4s", "1z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["18j", "3m"],
      "starting_dead_wall": ["2m"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "joker", "call_choice" => ["18j"]}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "2m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1z", "player" => 1, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Flower", [1, "Faan"]}, @closed, @seven]
      }
    })
  end

  test "b30fj - no honors or flowers" do
    TestUtils.test_yaku_advanced("bloody30faan", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "5m", "6m", "7m", "6j", "7p", "8p", "4s", "4s", "4s", "17j"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2m", "9s"]
    }
    """, [
      %{"type" => "discard", "tile" => "2m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "9s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"No Honors or Flowers", [2, "Faan"]}, @closed, @seven]
      }
    })
  end

  test "b30fj - no jokers" do
    TestUtils.test_yaku_advanced("bloody30faan", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "5m", "6m", "7m", "6p", "7p", "8p", "4s", "4s", "4s", "9s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2m", "9s"]
    }
    """, [
      %{"type" => "discard", "tile" => "2m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "9s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"No Jokers", [2, "Faan"]}, @closed, @seven, @no_honors]
      }
    })
  end

  test "b30fj - terminal sequences" do
    TestUtils.test_yaku_advanced("bloody30faan", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "5m", "6m", "7m", "8m", "9m", "3p", "3p", "5s", "5s", "6j"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "6m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2m", "7m"]
    }
    """, [
      %{"type" => "discard", "tile" => "2m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Terminal Sequences", [1, "Faan"]}, @closed, @seven, @no_honors]
      }
    })
  end

  test "b30fj - double terminal sequences" do
    TestUtils.test_yaku_advanced("bloody30faan", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "7m", "8m", "9m", "1p", "2p", "7p", "9p", "5s", "5s", "6j"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "6m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2m", "3p"]
    }
    """, [
      %{"type" => "discard", "tile" => "2m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"All Sequences", [2, "Faan"]}, {"Double Sequences", [2, "Faan"]}, {"Double Terminal Sequences", [10, "Faan"]}, @closed, @seven, @no_honors]
      }
    })
  end

  test "b30fj - pure double terminal sequences" do
    TestUtils.test_yaku_advanced("bloody30faan", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "1m", "2m", "7m", "8m", "9m", "7m", "9m", "6p", "6p", "18j"],
        "south": ["2m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "6m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2m", "3m"]
    }
    """, [
      %{"type" => "discard", "tile" => "2m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [
          {"All Sequences", [2, "Faan"]},
          {"One Voided Suit", [2, "Faan"]},
          {"Seven Pairs", [5, "Faan"]},
          {"Three Consecutive Pairs", [2, "Faan"]},
          {"Pure Double Terminal Sequences", [20, "Faan"]},
          @closed, @seven, @no_honors
        ]
      }
    })
  end

  test "b30fj - one voided suit" do
    TestUtils.test_yaku_advanced("bloody30faan", [], """
    {
      "starting_hand": {
        "east": ["1m", "2m", "3m", "5m", "6m", "3p", "3p", "5p", "5p", "6j", "7p", "8p", "9p"],
        "south": ["1m", "4m", "7m", "2p", "4p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2m", "7m"]
    }
    """, [
      %{"type" => "discard", "tile" => "2m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"One Voided Suit", [2, "Faan"]}, @closed, @seven, @no_honors]
      }
    })
  end

  test "b30fj - open nine gates" do
    TestUtils.test_yaku_advanced("bloody30faan", [], """
    {
      "starting_hand": {
        "east": ["1m", "1m", "1z", "2m", "2m", "4m", "5m", "6m", "7m", "18j", "9m", "9m", "9m"],
        "south": ["1p", "2p", "4p", "7p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1p", "2p", "4p", "7p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1p", "2p", "3p", "7p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2m", "1m", "3m"]
    }
    """, [
      %{"type" => "discard", "tile" => "2m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "1m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon", "call_choice" => ["1m", "1m"]}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "3m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Open Nine Gates", [20, "Faan"]}, {"Full Flush", [10, "Faan"]}, {"Short Straight", [1, "Faan"]}, @seven, @no_honors]
      }
    })
  end

  test "b30fj - daiminkan is open kong" do
    TestUtils.test_yaku_advanced("bloody30faan", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "6m", "3p", "4p", "4p", "5p", "6j", "7s", "8s", "9s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2m", "3m", "4m"],
      "starting_dead_wall": ["1z"]
    }
    """, [
      %{"type" => "discard", "tile" => "2m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "daiminkan", "call_choice" => ["3m", "3m", "3m"]}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Open Kong", [1, "Faan"]}, @seven, @no_honors]
      }
    })
  end

  test "b30fj - kakan is open kong" do
    TestUtils.test_yaku_advanced("bloody30faan", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "1z", "5m", "6m", "3p", "4p", "4p", "5p", "6j", "7s", "8s", "9s"],
        "south": ["1m", "2m", "7m", "2p", "5p", "8p", "3s", "6s", "8s", "9s", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2m", "3m", "4m", "5m", "6m", "3m", "4m"],
      "starting_dead_wall": ["1z"]
    }
    """, [
      %{"type" => "discard", "tile" => "2m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "3m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon", "call_choice" => ["3m", "3m"]}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "4m", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5m", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6m", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "kakan"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Open Kong", [1, "Faan"]}, @ten, @no_honors]
      }
    })
  end

  test "b30fj - ankan is closed kong" do
    TestUtils.test_yaku_advanced("bloody30faan", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "5m", "6m", "3p", "4p", "4p", "5p", "6j", "7s", "8s", "9s"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["3m", "4m"],
      "starting_dead_wall": ["1z"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ankan", "call_choice" => ["3m", "3m", "3m"]}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Concealed Kong", [2, "Faan"]}, @closed, @seven, @no_honors]
      }
    })
  end

  test "b30fj - two shifted triplets" do
    TestUtils.test_yaku_advanced("bloody30faan", [], """
    {
      "starting_hand": {
        "east": ["3m", "3m", "3m", "4m", "4m", "3p", "4p", "4p", "5p", "6j", "7s", "8s", "9s"],
        "south": ["1m", "2m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "2m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["1z", "4m"]
    }
    """, [
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Two Shifted Triplets", [2, "Faan"]}, @closed, @seven, @no_honors]
      }
    })
  end

  # TODO more tests

  test "b30fj - knitted straight" do
    TestUtils.test_yaku_advanced("bloody30faan", [], """
    {
      "starting_hand": {
        "east": ["1m", "4m", "18j", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "7z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["2m", "7z"]
    }
    """, [
      %{"type" => "discard", "tile" => "2m", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7z", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [@closed, {"Knitted Straight", [5, "Faan"]}, {"Thirteen Unconnected", [5, "Faan"]}, {"Within Seven Tiles", [8, "Faan"]}],
      }
    })
  end

end
