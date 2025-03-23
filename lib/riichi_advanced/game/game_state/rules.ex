defmodule RiichiAdvanced.GameState.Rules do
  alias RiichiAdvanced.GameState.Debug, as: Debug
  alias RiichiAdvanced.ModLoader, as: ModLoader
  alias RiichiAdvanced.Utils, as: Utils
  # import RiichiAdvanced.GameState

  defp decode_rules(ruleset, ruleset_json) do
    # decode the rules json
    try do
      case Jason.decode(ModLoader.strip_comments(ruleset_json)) do
        {:ok, rules} -> {:ok, rules}
        {:error, err} ->
          IO.puts("Erroring json:")
          IO.puts(ruleset_json)
          {:error, "WARNING: Failed to read rules file at character position #{err.position}!\nRemember that trailing commas are invalid!"}
      end
    rescue
      ArgumentError -> {:error, "WARNING: Ruleset \"#{ruleset}\" doesn't exist!"}
    end
  end

  defp check_rules(rules) do
    if get_in(rules["buttons"]["skip"]) != nil do
      {:error, "Error: \"skip\" is an invalid button name."}
    else
      rules = if not Enum.empty?(Debug.debug_am_match_definitions()) do
        Map.put(rules, "show_nearest_american_hand", true)
      else rules end
      {:ok, rules}
    end
  end

  defp replace_constants(rules) do
    # replace all @ constants in rules
    rules = if Map.has_key?(rules, "constants") do
      Utils.walk_json(rules, fn
        value when is_binary(value) ->
          cond do
            String.starts_with?(value, "@") -> Map.get(rules["constants"], String.replace_leading(value, "@", ""), value)
            true -> value
          end
        value -> value
      end)
    else rules end
    {:ok, rules}
  end

  def load_rules(ruleset, ruleset_json) do
    with {:ok, rules} <- decode_rules(ruleset, ruleset_json),
         {:ok, rules} <- replace_constants(rules),
         {:ok, rules} <- check_rules(rules) do
      # store rules in an anonymous ETS table
      # this is cleaned up once the creating process (GameState) dies
      rules_ref = :ets.new(nil, [:set, :public, read_concurrency: true]) 
      :ets.insert(rules_ref, {:ruleset_json, ruleset_json})
      for {k, v} <- rules do
        :ets.insert(rules_ref, {k, v})
      end
      rules_ref
    end
  end

  def get(rules_ref, key, default \\ nil)
  def get(nil, _key, default), do: default
  def get(rules_ref, key, default) do
    case :ets.lookup(rules_ref, key) do
      [{_key, value}] -> value
      [] -> default
    end
  end

  def has_key?(nil, _key), do: false
  def has_key?(rules_ref, key) do
    case :ets.lookup(rules_ref, key) do
      [_] -> true
      [] -> false
    end
  end

end
