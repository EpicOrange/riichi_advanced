
defmodule RiichiAdvanced.GameState.Conditions do
  alias RiichiAdvanced.GameState.Log, as: Log
  alias RiichiAdvanced.GameState.Saki, as: Saki
  alias RiichiAdvanced.GameState.Scoring, as: Scoring
  import RiichiAdvanced.GameState

  def get_hand_calls_spec(state, context, hand_calls_spec) do
    last_call_action = get_last_call_action(state)
    last_discard_action = get_last_discard_action(state)
    for item <- hand_calls_spec, reduce: [{[], []}] do
      hand_calls -> for {hand, calls} <- hand_calls do
        case item do
          "hand" -> [{hand ++ state.players[context.seat].hand, calls}]
          "draw" -> [{hand ++ state.players[context.seat].draw, calls}]
          "pond" -> [{hand ++ state.players[context.seat].pond, calls}]
          "aside" -> [{hand ++ state.players[context.seat].aside, calls}]
          "aside_unique" -> [{hand ++ Enum.uniq(state.players[context.seat].aside), calls}]
          "calls" -> [{hand, calls ++ state.players[context.seat].calls}]
          "flowers" -> [{hand, calls ++ Enum.filter(state.players[context.seat].calls, fn {call_name, _call} -> call_name in ["flower", "start_flower"] end)}]
          "start_flowers" -> [{hand, calls ++ Enum.filter(state.players[context.seat].calls, fn {call_name, _call} -> call_name == "start_flower" end)}]
          "jokers" -> [{hand, calls ++ Enum.filter(state.players[context.seat].calls, fn {call_name, _call} -> call_name in ["joker", "start_joker"] end)}]
          "start_jokers" -> [{hand, calls ++ Enum.filter(state.players[context.seat].calls, fn {call_name, _call} -> call_name == "start_joker" end)}]
          "call_tiles" -> [{hand ++ Enum.flat_map(state.players[context.seat].calls, &Riichi.call_to_tiles/1), calls}]
          "last_call" -> [{hand, calls ++ [context.call]}]
          "last_called_tile" -> if last_call_action != nil do [{hand ++ [last_call_action.called_tile], calls}] else [] end
          "last_discard" -> if last_discard_action != nil do [{hand ++ [last_discard_action.tile], calls}] else [] end
          "second_last_visible_discard" ->
            if last_discard_action != nil do 
              visible_pond = state.players[last_discard_action.seat].pond
              |> Enum.drop(-1)
              |> Enum.filter(fn tile -> Utils.count_tiles([tile], [:"1x", :"2x"]) == 0 end)
              if not Enum.empty?(visible_pond) do
                [{hand ++ Enum.take(visible_pond, -1), calls}]
              else [] end
            else [] end
          "self_last_discard" -> [{hand ++ Enum.take(state.players[context.seat].pond, -1), calls}]
          "shimocha_last_discard" -> [{hand ++ Enum.take(state.players[Utils.get_seat(context.seat, :shimocha)].pond, -1), calls}]
          "toimen_last_discard" -> [{hand ++ Enum.take(state.players[Utils.get_seat(context.seat, :toimen)].pond, -1), calls}]
          "kamicha_last_discard" -> [{hand ++ Enum.take(state.players[Utils.get_seat(context.seat, :kamicha)].pond, -1), calls}]
          "all_last_discards" -> [{hand ++ Enum.flat_map(state.players, fn {_seat, player} -> Enum.take(player.pond, -1) end), calls}]
          "tile" -> [{hand ++ [context.tile], calls}]
          "called_tile" -> [{hand ++ [context.called_tile], calls}]
          "call_choice" -> [{hand ++ [context.call_choice], calls}]
          "winning_tile" ->
            winning_tile = Map.get(context, :winning_tile, get_in(state.winners[context.seat].winning_tile))
            [{hand ++ [winning_tile], calls}]
          "any_discard" -> Enum.map(state.players[context.seat].discards, fn discard -> {hand ++ [discard], calls} end)
          "all_discards" -> [{hand ++ Enum.flat_map(state.players, fn {_seat, player} -> player.pond end), calls}]
          "others_discards" -> [{hand ++ Enum.flat_map(state.players, fn {seat, player} -> if seat == context.seat do [] else player.pond end end), calls}]
          "all_calls" -> [{hand, calls ++ Enum.flat_map(state.players, fn {_seat, player} -> player.calls end)}]
          "all_call_tiles" -> [{hand ++ Enum.flat_map(state.players, fn {_seat, player} -> Enum.flat_map(player.calls, &Riichi.call_to_tiles/1) end), calls}]
          "revealed_tiles" -> [{hand ++ get_revealed_tiles(state), calls}]
          "hand_any" -> Enum.flat_map(state.players[context.seat].hand, fn tile -> [{hand ++ [tile], calls}] end)
          "scry" -> [{hand ++ (state.wall |> Enum.drop(state.wall_index) |> Enum.take(state.players[context.seat].num_scryed_tiles)), calls}]
          _ -> [{[context.tile], []}]
        end
      end |> Enum.concat()
    end
  end

  def from_seat_spec(state, seat, seat_spec) do
    case seat_spec do
      "east" -> Riichi.get_player_from_seat_wind(state.kyoku, :east)
      "south" -> Riichi.get_player_from_seat_wind(state.kyoku, :south)
      "west" -> Riichi.get_player_from_seat_wind(state.kyoku, :west)
      "north" -> Riichi.get_player_from_seat_wind(state.kyoku, :north)
      "shimocha" -> Utils.get_seat(seat, :shimocha)
      "toimen" -> Utils.get_seat(seat, :toimen)
      "kamicha" -> Utils.get_seat(seat, :kamicha)
      "last_discarder" ->
        last_discard_action = get_last_discard_action(state)
        if last_discard_action != nil do last_discard_action.seat else seat end
      _ -> seat
    end
  end

  def from_seats_spec(state, seat, seat_spec) do
    case seat_spec do
      "all" -> [:east, :south, :west, :north]
      "others" -> [:east, :south, :west, :north] -- [seat]
      _ -> [from_seat_spec(state, seat, seat_spec)]
    end
  end

  def get_placements(state) do
    state.players
    |> Enum.sort_by(fn {seat, player} -> -player.score - Riichi.get_seat_scoring_offset(state.kyoku, seat) end)
    |> Enum.map(fn {seat, _player} -> seat end)
  end

  def check_condition(state, cond_spec, context \\ %{}, opts \\ []) do
    negated = String.starts_with?(cond_spec, "not_")
    cond_spec = if negated do String.slice(cond_spec, 4..-1//1) else cond_spec end
    last_action = get_last_action(state)
    last_call_action = get_last_call_action(state)
    last_discard_action = get_last_discard_action(state)
    cxt_player = if Map.has_key?(context, :seat) do state.players[context.seat] else nil end
    result = case cond_spec do
      "true"                        -> true
      "false"                       -> false
      "print"                       ->
        IO.inspect(opts)
        true
      "print_context"               ->
        IO.inspect(context)
        true
      "our_turn"                    -> state.turn == context.seat
      "our_turn_is_next"            -> state.turn == if state.reversed_turn_order do Utils.next_turn(context.seat) else Utils.prev_turn(context.seat) end
      "our_turn_is_prev"            -> state.turn == if state.reversed_turn_order do Utils.prev_turn(context.seat) else Utils.next_turn(context.seat) end
      "game_start"                  -> last_action == nil
      "no_discards_yet"             -> last_discard_action == nil
      "no_calls_yet"                -> last_call_action == nil
      "last_call_is"                -> last_call_action != nil && last_call_action.call_name == Enum.at(opts, 0, "kakan")
      "kamicha_discarded"           -> last_action != nil && last_action.action == :discard && last_action.seat == state.turn && state.turn == Utils.prev_turn(context.seat)
      "toimen_discarded"            -> last_action != nil && last_action.action == :discard && last_action.seat == state.turn && state.turn == Utils.prev_turn(context.seat, 2)
      "shimocha_discarded"          -> last_action != nil && last_action.action == :discard && last_action.seat == state.turn && state.turn == Utils.prev_turn(context.seat, 3)
      "anyone_just_discarded"       -> last_action != nil && last_action.action == :discard && last_action.seat == state.turn
      "someone_else_just_discarded" -> last_action != nil && last_action.action == :discard && last_action.seat == state.turn && state.turn != context.seat
      "just_discarded"              -> last_action != nil && last_action.action == :discard && last_action.seat == state.turn && state.turn == context.seat
      "just_called"                 -> last_action != nil && last_action.action == :call && last_action.seat == state.turn
      "call_available"              -> last_action != nil && last_action.action == :discard && Riichi.can_call?(context.calls_spec, Utils.add_attr(cxt_player.hand, ["hand"]), cxt_player.tile_ordering, cxt_player.tile_ordering_r, [last_action.tile], cxt_player.tile_aliases, cxt_player.tile_mappings)
      "self_call_available"         -> Riichi.can_call?(context.calls_spec, Utils.add_attr(cxt_player.hand, ["hand"]) ++ Utils.add_attr(cxt_player.draw, ["hand"]), cxt_player.tile_ordering, cxt_player.tile_ordering_r, [], cxt_player.tile_aliases, cxt_player.tile_mappings)
      "can_upgrade_call"            -> cxt_player.calls
        |> Enum.filter(fn {name, _call} -> name == context.upgrade_name end)
        |> Enum.any?(fn {_name, call} ->
          call_tiles = Enum.map(call, fn {tile, _sideways} -> tile end)
          Riichi.can_call?(context.calls_spec, call_tiles, cxt_player.tile_ordering, cxt_player.tile_ordering_r, cxt_player.hand ++ cxt_player.draw, cxt_player.tile_aliases, cxt_player.tile_mappings)
        end)
      "has_draw"                 -> not Enum.empty?(state.players[from_seat_spec(state, context.seat, Enum.at(opts, 0, "self"))].draw)
      "has_aside"                -> not Enum.empty?(state.players[from_seat_spec(state, context.seat, Enum.at(opts, 0, "self"))].aside)
      "has_calls"                -> not Enum.empty?(state.players[from_seat_spec(state, context.seat, Enum.at(opts, 0, "self"))].calls)
      "has_call_named"           -> Enum.all?(cxt_player.calls, fn {name, _call} -> name in opts end)
      "has_no_call_named"        -> Enum.all?(cxt_player.calls, fn {name, _call} -> name not in opts end)
      "won_by_call"              -> context.win_source == :call
      "won_by_draw"              -> context.win_source == :draw
      "won_by_discard"           -> context.win_source == :discard
      "fu_equals"                -> context.minipoints == Enum.at(opts, 0, 20)
      "has_yaku_with_hand"       -> Scoring.seat_scores_points(state, Enum.flat_map(Enum.at(opts, 1, ["yaku"]), fn yaku_key -> state.rules[yaku_key] end), Enum.at(opts, 0, 1), context.seat, Enum.at(cxt_player.draw, 0, nil), :draw)
      "has_yaku_with_discard"    -> last_action != nil && last_action.action == :discard && Scoring.seat_scores_points(state, Enum.flat_map(Enum.at(opts, 1, ["yaku"]), fn yaku_key -> state.rules[yaku_key] end), Enum.at(opts, 0, 1), context.seat, last_action.tile, :discard)
      "has_yaku_with_call"       -> last_action != nil && last_action.action == :call && Scoring.seat_scores_points(state, Enum.flat_map(Enum.at(opts, 1, ["yaku"]), fn yaku_key -> state.rules[yaku_key] end), Enum.at(opts, 0, 1), context.seat, last_action.tile, :call)
      "has_declared_yaku_with_hand"    -> Scoring.seat_scores_points(state, Enum.flat_map(opts, fn yaku_key -> state.rules[yaku_key] end), :declared, context.seat, Enum.at(cxt_player.draw, 0, nil), :draw)
      "has_declared_yaku_with_discard" -> last_action != nil && last_action.action == :discard && Scoring.seat_scores_points(state, Enum.flat_map(opts, fn yaku_key -> state.rules[yaku_key] end), :declared, context.seat, last_action.tile, :discard)
      "has_declared_yaku_with_call"    -> last_action != nil && last_action.action == :call && Scoring.seat_scores_points(state, Enum.flat_map(opts, fn yaku_key -> state.rules[yaku_key] end), :declared, context.seat, last_action.tile, :call)
      "last_discard_matches"     -> last_discard_action != nil && Riichi.tile_matches(opts, %{tile: last_discard_action.tile, tile2: context.tile, players: state.players, seat: context.seat})
      "last_called_tile_matches" -> last_action != nil && last_action.action == :call && Riichi.tile_matches(opts, %{tile: last_action.called_tile, tile2: context.tile, call: last_call_action, players: state.players, seat: context.seat})
      "needed_for_hand"          -> Riichi.needed_for_hand(cxt_player.hand ++ cxt_player.draw, cxt_player.calls, context.tile, translate_match_definitions(state, opts), cxt_player.tile_ordering, cxt_player.tile_ordering_r, cxt_player.tile_aliases)
      "is_drawn_tile"            -> Utils.has_attr?(context.tile, ["draw"])
      "status"                   -> Enum.all?(opts, fn st -> st in cxt_player.status end)
      "status_missing"           -> Enum.all?(opts, fn st -> st not in cxt_player.status end)
      "discarder_status"         -> last_action != nil && last_action.action == :discard && Enum.all?(opts, fn st -> st in state.players[last_action.seat].status end)
      "caller_status"            -> last_action != nil && last_action.action == :call && Enum.all?(opts, fn st -> st in state.players[last_action.seat].status end)
      "shimocha_status"          -> Enum.all?(opts, fn st -> st in state.players[Utils.get_seat(context.seat, :shimocha)].status end)
      "toimen_status"            -> Enum.all?(opts, fn st -> st in state.players[Utils.get_seat(context.seat, :toimen)].status end)
      "kamicha_status"           -> Enum.all?(opts, fn st -> st in state.players[Utils.get_seat(context.seat, :kamicha)].status end)
      "others_status"            -> Enum.any?(state.players, fn {seat, player} -> Enum.all?(opts, fn st -> seat != context.seat && st in player.status end) end)
      "anyone_status"            -> Enum.any?(state.players, fn {_seat, player} -> Enum.all?(opts, fn st -> st in player.status end) end)
      "everyone_status"          -> Enum.all?(state.players, fn {_seat, player} -> Enum.all?(opts, fn st -> st in player.status end) end)
      "buttons_include"          -> Enum.all?(opts, fn button_name -> button_name in cxt_player.buttons end)
      "buttons_exclude"          -> Enum.all?(opts, fn button_name -> button_name not in cxt_player.buttons end)
      "tile_drawn"               -> Enum.all?(opts, fn tile -> tile in state.drawn_reserved_tiles end)
      "tile_not_drawn"           -> Enum.all?(opts, fn tile -> tile not in state.drawn_reserved_tiles end)
      "tile_revealed"            ->
        Enum.all?(opts, fn tile ->
          tile in state.revealed_tiles || if is_integer(tile) do
            (tile - length(state.dead_wall)) in state.revealed_tiles
          else false end
        end)
      "tile_not_revealed"        ->
        Enum.all?(opts, fn tile ->
          tile not in state.revealed_tiles && if is_integer(tile) do
            (tile - length(state.dead_wall)) not in state.revealed_tiles
          else true end
        end)
      "no_tiles_remaining"       -> length(state.wall) - length(state.drawn_reserved_tiles) - state.wall_index <= 0
      "tiles_remaining"          -> length(state.wall) - length(state.drawn_reserved_tiles) - state.wall_index >= Enum.at(opts, 0, 0)
      "next_draw_possible"       ->
        draws_left = length(state.wall) - length(state.drawn_reserved_tiles) - state.wall_index
        case Utils.get_relative_seat(context.seat, state.turn) do
          :shimocha -> draws_left >= 3
          :toimen   -> draws_left >= 2
          :kamicha  -> draws_left >= 1
          :self     -> draws_left >= 4
        end
      "has_score"                -> state.players[context.seat].score >= Enum.at(opts, 0, 0)
      "has_score_below"          -> state.players[context.seat].score < Enum.at(opts, 0, 0)
      "round_wind_is"            ->
        round_wind = Riichi.get_round_wind(state.kyoku)
        case Enum.at(opts, 0, "east") do
          "east"  -> round_wind == :east
          "south" -> round_wind == :south
          "west"  -> round_wind == :west
          "north" -> round_wind == :north
          _       ->
            IO.puts("Unknown round wind #{inspect(Enum.at(opts, 0, "east"))}")
            false
        end
      "seat_is"                  ->
        seat_wind = Riichi.get_seat_wind(state.kyoku, context.seat)
        case Enum.at(opts, 0, "east") do
          "east"  -> seat_wind == :east
          "south" -> seat_wind == :south
          "west"  -> seat_wind == :west
          "north" -> seat_wind == :north
          _       ->
            IO.puts("Unknown seat wind #{inspect(Enum.at(opts, 0, "east"))}")
            false
        end
      "hand_tile_count"          -> (length(cxt_player.hand) + length(cxt_player.draw)) in opts
      "hand_dora_count"       ->
        dora_indicator = from_named_tile(state, Enum.at(opts, 0, :"1m"))
        if dora_indicator != nil do
          num = Enum.at(opts, 1, 1)
          doras = Map.get(state.rules["dora_indicators"], Utils.tile_to_string(dora_indicator), []) |> Enum.map(&Utils.to_tile/1)
          Utils.count_tiles(cxt_player.hand, doras) == num
        else false end
      "winning_dora_count"       ->
        dora_indicator = from_named_tile(state, Enum.at(opts, 0, :"1m"))
        if dora_indicator != nil do
          num = Enum.at(opts, 1, 1)
          doras = Map.get(state.rules["dora_indicators"], Utils.tile_to_string(dora_indicator), []) |> Enum.map(&Utils.to_tile/1)
          IO.inspect({cxt_player.winning_hand, doras})
          Utils.count_tiles(cxt_player.winning_hand, doras) == num
        else false end
      "winning_reverse_dora_count" ->
        dora_indicator = from_named_tile(state, Enum.at(opts, 0, :"1m"))
        if dora_indicator != nil do
          num = Enum.at(opts, 1, 1)
          doras = Map.get(state.rules["reverse_dora_indicators"], Utils.tile_to_string(dora_indicator), []) |> Enum.map(&Utils.to_tile/1)
          Utils.count_tiles(cxt_player.winning_hand, doras) == num
        else false end
      "match"                    ->
        hand_calls = get_hand_calls_spec(state, context, Enum.at(opts, 0, []))
        match_definitions = translate_match_definitions(state, Enum.at(opts, 1, []))
        ordering = cxt_player.tile_ordering
        ordering_r = cxt_player.tile_ordering_r
        tile_aliases = cxt_player.tile_aliases
        Enum.any?(hand_calls, fn {hand, calls} -> Riichi.match_hand(hand, calls, match_definitions, ordering, ordering_r, tile_aliases) end)
      "winning_hand_consists_of" ->
        tile_mappings = cxt_player.tile_mappings
        tiles = Enum.map(opts, &Utils.to_tile/1)
        non_flower_calls = Enum.reject(cxt_player.calls, fn {call_name, _call} -> call_name in ["flower", "joker", "start_flower", "start_joker"] end)
        winning_hand = cxt_player.hand ++ Enum.flat_map(non_flower_calls, &Riichi.call_to_tiles/1)
        Enum.all?(winning_hand, fn tile -> Utils.count_tiles([tile] ++ Map.get(tile_mappings, tile, []), tiles) > 0 end)
      "winning_hand_and_tile_consists_of" ->
        tile_mappings = cxt_player.tile_mappings
        tiles = Enum.map(opts, &Utils.to_tile/1)
        non_flower_calls = Enum.reject(cxt_player.calls, fn {call_name, _call} -> call_name in ["flower", "joker", "start_flower", "start_joker"] end)
        winning_hand = cxt_player.hand ++ Enum.flat_map(non_flower_calls, &Riichi.call_to_tiles/1)
        winning_tile = if Map.has_key?(context, :winning_tile) do context.winning_tile else state.winners[context.seat].winning_tile end
        Enum.all?(winning_hand ++ [winning_tile], fn tile -> Utils.count_tiles([tile] ++ Map.get(tile_mappings, tile, []), tiles) > 0 end)
      "all_saki_cards_drafted"   -> Map.has_key?(state, :saki) && Saki.check_if_all_drafted(state)
      "has_existing_yaku"        -> Enum.all?(opts, fn opt -> case opt do
          [name, value] -> Enum.any?(context.existing_yaku, fn {name2, value2} -> name == name2 && value == value2 end)
          name          -> Enum.any?(context.existing_yaku, fn {name2, _value} -> name == name2 end)
        end end)
      "has_no_yaku"             -> Enum.empty?(context.existing_yaku)
      "placement"               ->
        placements = get_placements(state)
        Enum.any?(opts, &Enum.at(placements, &1 - 1) == context.seat)
      "last_discard_matches_existing" -> 
        if last_discard_action != nil do
          tile = last_discard_action.tile
          discards = state.players[last_discard_action.seat].discards |> Enum.drop(-1)
          tile_aliases = state.players[last_discard_action.seat].tile_aliases
          Enum.any?(discards, fn discard -> Utils.same_tile(tile, discard, tile_aliases) end)
        else false end
      "called_tile_matches_any_discard" ->
        if last_call_action != nil do
          tile = last_call_action.called_tile
          discards = Enum.flat_map(state.players, fn {_seat, player} -> player.pond end)
          tile_aliases = state.players[context.seat].tile_aliases
          Enum.any?(discards, fn discard -> Utils.same_tile(tile, discard, tile_aliases) end)
        else false end
      "last_discard_exists" ->
        last_discard_action != nil && last_discard_action.tile == Enum.at(state.players[last_discard_action.seat].pond, -1)
      "visible_discard_exists" ->
        last_discard_action != nil && Enum.any?(state.players, fn {_seat, player} -> Enum.any?(player.pond, fn tile -> Utils.count_tiles([tile], [:"1x", :"2x"]) == 0 end) end)
      "second_last_visible_discard_exists" ->
        last_discard_action != nil && Enum.any?(Enum.drop(state.players[last_discard_action.seat].pond, -1), fn tile -> Utils.count_tiles([tile], [:"1x", :"2x"]) == 0 end)
      "call_would_change_waits" ->
        win_definitions = translate_match_definitions(state, opts)
        hand = Utils.add_attr(cxt_player.hand, ["hand"])
        draw = Utils.add_attr(cxt_player.draw, ["hand"])
        calls = cxt_player.calls
        ordering = cxt_player.tile_ordering
        ordering_r = cxt_player.tile_ordering_r
        tile_aliases = cxt_player.tile_aliases
        tile_mappings = cxt_player.tile_mappings
        waits = Riichi.get_waits(hand, calls, win_definitions, ordering, ordering_r, tile_aliases)
        Enum.all?(Riichi.make_calls(context.calls_spec, hand ++ draw, ordering, ordering_r, [], tile_aliases, tile_mappings), fn {called_tile, call_choices} ->
          Enum.all?(call_choices, fn call_choice ->
            call_tiles = [called_tile | call_choice]
            call = {context.call_name, Enum.map(call_tiles, fn tile -> {tile, false} end)}
            waits_after_call = Riichi.get_waits((hand ++ draw) -- call_tiles, calls ++ [call], win_definitions, ordering, ordering_r, tile_aliases)
            # IO.puts("call: #{inspect(call)}")
            # IO.puts("waits: #{inspect(waits)}")
            # IO.puts("waits after call: #{inspect(waits_after_call)}")
            Enum.sort(waits) != Enum.sort(waits_after_call)
          end)
        end)
        # %{seat: seat, calls_spec: calls_spec, upgrade_name: upgrades, call_wraps: call_wraps})
      "call_changes_waits" ->
        win_definitions = translate_match_definitions(state, opts)
        ordering = cxt_player.tile_ordering
        ordering_r = cxt_player.tile_ordering_r
        tile_aliases = cxt_player.tile_aliases
        hand = cxt_player.hand
        draw = cxt_player.draw
        calls = cxt_player.calls
        call_tiles = [context.called_tile | context.call_choice]
        call = {context.call_name, Enum.map(call_tiles, fn tile -> {tile, false} end)}
        hand_calls_def_before = Riichi.partially_apply_match_definitions(hand, calls, win_definitions, ordering, ordering_r, tile_aliases)
        [call_removed | _] = Riichi.try_remove_all_tiles(hand ++ draw, Utils.strip_attrs(call_tiles))
        hand_calls_def_after = Riichi.partially_apply_match_definitions(call_removed, calls ++ [call], win_definitions, ordering, ordering_r, tile_aliases)
        Enum.any?(state.all_tiles, fn tile ->
          waits_before = Riichi.is_waiting_on(tile, hand_calls_def_before, ordering, ordering_r, tile_aliases)
          waits_after = Riichi.is_waiting_on(tile, hand_calls_def_after, ordering, ordering_r, tile_aliases)
          waits_before != waits_after
        end)
      "wait_count_at_least" ->
        number = Enum.at(opts, 0, 1)
        win_definitions = translate_match_definitions(state, Enum.at(opts, 1, []))
        ordering = cxt_player.tile_ordering
        ordering_r = cxt_player.tile_ordering_r
        tile_aliases = cxt_player.tile_aliases
        hand = cxt_player.hand
        calls = cxt_player.calls
        waits = Riichi.get_waits(hand, calls, win_definitions, ordering, ordering_r, tile_aliases)
        length(waits) >= number
      "wait_count_at_most" ->
        number = Enum.at(opts, 0, 1)
        win_definitions = translate_match_definitions(state, Enum.at(opts, 1, []))
        ordering = cxt_player.tile_ordering
        ordering_r = cxt_player.tile_ordering_r
        tile_aliases = cxt_player.tile_aliases
        hand = cxt_player.hand
        calls = cxt_player.calls
        waits = Riichi.get_waits(hand, calls, win_definitions, ordering, ordering_r, tile_aliases)
        length(waits) <= number
      "call_contains" ->
        tiles = Enum.at(opts, 0, []) |> Enum.map(&Utils.to_tile(&1))
        count = Enum.at(opts, 1, 1)
        called_tiles = [context.called_tile] ++ context.call_choice
        Utils.count_tiles(called_tiles, tiles) >= count
      "called_tile_contains" ->
        tiles = Enum.at(opts, 0, []) |> Enum.map(&Utils.to_tile(&1))
        count = Enum.at(opts, 1, 1)
        called_tiles = [context.called_tile]
        Utils.count_tiles(called_tiles, tiles) >= count
      "call_choice_contains" ->
        tiles = Enum.at(opts, 0, []) |> Enum.map(&Utils.to_tile(&1))
        count = Enum.at(opts, 1, 1)
        called_tiles = context.call_choice
        Utils.count_tiles(called_tiles, tiles) >= count
      "tagged"              ->
        targets = case Enum.at(opts, 0, "tile") do
          "last_discard" -> if last_discard_action != nil do [last_discard_action.tile] else [] end
          _ -> [context.tile]
        end
        tag = Enum.at(opts, 1, "missing_tag")
        tagged_tile = state.tags[tag]
        tile_aliases = state.players[context.seat].tile_aliases
        Enum.any?(targets, fn target -> Utils.same_tile(target, tagged_tile, tile_aliases) end)
      "has_attr"              ->
        targets = get_hand_calls_spec(state, context, [Enum.at(opts, 0, "tile")])
        |> Enum.map(fn {hand, _calls} -> hand end)
        Utils.has_attr?(targets, Enum.drop(opts, 1))
      "has_hell_wait" ->
        hand = cxt_player.hand
        calls = cxt_player.calls
        wait_definitions = translate_match_definitions(state, opts)
        ordering = cxt_player.tile_ordering
        ordering_r = cxt_player.tile_ordering_r
        tile_aliases = cxt_player.tile_aliases
        waits = Enum.flat_map(wait_definitions, fn definition -> Riichi.remove_match_definition(hand, calls, definition, ordering, ordering_r, tile_aliases) end)
        |> Enum.flat_map(fn {hand, _calls} -> hand end)
        visible_ponds = Enum.flat_map(state.players, fn {_seat, player} -> player.pond end)
        visible_calls = Enum.flat_map(state.players, fn {_seat, player} -> player.calls end)
        ukeire = Riichi.count_ukeire(waits, hand, visible_ponds, visible_calls, Map.get(context, :winning_tile, nil), tile_aliases)
        # IO.puts("Waits: #{inspect(waits)}, ukeire: #{inspect(ukeire)}")
        ukeire == 1
      "third_row_discard"   -> length(cxt_player.pond) >= 12
      "tiles_in_hand"       -> length(cxt_player.hand ++ cxt_player.draw) == Enum.at(opts, 0, 0)
      "anyone"              -> Enum.any?(state.players, fn {seat, _player} -> check_cnf_condition(state, opts, %{seat: seat}) end)
      "dice_equals"         -> (state.die1 + state.die2) in opts
      "counter_equals"      -> Map.get(cxt_player.counters, Enum.at(opts, 0, "counter"), 0) in Enum.drop(opts, 1)
      "counter_at_least"    -> Map.get(cxt_player.counters, Enum.at(opts, 0, "counter"), 0) >= Enum.at(opts, 1, 0)
      "counter_at_most"     -> Map.get(cxt_player.counters, Enum.at(opts, 0, "counter"), 0) <= Enum.at(opts, 1, 0)
      "genbutsu_shimocha"   ->
        tiles = (Utils.get_seat(context.seat, :shimocha) |> Riichi.get_safe_tiles_against(state.players, state.turn))
        last_discard_action != nil && Utils.count_tiles(tiles, [Utils.strip_attrs(last_discard_action.tile)]) >= 1
      "genbutsu_toimen"     ->
        tiles = (Utils.get_seat(context.seat, :toimen) |> Riichi.get_safe_tiles_against(state.players, state.turn))
        last_discard_action != nil && Utils.count_tiles(tiles, [Utils.strip_attrs(last_discard_action.tile)]) >= 1
      "genbutsu_kamicha"    ->
        tiles = (Utils.get_seat(context.seat, :kamicha) |> Riichi.get_safe_tiles_against(state.players, state.turn))
        last_discard_action != nil && Utils.count_tiles(tiles, [Utils.strip_attrs(last_discard_action.tile)]) >= 1
      "dealt_in_last_round" ->
        case state.log_state.kyokus do
          [] -> false
          [kyoku | _] ->
            case kyoku.result do
              [] -> false
              [win | _] -> win.won_from == Log.to_seat(context.seat)
            end
        end
      "wall_is_here"        ->
        dice_roll = state.die1 + state.die2
        break_dir = Riichi.get_break_direction(dice_roll, state.kyoku, context.seat)
        end_dir = cond do
          state.wall_index < 2*(17 - dice_roll) -> break_dir
          state.wall_index < 2*(34 - dice_roll) -> Utils.prev_turn(break_dir)
          state.wall_index < 2*(51 - dice_roll) -> Utils.prev_turn(break_dir, 2)
          state.wall_index < 2*(68 - dice_roll) -> Utils.prev_turn(break_dir, 3)
          true                                  -> break_dir
        end
        end_dir == :self
      "dead_wall_ends_here"        ->
        dice_roll = state.die1 + state.die2
        break_dir = Riichi.get_break_direction(dice_roll, state.kyoku, context.seat)
        wall_length = length(state.wall) + length(state.dead_wall)
        end_dir = cond do
          wall_length < 2*(17 - dice_roll) -> break_dir
          wall_length < 2*(34 - dice_roll) -> Utils.prev_turn(break_dir)
          wall_length < 2*(51 - dice_roll) -> Utils.prev_turn(break_dir, 2)
          wall_length < 2*(68 - dice_roll) -> Utils.prev_turn(break_dir, 3)
          true                             -> break_dir
        end
        end_dir == :self
      "bet_at_least"        -> state.pot >= Enum.at(opts, 0, 0)
      "is_winner"           -> Map.has_key?(state.winners, context.seat)
      _                     ->
        IO.puts "Unhandled condition #{inspect(cond_spec)}"
        false
    end
    # if Map.has_key?(context, :tile) do
    #   IO.puts("#{context.tile}, #{if negated do "not" else "" end} #{inspect(cond_spec)} => #{result}")
    # end
    # IO.puts("#{inspect(context)}, #{if negated do "not" else "" end} #{inspect(cond_spec)} => #{result}")
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

end
