defmodule Player do
  defstruct [
    hand: [],
    draw: [],
    pond: [],
    calls: [],
    buttons: [],
    auto_buttons: [],
    call_buttons: %{},
    call_name: "",
    deferred_actions: [],
    button_choice: nil,
    big_text: "",
    status: []
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
    # initialize auto buttons
    initial_auto_buttons = if Map.has_key?(rules, "auto_buttons") do
        Enum.map(rules["auto_buttons"], fn {name, auto_button} -> {name, auto_button["enabled_at_start"]} end) |> Enum.reverse
      else
        []
      end

    wall = Enum.map(rules["wall"], &Riichi.to_tile(&1))
    wall = Enum.shuffle(wall)
    wall = List.insert_at(wall, 52, :"2p")
    # wall = List.insert_at(wall, 53, :"1z")
    hands = %{:east  => Riichi.sort_tiles([:"1m", :"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m", :"9m", :"8p", :"8p", :"3p", :"4p"]),
              :south => Riichi.sort_tiles([:"1z", :"1z", :"6z", :"7z", :"2z", :"2z", :"3z", :"3z", :"3z", :"4z", :"4z", :"4z", :"5z"]),
              # :south => Riichi.sort_tiles([:"1m", :"2m", :"3p", :"9p", :"1s", :"9s", :"1z", :"2z", :"3z", :"4z", :"5z", :"6z", :"7z"]),
              # :west  => Riichi.sort_tiles([:"1m", :"2m", :"3m", :"2p", :"0s", :"5s", :"5s", :"5s", :"5s", :"1z", :"1z", :"1z", :"1z"]),
              :west  => Riichi.sort_tiles([:"1z", :"1z", :"6z", :"7z", :"2z", :"2z", :"3z", :"3z", :"3z", :"4z", :"4z", :"4z", :"5z"]),
              :north => Riichi.sort_tiles([:"1m", :"2m", :"2m", :"5m", :"5m", :"7m", :"7m", :"9m", :"9m", :"1z", :"1z", :"2z", :"3z"])}
    # hands = %{:east  => Enum.slice(wall, 0..12),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    update_state(&Map.put(&1, :wall, wall))

    dirs = [:east, :south, :west, :north]
    update_state(&Map.put(&1, :players, Map.new(dirs, fn seat -> {seat, %Player{hand: hands[seat], auto_buttons: initial_auto_buttons}} end)))
    update_state(&Map.put(&1, :wall_index, 52))
    update_state(&Map.put(&1, :turn, nil))
    update_state(&Map.put(&1, :last_action, %{seat: nil, action: nil}))
    update_state(&Map.put(&1, :reversed_turn_order, false))
    update_state(&Map.put(&1, :paused, false))
    update_state(&Map.put(&1, :winner, nil))
    update_state(&Map.put(&1, :actions_cv, 0)) # condition variable

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
      state[:east] == nil  || is_pid(state[:east])  -> :east
      state[:south] == nil || is_pid(state[:south]) -> :south
      state[:west] == nil  || is_pid(state[:west])  -> :west
      state[:north] == nil || is_pid(state[:north]) -> :north
      true                                          -> :spectator
    end

    # if we're joining as east, restart the game
    if seat == :east do
      Enum.each([:east, :south, :west, :north], fn dir ->
        if is_pid(state[dir]) do
          IO.puts("Stopping AI for #{dir}: #{inspect(state[dir])}")
          DynamicSupervisor.terminate_child(RiichiAdvanced.AISupervisor, state[dir])
          update_state(&Map.put(&1, dir, nil))
        end
      end)
      initialize_game()
    else
      # if we're replacing an ai, shutdown the ai
      if is_pid(state[seat]) do
        IO.puts("Stopping AI for #{seat}: #{inspect(state[seat])}")
        DynamicSupervisor.terminate_child(RiichiAdvanced.AISupervisor, state[seat])
        update_state(&Map.put(&1, seat, nil))
      end
    end

    update_state(&Map.put(&1, seat, socket.id))
    GenServer.call(RiichiAdvanced.ExitMonitor, {:new_player, socket.root_pid, fn -> delete_player(seat) end})
    IO.puts("Player #{socket.id} joined as #{seat}")


    # for players with no seats, initialize an ai
    fill_empty_seats_with_ai()

    get_player(seat)
  end
  
  def get_player(seat) do
    state = get_state()
    [state.turn, state.players] ++ Utils.rotate_4([:east, :south, :west, :north], seat)
  end
  
  def delete_player(seat) do
    update_state(&Map.put(&1, seat, nil))
    IO.puts("#{seat} player exited")
    fill_empty_seats_with_ai()
  end

  def fill_empty_seats_with_ai do
    state = get_state()
    Enum.each([:east, :south, :west, :north], fn dir ->
      if state[dir] == nil do
        {:ok, ai_pid} = DynamicSupervisor.start_child(RiichiAdvanced.AISupervisor, {RiichiAdvanced.AIPlayer, %{seat: dir, player: state.players[dir]}})
        IO.puts("Starting AI for #{dir}: #{inspect(ai_pid)}")
        update_state(&Map.put(&1, dir, ai_pid))
      end
    end)
  end

  def temp_disable_play_tile(seat) do
    update_state(&Map.update!(&1, :play_tile_debounce, fn dbs -> Map.put(dbs, seat, true) end))
    Debounce.apply(Agent.get(__MODULE__, & &1.play_tile_debouncers[seat]))
  end

  def temp_display_big_text(seat, text) do
    update_player(seat, fn player -> %Player{ player | big_text: text } end )
    Debounce.apply(Agent.get(__MODULE__, & &1.big_text_debouncers[seat]))
  end

  def is_playable(seat, tile, tile_source) do
    state = get_state()
    Enum.all?(state.rules["play_restrictions"], fn [tile_spec, cond_spec] ->
      not Riichi.tile_matches(tile_spec, %{tile: tile}) || check_cnf_condition(cond_spec, %{seat: seat, tile: tile, tile_source: tile_source})
    end)
  end

  def play_tile(seat, tile, index) do
    state = get_state()
    tile_source = if index < length(state.players[seat].hand) do :hand else :draw end
    if is_playable(seat, tile, tile_source) do
      # assume we're skipping our button choices
      update_player(seat, fn player -> %Player{ player | buttons: %{}, call_buttons: %{}, call_name: "", deferred_actions: [] } end)
      if state.play_tile_debounce[seat] != true && no_buttons_remaining?() do
        temp_disable_play_tile(seat)
        # IO.puts("#{seat} played tile: #{inspect(tile)} at index #{index}")
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
                 hand: player.hand ++ player.draw,
                 draw: [tile]
               }
      end)
      update_state(&Map.update!(&1, :wall_index, fn ix -> ix + 1 end))
      update_action(seat, :draw, %{tile: tile})

      # IO.puts("wall index is now #{get_state().wall_index}")
      draw_tile(seat, num - 1)
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
    # get previous turn
    state = get_state()
    prev_turn = state.turn

    # change turn
    update_state(&Map.put(&1, :turn, seat))

    state = get_state()
    if state.winner == nil do
      # run on turn change, unless this turn change was triggered by an action
      state = get_state()
      if not via_action && seat != prev_turn && Map.has_key?(state.rules, "on_turn_change") do
        run_actions(state.rules["on_turn_change"]["actions"], %{seat: seat})
      end

      # TODO figure out where in control flow to run this
      # # check if any tiles are playable for this next player
      # state = get_state()
      # if Map.has_key?(state.rules, "on_no_valid_tiles") do
      #   if not Enum.any?(state.players[seat].hand ++ state.players[seat].draw, fn tile -> is_playable(seat, tile) end) do
      #     schedule_actions(seat, state.rules["on_no_valid_tiles"]["actions"])
      #   end
      # end
    end
  end

  def advance_turn do
    # this action is called after playing a tile
    # it should trigger next-turn effects, so don't mark the turn change as via_action
    state = get_state()
    change_turn(if state.reversed_turn_order do Utils.prev_turn(state.turn) else Utils.next_turn(state.turn) end)
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
        nored = Riichi.normalize_red_five(called_tile)
        [{:"1x", false}, {if red in call_choice do red else called_tile end, false}, {nored, false}, {:"1x", false}]
    end
    case call_source do
      :discards -> update_player(state.turn, fn player -> %Player{ player | pond: Enum.drop(player.pond, -1) } end)
      :hand     -> update_player(seat, fn player -> %Player{ player | hand: (player.hand ++ player.draw) -- [called_tile], draw: [] } end)
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
    IO.inspect({call_name, call, List.insert_at(call, 1, {called_tile, true})})
    upgraded_call = {call_name, List.insert_at(call, 1, {called_tile, true})}
    update_player(seat, fn player -> %Player{ player | hand: (player.hand ++ player.draw) -- [called_tile], draw: [], calls: List.replace_at(state.players[seat].calls, index, upgraded_call) } end)
    update_action(seat, :call,  %{from: state.turn, called_tile: called_tile, other_tiles: call_choice, call_name: call_name})
    update_player(seat, fn player -> %Player{ player | call_buttons: %{}, call_name: "" } end)
  end

  def get_yaku(seat, winning_tile, win_source) do
    state = get_state();
    context = %{
      seat: seat,
      winning_tile: winning_tile,
      win_source: win_source
    }
    state.rules["yaku"]
      |> Enum.filter(fn {_id, %{"display_name" => _name, "value" => _value, "when" => cond_spec}} -> check_cnf_condition(cond_spec, context) end)
      |> Enum.map(fn {_id, %{"display_name" => name, "value" => value, "when" => _cond_spec}} -> {name, value} end)
      |> Enum.reverse
  end

  def win(seat, winning_tile, win_source) do
    state = get_state();
    yaku = get_yaku(seat, winning_tile, win_source)
    # IO.puts("won by #{win_source}; yaku: #{inspect(yaku)}")
    winner_data = %{
      player: state.players[seat],
      yaku: yaku,
      winning_tile: winning_tile,
    }
    update_state(&Map.put(&1, :winner, winner_data))
  end

  def unpause(context) do
    update_state(&Map.put(&1, :paused, false))
    run_deferred_actions(context)
  end

  def recalculate_buttons do
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
  end

  def notify_ai_call_buttons(seat) do
    state = get_state()
    if state.winner == nil do
      call_choices = state.players[seat].call_buttons
      if is_pid(state[seat]) && not Enum.empty?(call_choices) && not Enum.empty?(call_choices |> Map.values() |> Enum.concat()) do
        IO.puts("Notifying #{seat} AI about their call buttons: #{inspect(state.players[seat].call_buttons)}")
        send(state[seat], {:call_buttons, %{player: state.players[seat]}})
      end
    end
  end

  def notify_ai do
    state = get_state()
    if state.initialized && state.winner == nil do
      # if there are any new buttons for any AI players, notify them
      # otherwise, just tell the current player it's their turn
      if no_buttons_remaining?() do
        if is_pid(state[state.turn]) do
          IO.puts("Notifying #{state.turn} AI that it's their turn")
          send(state[state.turn], {:your_turn, %{player: state.players[state.turn]}})
        end
      else
        Enum.each([:east, :south, :west, :north], fn seat ->
          has_buttons = not Enum.empty?(state.players[seat].buttons)
          if is_pid(state[seat]) && has_buttons do
            IO.puts("Notifying #{seat} AI about their buttons: #{inspect(state.players[seat].buttons)}")
            send(state[seat], {:buttons, %{player: state.players[seat]}})
          end
        end)
      end
    end
  end

  # trigger auto buttons actions for players
  def trigger_auto_buttons do
    state = get_state()
    Enum.each([:east, :south, :west, :north], fn seat ->
      if not is_pid(state[seat]) do
        Enum.each(state.players[seat].auto_buttons, fn {auto_button_name, enabled} ->
          trigger_auto_button(seat, auto_button_name, enabled)
        end)
      end
    end)
  end

  def run_deferred_actions(context) do
    state = get_state()
    actions = state.players[context.seat].deferred_actions
    if not Enum.empty?(actions) do
      IO.puts("Running deferred actions #{inspect(actions)} in context #{inspect(context)}")
      run_actions(actions, context)
      update_player(context.seat, fn player -> %{ player | deferred_actions: [] } end)
    end
  end

  def run_actions(actions, context \\ %{}) do
    update_state(&Map.update!(&1, :actions_cv, fn cv -> cv + 1 end))
    state = get_state()
    if (actions |> Enum.at(0) |> Enum.at(0)) not in ["when", "sort_hand", "unset_status"] do
      IO.puts("Running actions #{inspect(actions)} in context #{inspect(context)}; cv = #{state.actions_cv}")
    end
    # IO.inspect(Process.info(self(), :current_stacktrace))
    if not state.paused and state.winner == nil do
      # IO.puts("Running actions in context #{inspect(context)}: #{inspect(actions)}}")
      buttons_before = Enum.map(state.players, fn {seat, player} -> {seat, player.buttons} end)
      deferred_actions = Enum.drop_while(actions, fn [action | opts] ->
        case action do
          "play_tile"          -> play_tile(context.seat, Enum.at(opts, 0, :"1m"), Enum.at(opts, 1, 0))
          "draw"               -> draw_tile(context.seat, Enum.at(opts, 0, 1))
          "discard_draw"       -> run_actions([["play_tile", Enum.at(state.players[context.seat].draw, 0), length(state.players[context.seat].hand)], ["advance_turn"]], context)
          "reverse_turn_order" -> update_state(&Map.update!(&1, :reversed_turn_order, fn flag -> not flag end))
          "call"               -> trigger_call(context.seat, context.call_name, context.call_choice, context.called_tile, :discards)
          "self_call"          -> trigger_call(context.seat, context.call_name, context.call_choice, context.called_tile, :hand)
          "upgrade_call"       -> upgrade_call(context.seat, context.call_name, context.call_choice, context.called_tile)
          "advance_turn"       -> advance_turn()
          "change_turn"        -> change_turn(Utils.get_seat(context.seat, String.to_atom(Enum.at(opts, 0, "self"))), true)
          "win_by_discard"     -> win(context.seat, get_last_action().tile, :discard)
          "win_by_call"        -> win(context.seat, get_last_action().called_tile, :call)
          "win_by_draw"        -> win(context.seat, state.players[context.seat].draw, :draw)
          "set_status"         -> update_player(context.seat, fn player -> %Player{ player | status: player.status ++ opts } end)
          "unset_status"       -> update_player(context.seat, fn player -> %Player{ player | status: player.status -- opts } end)
          "big_text"           -> temp_display_big_text(context.seat, Enum.at(opts, 0, ""))
          "pause"              -> update_state(&Map.put(&1, :paused, true))
          "sort_hand"          -> update_player(context.seat, fn player -> %Player{ player | hand: Riichi.sort_tiles(player.hand) } end)
          "press_button"       -> press_button(context.seat, Enum.at(opts, 0, "skip"))
          "when"               -> check_cnf_condition(Enum.at(opts, 0, []), context) && run_actions(Enum.at(opts, 1, []), context)
          _                    -> IO.puts("Unhandled action #{action}")
        end
        if action == "pause" do
          # schedule an unpause after the given delay
          :timer.apply_after(Enum.at(opts, 0, 1500), RiichiAdvanced.GlobalState, :unpause, [context])
          # return false to defer future actions
          false
        else
          # if our action updates state, then we need to recalculate buttons
          # this is so other players can react to certain actions
          if action not in ["big_text", "pause"] do
            state = get_state()
            if state.winner != nil do
              # if there's a winner, never display buttons
              update_all_players(fn _seat, player -> %Player{ player | buttons: [] } end)
            else
              recalculate_buttons()
            end
            # if buttons changed, stop evaluating actions here
            buttons_after = Enum.map(state.players, fn {seat, player} -> {seat, player.buttons} end)
            (buttons_before == buttons_after) || no_buttons_remaining?()
          else
            true
          end
        end
      end)

      # defer the remaining actions
      # dropwhile keeps the action that we stop on, so we need to drop the first one
      deferred_actions = Enum.drop(deferred_actions, 1)
      if not Enum.empty?(deferred_actions) do
        IO.puts("Deferred actions for seat #{context.seat} due to existing buttons: #{inspect(deferred_actions)}")
        schedule_actions(context.seat, deferred_actions)
      end
    end
    update_state(&Map.update!(&1, :actions_cv, fn cv -> cv - 1 end))
    state = get_state()
    if state.actions_cv == 0 do
      notify_ai()
      trigger_auto_buttons()
    end
  end

  defp schedule_actions(seat, actions) do
    update_player(seat, fn player -> %{ player | deferred_actions: player.deferred_actions ++ actions } end)
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
    negated = String.starts_with?(cond_spec, "not_")
    cond_spec = if negated do String.slice(cond_spec, 4..-1//1) else cond_spec end
    result = case cond_spec do
      "our_turn"                 -> state.turn == context.seat
      "our_turn_is_next"         -> state.turn == if state.reversed_turn_order do Utils.next_turn(context.seat) else Utils.prev_turn(context.seat) end
      "our_turn_is_not_next"     -> state.turn != if state.reversed_turn_order do Utils.next_turn(context.seat) else Utils.prev_turn(context.seat) end
      "our_turn_is_prev"         -> state.turn == if state.reversed_turn_order do Utils.prev_turn(context.seat) else Utils.next_turn(context.seat) end
      "our_turn_is_not_prev"     -> state.turn != if state.reversed_turn_order do Utils.prev_turn(context.seat) else Utils.next_turn(context.seat) end
      "game_start"               -> get_last_action().action == nil
      "kamicha_discarded"        -> get_last_action().action == :discard && get_last_action().seat == state.turn && state.turn == Utils.prev_turn(context.seat)
      "someone_else_discarded"   -> get_last_action().action == :discard && get_last_action().seat == state.turn && state.turn != context.seat
      "just_called"              -> get_last_action().action == :call
      "call_available"           -> get_last_action().action == :discard && Riichi.can_call?(context.calls_spec, state.players[context.seat].hand, [get_last_action().tile])
      "self_call_available"      -> Riichi.can_call?(context.calls_spec, state.players[context.seat].hand ++ state.players[context.seat].draw)
      "hand_matches_hand"        -> Enum.any?(opts, fn name -> Riichi.check_hand(state.players[context.seat].hand ++ state.players[context.seat].draw, get_hand_definition(name <> "_definition"), String.to_atom(name)) end)
      "discard_matches_hand"     -> get_last_action().action == :discard && Enum.any?(opts, fn name -> Riichi.check_hand(state.players[context.seat].hand ++ [get_last_action().tile], get_hand_definition(name <> "_definition"), String.to_atom(name)) end)
      "call_matches_hand"        -> get_last_action().action == :call && get_last_action().call_name == Enum.at(opts, 0, "kakan") && Enum.any?(Enum.at(opts, 1, []), fn name -> Riichi.check_hand(state.players[context.seat].hand ++ [get_last_action().called_tile], get_hand_definition(name <> "_definition"), String.to_atom(name)) end)
      "last_discard_matches"     -> get_last_action().action == :discard && Riichi.tile_matches(opts, %{tile: context.tile, tile2: get_last_action().tile})
      "last_called_tile_matches" -> get_last_action().action == :call && Riichi.tile_matches(opts, %{tile: context.tile, tile2: get_last_action().called_tile})
      "unneeded_for_hand"        -> Enum.any?(opts, fn name -> Riichi.not_needed_for_hand(state.players[context.seat].hand ++ state.players[context.seat].draw, context.tile, get_hand_definition(name <> "_definition")) end)
      "can_upgrade_call"         -> state.players[context.seat].calls
        |> Enum.filter(fn {name, _call} -> name == context.upgrade_name end)
        |> Enum.any?(fn {_name, call} ->
          call_tiles = Enum.map(call, fn {tile, _sideways} -> tile end)
          Riichi.can_call?(context.calls_spec, call_tiles, state.players[context.seat].hand ++ state.players[context.seat].draw)
        end)
      "has_draw"                 -> not Enum.empty?(state.players[context.seat].draw)
      "furiten"                  -> true
      "has_yaku"                 -> true
      "has_calls"                -> not Enum.empty?(state.players[context.seat].calls)
      "no_calls"                 -> Enum.empty?(state.players[context.seat].calls)
      "has_call_named"           -> Enum.all?(state.players[context.seat].calls, fn {name, _call} -> name in opts end)
      "has_no_call_named"        -> Enum.all?(state.players[context.seat].calls, fn {name, _call} -> name not in opts end)
      "won_by_call"              -> context.win_source == :call
      "won_by_draw"              -> context.win_source == :draw
      "won_by_discard"           -> context.win_source == :discard
      "status"                   -> Enum.all?(opts, fn st -> st in state.players[context.seat].status end)
      "status_missing"           -> Enum.all?(opts, fn st -> st not in state.players[context.seat].status end)
      "is_drawn_tile"            -> context.tile_source == :draw
      "buttons_include"          -> Enum.all?(opts, fn button_name -> button_name in state.players[context.seat].buttons end)
      "buttons_exclude"          -> Enum.all?(opts, fn button_name -> button_name not in state.players[context.seat].buttons end)
      _                          ->
        IO.puts "Unhandled condition #{inspect(cond_spec)}"
        false
    end
    # IO.puts("#{inspect(context)}, #{inspect(cond_spec)} => #{result}")
    if negated do not result else result end
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

  def get_auto_button_display_name(button_name) do
    get_state().rules["auto_buttons"][button_name]["display_name"]
  end

  def adjudicate_buttons() do
    lock = Mutex.await(RiichiAdvanced.GlobalStateMutex, __MODULE__)
    # IO.puts("Lock obtained")
    superceded_buttons = get_superceded_buttons()
    state = get_state()
    Enum.each(state.players, fn {seat, player} ->
      button_name = player.button_choice
      # only trigger buttons that aren't overridden
      if button_name != nil && button_name != "skip" && not Enum.member?(superceded_buttons, button_name) do
        actions = state.rules["buttons"][button_name]["actions"]
        # check if a call action exists, in the case that multiple call choices are available
        call_action_exists = ["call"] in actions || ["self_call"] in actions || ["upgrade_call"] in actions
        if not call_action_exists do
          # just run all button actions as normal
          run_actions(actions, %{seat: seat})
        else
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
              callable_tiles = if ["call"] in actions do Enum.take(state.players[state.turn].pond, -1) else [] end
              Riichi.make_calls(state.rules["buttons"][button_name]["call"], state.players[seat].hand ++ state.players[seat].draw, callable_tiles)
            end
          flattened_call_choices = call_choices |> Map.values() |> Enum.concat()
          if length(flattened_call_choices) == 1 do
            # if there's only one choice, automatically choose it
            {called_tile, [call_choice]} = Enum.max_by(call_choices, fn {_tile, choices} -> length(choices) end)
            run_actions(actions, %{seat: seat, call_name: button_name, call_choice: call_choice, called_tile: called_tile})
          else
            # otherwise, defer all actions and display call choices
            update_player(seat, fn player -> %Player{ player | deferred_actions: actions, call_buttons: call_choices, call_name: button_name } end)
          end
        end
      end
    end)
    Mutex.release(RiichiAdvanced.GlobalStateMutex, lock)
    # IO.puts("Lock released")
  end

  def press_button(seat, button_name) do
    state = get_state()
    if Enum.member?(state.players[seat].buttons, button_name) do
      # hide all buttons and mark button pressed
      update_player(seat, fn player -> %Player{ player | buttons: [], button_choice: button_name } end)

      # if nobody else needs to make choices, trigger actions on all buttons that aren't superceded by precedence
      if no_buttons_remaining?() do
        adjudicate_buttons()

        # unmark all buttons pressed
        update_all_players(fn _seat, player -> %Player{ player | button_choice: nil } end)

        # if no call choices are pending, trigger everyone's deferred actions
        state = get_state()
        if Enum.all?(state.players, fn {_seat, player} -> Enum.empty?(player.call_buttons) end) do
          Enum.each([:east, :south, :west, :north], fn dir ->
            run_deferred_actions(%{seat: dir})
          end)
        else
          # otherwise, check if our AI needs notifying about their call buttons
          notify_ai_call_buttons(seat)
        end
      end
    end
  end

  def toggle_auto_button(seat, auto_button_name, enabled) do
    # Keyword.put screws up ordering, so we need to use Enum.map
    update_player(seat, fn player -> %Player{ player | auto_buttons: Enum.map(player.auto_buttons, fn {name, on} ->
      if auto_button_name == name do {name, enabled} else {name, on} end
    end) } end)
    trigger_auto_button(seat, auto_button_name, enabled)
  end

  def trigger_auto_button(seat, auto_button_name, enabled) do
    if enabled do
      state = get_state()
      # temporarily save deferred actions so we don't trigger them
      deferred_actions = state.players[seat].deferred_actions
      update_player(seat, fn player -> %Player{ player | deferred_actions: [] } end)
      # increment cv so we don't trigger notify_ai
      update_state(&Map.update!(&1, :actions_cv, fn cv -> cv + 1 end))
      run_actions(state.rules["auto_buttons"][auto_button_name]["actions"], %{seat: seat})
      update_state(&Map.update!(&1, :actions_cv, fn cv -> cv - 1 end))
      # restore deferred actions
      update_player(seat, fn player -> %Player{ player | deferred_actions: deferred_actions } end)

      # now notify ai if needed (e.g. turn changed to an ai player, or buttons exist for ai players)
      state = get_state()
      if is_pid(state[state.turn]) || Enum.any?(state.players, fn {seat, player} -> is_pid(state[seat]) && not Enum.empty?(player.buttons) end) do
        notify_ai()
      end
    end
  end
end
