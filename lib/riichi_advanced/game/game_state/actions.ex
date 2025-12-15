
defmodule RiichiAdvanced.GameState.Actions do
  alias RiichiAdvanced.Constants, as: Constants
  alias RiichiAdvanced.GameState.Buttons, as: Buttons
  alias RiichiAdvanced.GameState.Choice, as: Choice
  alias RiichiAdvanced.GameState.Conditions, as: Conditions
  alias RiichiAdvanced.GameState.Debug, as: Debug
  alias RiichiAdvanced.GameState.Marking, as: Marking
  alias RiichiAdvanced.GameState.Player, as: Player
  alias RiichiAdvanced.GameState.PlayerCache, as: PlayerCache
  alias RiichiAdvanced.GameState.Rules, as: Rules
  alias RiichiAdvanced.GameState.Saki, as: Saki
  alias RiichiAdvanced.GameState.TileBehavior, as: TileBehavior
  alias RiichiAdvanced.GameState.Log, as: Log
  alias RiichiAdvanced.Match, as: Match
  alias RiichiAdvanced.Riichi, as: Riichi
  alias RiichiAdvanced.Utils, as: Utils
  require Logger
  import RiichiAdvanced.GameState

  def trigger_event(state, event_name, context) do
    case Rules.get(state.rules_ref, event_name) do
      nil -> state
      event ->
        if Debug.debug_actions() do
          IO.puts("Triggered event #{event_name}: running #{inspect(event["actions"])}")
        end
        run_actions(state, event["actions"], context)
    end
  end

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

  # we use this to ensure no double discarding
  def can_discard(state, seat, ignore_turn \\ false) do
    our_turn = seat == state.turn
    ((our_turn and state.players[seat].last_discard == nil and state.awaiting_discard) or ignore_turn)
    and not has_unskippable_button?(state, seat)
    and Enum.empty?(state.players[seat].call_buttons)
    and not Marking.needs_marking?(state, seat)
  end

  def register_discard(state, seat, tile, tsumogiri \\ true, quiet \\ false) do
    state = update_action(state, seat, :discard, %{tile: tile})
    riichi = "just_reached" in state.players[seat].status
    state = Log.log(state, seat, :discard, %{tile: Utils.strip_attrs(tile), tsumogiri: tsumogiri, riichi: riichi})

    if not quiet do
      push_message(state, player_prefix(state, seat) ++ [
        %{text: "discarded %{tile}", vars: %{tile: {:tile, tile}}},
      ] ++ if tsumogiri do [] else [%{text: "from hand"}] end)

      click_sounds = [
        "/audio/tile1.mp3",
        "/audio/tile2.mp3",
        "/audio/tile3.mp3",
        "/audio/tile4.mp3",
        "/audio/tile5.mp3",
      ]
      play_sound(state, Enum.random(click_sounds))
    end

    state
  end

  def play_tile(state, seat, tile, index) do
    if can_discard(state, seat) and is_playable?(state, seat, tile) do
      # IO.puts("#{seat} played tile: #{inspect(tile)} at index #{index}")
      
      facedown = "discard_facedown" in state.players[seat].status or Utils.has_attr?(tile, ["_facedown"])
      tile = if facedown do Utils.add_attr(tile, ["_facedown"]) else tile end
      tile = Utils.add_attr(tile, ["_discard"])

      state = update_player(state, seat, &%Player{ &1 |
        hand: List.delete_at(&1.hand ++ Utils.remove_attr(&1.draw, ["_draw"]), index),
        pond: &1.pond ++ [tile],
        discards: &1.discards ++ [tile],
        draw: [],
        last_discard: {tile, index}
      })
      tsumogiri = index >= length(state.players[seat].hand)
      state = register_discard(state, seat, if facedown do :"1x" else tile end, tsumogiri)

      # trigger play effects
      state = case Rules.get(state.rules_ref, "play_effects") do
        nil -> state
        play_effects ->
          doras = get_doras(state)
          context = %{tile: tile, doras: doras}
          for [tile_spec, actions] <- play_effects, Riichi.tile_matches(List.wrap(tile_spec), context), reduce: state do
            state -> run_actions(state, actions, %{seat: seat, tile: tile})
          end
      end

      state = Map.put(state, :awaiting_discard, false)

      state
    else
      # IO.puts("#{seat} tried to play an unplayable tile: #{inspect(tile)}")
      state
    end
  end

  def draw_tile(state, seat, num, tile_spec \\ nil, to_aside \\ false) do
    if num > 0 do
      {tile_name, wall_index} = if tile_spec != nil do
        # we're drawing a specific tile, so keep the wall index the same
        {tile_spec, state.wall_index}
      else
        # take the next tile from the wall, and increment the wall index
        {Enum.at(state.wall, state.wall_index, nil), state.wall_index + 1}
      end
      cond do
        # we're drawing from the opposite end of the wall
        tile_name == "opposite_end" ->
          # check if there's any tiles left in the dead wall (if any)
          cond do
            state.dead_wall_index < length(state.dead_wall) ->
              pos = -1 - state.dead_wall_index
              reverse_parity = if rem(state.dead_wall_index, 2) == 0 do -1 else 1 end
              drawn_tile = Enum.at(state.dead_wall, pos + reverse_parity, Enum.at(state.dead_wall, pos))
              if Utils.has_attr?(drawn_tile, ["skip_draw"]) do
                # draw the next tile
                state
                |> Map.put(:dead_wall_index, state.dead_wall_index + 1)
                |> draw_tile(seat, num, tile_spec, to_aside)
              else
                state
                |> Map.put(:dead_wall_index, state.dead_wall_index + 1)
                |> draw_tile(seat, 1, drawn_tile, to_aside)
                |> draw_tile(seat, num - 1, tile_spec, to_aside)
              end
            length(state.wall) >= 1 ->
              # move the last tile of the wall to the dead wall
              # then draw the last tile of the dead wall
              {wall, [tile]} = cond do
                rem(length(state.wall), 2) == 1 -> Enum.split(state.wall, -1)
                length(state.wall) == 1         -> {[], state.wall}
                true                            -> with {wall, [tile1, tile2]} <- Enum.split(state.wall, -2) do {wall ++ [tile2], [tile1]} end
              end
              dead_wall = if rem(length(state.dead_wall), 2) == 0 do
                [tile | state.dead_wall]
              else List.insert_at(state.dead_wall, 1, tile) end
              state
              |> Map.put(:wall, wall)
              |> Map.put(:dead_wall, dead_wall)
              |> draw_tile(seat, num, tile_spec, to_aside)
            true ->
              # both walls are exhausted, draw nothing
              IO.puts("#{seat} tried to draw a nil tile!")
              state
          end
        # the wall is exhausted and we're not drawing a specific tile
        tile_name == nil ->
          # move a dead wall tile over
          if not Enum.empty?(state.dead_wall) do
            {wall_tile, dead_wall} = Enum.split(state.dead_wall, 1)
            state
            |> Map.put(:wall, state.wall ++ wall_tile)
            |> Map.put(:dead_wall, dead_wall)
            |> draw_tile(seat, num, tile_spec, to_aside)
          else
            IO.puts("#{seat} tried to draw a nil tile!")
            state
          end
        # otherwise, we draw a tile as normal
        true ->
          # if we're drawing a specific tile, update drawn_reserved_tiles with that tile
          state = if is_binary(tile_name) and tile_name in state.reserved_tiles do
            Map.update!(state, :drawn_reserved_tiles, fn tiles -> [tile_name | tiles] end)
          else state end
          # grab the named tile (no op if the tile name is a normal tile)
          tile = from_named_tile(state, %{seat: seat}, tile_name) |> Utils.add_attr(["_draw"])
          # if this is a skip_draw tile and we're not going to cause an infinite loop, then try again
          if Utils.has_attr?(tile, ["skip_draw"]) and tile_spec == nil do
            state
            |> Map.put(:wall_index, wall_index)
            |> draw_tile(seat, num, nil, to_aside)
          else # TODO should we check tile != nil here?
            # if we're drawing a dead wall tile, replace it with an empty undrawable tile
            state = if is_integer(tile_name) and tile != nil do
              Map.update!(state, :dead_wall, &List.replace_at(&1, tile_name, Utils.add_attr(:"2x", ["_skip_draw"])))
            else state end
            state = if not to_aside do
              # draw to hand
              state
              |> update_player(seat, &%Player{ &1 | draw: &1.draw ++ [tile] })
              |> Map.put(:wall_index, wall_index)
              |> update_action(seat, :draw, %{tile: tile})
              |> Log.log(seat, :draw, %{tile: Utils.strip_attrs(tile), kan_draw: "kan" in state.players[seat].status})
            else
              # draw to aside
              state
              |> update_player(seat, &%Player{ &1 | aside: [tile | &1.aside] })
              |> Map.put(:wall_index, wall_index)
              # TODO: log this
            end

            # IO.puts("wall index is now #{get_state().wall_index}")
            draw_tile(state, seat, num - 1, tile_spec, to_aside)
          end
      end
    else
      if num < 0 do
        # un-draw that many tiles
        undo_draw(state, seat, -num)
      else
        # run after_draw actions
        state = trigger_event(state, "after_draw", %{seat: seat})

        # update playable_indices
        GenServer.cast(self(), :calculate_playable_indices)

        state
      end
    end
  end

  def undo_draw(state, seat, num) do
    if num > 0 do
      # only allow this if a tile in draw matches the previous wall tile
      wall_tile = Enum.at(state.wall, state.wall_index - 1)
      draw = state.players[seat].draw
      case Enum.find_index(draw, &Utils.same_tile(&1, wall_tile)) do
        nil -> undo_draw(state, seat, 0) # halt
        ix ->
          # remove tile from draw, update wall index, and recurse
          state
          |> update_player(seat, &%Player{ &1 | draw: List.delete_at(draw, ix) })
          |> Map.put(:wall_index, state.wall_index -  1)
          |> undo_draw(seat, num - 1)
      end
    else
      # update playable_indices
      GenServer.cast(self(), :calculate_playable_indices)
      state
    end
  end

  def change_turn(state, seat, via_action \\ false) do
    # get previous turn
    prev_turn = state.turn

    # erase previous turn's deferred actions
    state = if prev_turn != nil do
      update_player(state, prev_turn, &%Player{ &1 | deferred_actions: [], deferred_context: %{} })
    else state end

    # IO.puts("Changing turn from #{prev_turn} to #{seat}")

    # run before_turn_change, unless this turn change was triggered by an action
    state = if state.game_active and not via_action and prev_turn != nil and seat != prev_turn do
      trigger_event(state, "before_turn_change", %{seat: prev_turn})
    else state end

    # change turn
    state = Map.put(state, :turn, seat)

    if state.game_active do
      # run after_turn_change, unless this turn change was triggered by an action
      state = if not via_action and seat != prev_turn do
        trigger_event(state, "after_turn_change", %{seat: seat})
      else state end

      # sort hands if debug mode is on
      state = if Debug.debug() do
        update_all_players(state, fn _seat, player -> %Player{ player | hand: Utils.sort_tiles(player.hand) } end)
      else state end

      state = Map.put(state, :awaiting_discard, true)

      state
    else state end
  end

  def advance_turn(state) do
    # this action is called after playing a tile
    # it should trigger on_turn_change, so don't mark the turn change as via_action
    if state.game_active do
      new_turn = if state.reversed_turn_order do Utils.prev_turn(state.turn) else Utils.next_turn(state.turn) end
      new_turn = for _ <- 1..4, reduce: new_turn do
        new_turn -> if new_turn in state.available_seats do
          new_turn
        else
          if state.reversed_turn_order do Utils.prev_turn(new_turn) else Utils.next_turn(new_turn) end
        end
      end
      state = change_turn(state, new_turn)
      state
    else
      # reschedule this turn change
      schedule_actions(state, state.turn, [["advance_turn"]], %{seat: state.turn})
    end
  end

  defp style_call(style, call_choice, called_tile) do
    if called_tile != nil do
      tiles = if "call" in style or "call_sideways" in style do call_choice else call_choice ++ [called_tile] end
      for style_spec <- style do
        case style_spec do
          "call"                                  -> called_tile
          "call_sideways"                         -> called_tile |> Utils.add_attr(["_sideways"])
          ix when is_integer(ix)                  -> Enum.at(tiles, ix)
          ["sideways", ix] when is_integer(ix)    -> Enum.at(tiles, ix) |> Utils.add_attr(["_sideways"])
          ["1x", ix] when is_integer(ix)          -> Enum.at(tiles, ix) |> Utils.add_attr(["_facedown"])
          ["1x", "call"]                          -> called_tile |> Utils.add_attr(["_facedown"])
          ["1x", tile]                            -> Utils.to_tile(tile) |> Utils.add_attr(["_facedown"])
          ["1x_sideways", ix] when is_integer(ix) -> Enum.at(tiles, ix) |> Utils.add_attr(["_facedown", "_sideways"])
          ["1x_sideways", "call"]                 -> called_tile |> Utils.add_attr(["_facedown", "_sideways"])
          ["1x_sideways", tile]                   -> Utils.to_tile(tile) |> Utils.add_attr(["_facedown", "_sideways"])
          tile                                    -> Utils.to_tile(tile)
        end
      end
    else call_choice end
  end

  def trigger_call(state, seat, button_name, call_choice, called_tile, call_source, simulated \\ false) do
    # get the actual called tile (with attrs)
    called_tile = case call_source do
      :discards -> Enum.at(state.players[state.turn].pond, -1)
      :hand     -> called_tile
      :draw     -> called_tile
      _         -> IO.puts("Unhandled call_source #{inspect(call_source)}")
    end

    buttons = Rules.get(state.rules_ref, "buttons", %{})
    call_name = Map.get(buttons[button_name], "call_name", button_name)
    msg_name = Map.get(buttons[button_name], "msg_name", call_name)
    default_call_style = Map.new(["self", "kamicha", "toimen", "shimocha"], fn dir -> {dir, 0..length(call_choice)} end)
    call_style = Map.merge(default_call_style, Map.get(buttons[button_name], "call_style", %{}))

    # style the call
    call = if called_tile != nil do
      style = call_style[Atom.to_string(Utils.get_relative_seat(seat, state.turn))]
      style_call(style, call_choice, called_tile)
    else call_choice end

    # add "_concealed" to every tile if it's a hidden call
    hidden = Map.get(buttons[button_name], "call_hidden", false)
    call = if hidden do Utils.add_attr(call, ["_concealed"]) else call end

    # finalize call
    call = {call_name, call}

    # remove called tiles from its source
    {state, to_remove} = case call_source do
      :discards -> {update_player(state, state.turn, &%Player{ &1 | pond: Enum.drop(&1.pond, -1) }), call_choice}
      :hand     -> {state, if called_tile != nil do [called_tile | call_choice] else call_choice end}
      :draw     -> {state, if called_tile != nil do [called_tile | call_choice] else call_choice end}
      _         ->
        IO.puts("Unhandled call_source #{inspect(call_source)}")
        {state, call_choice}
    end
    hand = Utils.add_attr(state.players[seat].hand, ["_hand"])
    draw = Utils.add_attr(state.players[seat].draw, ["_hand"])
    new_hand = Match.try_remove_all_tiles(hand ++ draw, to_remove) |> Enum.at(0) |> Utils.remove_attr(["_hand", "_draw"])
    new_hand = if new_hand == nil do
      Logger.error("trigger_call: Call #{call_name} on #{inspect(call_choice)} #{inspect(called_tile)} is to remove #{inspect(to_remove)} from hand #{inspect(hand)}, but none found")
      hand
    else new_hand end

    # actually add the call to the player
    state = update_player(state, seat, &%Player{ &1 | hand: new_hand, draw: [], calls: &1.calls ++ [call] })
    state = if called_tile != nil do
      update_action(state, seat, :call, %{from: state.turn, called_tile: called_tile, other_tiles: call_choice, call_name: call_name})
    else
      # flower
      update_action(state, seat, :call, %{from: state.turn, called_tile: Enum.at(call_choice, 0), other_tiles: [], call_name: call_name})
    end

    state = Log.add_call(state, seat, call_name, call_choice, called_tile)

    if not simulated do
      # messages and log
      cond do
        hidden ->
          push_message(state, player_prefix(state, seat) ++ [%{
            text: "called %{call}",
            vars: %{
              call: {:text, msg_name, %{bold: true}}
            }
          }])
        called_tile != nil ->
          push_message(state, player_prefix(state, seat) ++ [%{
            text: "called %{call} on %{tile} with %{choice}",
            vars: %{
              call: {:text, msg_name, %{bold: true}},
              tile: {:tile, called_tile},
              choice: {:hand, call_choice}
            }
          }])
        true ->
          push_message(state, player_prefix(state, seat) ++ [%{
            text: "called %{call} on %{tile}",
            vars: %{
              call: {:text, msg_name, %{bold: true}},
              tile: {:hand, call_choice}
            }
          }])
      end
      # play sound
      click_sounds = [
        "/audio/call1.mp3",
        "/audio/call2.mp3",
        "/audio/call3.mp3",
        "/audio/call4.mp3",
        "/audio/call5.mp3",
      ]
      play_sound(state, Enum.random(click_sounds))
    end

    state = update_player(state, seat, &%Player{ &1 | call_buttons: %{} })
    state
  end

  defp upgrade_call(state, seat, call_name, call_choice, called_tile) do
    # find the index of the call whose tiles match call_choice
    index = state.players[seat].calls
      |> Enum.map(&Utils.call_to_tiles/1)
      |> Enum.find_index(fn call_tiles -> Match.try_remove_all_tiles(call_choice, call_tiles) == [[]] end)

    # upgrade that call
    {name, call} = Enum.at(state.players[seat].calls, index)
    call_choice = Utils.call_to_tiles({name, call})

    # find the index of the sideways tile to determine the direction
    sideways_index = Enum.find_index(call, &Utils.has_attr?(&1, ["sideways"]))
    sideways_index_rev = Enum.find_index(Enum.reverse(call), &Utils.has_attr?(&1, ["sideways"]))
    dir = cond do
      sideways_index == 0 -> :kamicha
      sideways_index_rev == 0 -> :shimocha # for 2-tile calls
      sideways_index == 1 -> :toimen
      sideways_index == 2 -> :shimocha
      true -> :self
    end

    # style the call
    default_call_style = Map.new(["self", "kamicha", "toimen", "shimocha"], fn dir -> {dir, 0..length(call_choice)} end)
    buttons = Rules.get(state.rules_ref, "buttons", %{})
    call_style = Map.merge(default_call_style, Map.get(buttons[call_name], "call_style", %{}))
    style = call_style[Atom.to_string(dir)]
    call = style_call(style, call_choice, called_tile)

    upgraded_call = {call_name, call}
    state = update_player(state, seat, &%Player{ &1 | hand: Match.try_remove_all_tiles(Utils.add_attr(&1.hand, ["_hand"]) ++ Utils.add_attr(&1.draw, ["_hand"]), [called_tile]) |> Enum.at(0) |> Utils.remove_attr(["_hand"]), draw: [], calls: List.replace_at(state.players[seat].calls, index, upgraded_call) })
    state = update_action(state, seat, :call, %{from: state.turn, called_tile: called_tile, other_tiles: call_choice, call_name: call_name})
    state = update_player(state, seat, &%Player{ &1 | call_buttons: %{} })
    state
  end

  @amt_specs [
    "count_matches",
    "count_matching_ways",
    "tiles_in_wall",
    "num_discards",
    "num_aside",
    "num_facedown_tiles",
    "num_facedown_tiles_others",
    "num_matching_revealed_tiles_all",
    "num_matching_melded_tiles_all",
    "num_players",
    "current_score",
    "half_score",
    "100_times_tile_number",
    "count_tiles",
    "count_draws",
    "count_dora",
    "count_reverse_dora",
    "dice",
    "pot",
    "honba",
    "riichi_value",
    "honba_value",
    "payout",
    "points",
    "points2",
    "score",
    "minipoints"
  ]
  def is_amount?(state, seat, value) do
    is_number(value)
    or (List.wrap(value) |> Enum.at(0)) in @amt_specs
    or value in Map.keys(state.players[seat].counters)
  end

  def interpret_amount(state, context, amt_spec) do
    amt_spec = List.wrap(amt_spec)
    # counters should take precedence over keywords
    counter = with [amount | _opts] <- amt_spec do
      Map.get(state.players[context.seat].counters, amount, nil)
    end
    case amt_spec do
      _ when counter != nil -> counter
      ["count_matches" | opts] ->
        # count how many times the given hand calls spec matches the given match definition
        hand_calls = Conditions.get_hand_calls_spec(state, context, Enum.at(opts, 0, []))
        match_definitions = Rules.translate_match_definitions(state.rules_ref, Enum.at(opts, 1, []))
        tile_behavior = state.players[context.seat].tile_behavior
        Match.binary_search_count_matches(hand_calls, match_definitions, tile_behavior)
      ["count_matching_ways" | opts] ->
        # count how many given hand-calls combinations matches the given match definition
        hand_calls = Conditions.get_hand_calls_spec(state, context, Enum.at(opts, 0, []))
        match_definitions = Rules.translate_match_definitions(state.rules_ref, Enum.at(opts, 1, []))
        tile_behavior = state.players[context.seat].tile_behavior
        Enum.count(hand_calls, fn {hand, calls} -> Match.match_hand(hand, calls, match_definitions, tile_behavior) end)
      ["tiles_in_wall" | _opts] -> length(state.wall) - state.wall_index
      ["num_discards" | _opts] -> length(state.players[context.seat].discards)
      ["num_aside" | _opts] -> length(state.players[context.seat].aside)
      ["num_facedown_tiles" | _opts] -> Utils.count_tiles(state.players[context.seat].pond, [:"1x"])
      ["num_facedown_tiles_others" | _opts] ->
        for {seat, player} <- state.players, seat != context.seat do
          Utils.count_tiles(player.pond, [:"1x"])
        end |> Enum.sum()
      ["num_matching_revealed_tiles_all" | opts] ->
        for {_seat, player} <- state.players do
          player.hand ++ player.draw
          |> Enum.filter(&Riichi.tile_matches(opts, %{tile: &1}))
          |> Utils.count_tiles([{:any, ["revealed"]}])
        end |> Enum.sum()
      ["num_matching_melded_tiles_all" | opts] ->
        for {_seat, player} <- state.players do
          player.calls
          |> Enum.flat_map(&Utils.call_to_tiles/1)
          |> Enum.count(&Riichi.tile_matches(opts, %{tile: &1}))
        end |> Enum.sum()
      ["num_players" | _opts] -> length(state.available_seats)
      ["current_score" | _opts] -> state.players[context.seat].score
      ["half_score" | _opts] -> Utils.half_score_rounded_up(state.players[context.seat].score)
      ["100_times_tile_number" | _opts] ->
        cond do
          Riichi.is_num?(context.tile, 1) -> 100
          Riichi.is_num?(context.tile, 2) -> 200
          Riichi.is_num?(context.tile, 3) -> 300
          Riichi.is_num?(context.tile, 4) -> 400
          Riichi.is_num?(context.tile, 5) -> 500
          Riichi.is_num?(context.tile, 6) -> 600
          Riichi.is_num?(context.tile, 7) -> 700
          Riichi.is_num?(context.tile, 8) -> 800
          Riichi.is_num?(context.tile, 9) -> 900
          true                            -> 0
        end
      ["count_tiles" | opts] ->
        seat = Conditions.from_seat_spec(state, context, Enum.at(opts, 0, "self"))
        # for some reason, not using a variable makes it return the last summand only :/
        won_by_draw = Map.get(context, :win_source, :draw) == :draw
        num_tiles = length(state.players[seat].hand)
        num_tiles = num_tiles + length(state.players[seat].draw)
        num_tiles = num_tiles + length(state.players[seat].aside)
        num_tiles = num_tiles + length(Enum.flat_map(state.players[seat].calls, &Utils.call_to_tiles/1))
        num_tiles = num_tiles + if won_by_draw do 0 else 1 end
        num_tiles
      ["count_draws" | opts] ->
        seat = Conditions.from_seat_spec(state, context, Enum.at(opts, 0, "self"))
        length(state.players[seat].draw)
      ["count_dora" | opts] ->
        dora_indicator = from_named_tile(state, context, Enum.at(opts, 0, :"1m"))
        case Conditions.get_hand_calls_spec(state, context, Enum.at(opts, 1, [])) do
          [] -> 0
          [{hand, calls} | _] ->
            hand = hand ++ Enum.flat_map(calls, &Utils.call_to_tiles/1)
            if dora_indicator != nil do
              doras = Map.get(Rules.get(state.rules_ref, "dora_indicators", %{}), Utils.tile_to_string(dora_indicator), []) |> Enum.map(&Utils.to_tile/1)
              Utils.count_tiles(hand, doras, state.players[context.seat].tile_behavior)
            else 0 end
        end
      ["count_reverse_dora" | opts] ->
        dora_indicator = from_named_tile(state, context, Enum.at(opts, 0, :"1m"))
        case Conditions.get_hand_calls_spec(state, context, Enum.at(opts, 1, [])) do
          [] -> 0
          [{hand, calls} | _] ->
            hand = hand ++ Enum.flat_map(calls, &Utils.call_to_tiles/1)
            if dora_indicator != nil do
              doras = Map.get(Rules.get(state.rules_ref, "reverse_dora_indicators", %{}), Utils.tile_to_string(dora_indicator), []) |> Enum.map(&Utils.to_tile/1)
              Utils.count_tiles(hand, doras, state.players[context.seat].tile_behavior)
            else 0 end
        end
      ["dice" | _opts] -> Enum.sum(state.dice)
      ["pot" | _opts] -> state.pot
      ["honba" | _opts] -> state.honba
      ["riichi_value" | _opts] -> Rules.get(state.rules_ref, "score_calculation", %{}) |> Map.get("riichi_value", 0)
      ["honba_value" | _opts] -> Rules.get(state.rules_ref, "score_calculation", %{}) |> Map.get("honba_value", 0)
      ["payout" | opts] -> state.delta_scores[Conditions.from_seat_spec(state, context, Enum.at(opts, 0, "self"))]
      ["points" | _opts] when is_map_key(context, :points) -> context.points
      ["points2" | _opts] when is_map_key(context, :points2) -> context.points2
      ["score" | _opts] when is_map_key(context, :score) -> context.score
      ["minipoints" | _opts] when is_map_key(context, :minipoints) -> context.minipoints
      ["minipoints" | opts] ->
        score_actions = Enum.at(opts, 0)
        actions_with_lookahead = for action <- Enum.reverse(score_actions), reduce: [] do
          [] -> [{action, [nil]}]
          [{["print" | _], next_action} | _] = acc -> [{action, next_action} | acc]
          [{["count" | _], next_action} | _] = acc -> [{action, next_action} | acc]
          [{["prune" | _], next_action} | _] = acc -> [{action, next_action} | acc]
          [{next_action, _} | _] = acc -> [{action, next_action} | acc]
        end
        # IO.inspect(Enum.map(actions_with_lookahead, fn {[a|_],[b|_]} -> {a, b} end))
        player = state.players[context.seat]
        tile_behavior = player.tile_behavior
        initial_hand_calls_fus = get_winning_tiles(state, context.seat, context.win_source)
        |> Enum.map(&{[&1 | player.hand], player.calls, [0]})
        for {[action | opts], [next_action | next_opts]} <- actions_with_lookahead, reduce: initial_hand_calls_fus do
          hand_calls_fus -> 
            conditions = Enum.at(opts, 1, [])
            passes_conditions = Conditions.check_cnf_condition(state, conditions, context)
            # IO.inspect(hand_calls_fus, label: action)
            case action do
              "add" ->
                amt = interpret_amount(state, context, Enum.at(opts, 0, 0))
                for {hand, calls, fus} <- hand_calls_fus do
                  {hand, calls, for fu <- fus do
                    context = Map.put(context, :minipoints, fu)
                    if Conditions.check_cnf_condition(state, conditions, context) do
                      fu + amt
                    else fu end
                  end}
                end
              _ when not passes_conditions -> hand_calls_fus
              "prune" ->
                case Enum.at(opts, 0, %{}) do
                  %{"method" => "tile_count", "num_tiles" => num_tiles} ->
                    Enum.reject(hand_calls_fus, fn {hand, _calls, _fus} ->
                      length(hand) in num_tiles
                    end)
                  arg ->
                    IO.puts("WARNING: unknown pruning method #{inspect(arg)}")
                    hand_calls_fus
                end
                hand_calls_fus
              "put_calls_in_hand" ->
                call_names = List.wrap(Enum.at(opts, 0, []))
                for {hand, calls, fus} <- hand_calls_fus do
                  {match, nomatch} = Enum.split_with(calls, fn {name, _call} -> name in call_names or Enum.empty?(call_names) end)
                  {hand ++ Enum.flat_map(match, &Utils.call_to_tiles/1), nomatch, fus}
                end
              "remove_attrs" ->
                for {hand, calls, fus} <- hand_calls_fus do
                  {Utils.strip_attrs(hand), Enum.map(calls, fn {name, call} -> {name, Utils.strip_attrs(call)} end), fus}
                end
              "convert_calls" ->
                value_map = Enum.at(opts, 0, %{})
                for {hand, calls, fus} <- hand_calls_fus do
                  value = Enum.map(calls, fn {name, _call} -> Map.get(value_map, name, 0) end)
                  |> Enum.sum()
                  {hand, calls, Enum.map(fus, & &1 + value)}
                end
              "remove_calls" ->
                tile_specs = List.wrap(Enum.at(opts, 0, []))
                for {hand, calls, fus} <- hand_calls_fus do
                  {hand, Enum.reject(calls, fn {_name, call} -> Enum.any?(call, &Riichi.tile_matches_all(tile_specs, %{tile: &1})) end), fus}
                end
              "remove_groups" ->
                # if the next action is also remove_groups,
                # during removals, if two non-overlapping groups are removal candidates
                # only remove one of the groups (since the other groups can be removed later)
                # this enforces a kind of ordering on group removal, reducing redundancy
                group_specs = Enum.at(opts, 0)
                next_group_specs = if next_action == "remove_groups" do
                  Enum.at(next_opts, 0, [])
                else [] end
                may_remove_later = group_specs == next_group_specs
                result = Enum.flat_map(hand_calls_fus, fn {hand, calls, fus} ->
                  group_value = for %{"groups" => groups} = group_spec <- group_specs, group <- groups do
                    value = Map.get(group_spec, "value", 0)
                    tiles = Match.collect_base_tiles(hand, [], group, tile_behavior)
                    {hands, _} = Match.remove_group(hand, [], group, tiles, tile_behavior)
                    |> Enum.unzip()
                    hands
                    |> Enum.uniq()
                    |> Enum.map(&{hand -- &1, value})
                  end
                  |> Enum.concat()
                  |> Enum.uniq()
                  if may_remove_later do
                    # IO.inspect(Enum.map(group_value, fn {group, _value} -> Utils.hand_to_string(group) end), label: "Choices for #{Utils.hand_to_string(hand)}")
                    ret = for {group, _value} <- group_value do
                      Enum.filter(group_value, fn {group2, _} -> Enum.any?(group2, & &1 in group) end)
                    end
                    |> Enum.reject(&Enum.empty?/1)
                    |> Enum.min_by(&length/1, &<=/2, fn -> [] end)
                    # if there's a choice to take nothing, always include it as an option
                    ret = case Enum.find(group_value, fn {group, _value} -> group == [] end) do
                      nil -> ret
                      empty_group -> [empty_group | ret]
                    end
                    # IO.inspect(Enum.map(ret, fn {group, _value} -> Utils.hand_to_string(group) end), label: "Removing from #{Utils.hand_to_string(hand)}")
                    # IO.inspect(Enum.map(group_value -- ret, fn {group, _value} -> Utils.hand_to_string(group) end), label: "Not removing from #{Utils.hand_to_string(hand)}")
                    ret
                  else group_value end
                  |> Enum.map(fn {group, value} -> {hand -- group, calls, Enum.map(fus, & &1 + value)} end)
                end)
                # roll back if no matches
                if Enum.empty?(result) do hand_calls_fus else result end
              "retain_empty_hands" ->
                for {[], [], fus} <- hand_calls_fus do
                  {[], [], fus}
                end
              "round_up" ->
                to = Enum.at(opts, 0, 10)
                to = if to == 0 do 10 else to end
                for {hand, calls, fus} <- hand_calls_fus do
                  {hand, calls, for fu <- fus, uniq: true do
                    remainder = rem(fu, to)
                    if remainder == 0 do fu else fu - remainder + to end
                  end}
                end
              "take_maximum" ->
                if not Enum.empty?(hand_calls_fus) do
                  max_fu = Enum.flat_map(hand_calls_fus, fn {_hand, _calls, fus} -> fus end) |> Enum.max()
                  for {hand, calls, fus} <- hand_calls_fus, max_fu in fus do
                    {hand, calls, [max_fu]}
                  end
                else [] end
              "add_original_hand" -> hand_calls_fus ++ initial_hand_calls_fus
              "print" ->
                IO.inspect(Enum.take(hand_calls_fus, Enum.at(opts, 0, length(hand_calls_fus))), limit: :infinity)
                hand_calls_fus
              "count" ->
                IO.inspect(length(hand_calls_fus))
                hand_calls_fus
            end
            # uniq by hand/calls while preserving min and max fus
            |> Enum.group_by(fn {hand, calls, _fus} -> {hand, calls} end)
            |> Enum.map(fn {{hand, calls}, hand_calls_fus} -> 
              {hand, calls, Enum.flat_map(hand_calls_fus, fn {_hand, _calls, fus} -> fus end) |> Enum.uniq()}
            end)
        end
        |> Enum.take(1)
        |> Enum.map(fn {_hand, _calls, fus} -> Enum.max(fus) end)
        |> Enum.at(0, 0)
      [amount | _opts] when is_binary(amount) -> Map.get(state.players[context.seat].counters, amount, 0)
      [amount | _opts] when is_number(amount) -> Utils.try_integer(amount)
      _ ->
        IO.puts("Unknown amount spec #{inspect(amt_spec)}")
        0
    end
  end
  # useful function to replace all amounts in a vars map used for interpolation
  def map_var_amounts(state, context, vars) do
    for {k, v} <- vars, into: %{} do
      if is_amount?(state, context.seat, v) do
        {k, to_string(interpret_amount(state, context, v))}
      else {k, v} end
    end
  end

  defp warn_counter(counter_name) do
    if counter_name in @amt_specs do
      IO.puts("WARNING: do not set a counter to an amount name like \"#{counter_name}\", since it makes the amount name unusable")
    end
  end

  defp set_counter(state, context, counter_name, amt_spec) do
    warn_counter(counter_name)
    amount = interpret_amount(state, context, amt_spec)
    put_in(state.players[context.seat].counters[counter_name], amount)
  end

  defp set_counter_all(state, context, counter_name, amt_spec) do
    warn_counter(counter_name)
    amount = interpret_amount(state, context, amt_spec)
    for dir <- state.available_seats, reduce: state do
      state -> put_in(state.players[dir].counters[counter_name], amount)
    end
  end

  defp add_counter(state, context, counter_name, amt_spec) do
    warn_counter(counter_name)
    amount = interpret_amount(state, context, amt_spec)
    new_ctr = amount + Map.get(state.players[context.seat].counters, counter_name, 0)
    put_in(state.players[context.seat].counters[counter_name], new_ctr)
  end

  defp subtract_counter(state, context, counter_name, amt_spec) do
    warn_counter(counter_name)
    amount = interpret_amount(state, context, amt_spec)
    new_ctr = -amount + Map.get(state.players[context.seat].counters, counter_name, 0)
    put_in(state.players[context.seat].counters[counter_name], new_ctr)
  end
  
  defp multiply_counter(state, context, counter_name, amt_spec) do
    warn_counter(counter_name)
    amount = interpret_amount(state, context, amt_spec)
    new_ctr = Utils.try_integer(amount * Map.get(state.players[context.seat].counters, counter_name, 0))
    put_in(state.players[context.seat].counters[counter_name], new_ctr)
  end
  
  defp divide_counter(state, context, counter_name, amt_spec) do
    warn_counter(counter_name)
    amount = interpret_amount(state, context, amt_spec)
    if amount == 0 do
      IO.puts("WARNING: tried to divide by zero")
      state
    else
      new_ctr = Utils.try_integer(Map.get(state.players[context.seat].counters, counter_name, 0) / amount)
      put_in(state.players[context.seat].counters[counter_name], new_ctr)
    end
  end

  def interpolate_string(state, context, str, assigns) do
    for {name, value} <- assigns, reduce: str do
      str when is_list(value) -> str
      str ->
        value = if is_amount?(state, context.seat, value) do
          to_string(interpret_amount(state, context, value))
        else value end
        String.replace(str, "$" <> name, value)
    end
  end

  defp do_charleston(state, dir, seat, marked_objects) do
    marked = Marking.get_marked(marked_objects, :hand)
    {_, hand_seat, _} = Enum.at(marked, 0)
    {hand_tiles, hand_indices} = marked
    |> Enum.map(fn {tile, _seat, ix} -> {tile, ix} end)
    |> Enum.unzip()
    # remove specified tiles from hand
    state = for ix <- Enum.sort(hand_indices, :desc), reduce: state do
      state ->
        hand_length = length(state.players[hand_seat].hand)
        if ix < hand_length do
          update_player(state, hand_seat, &%Player{ &1 | hand: List.delete_at(&1.hand, ix) })
        else
          update_player(state, hand_seat, &%Player{ &1 | draw: List.delete_at(&1.draw, ix - hand_length) })
        end
    end
    # send them according to dir
    state = update_player(state, Utils.get_seat(hand_seat, dir), &%Player{ &1 | hand: &1.hand ++ Utils.remove_attr(&1.draw, ["_draw"]), draw: hand_tiles, status: MapSet.put(&1.status, "_charleston_completed") })
    state = Marking.mark_done(state, seat)

    # if everyone has charleston completed then we run after_charleston actions
    state = if Enum.all?(state.players, fn {_seat, player} -> "_charleston_completed" in player.status end) do
      state = update_all_players(state, fn _seat, player -> %Player{ player | status: MapSet.delete(player.status, "_charleston_completed") } end)
      trigger_event(state, "after_charleston", %{seat: seat})
    else state end
    state
  end

  defp translate_tile_alias(state, context, tile_alias) do
    case tile_alias do
      "draw" -> state.players[context.seat].draw
      "last_discard" -> if get_last_discard_action(state) != nil do [get_last_discard_action(state).tile] else [] end
      "last_called_tile" -> if get_last_call_action(state) != nil do [get_last_call_action(state).called_tile] else [] end
      [tile_alias | attrs] -> translate_tile_alias(state, context, tile_alias) |> Utils.add_attr(attrs)
      _      -> [Utils.to_tile(tile_alias)]
    end
  end

  defp set_tile_alias(state, seat, from_tiles, to_tiles) do
    from_tiles = MapSet.new(from_tiles)
    update_player(state, seat, fn player -> %Player{ player | tile_behavior: Map.update!(player.tile_behavior, :aliases, fn aliases ->
      for to <- to_tiles, reduce: aliases do
        aliases ->
          {to, attrs} = Utils.to_attr_tile(to)
          Map.update(aliases, to, %{attrs => from_tiles}, fn from -> Map.update(from, attrs, from_tiles, &MapSet.union(&1, from_tiles)) end)
      end
    end) } end)
  end

  def add_attr_matching(tiles, attrs, tile_specs, tile_behavior) do
    for tile <- tiles do
      if Riichi.tile_matches_all(tile_specs, %{tile: tile, tile_behavior: tile_behavior}) do
        Utils.add_attr(tile, attrs)
      else tile end
    end
  end

  def add_attr_tagged(tiles, attrs, tagged) do
    for tile <- tiles do
      if Utils.has_matching_tile?([tile], tagged) do
        Utils.add_attr(tile, attrs)
      else tile end
    end
  end

  def remove_attr_tagged(tiles, attrs, tagged) do
    for tile <- tiles do
      if Utils.has_matching_tile?([tile], tagged) do
        Utils.remove_attr(tile, attrs)
      else tile end
    end
  end

  defp call_function(state, context, fn_name, args) do
    if length(state.call_stack) < 10 do
      args = Map.new(args, fn {name, value} -> {"$" <> name, value} end)
      state = Map.update!(state, :call_stack, &[[fn_name | args] | &1])
      actions = Rules.get(state.rules_ref, "functions", %{}) |> Map.get(fn_name)
      if actions != nil do
        actions = Utils.walk_json(actions, &Map.get(args, &1, &1))
        if Debug.debug_actions() do
          IO.puts("Running function: #{inspect(actions)}")
        end
        state = run_actions(state, actions, context)
        state = Map.update!(state, :call_stack, &Enum.drop(&1, 1))
        state
      else
        IO.puts("Tried to call nonexistent function #{fn_name}!")
        state
      end
    else
      IO.puts("Cannot call function #{fn_name}: call stack limit reached")
      state
    end
  end

  defp move_all_tiles(state, seat, src_targets, destination, destination_ix, delete_src \\ true, copy_dst \\ true) do
    # remove tiles from source (in reverse ordering)
    state = if delete_src do
      src_targets
      |> Enum.sort_by(fn {_source, _tile, _seat, ix} -> -ix end)
      |> Enum.reduce(state, fn {source, _tile, seat, ix}, state ->
        case source do
          "hand" ->
            hand_length = length(state.players[seat].hand)
            if ix < hand_length do
              update_player(state, seat, &%Player{ &1 | hand: List.delete_at(&1.hand, ix) })
            else
              update_player(state, seat, &%Player{ &1 | draw: List.delete_at(&1.draw, ix - hand_length) })
            end
          "draw" -> update_player(state, seat, &%Player{ &1 | draw: List.delete_at(&1.draw, ix) })
          "calls" -> update_player(state, seat, &%Player{ &1 | calls: List.delete_at(&1.calls, ix) })
          "aside" -> update_player(state, seat, &%Player{ &1 | aside: List.delete_at(&1.aside, ix) })
          "discard" -> update_player(state, seat, &%Player{ &1 | pond: List.replace_at(&1.pond, ix, :"2x") })
          "dead_wall" -> Map.update!(state, :dead_wall, &List.replace_at(&1, ix, :"2x"))
          "atop_wall" -> Map.update!(state, :atop_wall, &Map.delete(&1, ix))
        end
      end)
    else state end
    # add tiles to dst (in original ordering)
    state = if copy_dst do
      Enum.reduce(src_targets, state, fn {_source, tile, _seat, _ix}, state ->
        case destination do
          "hand" -> update_player(state, seat, &%Player{ &1 | hand: &1.hand ++ [Utils.remove_attr(tile, ["_draw"])] })
          "draw" -> update_player(state, seat, &%Player{ &1 | draw: &1.draw ++ [tile] })
          "calls" -> update_player(state, seat, &%Player{ &1 | calls: &1.calls ++ [tile] })
          "aside" -> update_player(state, seat, &%Player{ &1 | aside: &1.aside ++ [tile] })
          "discard" -> update_player(state, seat, &%Player{ &1 | pond: &1.pond ++ [tile], discards: &1.discards ++ [tile] })
          "dead_wall" -> Map.update!(state, :dead_wall, &List.replace_at(&1, destination_ix, tile))
          "atop_wall" -> Map.update!(state, :atop_wall, &Map.update(&1, destination_ix, tile, fn _prev_tile -> tile end))
        end
      end)
    else state end
    state
  end

  defp get_move_tiles_targets(state, seat, source, opts) do
    all_seat_specs = Conditions.all_seat_specs()
    {flags, tile_specs} = Enum.split_with(opts, & &1 == "marked" or is_integer(&1) or &1 in all_seat_specs)
    marked_objects = state.marking[seat]
    seats = Enum.flat_map(flags, fn flag ->
      if flag in all_seat_specs do
        Conditions.from_seats_spec(state, %{seat: seat}, flag)
      else [seat] end
    end)
    Enum.flat_map(Enum.uniq([seat | seats]), fn seat ->
      case {source, "marked" in flags} do
        {"hand", false} -> state.players[seat].hand |> Enum.with_index() |> Enum.map(fn {tile, ix} -> {tile, seat, ix} end)
        {"draw", false} -> state.players[seat].draw |> Enum.with_index() |> Enum.map(fn {tile, ix} -> {tile, seat, ix} end)
        {"aside", false} -> state.players[seat].aside |> Enum.with_index() |> Enum.map(fn {tile, ix} -> {tile, seat, ix} end)
        {"calls", false} -> state.players[seat].calls |> Enum.with_index() |> Enum.map(fn {tile, ix} -> {tile, seat, ix} end)
        {"discard", false} -> state.players[seat].pond |> Enum.with_index() |> Enum.map(fn {tile, ix} -> {tile, seat, ix} end)
        {"revealed_tile", false} -> [] # unimplemented
        {"scry", false} -> [] # unimplemented
        {"dead_wall", false} -> flags |> Enum.filter(&is_integer/1) |> Enum.map(fn ix -> {Enum.at(state.dead_wall, ix, nil), nil, ix} end)
        {"atop_wall", false} -> flags |> Enum.filter(&is_integer/1) |> Enum.map(fn ix -> {Map.get(state.atop_wall, ix, nil), nil, ix} end)
        {"hand", true} -> Marking.get_marked(marked_objects, :hand)
        {"draw", true} -> [] # unimplemented
        {"aside", true} -> Marking.get_marked(marked_objects, :aside)
        {"calls", true} -> Marking.get_marked(marked_objects, :calls)
        {"discard", true} -> Marking.get_marked(marked_objects, :discard)
        {"revealed_tile", true} -> Marking.get_marked(marked_objects, :revealed_tile)
        {"scry", true} -> Marking.get_marked(marked_objects, :scry)
        {"dead_wall", true} -> [] # unimplemented
        {"atop_wall", true} -> [] # unimplemented
        _ -> 
          IO.puts("Unknown move_tiles target #{inspect(source)}")
          []
      end
    end)
    # note: allow nil tiles, because destination is often nil
    |> Enum.filter(fn {tile, _seat, _ix} -> Riichi.tile_matches_all(tile_specs, %{tile: tile}) end)
    |> Enum.map(fn {tile, seat, ix} -> {source, tile, seat, ix} end)
  end

  defp move_tiles(state, seat, src, dst, operation) do
    src = if is_map(src) do src else %{src => []} end
    src_targets = Enum.flat_map(src, fn {source, opts} -> get_move_tiles_targets(state, seat, source, opts) end)
    dst = if is_map(dst) do dst else %{dst => []} end
    dst_targets = Enum.flat_map(dst, fn {source, opts} -> get_move_tiles_targets(state, seat, source, opts) end)
    # IO.inspect(src_targets, label: "src_targets")
    # IO.inspect(dst_targets, label: "dst_targets")

    if operation == :swap do
      state = for {{source1, tile1, seat1, ix1}, {source2, tile2, seat2, ix2}} <- Enum.zip(src_targets, dst_targets), reduce: state do
        state ->
          # replace {source2, seat2} tile with tile1
          state = case source2 do
            "hand" ->
              hand_length = length(state.players[seat2].hand)
              if ix2 < hand_length do
                update_player(state, seat2, &%Player{ &1 | hand: List.replace_at(&1.hand, ix2, tile1) })
              else
                update_player(state, seat2, &%Player{ &1 | draw: List.replace_at(&1.draw, ix2 - hand_length, tile1) })
              end
            "draw" -> update_player(state, seat2, &%Player{ &1 | draw: List.replace_at(&1.draw, ix2, tile1) })
            "calls" -> update_player(state, seat2, &%Player{ &1 | calls: List.replace_at(&1.calls, ix2, tile1) })
            "aside" -> update_player(state, seat2, &%Player{ &1 | aside: List.replace_at(&1.aside, ix2, tile1) })
            "discard" -> update_player(state, seat2, &%Player{ &1 | pond: List.replace_at(&1.pond, ix2, tile1) })
            "revealed_tile" -> replace_revealed_tile(state, ix2, tile1)
            "scry" -> update_in(state.wall, &List.replace_at(&1, state.wall_index + ix2, tile1))
            "dead_wall" -> state # unimplemented
            "atop_wall" -> state # unimplemented
          end
          # replace {source1, seat1} tile with tile2
          state = case source1 do
            "hand" ->
              hand_length = length(state.players[seat1].hand)
              if ix1 < hand_length do
                update_player(state, seat1, &%Player{ &1 | hand: List.replace_at(&1.hand, ix1, tile2) })
              else
                update_player(state, seat1, &%Player{ &1 | draw: List.replace_at(&1.draw, ix1 - hand_length, tile2) })
              end
            "draw" -> update_player(state, seat1, &%Player{ &1 | draw: List.replace_at(&1.draw, ix1, tile2) })
            "calls" -> update_player(state, seat1, &%Player{ &1 | calls: List.replace_at(&1.calls, ix1, tile2) })
            "aside" -> update_player(state, seat1, &%Player{ &1 | aside: List.replace_at(&1.aside, ix1, tile2) })
            "discard" -> update_player(state, seat1, &%Player{ &1 | pond: List.replace_at(&1.pond, ix1, tile2) })
            "revealed_tile" -> replace_revealed_tile(state, ix1, tile2)
            "scry" -> update_in(state.wall, &List.replace_at(&1, state.wall_index + ix1, tile2))
            "dead_wall" -> state # unimplemented
            "atop_wall" -> state # unimplemented
          end
          state = update_action(state, seat, :swap, %{
            tile1: {tile1, seat1, ix1, Marking.mark_targets()[source1]},
            tile2: {tile2, seat2, ix2, Marking.mark_targets()[source2]},
          })
          state
      end
      state = if length(src_targets) < length(dst_targets) do
        remaining_dst = Enum.drop(dst_targets, length(src_targets))
        case Enum.at(src_targets, 0) do
          {source, _, seat, ix} -> move_all_tiles(state, seat, remaining_dst, source, ix)
          _                    -> state
        end
      else state end
      state = if length(src_targets) > length(dst_targets) do
        remaining_src = Enum.drop(src_targets, length(dst_targets))
        case Enum.at(dst_targets, 0) do
          {source, _, seat, ix} -> move_all_tiles(state, seat, remaining_src, source, ix)
          _                    -> state
        end
      else state end
      state
    else
      # assert that there's only one entry in dst
      if map_size(dst) == 1 do
        {source, ix} = case dst_targets do
          [{source, _tile, _seat, ix} | _] -> {source, ix}
          _ -> {Map.keys(dst) |> Enum.at(0), nil}
        end
        # TODO perhaps allow for other seats to be targeted
        # by using flags in dst[destination] to determine the seat
        move_all_tiles(state, seat, src_targets, source, ix, operation in [:move, :delete], operation in [:move, :copy])
      else
        IO.puts("Moving with more than one destination not implemented: #{inspect(dst_targets)}")
        state
      end
    end
  end

  def declare_yaku(state, seat) do
    yaku_string = Enum.map(state.players[seat].declared_yaku, fn yaku -> %{bold: true, text: yaku} end)
    push_message(state, player_prefix(state, seat) ++ [%{text: "declared the following yaku:"}] ++ yaku_string)
    state
  end

  defp _run_actions(state, [], _context), do: {state, []}
  defp _run_actions(state, [[action | opts] | actions], context) do
    buttons_before = Enum.map(state.players, fn {seat, player} -> {seat, player.buttons} end)
    marked_objects = state.marking[context.seat]
    uninterruptible = String.starts_with?(action, "uninterruptible_")
    action = if uninterruptible do String.replace_leading(action, "uninterruptible_", "") else action end
    state = case action do
      "noop"                  -> state
      "print"                 ->
        IO.puts(interpolate_string(state, context, Enum.at(opts, 0, ""), Enum.at(opts, 1, %{})))
        state
      "inspect"               ->
        IO.inspect(opts)
        state
      "print_status"          ->
        for seat <- Conditions.from_seats_spec(state, context, Enum.at(opts, 0, "self")) do
          IO.inspect({seat, state.players[seat].status})
        end
        state
      "print_counters"         ->
        for seat <- Conditions.from_seats_spec(state, context, Enum.at(opts, 0, "self")) do
          IO.inspect({seat, state.players[seat].counters})
        end
        state
      "print_pao_map"         ->
        for seat <- Conditions.from_seats_spec(state, context, Enum.at(opts, 0, "self")) do
          IO.inspect({seat, state.players[seat].pao_map})
        end
        state
      "print_context"         ->
        IO.inspect(context)
        state
      "print_hand"         ->
        for seat <- Conditions.from_seats_spec(state, context, Enum.at(opts, 0, "self")) do
          IO.inspect({seat, state.players[seat].hand, state.players[seat].draw, state.players[seat].calls})
        end
        state
      "print_discards"         ->
        for seat <- Conditions.from_seats_spec(state, context, Enum.at(opts, 0, "self")) do
          IO.inspect({seat, state.players[seat].discards})
        end
        state
      "print_tags"         ->
        IO.inspect(state.tags)
        state
      "push_message"          ->
        vars = Enum.at(opts, 1, %{})
        message = interpolate_string(state, context, Enum.at(opts, 0, ""), vars)
        # IO.inspect(["Player #{player_name(state, context.seat)}", message], label: "Sent message")
        push_message(state, player_prefix(state, context.seat) ++ [%{text: message, vars: map_var_amounts(state, context, vars)}])
        state
      "push_system_message"   ->
        vars = Enum.at(opts, 1, %{})
        message = interpolate_string(state, context, Enum.at(opts, 0, ""), vars)
        push_message(state, [%{text: message, vars: map_var_amounts(state, context, vars)}])
        state
      "add_rule"             ->
        tab = Enum.at(opts, 0, "Rules")
        id = Enum.at(opts, 1, "")
        text = Enum.at(opts, 2, "")
        {tab, id, text, vars, priority} = if is_map(Enum.at(opts, 3)) do
          vars = Enum.at(opts, 3, %{})
          tab = interpolate_string(state, context, tab, vars)
          id = interpolate_string(state, context, id, vars)
          text = interpolate_string(state, context, text, vars)
          priority = Enum.at(opts, 4, nil)
          {tab, id, text, vars, priority}
        else {tab, id, text, %{}, Enum.at(opts, 3, nil)} end
        state = if not Map.has_key?(state.rules_text, tab) do
          state = put_in(state.rules_text[tab], %{})
          state = update_in(state.rules_text_order, & &1 ++ [tab])
          state
        else state end
        update_in(state.rules_text[tab], &Map.update(&1, id,
          {[text], map_var_amounts(state, context, vars), if priority == nil do 0 else priority end},
          fn {orig_text, orig_vars, orig_priority} -> {
              orig_text ++ [text],
              Map.merge(orig_vars, map_var_amounts(state, context, vars)),
              priority || orig_priority
          } end)
        )
      "update_rule"             ->
        tab = Enum.at(opts, 0, "Rules")
        id = Enum.at(opts, 1, "")
        text = Enum.at(opts, 2, "")
        {tab, id, text, vars, priority} = if is_map(Enum.at(opts, 3)) do
          vars = Enum.at(opts, 3, %{})
          tab = String.trim(interpolate_string(state, context, tab, vars))
          id = String.trim(interpolate_string(state, context, id, vars))
          text = interpolate_string(state, context, text, vars)
          priority = Enum.at(opts, 4, nil)
          {tab, id, text, vars, priority}
        else {tab, id, text, %{}, Enum.at(opts, 3, nil)} end
        if Map.has_key?(state.rules_text, tab) and Map.has_key?(state.rules_text[tab], id) do
          update_in(state.rules_text[tab], &Map.update!(&1, id,
            fn {orig_text, orig_vars, orig_priority} -> {
                if text in orig_text do orig_text else orig_text ++ [text] end,
                Map.merge(orig_vars, map_var_amounts(state, context, vars)),
                priority || orig_priority
            } end)
          )
        else state end
      "delete_rule"             ->
        tab = Enum.at(opts, 0, "Rules")
        id = Enum.at(opts, 1, "")
        {tab, id} = if is_map(Enum.at(opts, 3)) do
          vars = Enum.at(opts, 3, %{})
          tab = String.trim(interpolate_string(state, context, tab, vars))
          id = String.trim(interpolate_string(state, context, id, vars))
          {tab, id}
        else {tab, id} end
        if Map.has_key?(state.rules_text, tab) and Map.has_key?(state.rules_text[tab], id) do
          update_in(state.rules_text[tab], &Map.delete(&1, id))
        else state end
      "add_rule_tab"             ->
        tab = String.trim(interpolate_string(state, context, Enum.at(opts, 0, "Rules"), Enum.at(opts, 1, %{})))
        if not Map.has_key?(state.rules_text, tab) do
          state = put_in(state.rules_text[tab], %{})
          state = update_in(state.rules_text_order, & &1 ++ [tab])
          state
        else state end
      "run"                   -> call_function(state, context, Enum.at(opts, 0, "noop"), Enum.at(opts, 1, %{}))
      "play_tile"             -> play_tile(state, context.seat, Enum.at(opts, 0, :"1m"), Enum.at(opts, 1, 0))
      "draw"                  -> draw_tile(state, context.seat, Enum.at(opts, 0, 1), Enum.at(opts, 1, nil), false)
      "draw_aside"            -> draw_tile(state, context.seat, Enum.at(opts, 0, 1), Enum.at(opts, 1, nil), true)
      "call"                  -> trigger_call(state, context.seat, context.choice.name, context.choice.chosen_call_choice, context.choice.chosen_called_tile, :discards)
      "self_call"             -> trigger_call(state, context.seat, context.choice.name, context.choice.chosen_call_choice, context.choice.chosen_called_tile, :hand)
      "upgrade_call"          -> upgrade_call(state, context.seat, context.choice.name, context.choice.chosen_call_choice, context.choice.chosen_called_tile)
      "flower"                -> trigger_call(state, context.seat, context.choice.name, context.choice.chosen_call_choice, nil, :hand)
      "trigger_custom_call"   ->
        name = Enum.at(opts, 0, "")
        source = case Enum.at(opts, 1, "") do
          "discards" -> :discards
          _          -> :hand
        end
        {call_choice, _calls} = Conditions.get_hand_calls_spec(state, context, Enum.at(opts, 2, [])) |> Enum.at(0)
        {called_tiles, _calls} = Conditions.get_hand_calls_spec(state, context, Enum.at(opts, 3, [])) |> Enum.at(0)
        called_tile = Enum.at(called_tiles, 0)
        trigger_call(state, context.seat, name, call_choice, called_tile, source)
      "draft_saki_card"       -> Saki.draft_saki_card(state, context.seat, context.choice.chosen_saki_card)
      "reverse_turn_order"    -> Map.update!(state, :reversed_turn_order, &not &1)
      "advance_turn"          -> advance_turn(state)
      "change_turn"           -> change_turn(state, Conditions.from_seat_spec(state, context, Enum.at(opts, 0, "self")), true)
      "win_by_discard"        -> win(state, context.seat, :discard)
      "win_by_call"           -> win(state, context.seat, :call)
      "win_by_draw"           -> win(state, context.seat, :draw)
      "win_by_second_visible_discard" -> win(state, context.seat, :second_discard)
      "ryuukyoku"             -> exhaustive_draw(state, Enum.at(opts, 0, nil))
      "abortive_draw"         -> abortive_draw(state, Enum.at(opts, 0, nil))
      "set_status"            -> update_player(state, context.seat, fn player -> %Player{ player | status: MapSet.union(player.status, MapSet.new(opts)) } end)
      "unset_status"          -> update_player(state, context.seat, fn player -> %Player{ player | status: MapSet.difference(player.status, MapSet.new(opts)) } end)
      "set_status_all"        -> update_all_players(state, fn _seat, player -> %Player{ player | status: MapSet.union(player.status, MapSet.new(opts)) } end)
      "unset_status_all"      -> update_all_players(state, fn _seat, player -> %Player{ player | status: MapSet.difference(player.status, MapSet.new(opts)) } end)
      "set_counter"           -> set_counter(state, context, Enum.at(opts, 0, "counter"), Enum.drop(opts, 1))
      "set_counter_all"       -> set_counter_all(state, context, Enum.at(opts, 0, "counter"), Enum.drop(opts, 1))
      "add_counter"           -> add_counter(state, context, Enum.at(opts, 0, "counter"), Enum.drop(opts, 1))
      "subtract_counter"      -> subtract_counter(state, context, Enum.at(opts, 0, "counter"), Enum.drop(opts, 1))
      "multiply_counter"      -> multiply_counter(state, context, Enum.at(opts, 0, "counter"), Enum.drop(opts, 1))
      "divide_counter"        -> divide_counter(state, context, Enum.at(opts, 0, "counter"), Enum.drop(opts, 1))
      "big_text"              -> temp_display_big_text(state, context.seat, interpolate_string(state, context, Enum.at(opts, 0, ""), Enum.at(opts, 1, %{})))
      "pause"                 ->
        if not state.log_loading_mode do
          Map.put(state, :game_active, false)
        else state end
      "sort_hand"             ->
        {hand, orig_ixs} = Enum.with_index(state.players[context.seat].hand)
        |> Enum.sort_by(fn {tile, _ix} -> Constants.sort_value(tile) end)
        |> Enum.unzip()
        ix_map = Enum.with_index(orig_ixs) |> Map.new()
        # map marked tiles' indices
        state = update_in(state.marking[context.seat], &Enum.map(&1, fn {key, val} ->
          if key == :hand do
            {key, update_in(val.marked, fn marked -> Enum.map(marked, fn {tile, seat, ix} -> {tile, seat, Map.get(ix_map, ix, ix)} end) end)}
          else {key, val} end
        end))
        # map playable_indices
        playable_indices = state.players[context.seat].cache.playable_indices
        playable_indices = if is_list(playable_indices) do Enum.map(playable_indices, &Map.get(ix_map, &1, &1)) else playable_indices end
        # set hand and playable_indices
        update_player(state, context.seat, fn player -> %Player{ player | hand: hand, cache: %PlayerCache{ player.cache | playable_indices: playable_indices } } end)
      "reveal_tile"           ->
        tile_name = Enum.at(opts, 0, :"1m")
        if Utils.is_tile(tile_name) do
          state = Map.update!(state, :revealed_tiles, fn tiles -> tiles ++ [tile_name] end)
          state
        else
          tile_name = interpret_amount(state, context, tile_name)
          state = Map.update!(state, :revealed_tiles, fn tiles -> tiles ++ [tile_name] end)
          state = Log.log(state, context.seat, :dora_flip, %{dora_count: length(state.revealed_tiles), dora_indicator: from_named_tile(state, context, tile_name)})
          state
        end
      "add_score"             ->
        amount = interpret_amount(state, context, Enum.at(opts, 0, 0))
        recipients = Conditions.from_seats_spec(state, context, Enum.at(opts, 1, "self"))
        for recipient <- recipients, reduce: state do
          state -> update_player(state, recipient, fn player -> %Player{ player | score: player.score + amount } end)
        end
      "subtract_score"             ->
        amount = -interpret_amount(state, context, Enum.at(opts, 0, 0))
        recipients = Conditions.from_seats_spec(state, context, Enum.at(opts, 1, "self"))
        for recipient <- recipients, reduce: state do
          state -> update_player(state, recipient, fn player -> %Player{ player | score: player.score + amount } end)
        end
      "put_down_riichi_stick" ->
        riichi_discard_indices = Map.new(state.players, fn {seat, player} -> {seat, length(player.discards)} end)
        riichi_value = Rules.get(state.rules_ref, "score_calculation", %{}) |> Map.get("riichi_value", 0)
        state
        |> Map.update!(:pot, & &1 + Enum.at(opts, 0, 1) * riichi_value)
        |> update_player(context.seat, &%Player{ &1 | riichi_stick: true, cache: %PlayerCache{ &1.cache | riichi_discard_indices: riichi_discard_indices } })
      "bet_points"            ->
        amount = interpret_amount(state, context, opts)
        state
        |> Map.update!(:pot, & &1 + amount)
        |> update_player(context.seat, &%Player{ &1 | score: &1.score - amount })
      "add_honba"             -> Map.update!(state, :honba, & &1 + interpret_amount(state, context, Enum.at(opts, 0, 1)))
      "reveal_hand"           -> update_player(state, context.seat, fn player -> %Player{ player | hand_revealed: true } end)
      "reveal_other_hands"    -> update_all_players(state, fn seat, player -> %Player{ player | hand_revealed: player.hand_revealed or seat != context.seat } end)
      "discard_draw"          ->
        if not state.log_seeking_mode and not state.log_loading_mode do
          GenServer.cast(self(), {:play_tile, context.seat, length(state.players[context.seat].hand)})
        end
        state
      "press_button"          ->
        if not state.log_seeking_mode and not state.log_loading_mode do
          GenServer.cast(self(), {:press_button, context.seat, Enum.at(opts, 0, "skip")})
        end
        state
      "press_first_call_button" ->
        if not state.log_seeking_mode and not state.log_loading_mode do
          GenServer.cast(self(), {:press_first_call_button, context.seat, Enum.at(opts, 0, "skip")})
        end
        state
      "when"                  -> if Conditions.check_cnf_condition(state, Enum.at(opts, 0, []), context) do run_actions(state, Enum.at(opts, 1, []), context) else state end
      "unless"                -> if Conditions.check_cnf_condition(state, Enum.at(opts, 0, []), context) do state else run_actions(state, Enum.at(opts, 1, []), context) end
      "ite"                   -> if Conditions.check_cnf_condition(state, Enum.at(opts, 0, []), context) do run_actions(state, Enum.at(opts, 1, []), context) else run_actions(state, Enum.at(opts, 2, []), context) end
      "as"                    ->
        for dir <- Conditions.from_seats_spec(state, context, Enum.at(opts, 0, [])), reduce: state do
          state -> run_actions(state, Enum.at(opts, 1, []), Map.merge(context, %{seat: dir, prev_seat: context.seat}))
        end
      "when_anyone"           ->
        for dir <- state.available_seats, Conditions.check_cnf_condition(state, Enum.at(opts, 0, []), %{context | seat: dir}), reduce: state do
          state -> run_actions(state, Enum.at(opts, 1, []), %{context | seat: dir})
        end
      "when_everyone"           ->
        if Enum.all?(state.available_seats, fn dir -> Conditions.check_cnf_condition(state, Enum.at(opts, 0, []), %{context | seat: dir}) end) do
          run_actions(state, Enum.at(opts, 1, []), context)
        else state end
      "when_others"           ->
        if Enum.all?(state.available_seats -- [context.seat], fn dir -> Conditions.check_cnf_condition(state, Enum.at(opts, 0, []), %{context | seat: dir}) end) do
          run_actions(state, Enum.at(opts, 1, []), context)
        else state end
      "mark" -> state # no-op
      "move_tiles" -> move_tiles(state, context.seat, Enum.at(opts, 0, %{}), Enum.at(opts, 1, nil), :move)
      "swap_tiles" -> move_tiles(state, context.seat, Enum.at(opts, 0, %{}), Enum.at(opts, 1, nil), :swap)
      "copy_tiles" -> move_tiles(state, context.seat, Enum.at(opts, 0, %{}), Enum.at(opts, 1, nil), :copy)
      "delete_tiles" -> move_tiles(state, context.seat, Enum.at(opts, 0, %{}), nil, :delete)
      "swap_marked_calls" ->
        marked_call = Marking.get_marked(marked_objects, :calls)
        {call1, call_seat1, call_index1} = Enum.at(marked_call, 0)
        {call2, call_seat2, call_index2} = Enum.at(marked_call, 1)

        state = update_player(state, call_seat1, &%Player{ &1 | calls: List.replace_at(&1.calls, call_index1, call2) })
        state = update_player(state, call_seat2, &%Player{ &1 | calls: List.replace_at(&1.calls, call_index2, call1) })

        state = Marking.mark_done(state, context.seat)
        state
      "swap_out_fly_joker" ->
        {tile, hand_seat, hand_index} = Marking.get_marked(marked_objects, :hand) |> Enum.at(0)
        {call, call_seat, call_index} = Marking.get_marked(marked_objects, :calls) |> Enum.at(0)
        fly_joker = Enum.at(opts, 0, "1j") |> Utils.to_tile()
        call_tiles = Utils.call_to_tiles(call)

        call_joker_index = Enum.find_index(call_tiles, &Utils.same_tile(&1, fly_joker))
        new_call = with {call_type, call_content} <- call do
          {call_type, List.update_at(call_content, call_joker_index, &Utils.replace_base_tile(&1, tile))}
        end
        push_message(state, player_prefix(state, context.seat) ++ [
          %{text: "swapped out a joker from the call %{call}", vars: %{call: {:hand, call_tiles}}}
        ])

        # replace hand tile with joker
        hand_length = length(state.players[hand_seat].hand)
        state = if hand_index < hand_length do
          update_player(state, hand_seat, &%Player{ &1 | hand: List.replace_at(&1.hand, hand_index, fly_joker) })
        else
          update_player(state, hand_seat, &%Player{ &1 | draw: List.replace_at(&1.draw, hand_index - hand_length, fly_joker) })
        end

        # replace call with new call
        state = update_player(state, call_seat, &%Player{ &1 | calls: List.replace_at(&1.calls, call_index, new_call) })

        state = Marking.mark_done(state, context.seat)
        state
      "extend_live_wall_with_marked" ->
        marked_hand = Marking.get_marked(marked_objects, :hand)
        marked_scry = Marking.get_marked(marked_objects, :scry)
        {state, hand_tiles} = if not Enum.empty?(marked_hand) do
          {_, hand_seat, _} = Enum.at(marked_hand, 0)
          {hand_tiles, hand_indices} = marked_hand
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
          {state, hand_tiles}
        else {state, []} end

        {state, scry_tiles} = if not Enum.empty?(marked_scry) do
          {scry_tiles, scry_indices} = marked_scry
          |> Enum.map(fn {tile, _seat, ix} -> {tile, ix} end)
          |> Enum.unzip()
          state = for _i <- scry_indices, reduce: state do
            state -> update_in(state.wall, &List.delete_at(&1, state.wall_index))
          end
          state = update_all_players(state, fn _seat, player -> %Player{ player | num_scryed_tiles: 0 } end)
          {state, scry_tiles}
        else {state, []} end

        # place them at the end of the live wall
        state = for tile <- (hand_tiles ++ scry_tiles), reduce: state do
          state -> Map.update!(state, :wall, fn wall -> List.insert_at(wall, -1, tile) end)
        end
        state = Marking.mark_done(state, context.seat)
        state
      "extend_dead_wall_with_marked" ->
        marked_hand = Marking.get_marked(marked_objects, :hand)
        {_, hand_seat, _} = Enum.at(marked_hand, 0)
        {hand_tiles, hand_indices} = marked_hand
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
        state = Marking.mark_done(state, context.seat)
        state
      "pon_marked_discard" ->
        {discard_tile, discard_seat, discard_index} = Marking.get_marked(marked_objects, :discard) |> Enum.at(0)

        # replace pond tile with blank
        state = update_player(state, discard_seat, &%Player{ &1 | pond: List.replace_at(&1.pond, discard_index, :"2x") })

        # remove tiles from hand
        call_choice = [:"7z", :"7z"]
        state = update_player(state, context.seat, &%Player{ &1 | hand: &1.hand -- call_choice })

        # make call
        call_style = %{kamicha: ["call_sideways", 0, 1], toimen: [0, "call_sideways", 1], shimocha: [0, 1, "call_sideways"]}
        style = call_style[Utils.get_relative_seat(context.seat, discard_seat)]
        call = style_call(style, call_choice, discard_tile)
        call = {"pon", call}
        state = update_player(state, context.seat, &%Player{ &1 | calls: &1.calls ++ [call] })
        state = update_action(state, context.seat, :call, %{from: discard_seat, called_tile: discard_tile, other_tiles: call_choice, call_name: "pon"})
        state = trigger_event(state, "after_call", %{seat: context.seat, callee: discard_seat, caller: context.seat, call: call})
        state = Marking.mark_done(state, context.seat)
        state
      "flip_marked_discard_facedown" ->
        {_discard_tile, discard_seat, discard_index} = Marking.get_marked(marked_objects, :discard) |> Enum.at(0)
        state = update_in(state.players[discard_seat].pond, &List.update_at(&1, discard_index, fn tile -> Utils.add_attr(tile, ["_facedown"]) end))
        state = Marking.mark_done(state, context.seat)
        state
      "clear_marking"         -> Marking.mark_done(state, context.seat)
      "set_tile_alias"        ->
        from_tiles = Enum.at(opts, 0, []) |> Enum.flat_map(&translate_tile_alias(state, context, &1))
        to_tiles = Enum.at(opts, 1, []) |> Enum.map(&Utils.to_tile/1)
        set_tile_alias(state, context.seat, from_tiles, to_tiles)
      "set_tile_alias_all"        ->
        from_tiles = Enum.at(opts, 0, []) |> Enum.flat_map(&translate_tile_alias(state, context, &1))
        to_tiles = Enum.at(opts, 1, []) |> Enum.map(&Utils.to_tile/1)
        for seat <- state.available_seats, reduce: state do
          state -> set_tile_alias(state, seat, from_tiles, to_tiles)
        end
      "save_tile_behavior"     ->
        label = Enum.at(opts, 0, "default")
        for seat <- state.available_seats, reduce: state do
          state -> put_in(state.players[seat].cache.saved_tile_behavior[label], state.players[seat].tile_behavior)
        end
      "load_tile_behavior"     ->
        label = Enum.at(opts, 0, "default")
        for seat <- state.available_seats, reduce: state do
          state -> put_in(state.players[seat].tile_behavior, Map.get(state.players[seat].cache.saved_tile_behavior, label, state.players[seat].tile_behavior))
        end
      "clear_tile_aliases"    -> update_player(state, context.seat, &%Player{ &1 | tile_behavior: %TileBehavior{ &1.tile_behavior | aliases: %{} } })
      "set_tile_ordering"     ->
        tiles = Enum.map(Enum.at(opts, 0, []), &Utils.to_tile/1)
        ordering = Enum.zip(Enum.drop(tiles, -1), Enum.drop(tiles, 1)) |> Map.new()
        ordering_r = Enum.zip(Enum.drop(tiles, 1), Enum.drop(tiles, -1)) |> Map.new()
        update_player(state, context.seat, &%Player{ &1 | tile_behavior: %TileBehavior{ &1.tile_behavior |
          ordering: Map.merge(&1.tile_behavior.ordering, ordering),
          ordering_r: Map.merge(&1.tile_behavior.ordering_r, ordering_r)
        } })
      "set_tile_ordering_all" ->
        tiles = Enum.map(Enum.at(opts, 0, []), &Utils.to_tile/1)
        ordering = Enum.zip(Enum.drop(tiles, -1), Enum.drop(tiles, 1)) |> Map.new()
        ordering_r = Enum.zip(Enum.drop(tiles, 1), Enum.drop(tiles, -1)) |> Map.new()
        update_all_players(state, fn _seat, player -> %Player{ player | tile_behavior: %TileBehavior{ player.tile_behavior |
          ordering: Map.merge(player.tile_behavior.ordering, ordering),
          ordering_r: Map.merge(player.tile_behavior.ordering_r, ordering_r)
        } } end)
      "add_attr" ->
        targets = Enum.at(opts, 0, [])
        attrs = List.wrap(Enum.at(opts, 1, []))
        tile_specs = Enum.at(opts, 2, [])
        tile_behavior = state.players[context.seat].tile_behavior
        for target <- targets, reduce: state do
          state ->
            case target do
              "hand" -> update_in(state.players[context.seat].hand, &add_attr_matching(&1, attrs, tile_specs, tile_behavior))
              "draw" -> update_in(state.players[context.seat].draw, &add_attr_matching(&1, attrs, tile_specs, tile_behavior))
              "calls" -> update_in(state.players[context.seat].calls, &Enum.map(&1, fn {name, call} -> {name, add_attr_matching(call, attrs, tile_specs, tile_behavior)} end))
              "aside" -> update_in(state.players[context.seat].aside, &add_attr_matching(&1, attrs, tile_specs, tile_behavior))
              "last_discard" -> update_winning_tile(state, context.seat, :discard, fn tile -> add_attr_matching([tile], attrs, tile_specs, tile_behavior) |> Enum.at(0) end)
              "last_called_tile" -> update_winning_tile(state, context.seat, :call, fn tile -> add_attr_matching([tile], attrs, tile_specs, tile_behavior) |> Enum.at(0) end)
              "winning_tile" -> update_winning_tile(state, context.seat, Map.get(context, :win_source, nil), fn tile -> add_attr_matching([tile], attrs, tile_specs, tile_behavior) |> Enum.at(0) end)
              _ when is_integer(target) -> update_in(state.dead_wall, fn dead_wall -> List.update_at(dead_wall, target, &add_attr_matching([&1], attrs, tile_specs, tile_behavior) |> Enum.at(0)) end)
              _      ->
                IO.inspect("Unhandled add_attr target #{inspect(target)}")
                state
            end
        end
      "add_attr_first_tile"   ->
        tile = Enum.at(opts, 0, :"1x") |> Utils.to_tile()
        attrs = List.wrap(Enum.at(opts, 1, []))
        ix = Enum.find_index(state.players[context.seat].hand ++ state.players[context.seat].draw, fn t -> Utils.same_tile(t, tile) end)
        hand_len = length(state.players[context.seat].hand)
        cond do
          ix == nil -> state
          ix < hand_len ->
            update_player(state, context.seat, &%Player{ &1 | hand: List.update_at(&1.hand, ix, fn t -> Utils.add_attr(t, attrs) end) })
          true ->
            update_player(state, context.seat, &%Player{ &1 | draw: List.update_at(&1.draw, ix - hand_len, fn t -> Utils.add_attr(t, attrs) end) })
        end
      "add_attr_tagged"   ->
        tag = Enum.at(opts, 0, "missing_tag")
        tagged = Map.get(state.tags, tag, MapSet.new())
        attrs = List.wrap(Enum.at(opts, 1, []))
        # update every zone i guess
        state = update_in(state.wall, &add_attr_tagged(&1, attrs, tagged))
        state = update_in(state.dead_wall, &add_attr_tagged(&1, attrs, tagged))
        state = for seat <- state.available_seats, reduce: state do
          state ->
            state = update_in(state.players[seat].hand, &add_attr_tagged(&1, attrs, tagged))
            state = update_in(state.players[seat].draw, &add_attr_tagged(&1, attrs, tagged))
            state = update_in(state.players[seat].aside, &add_attr_tagged(&1, attrs, tagged))
            state = update_in(state.players[seat].pond, &add_attr_tagged(&1, attrs, tagged))
            state = update_in(state.players[seat].discards, &add_attr_tagged(&1, attrs, tagged))
            state = update_in(state.players[seat].calls, &Enum.map(&1, fn {name, call} -> {name, add_attr_tagged(call, attrs, tagged)} end))
            state
        end
        state
      "remove_attr_tagged"   ->
        tag = Enum.at(opts, 0, "missing_tag")
        tagged = Map.get(state.tags, tag, MapSet.new())
        attrs = List.wrap(Enum.at(opts, 1, []))
        # update every zone i guess
        state = update_in(state.wall, &remove_attr_tagged(&1, attrs, tagged))
        state = update_in(state.dead_wall, &remove_attr_tagged(&1, attrs, tagged))
        state = for seat <- state.available_seats, reduce: state do
          state ->
            state = update_in(state.players[seat].hand, &remove_attr_tagged(&1, attrs, tagged))
            state = update_in(state.players[seat].draw, &remove_attr_tagged(&1, attrs, tagged))
            state = update_in(state.players[seat].aside, &remove_attr_tagged(&1, attrs, tagged))
            state = update_in(state.players[seat].pond, &remove_attr_tagged(&1, attrs, tagged))
            state = update_in(state.players[seat].discards, &remove_attr_tagged(&1, attrs, tagged))
            state = update_in(state.players[seat].calls, &Enum.map(&1, fn {name, call} -> {name, remove_attr_tagged(call, attrs, tagged)} end))
            state
        end
        state
      "remove_attr_hand"      ->
        # TODO generalize to remove_attr
        state = update_player(state, context.seat, &%Player{ &1 | hand: Utils.remove_attr(&1.hand, opts) })
        state
      "remove_attr_all"       ->
        # TODO generalize to remove_attr
        state = update_player(state, context.seat, &%Player{ &1 | hand: Utils.remove_attr(&1.hand, opts), draw: Utils.remove_attr(&1.draw, opts), aside: Utils.remove_attr(&1.aside, opts) })
        state
      "tag_tiles"             ->
        tag = Enum.at(opts, 0, "missing_tag")
        tiles = List.wrap(Enum.at(opts, 1, [:"1x"]))
        |> Enum.flat_map(&case &1 do
          "last_discard" -> if get_last_discard_action(state) != nil do [get_last_discard_action(state).tile] else [] end
          "all" -> TileBehavior.get_all_tiles(state.players[context.seat].tile_behavior)
          _ -> [from_named_tile(state, context, &1)]
        end)
        state = Map.update!(state, :tags, fn tags -> Map.update(tags, tag, MapSet.new(tiles), &MapSet.union(&1, MapSet.new(tiles))) end)
        state
      "tag_drawn_tile"        ->
        tag = Enum.at(opts, 0, "missing_tag")
        tile = Enum.at(state.players[context.seat].draw, 0, :"1x")
        state = Map.update!(state, :tags, fn tags -> Map.update(tags, tag, MapSet.new([tile]), &MapSet.put(&1, tile)) end)
        state
      "tag_last_discard"      ->
        tag = Enum.at(opts, 0, "missing_tag")
        tile = get_last_discard_action(state).tile
        state = put_in(state.tags[tag], tile)
        state = Map.update!(state, :tags, fn tags -> Map.update(tags, tag, MapSet.new([tile]), &MapSet.put(&1, tile)) end)
        state
      "tag_dora"              ->
        tag = Enum.at(opts, 0, "missing_tag")
        named_tile = Enum.at(opts, 1, -1)
        dora_indicator = from_named_tile(state, context, named_tile)
        dora_indicators_map = Rules.get(state.rules_ref, "dora_indicators", %{})
        doras = Map.get(dora_indicators_map, Utils.tile_to_string(dora_indicator), [])
        |> Enum.map(&Utils.to_tile/1)
        state = Map.update!(state, :tags, fn tags -> Map.update(tags, tag, MapSet.new(doras), &MapSet.union(&1, MapSet.new(doras))) end)
        state
      "untag_tiles"           ->
        tag = Enum.at(opts, 0, "missing_tag")
        tiles = List.wrap(Enum.at(opts, 1, [:"1x"]))
        |> Enum.flat_map(&case &1 do
          "last_discard" -> if get_last_discard_action(state) != nil do [get_last_discard_action(state).tile] else [] end
          "all" -> TileBehavior.get_all_tiles(state.players[context.seat].tile_behavior)
          _ -> [from_named_tile(state, context, &1)]
        end)
        state = Map.update!(state, :tags, fn tags -> Map.update(tags, tag, MapSet.new(tiles), &MapSet.difference(&1, MapSet.new(tiles))) end)
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
        state = Buttons.recalculate_buttons(state) # TODO remove
        state
      "flip_all_calls_faceup"  ->
        update_all_players(state, fn _seat, player ->
          faceup_calls = Enum.map(player.calls, fn {call_name, call} -> {call_name, Utils.remove_attr(call, ["_facedown"])} end)
          %Player{ player | calls: faceup_calls }
        end)
      "flip_first_visible_discard_facedown" -> 
        ix = Enum.find_index(state.players[context.seat].pond, fn tile -> not Utils.has_attr?(tile, ["_facedown"]) and not Utils.same_tile(tile, :"1x") and not Utils.same_tile(tile, :"2x") end)
        if ix != nil do
          update_in(state.players[context.seat].pond, &List.update_at(&1, ix, fn tile -> Utils.add_attr(tile, ["_facedown"]) end))
        else state end
      "flip_aside_facedown" -> update_in(state.players[context.seat].aside, &Enum.map(&1, fn tile -> Utils.add_attr(tile, ["_facedown"]) end))
      # "shuffle_aside"      -> update_in(state.players[context.seat].aside, &Enum.shuffle/1)
      "draw_from_aside"    ->
        state = case state.players[context.seat].aside do
          [] -> state
          [tile | aside] -> update_player(state, context.seat, &%Player{ &1 | draw: &1.draw ++ [Utils.add_attr(tile, ["_draw"])], aside: aside })
        end
        state
      "charleston_left" -> do_charleston(state, :kamicha, context.seat, marked_objects)
      "charleston_across" -> do_charleston(state, :toimen, context.seat, marked_objects)
      "charleston_right" -> do_charleston(state, :shimocha, context.seat, marked_objects)
      "shift_tile_to_dead_wall" -> 
        amount = interpret_amount(state, context, Enum.at(opts, 0, 1))
        {wall, tiles} = Enum.split(state.wall, -amount)
        state
        |> Map.put(:wall, wall)
        |> Map.put(:dead_wall, tiles ++ state.dead_wall)
      "resume_deferred_actions" -> resume_deferred_actions(state)
      "cancel_deferred_actions" -> update_all_players(state, fn _seat, player -> %Player{ player | deferred_actions: [], deferred_context: %{} } end)
      "recalculate_buttons" -> Buttons.recalculate_buttons(state, Enum.at(opts, 0, 0))
      "recalculate_playables" -> 
        GenServer.cast(self(), :calculate_playable_indices)
        state
      "draw_last_discard" ->
        last_discard_action = get_last_discard_action(state)
        if last_discard_action != nil do
          state = update_player(state, context.seat, &%Player{ &1 | draw: &1.draw ++ [Utils.add_attr(last_discard_action.tile, ["_draw"])] })
          state = update_in(state.players[last_discard_action.seat].pond, &Enum.drop(&1, -1))
          state
        else state end
      "check_discard_passed" ->
        last_action = get_last_action(state)
        if last_action != nil and last_action.action == :discard do
          trigger_event(state, "after_discard_passed", %{seat: context.seat})
        else state end
      "scry"            -> update_player(state, context.seat, &%Player{ &1 | num_scryed_tiles: Enum.at(opts, 0, 1) })
      "scry_all"        ->
        num = Enum.at(opts, 0, 1)
        state = update_all_players(state, fn _seat, player -> %Player{ player | num_scryed_tiles: num } end)
        push_message(state, player_prefix(state, context.seat) ++ [
          %{text: "revealed tiles %{tiles}", vars: %{tiles: {:hand, get_scryed_tiles(state, context.seat)}}}
        ])
        state
      "clear_scry"      -> update_all_players(state, fn _seat, player -> %Player{ player | num_scryed_tiles: 0 } end)
      "choose_yaku"     -> declare_yaku(state, context.seat)
      "disable_saki_card" ->
        targets = Conditions.from_seats_spec(state, context, Enum.at(opts, 0, "self"))
        state = Saki.disable_saki_card(state, targets)
        state
      "enable_saki_card" ->
        targets = Conditions.from_seats_spec(state, context, Enum.at(opts, 0, "self"))
        state = Saki.enable_saki_card(state, targets)
        state
      "save_revealed_tiles" -> put_in(state.saved_revealed_tiles, state.revealed_tiles)
      "load_revealed_tiles" -> put_in(state.revealed_tiles, state.saved_revealed_tiles)
      # deprecated
      "merge_draw"          -> update_player(state, context.seat, &%Player{ &1 | hand: &1.hand ++ Utils.remove_attr(&1.draw, ["_draw"]), draw: [] })
      "pass_draws"      ->
        to = Conditions.from_seat_spec(state, context, Enum.at(opts, 0, "self"))
        {to_pass, remaining} = Enum.split(state.players[context.seat].draw, Enum.at(opts, 1, 1))
        state = update_player(state, context.seat, &%Player{ &1 | draw: remaining })
        state = update_player(state, to, &%Player{ &1 | draw: &1.draw ++ to_pass })
        state
      "saki_start"      -> Saki.saki_start(state)
      "register_last_discard" -> register_discard(state, context.seat, Enum.at(state.players[context.seat].pond, -1))
      "enable_auto_button" ->
        auto_button_name = Enum.at(opts, 0, "")
        GenServer.cast(self(), {:toggle_auto_button, context.seat, auto_button_name, true})
        state
      "modify_winner"   ->
        {key, type} = case Enum.at(opts, 0, nil) do
          "score"              -> {:displayed_score, :number}
          "points"             -> {:points, :number}
          "points2"            -> {:points2, :number}
          "score_name"         -> {:score_name, :string}
          "point_name"         -> {:point_name, :string}
          "point2_name"        -> {:point2_name, :string}
          "minipoint_name"     -> {:minipoint_name, :string}
          "minipoints"         -> {:minipoints, :number}
          "score_denomination" -> {:score_name, :string}
          "winning_tile_text"  -> {:winning_tile_text, :string}
          key ->
            IO.puts("Unhandled modify_winner key #{inspect(key)}")
            {nil, nil}
        end
        method = case Enum.at(opts, 2) do
          "add"      -> if type == :number do :add else nil end
          "subtract" -> if type == :number do :subtract else nil end
          "multiply" -> if type == :number do :multiply else nil end
          "divide"   -> if type == :number do :divide else nil end
          "min"      -> if type == :number do :min else nil end
          "max"      -> if type == :number do :max else nil end
          "prepend"  -> if type == :string do :prepend else nil end
          "append"   -> if type == :string do :append else nil end
          _          -> :set
        end
        if key != nil and method != nil and context.seat in state.winner_seats do
          value = case type do
            :number -> interpret_amount(state, context, Enum.at(opts, 1, 0))
            :string -> Enum.at(opts, 1, "")
          end
          update_in(state.winners[context.seat][key], fn prev_value -> case method do
            :set      -> value
            :add      -> prev_value + value
            :subtract -> prev_value - value
            :multiply -> prev_value * value
            :divide   -> Integer.floor_div(prev_value, value)
            :min      -> min(prev_value, value)
            :max      -> max(prev_value, value)
            :prepend  -> value <> prev_value
            :append   -> prev_value <> value
          end end)
        else state end
      "modify_payout"   ->
        if not Enum.empty?(state.delta_scores) do
          seats = Conditions.from_seats_spec(state, context, Enum.at(opts, 0, "self"))
          method = case Enum.at(opts, 2) do
            "set"      -> :set
            "subtract" -> :subtract
            "multiply" -> :multiply
            "divide"   -> :divide
            "min"      -> :min
            "max"      -> :max
            _          -> :add
          end
          value = interpret_amount(state, context, Enum.at(opts, 1, 0))
          for seat <- seats, reduce: state do
            state -> update_in(state.delta_scores, &Map.update!(&1, seat, fn prev_value -> case method do
              :set      -> value
              :add      -> prev_value + value
              :subtract -> prev_value - value
              :multiply -> prev_value * value
              :divide   -> Integer.floor_div(prev_value, value)
              :min      -> min(prev_value, value)
              :max      -> max(prev_value, value)
            end |> Utils.try_integer() end))
          end
        else
          IO.puts("WARNING: called modify_payout before payouts were calculated")
          state
        end
      "set_scoring_header" -> Map.put(state, :delta_scores_reason, interpolate_string(state, context, Enum.at(opts, 0, ""), Enum.at(opts, 1, %{})))
      "make_responsible_for" ->
        # player.pao_map: an entry %{seat => [yaku]} means if this player wins, `seat` must pay for `yaku`
        for_seat = Conditions.from_seat_spec(state, context, Enum.at(opts, 0, "self"))
        pao_yaku = List.wrap(Enum.at(opts, 1, "all"))
        update_player(state, for_seat, &%Player{ &1 | pao_map: Map.update(&1.pao_map, context.seat, pao_yaku, fn yakus -> yakus ++ pao_yaku end) })
      _                 ->
        IO.puts("Unhandled action #{action}")
        state
    end

    case action do
      "pause" when not state.log_loading_mode ->
        # schedule an unpause after the given delay
        state = schedule_actions_before(state, context.seat, actions, context)
        :timer.apply_after(Enum.at(opts, 0, 1500), GenServer, :cast, [self(), {:unpause, context}])
        if Debug.debug_actions() do
          IO.puts("Stopping actions due to pause: #{inspect([[action | opts] | actions])}")
        end
        {state, []}
      _ ->
        # if our action updates state, then we need to recalculate buttons
        # this is so other players can react to certain actions
        if not uninterruptible and Map.has_key?(state.interruptible_actions, action) do
          state = if state.visible_screen != nil do
            # if viewing a win screen, never display buttons
            update_all_players(state, fn _seat, player -> %Player{ player | buttons: [], button_choices: %{}, call_buttons: %{}, choice: nil } end)
          else
            Buttons.recalculate_buttons(state, state.interruptible_actions[action])
          end
          buttons_after = Enum.map(state.players, fn {seat, player} -> {seat, player.buttons} end)
          # IO.puts("buttons_before: #{inspect(buttons_before)}")
          # IO.puts("buttons_after: #{inspect(buttons_after)}")
          if buttons_before == buttons_after or Buttons.no_buttons_remaining?(state) do
            _run_actions(state, actions, context)
          else
            # if buttons changed, stop evaluating actions here
            if Debug.debug_actions() do
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
    IO.puts("Unhandled action spec #{inspect(action)}")
    _run_actions(state, actions, context)
  end
  defp _run_actions(state, not_actions, _context) do
    IO.puts("Can't run actions #{inspect(not_actions)}")
    IO.inspect(Process.info(self(), :current_stacktrace))
    {state, []}
  end

  def run_actions(state, actions, context) do
    if Debug.debug_actions() do
      if (Enum.empty?(actions) or (actions |> Enum.at(0) |> Enum.at(0)) not in ["when", "sort_hand", "unset_status"]) do
        IO.puts("Running actions #{inspect(actions)} in context #{inspect(context)}")
      end
    end
    # IO.puts("Running actions #{inspect(actions)} in context #{inspect(context)}")
    # IO.inspect(Process.info(self(), :current_stacktrace))
    {state, deferred_actions} = _run_actions(state, actions, context)
    # defer the remaining actions
    state = if not Enum.empty?(deferred_actions) do
      if Debug.debug_actions() do
        IO.puts("Deferred actions for seat #{context.seat} due to pause or existing buttons / #{inspect(deferred_actions)}")
      end
      state = schedule_actions(state, context.seat, deferred_actions, context)
      state
    else state end
    state
  end

  def schedule_actions_before(state, seat, actions, context) do
    update_player(state, seat, &%Player{ &1 | deferred_actions: actions ++ &1.deferred_actions, deferred_context: Map.merge(&1.deferred_context, context) })
  end

  def schedule_actions(state, seat, actions, context) do
    update_player(state, seat, &%Player{ &1 | deferred_actions: &1.deferred_actions ++ actions, deferred_context: Map.merge(&1.deferred_context, context) })
  end

  # TODO make context optional and use player.deferred_context instead
  def run_deferred_actions(state, context) do
    actions = state.players[context.seat].deferred_actions
    if state.game_active and not Enum.empty?(actions) do
      state = update_player(state, context.seat, &%Player{ &1 | choice: nil, deferred_actions: [], deferred_context: %{} })
      if Debug.debug_actions() do
        IO.puts("Running deferred actions #{inspect(actions)} in context #{inspect(context)}")
      end
      state = run_actions(state, actions, context)
      state = Buttons.recalculate_buttons(state)
      notify_ai(state)
      state
    else state end
  end

  def resume_deferred_actions(state) do
    for {seat, player} <- state.players, reduce: state do
      state ->
        state = if not Enum.empty?(player.deferred_actions) do
          if Debug.debug_actions() do
            IO.puts("Resuming deferred actions for #{seat}")
          end
          run_deferred_actions(state, player.deferred_context)
        else state end
        state = if not Enum.empty?(state.marking[seat]) and Marking.is_done?(state, seat) do
          state = Log.log(state, seat, :mark, %{marking: Log.encode_marking(state.marking[seat])})
          Marking.reset_marking(state, seat)
        else state end
        state
    end |> evaluate_choices(true)
  end

  def get_superceded_buttons(state, button_name) do
    buttons = Rules.get(state.rules_ref, "buttons", %{})
    if Map.has_key?(buttons, button_name) do
      ["play_tile"] ++ Map.get(buttons[button_name], "precedence_over", [])
    else [] end
  end

  def get_all_superceded_buttons(state, seat) do
    Enum.flat_map(state.players, fn {dir, player} -> if dir != seat do ["skip"] ++ get_superceded_buttons(state, player.choice) else [] end end)
  end

  # triggered when all players' choices are non-nil
  defp adjudicate_actions(state) do
    if state.game_active do
      lock = Mutex.await(state.mutex, __MODULE__)

      if Debug.debug_actions() do
        IO.puts("\nAdjudicating actions! Choices: #{inspect(Map.new(state.players, fn {seat, player} -> {seat, player.choice} end))}")
        # IO.puts("Button choices: #{inspect(Map.new(state.players, fn {seat, player} -> {seat, player.button_choices} end))}")
      end
      # clear ai thinking and last discard
      state = update_all_players(state, fn _seat, player -> %Player{ player | ai_thinking: false, last_discard: nil } end)
      # trigger all choices that aren't "skip"
      state = for {seat, player} <- state.players, reduce: state do
        state ->
          choice = player.choice
          # don't clear deferred actions here
          # for example, someone might play a tile and have advance_turn interrupted by their own button
          # if they choose to skip, we still want to advance turn
          # also don't clear buttons here!! buttons are only cleared by player and in evaluate_choices
          state = update_player(state, seat, fn player -> %Player{ player | choice: nil } end)
          state = if choice != nil and choice.name != "skip" do
            actions = choice.chosen_actions
            button_choices = player.button_choices
            button_choice = if button_choices != nil do Map.get(button_choices, choice.name, nil) else nil end
            case button_choice do
              {:call, _call_choices} ->
                if Debug.debug_actions() do
                  IO.puts("Running call actions for #{seat}: #{inspect(actions)}")
                end

                # run before_call actions
                callee = state.turn
                state = trigger_event(state, "before_call", %{seat: state.turn, callee: callee, caller: seat})

                state = run_actions(state, actions, %{seat: seat, choice: choice})

                # run after_call actions
                state = trigger_event(state, "after_call", %{seat: state.turn, callee: callee, caller: seat})

                state
              {:mark, mark_spec, pre_actions, post_actions, cancel_actions} ->
                # run pre-mark actions
                if Debug.debug_actions() do
                  IO.puts("Running pre-mark actions for #{seat}: #{inspect(pre_actions)}")
                end
                state = run_actions(state, pre_actions, %{seat: seat})
                # setup marking
                buttons = Rules.get(state.rules_ref, "buttons", %{})
                cancellable = Map.get(buttons[choice.name], "cancellable", true)
                state = Marking.setup_marking(state, seat, mark_spec, cancellable, post_actions, cancel_actions)
                if Debug.debug_actions() do
                  IO.puts("Scheduling mark actions for #{seat}: #{inspect(actions)}")
                end
                state = schedule_actions(state, seat, actions, %{seat: seat})
                state
              _ ->
                # just run all button actions as normal
                if Debug.debug_actions() do
                  IO.puts("Running actions for #{seat}: #{inspect(actions)}")
                end
                state = run_actions(state, actions, %{seat: seat})
                state
            end
          else state end
          state
      end

      # done with all choices
      state = if not performing_intermediate_action?(state) do
        notify_ai(state)
        state
      else state end

      Mutex.release(state.mutex, lock)
      # IO.puts("Done adjudicating actions!\n")

      # after releasing mutex, check if new choices exist
      # this is possible if actions pressed buttons or played tiles, for example
      state = if Enum.any?(state.players, fn {_seat, player} -> player.choice != nil end) do
        adjudicate_actions(state)
      else state end

      # ensure playable_indices is populated for the current player
      # this also notifies ai marking once :set_playable_indices is received
      state = broadcast_state_change(state, true)

      state
    else state end
  end

  def performing_intermediate_action?(state) do
    Enum.any?(state.available_seats, fn seat -> performing_intermediate_action?(state, seat) end)
  end

  def performing_intermediate_action?(state, seat) do
    no_call_buttons = Enum.empty?(state.players[seat].call_buttons)
    made_choice = state.players[seat].choice != nil and state.players[seat].choice.name != "skip"
    marking = Marking.needs_marking?(state, seat)
    declaring_yaku = state.players[seat].declared_yaku == []
    not no_call_buttons or made_choice or marking or declaring_yaku
  end

  def evaluate_choices(state, from_deferred_actions \\ false) do
    if Debug.debug_actions() do
      IO.puts("Evaluating the following choices:")
      IO.inspect(Map.new(state.players, fn {seat, player} -> {seat, player.choice} end))
    end

    # for the current turn's player, if they just acted (have deferred actions) and have no buttons, their choice is "skip"
    # for other players who have no buttons and have not made a choice yet, their choice is "skip"
    # also for other players who have made a choice, if their choice is superceded by others then set it to "skip"
    last_action = get_last_action(state)
    turn_just_acted = last_action != nil and not Enum.empty?(state.players[state.turn].deferred_actions) and last_action.seat == state.turn
    last_discard_action = get_last_discard_action(state)
    turn_just_discarded = last_discard_action != nil and last_discard_action.seat == state.turn
    extra_turn = "extra_turn" in state.players[state.turn].status
    state = for {seat, player} <- state.players, reduce: state do
      state -> cond do
        seat == state.turn and (turn_just_acted or (turn_just_discarded and not extra_turn)) and Enum.empty?(player.buttons) and not performing_intermediate_action?(state, seat) ->
          if Debug.debug_actions() do
            IO.puts("Player #{seat} must skip due to having just discarded")
          end
          update_player(state, seat, &%Player{ &1 | choice: %Choice{ name: "skip" } })
        seat != state.turn and player.choice == nil and Enum.empty?(player.buttons) and not performing_intermediate_action?(state, seat) ->
          if Debug.debug_actions() do
            IO.puts("Player #{seat} must skip due to having no buttons")
          end
          update_player(state, seat, &%Player{ &1 | choice: %Choice{ name: "skip" } })
        true -> state
      end
    end

    # supercede choices
    # basically, starting from the current turn player's choice, clear out others' choices
    buttons = Rules.get(state.rules_ref, "buttons", %{})
    ordered_seats = [state.turn, Utils.next_turn(state.turn), Utils.next_turn(state.turn, 2), Utils.next_turn(state.turn, 3)]
    |> Enum.filter(fn seat -> seat in state.available_seats end)
    {_, _, state} = for _ <- ordered_seats, reduce: {ordered_seats, ["skip", "play_tile"], state} do
      {[seat | later_seats], superceded_choices, state} ->
        choice = state.players[seat].choice
        new_superceded_choices = if choice != nil do get_in(buttons[choice.name]["precedence_over"]) || [] else [] end
        superceded_choices = superceded_choices ++ new_superceded_choices
        state = if choice != nil and choice.name not in [nil, "skip", "play_tile"] do
          # replace with "skip" every button and choice that is superceded by our choice
          update_all_players(state, fn dir, player ->
            is_later = dir in later_seats
            our_choices = if player.choice != nil do [player.choice.name] else player.buttons ++ Map.keys(player.button_choices) end
            all_choices_superceded = Enum.all?(our_choices, fn button -> button in superceded_choices end)
            strictly_supercedes = Enum.all?(our_choices, fn button -> button != choice.name and button in superceded_choices end)
            if (is_later or strictly_supercedes) and all_choices_superceded do
              if Debug.debug_actions() do
                cond do
                  all_choices_superceded -> IO.puts("Player #{dir} must skip due to having choices superceded by #{seat}, original choices were: #{inspect(player.buttons ++ Map.keys(player.button_choices))}")
                  true -> :ok
                end
              end
              %Player{ player | choice: %Choice{ name: "skip" }, buttons: [] }
            else player end
          end)
        else state end
        {later_seats, superceded_choices, state}
    end

    # check call priority lists
    # if multiple people have the same call, normally it will just trigger both calls
    # define a "call_priority_list" key in your button to prevent this
    # each item should be a CNF condition
    # calls that satisfy the first condition are given priority over calls that don't
    # calls that satisfy the second condition are given priority over calls that don't
    # etc. if there are still multiple of the same call then it reverts to "first in turn order"
    conflicting_players = ordered_seats
    |> Enum.map(fn seat -> {seat, state.players[seat].choice} end)
    |> Enum.filter(fn {_seat, choice} -> choice != nil and get_in(buttons[choice.name]["call_priority_list"]) != nil end)
    |> Enum.map(fn {seat, choice} -> %{choice => [seat]} end)
    |> Enum.reduce(%{}, fn m, acc -> Map.merge(m, acc, fn _k, l, r -> l ++ r end) end)
    state = for {choice, seats} <- conflicting_players, reduce: state do
      state ->
        priority_list = buttons[choice.name]["call_priority_list"]
        winning_seat = seats
        |> Enum.sort_by(fn seat ->
          context = %{seat: seat, choice: choice}
          ix = Enum.find_index(priority_list, fn conditions -> Conditions.check_cnf_condition(state, conditions, context) end)
          if ix == nil do :infinity else ix end
        end)
        |> Enum.at(0)
        update_all_players(state, fn dir, player ->
          if dir in (seats -- [winning_seat]) do
            if Debug.debug_actions() do
              IO.puts("Superceding choice for #{dir} due to existing #{inspect(choice)} having higher call priority")
            end
            %Player{ player | choice: %Choice{ name: "skip" }, buttons: [] }
          else player end
        end)
    end

    if Debug.debug_actions() do
      IO.puts("Final choices:")
      IO.inspect(Enum.map(state.players, fn {_seat, player} -> player.choice end))
    end

    # check if nobody else needs to make choices
    if Enum.all?(state.players, fn {_seat, player} -> player.choice != nil end) do
      # if every action is skip, we need to resume deferred actions for all players
      # otherwise, adjudicate actions as normal
      if Enum.all?(state.players, fn {_seat, player} -> player.choice.name == "skip" end) do
        if state.game_active and not from_deferred_actions do
          # IO.puts("All choices are no-ops, running deferred actions")
          state = resume_deferred_actions(state)
          state = update_all_players(state, fn _seat, player -> %Player{ player | choice: nil } end)
          GenServer.cast(self(), :calculate_playable_indices) # need to newly calculate playable indices
          state = broadcast_state_change(state, false)
          state
        else state end
      else
        adjudicate_actions(state)
      end
    else
      if Debug.debug_actions() do
        for {seat, player} <- state.players, player.choice == nil do
          IO.puts("Player #{seat} still has a choice to make")
        end
        IO.puts("")
      end
      # when we interrupt the current turn AI with our button choice, they fail to make a choice
      # this rectifies that
      notify_ai(state)
      state
    end
  end

  # TODO this argument list is stupid, need to refactor it to a map
  def submit_actions(state, seat, choice_name, actions, call_choice \\ nil, called_tile \\ nil, saki_card \\ nil, declared_yakus \\ nil) do
    player = state.players[seat]
    if state.game_active and (player.choice == nil or player.choice.name == choice_name) do
      if Debug.debug_actions() do
        IO.puts("Submitting choice for #{seat}: #{choice_name}, #{inspect(actions)}")
      end

      {called_tile, call_choice, call_choices} = if called_tile == nil and call_choice == nil and declared_yakus == nil and player.button_choices != nil do
        button_choice = Map.get(player.button_choices, choice_name, nil)
        case button_choice do
          {:call, call_choices} ->
            flattened_call_choices = call_choices |> Map.values() |> Enum.concat()
            if length(flattened_call_choices) == 1 do
              # if there's only one choice, automatically choose it
              {called_tile, [call_choice]} = Enum.max_by(call_choices, fn {_tile, choices} -> length(choices) end)
              if Debug.debug_actions() do
                IO.puts("Submitting actions due to there being only one call choice for #{seat}: #{inspect(actions)}")
              end
              {called_tile, call_choice, call_choices}
            else {nil, nil, call_choices} end
          :declare_yaku -> {nil, nil, :declare_yaku}
          _ -> {nil, nil, nil}
        end
      else {called_tile, call_choice, nil} end

      if called_tile == nil and call_choice == nil and saki_card == nil and declared_yakus == nil and call_choices != nil do
        case call_choices do
          :declare_yaku ->
            # show declare yaku 
            state = update_player(state, seat, &%Player{ &1 | declared_yaku: [], choice: %Choice{ name: choice_name } })
            notify_ai_declare_yaku(state, seat)
            state
          _ ->
            # show call choice buttons
            # clicking them will call submit_actions again, but with the optional parameters included
            if Debug.debug_actions() do
              IO.puts("Showing call buttons for #{seat}: #{inspect(actions)}")
            end
            state = update_player(state, seat, &%Player{ &1 | call_buttons: call_choices, choice: %Choice{ name: choice_name } })
            notify_ai_call_buttons(state, seat)
            state
        end
      else
        # log the button press
        state = case choice_name do
          "skip" -> state
          "play_tile" -> state
          _ ->
            data = cond do
              saki_card != nil -> %{choice: saki_card}
              call_choice != nil -> %{call_choice: call_choice, called_tile: called_tile}
              true -> %{}
            end
            Log.add_button_press(state, seat, choice_name, data)
        end
        # set choice now that a choice has been made
        state = update_player(state, seat, &%Player{ &1 | choice: %Choice{ name: choice_name, chosen_actions: actions, chosen_called_tile: called_tile, chosen_call_choice: call_choice, chosen_saki_card: saki_card } })
        state = if choice_name != "skip" do update_player(state, seat, &%Player{ &1 | deferred_actions: [] }) else state end
        evaluate_choices(state)
      end
    else state end
  end

  def extract_actions([action | actions], names) do
    case action do
      ["when", _condition, subactions] -> extract_actions(subactions, names)
      ["as", _seats_spec, subactions] -> extract_actions(subactions, names)
      ["when_anyone", _condition, subactions] -> extract_actions(subactions, names)
      ["when_everyone", _condition, subactions] -> extract_actions(subactions, names)
      ["when_others", _condition, subactions] -> extract_actions(subactions, names)
      ["unless", _condition, subactions] -> extract_actions(subactions, names)
      ["ite", _condition, subactions1, subactions2] -> extract_actions(subactions1, names) ++ extract_actions(subactions2, names)
      [action_name | _opts] -> if action_name in names do [action] else [] end
    end ++ extract_actions(actions, names)
  end
  def extract_actions(_anything_else, _names), do: []

end
