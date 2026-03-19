defmodule RiichiAdvanced.RulesetsTest do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.Constants, as: Constants
  alias RiichiAdvanced.GameState.Rules, as: Rules
  alias RiichiAdvanced.TestUtils, as: TestUtils
  require Logger

  def add_default_mod_config(mod) do
    mod_name = mod["id"]
    config = mod["config"]
    if config == nil do
      mod_name
    else
      config = for %{"name" => name, "values" => [value | _]} <- config do
        {name, value}
      end
      %{name: mod_name, config: config}
    end
  end

  def test_ruleset_mods(ruleset) do
    %{game_state_pid: game_state_pid} = TestUtils.initialize_test_state(ruleset, [], "")
    rules_ref = GenServer.call(game_state_pid, :get_state).rules_ref
    mods = Rules.get(rules_ref, "available_mods", %{})
    |> Enum.filter(&is_map/1)
    |> Enum.map(&add_default_mod_config/1)
    for mod <- mods do
      try do
        TestUtils.initialize_test_state("riichi", [mod], "")
      rescue
        err ->
          Logger.error("Failed to load #{ruleset} mod #{inspect(mod)}")
          raise err
      end
    end
  end

  test "load each ruleset" do
    for {ruleset, _, _} <- Constants.available_rulesets do
      try do
        TestUtils.initialize_test_state(ruleset, [], "")
      rescue
        err ->
          Logger.error("Failed to load #{ruleset}")
          raise err
      end
    end
  end

  # test "load each mod" do
  #   for {ruleset, _, _} <- Constants.available_rulesets do
  #     test_ruleset_mods(ruleset)
  #   end
  # end

end
