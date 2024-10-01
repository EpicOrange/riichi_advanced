defmodule RiichiAdvanced.ETSCache do
  use GenServer

  @max_size 1000

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    :ets.new(:cache, [:named_table, :set, :public, read_concurrency: true, write_concurrency: true])
    :ets.new(:cache_mods, [:named_table, :set, :public, read_concurrency: true, write_concurrency: true])
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
      remove_random_entry(table)
    end
    :ets.insert(table, {key, value})
  end

  defp remove_random_entry(table) do
    :ets.delete(table, :ets.first(table))
  end
end
