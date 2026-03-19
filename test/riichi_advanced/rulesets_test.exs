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
      config = for %{"name" => name, "values" => values} = config_item <- config, into: %{} do
        {name, if Map.has_key?(config_item, "default") do config_item["default"] else Enum.at(values, 0) end}
      end
      %{name: mod_name, config: config}
    end
  end

  def test_ruleset_mods_individually(ruleset) do
    %{game_state_pid: game_state_pid} = TestUtils.initialize_test_state(ruleset, [], "")
    rules_ref = GenServer.call(game_state_pid, :get_state).rules_ref
    Rules.get(rules_ref, "available_mods", %{})
    |> Enum.filter(&is_map/1)
    |> Enum.map(&add_default_mod_config/1)
    |> Task.async_stream(fn mod ->
      try do
        %{game_state_pid: game_state_pid} = TestUtils.initialize_test_state("riichi", [mod], "")
        monitor_ref = Process.monitor(game_state_pid)
        # make sure it's terminated before starting the next one
        # or we get emfile (too many open files) errors
        GenServer.cast(game_state_pid, :terminate_game)
        receive do
          {:DOWN, ^monitor_ref, :process, ^game_state_pid, _} ->
            IO.puts("terminated #{inspect(ruleset)} with mod #{inspect(mod)}")
            :ok
        after
          5000 -> raise "Took more than 5 seconds to spin up ruleset #{inspect(ruleset)} with mod #{inspect(mod)}"
        end
      rescue
        err ->
          Logger.error("Failed to load #{inspect(ruleset)} mod #{inspect(mod)}")
          raise err
      end
    end, max_concurrency: 64, timeout: :infinity)
    |> Stream.run()
  end

  def test_ruleset_default_mods(ruleset) do
    %{game_state_pid: game_state_pid} = TestUtils.initialize_test_state(ruleset, [], "")
    rules_ref = GenServer.call(game_state_pid, :get_state).rules_ref
    monitor_ref = Process.monitor(game_state_pid)
    available_mods = Rules.get(rules_ref, "available_mods", %{})
    |> Enum.filter(&is_map/1)
    mods = Rules.get(rules_ref, "default_mods", %{})
    |> Enum.map(fn
      mod_id when is_binary(mod_id) ->
        ret = Enum.find(available_mods, & &1["id"] == mod_id)
        |> add_default_mod_config()
        if ret == nil do
          Logger.error("Tried to load mod id #{inspect(mod_id)}, which doesn't exist as an available mod in ruleset #{inspect(ruleset)}")
        end
        ret
      %{"name" => id, "config" => config} -> %{name: id, config: config}
    end)
    try do
      TestUtils.initialize_test_state("riichi", mods, "")
    rescue
      err ->
        Logger.error("Failed to apply mods to ruleset #{inspect(ruleset)}: #{inspect(mods)}")
        raise err
    end
    # make sure it's terminated before starting the next one
    # or we get emfile (too many open files) errors
    GenServer.cast(game_state_pid, :terminate_game)
    receive do
      {:DOWN, ^monitor_ref, :process, ^game_state_pid, _} -> :ok
    after
      5000 -> raise "Took more than 5 seconds to spin up ruleset #{ruleset}"
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

  test "load each ruleset with default mods" do
    for {ruleset, _, _} <- Constants.available_rulesets do
      test_ruleset_default_mods(ruleset)
    end
  end

  # # this test runs rly slowly, probably due to file handle contention, so it's disabled
  # test "load each mod individually" do
  #   for {ruleset, _, _} <- Constants.available_rulesets do
  #     test_ruleset_mods_individually(ruleset)
  #   end
  # end

end
