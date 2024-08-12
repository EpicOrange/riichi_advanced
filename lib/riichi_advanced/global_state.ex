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
    rules = Jason.decode!(File.read!(Application.app_dir(:riichi_advanced, "priv/static/riichi.json")))
    update_state(&Map.put(&1, :rules, rules))

    wall = Enum.map(rules["wall"], &Riichi.to_tile(&1))
    wall = Enum.shuffle(wall)
    hands = %{:east => Riichi.sort_tiles(Enum.slice(wall, 0..12) ++ [:"2m"]),
              :south => Riichi.sort_tiles(Enum.slice(wall, 13..25) ++ [:"1m", :"3m"]),
              :west => Riichi.sort_tiles(Enum.slice(wall, 26..38) ++ [:"2m", :"2m", :"1m", :"3m"]),
              :north => Riichi.sort_tiles(Enum.slice(wall, 39..51))}
    update_state(&Map.put(&1, :wall, wall))
    update_state(&Map.put(&1, :hands, hands))

    dirs = [:east, :south, :west, :north]
    update_state(&Map.put(&1, :draws, Map.new(dirs, fn dir -> {dir, []} end)))
    update_state(&Map.put(&1, :ponds, Map.new(dirs, fn dir -> {dir, []} end)))
    update_state(&Map.put(&1, :buttons, Map.new(dirs, fn dir -> {dir, []} end)))
    update_state(&Map.put(&1, :button_choice, Map.new(dirs, fn dir -> {dir, nil} end)))
    update_state(&Map.put(&1, :wall_index, 52))
    update_state(&Map.put(&1, :last_discard, nil))
    update_state(&Map.put(&1, :reversed_turn_order, false))

    change_turn(:east)

    update_state(&Map.put(&1, :initialized, true))
  end

  def get_state, do: Agent.get(__MODULE__, & &1.main)

  def update_state(fun) do
    Agent.update(__MODULE__, &Map.update!(&1, :main, fun))
    if get_state().initialized == true do
      RiichiAdvancedWeb.Endpoint.broadcast("game:main", "state_updated", %{"state" => get_state()})
    end
  end

  def print_state, do: IO.puts("Global state: #{inspect(get_state())}")
  
  def next_turn(seat, iterations \\ 1) do
    next = cond do
      seat == :east -> :south
      seat == :south -> :west
      seat == :west -> :north
      seat == :north -> :east
    end
    if iterations <= 1 do next else next_turn(next, iterations - 1) end
  end
  def prev_turn(seat, iterations \\ 1) do
    prev = cond do
      seat == :east -> :north
      seat == :south -> :east
      seat == :west -> :south
      seat == :north -> :west
    end
    if iterations <= 1 do prev else prev_turn(prev, iterations - 1) end
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
    [state.turn, state.hands, state.ponds, state.draws, state.buttons] ++ rotate_4([:east, :south, :west, :north], seat)
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
                  "manzu" -> Riichi.is_manzu?(state.last_discard)
                  "pinzu" -> Riichi.is_pinzu?(state.last_discard)
                  "souzu" -> Riichi.is_souzu?(state.last_discard)
                  "jihai" -> Riichi.is_jihai?(state.last_discard)
                  "1" -> Riichi.is_num?(state.last_discard, 1)
                  "2" -> Riichi.is_num?(state.last_discard, 2)
                  "3" -> Riichi.is_num?(state.last_discard, 3)
                  "4" -> Riichi.is_num?(state.last_discard, 4)
                  "5" -> Riichi.is_num?(state.last_discard, 5)
                  "6" -> Riichi.is_num?(state.last_discard, 6)
                  "7" -> Riichi.is_num?(state.last_discard, 7)
                  "8" -> Riichi.is_num?(state.last_discard, 8)
                  "9" -> Riichi.is_num?(state.last_discard, 9)
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
      IO.puts("#{seat} played tile: #{inspect(tile)} at index #{index}")
      update_state(&Map.update!(&1, :hands, fn hands -> Map.update!(hands, seat, fn hand -> List.delete_at(hand ++ &1.draws[seat], index) end) end))
      update_state(&Map.update!(&1, :ponds, fn ponds -> Map.update!(ponds, seat, fn pond -> pond ++ [tile] end) end))
      update_state(&Map.update!(&1, :draws, fn draws -> Map.put(draws, seat, []) end))
      update_state(&Map.put(&1, :last_discard, tile))
      RiichiAdvancedWeb.Endpoint.broadcast("game:main", "played_tile", %{"seat" => seat, "tile" => tile, "index" => index})

      # trigger play effects
      if Map.has_key?(state.rules, "play_effects") do
        Enum.each(state.rules["play_effects"], fn [tile_spec, actions] ->
          if tile == tile_spec do
            run_actions(seat, actions)
          end
        end)
      end

      # update buttons for all players
      update_buttons()

      # change turn if no buttons exist
      if no_buttons_remaining?() do
        state = get_state()
        change_turn(if state.reversed_turn_order do prev_turn(state.turn) else next_turn(state.turn) end)
      end
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
      update_state(&Map.update!(&1, :hands, fn hands -> Map.update!(hands, &1.turn, fn hand -> hand ++ &1.draws[&1.turn] end) end))
      update_state(&Map.update!(&1, :draws, fn draws -> Map.put(draws, &1.turn, [Enum.at(&1.wall, &1.wall_index)]) end))
      update_state(&Map.update!(&1, :wall_index, fn ix -> ix + 1 end))
      # IO.puts("wall index is now #{get_state().wall_index}")
      draw_tile(seat, num - 1)
    end
  end

  def trigger_on_no_valid_tiles(seat, gas \\ 100) do
    if gas > 0 do
      state = get_state()
      if not Enum.any?(state.hands[seat] ++ state.draws[seat], &is_playable/1) do
        run_actions(seat, state.rules["on_no_valid_tiles"]["actions"])
        if state.rules["on_no_valid_tiles"]["recurse"] do
          trigger_on_no_valid_tiles(seat, gas - 1)
        end
      end
    end
  end

  # return all button names that have no effect due to other players' button choices
  def get_superceded_buttons do
    state = get_state()
    Enum.flat_map(state.button_choice, fn {_seat, button_name} -> 
      if button_name != nil do
        state.rules["buttons"][button_name]["precedence_over"]
      else
        []
      end
    end)
  end

  # returns true if no button choices remain
  # if any of the pressed buttons takes precedence over all buttons available to a given seat,
  # then that seat is not considered to have button choices
  def no_buttons_remaining? do
    state = get_state()
    superceded_buttons = get_superceded_buttons()
    Enum.all?(state.buttons, fn {_seat, button_names} ->
      Enum.empty?(button_names) || Enum.all?(button_names, fn name -> Enum.member?(superceded_buttons, name) end)
    end)
  end

  def update_buttons do
    # calculate buttons for each seat
    state = get_state()
    if Map.has_key?(state.rules, "buttons") do
      new_buttons = Map.new([:east, :south, :west, :north], fn seat ->
        {seat, Enum.map(Enum.filter(state.rules["buttons"], fn {_name, button} -> check_cnf_condition(seat, button["show_when"]) end),
          fn {name, _button} -> name end)}
      end)
      update_state(&Map.put(&1, :buttons, new_buttons))
    end
  end

  def change_turn(seat, via_action \\ false) do
    # change turn
    update_state(&Map.put(&1, :turn, seat))
    update_buttons()

    # run on turn change (unless this turn change was triggered by an action
    state = get_state()
    if not via_action && Map.has_key?(state.rules, "on_turn_change") do
      run_actions(seat, state.rules["on_turn_change"]["actions"])
    end

    # check if any tiles are playable for this next player
    state = get_state()
    if Map.has_key?(state.rules, "on_no_valid_tiles") do
      trigger_on_no_valid_tiles(seat)
    end
  end

  def run_actions(seat, actions) do
    Enum.each(actions, fn [action | opts] ->
      case action do
        "draw"               -> draw_tile(seat, Enum.at(opts, 0, 1))
        "reverse_turn_order" -> update_state(&Map.update!(&1, :reversed_turn_order, fn flag -> not flag end))
        "chii"               -> IO.puts("Chii not implemented")
          # update_state(&Map.update!(&1, :ponds, fn ponds -> Map.update!(ponds, &1.turn, fn hand -> hand ++ &1.draws[&1.turn] end) end))
        "pon"                -> IO.puts("Pon not implemented")
        "daiminkan"          -> IO.puts("Kan not implemented")
        "shouminkan"         -> IO.puts("Kan not implemented")
        "ankan"              -> IO.puts("Kan not implemented")
        "change_turn"        -> change_turn(get_seat(seat, String.to_atom(Enum.at(opts, 0, "self"))), true)
        "flower"             -> IO.puts("Flower not implemented")
        "ron"                -> IO.puts("Ron not implemented")
        "tsumo"              -> IO.puts("Tsumo not implemented")
        "riichi"             -> IO.puts("Riichi not implemented")
        _                    -> IO.puts("Unhandled action #{action}")
      end
    end)
  end

  def check_condition(seat, cond_spec) do
    state = get_state()
    case cond_spec do
      "our_turn"            -> state.turn == seat
      "not_our_turn"        -> state.turn != seat
      "our_turn_is_next"    -> state.turn == if state.reversed_turn_order do next_turn(seat) else prev_turn(seat) end
      "chii_available"      -> Riichi.can_chii?(state.hands[seat], state.last_discard)
      "pon_available"       -> Riichi.can_pon?(state.hands[seat], state.last_discard)
      "daiminkan_available" -> Riichi.can_daiminkan?(state.hands[seat], state.last_discard)
      _                     ->
        IO.puts "Unhandled condition #{inspect(cond_spec)}"
        false
    end
  end

  def check_dnf_condition(seat, cond_spec) do
    cond do
      is_binary(cond_spec) -> check_condition(seat, cond_spec)
      is_list(cond_spec)   -> Enum.any?(cond_spec, &check_cnf_condition(seat, &1))
      true                 ->
        IO.puts "Unhandled condition clause #{inspect(cond_spec)}"
        true
    end
  end

  def check_cnf_condition(seat, cond_spec) do
    cond do
      is_binary(cond_spec) -> check_condition(seat, cond_spec)
      is_list(cond_spec)   -> Enum.all?(cond_spec, &check_dnf_condition(seat, &1))
      true                 ->
        IO.puts "Unhandled condition clause #{inspect(cond_spec)}"
        true
    end
  end


  def press_button(seat, button_name) do
    state = get_state()
    if Enum.member?(state.buttons[seat], button_name) do
      # mark button pressed
      update_state(&Map.update!(&1, :button_choice, fn buttons -> Map.put(buttons, seat, button_name) end))
      # hide all buttons
      update_state(&Map.update!(&1, :buttons, fn buttons -> Map.put(buttons, seat, []) end))

      # if nobody else needs to make choices, trigger actions on all buttons that aren't superceded by precedence
      if no_buttons_remaining?() do
        state = get_state()
        superceded_buttons = get_superceded_buttons()
        Enum.each(state.button_choice, fn {seat, button_name} ->
          if button_name != nil && not Enum.member?(superceded_buttons, button_name) do
            run_actions(seat, state.rules["buttons"][button_name]["actions"])
          end
        end)
      end
    end
  end
end
