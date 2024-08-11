defmodule RiichiAdvanced.GameSupervisor do
  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      RiichiAdvanced.GlobalState,
      RiichiAdvanced.ExitMonitor,
      %{
        id: DebounceEast,
        start: {Debounce, :start_link, [{RiichiAdvanced.GlobalState, :update_state, [&Map.update!(&1, :play_tile_debounce, fn dbs -> Map.put(dbs, :east, false) end)]}, 100, [name: DebounceEast]]},
        type: :worker,
        restart: :transient
      },
      %{
        id: DebounceSouth,
        start: {Debounce, :start_link, [{RiichiAdvanced.GlobalState, :update_state, [&Map.update!(&1, :play_tile_debounce, fn dbs -> Map.put(dbs, :south, false) end)]}, 100, [name: DebounceSouth]]},
        type: :worker,
        restart: :transient
      },
      %{
        id: DebounceWest,
        start: {Debounce, :start_link, [{RiichiAdvanced.GlobalState, :update_state, [&Map.update!(&1, :play_tile_debounce, fn dbs -> Map.put(dbs, :west, false) end)]}, 100, [name: DebounceWest]]},
        type: :worker,
        restart: :transient
      },
      %{
        id: DebounceNorth,
        start: {Debounce, :start_link, [{RiichiAdvanced.GlobalState, :update_state, [&Map.update!(&1, :play_tile_debounce, fn dbs -> Map.put(dbs, :north, false) end)]}, 100, [name: DebounceNorth]]},
        type: :worker,
        restart: :transient
      },
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end