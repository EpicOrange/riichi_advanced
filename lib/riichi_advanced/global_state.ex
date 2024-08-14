defmodule Player do
  defstruct [
    hand: [],
    draw: [],
    pond: [],
    calls: [{"pon", [{:"2p", false}, {:"2p", true}, {:"2p", false}]}],
    buttons: [],
    call_buttons: %{},
    call_name: "",
    deferred_actions: [],
    button_choice: nil,
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
    hands = %{:east  => Riichi.sort_tiles([:"1m", :"2m", :"3m", :"2p", :"0s", :"5s", :"5s", :"5s", :"5s", :"1z", :"1z", :"1z", :"1z"]),
              :south => Riichi.sort_tiles([:"1m", :"9m", :"1p", :"9p", :"1s", :"9s", :"1z", :"2z", :"3z", :"4z", :"5z", :"6z", :"7z"]),
              :west  => Riichi.sort_tiles([:"1m", :"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m", :"9m", :"1p", :"1p", :"3p", :"4p"]),
              :north => Riichi.sort_tiles([:"1m", :"2m", :"2m", :"5m", :"5m", :"7m", :"7m", :"9m", :"9m", :"1z", :"1z", :"2z", :"3z"])}
    # hands = %{:east  => Riichi.sort_tiles(Enum.slice(wall, 0..12)),
    #           :south => Riichi.sort_tiles(Enum.slice(wall, 13..25)),
    #           :west  => Riichi.sort_tiles(Enum.slice(wall, 26..38)),
    #           :north => Riichi.sort_tiles(Enum.slice(wall, 39..51))}
    update_state(&Map.put(&1, :wall, wall))

    dirs = [:east, :south, :west, :north]
    update_state(&Map.put(&1, :players, Map.new(dirs, fn seat -> {seat, %Player{hand: hands[seat]}} end)))
    update_state(&Map.put(&1, :wall_index, 52))
    update_state(&Map.put(&1, :last_action, %{seat: nil, action: nil}))
    update_state(&Map.put(&1, :reversed_turn_order, false))

    run_actions([["change_turn", "self"], ["draw"]], %{seat: :east})

    update_state(&Map.put(&1, :initialized, true))
  end

  def get_state, do: Agent.get(__MODULE__, & &1.main)

  def update_state(fun) do
    Agent.update(__MODULE__, &Map.update!(&1, :main, fun))
    if get_state().initialized == true do
      RiichiAdvancedWeb.Endpoint.broadcast("game:main", "state_updated", %{"state" => get_state()})
    end
  end

  def update_player(seat, fun) do
    update_state(&Map.update!(&1, :players, fn players -> Map.update!(players, seat, fun) end))
  end

  def update_all_players(fun) do
    update_state(&Map.update!(&1, :players, fn players -> Map.new(players, fn {seat, player} -> {seat, fun.(seat, player)} end) end))
  end

  def get_last_action do
    get_state().last_action
  end

  def update_action(seat, action, opts \\ %{}) do
    update_state(&Map.put(&1, :last_action, opts |> Map.put(:seat, seat) |> Map.put(:action, action)))
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

  def temp_disable_play_tile(seat) do
    update_state(&Map.update!(&1, :play_tile_debounce, fn dbs -> Map.put(dbs, seat, true) end))
    Debounce.apply(Agent.get(__MODULE__, & &1.play_tile_debouncers[seat]))
  end

  def temp_display_big_text(seat, text) do
    update_player(seat, fn player -> %Player{ player | big_text: text } end )
    Debounce.apply(Agent.get(__MODULE__, & &1.big_text_debouncers[seat]))
  end

  def advance_turn do
    state = get_state()
    change_turn(if state.reversed_turn_order do Utils.prev_turn(state.turn) else Utils.next_turn(state.turn) end)
  end

  def is_playable(seat, tile) do
    state = get_state()
    Enum.all?(state.rules["play_restrictions"], fn [tile_spec, cond_spec] ->
      not Riichi.tile_matches(tile, tile_spec) || check_cnf_condition(cond_spec, %{seat: seat})
    end)
  end

  def play_tile(seat, tile, index) do
    state = get_state()
    # assume we're skipping our button choices
    update_player(seat, fn player -> %Player{ player | buttons: %{}, call_buttons: %{}, call_name: "", deferred_actions: [] } end)
    if state.play_tile_debounce[seat] != true && no_buttons_remaining?() do
      temp_disable_play_tile(seat)
      IO.puts("#{seat} played tile: #{inspect(tile)} at index #{index}")
      update_player(seat, fn player ->
        %Player{ player |
                 hand: List.delete_at(player.hand ++ player.draw, index),
                 pond: player.pond ++ [tile],
                 draw: [] }
      end)
      update_action(seat, :discard, %{tile: tile})
      RiichiAdvancedWeb.Endpoint.broadcast("game:main", "played_tile", %{"seat" => seat, "tile" => tile, "index" => index})

      # trigger play effects
      if Map.has_key?(state.rules, "play_effects") do
        Enum.each(state.rules["play_effects"], fn [tile_spec, actions] ->
          if tile == tile_spec do
            run_actions(actions, %{seat: seat})
          end
        end)
      end
    end
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
      tile = Enum.at(state.wall, state.wall_index)
      update_player(seat, fn player ->
        %Player{ player |
                 hand: Riichi.sort_tiles(player.hand ++ player.draw),
                 draw: [tile]
               }
      end)
      update_state(&Map.update!(&1, :wall_index, fn ix -> ix + 1 end))
      update_action(seat, :draw, %{tile: tile})

      # IO.puts("wall index is now #{get_state().wall_index}")
      draw_tile(seat, num - 1)
    end
  end

  def trigger_on_no_valid_tiles(seat, gas \\ 100) do
    if gas > 0 do
      state = get_state()
      IO.inspect(seat)
      IO.inspect(state.players[seat].hand ++ state.players[seat].draw)
      IO.inspect(Enum.map(state.players[seat].hand ++ state.players[seat].draw, fn tile -> is_playable(seat, tile) end))
      if not Enum.any?(state.players[seat].hand ++ state.players[seat].draw, fn tile -> is_playable(seat, tile) end) do
        run_actions(state.rules["on_no_valid_tiles"]["actions"], %{seat: seat})
        if Map.has_key?(state.rules["on_no_valid_tiles"], "recurse") && state.rules["on_no_valid_tiles"]["recurse"] do
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

  def change_turn(seat, via_action \\ false) do
    # change turn
    update_state(&Map.put(&1, :turn, seat))

    # run on turn change (unless this turn change was triggered by an action)
    state = get_state()
    if not via_action && Map.has_key?(state.rules, "on_turn_change") do
      run_actions(state.rules["on_turn_change"]["actions"], %{seat: seat})
    end

    # check if any tiles are playable for this next player
    state = get_state()
    if Map.has_key?(state.rules, "on_no_valid_tiles") do
      trigger_on_no_valid_tiles(seat)
    end
  end

  def trigger_call(seat, call_name, call_choice, called_tile, call_source) do
    state = get_state()
    tiles = Enum.map(call_choice, fn t -> {t, false} end)
    call = case Utils.get_relative_seat(seat, state.turn) do
      :kamicha -> [{called_tile, true} | tiles]
      :toimen ->
        [first | rest] = tiles
        [first, {called_tile, true} | rest]
      :shimocha -> tiles ++ [{called_tile, true}]
      :self -> 
        # TODO support more than just ankan
        red = Riichi.to_red(called_tile)
        [{:"1x", false}, {if red in call_choice do red else called_tile end, false}, {called_tile, false}, {:"1x", false}]
    end
    case call_source do
      :discards -> update_player(state.turn, fn player -> %Player{ player | pond: player.pond |> Enum.reverse() |> tl() |> Enum.reverse() } end)
      :hand     -> update_player(seat, fn player -> %Player{ player | hand: player.hand -- [called_tile] } end)
      _         -> IO.puts("Unhandled call_source #{inspect(call_source)}")
    end
    update_player(seat, fn player -> %Player{ player | hand: player.hand -- call_choice, calls: player.calls ++ [{call_name, call}] } end)
    update_action(seat, :call,  %{from: state.turn, called_tile: called_tile, other_tiles: call_choice, call_name: call_name})
    update_player(seat, fn player -> %Player{ player | call_buttons: %{}, call_name: "" } end)
    # since we interrupted the player we called from, cancel their remaining actions
    update_player(state.turn, fn player -> %Player{ player | deferred_actions: [] } end)
  end

  def upgrade_call(seat, call_name, call_choice, called_tile) do
    # find the index of the call whose tiles match call_choice
    state = get_state()
    index = state.players[seat].calls
      |> Enum.map(fn {_name, call} -> Enum.map(call, fn {tile, _sideways} -> tile end) end)
      |> Enum.find_index(fn call_tiles -> Enum.sort(call_tiles) == Enum.sort(call_choice) end)
    # upgrade that call
    {_name, call} = Enum.at(state.players[seat].calls, index)
    upgraded_call = {call_name, List.insert_at(call, 1, {called_tile, true})}
    update_player(seat, fn player -> %Player{ player | hand: player.hand -- [called_tile], calls: List.replace_at(state.players[seat].calls, index, upgraded_call) } end)
    update_action(seat, :call,  %{from: state.turn, called_tile: called_tile, other_tiles: call_choice, call_name: call_name})
    update_player(seat, fn player -> %Player{ player | call_buttons: %{}, call_name: "" } end)
  end

  def run_actions(actions, context \\ %{}) do
    deferred_actions = if Map.has_key?(context, :seat) do
      state = get_state()
      state.players[context.seat].deferred_actions
    else
      []
    end
    # IO.puts("Running actions in context #{inspect(context)}: #{inspect(actions)} ++ #{inspect(deferred_actions)}")
    update_player(context.seat, fn player -> %{ player | deferred_actions: [] } end)
    deferred_actions = Enum.drop_while(actions ++ deferred_actions, fn [action | opts] ->
      case action do
        "play_tile"          -> play_tile(context.seat, Enum.at(opts, 0, :"1m"), Enum.at(opts, 1, 0))
        "draw"               -> draw_tile(context.seat, Enum.at(opts, 0, 1))
        "reverse_turn_order" -> update_state(&Map.update!(&1, :reversed_turn_order, fn flag -> not flag end))
        "call"               -> trigger_call(context.seat, context.call_name, context.call_choice, context.called_tile, :discards)
        "self_call"          -> trigger_call(context.seat, context.call_name, context.call_choice, context.called_tile, :hand)
        "upgrade_call"       -> upgrade_call(context.seat, context.call_name, context.call_choice, context.called_tile)
        "advance_turn"       -> advance_turn()
        "change_turn"        -> change_turn(Utils.get_seat(context.seat, String.to_atom(Enum.at(opts, 0, "self"))), true)
        "flower"             -> IO.puts("Flower not implemented")
        "ron"                -> IO.puts("Ron not implemented")
        "tsumo"              -> IO.puts("Tsumo not implemented")
        "riichi"             -> update_player(context.seat, fn player -> %Player{ player | riichi: true } end)
        "big_text"           -> temp_display_big_text(context.seat, Enum.at(opts, 0, ""))
        _                    -> IO.puts("Unhandled action #{action}")
      end
      # if our action updates state, then we need to recalculate buttons
      # if buttons appear, stop evaluating actions here
      # this is so other players can react to certain actions
      if action not in ["big_text"] do
        state = get_state()
        if Map.has_key?(state.rules, "buttons") do
          new_buttons = Map.new([:east, :south, :west, :north], fn seat ->
            buttons = state.rules["buttons"]
              |> Enum.filter(fn {_name, button} ->
                   calls_spec = if Map.has_key?(button, "call") do button["call"] else [] end
                   upgrades = if Map.has_key?(button, "upgrades") do button["upgrades"] else [] end
                   check_cnf_condition(button["show_when"], %{seat: seat, calls_spec: calls_spec, upgrade_name: upgrades})
                 end)
              |> Enum.map(fn {name, _button} -> name end)
            {seat, if not Enum.empty?(buttons) do buttons ++ ["skip"] else buttons end}
          end)
          # IO.puts("Updating buttons after action #{action}: #{inspect(new_buttons)}")
          update_all_players(fn seat, player -> %Player{ player | buttons: new_buttons[seat] } end)
        end
        no_buttons_remaining?()
      else
        true
      end
    end)
    # dropwhile keeps the action that we stop on, so we need to drop the first one
    deferred_actions = Enum.drop(deferred_actions, 1)
    if not Enum.empty?(deferred_actions) do
      # IO.puts("Deferred actions for seat #{context.seat}: #{inspect(deferred_actions)}")
      update_player(context.seat, fn player -> %{ player | deferred_actions: deferred_actions } end)
    end
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

  def check_condition(cond_spec, context \\ %{}, opts \\ []) do
    state = get_state()
    result = case cond_spec do
      "our_turn"               -> state.turn == context.seat
      "not_our_turn"           -> state.turn != context.seat
      "our_turn_is_next"       -> state.turn == if state.reversed_turn_order do Utils.next_turn(context.seat) else Utils.prev_turn(context.seat) end
      "our_turn_is_not_next"   -> state.turn != if state.reversed_turn_order do Utils.next_turn(context.seat) else Utils.prev_turn(context.seat) end
      "our_turn_is_prev"       -> state.turn == if state.reversed_turn_order do Utils.prev_turn(context.seat) else Utils.next_turn(context.seat) end
      "our_turn_is_not_prev"   -> state.turn != if state.reversed_turn_order do Utils.prev_turn(context.seat) else Utils.next_turn(context.seat) end
      "kamicha_discarded"      -> get_last_action().action == :discard && get_last_action().seat == Utils.prev_turn(context.seat)
      "someone_else_discarded" -> get_last_action().action == :discard && get_last_action().seat != context.seat
      "call_available"         -> get_last_action().action == :discard && Riichi.can_call?(context.calls_spec, state.players[context.seat].hand, [get_last_action().tile])
      "self_call_available"    -> Riichi.can_call?(context.calls_spec, state.players[context.seat].hand ++ state.players[context.seat].draw)
      "hand_matches"           -> Enum.any?(opts, fn name -> Riichi.check_hand(state.players[context.seat].hand ++ state.players[context.seat].draw, get_hand_definition(name <> "_definition"), String.to_atom(name)) end)
      "discard_matches"        -> get_last_action().action == :discard && Enum.any?(opts, fn name -> Riichi.check_hand(state.players[context.seat].hand ++ [get_last_action().tile], get_hand_definition(name <> "_definition"), String.to_atom(name)) end)
      "game_start"             -> get_last_action().action == nil
      "last_discard_matches"   -> get_last_action().action == :discard && Riichi.tile_matches(get_last_action().tile, opts)
      "call_matches"           -> get_last_action().action == :call && get_last_action().call_name == Enum.at(opts, 0, "kakan") && Enum.any?(Enum.at(opts, 1, []), fn name -> Riichi.check_hand(state.players[context.seat].hand ++ [get_last_action().called_tile], get_hand_definition(name <> "_definition"), String.to_atom(name)) end)
      "can_upgrade_call"       -> state.players[context.seat].calls
        |> Enum.filter(fn {name, _call} -> name == context.upgrade_name end)
        |> Enum.any?(fn {_name, call} ->
          call_tiles = Enum.map(call, fn {tile, _sideways} -> tile end)
          Riichi.can_call?(context.calls_spec, call_tiles, state.players[context.seat].hand ++ state.players[context.seat].draw)
        end)
      "have_draw"              -> not Enum.empty?(state.players[context.seat].draw)
      "not_furiten"            -> true
      "not_riichi"             -> not state.players[context.seat].riichi
      "has_yaku"               -> true
      _                        ->
        IO.puts "Unhandled condition #{inspect(cond_spec)}"
        false
    end
    # IO.puts("#{inspect(context)}, #{inspect(cond_spec)} => #{result}")
    result
  end

  def check_dnf_condition(cond_spec, context \\ %{}) do
    cond do
      is_binary(cond_spec) -> check_condition(cond_spec, context)
      is_map(cond_spec)    -> check_condition(cond_spec["name"], context, cond_spec["opts"])
      is_list(cond_spec)   -> Enum.any?(cond_spec, &check_cnf_condition(&1, context))
      true                 ->
        IO.puts "Unhandled condition clause #{inspect(cond_spec)}"
        true
    end
  end

  def check_cnf_condition(cond_spec, context \\ %{}) do
    cond do
      is_binary(cond_spec) -> check_condition(cond_spec, context)
      is_map(cond_spec)    -> check_condition(cond_spec["name"], context, cond_spec["opts"])
      is_list(cond_spec)   -> Enum.all?(cond_spec, &check_dnf_condition(&1, context))
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
            actions = state.rules["buttons"][button_name]["actions"]
            if ["call"] in actions || ["self_call"] in actions || ["upgrade_call"] in actions do
              # if there is a call action, check if there are multiple call choices
              state = get_state()
              call_choices = if ["upgrade_call"] in actions do
                state.players[seat].calls
                  |> Enum.filter(fn {name, _call} -> name == state.rules["buttons"][button_name]["upgrades"] end)
                  |> Enum.map(fn {_name, call} -> Enum.map(call, fn {tile, _sideways} -> tile end) end)
                  |> Enum.map(fn call_tiles ->
                    Riichi.make_calls(state.rules["buttons"][button_name]["call"], call_tiles, state.players[seat].hand ++ state.players[seat].draw)
                  end)
                  |> Enum.reduce(%{}, fn call_choices, acc -> Map.merge(call_choices, acc, fn _k, l, r -> l ++ r end) end)
                else
                  callable_tiles = if ["call"] in actions do [List.last(state.players[state.turn].pond)] else [] end
                  Riichi.make_calls(state.rules["buttons"][button_name]["call"], state.players[seat].hand ++ state.players[seat].draw, callable_tiles)
                end
              IO.inspect(call_choices)
              flattened_call_choices = call_choices |> Map.values() |> Enum.concat()
              if length(flattened_call_choices) == 1 do
                # if there's only one choice, automatically choose it
                {called_tile, [call_choice]} = Enum.max_by(call_choices, fn {_tile, choices} -> length(choices) end)
                IO.inspect(%{seat: seat, call_name: button_name, call_choice: call_choice, called_tile: called_tile})
                run_actions(actions, %{seat: seat, call_name: button_name, call_choice: call_choice, called_tile: called_tile})
              else
                # otherwise, defer all actions and display call choices
                update_player(seat, fn player -> %Player{ player | deferred_actions: actions, call_buttons: call_choices, call_name: button_name } end)
              end
            else
              # otherwise, just run all button actions as normal
              run_actions(actions, %{seat: seat})
            end
          end
        end)

        # unmark all buttons pressed
        update_all_players(fn _seat, player -> %Player{ player | button_choice: nil } end)
      end
    end
  end
end
