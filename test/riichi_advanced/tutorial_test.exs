defmodule RiichiAdvanced.TutorialTest do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.Constants
  alias RiichiAdvanced.TutorialTestUtils

  # this file is just random uncategorized tests for specific bugs that came up

  test "tutorial sequences" do
    TutorialTestUtils.test_tutorial_sequence("sanma", "sanma_vs_riichi", :south)
    # for {ruleset, tutorials} <- Constants.tutorials(), {sequence_name, _title, seat} <- tutorials do
    #   TutorialTestUtils.test_tutorial_sequence(ruleset, sequence_name, seat)
    # end
  end
end
