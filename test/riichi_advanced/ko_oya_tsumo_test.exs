defmodule RiichiAdvanced.KoOyaTsumoTest do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.GameState, as: GameState
  alias RiichiAdvanced.GameState.Scoring, as: Scoring
  alias RiichiAdvanced.Riichi, as: Riichi
  alias RiichiAdvanced.TestUtils, as: TestUtils

  @default_riichi_mods [
    %{name: "honba", config: %{"value" => 100}},
    %{name: "yaku/riichi", config: %{"bet" => 1000, "drawless" => false}},
    %{name: "nagashi", config: %{"is" => "Mangan"}},
    %{name: "tobi", config: %{"below" => 0}},
    %{
     name: "uma",
     config: %{"_1st" => 10, "_2nd" => 5, "_3rd" => -5, "_4th" => -10}
    },
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
    %{name: "dora", config: %{"start_indicators" => 1}},
    "ura",
    "kandora",
    "yaku/ippatsu",
    %{name: "yaku/riichi_renhou", config: %{"is" => "Yakuman"}},
    "show_waits",
    %{name: "min_han", config: %{"min" => 1}},
    %{name: "aka", config: %{"man" => 1, "pin" => 1, "sou" => 1}}
  ]

  def test_ko_oya_3p(score, expected) do
    assert expected == Riichi.calc_ko_oya_points(score, false, 3, 100)
  end

  def test_ko_oya_4p(score, expected) do
    assert expected == Riichi.calc_ko_oya_points(score, false, 4, 100)
  end

  test "ko oya 4p" do
    test_ko_oya_4p(1300, {400, 700}) # 2/20, 1/40
    test_ko_oya_4p(2600, {700, 1300}) # 3/20, 2/40
    test_ko_oya_4p(5200, {1300, 2600}) # 4/20, 3/40

    test_ko_oya_4p(1600, {400, 800}) # 1/50
    test_ko_oya_4p(3200, {800, 1600}) # 3/25, 2/50
    test_ko_oya_4p(6400, {1600, 3200}) # 4/25, 3/50

    test_ko_oya_4p(1000, {300, 500}) # 1/30
    test_ko_oya_4p(2000, {500, 1000}) # 2/30, 1/60
    test_ko_oya_4p(3900, {1000, 2000}) # 3/30, 2/60
    test_ko_oya_4p(7700, {2000, 3900}) # 4/30, 3/60

    test_ko_oya_4p(8000, {2000, 4000}) # mangan
    test_ko_oya_4p(12000, {3000, 6000}) # haneman
    test_ko_oya_4p(16000, {4000, 8000}) # baiman
    test_ko_oya_4p(24000, {6000, 12000}) # sanbaiman
    test_ko_oya_4p(32000, {8000, 16000}) # yakuman
  end

  test "ko oya 3p with tsumo loss" do
    test_ko_oya_3p(1100, {400, 700}) # 2/20, 1/40
    test_ko_oya_3p(2000, {700, 1300}) # 3/20, 2/40
    test_ko_oya_3p(3900, {1300, 2600}) # 4/20, 3/40

    test_ko_oya_3p(1200, {400, 800}) # 1/50
    test_ko_oya_3p(2400, {800, 1600}) # 3/25, 2/50
    test_ko_oya_3p(4800, {1600, 3200}) # 4/25, 3/50

    test_ko_oya_3p(800, {300, 500}) # 1/30
    test_ko_oya_3p(1500, {500, 1000}) # 2/30, 1/60
    test_ko_oya_3p(3000, {1000, 2000}) # 3/30, 2/60
    test_ko_oya_3p(5900, {2000, 3900}) # 4/30, 3/60

    test_ko_oya_3p(6000, {2000, 4000}) # mangan
    test_ko_oya_3p(9000, {3000, 6000}) # haneman
    test_ko_oya_3p(12000, {4000, 8000}) # baiman
    test_ko_oya_3p(18000, {6000, 12000}) # sanbaiman
    test_ko_oya_3p(24000, {8000, 16000}) # yakuman
  end

  test "ko oya 3p unequal_split" do
    test_ko_oya_3p(1300, {500, 900}) # 2/20, 1/40
    test_ko_oya_3p(2600, {900, 1700}) # 3/20, 2/40
    test_ko_oya_3p(5200, {1800, 3500}) # 4/20, 3/40

    test_ko_oya_3p(1600, {600, 1100}) # 1/50
    test_ko_oya_3p(3200, {1100, 2100}) # 3/25, 2/50
    test_ko_oya_3p(6400, {2200, 4300}) # 4/25, 3/50

    test_ko_oya_3p(1000, {400, 700}) # 1/30
    test_ko_oya_3p(2000, {700, 1300}) # 2/30, 1/60
    test_ko_oya_3p(3900, {1300, 2600}) # 3/30, 2/60
    test_ko_oya_3p(7700, {2600, 5100}) # 4/30, 3/60

    test_ko_oya_3p(8000, {2700, 5300}) # mangan
    test_ko_oya_3p(12000, {4000, 8000}) # haneman
    test_ko_oya_3p(16000, {5400, 10700}) # baiman
    test_ko_oya_3p(24000, {8000, 16000}) # sanbaiman
    test_ko_oya_3p(32000, {10700, 21300}) # yakuman
  end

  def tsumo_loss_yakuman_test(tsumo_loss, seat, expected_score, expected_delta_scores) do
    mods = @default_riichi_mods
    test_state = TestUtils.initialize_test_state("kansai", mods, "{\"score_calculation\": {\"tsumo_loss\": #{inspect(tsumo_loss)}}}")
    state = GenServer.call(test_state.game_state_pid, :get_state)
    hand = [:"2m", :"3m", :"4m", :"4m", :"5m", :"6m", :"7p", :"7p", :"7p", :"8s", :"8s", :"8s", :"6p"]
    draw = [:"6p"]
    calls = []
    state = put_in(state.turn, seat)
    state = put_in(state.players[seat].hand, hand)
    state = put_in(state.players[seat].draw, draw)
    state = put_in(state.players[seat].calls, calls)
    state = update_in(state.players[seat].status, &MapSet.put(&1, "discards_empty")) # trigger tenhou
    state = GameState.win(state, seat, :draw)
    {_state, delta_scores, _delta_scores_reason, _next_dealer} = Scoring.adjudicate_win_scoring(state)
    score = state.winners[seat].score
    assert score == expected_score
    assert delta_scores == expected_delta_scores
  end

  # tsumo loss values
  # https://ja.wikipedia.org/wiki/%E4%B8%89%E4%BA%BA%E9%BA%BB%E9%9B%80#%E6%AF%94%E8%BC%83%E8%A1%A8
  test "tsumo_loss == true" do
    tsumo_loss_yakuman_test(true, :east, 32000, %{east: 32000, south: -16000, west: -16000})
    tsumo_loss_yakuman_test(true, :south, 24000, %{east: -16000, south: 24000, west: -8000})
  end
  test "tsumo_loss == add_1000" do
    tsumo_loss_yakuman_test("add_1000", :east, 50000, %{east: 34000, south: -17000, west: -17000})
    tsumo_loss_yakuman_test("add_1000", :south, 34000, %{east: -17000, south: 26000, west: -9000})
  end
  test "tsumo_loss == unequal_split" do
    tsumo_loss_yakuman_test("unequal_split", :east, 48000, %{east: 48000, south: -24000, west: -24000})
    tsumo_loss_yakuman_test("unequal_split", :south, 32000, %{east: -21300, south: 32000, west: -10700})
  end
  test "tsumo_loss == false" do # same as north_split
    tsumo_loss_yakuman_test(false, :east, 48000, %{east: 48000, south: -24000, west: -24000})
    tsumo_loss_yakuman_test(false, :south, 32000, %{east: -20000, south: 32000, west: -12000})
  end
  test "tsumo_loss == north_split" do
    tsumo_loss_yakuman_test("north_split", :east, 48000, %{east: 48000, south: -24000, west: -24000})
    tsumo_loss_yakuman_test("north_split", :south, 32000, %{east: -20000, south: 32000, west: -12000})
  end
  test "tsumo_loss == equal_split" do
    tsumo_loss_yakuman_test("equal_split", :east, 48000, %{east: 48000, south: -24000, west: -24000})
    tsumo_loss_yakuman_test("equal_split", :south, 32000, %{east: -16000, south: 32000, west: -16000})
  end
  test "tsumo_loss == north_to_oya" do
    tsumo_loss_yakuman_test("north_to_oya", :east, 48000, %{east: 48000, south: -24000, west: -24000})
    tsumo_loss_yakuman_test("north_to_oya", :south, 32000, %{east: -24000, south: 32000, west: -8000})
  end
  test "tsumo_loss == double_collection" do
    tsumo_loss_yakuman_test("double_collection", :east, 96000, %{east: 96000, south: -48000, west: -48000})
    tsumo_loss_yakuman_test("double_collection", :south, 64000, %{east: -32000, south: 64000, west: -32000})
  end
  test "tsumo_loss == ron_loss" do
    tsumo_loss_yakuman_test("ron_loss", :east, 32000, %{east: 32000, south: -16000, west: -16000})
    tsumo_loss_yakuman_test("ron_loss", :south, 24000, %{east: -16000, south: 24000, west: -8000})
  end

end
