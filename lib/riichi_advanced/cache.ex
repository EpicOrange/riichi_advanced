defmodule RiichiAdvanced.ETSCache do
  use GenServer

  @table :cache
  @max_size 10000

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    :ets.new(@table, [:named_table, :set, :public, read_concurrency: true, write_concurrency: true])
    {:ok, %{}}
  end

  def get(key) do
    :ets.lookup(@table, key) |> Enum.map(&elem(&1, 1))
  end

  def put(key, value) do
    current_size = :ets.info(@table, :size)
    if current_size >= @max_size do
      remove_random_entry()
    end
    :ets.insert(@table, {key, value})
  end

  defp remove_random_entry do
    :ets.delete(@table, :ets.first(@table))
  end
end
