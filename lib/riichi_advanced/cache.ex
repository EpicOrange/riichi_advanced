defmodule RiichiAdvanced.ETSCache do
  use GenServer

  @max_size 4000

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    # Cache for function calls
    :ets.new(:cache, [:named_table, :ordered_set, :public, read_concurrency: true, write_concurrency: true])
    
    # Cache for mods
    :ets.new(:cache_mods, [:named_table, :ordered_set, :public, read_concurrency: true, write_concurrency: true])

    # Cache for custom rulesets
    :ets.new(:cache_rulesets, [:named_table, :ordered_set, :public, read_concurrency: true, write_concurrency: true])

    # Cache for configs
    :ets.new(:cache_configs, [:named_table, :ordered_set, :public, read_concurrency: true, write_concurrency: true])

    # Cache for tutorial sequences
    :ets.new(:cache_sequences, [:named_table, :ordered_set, :public, read_concurrency: true, write_concurrency: true])

    {:ok, %{}}
  end

  def get(key, default \\ [], table \\ :cache) do
    case :ets.lookup(table, key) do
      [{_key, result}] -> [result]
      _                -> default
    end
  end

  def put(key, value, table \\ :cache) do
    if :ets.info(table, :size) >= @max_size do
      remove_last_entry(table)
    end
    :ets.insert(table, {key, value})
  end

  defp remove_last_entry(table) do
    :ets.delete(table, :ets.last(table))
  end
end
