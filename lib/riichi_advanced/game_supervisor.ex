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
      debounce_worker(:east, 100, :reset_play_tile_debounce, PlayTileDebounceEast),
      debounce_worker(:south, 100, :reset_play_tile_debounce, PlayTileDebounceSouth),
      debounce_worker(:west, 100, :reset_play_tile_debounce, PlayTileDebounceWest),
      debounce_worker(:north, 100, :reset_play_tile_debounce, PlayTileDebounceNorth),
      debounce_worker(:east, 1500, :reset_big_text, BigTextDebounceEast),
      debounce_worker(:south, 1500, :reset_big_text, BigTextDebounceSouth),
      debounce_worker(:west, 1500, :reset_big_text, BigTextDebounceWest),
      debounce_worker(:north, 1500, :reset_big_text, BigTextDebounceNorth)
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end

  defp debounce_worker(seat, delay, message, name) do
    %{
      id: name,
      start: {Debounce, :start_link, [{GenServer, :cast, [RiichiAdvanced.GameState, {message, seat}]}, delay, [name: name]]},
      type: :worker,
      restart: :transient
    }
  end
end
