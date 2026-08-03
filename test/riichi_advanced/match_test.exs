defmodule RiichiAdvanced.MatchTest do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "waits are calculated correctly" do
    TestUtils.test_wait_calculation("riichi", ["kansai_chiitoitsu", %{name: "aka", config: %{man: 1, pin: 1, sou: 1}}], "3344m33p22445s22z", [], "05s")
  end
end
