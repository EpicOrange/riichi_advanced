defmodule RiichiAdvanced.TutorialTest do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.Constants
  alias RiichiAdvanced.TutorialTestUtils

  # this file is just random uncategorized tests for specific bugs that came up

  test "tutorial sequences" do
    # TutorialTestUtils.test_tutorial_sequence("cosmic", "cosmic_basics", :west)
    # TutorialTestUtils.test_tutorial_sequence("galaxy", "galaxy_basics", :west)
    # TutorialTestUtils.test_tutorial_sequence("galaxy", "galaxy_milky_way", :south)
    # TutorialTestUtils.test_tutorial_sequence("mcr", "mcr_basics", :west)
    # TutorialTestUtils.test_tutorial_sequence("riichi", "riichi_basics", :east)
    # TutorialTestUtils.test_tutorial_sequence("riichi", "riichi_calls", :north)
    # TutorialTestUtils.test_tutorial_sequence("sanma", "sanma_vs_riichi", :south)
    # TutorialTestUtils.test_tutorial_sequence("space", "space_basics", :east)
    # TutorialTestUtils.test_tutorial_sequence("tianjin", "tianjin_basics", :south)

    # for {ruleset, tutorials} <- Constants.tutorials(), {sequence_name, _title, seat} <- tutorials do
    #   IO.inspect({ruleset, sequence_name, seat})
    #   TutorialTestUtils.test_tutorial_sequence(ruleset, sequence_name, seat)
    # end
  end
end
