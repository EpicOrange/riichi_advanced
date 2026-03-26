defmodule RiichiAdvanced.RiichiMechanicsTest do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "riichi - kuikae ari" do
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["2m", "2m", "5z", "5m", "5m", "5z", "6m", "6m", "5z", "5s", "6s", "7s", "8s"],
        "south": ["4m", "4m", "4m", "2p", "2p", "2p", "3s", "3s", "3s", "7z", "7z", "6s", "6s"],
        "west": ["1m", "4m", "7m", "3p", "5p", "8p", "4s", "5s", "8s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "3p", "5p", "8p", "4s", "5s", "8s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["5z", "2m", "5m", "6m", "6z", "6z", "9s"]
    }
    """, [
      %{"type" => "discard", "tile" => "5z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "5z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "5z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "5z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "9s", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "6s", "player" => 0, "tsumogiri" => false},
      %{"type" => "buttons_pressed", "buttons" => [nil, %{"button" => "ron"}, nil, nil]},
    ], %{
      south: %{
        yaku: [{"Sanankou", [2, "Han"]}, {"Toitoi", [2, "Han"]}],
        yaku2: [],
        minipoints: 50
      }
    })
  end

  test "riichi - kuikae nashi" do
    TestUtils.test_yaku_advanced("riichi", ["kuikae_nashi"], """
    {
      "starting_hand": {
        "east": ["2m", "2m", "5z", "5m", "5m", "5z", "6m", "6m", "5z", "5s", "6s", "7s", "8s"],
        "south": ["4m", "4m", "4m", "2p", "2p", "2p", "3s", "3s", "3s", "7z", "7z", "6s", "6s"],
        "west": ["1m", "4m", "7m", "3p", "5p", "8p", "4s", "5s", "8s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "3p", "5p", "8p", "4s", "5s", "8s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["5z", "2m", "5m", "6m", "6z", "6z", "9s"]
    }
    """, [
      %{"type" => "discard", "tile" => "5z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "5z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "5z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "5z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "9s", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii"}, nil, nil, nil]},
      # this is illegal, you know
      %{"type" => "discard", "tile" => "6s", "player" => 0, "tsumogiri" => false}
      # check that south cannot ron 6s, since it never came out
    ], :no_buttons)
  end

  test "riichi - kuikae nashi 2" do
    TestUtils.test_yaku_advanced("riichi", ["kuikae_nashi"], """
    {
      "starting_hand": {
        "east": ["2m", "2m", "5z", "5m", "5m", "5z", "6m", "6m", "5z", "5s", "6s", "7s", "8p"],
        "south": ["4m", "4m", "4m", "2p", "2p", "2p", "3s", "3s", "3s", "7z", "7z", "7s", "7s"],
        "west": ["1m", "4m", "7m", "3p", "5p", "8p", "4s", "5s", "8s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "3p", "5p", "8p", "4s", "5s", "8s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["5z", "2m", "5m", "6m", "6z", "6z", "7s"]
    }
    """, [
      %{"type" => "discard", "tile" => "5z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "5z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "5z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "5z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7s", "player" => 3, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "7s", "player" => 0, "tsumogiri" => false}
      # check that south cannot ron 7s, since it never came out
    ], :no_winners)
  end

  test "riichi - can't kuikae softlock" do
    TestUtils.test_yaku_advanced("riichi", ["kuikae_nashi"], """
    {
      "starting_hand": {
        "east": ["2m", "2m", "5z", "5m", "5m", "5z", "6m", "6m", "5z", "6s", "6s", "7s", "8s"],
        "south": ["4m", "4m", "4m", "2p", "2p", "2p", "3s", "3s", "3s", "1z", "7z", "6s", "6s"],
        "west": ["1m", "4m", "7m", "3p", "5p", "8p", "4s", "5s", "8s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "3p", "5p", "8p", "4s", "5s", "8s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["5z", "2m", "5m", "6m", "6z", "6z", "9s"]
    }
    """, [
      %{"type" => "discard", "tile" => "5z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "2m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "5z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "5z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6m", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "5z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "6z", "player" => 1, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6z", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "9s", "player" => 3, "tsumogiri" => true},
      # can't chii since it would softlock us
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "chii"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "6s", "player" => 0, "tsumogiri" => false}
    ], :no_winners)
  end


  test "chinitsu - fifth tile tenpai" do
    TestUtils.test_yaku_advanced("chinitsu", [%{name: "yaku/riichi", config: %{bet: 1000, drawless: true}}, "no_honors"], """
    {
      "starting_hand": {
        "east": ["1s", "2s", "3s", "4s", "5s", "6s", "4s", "5s", "6s", "9s", "9s", "9s", "9s"],
        "west": ["1s", "2s", "3s", "1s", "2s", "3s", "1s", "2s", "3s", "4s", "7s", "8s", "8s"]
      },
      "starting_draws": ["4s", "5s", "5s", "6s", "6s", "7s", "7s", "7s", "8s", "8s"]
    }
    """, [
      %{"type" => "discard", "tile" => "4s", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6s", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7s", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8s", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8s", "player" => 2, "tsumogiri" => true}
    ], :no_winners, %{delta_scores: [1000, -1000]})
  end

  test "chinitsu - no fifth tile tenpai" do
    TestUtils.test_yaku_advanced("chinitsu", [%{name: "yaku/riichi", config: %{bet: 1000, drawless: true}}, "no_honors", "no_fifth_tile_tenpai"], """
    {
      "starting_hand": {
        "east": ["1s", "2s", "3s", "4s", "5s", "6s", "4s", "5s", "6s", "9s", "9s", "9s", "9s"],
        "west": ["1s", "2s", "3s", "1s", "2s", "3s", "1s", "2s", "3s", "4s", "7s", "8s", "8s"]
      },
      "starting_draws": ["4s", "5s", "5s", "6s", "6s", "7s", "7s", "7s", "8s", "8s"]
    }
    """, [
      %{"type" => "discard", "tile" => "4s", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5s", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6s", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7s", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "7s", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8s", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8s", "player" => 2, "tsumogiri" => true}
    ], :no_winners, %{delta_scores: [1000, -1000]})
  end

  test "riichi - kazoe" do
    TestUtils.test_yaku_advanced("riichi", [%{name: "yaku/riichi", config: %{bet: 1000, drawless: false}}, "yaku/ippatsu", %{name: "min_han", config: %{min: 1}}], """
    {
      "starting_hand": {
        "east": ["2p", "2p", "3p", "3p", "4p", "4p", "5p", "5p", "6p", "6p", "7p", "7p", "8p"],
        "south": ["1m", "2m", "3m", "4m", "5m", "7m", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "2m", "3m", "4m", "5m", "7m", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "2m", "3m", "4m", "5m", "7m", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["3z", "8p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "riichi"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "3z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Double Riichi", [2, "Han"]}, {"Ippatsu", [1, "Han"]}, {"Pinfu", [1, "Han"]}, {"Tanyao", [1, "Han"]}, {"Ryanpeikou", [3, "Han"]}, {"Chinitsu", [6, "Han"]}],
        minipoints: 30,
        score: 48000
      }
    })
  end

  test "riichi - no kazoe" do
    TestUtils.test_yaku_advanced("riichi", [%{name: "yaku/riichi", config: %{bet: 1000, drawless: false}}, "yaku/ippatsu", "no_kazoe_yakuman", %{name: "min_han", config: %{min: 1}}], """
    {
      "starting_hand": {
        "east": ["2p", "2p", "3p", "3p", "4p", "4p", "5p", "5p", "6p", "6p", "7p", "7p", "8p"],
        "south": ["1m", "2m", "3m", "4m", "5m", "7m", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "2m", "3m", "4m", "5m", "7m", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "2m", "3m", "4m", "5m", "7m", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["3z", "8p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "riichi"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "3z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8p", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "ron"}, nil, nil, nil]}
    ], %{
      east: %{
        yaku: [{"Double Riichi", [2, "Han"]}, {"Ippatsu", [1, "Han"]}, {"Pinfu", [1, "Han"]}, {"Tanyao", [1, "Han"]}, {"Ryanpeikou", [3, "Han"]}, {"Chinitsu", [6, "Han"]}],
        minipoints: 30,
        score: 36000
      }
    })
  end

  test "riichi - kazoe with yakuman only" do
    TestUtils.test_yaku_advanced("riichi", [%{name: "yaku/riichi", config: %{bet: 1000, drawless: false}}, "yaku/ippatsu", "no_kazoe_yakuman", %{name: "min_han", config: %{min: "Yakuman"}}], """
    {
      "starting_hand": {
        "east": ["2p", "2p", "3p", "3p", "4p", "4p", "5p", "5p", "6p", "6p", "7p", "7p", "8p"],
        "south": ["1m", "2m", "3m", "4m", "5m", "7m", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "2m", "3m", "4m", "5m", "7m", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "2m", "3m", "4m", "5m", "7m", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["3z", "8p"]
    }
    """, [
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "riichi"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "3z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "8p", "player" => 1, "tsumogiri" => true}
    ], :no_winners)
  end

  test "riichi - noten payments with no tenpai" do
    draws = List.duplicate("5p", 70) |> List.replace_at(1, "4s")
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["4m", "4m", "4m", "6m", "7m", "8m", "1p", "1p", "3z", "4z", "4s", "4s", "1z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": [#{draws |> Enum.map(&"\"" <> &1 <> "\"") |> Enum.intersperse(", ") |> Enum.join()}]
    }
    """, [
      %{"type" => "discard", "tile" => "5p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5p", "player" => 1, "tsumogiri" => false},
    ] ++ Enum.take(Stream.cycle([
      %{"type" => "discard", "tile" => "5p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5p", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5p", "player" => 1, "tsumogiri" => true},
    ]), 67), :no_winners, %{delta_scores: [0, 0, 0, 0]})
  end

  test "riichi - noten payments with 1 tenpai" do
    draws = List.duplicate("5p", 70) |> List.replace_at(1, "4s")
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["4m", "4m", "4m", "6m", "7m", "8m", "1p", "1p", "3z", "3z", "4s", "4s", "1z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": [#{draws |> Enum.map(&"\"" <> &1 <> "\"") |> Enum.intersperse(", ") |> Enum.join()}]
    }
    """, [
      %{"type" => "discard", "tile" => "5p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5p", "player" => 1, "tsumogiri" => false},
    ] ++ Enum.take(Stream.cycle([
      %{"type" => "discard", "tile" => "5p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5p", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5p", "player" => 1, "tsumogiri" => true},
    ]), 67), :no_winners, %{delta_scores: [3000, -1000, -1000, -1000]})
  end

  test "riichi - noten payments with 2 tenpai" do
    draws = List.duplicate("5p", 70) |> List.replace_at(1, "4s")
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["4m", "4m", "4m", "6m", "7m", "8m", "1p", "1p", "3z", "3z", "4s", "4s", "1z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["4m", "4m", "4m", "6m", "7m", "8m", "1p", "1p", "3z", "3z", "4s", "4s", "4s"],
        "north": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": [#{draws |> Enum.map(&"\"" <> &1 <> "\"") |> Enum.intersperse(", ") |> Enum.join()}]
    }
    """, [
      %{"type" => "discard", "tile" => "5p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5p", "player" => 1, "tsumogiri" => false},
    ] ++ Enum.take(Stream.cycle([
      %{"type" => "discard", "tile" => "5p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5p", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5p", "player" => 1, "tsumogiri" => true},
    ]), 67), :no_winners, %{delta_scores: [1500, -1500, 1500, -1500]})
  end

  test "riichi - noten payments with 3 tenpai" do
    draws = List.duplicate("5p", 70) |> List.replace_at(1, "4s")
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["4m", "4m", "4m", "6m", "7m", "8m", "1p", "1p", "3z", "3z", "4s", "4s", "1z"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["4m", "4m", "4m", "6m", "7m", "8m", "1p", "1p", "3z", "3z", "4s", "4s", "4s"],
        "north": ["4m", "4m", "4m", "6m", "7m", "8m", "1p", "1p", "3z", "3z", "4s", "4s", "4s"]
      },
      "starting_draws": [#{draws |> Enum.map(&"\"" <> &1 <> "\"") |> Enum.intersperse(", ") |> Enum.join()}]
    }
    """, [
      %{"type" => "discard", "tile" => "5p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5p", "player" => 1, "tsumogiri" => false},
    ] ++ Enum.take(Stream.cycle([
      %{"type" => "discard", "tile" => "5p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5p", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5p", "player" => 1, "tsumogiri" => true},
    ]), 67), :no_winners, %{delta_scores: [1000, -3000, 1000, 1000]})
  end

  test "riichi - noten payments with 4 tenpai" do
    draws = List.duplicate("5p", 70) |> List.replace_at(1, "4s")
    TestUtils.test_yaku_advanced("riichi", [], """
    {
      "starting_hand": {
        "east": ["4m", "4m", "4m", "6m", "7m", "8m", "1p", "1p", "3z", "3z", "4s", "4s", "1z"],
        "south": ["4m", "4m", "4m", "6m", "7m", "8m", "1p", "1p", "3z", "3z", "4s", "4s", "4s"],
        "west": ["4m", "4m", "4m", "6m", "7m", "8m", "1p", "1p", "3z", "3z", "4s", "4s", "4s"],
        "north": ["4m", "4m", "4m", "6m", "7m", "8m", "1p", "1p", "3z", "3z", "4s", "4s", "4s"]
      },
      "starting_draws": [#{draws |> Enum.map(&"\"" <> &1 <> "\"") |> Enum.intersperse(", ") |> Enum.join()}]
    }
    """, [
      %{"type" => "discard", "tile" => "5p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "4s", "player" => 1, "tsumogiri" => true},
      %{"type" => "buttons_pressed", "buttons" => [%{"button" => "pon"}, nil, nil, nil]},
      %{"type" => "discard", "tile" => "1z", "player" => 0, "tsumogiri" => false},
      %{"type" => "discard", "tile" => "5p", "player" => 1, "tsumogiri" => false},
    ] ++ Enum.take(Stream.cycle([
      %{"type" => "discard", "tile" => "5p", "player" => 2, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5p", "player" => 3, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5p", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "5p", "player" => 1, "tsumogiri" => true},
    ]), 67), :no_winners, %{delta_scores: [0, 0, 0, 0]})
  end

end
