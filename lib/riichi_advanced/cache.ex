defmodule RiichiAdvanced.ETSCache do
  use GenServer

  @table :cache

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    :ets.new(@table, [:named_table, :set, :public, read_concurrency: true, write_concurrency: true])
    {:ok, %{}}
  end

  def get(key), do: :ets.lookup(@table, key) |> Enum.map(&elem(&1, 1))
  def put(key, value), do: :ets.insert(@table, {key, value})
end
