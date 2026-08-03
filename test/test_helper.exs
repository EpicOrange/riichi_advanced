# start a long-lived genserver to hold ruleset ets tables generated in TestUtils
defmodule RiichiAdvanced.TestStaticEtsOwner do
  use GenServer
  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)
  def init(_), do: {:ok, %{}}
  def handle_info({:"ETS-TRANSFER", _table, _from_pid, _extra}, state) do
    {:noreply, state}
  end
end
{:ok, _pid} = RiichiAdvanced.TestStaticEtsOwner.start_link([])

ExUnit.start(timeout: :infinity)
