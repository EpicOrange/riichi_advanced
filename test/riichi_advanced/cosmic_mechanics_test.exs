defmodule RiichiAdvanced.CosmicMechanics do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  @cosmic_mods [
    %{name: "honba", config: %{value: 100}},
    %{name: "nagashi", config: %{is: "Mangan"}},
    %{name: "tobi", config: %{below: 0}},
    %{name: "yaku/riichi", config: %{bet: 1000, drawless: false}},
    %{name: "uma", config: %{_1st: 10, _2nd: 5, _3rd: -5, _4th: -10}},
    "agarirenchan",
    "tenpairenchan",
    "kuikae_nashi",
    "double_wind_4_fu",
    "pao",
    "kokushi_ankan_chankan",
    "suufon_renda",
    "suucha_riichi",
    "suukaikan",
    "kyuushu_kyuuhai",
    # %{name: "dora", config: %{start_indicators: 1}},
    # "ura",
    # "kandora",
    "yaku/tsubame_gaeshi",
    "yaku/kanburi",
    "yaku/uumensai",
    "yaku/isshoku_sanjun",
    %{name: "yaku/riichi_renhou", config: %{is: "Yakuman"}},
    "yaku/isshoku_yonjun",
    "show_waits",
    %{name: "min_han", config: %{min: 1}},
    # "cancellable_riichi",
    "cosmic_calls",
    "yaku/ippatsu",
    "space",
    # %{name: "aka", config: %{man: 1, pin: 1, sou: 1}},
    "cosmic",
    "yaku/kontsu_yaku",
    "yaku/chanfuun",
    "yaku/fuunburi",
    "yaku/uumensai_cosmic",
    "kontsu",
    "yakuman_13_han"
  ]

  test "cosmic - sequences wrap" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
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

  test "cosmic - mini-sangen is not enough han" do
    TestUtils.test_yaku_advanced("cosmic", @cosmic_mods, """
    {
      "starting_hand": {
        "east": ["9m", "1m", "2m", "8p", "9p", "1p", "1s", "2s", "3s", "5z", "6z", "7z", "6p"],
        "south": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "west": ["1m", "4m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"],
        "north": ["1m", "3m", "7m", "2p", "5p", "8p", "3s", "6s", "9s", "1z", "2z", "3z", "4z"]
      },
      "starting_draws": ["6z", "6p"]
    }
    """, [
      %{"type" => "discard", "tile" => "6z", "player" => 0, "tsumogiri" => true},
      %{"type" => "discard", "tile" => "6p", "player" => 1, "tsumogiri" => true}
    ], :no_winners)
  end

end
