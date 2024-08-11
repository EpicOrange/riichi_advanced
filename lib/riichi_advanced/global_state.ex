defmodule RiichiAdvanced.GlobalState do
  use Agent

  def start_link(_initial_data) do
    initial_data = %{:turn => :east}

    wall = ["1m", "1m", "1m", "1m",
            "2m", "2m", "2m", "2m",
            "3m", "3m", "3m", "3m",
            "4m", "4m", "4m", "4m",
            "0m", "5m", "5m", "5m",
            "6m", "6m", "6m", "6m",
            "7m", "7m", "7m", "7m",
            "8m", "8m", "8m", "8m",
            "9m", "9m", "9m", "9m",
            "1p", "1p", "1p", "1p",
            "2p", "2p", "2p", "2p",
            "3p", "3p", "3p", "3p",
            "4p", "4p", "4p", "4p",
            "0p", "5p", "5p", "5p",
            "6p", "6p", "6p", "6p",
            "7p", "7p", "7p", "7p",
            "8p", "8p", "8p", "8p",
            "9p", "9p", "9p", "9p",
            "1s", "1s", "1s", "1s",
            "2s", "2s", "2s", "2s",
            "3s", "3s", "3s", "3s",
            "4s", "4s", "4s", "4s",
            "0s", "5s", "5s", "5s",
            "6s", "6s", "6s", "6s",
            "7s", "7s", "7s", "7s",
            "8s", "8s", "8s", "8s",
            "9s", "9s", "9s", "9s",
            "1z", "1z", "1z", "1z",
            "2z", "2z", "2z", "2z",
            "3z", "3z", "3z", "3z",
            "4z", "4z", "4z", "4z",
            "5z", "5z", "5z", "5z",
            "6z", "6z", "6z", "6z",
            "7z", "7z", "7z", "7z"]
    wall = Enum.shuffle(wall)
    hands = %{:east => sort_tiles(Enum.slice(wall, 0..12)),
              :south => sort_tiles(Enum.slice(wall, 13..25)),
              :west => sort_tiles(Enum.slice(wall, 26..38)),
              :north => sort_tiles(Enum.slice(wall, 39..51))}

    draws = %{:east => [Enum.at(wall, 52)], :south => [], :west => [], :north => []}
    wall_index = 53
    ponds = %{:east => [], :south => [], :west => [], :north => []}
    initial_data = Map.put(initial_data, :wall, wall)
    initial_data = Map.put(initial_data, :wall_index, wall_index)
    initial_data = Map.put(initial_data, :hands, hands)
    initial_data = Map.put(initial_data, :draws, draws)
    initial_data = Map.put(initial_data, :ponds, ponds)
    play_tile_debounce = %{:east => false, :south => false, :west => false, :north => false}
    initial_data = Map.put(initial_data, :play_tile_debounce, play_tile_debounce)

    debouncers = %{
      :east => DebounceEast,
      :south => DebounceSouth,
      :west => DebounceWest,
      :north => DebounceNorth
    }
    Agent.start_link(fn -> %{main: initial_data, debouncers: debouncers} end, name: __MODULE__)
  end

  def get_state do
    Agent.get(__MODULE__, & &1.main)
  end

  def update_state(fun) do
    Agent.update(__MODULE__, &Map.update!(&1, :main, fun))
    RiichiAdvancedWeb.Endpoint.broadcast("game:main", "state_updated", %{"state" => get_state()})
  end

  def print_state do
    IO.puts("Global state:")
    IO.inspect(get_state())
  end
  
  def next_turn(seat, iterations \\ 1) do
    next = cond do
      seat == :east -> :south
      seat == :spectator -> :south
      seat == :south -> :west
      seat == :west -> :north
      seat == :north -> :east
    end
    if iterations <= 1 do next else next_turn(next, iterations - 1) end
  end
  
  def get_seat(seat, direction) do
    cond do
      direction == :shimocha -> next_turn(seat)
      direction == :toimen -> next_turn(seat, 2)
      direction == :kamicha -> next_turn(seat, 3)
      direction == :self -> next_turn(seat, 4)
    end
  end

  def get_relative_seat(seat, seat2) do
    cond do
      seat2 == next_turn(seat) -> :shimocha
      seat2 == next_turn(seat, 2) -> :toimen
      seat2 == next_turn(seat, 3) -> :kamicha
      seat2 == next_turn(seat, 4) -> :self
    end
  end
  
  def rotate_4([a,b,c,d], seat) do
    case seat do
      :east  -> [a,b,c,d]
      :south -> [b,c,d,a]
      :west  -> [c,d,a,b]
      :north -> [d,a,b,c]
    end
  end

  def new_player(socket) do
    state = get_state()
    seat = cond do
      state[:east] == nil  -> :east
      state[:south] == nil -> :south
      state[:west] == nil  -> :west
      state[:north] == nil -> :north
      true                 -> :spectator
    end
    update_state(&Map.put(&1, seat, socket.id))
    GenServer.call(RiichiAdvanced.ExitMonitor, {:new_player, socket.root_pid, fn -> delete_player(seat) end})
    IO.puts("Player #{socket.id} joined as #{seat}")
    IO.puts("Figuring out seat: #{seat}")
    get_player(seat)
  end
  
  def get_player(seat) do
    state = get_state()
    [state.turn, state.hands, state.ponds, state.draws] ++ rotate_4([:east, :south, :west, :north], seat)
  end
  
  def delete_player(seat) do
    update_state(&Map.put(&1, seat, nil))
    IO.puts("#{seat} player exited")
  end

  def play_tile(seat, tile, index) do
    state = get_state()
    if state.play_tile_debounce[seat] != true do
      temp_disable_play_tile(seat)
      IO.puts("#{seat} played tile: #{tile} at index #{index}")
      update_state(&Map.update!(&1, :hands, fn hands -> Map.update!(hands, seat, fn hand -> List.delete_at(hand ++ &1.draws[seat], index) end) end))
      update_state(&Map.update!(&1, :ponds, fn ponds -> Map.update!(ponds, seat, fn pond -> pond ++ [tile] end) end))
      update_state(&Map.update!(&1, :draws, fn draws -> Map.put(draws, seat, []) end))
      RiichiAdvancedWeb.Endpoint.broadcast("game:main", "played_tile", %{"seat" => seat, "tile" => tile, "index" => index})
      change_turn(next_turn(get_state().turn))
    end
  end

  def temp_disable_play_tile(seat) do
    update_state(&Map.update!(&1, :play_tile_debounce, fn dbs -> Map.put(dbs, seat, true) end))
    Debounce.apply(Agent.get(__MODULE__, & &1.debouncers[seat]))
  end

  def reindex_hand(seat, from, to) do
    temp_disable_play_tile(seat)
    IO.puts("#{seat} moved tile from #{from} to #{to}")
    # TODO disallow moving the draw tiles over
    update_state(&Map.update!(&1, :hands, fn hands -> Map.update!(hands, seat, fn hand ->
      {l1, [tile | r1]} = Enum.split(hand, from)
      {l2, r2} = Enum.split(l1 ++ r1, to)
      l2 ++ [tile] ++ r2
    end) end))
  end

  def change_turn(seat) do
    update_state(&Map.put(&1, :turn, seat))
    update_state(&Map.update!(&1, :draws, fn draws -> Map.put(draws, &1.turn, [Enum.at(&1.wall, &1.wall_index)]) end))
    IO.puts("#{seat} drew: #{get_state().draws[seat]}")
    update_state(&Map.update!(&1, :wall_index, fn ix -> ix + 1 end))
    IO.puts("wall index is now #{get_state().wall_index}")
  end

  def sort_tiles(tiles) do
    Enum.sort_by(tiles, &case &1 do
      "1m" -> 0; "2m" -> 1; "3m" -> 2; "4m" -> 3; "0m" -> 4; "5m" -> 5; "6m" -> 6; "7m" -> 7; "8m" -> 8; "9m" -> 9;
      "1p" -> 10; "2p" -> 11; "3p" -> 12; "4p" -> 13; "0p" -> 14; "5p" -> 15; "6p" -> 16; "7p" -> 17; "8p" -> 18; "9p" -> 19;
      "1s" -> 20; "2s" -> 21; "3s" -> 22; "4s" -> 23; "0s" -> 24; "5s" -> 25; "6s" -> 26; "7s" -> 27; "8s" -> 28; "9s" -> 29;
      "1z" -> 30; "2z" -> 31; "3z" -> 32; "4z" -> 33; "5z" -> 34; "6z" -> 35; "7z" -> 36;
      "1x" -> 37;
    end)
  end
end
