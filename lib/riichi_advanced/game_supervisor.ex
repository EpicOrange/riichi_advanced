defmodule RiichiAdvanced.GameSupervisor do
  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      {Mutex, name: RiichiAdvanced.GlobalStateMutex},
      {RiichiAdvanced.AISupervisor, name: RiichiAdvanced.AISupervisor},
      RiichiAdvanced.GlobalState,
      RiichiAdvanced.ExitMonitor,
      RiichiAdvanced.ETSCache,
      %{
        id: PlayTileDebounceEast,
        start: {Debounce, :start_link, [{RiichiAdvanced.GlobalState, :update_state, [&Map.update!(&1, :play_tile_debounce, fn dbs -> Map.put(dbs, :east, false) end)]}, 100, [name: PlayTileDebounceEast]]},
        type: :worker,
        restart: :transient
      },
      %{
        id: PlayTileDebounceSouth,
        start: {Debounce, :start_link, [{RiichiAdvanced.GlobalState, :update_state, [&Map.update!(&1, :play_tile_debounce, fn dbs -> Map.put(dbs, :south, false) end)]}, 100, [name: PlayTileDebounceSouth]]},
        type: :worker,
        restart: :transient
      },
      %{
        id: PlayTileDebounceWest,
        start: {Debounce, :start_link, [{RiichiAdvanced.GlobalState, :update_state, [&Map.update!(&1, :play_tile_debounce, fn dbs -> Map.put(dbs, :west, false) end)]}, 100, [name: PlayTileDebounceWest]]},
        type: :worker,
        restart: :transient
      },
      %{
        id: PlayTileDebounceNorth,
        start: {Debounce, :start_link, [{RiichiAdvanced.GlobalState, :update_state, [&Map.update!(&1, :play_tile_debounce, fn dbs -> Map.put(dbs, :north, false) end)]}, 100, [name: PlayTileDebounceNorth]]},
        type: :worker,
        restart: :transient
      },
      %{
        id: BigTextDebounceEast,
        start: {Debounce, :start_link, [{RiichiAdvanced.GlobalState, :update_player, [:east, &Map.put(&1, :big_text, "")]}, 1500, [name: BigTextDebounceEast]]},
        type: :worker,
        restart: :transient
      },
      %{
        id: BigTextDebounceSouth,
        start: {Debounce, :start_link, [{RiichiAdvanced.GlobalState, :update_player, [:south, &Map.put(&1, :big_text, "")]}, 1500, [name: BigTextDebounceSouth]]},
        type: :worker,
        restart: :transient
      },
      %{
        id: BigTextDebounceWest,
        start: {Debounce, :start_link, [{RiichiAdvanced.GlobalState, :update_player, [:west, &Map.put(&1, :big_text, "")]}, 1500, [name: BigTextDebounceWest]]},
        type: :worker,
        restart: :transient
      },
      %{
        id: BigTextDebounceNorth,
        start: {Debounce, :start_link, [{RiichiAdvanced.GlobalState, :update_player, [:north, &Map.put(&1, :big_text, "")]}, 1500, [name: BigTextDebounceNorth]]},
        type: :worker,
        restart: :transient
      },
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end