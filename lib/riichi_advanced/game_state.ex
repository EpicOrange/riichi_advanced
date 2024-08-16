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

defmodule RiichiAdvanced.GameState do
  use GenServer

  def start_link(_initial_data) do
    play_tile_debounce = %{:east => false, :south => false, :west => false, :north => false}
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
    GenServer.start_link(__MODULE__, %{
      initialized: false,
      play_tile_debounce: play_tile_debounce,
      play_tile_debouncers: play_tile_debouncers,
      big_text_debouncers: big_text_debouncers
    }, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def initialize_game(state) do
    rules = Jason.decode!(File.read!(Application.app_dir(:riichi_advanced, "priv/static/riichi.json")))
    state = Map.put(state, :rules, rules)
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
    state
     |> Map.put(:wall, wall)
     |> Map.put(:players, Map.new([:east, :south, :west, :north], fn seat -> {seat, %Player{ hand: hands[seat], auto_buttons: initial_auto_buttons }} end))
     |> Map.put(:turn, :east)
     |> Map.put(:wall_index, 52)
     |> Map.put(:turn, nil)
     |> Map.put(:last_action, %{seat: nil, action: nil})
     |> Map.put(:reversed_turn_order, false)
     |> Map.put(:paused, false)
     |> Map.put(:winner, nil)
     |> Map.put(:actions_cv, 0) # condition variable
     |> Map.put(:initialized, true)
  end

  def update_player(state, seat, fun), do: Map.update!(state, :players, &Map.update!(&1, seat, fun))
  def update_all_players(state, fun), do: Map.update!(state, :players, &Map.new(&1, fn {seat, player} -> {seat, fun.(seat, player)} end))
  
  def get_last_action(state), do: state.last_action
  def update_action(state, seat, action, opts \\ %{}), do: Map.put(state, :last_action, opts |> Map.put(:seat, seat) |> Map.put(:action, action))

  defp fill_empty_seats_with_ai(state) do
    for dir <- [:east, :south, :west, :north], state[dir] == nil, reduce: state do
      state ->
        {:ok, ai_pid} = DynamicSupervisor.start_child(RiichiAdvanced.AISupervisor, {RiichiAdvanced.AIPlayer, %{seat: dir, player: state.players[dir]}})
        IO.puts("Starting AI for #{dir}: #{inspect(ai_pid)}")
        Map.put(state, dir, ai_pid)
    end
  end

  defp temp_disable_play_tile(state, seat) do
    state = Map.update!(state, :play_tile_debounce, &Map.put(&1, seat, true))
    Debounce.apply(state.play_tile_debouncers[seat])
    state
  end

  defp temp_display_big_text(state, seat, text) do
    state = update_player(state, seat, &%Player{ &1 | big_text: text })
    Debounce.apply(state.big_text_debouncers[seat])
    state
  end

  defp is_playable(state, seat, tile, tile_source) do
    Enum.all?(state.rules["play_restrictions"], fn [tile_spec, cond_spec] ->
      not Riichi.tile_matches(tile_spec, %{tile: tile}) || check_cnf_condition(state, cond_spec, %{seat: seat, tile: tile, tile_source: tile_source})
    end)
  end

  defp play_tile(state, seat, tile, index) do
    tile_source = if index < length(state.players[seat].hand) do :hand else :draw end
    if is_playable(state, seat, tile, tile_source) && state.play_tile_debounce[seat] == false do
      # assume we're skipping our button choices
      state = update_player(state, seat, &%Player{ &1 | buttons: %{}, call_buttons: %{}, call_name: "", deferred_actions: [] })
      if no_buttons_remaining?(state) do
        state = temp_disable_play_tile(state, seat)
        # IO.puts("#{seat} played tile: #{inspect(tile)} at index #{index}")
        state = update_player(state, seat, &%Player{ &1 |
          hand: List.delete_at(&1.hand ++ &1.draw, index),
          pond: &1.pond ++ [tile],
          draw: []
        })
        state = update_action(state, seat, :discard, %{tile: tile})
        RiichiAdvancedWeb.Endpoint.broadcast("game:main", "played_tile", %{"seat" => seat, "tile" => tile, "index" => index})

        # trigger play effects
        if Map.has_key?(state.rules, "play_effects") do
          for [tile_spec, actions] <- state.rules["play_effects"], Riichi.tile_matches([tile_spec], %{tile: tile}), reduce: state do
            state -> run_actions(state, actions, %{seat: seat})
          end
        else state end
      else state end
    else state end
  end

  defp _reindex_hand(hand, from, to) do
    {l1, [tile | r1]} = Enum.split(hand, from)
    {l2, r2} = Enum.split(l1 ++ r1, to)
    l2 ++ [tile] ++ r2
  end

  defp draw_tile(state, seat, num) do
    if num > 0 do
      tile = Enum.at(state.wall, state.wall_index)
      state = update_player(state, seat, &%Player{ &1 |
        hand: &1.hand ++ &1.draw,
        draw: [tile]
      })
      state = Map.update!(state, :wall_index, & &1 + 1)
      state = update_action(state, seat, :draw, %{tile: tile})

      # IO.puts("wall index is now #{get_state().wall_index}")
      draw_tile(state, seat, num - 1)
    else state end
  end

  # return all button names that have no effect due to other players' button choices
  defp get_superceded_buttons(state) do
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
  defp no_buttons_remaining?(state) do
    superceded_buttons = get_superceded_buttons(state)
    Enum.all?(state.players, fn {_seat, player} ->
      Enum.empty?(player.buttons) || Enum.all?(player.buttons, fn name -> Enum.member?(superceded_buttons, name) end)
    end)
  end

  defp change_turn(state, seat, via_action \\ false) do
    # get previous turn
    prev_turn = state.turn

    # change turn
    state = Map.put(state, :turn, seat)

    if state.winner == nil do
      # run on turn change, unless this turn change was triggered by an action
      state = if not via_action && seat != prev_turn && Map.has_key?(state.rules, "on_turn_change") do
        run_actions(state, state.rules["on_turn_change"]["actions"], %{seat: seat})
      else state end

      # TODO figure out where in control flow to run this
      # # check if any tiles are playable for this next player
      # state = get_state()
      # if Map.has_key?(state.rules, "on_no_valid_tiles") do
      #   if not Enum.any?(state.players[seat].hand ++ state.players[seat].draw, fn tile -> is_playable(seat, tile) end) do
      #     schedule_actions(seat, state.rules["on_no_valid_tiles"]["actions"])
      #   end
      # end

      state
    else state end
  end

  defp advance_turn(state) do
    # this action is called after playing a tile
    # it should trigger on_turn_change, so don't mark the turn change as via_action
    change_turn(state, if state.reversed_turn_order do Utils.prev_turn(state.turn) else Utils.next_turn(state.turn) end)
  end

  defp trigger_call(state, seat, call_name, call_choice, called_tile, call_source) do
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
    state = case call_source do
      :discards -> update_player(state, state.turn, &%Player{ &1 | pond: Enum.drop(&1.pond, -1) })
      :hand     -> update_player(state, seat, &%Player{ &1 | hand: (&1.hand ++ &1.draw) -- [called_tile], draw: [] })
      _         -> IO.puts("Unhandled call_source #{inspect(call_source)}")
    end
    state = update_player(state, seat, &%Player{ &1 | hand: &1.hand -- call_choice, calls: &1.calls ++ [{call_name, call}] })
    state = update_action(state, seat, :call,  %{from: state.turn, called_tile: called_tile, other_tiles: call_choice, call_name: call_name})
    state = update_player(state, seat, &%Player{ &1 | call_buttons: %{}, call_name: "" })
    # since we interrupted the player we called from, cancel their remaining actions
    state = update_player(state, state.turn, &%Player{ &1 | deferred_actions: [] })
    state
  end

  defp upgrade_call(state, seat, call_name, call_choice, called_tile) do
    # find the index of the call whose tiles match call_choice
    index = state.players[seat].calls
      |> Enum.map(fn {_name, call} -> Enum.map(call, fn {tile, _sideways} -> tile end) end)
      |> Enum.find_index(fn call_tiles -> Enum.sort(call_tiles) == Enum.sort(call_choice) end)
    # upgrade that call
    {_name, call} = Enum.at(state.players[seat].calls, index)
    IO.inspect({call_name, call, List.insert_at(call, 1, {called_tile, true})})
    upgraded_call = {call_name, List.insert_at(call, 1, {called_tile, true})}
    state = update_player(state, seat, &%Player{ &1 | hand: (&1.hand ++ &1.draw) -- [called_tile], draw: [], calls: List.replace_at(state.players[seat].calls, index, upgraded_call) })
    state = update_action(state, seat, :call,  %{from: state.turn, called_tile: called_tile, other_tiles: call_choice, call_name: call_name})
    state = update_player(state, seat, &%Player{ &1 | call_buttons: %{}, call_name: "" })
    state
  end

  defp get_yaku(state, seat, winning_tile, win_source) do
    context = %{
      seat: seat,
      winning_tile: winning_tile,
      win_source: win_source
    }
    state.rules["yaku"]
      |> Enum.filter(fn {_id, %{"display_name" => _name, "value" => _value, "when" => cond_spec}} -> check_cnf_condition(state, cond_spec, context) end)
      |> Enum.map(fn {_id, %{"display_name" => name, "value" => value, "when" => _cond_spec}} -> {name, value} end)
      |> Enum.reverse
  end

  defp win(state, seat, winning_tile, win_source) do
    yaku = get_yaku(state, seat, winning_tile, win_source)
    # IO.puts("won by #{win_source}; yaku: #{inspect(yaku)}")
    Map.put(state, :winner, %{
      player: state.players[seat],
      yaku: yaku,
      winning_tile: winning_tile,
    })
  end

  defp recalculate_buttons(state) do
    if Map.has_key?(state.rules, "buttons") do
      # IO.puts("Regenerating buttons...")
      # IO.inspect(Process.info(self(), :current_stacktrace))
      new_buttons = Map.new([:east, :south, :west, :north], fn seat ->
        buttons = state.rules["buttons"]
          |> Enum.filter(fn {_name, button} ->
               calls_spec = if Map.has_key?(button, "call") do button["call"] else [] end
               upgrades = if Map.has_key?(button, "upgrades") do button["upgrades"] else [] end
               check_cnf_condition(state, button["show_when"], %{seat: seat, calls_spec: calls_spec, upgrade_name: upgrades})
             end)
          |> Enum.map(fn {name, _button} -> name end)
        {seat, if not Enum.empty?(buttons) do buttons ++ ["skip"] else buttons end}
      end)
      # IO.puts("Updating buttons after action #{action}: #{inspect(new_buttons)}")
      update_all_players(state, fn seat, player -> %Player{ player | buttons: new_buttons[seat] } end)
    else state end
  end

  defp notify_ai_call_buttons(state, seat) do
    if state.winner == nil do
      call_choices = state.players[seat].call_buttons
      if is_pid(state[seat]) && not Enum.empty?(call_choices) && not Enum.empty?(call_choices |> Map.values() |> Enum.concat()) do
        IO.puts("Notifying #{seat} AI about their call buttons: #{inspect(state.players[seat].call_buttons)}")
        send(state[seat], {:call_buttons, %{player: state.players[seat]}})
      end
    end
  end

  defp notify_ai(state) do
    if state.initialized && state.winner == nil do
      # if there are any new buttons for any AI players, notify them
      # otherwise, just tell the current player it's their turn
      if no_buttons_remaining?(state) do
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
  defp trigger_auto_buttons(state) do
    for seat <- [:east, :south, :west, :north],
        not is_pid(state[seat]),
        {auto_button_name, enabled} <- state.players[seat].auto_buttons,
        reduce: state do
      state -> trigger_auto_button(state, seat, auto_button_name, enabled)
    end
  end

  defp _run_actions(state, [], _context), do: {state, []}
  defp _run_actions(state, [[action | opts] | actions], context) do
    buttons_before = Enum.map(state.players, fn {seat, player} -> {seat, player.buttons} end)
    state = case action do
      "play_tile"          -> play_tile(state, context.seat, Enum.at(opts, 0, :"1m"), Enum.at(opts, 1, 0))
      "draw"               -> draw_tile(state, context.seat, Enum.at(opts, 0, 1))
      "discard_draw"       -> run_actions(state, [["play_tile", Enum.at(state.players[context.seat].draw, 0), length(state.players[context.seat].hand)], ["advance_turn"]], context)
      "reverse_turn_order" -> Map.update!(state, :reversed_turn_order, &not &1)
      "call"               -> trigger_call(state, context.seat, context.call_name, context.call_choice, context.called_tile, :discards)
      "self_call"          -> trigger_call(state, context.seat, context.call_name, context.call_choice, context.called_tile, :hand)
      "upgrade_call"       -> upgrade_call(state, context.seat, context.call_name, context.call_choice, context.called_tile)
      "advance_turn"       -> advance_turn(state)
      "change_turn"        -> change_turn(state, Utils.get_seat(context.seat, String.to_atom(Enum.at(opts, 0, "self"))), true)
      "win_by_discard"     -> win(state, context.seat, get_last_action(state).tile, :discard)
      "win_by_call"        -> win(state, context.seat, get_last_action(state).called_tile, :call)
      "win_by_draw"        -> win(state, context.seat, state.players[context.seat].draw, :draw)
      "set_status"         -> update_player(state, context.seat, fn player -> %Player{ player | status: player.status ++ opts } end)
      "unset_status"       -> update_player(state, context.seat, fn player -> %Player{ player | status: player.status -- opts } end)
      "big_text"           -> temp_display_big_text(state, context.seat, Enum.at(opts, 0, ""))
      "pause"              -> Map.put(state, :paused, true)
      "sort_hand"          -> update_player(state, context.seat, fn player -> %Player{ player | hand: Riichi.sort_tiles(player.hand) } end)
      "press_button"       -> press_button(state, context.seat, Enum.at(opts, 0, "skip"))
      "when"               -> if check_cnf_condition(state, Enum.at(opts, 0, []), context) do run_actions(state, Enum.at(opts, 1, []), context) else state end
      _                    ->
        IO.puts("Unhandled action #{action}")
        state
    end
    if action == "pause" do
      # schedule an unpause after the given delay
      :timer.apply_after(Enum.at(opts, 0, 1500), GenServer, :cast, [RiichiAdvanced.GameState, {:unpause, context}])
      {state, actions}
    else
      # if our action updates state, then we need to recalculate buttons
      # this is so other players can react to certain actions
      if action not in ["big_text", "pause"] do
        state = if state.winner != nil do
          # if there's a winner, never display buttons
          update_all_players(state, fn _seat, player -> %Player{ player | buttons: [] } end)
        else
          recalculate_buttons(state)
        end
        buttons_after = Enum.map(state.players, fn {seat, player} -> {seat, player.buttons} end)
        if buttons_before == buttons_after || no_buttons_remaining?(state) do
          _run_actions(state, actions, context)
        else
          # if buttons changed, stop evaluating actions here
          {state, actions}
        end
      else
        _run_actions(state, actions, context)
      end
    end
  end
  defp _run_actions(state, [action | actions], context) do
    IO.puts("Unhandled action spec #{action}")
    _run_actions(state, actions, context)
  end

  def run_actions(state, actions, context \\ %{}) do
    state = Map.update!(state, :actions_cv, & &1 + 1)
    if (actions |> Enum.at(0) |> Enum.at(0)) not in ["when", "sort_hand", "unset_status"] do
      IO.puts("Running actions #{inspect(actions)} in context #{inspect(context)}; cv = #{state.actions_cv}")
    end
    # IO.inspect(Process.info(self(), :current_stacktrace))
    state = if not state.paused and state.winner == nil do
      # IO.puts("Running actions in context #{inspect(context)}: #{inspect(actions)}}")
      {state, deferred_actions} = _run_actions(state, actions, context)
      # defer the remaining actions
      if not Enum.empty?(deferred_actions) do
        buttons = Enum.map(state.players, fn {seat, player} -> {seat, player.buttons} end)
        IO.puts("Deferred actions for seat #{context.seat} due to pause or existing buttons: #{inspect(buttons)} / #{inspect(deferred_actions)}")
        schedule_actions(state, context.seat, deferred_actions)
      else state end
    else state end
    state = Map.update!(state, :actions_cv, & &1 - 1)
    if state.actions_cv == 0 do
      notify_ai(state)
      trigger_auto_buttons(state)
    else state end
  end

  defp run_deferred_actions(state, context) do
    actions = state.players[context.seat].deferred_actions
    if not Enum.empty?(actions) do
      IO.puts("Running deferred actions #{inspect(actions)} in context #{inspect(context)}")
      state = run_actions(state, actions, context)
      update_player(state, context.seat, &%Player{ &1 | deferred_actions: [] })
    else state end
  end

  defp schedule_actions(state, seat, actions) do
    update_player(state, seat, &%Player{ &1 | deferred_actions: &1.deferred_actions ++ actions })
  end

  defp translate_hand_definition(hand_definitions, set_definitions) do
    for hand_def <- hand_definitions do
      for [groups, num] <- hand_def do
        translated_groups = for group <- groups, do: (if Map.has_key?(set_definitions, group) do set_definitions[group] else group end)
        [translated_groups, num]
      end
    end
  end

  def get_hand_definition(state, name) do
    if Map.has_key?(state.rules, "set_definitions") do
      translate_hand_definition(state.rules[name], state.rules["set_definitions"])
    else
      state.rules[name]
    end
  end

  def check_condition(state, cond_spec, context \\ %{}, opts \\ []) do
    negated = String.starts_with?(cond_spec, "not_")
    cond_spec = if negated do String.slice(cond_spec, 4..-1//1) else cond_spec end
    last_action = get_last_action(state)
    result = case cond_spec do
      "our_turn"                 -> state.turn == context.seat
      "our_turn_is_next"         -> state.turn == if state.reversed_turn_order do Utils.next_turn(context.seat) else Utils.prev_turn(context.seat) end
      "our_turn_is_not_next"     -> state.turn != if state.reversed_turn_order do Utils.next_turn(context.seat) else Utils.prev_turn(context.seat) end
      "our_turn_is_prev"         -> state.turn == if state.reversed_turn_order do Utils.prev_turn(context.seat) else Utils.next_turn(context.seat) end
      "our_turn_is_not_prev"     -> state.turn != if state.reversed_turn_order do Utils.prev_turn(context.seat) else Utils.next_turn(context.seat) end
      "game_start"               -> last_action.action == nil
      "kamicha_discarded"        -> last_action.action == :discard && last_action.seat == state.turn && state.turn == Utils.prev_turn(context.seat)
      "someone_else_discarded"   -> last_action.action == :discard && last_action.seat == state.turn && state.turn != context.seat
      "just_called"              -> last_action.action == :call
      "call_available"           -> last_action.action == :discard && Riichi.can_call?(context.calls_spec, state.players[context.seat].hand, [last_action.tile])
      "self_call_available"      -> Riichi.can_call?(context.calls_spec, state.players[context.seat].hand ++ state.players[context.seat].draw)
      "hand_matches_hand"        -> Enum.any?(opts, fn name -> Riichi.check_hand(state.players[context.seat].hand ++ state.players[context.seat].draw, get_hand_definition(state, name <> "_definition"), String.to_atom(name)) end)
      "discard_matches_hand"     -> last_action.action == :discard && Enum.any?(opts, fn name -> Riichi.check_hand(state.players[context.seat].hand ++ [last_action.tile], get_hand_definition(state, name <> "_definition"), String.to_atom(name)) end)
      "call_matches_hand"        -> last_action.action == :call && last_action.call_name == Enum.at(opts, 0, "kakan") && Enum.any?(Enum.at(opts, 1, []), fn name -> Riichi.check_hand(state.players[context.seat].hand ++ [last_action.called_tile], get_hand_definition(state, name <> "_definition"), String.to_atom(name)) end)
      "last_discard_matches"     -> last_action.action == :discard && Riichi.tile_matches(opts, %{tile: context.tile, tile2: last_action.tile})
      "last_called_tile_matches" -> last_action.action == :call && Riichi.tile_matches(opts, %{tile: context.tile, tile2: last_action.called_tile})
      "unneeded_for_hand"        -> Enum.any?(opts, fn name -> Riichi.not_needed_for_hand(state.players[context.seat].hand ++ state.players[context.seat].draw, context.tile, get_hand_definition(state, name <> "_definition")) end)
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

  def check_dnf_condition(state, cond_spec, context \\ %{}) do
    cond do
      is_binary(cond_spec) -> check_condition(state, cond_spec, context)
      is_map(cond_spec)    -> check_condition(state, cond_spec["name"], context, cond_spec["opts"])
      is_list(cond_spec)   -> Enum.any?(cond_spec, &check_cnf_condition(state, &1, context))
      true                 ->
        IO.puts "Unhandled condition clause #{inspect(cond_spec)}"
        true
    end
  end

  def check_cnf_condition(state, cond_spec, context \\ %{}) do
    cond do
      is_binary(cond_spec) -> check_condition(state, cond_spec, context)
      is_map(cond_spec)    -> check_condition(state, cond_spec["name"], context, cond_spec["opts"])
      is_list(cond_spec)   -> Enum.all?(cond_spec, &check_dnf_condition(state, &1, context))
      true                 ->
        IO.puts "Unhandled condition clause #{inspect(cond_spec)}"
        true
    end
  end

  def adjudicate_buttons(state) do
    # lock = Mutex.await(RiichiAdvanced.GlobalStateMutex, __MODULE__)
    # IO.puts("Lock obtained")
    superceded_buttons = get_superceded_buttons(state)
    for {seat, player} <- state.players, reduce: state do
      state ->
        button_name = player.button_choice
        # only trigger buttons that aren't overridden
        if button_name != nil && button_name != "skip" && not Enum.member?(superceded_buttons, button_name) do
          actions = state.rules["buttons"][button_name]["actions"]
          # check if a call action exists, in the case that multiple call choices are available
          call_action_exists = ["call"] in actions || ["self_call"] in actions || ["upgrade_call"] in actions
          if not call_action_exists do
            # just run all button actions as normal
            run_actions(state, actions, %{seat: seat})
          else
            # if there is a call action, check if there are multiple call choices
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
              run_actions(state, actions, %{seat: seat, call_name: button_name, call_choice: call_choice, called_tile: called_tile})
            else
              # otherwise, defer all actions and display call choices
              update_player(state, seat, fn player -> %Player{ player | deferred_actions: actions, call_buttons: call_choices, call_name: button_name } end)
            end
          end
        else state end
      end
    # Mutex.release(RiichiAdvanced.GlobalStateMutex, lock)
    # IO.puts("Lock released")
  end

  def press_button(state, seat, button_name) do
    state = if Enum.member?(state.players[seat].buttons, button_name) do
      # hide all buttons and mark button pressed
      # also clear deferred actions, since we're running our actions now
      state = update_player(state, seat, fn player -> %Player{ player | buttons: [], button_choice: button_name, deferred_actions: [] } end)

      # if nobody else needs to make choices, trigger actions on all buttons that aren't superceded by precedence
      if no_buttons_remaining?(state) do
        state = adjudicate_buttons(state)

        # unmark all buttons pressed
        state = update_all_players(state, fn _seat, player -> %Player{ player | button_choice: nil } end)

        # if no call choices are pending, trigger everyone's deferred actions
        if Enum.all?(state.players, fn {_seat, player} -> Enum.empty?(player.call_buttons) end) do
          # for dir <- [:east, :south, :west, :north], reduce: state do
          #   state -> run_deferred_actions(state, %{seat: dir})
          # end
          state
        else
          # otherwise, check if our AI needs notifying about their call buttons
          notify_ai_call_buttons(state, seat)
          state
        end
      else state end
    else state end
    broadcast_state_change(state)
    state
  end

  def trigger_auto_button(state, seat, auto_button_name, enabled) do
    if enabled do
      # temporarily save deferred actions so we don't trigger them
      deferred_actions = state.players[seat].deferred_actions
      state = update_player(state, seat, fn player -> %Player{ player | deferred_actions: [] } end)
      # increment cv so we don't trigger notify_ai
      state = Map.update!(state, :actions_cv, & &1 + 1)
      state = run_actions(state, state.rules["auto_buttons"][auto_button_name]["actions"], %{seat: seat})
      state = Map.update!(state, :actions_cv, & &1 - 1)
      # restore deferred actions
      state = update_player(state, seat, fn player -> %Player{ player | deferred_actions: deferred_actions } end)

      # now notify ai if needed (e.g. turn changed to an ai player, or buttons exist for ai players)
      if is_pid(state[state.turn]) || Enum.any?(state.players, fn {seat, player} -> is_pid(state[seat]) && not Enum.empty?(player.buttons) end) do
        notify_ai(state)
      end
      state
    else state end
  end

  def broadcast_state_change(state) do
    if state.initialized == true do
      RiichiAdvancedWeb.Endpoint.broadcast("game:main", "state_updated", %{"state" => state})
    end
  end

  def handle_call({:new_player, socket}, _from, state) do
    seat = cond do
      state[:east] == nil  || is_pid(state[:east])  -> :east
      state[:south] == nil || is_pid(state[:south]) -> :south
      state[:west] == nil  || is_pid(state[:west])  -> :west
      state[:north] == nil || is_pid(state[:north]) -> :north
      true                                          -> :spectator
    end

    # if we're joining as east, restart the game
    state = if seat == :east do
      # clear the AIs
      state = for dir <- [:east, :south, :west, :north], is_pid(state[dir]), reduce: state do
        state ->
          IO.puts("Stopping AI for #{dir}: #{inspect(state[dir])}")
          DynamicSupervisor.terminate_child(RiichiAdvanced.AISupervisor, state[dir])
          Map.put(state, dir, nil)
      end
      state = initialize_game(state)
      state = change_turn(state, :east)
      state
    else state end

    # if we're replacing an ai, shutdown the ai
    state = if is_pid(state[seat]) do
      IO.puts("Stopping AI for #{seat}: #{inspect(state[seat])}")
      DynamicSupervisor.terminate_child(RiichiAdvanced.AISupervisor, state[seat])
      Map.put(state, seat, nil)
    else state end

    state = Map.put(state, seat, socket.id)
    GenServer.call(RiichiAdvanced.ExitMonitor, {:new_player, socket.root_pid, seat})
    IO.puts("Player #{socket.id} joined as #{seat}")

    # for players with no seats, initialize an ai
    state = fill_empty_seats_with_ai(state)

    broadcast_state_change(state)
    {:reply, [state.turn, state.players] ++ Utils.rotate_4([:east, :south, :west, :north], seat), state}
  end

  def handle_call({:delete_player, seat}, _from, state) do
    state = Map.put(state, seat, nil)
    IO.puts("#{seat} player exited")
    state = fill_empty_seats_with_ai(state)
    broadcast_state_change(state)
    {:reply, :ok, state}
  end

  def handle_call({:is_playable, seat, tile, tile_source}, _from, state), do: {:reply, is_playable(state, seat, tile, tile_source), state}
  def handle_call({:get_button_display_name, button_name}, _from, state), do: {:reply, if button_name == "skip" do "Skip" else state.rules["buttons"][button_name]["display_name"] end, state}
  def handle_call({:get_auto_button_display_name, button_name}, _from, state), do: {:reply, state.rules["auto_buttons"][button_name]["display_name"], state}
  
  # debugging only
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:reset_play_tile_debounce, seat}, state) do
    state = Map.update!(state, :play_tile_debounce, &Map.put(&1, seat, false))
    {:noreply, state}
  end
  def handle_cast({:reset_big_text, seat}, state) do
    state = update_player(state, seat, &Map.put(&1, :big_text, ""))
    broadcast_state_change(state)
    {:noreply, state}
  end
  def handle_cast({:unpause, context}, state) do
    state = Map.put(state, :paused, false)
    state = run_deferred_actions(state, context)
    broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast({:reindex_hand, seat, from, to}, state) do
    state = temp_disable_play_tile(state, seat)
    # IO.puts("#{seat} moved tile from #{from} to #{to}")
    state = update_player(state, seat, &%Player{ &1 | :hand => _reindex_hand(&1.hand, from, to) })
    broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast({:run_actions, actions, context}, state) do 
    state = run_actions(state, actions, context)
    broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast({:run_deferred_actions, context}, state) do 
    state = run_deferred_actions(state, context)
    broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast({:press_button, seat, button_name}, state) do
    state = press_button(state, seat, button_name)
    broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast({:toggle_auto_button, seat, auto_button_name, enabled}, state) do
    # Keyword.put screws up ordering, so we need to use Enum.map
    state = update_player(state, seat, fn player -> %Player{ player | auto_buttons: Enum.map(player.auto_buttons, fn {name, on} ->
      if auto_button_name == name do {name, enabled} else {name, on} end
    end) } end)
    state = trigger_auto_button(state, seat, auto_button_name, enabled)
    broadcast_state_change(state)
    {:noreply, state}
  end

  # clicking the compass will send this (debug use only)
  def handle_cast({:change_turn, seat}, state) do
    state = change_turn(state, seat)
    broadcast_state_change(state)
    {:noreply, state}
  end

end
