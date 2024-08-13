defmodule Player do
  defstruct [
    hand: [],
    draw: [],
    pond: [:"3m"],
    calls: [],
    buttons: [],
    call_buttons: %{},
    deferred_actions: [],
    button_choice: nil,
    call_source: nil,
    big_text: "",
    riichi: false
  ]
end

defmodule RiichiAdvanced.GlobalState do
  use Agent

  def start_link(_initial_data) do
    initial_data = %{initialized: false}
    play_tile_debounce = %{:east => false, :south => false, :west => false, :north => false}
    initial_data = Map.put(initial_data, :play_tile_debounce, play_tile_debounce)
    play_tile_debouncers = %{
      :east => PlayTileDebounceEast,
      :south => PlayTileDebounceSouth,
      :west => PlayTileDebounceWest,
      :north => PlayTileDebounceNorth
    }
    big_text_debouncers = %{
      :east => BigTextDebounceEast,
      :south => BigTextDebounceSouth,
      :west => BigTextDebounceWest,
      :north => BigTextDebounceNorth
    }
    Agent.start_link(fn -> %{
      main: initial_data,
      play_tile_debouncers: play_tile_debouncers,
      big_text_debouncers: big_text_debouncers,
    } end, name: __MODULE__)
  end

  def initialize_game do
    rules = Jason.decode!(File.read!(Application.app_dir(:riichi_advanced, "priv/static/riichi.json")))
    update_state(&Map.put(&1, :rules, rules))

    wall = Enum.map(rules["wall"], &Riichi.to_tile(&1))
    wall = Enum.shuffle(wall)
    hands = %{:east => Riichi.sort_tiles([:"1m", :"2m", :"3m", :"4m", :"0s", :"5s", :"5s", :"5s", :"5s", :"1z", :"1z", :"1z", :"1z"]),
              :south => Riichi.sort_tiles([:"1m",:"9m",:"1p",:"9p",:"1s",:"9s",:"1z",:"2z",:"3z",:"4z",:"5z",:"6z",:"7z"]),
              :west => Riichi.sort_tiles([:"1m", :"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m", :"9m", :"1p", :"1p", :"3p", :"4p"]),
              :north => Riichi.sort_tiles([:"1m", :"2m", :"2m", :"5m", :"5m", :"7m", :"7m", :"9m", :"9m", :"1z", :"1z", :"2z", :"3z"])}
    # hands = %{:east => Riichi.sort_tiles(Enum.slice(wall, 0..12)),
    #           :south => Riichi.sort_tiles(Enum.slice(wall, 13..25)),
    #           :west => Riichi.sort_tiles(Enum.slice(wall, 26..38)),
    #           :north => Riichi.sort_tiles(Enum.slice(wall, 39..51))}
    update_state(&Map.put(&1, :wall, wall))

    dirs = [:east, :south, :west, :north]
    update_state(&Map.put(&1, :players, Map.new(dirs, fn seat -> {seat, %Player{hand: hands[seat]}} end)))
    update_state(&Map.put(&1, :wall_index, 52))
    update_state(&Map.put(&1, :last_discard, nil))
    update_state(&Map.put(&1, :last_discarder, nil))
    update_state(&Map.put(&1, :reversed_turn_order, false))
    update_state(&Map.put(&1, :paused, false))

    change_turn(:east)
    update_buttons()

    update_state(&Map.put(&1, :initialized, true))
  end

  def get_state, do: Agent.get(__MODULE__, & &1.main)

  def update_state(fun) do
    Agent.update(__MODULE__, &Map.update!(&1, :main, fun))
    if get_state().initialized == true do
      RiichiAdvancedWeb.Endpoint.broadcast("game:main", "state_updated", %{"state" => get_state()})
    end
  end

  def update_player(seat, func) do
    update_state(&Map.update!(&1, :players, fn players -> Map.update!(players, seat, func) end))
  end

  def print_state, do: IO.puts("Global state: #{inspect(get_state())}")
  
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
    [state.turn, state.players] ++ Utils.rotate_4([:east, :south, :west, :north], seat)
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
    if state.play_tile_debounce[seat] != true && no_buttons_remaining?() do
      temp_disable_play_tile(seat)
      IO.puts("#{seat} played tile: #{inspect(tile)} at index #{index}")
      update_player(seat, fn player ->
        %Player{ player |
                 hand: List.delete_at(player.hand ++ player.draw, index),
                 pond: player.pond ++ [tile],
                 draw: [] }
      end)
      update_state(&Map.put(&1, :last_discard, tile))
      update_state(&Map.put(&1, :last_discarder, seat))
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

      # clear call choices and deferred actions (if any)
      update_state(&Map.update!(&1, :players, fn players -> Map.new(players, fn {seat, player} ->
        {seat, %Player{ player | call_buttons: %{}, deferred_actions: [], call_source: nil }}
      end) end))

      # change turn if no buttons exist to interrupt the turn change
      if no_buttons_remaining?() do
        state = get_state()
        change_turn(if state.reversed_turn_order do Utils.prev_turn(state.turn) else Utils.next_turn(state.turn) end)
      else
        update_state(&Map.put(&1, :paused, true))
      end
    end
  end

  def temp_disable_play_tile(seat) do
    update_state(&Map.update!(&1, :play_tile_debounce, fn dbs -> Map.put(dbs, seat, true) end))
    Debounce.apply(Agent.get(__MODULE__, & &1.play_tile_debouncers[seat]))
  end

  def temp_display_big_text(seat, text) do
    update_player(seat, fn player -> %Player{ player | big_text: text } end )
    Debounce.apply(Agent.get(__MODULE__, & &1.big_text_debouncers[seat]))
  end

  defp _reindex_hand(hand, from, to) do
    {l1, [tile | r1]} = Enum.split(hand, from)
    {l2, r2} = Enum.split(l1 ++ r1, to)
    l2 ++ [tile] ++ r2
  end

  def reindex_hand(seat, from, to) do
    temp_disable_play_tile(seat)
    # IO.puts("#{seat} moved tile from #{from} to #{to}")
    update_player(seat, fn player -> %Player{ player | :hand => _reindex_hand(player.hand, from, to) } end)
  end

  def draw_tile(seat, num) do
    if num > 0 do
      state = get_state()
      update_player(seat, fn player ->
        %Player{ player |
                 hand: Riichi.sort_tiles(player.hand ++ player.draw),
                 draw: [Enum.at(state.wall, state.wall_index)]
               }
      end)
      update_state(&Map.update!(&1, :wall_index, fn ix -> ix + 1 end))
      # IO.puts("wall index is now #{get_state().wall_index}")
      draw_tile(seat, num - 1)
    end
  end

  def trigger_on_no_valid_tiles(seat, gas \\ 100) do
    if gas > 0 do
      state = get_state()
      if not Enum.any?(state.players[seat].hand ++ state.players[seat].draw, &is_playable/1) do
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
    Enum.flat_map(state.players, fn {_seat, player} -> 
      if player.button_choice != nil && player.button_choice != "skip" do
        ["skip"] ++ state.rules["buttons"][player.button_choice]["precedence_over"]
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
    Enum.all?(state.players, fn {_seat, player} ->
      Enum.empty?(player.buttons) || Enum.all?(player.buttons, fn name -> Enum.member?(superceded_buttons, name) end)
    end)
  end

  # update buttons for each seat based on current game state
  def update_buttons do
    state = get_state()
    if Map.has_key?(state.rules, "buttons") do
      new_buttons = Map.new([:east, :south, :west, :north], fn seat ->
        buttons = state.rules["buttons"]
          |> Enum.filter(fn {_name, button} ->
               calls_spec = if Map.has_key?(button, "call") do button["call"] else [] end
               check_cnf_condition(seat, button["show_when"], calls_spec)
             end)
          |> Enum.map(fn {name, _button} -> name end)
        {seat, if not Enum.empty?(buttons) do buttons ++ ["skip"] else buttons end}
      end)
      update_state(&Map.update!(&1, :players, fn players -> Map.new(players, fn {seat, player} ->
        {seat, %Player{player | buttons: new_buttons[seat]}}
      end) end))
    end
  end

  def change_turn(seat, via_action \\ false) do
    # change turn
    update_state(&Map.put(&1, :turn, seat))
    update_buttons()

    # since turn changed, we are no longer paused
    update_state(&Map.put(&1, :paused, false))

    # run on turn change (unless this turn change was triggered by an action
    state = get_state()
    if not via_action && Map.has_key?(state.rules, "on_turn_change") do
      run_actions(seat, state.rules["on_turn_change"]["actions"])
      update_buttons()
    end

    # check if any tiles are playable for this next player
    state = get_state()
    if Map.has_key?(state.rules, "on_no_valid_tiles") do
      trigger_on_no_valid_tiles(seat)
    end
  end

  def trigger_call(seat, call_choice, called_tile, call_source) do
    state = get_state()
    tiles = Enum.map(call_choice, fn t -> {t, false} end)
    call = case Utils.get_relative_seat(seat, state.turn) do
      :kamicha -> [{called_tile, true} | tiles]
      :toimen ->
        [first | rest] = tiles
        [first, {called_tile, true} | rest]
      :shimocha -> tiles ++ [{called_tile, true}]
      :self -> 
        red = Riichi.to_red(called_tile)
        [{:"1x", false}, {if red in call_choice do red else called_tile end, false}, {called_tile, false}, {:"1x", false}] # TODO support more than just ankan
    end
    case call_source do
      :discards -> update_player(state.turn, fn player -> %Player{ player | pond: player.pond |> Enum.reverse() |> tl() |> Enum.reverse() } end)
      :hand     -> update_player(seat, fn player -> %Player{ player | hand: player.hand -- [called_tile] } end)
      _         -> IO.puts("Unhandled call_source #{inspect(call_source)}")
    end
    update_player(seat, fn player -> %Player{ player | hand: player.hand -- call_choice, calls: player.calls ++ [call] } end)
    update_state(&Map.put(&1, :last_discard, nil))
    run_actions(seat, state.players[seat].deferred_actions)
    update_player(seat, fn player -> %Player{ player | call_buttons: %{}, deferred_actions: [], call_source: nil } end)
  end

  def run_actions(seat, actions) do
    Enum.each(actions, fn [action | opts] ->
      case action do
        "draw"               -> draw_tile(seat, Enum.at(opts, 0, 1))
        "reverse_turn_order" -> update_state(&Map.update!(&1, :reversed_turn_order, fn flag -> not flag end))
        "shouminkan"         -> IO.puts("Kan not implemented")
        "ankan"              -> IO.puts("Kan not implemented")
        "change_turn"        -> change_turn(Utils.get_seat(seat, String.to_atom(Enum.at(opts, 0, "self"))), true)
        "flower"             -> IO.puts("Flower not implemented")
        "ron"                -> IO.puts("Ron not implemented")
        "tsumo"              -> IO.puts("Tsumo not implemented")
        "riichi"             -> update_player(seat, fn player -> %Player{ player | riichi: true } end)
        "big_text"           -> temp_display_big_text(seat, Enum.at(opts, 0, ""))
        _                    -> IO.puts("Unhandled action #{action}")
      end
    end)
  end

  defp translate_hand_definition(hand_definitions, set_definitions) do
    for hand_def <- hand_definitions do
      for [groups, num] <- hand_def do
        translated_groups = for group <- groups, do: (if Map.has_key?(set_definitions, group) do set_definitions[group] else group end)
        [translated_groups, num]
      end
    end
  end

  def get_hand_definition(name) do
    state = get_state()
    if Map.has_key?(state.rules, "set_definitions") do
      translate_hand_definition(state.rules[name], state.rules["set_definitions"])
    else
      state.rules[name]
    end
  end

  def check_condition(seat, cond_spec, calls_spec, opts \\ []) do
    state = get_state()
    case cond_spec do
      "our_turn"               -> state.turn == seat
      "not_our_turn"           -> state.turn != seat
      "our_turn_is_next"       -> state.turn == if state.reversed_turn_order do Utils.next_turn(seat) else Utils.prev_turn(seat) end
      "our_turn_is_not_next"   -> state.turn != if state.reversed_turn_order do Utils.next_turn(seat) else Utils.prev_turn(seat) end
      "our_turn_is_prev"       -> state.turn == if state.reversed_turn_order do Utils.prev_turn(seat) else Utils.next_turn(seat) end
      "our_turn_is_not_prev"   -> state.turn != if state.reversed_turn_order do Utils.prev_turn(seat) else Utils.next_turn(seat) end
      "kamicha_discarded"      -> state.last_discarder != nil && state.last_discarder == Utils.prev_turn(seat)
      "someone_else_discarded" -> state.last_discarder != nil && state.last_discarder != seat
      "call_available"         -> Riichi.can_call?(calls_spec, state.players[seat].hand, [state.last_discard])
      "self_call_available"    -> Riichi.can_call?(calls_spec, state.players[seat].hand ++ state.players[seat].draw)
      "shouminkan_available"   -> false # TODO kakan
      "hand_matches"           -> Enum.any?(opts, fn name -> Riichi.check_hand(state.players[seat].hand ++ state.players[seat].draw, get_hand_definition(name <> "_definition"), String.to_atom(name)) end)
      "hand_discard_matches"   -> Enum.any?(opts, fn name -> Riichi.check_hand(state.players[seat].hand ++ [state.last_discard], get_hand_definition(name <> "_definition"), String.to_atom(name)) end)
      "hand_kakan_matches"     -> false
      "hand_ankan_matches"     -> false
      "chankan_available"      -> false
      "have_draw"              -> not Enum.empty?(state.players[seat].draw)
      "not_furiten"            -> true
      "not_riichi"             -> not state.players[seat].riichi
      "has_yaku"               -> true
      _                        ->
        IO.puts "Unhandled condition #{inspect(cond_spec)}"
        false
    end
  end

  def check_dnf_condition(seat, cond_spec, calls_spec) do
    cond do
      is_binary(cond_spec) -> check_condition(seat, cond_spec, calls_spec)
      is_map(cond_spec)    -> check_condition(seat, cond_spec["name"], calls_spec, cond_spec["opts"])
      is_list(cond_spec)   -> Enum.any?(cond_spec, &check_cnf_condition(seat, &1, calls_spec))
      true                 ->
        IO.puts "Unhandled condition clause #{inspect(cond_spec)}"
        true
    end
  end

  def check_cnf_condition(seat, cond_spec, calls_spec) do
    cond do
      is_binary(cond_spec) -> check_condition(seat, cond_spec, calls_spec)
      is_map(cond_spec)    -> check_condition(seat, cond_spec["name"], calls_spec, cond_spec["opts"])
      is_list(cond_spec)   -> Enum.all?(cond_spec, &check_dnf_condition(seat, &1, calls_spec))
      true                 ->
        IO.puts "Unhandled condition clause #{inspect(cond_spec)}"
        true
    end
  end

  def get_button_display_name(button_name) do
    if button_name == "skip" do
      "Skip"
    else
      get_state().rules["buttons"][button_name]["display_name"]
    end
  end

  def press_button(seat, button_name) do
    state = get_state()
    if Enum.member?(state.players[seat].buttons, button_name) do
      # hide all buttons and mark button pressed
      update_player(seat, fn player -> %Player{ player | buttons: [], button_choice: button_name } end)

      # if nobody else needs to make choices, trigger actions on all buttons that aren't superceded by precedence
      if no_buttons_remaining?() do
        state = get_state()
        superceded_buttons = get_superceded_buttons()
        Enum.each(state.players, fn {seat, player} ->
          button_name = player.button_choice
          if button_name != nil && button_name != "skip" && not Enum.member?(superceded_buttons, button_name) do
            IO.puts("Running button actions for player #{seat}")
            # run actions up to the first "call" action
            {actions, deferred_actions} = Enum.split_while(state.rules["buttons"][button_name]["actions"], fn action -> action not in [["call"], ["self_call"]] end)
            run_actions(seat, actions)
            # if there is a call action, schedule deferred actions for after the call is made
            # (this just to handle the case that multiple call choices are possible)
            if not Enum.empty?(deferred_actions) do
              [[call_type] | deferred_actions] = deferred_actions
              update_player(seat, fn player -> %Player{ player | deferred_actions: deferred_actions } end)
              state = get_state()
              called_tiles = if call_type == "self_call" do [] else [List.last(state.players[state.turn].pond)] end
              call_choices = Riichi.make_calls(state.rules["buttons"][button_name]["call"], state.players[seat].hand, called_tiles)
              # if there's only one choice, automatically choose it
              flattened_call_choices = call_choices |> Map.values() |> Enum.concat()
              call_source = if call_type == "self_call" do :hand else :discards end
              if length(flattened_call_choices) == 1 do
                {called_tile, [call_choice]} = Enum.max_by(call_choices, fn {_tile, choices} -> length(choices) end)
                trigger_call(seat, call_choice, called_tile, call_source)
              else
                update_player(seat, fn player -> %Player{ player | call_buttons: call_choices, call_source: call_source } end)
              end
            end
          end
        end)

        # unmark all buttons pressed
        update_state(&Map.update!(&1, :players, fn players -> Map.new(players, fn {seat, player} ->
          {seat, %Player{ player | button_choice: nil }}
        end) end))

        # resume play, if it hasn't been resumed by change_turn actions and we don't have call buttons displaying
        state = get_state()
        if state.paused and Enum.all?(state.players, fn {_seat, player} -> Enum.empty?(player.call_buttons) end) do
          change_turn(if state.reversed_turn_order do Utils.prev_turn(state.turn) else Utils.next_turn(state.turn) end)
        end
      else
        update_state(&Map.put(&1, :paused, true))
      end
    end
  end
end
