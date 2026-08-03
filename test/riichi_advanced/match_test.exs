defmodule RiichiAdvanced.MatchTest do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  @ruleset "riichi"
  @mods [
    "lib/yaku/kansai_chiitoitsu",
    %{name: "dora", config: %{start_indicators: 0}},
    %{name: "aka", config: %{man: 1, pin: 1, sou: 1}},
    %{name: "aka9", config: %{man: 1, pin: 1, sou: 1}},
    "jokers/147",
    "yaku/dorahairi_chinroutou_chiitoitsu",
    "shiny_dora",
  ]
  @config """
  
  """
  setup do
    test_state = TestUtils.initialize_test_state(@ruleset, @mods, @config)
    GenServer.cast(test_state.game_state_pid, :sort_hands)
    state = GenServer.call(test_state.game_state_pid, :get_state)
    on_exit(fn -> GenServer.cast(test_state.game_state_pid, :terminate_game) end)
    {:ok, %{state: state}}
  end


  test "subtract works", %{state: state} do
    TestUtils.test_subtract_calculation(state, "3m3m4m4m3p3p2s2s4s4s5s2z2z", "3m3m", "4m4m3p3p2s2s4s4s5s2z2z")
    TestUtils.test_subtract_calculation(state, "3m3m147j4m3p3p2s2s4s4s5s2z2z", "3m3m", "147j4m3p3p2s2s4s4s5s2z2z")
    TestUtils.test_subtract_calculation(state, "1p147j8p09p@dora", "7p8p9p", "1p")
    TestUtils.test_subtract_calculation(state, "2m3m4m5m5m5m2p3p4p8p1z 09p@dora 147j", "7p8p9p", "2m3m4m5m5m5m2p3p4p1z")
  end
  test "remove_match_definition works", %{state: state} do
    TestUtils.test_remove_match_definition(state, "3m3m4m4m3p3p2s2s4s4s5s2z2z", [], [ [["3m"], 2] ], "4m4m3p3p2s2s4s4s5s2z2z")
    TestUtils.test_remove_match_definition(state, "3m3m147j4m3p3p2s2s4s4s5s2z2z", [], [ [["3m"], 2] ], "147j4m3p3p2s2s4s4s5s2z2z")
    TestUtils.test_remove_match_definition(state, "1p147j8p09p", [], [ [[["7p", "8p", "9p"]], 1] ], "1p")
    TestUtils.test_remove_match_definition(state, "1p147j8p09p@dora", [], [ [[["7p", "8p", "9p"]], 1] ], "1p")
    TestUtils.test_remove_match_definition(state, "1p7p8p09p@dora", [], [ [[["7p", "8p", "9p"]], 1] ], "1p")
    TestUtils.test_remove_match_definition(state, "2m3m4m5m5m5m2p3p4p8p1z 09p@dora 147j", [], [ [[["7p", "8p", "9p"]], 1] ], "2m3m4m5m5m5m2p3p4p1z")
  end
  test "waits are calculated correctly", %{state: state} do
    TestUtils.test_wait_calculation(state, "3344m33p22445s22z", [], "05s")
  end
  test "unneeded tiles are calculated correctly", %{state: state} do
    TestUtils.test_unneeded_tile_calculation(state, "3344m33p224455s22z", [], "34m3p245s2z")
  end

end
