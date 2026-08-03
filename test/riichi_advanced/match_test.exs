defmodule RiichiAdvanced.MatchTest do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  @ruleset "riichi"
  @mods ["kansai_chiitoitsu", %{name: "aka", config: %{man: 1, pin: 1, sou: 1}}]
  setup do
    test_state = TestUtils.initialize_test_state(@ruleset, @mods)
    GenServer.cast(test_state.game_state_pid, :sort_hands)
    state = GenServer.call(test_state.game_state_pid, :get_state)
    on_exit(fn -> GenServer.cast(test_state.game_state_pid, :terminate_game) end)
    {:ok, %{state: state}}
  end


  test "waits are calculated correctly", %{state: state} do
    TestUtils.test_wait_calculation(state, "3344m33p22445s22z", [], "05s")
  end
  test "unneeded tiles are calculated correctly", %{state: state} do
    TestUtils.test_unneeded_tile_calculation(state, "3344m33p224455s22z", [], "34m3p245s2z")
  end

end
