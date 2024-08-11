defmodule RiichiAdvanced.GlobalState do
  use Agent

  def start_link(_initial_data) do
    initial_data = %{initialized: false}
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

  def initialize_game do
    rules = Jason.decode!(File.read!(Application.app_dir(:riichi_advanced, "priv/static/uno.json")))
    update_state(&Map.put(&1, :rules, rules))

    wall = rules["wall"]
    wall = Enum.shuffle(wall)
    hands = %{:east => sort_tiles(Enum.slice(wall, 0..12)),
              :south => sort_tiles(Enum.slice(wall, 13..25)),
              :west => sort_tiles(Enum.slice(wall, 26..38)),
              :north => sort_tiles(Enum.slice(wall, 39..51))}
    draws = %{:east => [], :south => [], :west => [], :north => []}
    ponds = %{:east => [], :south => [], :west => [], :north => []}
    wall_index = 52
    update_state(&Map.put(&1, :wall, wall))
    update_state(&Map.put(&1, :hands, hands))
    update_state(&Map.put(&1, :draws, draws))
    update_state(&Map.put(&1, :ponds, ponds))
    update_state(&Map.put(&1, :wall_index, wall_index))
    update_state(&Map.put(&1, :last_discard, nil))
    update_state(&Map.put(&1, :reversed_turn_order, false))

    change_turn(:east)

    update_state(&Map.put(&1, :initialized, true))
  end

  def get_state do
    Agent.get(__MODULE__, & &1.main)
  end

  def update_state(fun) do
    Agent.update(__MODULE__, &Map.update!(&1, :main, fun))
    if get_state().initialized == true do
      RiichiAdvancedWeb.Endpoint.broadcast("game:main", "state_updated", %{"state" => get_state()})
    end
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
    if seat == :east do
      initialize_game()
    end
    update_state(&Map.put(&1, seat, socket.id))
    GenServer.call(RiichiAdvanced.ExitMonitor, {:new_player, socket.root_pid, fn -> delete_player(seat) end})
    IO.puts("Player #{socket.id} joined as #{seat}")
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

  def is_playable(tile) do
    state = get_state()
    Enum.all?(state.rules["play_restrictions"], fn [tile_spec, rule, opts] -> 
      tile != tile_spec || case rule do
        "disable_unless_any" -> Enum.any?(opts, fn [restriction_spec, restriction_opts] ->
            case restriction_spec do
              "last_tile" -> state.last_discard == nil || case restriction_opts do
                  "manzu" -> String.ends_with?(state.last_discard, "m")
                  "pinzu" -> String.ends_with?(state.last_discard, "p")
                  "souzu" -> String.ends_with?(state.last_discard, "s")
                  "jihai" -> String.ends_with?(state.last_discard, "z")
                  "0" -> String.starts_with?(state.last_discard, "0")
                  "1" -> String.starts_with?(state.last_discard, "1")
                  "2" -> String.starts_with?(state.last_discard, "2")
                  "3" -> String.starts_with?(state.last_discard, "3")
                  "4" -> String.starts_with?(state.last_discard, "4")
                  "5" -> String.starts_with?(state.last_discard, "5")
                  "6" -> String.starts_with?(state.last_discard, "6")
                  "7" -> String.starts_with?(state.last_discard, "7")
                  "8" -> String.starts_with?(state.last_discard, "8")
                  "9" -> String.starts_with?(state.last_discard, "9")
                end
              _ -> true
            end
          end)
        _ -> true
      end
    end)
  end

  def play_tile(seat, tile, index) do
    state = get_state()
    if state.play_tile_debounce[seat] != true do
      temp_disable_play_tile(seat)
      IO.puts("#{seat} played tile: #{tile} at index #{index}")
      update_state(&Map.update!(&1, :hands, fn hands -> Map.update!(hands, seat, fn hand -> List.delete_at(hand ++ &1.draws[seat], index) end) end))
      update_state(&Map.update!(&1, :ponds, fn ponds -> Map.update!(ponds, seat, fn pond -> pond ++ [tile] end) end))
      update_state(&Map.update!(&1, :draws, fn draws -> Map.put(draws, seat, []) end))
      update_state(&Map.put(&1, :last_discard, tile))
      RiichiAdvancedWeb.Endpoint.broadcast("game:main", "played_tile", %{"seat" => seat, "tile" => tile, "index" => index})

      # trigger play effects
      if Map.has_key?(state.rules, "play_effects") do
        Enum.each(state.rules["play_effects"], fn [tile_spec, action] ->
          if tile == tile_spec do
            case action do
              "reverse_turn_order" -> update_state(&Map.update!(&1, :reversed_turn_order, fn flag -> not flag end))
              _                    -> IO.puts("Unhandled action #{action}")
            end
          end
        end)
      end

      # change turn
      state = get_state()
      change_turn(next_turn(state.turn, if state.reversed_turn_order do 3 else 1 end))
    end
  end

  def temp_disable_play_tile(seat) do
    update_state(&Map.update!(&1, :play_tile_debounce, fn dbs -> Map.put(dbs, seat, true) end))
    Debounce.apply(Agent.get(__MODULE__, & &1.debouncers[seat]))
  end

  def reindex_hand(seat, from, to) do
    temp_disable_play_tile(seat)
    # IO.puts("#{seat} moved tile from #{from} to #{to}")
    update_state(&Map.update!(&1, :hands, fn hands -> Map.update!(hands, seat, fn hand ->
      {l1, [tile | r1]} = Enum.split(hand, from)
      {l2, r2} = Enum.split(l1 ++ r1, to)
      l2 ++ [tile] ++ r2
    end) end))
  end

  def draw_tile(seat, num) do
    if num > 0 do
      update_state(&Map.update!(&1, :draws, fn draws -> Map.update!(draws, &1.turn, fn draw -> draw ++ [Enum.at(&1.wall, &1.wall_index)] end) end))
      update_state(&Map.update!(&1, :wall_index, fn ix -> ix + 1 end))
      # IO.puts("wall index is now #{get_state().wall_index}")
      draw_tile(seat, num - 1)
    end
  end

  def trigger_on_no_valid_tiles(seat, gas \\ 100) do
    if gas > 0 do
      state = get_state()
      if not Enum.any?(state.hands[seat] ++ state.draws[seat], &is_playable/1) do
        # IO.puts("player #{seat} has no valid plays")
        Enum.each(state.rules["on_no_valid_tiles"]["actions"], fn [action | opts] ->
          case action do
            "draw" -> draw_tile(seat, Enum.at(opts, 0, 1))
            _      -> IO.puts("Unhandled action #{action}")
          end
        end)
        if state.rules["on_no_valid_tiles"]["recurse"] do
          trigger_on_no_valid_tiles(seat, gas - 1)
        end
      # else
      #   IO.puts("player #{seat} has valid plays:")
      #   IO.inspect(state.hands[seat] ++ state.draws[seat])
      #   IO.inspect(Enum.map(state.hands[seat] ++ state.draws[seat], &is_playable/1))
      end
    end
  end

  def change_turn(seat) do
    update_state(&Map.put(&1, :turn, seat))
    # check if any tiles are playable for this next player
    state = get_state()
    if Map.has_key?(state.rules, "on_no_valid_tiles") do
      trigger_on_no_valid_tiles(seat)
    end
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
