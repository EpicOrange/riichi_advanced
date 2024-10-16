
defmodule RiichiAdvanced.GameState.Actions do
  alias RiichiAdvanced.GameState.Buttons, as: Buttons
  alias RiichiAdvanced.GameState.Saki, as: Saki
  alias RiichiAdvanced.GameState.Marking, as: Marking
  alias RiichiAdvanced.GameState.Log, as: Log
  import RiichiAdvanced.GameState

  @debug_actions false

  def temp_disable_play_tile(state, seat) do
    state = Map.update!(state, :play_tile_debounce, &Map.put(&1, seat, true))
    Debounce.apply(state.play_tile_debouncers[seat])
    state
  end

  def temp_display_big_text(state, seat, text) do
    state = update_player(state, seat, &%Player{ &1 | big_text: text })
    Debounce.apply(state.big_text_debouncers[seat])
    state
  end

  def play_tile(state, seat, tile, index) do
    tile_source = if index < length(state.players[seat].hand) do :hand else :draw end
    if is_playable?(state, seat, tile, tile_source) do
      # IO.puts("#{seat} played tile: #{inspect(tile)} at index #{index}")
      
      tile = if "discard_facedown" in state.players[seat].status do :"1x" else tile end

      state = update_player(state, seat, &%Player{ &1 |
        hand: List.delete_at(&1.hand ++ &1.draw, index),
        pond: &1.pond ++ [tile],
        discards: &1.discards ++ [tile],
        draw: [],
        last_discard: {tile, index}
      })
      state = update_action(state, seat, :discard, %{tile: tile})
      state = push_message(state, [
        %{text: "Player #{seat} #{state.players[seat].nickname} discarded"},
        Utils.pt(tile)
      ])
      tsumogiri = index >= length(state.players[seat].hand)
      riichi = "just_reached" in state.players[seat].status
      state = Log.log(state, seat, :discard, %{tile: tile, tsumogiri: tsumogiri, riichi: riichi})

      click_sounds = [
        "/audio/tile1.mp3",
        "/audio/tile2.mp3",
        "/audio/tile3.mp3",
        "/audio/tile4.mp3",
        "/audio/tile5.mp3",
      ]
      play_sound(state, Enum.random(click_sounds))

      # check if it completes second row discards
      state = if Map.has_key?(state, :saki) do
        if length(state.players[seat].pond) == 1 && not state.saki.already_finished_second_row_discards do
          state = put_in(state.saki.just_finished_second_row_discards, true)
          state = put_in(state.saki.already_finished_second_row_discards, true)
          state
        else
          state = put_in(state.saki.just_finished_second_row_discards, false)
          state
        end
      else state end

      # trigger play effects
      if Map.has_key?(state.rules, "play_effects") do
        for [tile_spec, actions] <- state.rules["play_effects"], Riichi.tile_matches([tile_spec], %{tile: tile}), reduce: state do
          state -> run_actions(state, actions, %{seat: seat, tile: tile})
        end
      else state end
    else state end
  end

  def draw_tile(state, seat, num, tile_spec \\ nil) do
    if num > 0 do
      {tile_name, wall_index} = if tile_spec != nil do {tile_spec, state.wall_index} else {Enum.at(state.wall, state.wall_index), state.wall_index + 1} end
      if tile_name == nil do
        IO.puts("Tried to draw a nil tile!")
        state
      else
        state = if is_binary(tile_name) && List.keymember?(state.reserved_tiles, tile_name, 0) do
            Map.update!(state, :drawn_reserved_tiles, fn tiles -> [tile_name | tiles] end)
          else state end
        tile = from_tile_name(state, tile_name)
        state = update_player(state, seat, &%Player{ &1 |
          hand: &1.hand ++ &1.draw,
          draw: [tile]
        })
        state = Map.put(state, :wall_index, wall_index)
        state = update_action(state, seat, :draw, %{tile: tile})
        kan_draw = "kan" in state.players[seat].status
        state = Log.log(state, seat, :draw, %{tile: tile, kan_draw: kan_draw})

        # IO.puts("wall index is now #{get_state().wall_index}")
        draw_tile(state, seat, num - 1, tile_spec)
      end
    else state end
  end

  def run_on_no_valid_tiles(state, seat, gas \\ 100) do
    if gas > 0 do
      if not Enum.any?(state.players[seat].hand, fn tile -> is_playable?(state, seat, tile, :hand) end) &&
         not Enum.any?(state.players[seat].draw, fn tile -> is_playable?(state, seat, tile, :draw) end) do
        state = run_actions(state, state.rules["on_no_valid_tiles"]["actions"], %{seat: seat})
        if Map.has_key?(state.rules["on_no_valid_tiles"], "recurse") && state.rules["on_no_valid_tiles"]["recurse"] do
          run_on_no_valid_tiles(state, seat, gas - 1)
        else state end
      else state end
    else state end
  end

  def change_turn(state, seat, via_action \\ false) do
    # get previous turn
    prev_turn = state.turn

    # erase previous turn's deferred actions
    state = if prev_turn != nil do
      update_player(state, prev_turn, &%Player{ &1 | deferred_actions: [] })
    else state end

    # IO.puts("Changing turn from #{prev_turn} to #{seat}")

    # change turn
    state = Map.put(state, :turn, seat)

    if state.game_active do
      # run on turn change, unless this turn change was triggered by an action
      state = if not via_action && prev_turn != nil && seat != prev_turn && Map.has_key?(state.rules, "before_turn_change") do
        run_actions(state, state.rules["before_turn_change"]["actions"], %{seat: prev_turn})
      else state end
      state = if not via_action && seat != prev_turn && Map.has_key?(state.rules, "after_turn_change") do
        run_actions(state, state.rules["after_turn_change"]["actions"], %{seat: seat})
      else state end

      # check if any tiles are playable for this next player
      state = if Map.has_key?(state.rules, "on_no_valid_tiles") do
        run_on_no_valid_tiles(state, seat)
      else state end

      state
    else state end
  end

  def advance_turn(state) do
    # this action is called after playing a tile
    # it should trigger on_turn_change, so don't mark the turn change as via_action
    change_turn(state, if state.reversed_turn_order do Utils.prev_turn(state.turn) else Utils.next_turn(state.turn) end)
  end

  defp style_call(style, call_choice, called_tile) do
    if called_tile != nil do
      tiles = if "call" in style or "call_sideways" in style do call_choice else call_choice ++ [called_tile] end
      tiles = Utils.sort_tiles(tiles)
      for style_spec <- style, reduce: [] do
        acc ->
          tile = case style_spec do
            "call"                 -> {called_tile, false}
            "call_sideways"        -> {called_tile, true}
            ix when is_integer(ix) -> {Enum.at(tiles, ix), false}
            tile                   -> {Utils.to_tile(tile), false}
          end
          [tile | acc]
      end |> Enum.reverse()
    else
      Enum.map(call_choice, fn tile -> {tile, false} end)
    end
  end

  def trigger_call(state, seat, call_name, call_choice, called_tile, call_source) do
    call_style = if Map.has_key?(state.rules["buttons"][call_name], "call_style") do
        state.rules["buttons"][call_name]["call_style"]
      else Map.new(["self", "kamicha", "toimen", "shimocha"], fn dir -> {dir, 0..length(call_choice)} end) end

    # style the call
    # tiles = Enum.map(call_choice, fn t -> {t, false} end)
    call = if called_tile != nil do
      style = call_style[Atom.to_string(Utils.get_relative_seat(seat, state.turn))]
      style_call(style, Utils.strip_attrs(call_choice), Utils.strip_attrs(called_tile))
    else
      Enum.map(call_choice, fn tile -> {tile, false} end)
    end
    call = {call_name, call}
    state = if Map.has_key?(state.rules, "before_call") do
      run_actions(state, state.rules["before_call"]["actions"], %{seat: state.turn, callee: state.turn, caller: seat, call: call})
    else state end
    state = case call_source do
      :discards -> update_player(state, state.turn, &%Player{ &1 | pond: Enum.drop(&1.pond, -1) })
      :hand     ->
        new_hand = Riichi.try_remove_all_tiles(Utils.add_attr(state.players[seat].hand, ["hand"]) ++ Utils.add_attr(state.players[seat].draw, [:hand, :draw]), [called_tile])
        |> Enum.at(0)
        |> Utils.strip_attrs()
        update_player(state, seat, &%Player{ &1 | hand: new_hand, draw: [] })
      _         -> IO.puts("Unhandled call_source #{inspect(call_source)}")
    end
    new_hand = Riichi.try_remove_all_tiles(Utils.add_attr(state.players[seat].hand, ["hand"]), call_choice)
    new_hand = new_hand
    |> Enum.at(0)
    |> Utils.strip_attrs()
    state = update_player(state, seat, &%Player{ &1 | hand: new_hand, calls: &1.calls ++ [call] })
    state = update_action(state, seat, :call, %{from: state.turn, called_tile: called_tile, other_tiles: call_choice, call_name: call_name})
    state = if called_tile != nil do
      push_message(state, [
        %{text: "Player #{seat} #{state.players[seat].nickname} called "},
        %{bold: true, text: "#{call_name}"},
        %{text: " on "},
        Utils.pt(called_tile),
        %{text: " with "}
      ] ++ Utils.ph(call_choice))
    else
      push_message(state, [
        %{text: "Player #{seat} #{state.players[seat].nickname} called "},
        %{bold: true, text: "#{call_name}"},
        %{text: " on "}
      ] ++ Utils.ph(call_choice))
    end
    state = Log.add_call(state, seat, call_name, call_choice)
    click_sounds = [
      "/audio/call1.mp3",
      "/audio/call2.mp3",
      "/audio/call3.mp3",
      "/audio/call4.mp3",
      "/audio/call5.mp3",
    ]
    play_sound(state, Enum.random(click_sounds))
    state = update_player(state, seat, &%Player{ &1 | call_buttons: %{}, call_name: "" })
    state = if Map.has_key?(state.rules, "after_call") do
      run_actions(state, state.rules["after_call"]["actions"], %{seat: seat, callee: state.turn, caller: seat, call: call})
    else state end
    state
  end

  defp upgrade_call(state, seat, call_name, call_choice, called_tile) do
    # find the index of the call whose tiles match call_choice
    index = state.players[seat].calls
      |> Enum.map(fn {_name, call} -> Enum.map(call, fn {tile, _sideways} -> tile end) end)
      |> Enum.find_index(fn call_tiles -> Enum.sort(call_tiles) == Enum.sort(call_choice) end)
    # upgrade that call
    {_name, call} = Enum.at(state.players[seat].calls, index)

    # find the index of the sideways tile
    sideways_index = Enum.find_index(call, fn {_tile, sideways} -> sideways end)
    sideways_index = if sideways_index == nil do -1 else sideways_index end
    upgraded_call = {call_name, List.insert_at(call, sideways_index, {called_tile, true})}
    state = update_player(state, seat, &%Player{ &1 | hand: Riichi.try_remove_all_tiles(Utils.add_attr(&1.hand, ["hand"]) ++ Utils.add_attr(&1.draw, ["hand", "draw"]), [called_tile]), draw: [], calls: List.replace_at(state.players[seat].calls, index, upgraded_call) })
    state = update_action(state, seat, :call,  %{from: state.turn, called_tile: called_tile, other_tiles: call_choice, call_name: call_name})
    state = update_player(state, seat, &%Player{ &1 | call_buttons: %{}, call_name: "" })
    state
  end

  defp multiply_match_definitions(match_definitions, mult) do
    for match_definition <- match_definitions do
      for [groups, num] <- match_definition do
        [groups, if num < 0 do num else num * mult end]
      end
    end
  end

  defp binary_search_count_matches(state, seat, hand_calls, match_definitions, ordering, ordering_r, tile_aliases, l \\ -1, r \\ 1) do
    if l < r do
      m = if l == -1 do r else Integer.floor_div(l + r + 1, 2) end
      multiplied_match_def = multiply_match_definitions(match_definitions, m)
      matched = Enum.any?(hand_calls, fn {hand, calls} -> Riichi.match_hand(hand, calls, multiplied_match_def, ordering, ordering_r, tile_aliases) end)
      {l, r} = if matched do
        if l == -1 do {l, r * 2} else {m, r} end
      else
        if l == -1 do {0, r} else {l, m - 1} end
      end
      binary_search_count_matches(state, seat, hand_calls, match_definitions, ordering, ordering_r, tile_aliases, l, r)
    else l end 
  end

  defp interpret_amount(state, seat, amt_spec) do
    case amt_spec do
      ["count_matches" | opts] ->
        hand_calls = get_hand_calls_spec(state, %{seat: seat}, Enum.at(opts, 0, []))
        match_definitions = translate_match_definitions(state, Enum.at(opts, 1, []))
        ordering = state.players[seat].tile_ordering
        ordering_r = state.players[seat].tile_ordering_r
        tile_aliases = state.players[seat].tile_aliases
        binary_search_count_matches(state, seat, hand_calls, match_definitions, ordering, ordering_r, tile_aliases)
      _ when is_integer(amt_spec) -> amt_spec
    end
  end

  defp add_counter(state, seat, counter_name, amt_spec) do
    amount = interpret_amount(state, seat, amt_spec)
    new_ctr = amount + Map.get(state.players[seat].counters, counter_name, 0)
    state = put_in(state.players[seat].counters[counter_name], new_ctr)
    state
  end

  defp do_charleston(state, dir, seat, marked_objects) do
    if Enum.any?(state.players, fn {seat, _} -> Marking.needs_marking?(state, seat) end) do
      # defer until everyone is done marking
      actions = case dir do
        :kamicha -> [["charleston_left"]]
        :toimen -> [["charleston_across"]]
        :shimocha -> [["charleston_right"]]
      end
      schedule_actions(state, seat, actions)
    else
      {hand_tile1, hand_seat, hand_index1} = Enum.at(marked_objects.hand.marked, 0)
      {hand_tile2, _, hand_index2} = Enum.at(marked_objects.hand.marked, 1)
      {hand_tile3, _, hand_index3} = Enum.at(marked_objects.hand.marked, 2)
      hand_length = length(state.players[hand_seat].hand)
      # remove specified tiles from hand
      state = for ix <- Enum.sort([-hand_index1, -hand_index2, -hand_index3]), reduce: state do
        state ->
          ix = -ix
          if ix < hand_length do
            update_player(state, hand_seat, &%Player{ &1 | hand: List.delete_at(&1.hand, ix) })
          else
            update_player(state, hand_seat, &%Player{ &1 | draw: List.delete_at(&1.draw, ix - hand_length) })
          end
      end
      # send them according to dir
      state = update_player(state, Utils.get_seat(hand_seat, dir), &%Player{ &1 | hand: &1.hand ++ &1.draw, draw: [hand_tile1, hand_tile2, hand_tile3] })
      state = put_in(state.marking[seat].done, true)
      state
    end
  end

  defp translate_tile_alias(state, context, tile_alias) do
    ret = case tile_alias do
      "any" -> state.all_tiles
      "draw" -> state.players[context.seat].draw
      "last_discard" -> if get_last_discard_action(state) != nil do [get_last_discard_action(state).tile] else [] end
      [tile_alias | attrs] -> translate_tile_alias(state, context, tile_alias) |> Utils.add_attr(attrs)
      _      -> [Utils.to_tile(tile_alias)]
    end
    ret
  end

  defp _run_actions(state, [], _context), do: {state, []}
  defp _run_actions(state, [[action | opts] | actions], context) do
    buttons_before = Enum.map(state.players, fn {seat, player} -> {seat, player.buttons} end)
    marked_objects = state.marking[context.seat]
    state = case action do
      "noop"                  -> state
      "push_message"          -> push_message(state, Enum.map(["Player #{context.seat} #{state.players[context.seat].nickname}"] ++ opts, fn msg -> %{text: msg} end))
      "play_tile"             -> play_tile(state, context.seat, Enum.at(opts, 0, :"1m"), Enum.at(opts, 1, 0))
      "draw"                  -> draw_tile(state, context.seat, Enum.at(opts, 0, 1), Enum.at(opts, 1, nil))
      "call"                  -> trigger_call(state, context.seat, context.call_name, context.call_choice, context.called_tile, :discards)
      "self_call"             -> trigger_call(state, context.seat, context.call_name, context.call_choice, context.called_tile, :hand)
      "upgrade_call"          -> upgrade_call(state, context.seat, context.call_name, context.call_choice, context.called_tile)
      "flower"                -> trigger_call(state, context.seat, context.call_name, context.call_choice, nil, :hand)
      "draft_saki_card"       -> Saki.draft_saki_card(state, context.seat, context.choice)
      "reverse_turn_order"    -> Map.update!(state, :reversed_turn_order, &not &1)
      "advance_turn"          -> advance_turn(state)
      "change_turn"           -> 
        seat = case Enum.at(opts, 0, "self") do
          "east" -> Riichi.get_player_from_seat_wind(state.kyoku, :east)
          "south" -> Riichi.get_player_from_seat_wind(state.kyoku, :south)
          "west" -> Riichi.get_player_from_seat_wind(state.kyoku, :west)
          "north" -> Riichi.get_player_from_seat_wind(state.kyoku, :north)
          "shimocha" -> Utils.get_seat(context.seat, :shimocha)
          "toimen" -> Utils.get_seat(context.seat, :toimen)
          "kamicha" -> Utils.get_seat(context.seat, :kamicha)
          _ -> context.seat
        end
        change_turn(state, seat, true)
      "win_by_discard"        -> win(state, context.seat, get_last_discard_action(state).tile, :discard)
      "win_by_call"           -> win(state, context.seat, get_last_action(state).called_tile, :call)
      "win_by_draw"           -> win(state, context.seat, Enum.at(state.players[context.seat].draw, 0), :draw)
      "ryuukyoku"             -> exhaustive_draw(state)
      "abortive_draw"         -> abortive_draw(state, Enum.at(opts, 0, "Abortive draw"))
      "set_status"            -> update_player(state, context.seat, fn player -> %Player{ player | status: Enum.uniq(player.status ++ opts) } end)
      "unset_status"          -> update_player(state, context.seat, fn player -> %Player{ player | status: Enum.uniq(player.status -- opts) } end)
      "set_status_all"        -> update_all_players(state, fn _seat, player -> %Player{ player | status: Enum.uniq(player.status ++ opts) } end)
      "unset_status_all"      -> update_all_players(state, fn _seat, player -> %Player{ player | status: Enum.uniq(player.status -- opts) } end)
      "set_callee_status"     -> update_player(state, context.callee, fn player -> %Player{ player | status: Enum.uniq(player.status ++ opts) } end)
      "unset_callee_status"   -> update_player(state, context.callee, fn player -> %Player{ player | status: Enum.uniq(player.status -- opts) } end)
      "set_caller_status"     -> update_player(state, context.caller, fn player -> %Player{ player | status: Enum.uniq(player.status ++ opts) } end)
      "unset_caller_status"   -> update_player(state, context.caller, fn player -> %Player{ player | status: Enum.uniq(player.status -- opts) } end)
      "add_counter"           -> add_counter(state, context.seat, Enum.at(opts, 0, "counter"), Enum.drop(opts, 1))
      "big_text"              ->
        seat = case Enum.at(opts, 1) do
          "shimocha" -> Utils.get_seat(context.seat, :shimocha)
          "toimen" -> Utils.get_seat(context.seat, :toimen)
          "kamicha" -> Utils.get_seat(context.seat, :kamicha)
          "last_discarder" -> get_last_discard_action(state).seat
          _ -> context.seat
        end
        temp_display_big_text(state, seat, Enum.at(opts, 0, ""))
      "pause"                 -> Map.put(state, :game_active, false)
      "sort_hand"             -> update_player(state, context.seat, fn player -> %Player{ player | hand: Utils.sort_tiles(player.hand) } end)
      "reveal_tile"           ->
        tile_name = Enum.at(opts, 0, :"1m")
        state = Map.update!(state, :revealed_tiles, fn tiles -> tiles ++ [tile_name] end)
        state = if String.starts_with?(tile_name, "doraindicator") do
          Log.log(state, context.seat, :dora_flip, %{dora_count: length(state.revealed_tiles), dora_indicator: from_tile_name(state, tile_name)})
        else state end
        state
      "add_score"             ->
        recipients = case Enum.at(opts, 1) do
          "shimocha" -> [Utils.get_seat(context.seat, :shimocha)]
          "toimen" -> [Utils.get_seat(context.seat, :toimen)]
          "kamicha" -> [Utils.get_seat(context.seat, :kamicha)]
          "last_discarder" -> [get_last_discard_action(state).seat]
          "all" -> [:east, :south, :west, :north]
          "others" -> [:east, :south, :west, :north] -- [context.seat]
          _ -> [context.seat]
        end
        for recipient <- recipients, reduce: state do
          state -> update_player(state, recipient, fn player -> %Player{ player | score: player.score + Enum.at(opts, 0, 0) } end)
        end
      "put_down_riichi_stick" -> state |> Map.update!(:riichi_sticks, & &1 + Enum.at(opts, 0, 1)) |> update_player(context.seat, &%Player{ &1 | riichi_stick: true })
      "add_honba"             -> Map.update!(state, :honba, & &1 + Enum.at(opts, 0, 1))
      "reveal_hand"           -> update_player(state, context.seat, fn player -> %Player{ player | hand_revealed: true } end)
      "discard_draw"          ->
        # need to do this or else we might reenter adjudicate_actions
        :timer.apply_after(100, GenServer, :cast, [self(), {:play_tile, context.seat, length(state.players[context.seat].hand)}])
        state
      "press_button"          ->
        # need to do this or else we might reenter adjudicate_actions
        :timer.apply_after(100, GenServer, :cast, [self(), {:press_button, context.seat, Enum.at(opts, 0, "skip")}])
        state
      "random"                -> run_actions(state, [Enum.random(Enum.at(opts, 0, ["noop"]))], context)
      "when"                  -> if check_cnf_condition(state, Enum.at(opts, 0, []), context) do run_actions(state, Enum.at(opts, 1, []), context) else state end
      "ite"                   -> if check_cnf_condition(state, Enum.at(opts, 0, []), context) do run_actions(state, Enum.at(opts, 1, []), context) else run_actions(state, Enum.at(opts, 2, []), context) end
      "when_anyone"           ->
        for dir <- [:east, :south, :west, :north], check_cnf_condition(state, Enum.at(opts, 0, []), %{seat: dir}), reduce: state do
          state -> run_actions(state, Enum.at(opts, 1, []), %{context | seat: dir})
        end
      "when_everyone"           ->
        if Enum.all?([:east, :south, :west, :north], fn dir -> check_cnf_condition(state, Enum.at(opts, 0, []), %{seat: dir}) end) do
          run_actions(state, Enum.at(opts, 1, []), context)
        else state end
      "mark" -> state # no-op
      "swap_marked_hand_and_discard" ->
        {hand_tile, hand_seat, hand_index} = Enum.at(marked_objects.hand.marked, 0)
        {discard_tile, discard_seat, discard_index} = Enum.at(marked_objects.discard.marked, 0)

        # replace pond tile with hand tile
        state = update_player(state, discard_seat, &%Player{ &1 | pond: List.replace_at(&1.pond, discard_index, hand_tile) })

        # replace hand tile with pond tile
        hand_length = length(state.players[hand_seat].hand)
        state = if hand_index < hand_length do
          update_player(state, hand_seat, &%Player{ &1 | hand: List.replace_at(&1.hand, hand_index, discard_tile) })
        else
          update_player(state, hand_seat, &%Player{ &1 | draw: List.replace_at(&1.draw, hand_index - hand_length, discard_tile) })
        end

        state = update_action(state, context.seat, :swap, %{tile1: {hand_tile, hand_seat, hand_index, :hand}, tile2: {discard_tile, discard_seat, discard_index, :discard}})
        state = put_in(state.marking[context.seat].done, true)
        state
      "swap_marked_hand_and_dora_indicator" ->
        {hand_tile, hand_seat, hand_index} = Enum.at(marked_objects.hand.marked, 0)
        {revealed_tile, _, revealed_tile_index} = Enum.at(marked_objects.revealed_tile.marked, 0)

        # replace revealed tile with hand tile
        tile_spec = Enum.at(state.revealed_tiles, revealed_tile_index)
        state = update_in(state.reserved_tiles, &List.keyreplace(&1, tile_spec, 0, {tile_spec, hand_tile}))

        # replace hand tile with revealed tile
        hand_length = length(state.players[hand_seat].hand)
        state = if hand_index < hand_length do
          update_player(state, hand_seat, &%Player{ &1 | hand: List.replace_at(&1.hand, hand_index, revealed_tile) })
        else
          update_player(state, hand_seat, &%Player{ &1 | draw: List.replace_at(&1.draw, hand_index - hand_length, revealed_tile) })
        end

        state = update_action(state, context.seat, :swap, %{tile1: {hand_tile, hand_seat, hand_index, :hand}, tile2: {revealed_tile, nil, revealed_tile_index, :discard}})
        state = put_in(state.marking[context.seat].done, true)
        state
      "extend_live_wall_with_marked" ->
        {_, hand_seat, _} = Enum.at(marked_objects.hand.marked, 0)
        {hand_tiles, hand_indices} = marked_objects.hand.marked
        |> Enum.map(fn {tile, _seat, ix} -> {tile, ix} end)
        |> Enum.unzip()
        # remove specified tiles from hand (rightmost first)
        hand_length = length(state.players[hand_seat].hand)
        state = for ix <- Enum.sort_by(hand_indices, fn ix -> -ix end), reduce: state do
          state ->
            if ix < hand_length do
              update_player(state, hand_seat, &%Player{ &1 | hand: List.delete_at(&1.hand, ix) })
            else
              update_player(state, hand_seat, &%Player{ &1 | draw: List.delete_at(&1.draw, ix - hand_length) })
            end
        end
        # place them at the end of the live wall
        state = for tile <- hand_tiles, reduce: state do
          state -> Map.update!(state, :wall, fn wall -> List.insert_at(wall, -1, tile) end)
        end
        state = put_in(state.marking[context.seat].done, true)
        state
      "extend_dead_wall_with_marked" ->
        {_, hand_seat, _} = Enum.at(marked_objects.hand.marked, 0)
        {hand_tiles, hand_indices} = marked_objects.hand.marked
        |> Enum.map(fn {tile, _seat, ix} -> {tile, ix} end)
        |> Enum.unzip()
        # remove specified tiles from hand (rightmost first)
        hand_length = length(state.players[hand_seat].hand)
        state = for ix <- Enum.sort_by(hand_indices, fn ix -> -ix end), reduce: state do
          state ->
            if ix < hand_length do
              update_player(state, hand_seat, &%Player{ &1 | hand: List.delete_at(&1.hand, ix) })
            else
              update_player(state, hand_seat, &%Player{ &1 | draw: List.delete_at(&1.draw, ix - hand_length) })
            end
        end
        # place them at the end of the dead wall
        state = for tile <- hand_tiles, reduce: state do
          state -> Map.update!(state, :dead_wall, fn dead_wall -> List.insert_at(dead_wall, -1, tile) end)
        end
        state = put_in(state.marking[context.seat].done, true)
        state
      "set_aside_marked" ->
        {discard_tile, discard_seat, discard_index} = Enum.at(marked_objects.discard.marked, 0)

        # replace pond tile with blank
        state = update_player(state, discard_seat, &%Player{ &1 | pond: List.replace_at(&1.pond, discard_index, :"2x") })

        # set discard_tile aside
        state = update_player(state, context.seat, &%Player{ &1 | aside: &1.aside ++ [discard_tile] })

        state = put_in(state.marking[context.seat].done, true)
        state
      "pon_marked_discard" ->
        {called_tile, discard_seat, discard_index} = Enum.at(marked_objects.discard.marked, 0)

        # replace pond tile with blank
        state = update_player(state, discard_seat, &%Player{ &1 | pond: List.replace_at(&1.pond, discard_index, :"2x") })

        # remove tiles from hand
        call_choice = [:"7z", :"7z"]
        state = update_player(state, context.seat, &%Player{ &1 | hand: &1.hand -- call_choice })

        # make call
        call_style = %{kamicha: ["call_sideways", 0, 1], toimen: [0, "call_sideways", 1], shimocha: [0, 1, "call_sideways"]}
        style = call_style[Utils.get_relative_seat(context.seat, discard_seat)]
        call = style_call(style, call_choice, called_tile)
        call = {"pon", call}
        state = update_player(state, context.seat, &%Player{ &1 | calls: &1.calls ++ [call] })
        state = update_action(state, context.seat, :call,  %{from: discard_seat, called_tile: called_tile, other_tiles: call_choice, call_name: "pon"})
        state = if Map.has_key?(state.rules, "after_call") do
          run_actions(state, state.rules["after_call"]["actions"], %{seat: context.seat, callee: discard_seat, caller: context.seat, call: call})
        else state end

        state = put_in(state.marking[context.seat].done, true)
        state
      "about_to_draw"         -> state # no-op
      "about_to_ron"          -> state # no-op
      "set_tile_alias"        ->
        from_tiles = Enum.at(opts, 0, []) |> Enum.flat_map(&translate_tile_alias(state, context, &1))
        to_tiles = Enum.at(opts, 1, []) |> Enum.map(&Utils.to_tile/1)
        aliases = for to <- to_tiles, reduce: state.players[context.seat].tile_aliases do
          aliases -> Map.update(aliases, to, Enum.uniq(from_tiles), fn from -> Enum.uniq(from ++ from_tiles) end)
        end
        state = update_player(state, context.seat, &%Player{ &1 | tile_aliases: aliases })
        mappings = for from <- from_tiles, reduce: state.players[context.seat].tile_mappings do
          mappings -> Map.update(mappings, from, Enum.uniq(to_tiles), fn to -> Enum.uniq(to ++ to_tiles) end)
        end
        state = update_player(state, context.seat, &%Player{ &1 | tile_mappings: mappings })
        state
      "set_tile_alias_all"        ->
        from_tiles = Enum.at(opts, 0, []) |> Enum.flat_map(&translate_tile_alias(state, context, &1))
        to_tiles = Enum.at(opts, 1, []) |> Enum.map(&Utils.to_tile/1)
        aliases = for to <- to_tiles, reduce: state.players[context.seat].tile_aliases do
          aliases -> Map.update(aliases, to, Enum.uniq(from_tiles), fn from -> Enum.uniq(from ++ from_tiles) end)
        end
        state = update_all_players(state, fn _seat, player -> %Player{ player | tile_aliases: aliases } end)
        mappings = for from <- from_tiles, reduce: state.players[context.seat].tile_mappings do
          mappings -> Map.update(mappings, from, Enum.uniq(to_tiles), fn to -> Enum.uniq(to ++ to_tiles) end)
        end
        state = update_all_players(state, fn _seat, player -> %Player{ player | tile_mappings: mappings } end)
        state
      "set_tile_ordering"     ->
        tiles = Enum.map(Enum.at(opts, 0, []), &Utils.to_tile/1)
        ordering = Enum.zip(Enum.drop(tiles, -1), Enum.drop(tiles, 1)) |> Map.new()
        ordering_r = Enum.zip(Enum.drop(tiles, 1), Enum.drop(tiles, -1)) |> Map.new()
        state = update_player(state, context.seat, &%Player{ &1 |
          tile_ordering: Map.merge(&1.tile_ordering, ordering),
          tile_ordering_r: Map.merge(&1.tile_ordering_r, ordering_r)
        })
        state
      "set_tile_ordering_all"     ->
        tiles = Enum.map(Enum.at(opts, 0, []), &Utils.to_tile/1)
        ordering = Enum.zip(Enum.drop(tiles, -1), Enum.drop(tiles, 1)) |> Map.new()
        ordering_r = Enum.zip(Enum.drop(tiles, 1), Enum.drop(tiles, -1)) |> Map.new()
        state = update_all_players(state, fn _seat, player -> %Player{ player |
          tile_ordering: Map.merge(player.tile_ordering, ordering),
          tile_ordering_r: Map.merge(player.tile_ordering_r, ordering_r)
        } end)
        state
      "add_attr_last_discard"   ->
        # TODO generalize to add_attr
        last_discarder = get_last_discard_action(state).seat
        state = update_in(state.players[last_discarder].pond, fn pond -> Enum.drop(pond, -1) ++ (Enum.at(pond, -1) |> Utils.add_attr(opts)) end)
        state
      "add_attr_drawn_tile"   ->
        # TODO generalize to add_attr
        state = update_player(state, context.seat, &%Player{ &1 | draw: Utils.add_attr(&1.draw, opts) })
        state
      "remove_attr_all"   ->
        # TODO generalize to remove_attr
        state = update_player(state, context.seat, &%Player{ &1 | hand: Utils.remove_attr(&1.hand, opts), draw: Utils.remove_attr(&1.draw, opts), aside: Utils.remove_attr(&1.aside, opts) })
        state
      "tag_drawn_tile"        ->
        tag = Enum.at(opts, 0, "missing_tag")
        state = put_in(state.tags[tag], Enum.at(state.players[context.seat].draw, 0, :"1x"))
        state
      "untag"                 ->
        tag = Enum.at(opts, 0, "missing_tag")
        {_, state} = pop_in(state.tags[tag])
        state
      "convert_last_discard"  ->
        last_discarder = get_last_discard_action(state).seat
        tile = Utils.to_tile(Enum.at(opts, 0, "0m"))
        state = update_in(state.players[last_discarder].pond, fn pond -> Enum.drop(pond, -1) ++ [tile] end)
        state = update_action(state, last_discarder, :discard, %{tile: tile})
        state = Buttons.recalculate_buttons(state)
        state
      "set_aside_draw"     -> update_player(state, context.seat, &%Player{ &1 | draw: [], aside: &1.aside ++ &1.draw })
      "draw_from_aside"    ->
        state = case state.players[context.seat].aside do
          [] -> state
          [tile | aside] -> update_player(state, context.seat, &%Player{ &1 | draw: &1.draw ++ [tile], aside: aside })
        end
        state
      "swap_marked_with_aside" ->
        {hand_tile, hand_seat, hand_index} = Enum.at(marked_objects.hand.marked, 0)
        [aside_tile | aside] = state.players[hand_seat].aside
        aside = [hand_tile | aside]

        # replace hand tile with aside tile
        hand_length = length(state.players[hand_seat].hand)
        state = if hand_index < hand_length do
          update_player(state, hand_seat, &%Player{ &1 | aside: aside, hand: List.replace_at(&1.hand, hand_index, aside_tile) })
        else
          update_player(state, hand_seat, &%Player{ &1 | aside: aside, draw: List.replace_at(&1.draw, hand_index - hand_length, aside_tile) })
        end
        
        state = update_action(state, context.seat, :swap, %{tile1: {hand_tile, hand_seat, hand_index, :hand}, tile2: {aside_tile, hand_seat, 0, :aside}})
        state = put_in(state.marking[context.seat].done, true)
        state
      "charleston_left" -> do_charleston(state, :kamicha, context.seat, marked_objects)
      "charleston_across" -> do_charleston(state, :toimen, context.seat, marked_objects)
      "charleston_right" -> do_charleston(state, :shimocha, context.seat, marked_objects)
      "shift_dead_wall_index" -> Map.update!(state, :dead_wall_index, & &1 + Enum.at(opts, 0, 1))
      "cancel_deferred_actions" -> update_all_players(state, fn _seat, player -> %Player{ player | deferred_actions: [] } end)
      _                 ->
        IO.puts("Unhandled action #{action}")
        state
    end

    case action do
      "pause" ->
        # schedule an unpause after the given delay
        :timer.apply_after(Enum.at(opts, 0, 1500), GenServer, :cast, [self(), {:unpause, actions, context}])
        if @debug_actions do
          IO.puts("Stopping actions due to pause: #{inspect([[action | opts] | actions])}")
        end
        {state, []}
      _ ->
        # if our action updates state, then we need to recalculate buttons
        # this is so other players can react to certain actions
        if Map.has_key?(state.rules, "interruptible_actions") && action in state.rules["interruptible_actions"] do
          state = if not Enum.empty?(state.winners) do
            # if there's a winner, never display buttons
            update_all_players(state, fn _seat, player -> %Player{ player | buttons: [] } end)
          else
            Buttons.recalculate_buttons(state)
          end
          buttons_after = Enum.map(state.players, fn {seat, player} -> {seat, player.buttons} end)
          # IO.puts("buttons_before: #{inspect(buttons_before)}")
          # IO.puts("buttons_after: #{inspect(buttons_after)}")
          if buttons_before == buttons_after || Buttons.no_buttons_remaining?(state) do
            _run_actions(state, actions, context)
          else
            # if buttons changed, stop evaluating actions here
            if @debug_actions do
              IO.puts("Stopping actions due to buttons: #{inspect(buttons_after)} actions are: #{inspect([[action | opts] | actions])}")
            end
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

  def run_actions(state, actions, context) do
    state = Map.update!(state, :actions_cv, & &1 + 1)
    # if Enum.empty?(actions) || (actions |> Enum.at(0) |> Enum.at(0)) not in ["when", "sort_hand", "unset_status"] do
    #   IO.puts("Running actions #{inspect(actions)} in context #{inspect(context)}; cv = #{state.actions_cv}")
    # end
    # IO.puts("Running actions #{inspect(actions)} in context #{inspect(context)}; cv = #{state.actions_cv}")
    # IO.inspect(Process.info(self(), :current_stacktrace))
    {state, deferred_actions} = _run_actions(state, actions, context)
    # defer the remaining actions
    state = if not Enum.empty?(deferred_actions) do
      if @debug_actions do
        IO.puts("Deferred actions for seat #{context.seat} due to pause or existing buttons / #{inspect(deferred_actions)}")
      end
      state = schedule_actions(state, context.seat, deferred_actions)
      state
    else state end
    state = Map.update!(state, :actions_cv, & &1 - 1)
    state = if state.actions_cv == 0 do
      # notify_ai(state)
      # make our next decision for us (unless these actions were caused by auto buttons)
      state = if not Map.has_key?(context, :auto) || not context.auto do
        # IO.puts("Triggering auto buttons")
        state = Buttons.trigger_auto_buttons(state)
        state
      else state end
      state
    else state end
    state
  end

  def run_deferred_actions(state, context) do
    actions = state.players[context.seat].deferred_actions
    if state.game_active && not Enum.empty?(actions) do
      state = update_player(state, context.seat, &%Player{ &1 | choice: nil, chosen_actions: nil, deferred_actions: [] })
      if @debug_actions do
        IO.puts("Running deferred actions #{inspect(actions)} in context #{inspect(context)}")
      end
      state = run_actions(state, actions, context)
      notify_ai(state)
      state
    else state end
  end

  def schedule_actions(state, seat, actions) do
    update_player(state, seat, &%Player{ &1 | deferred_actions: &1.deferred_actions ++ actions })
  end

  def get_superceded_buttons(state, button_name) do
    if Map.has_key?(state.rules["buttons"], button_name) do
      ["play_tile"] ++ Map.get(state.rules["buttons"][button_name], "precedence_over", [])
    else [] end
  end

  def get_all_superceded_buttons(state, seat) do
    Enum.flat_map(state.players, fn {dir, player} -> if dir != seat do ["skip"] ++ get_superceded_buttons(state, player.choice) else [] end end)
  end

  defp adjudicate_actions(state) do
    if state.game_active do
      lock = Mutex.await(state.mutex, __MODULE__)
      # IO.puts("\nAdjudicating actions!")
      # clear last discard
      state = update_all_players(state, fn _seat, player -> %Player{ player | last_discard: nil } end)
      # supercede actions
      # basically, starting from the current turn player's choice, nil out others' choices
      seats = [state.turn, Utils.next_turn(state.turn), Utils.next_turn(state.turn, 2), Utils.next_turn(state.turn, 3)]
      state = for seat <- seats, reduce: state do
        state ->
          choice = state.players[seat].choice
          if choice not in [nil, "skip", "play_tile"] do
            superceded_choices = ["skip", "play_tile"] ++ if Map.has_key?(state.rules["buttons"], choice) do
              Map.get(state.rules["buttons"][choice], "precedence_over", [])
            else [] end
            # nil out every choice that is superceded by our choice
            update_all_players(state, fn dir, player ->
              if seat != dir && player.choice in superceded_choices do
                %Player{ player | choice: nil, chosen_actions: nil }
              else player end
            end)
          else
            if choice == "skip" do
              # always nil out skip
              update_player(state, seat, fn player -> %Player{ player | choice: nil, chosen_actions: nil } end)
            else state end
          end
      end
      # trigger all non-nil choices
      state = for {seat, player} <- state.players, reduce: state do
        state ->
          choice = player.choice
          actions = player.chosen_actions
          # don't clear deferred actions here
          # for example, someone might play a tile and have advance_turn interrupted by their own button
          # if they choose to skip, we still want to advance turn
          state = update_player(state, seat, fn player -> %Player{ player | choice: nil, chosen_actions: nil } end)
          state = if choice != nil do
            button_choice = if state.players[seat].button_choices != nil do
              Map.get(state.players[seat].button_choices, choice, nil)
            else nil end
            case button_choice do
              {:call, call_choices} ->
                button_name = choice
                flattened_call_choices = call_choices |> Map.values() |> Enum.concat()
                if length(flattened_call_choices) == 1 do
                  # if there's only one choice, automatically choose it
                  {called_tile, [call_choice]} = Enum.max_by(call_choices, fn {_tile, choices} -> length(choices) end)
                  state = run_actions(state, actions, %{seat: seat, call_name: button_name, call_choice: call_choice, called_tile: called_tile})
                  state
                else
                  # otherwise, defer all actions and display call choices
                  state = schedule_actions(state, seat, actions)
                  state = update_player(state, seat, fn player -> %Player{ player | call_buttons: call_choices, call_name: button_name } end)
                  notify_ai_call_buttons(state, seat)
                  state
                end
              {:mark, mark_spec, pre_actions} ->
                # run pre-mark actions
                state = run_actions(state, pre_actions, %{seat: seat})
                # setup marking
                state = Marking.setup_marking(state, seat, mark_spec)
                state = schedule_actions(state, seat, actions)
                notify_ai_marking(state, seat)
                state
              nil ->
                # just run all button actions as normal
                state = run_actions(state, actions, %{seat: seat})
                state
            end
          else state end
          state
      end
      # done with all choices
      state = if not performing_intermediate_action?(state) do
        notify_ai(state)
        if Buttons.no_buttons_remaining?(state) do
          Buttons.recalculate_buttons(state)
        else state end
      else state end
      # state = update_all_players(state, fn _seat, player -> %Player{ player | choice: nil, chosen_actions: nil } end)
      Mutex.release(state.mutex, lock)
      # IO.puts("Done adjudicating actions!\n")
      state
    else state end
  end

  def performing_intermediate_action?(state) do
    Enum.any?([:east, :south, :west, :north], fn seat -> performing_intermediate_action?(state, seat) end)
  end

  def performing_intermediate_action?(state, seat) do
    no_call_buttons = Enum.empty?(state.players[seat].call_buttons)
    made_choice = state.players[seat].choice != nil && state.players[seat].choice != "skip"
    marking = Marking.needs_marking?(state, seat)
    not no_call_buttons || made_choice || marking
  end

  def submit_actions(state, seat, choice, actions) do
    if state.game_active && state.players[seat].choice == nil do
      # IO.puts("Submitting choice for #{seat}: #{choice}, #{inspect(actions)}")
      # IO.puts("Deferred actions for #{seat}: #{inspect(state.players[seat].deferred_actions)}")
      state = update_player(state, seat, &%Player{ &1 | choice: choice, chosen_actions: actions })
      state = if choice != "skip" do update_player(state, seat, &%Player{ &1 | deferred_actions: [] }) else state end

      # for the current turn's player, if they just acted (have deferred actions) and have no buttons, their choice is "skip"
      # for other players who have no buttons and have not made a choice yet, their choice is "skip"
      # also for other players who have made a choice, if their choice is superceded by others then set it to "skip"
      last_action = get_last_action(state)
      turn_just_acted = last_action != nil && not Enum.empty?(state.players[state.turn].deferred_actions) && last_action.seat == state.turn
      last_discard_action = get_last_discard_action(state)
      turn_just_discarded = last_discard_action != nil && last_discard_action.seat == state.turn
      extra_turn = "extra_turn" in state.players[state.turn].status
      state = for {seat, player} <- state.players, reduce: state do
        state -> cond do
          seat == state.turn && (turn_just_acted || (turn_just_discarded && not extra_turn)) && Enum.empty?(player.buttons) && not performing_intermediate_action?(state, seat) ->
            # IO.puts("Player #{seat} must skip due to having just discarded")
            update_player(state, seat, &%Player{ &1 | choice: "skip", chosen_actions: [] })
          seat != state.turn && player.choice == nil && Enum.empty?(player.buttons) && not performing_intermediate_action?(state, seat) ->
            # IO.puts("Player #{seat} must skip due to having no buttons")
            update_player(state, seat, &%Player{ &1 | choice: "skip", chosen_actions: [] })
          seat != state.turn && player.choice != nil && player.choice in get_all_superceded_buttons(state, seat) && player.choice not in get_superceded_buttons(state, player.choice) ->
            # IO.puts("Player #{seat} must skip due to having buttons superceded")
            update_player(state, seat, &%Player{ &1 | choice: "skip", chosen_actions: [] })
          true -> state
        end
      end

      # check if nobody else needs to make choices
      if Enum.all?(state.players, fn {_seat, player} -> player.choice != nil end) do
        # if every action is skip, we need to resume deferred actions for all players
        # otherwise, adjudicate actions as normal
        if Enum.all?(state.players, fn {_seat, player} -> player.choice == "skip" end) do
          if state.game_active do
            # IO.puts("All choices are no-ops, running deferred actions")
            state = for {seat, _player} <- state.players, reduce: state do
              state ->
                state = update_player(state, seat, fn player -> %Player{ player | choice: nil, chosen_actions: nil } end)
                state = run_deferred_actions(state, %{seat: seat})
                state
            end
            notify_ai(state)
            state
          else state end
        else
          adjudicate_actions(state)
        end
      else state end
    else state end
  end

end
