defmodule RiichiAdvanced.GameSupervisor do
  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      {Mutex, name: RiichiAdvanced.GlobalStateMutex},
      {RiichiAdvanced.AISupervisor, name: RiichiAdvanced.AISupervisor},
      RiichiAdvanced.GameState,
      RiichiAdvanced.ExitMonitor,
      RiichiAdvanced.ETSCache,
      %{
        id: PlayTileDebounceEast,
        start: {Debounce, :start_link, [{GenServer, :cast, [RiichiAdvanced.GameState, {:reset_play_tile_debounce, :east}]}, 100, [name: PlayTileDebounceEast]]},
        type: :worker,
        restart: :transient
      },
      %{
        id: PlayTileDebounceSouth,
        start: {Debounce, :start_link, [{GenServer, :cast, [RiichiAdvanced.GameState, {:reset_play_tile_debounce, :south}]}, 100, [name: PlayTileDebounceSouth]]},
        type: :worker,
        restart: :transient
      },
      %{
        id: PlayTileDebounceWest,
        start: {Debounce, :start_link, [{GenServer, :cast, [RiichiAdvanced.GameState, {:reset_play_tile_debounce, :west}]}, 100, [name: PlayTileDebounceWest]]},
        type: :worker,
        restart: :transient
      },
      %{
        id: PlayTileDebounceNorth,
        start: {Debounce, :start_link, [{GenServer, :cast, [RiichiAdvanced.GameState, {:reset_play_tile_debounce, :north}]}, 100, [name: PlayTileDebounceNorth]]},
        type: :worker,
        restart: :transient
      },
      %{
        id: BigTextDebounceEast,
        start: {Debounce, :start_link, [{GenServer, :cast, [RiichiAdvanced.GameState, {:reset_play_tile_debounce, :east}]}, 1500, [name: BigTextDebounceEast]]},
        type: :worker,
        restart: :transient
      },
      %{
        id: BigTextDebounceSouth,
        start: {Debounce, :start_link, [{GenServer, :cast, [RiichiAdvanced.GameState, {:reset_big_text, :south}]}, 1500, [name: BigTextDebounceSouth]]},
        type: :worker,
        restart: :transient
      },
      %{
        id: BigTextDebounceWest,
        start: {Debounce, :start_link, [{GenServer, :cast, [RiichiAdvanced.GameState, {:reset_big_text, :west}]}, 1500, [name: BigTextDebounceWest]]},
        type: :worker,
        restart: :transient
      },
      %{
        id: BigTextDebounceNorth,
        start: {Debounce, :start_link, [{GenServer, :cast, [RiichiAdvanced.GameState, {:reset_big_text, :north}]}, 1500, [name: BigTextDebounceNorth]]},
        type: :worker,
        restart: :transient
      },
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end