
defmodule RiichiAdvanced.GameState.Conditions do
  alias RiichiAdvanced.GameState.Actions, as: Actions
  alias RiichiAdvanced.GameState.American, as: American
  alias RiichiAdvanced.GameState.Debug, as: Debug
  alias RiichiAdvanced.GameState.Log, as: Log
  alias RiichiAdvanced.GameState.Player, as: Player
  alias RiichiAdvanced.GameState.Saki, as: Saki
  alias RiichiAdvanced.GameState.Scoring, as: Scoring
  alias RiichiAdvanced.GameState.TileBehavior, as: TileBehavior
  alias RiichiAdvanced.Match, as: Match
  alias RiichiAdvanced.Riichi, as: Riichi
  alias RiichiAdvanced.Utils, as: Utils
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
          "calls" -> [{hand, calls ++ Enum.reject(state.players[context.seat].calls, fn {call_name, _call} -> call_name in Riichi.flower_names() end)}]
          "flowers" -> [{hand, calls ++ Enum.filter(state.players[context.seat].calls, fn {call_name, _call} -> call_name in ["flower", "start_flower", "pei"] end)}]
          "start_flowers" -> [{hand, calls ++ Enum.filter(state.players[context.seat].calls, fn {call_name, _call} -> call_name == "start_flower" end)}]
          "jokers" -> [{hand, calls ++ Enum.filter(state.players[context.seat].calls, fn {call_name, _call} -> call_name in ["joker", "start_joker"] end)}]
          "start_jokers" -> [{hand, calls ++ Enum.filter(state.players[context.seat].calls, fn {call_name, _call} -> call_name == "start_joker" end)}]
          "call_tiles" -> [{hand ++ Enum.flat_map(state.players[context.seat].calls, &Utils.call_to_tiles(&1, true)), calls}]
          "arranged_hand" -> [{hand ++ state.players[context.seat].cache.arranged_hand, calls}]
          "arranged_calls" -> [{hand, calls ++ state.players[context.seat].cache.arranged_calls}]
          "last_call" -> [{hand, calls ++ [context.call]}]
          "last_called_tile" -> if last_call_action != nil do [{hand ++ [last_call_action.called_tile], calls}] else [{hand, calls}] end
          "last_discard" -> if last_discard_action != nil do [{hand ++ [last_discard_action.tile], calls}] else [{hand, calls}] end
          "second_last_visible_discard" ->
            if last_discard_action != nil do 
              visible_pond = state.players[last_discard_action.seat].pond
              |> Enum.drop(-1)
              |> Enum.reject(&Utils.has_matching_tile?([&1], [:"1x", :"2x"]))
              if not Enum.empty?(visible_pond) do
                [{hand ++ Enum.take(visible_pond, -1), calls}]
              else [{hand, calls}] end
            else [{hand, calls}] end
          "self_last_discard" -> [{hand ++ Enum.take(state.players[context.seat].pond, -1), calls}]
          "shimocha_last_discard" -> [{hand ++ Enum.take(state.players[Utils.get_seat(context.seat, :shimocha)].pond, -1), calls}]
          "toimen_last_discard" -> [{hand ++ Enum.take(state.players[Utils.get_seat(context.seat, :toimen)].pond, -1), calls}]
          "kamicha_last_discard" -> [{hand ++ Enum.take(state.players[Utils.get_seat(context.seat, :kamicha)].pond, -1), calls}]
          "shimocha_calls" -> [{hand, calls ++ state.players[Utils.get_seat(context.seat, :shimocha)].calls}]
          "toimen_calls" -> [{hand, calls ++ state.players[Utils.get_seat(context.seat, :toimen)].calls}]
          "kamicha_calls" -> [{hand, calls ++ state.players[Utils.get_seat(context.seat, :kamicha)].calls}]
          "all_last_discards" -> [{hand ++ Enum.flat_map(state.players, fn {_seat, player} -> Enum.take(player.pond, -1) end), calls}]
          "tile" -> [{hand ++ [context.tile], calls}]
          "called_tile" -> [{hand ++ [context.choice.chosen_called_tile], calls}]
          "call_choice" -> [{hand ++ context.choice.chosen_call_choice, calls}]
          "winning_tile" ->
            winning_tile = Map.get(context, :winning_tile, get_in(state.winners[context.seat].winning_tile))
            [{hand ++ [Utils.add_attr(winning_tile, ["winning_tile"])], calls}]
          "assigned_hand" -> [{state.winners[context.seat].assigned_hand, calls}] # includes winning tile
          "any_discard" -> Enum.map(state.players[context.seat].discards, fn discard -> {hand ++ [discard], calls} end)
          "all_discards" -> [{hand ++ Enum.flat_map(state.players, fn {_seat, player} -> player.pond end), calls}]
          "others_discards" -> [{hand ++ Enum.flat_map(state.players, fn {seat, player} -> if seat == context.seat do [] else player.pond end end), calls}]
          "all_calls" -> [{hand, calls ++ Enum.flat_map(state.players, fn {_seat, player} -> player.calls end)}]
          "all_call_tiles" -> [{hand ++ Enum.flat_map(state.players, fn {_seat, player} -> Enum.flat_map(player.calls, &Utils.call_to_tiles/1) end), calls}]
          "revealed_tiles" -> [{hand ++ get_revealed_tiles(state), calls}]
          "visible_tiles" -> [{hand ++ get_visible_tiles(state), calls}]
          "any_visible_tile" -> Enum.map(get_visible_tiles(state), fn tile -> {hand ++ [tile], calls} end)
          "hand_any" -> Enum.flat_map(state.players[context.seat].hand, fn tile -> [{hand ++ [tile], calls}] end)
          "hand_draw_nonjoker_any" ->
            player = state.players[context.seat]
            Enum.flat_map(player.hand ++ player.draw, fn tile ->
              [{hand ++ if TileBehavior.is_any_joker?(tile, player.tile_behavior) do [] else [tile] end, calls}]
            end)
          "scry" -> [{hand ++ get_scryed_tiles(state, context.seat), calls}]
          "self_joker_meld_tiles" ->
            # used in malaysian, this selects one nonjoker tile from own exposed calls containing a joker
            state.players[context.seat].calls
            |> Enum.map(&Utils.get_joker_meld_tile(&1, [:"2y"], state.players[context.seat].tile_behavior))
            |> Enum.reject(&is_nil/1)
            |> Enum.flat_map(fn tile -> [{hand ++ [tile], calls}] end)
          "anyone_joker_meld_tiles" ->
            # used in american, this selects one nonjoker tile from each exposed call containing a joker
            state.players
            |> Enum.flat_map(fn {_seat, player} -> Enum.map(player.calls, &Utils.get_joker_meld_tile(&1, [:"1j"], player.tile_behavior)) end)
            |> Enum.reject(&is_nil/1)
            |> Enum.flat_map(fn tile -> [{hand ++ [tile], calls}] end)
          _ ->
            IO.puts("Unhandled hand_calls spec #{inspect(item)}")
            [{hand, calls}]
        end
      end |> Enum.concat()
    end
  end

  @all_seat_specs [
    "east",
    "south",
    "west",
    "north",
    "self",
    "shimocha",
    "toimen",
    "kamicha",
    "last_discarder",
    "caller",
    "callee",
    "all",
    "everyone",
    "others",
    "chii_victims"
  ]

  def all_seat_specs, do: @all_seat_specs

  def from_seat_spec(state, context, seat_spec) do
    case seat_spec do
      "east" -> Riichi.get_player_from_seat_wind(state.kyoku, :east, state.available_seats)
      "south" -> Riichi.get_player_from_seat_wind(state.kyoku, :south, state.available_seats)
      "west" -> Riichi.get_player_from_seat_wind(state.kyoku, :west, state.available_seats)
      "north" -> Riichi.get_player_from_seat_wind(state.kyoku, :north, state.available_seats)
      "shimocha" -> Utils.get_seat(context.seat, :shimocha)
      "toimen" -> Utils.get_seat(context.seat, :toimen)
      "kamicha" -> Utils.get_seat(context.seat, :kamicha)
      "last_discarder" ->
        last_discard_action = get_last_discard_action(state)
        if last_discard_action != nil do last_discard_action.seat else context.seat end
      "caller" ->
        last_call_action = get_last_call_action(state)
        Map.get(context, :caller, if last_call_action != nil do last_call_action.seat else context.seat end)
      "callee" ->
        last_call_action = get_last_call_action(state)
        Map.get(context, :callee, if last_call_action != nil do last_call_action.from else context.seat end)
      _ -> context.seat
    end
  end

  def from_seats_spec(state, context, seat_spec) do
    negated = is_binary(seat_spec) and String.starts_with?(seat_spec, "not_")
    seat_spec = if negated do String.slice(seat_spec, 4..-1//1) else seat_spec end
    seats = case seat_spec do
      "all" -> state.available_seats
      "everyone" -> state.available_seats
      "others" -> state.available_seats -- [context.seat]
      "chii_victims" -> for {"chii", tiles} <- state.players[context.seat].calls do
        # check sideways tiles
        case Enum.map(tiles, &Utils.has_attr?(&1, ["sideways"])) do
          [false, false, true] -> [:shimocha]
          [false, true, false] -> [:toimen]
          [true, false, false] -> [:kamicha]
          _ -> []
        end
      end |> Enum.concat()
      _ when is_list(seat_spec) -> Enum.flat_map(seat_spec, &from_seats_spec(state, context, &1)) |> Enum.uniq()
      _ -> [from_seat_spec(state, context, seat_spec)]
    end
    if negated do state.available_seats -- seats else seats end
  end

  def get_placements(state) do
    state.players
    |> Enum.sort_by(fn {seat, player} -> -player.score - Riichi.get_seat_scoring_offset(state.kyoku, seat, state.available_seats) end)
    |> Enum.map(fn {seat, _player} -> seat end)
  end

  def get_yaku_lists(state) do
    (get_in(state.rules["score_calculation"]["yaku_lists"]) || []) -- (get_in(state.rules["score_calculation"]["extra_yaku_lists"]) || [])
  end

  def get_yaku2_lists(state) do
    (get_in(state.rules["score_calculation"]["yaku2_lists"]) || []) -- (get_in(state.rules["score_calculation"]["extra_yaku_lists"]) || [])
  end

  def check_condition(state, cond_spec, context \\ %{}, opts \\ []) do
    t = System.os_time(:millisecond)

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
      "last_call_is"                -> last_call_action != nil and last_call_action.call_name in opts
      # TODO replace with "as": keyword
      "kamicha_discarded"           -> last_action != nil and last_action.action == :discard and last_action.seat == state.turn and state.turn == Utils.prev_turn(context.seat)
      "toimen_discarded"            -> last_action != nil and last_action.action == :discard and last_action.seat == state.turn and state.turn == Utils.prev_turn(context.seat, 2)
      "shimocha_discarded"          -> last_action != nil and last_action.action == :discard and last_action.seat == state.turn and state.turn == Utils.prev_turn(context.seat, 3)
      "anyone_just_discarded"       -> last_action != nil and last_action.action == :discard and last_action.seat == state.turn
      "someone_else_just_discarded" -> last_action != nil and last_action.action == :discard and last_action.seat == state.turn and state.turn != context.seat
      "just_discarded"              -> last_action != nil and last_action.action == :discard and last_action.seat == state.turn and state.turn == context.seat
      "just_called"                 -> last_action != nil and last_action.action == :call and last_action.seat == state.turn
      "just_self_called"            -> last_action != nil and last_action.action == :call and last_action.seat == state.turn and last_action.from == state.turn
      "call_available"              -> last_action != nil and last_action.action == :discard and Riichi.can_call?(context.calls_spec, Utils.add_attr(cxt_player.hand, ["hand"]), cxt_player.tile_behavior, [last_action.tile])
      "self_call_available"         -> Riichi.can_call?(context.calls_spec, Utils.add_attr(cxt_player.hand, ["hand"]) ++ Utils.add_attr(cxt_player.draw, ["hand"]), cxt_player.tile_behavior, [])
      "can_upgrade_call"            -> cxt_player.calls
        |> Enum.filter(fn {name, _call} -> name == context.upgrade_name end)
        |> Enum.map(&Utils.call_to_tiles/1)
        |> Enum.any?(&Riichi.can_call?(context.calls_spec, &1, cxt_player.tile_behavior, cxt_player.hand ++ cxt_player.draw))
      "has_draw"                 -> not Enum.empty?(state.players[from_seat_spec(state, context, Enum.at(opts, 0, "self"))].draw)
      "has_aside"                -> not Enum.empty?(state.players[from_seat_spec(state, context, Enum.at(opts, 0, "self"))].aside)
      "has_calls"                -> not Enum.empty?(state.players[from_seat_spec(state, context, Enum.at(opts, 0, "self"))].calls)
      "has_call_named"           -> Enum.all?(cxt_player.calls, fn {name, _call} -> name in opts end)
      "has_no_call_named"        -> Enum.all?(cxt_player.calls, fn {name, _call} -> name not in opts end)
      "won_by_call"              -> context.win_source == :call
      "won_by_draw"              -> context.win_source == :draw
      "won_by_discard"           -> context.win_source == :discard
      "fu_equals"                -> context.minipoints == Enum.at(opts, 0, 20)
      "has_yaku"                 -> context.seat in state.winner_seats and Scoring.seat_scores_points(state, get_yaku_lists(state), Enum.at(opts, 0, 1), Enum.at(opts, 1, 0), context.seat, state.winners[context.seat].winning_tile, state.winners[context.seat].win_source)
      "has_yaku2"                -> context.seat in state.winner_seats and Scoring.seat_scores_points(state, get_yaku2_lists(state), Enum.at(opts, 0, 1), Enum.at(opts, 1, 0), context.seat, state.winners[context.seat].winning_tile, state.winners[context.seat].win_source)
      "has_yaku_with_hand"       -> Scoring.seat_scores_points(state, get_yaku_lists(state), Enum.at(opts, 0, 1), Enum.at(opts, 1, 0), context.seat, Enum.at(cxt_player.draw, 0, nil), :draw)
      "has_yaku_with_discard"    -> last_action != nil and last_action.action == :discard and Scoring.seat_scores_points(state, get_yaku_lists(state), Enum.at(opts, 0, 1), Enum.at(opts, 1, 0), context.seat, last_action.tile, :discard)
      "has_yaku_with_call"       -> last_action != nil and last_action.action == :call and Scoring.seat_scores_points(state, get_yaku_lists(state), Enum.at(opts, 0, 1), Enum.at(opts, 1, 0), context.seat, last_action.tile, :call)
      "has_yaku2_with_hand"      -> Scoring.seat_scores_points(state, get_yaku2_lists(state), Enum.at(opts, 0, 1), Enum.at(opts, 1, 0), context.seat, Enum.at(cxt_player.draw, 0, nil), :draw)
      "has_yaku2_with_discard"   -> last_action != nil and last_action.action == :discard and Scoring.seat_scores_points(state, get_yaku2_lists(state), Enum.at(opts, 0, 1), Enum.at(opts, 1, 0), context.seat, last_action.tile, :discard)
      "has_yaku2_with_call"      -> last_action != nil and last_action.action == :call and Scoring.seat_scores_points(state, get_yaku2_lists(state), Enum.at(opts, 0, 1), Enum.at(opts, 1, 0), context.seat, last_action.tile, :call)
      "has_declared_yaku_with_hand"    -> Scoring.seat_scores_points(state, opts, :declared, 0, context.seat, Enum.at(cxt_player.draw, 0, nil), :draw)
      "has_declared_yaku_with_discard" -> last_action != nil and last_action.action == :discard and Scoring.seat_scores_points(state, opts, :declared, 0, context.seat, last_action.tile, :discard)
      "has_declared_yaku_with_call"    -> last_action != nil and last_action.action == :call and Scoring.seat_scores_points(state, opts, :declared, 0, context.seat, last_action.tile, :call)
      "last_discard_matches"     -> last_discard_action != nil and Riichi.tile_matches(opts, %{tile: last_discard_action.tile, tile2: Map.get(context, :tile, nil), players: state.players, seat: context.seat})
      "last_called_tile_matches" -> last_action != nil and last_action.action == :call and Riichi.tile_matches(opts, %{tile: last_action.called_tile, tile2: Map.get(context, :tile, nil), call: last_call_action, players: state.players, seat: context.seat})
      "needed_for_hand"          -> Riichi.needed_for_hand(cxt_player.hand ++ cxt_player.draw, cxt_player.calls, context.tile, translate_match_definitions(state, opts), cxt_player.tile_behavior)
      "is_drawn_tile"            -> Utils.has_attr?(context.tile, ["draw"])
      "status"                   -> Enum.all?(opts, fn st -> st in cxt_player.status end)
      "status_missing"           -> Enum.all?(opts, fn st -> st not in cxt_player.status end)
      "discarder_status"         -> last_action != nil and last_action.action == :discard and Enum.all?(opts, fn st -> st in state.players[last_action.seat].status end)
      "callee_status"            -> last_action != nil and last_action.action == :call and Enum.all?(opts, fn st -> st in state.players[last_action.from].status end)
      "caller_status"            -> last_action != nil and last_action.action == :call and Enum.all?(opts, fn st -> st in state.players[last_action.seat].status end)
      "shimocha_status"          -> Enum.all?(opts, fn st -> st in state.players[Utils.get_seat(context.seat, :shimocha)].status end)
      "toimen_status"            -> Enum.all?(opts, fn st -> st in state.players[Utils.get_seat(context.seat, :toimen)].status end)
      "kamicha_status"           -> Enum.all?(opts, fn st -> st in state.players[Utils.get_seat(context.seat, :kamicha)].status end)
      "others_status"            -> Enum.any?(state.players, fn {seat, player} -> Enum.all?(opts, fn st -> seat != context.seat and st in player.status end) end)
      "anyone_status"            -> Enum.any?(state.players, fn {_seat, player} -> Enum.all?(opts, fn st -> st in player.status end) end)
      "everyone_status"          -> Enum.all?(state.players, fn {_seat, player} -> Enum.all?(opts, fn st -> st in player.status end) end)
      "buttons_include"          -> Enum.all?(opts, fn button_name -> button_name in cxt_player.buttons end)
      "buttons_exclude"          -> Enum.all?(opts, fn button_name -> button_name not in cxt_player.buttons end)
      "tile_drawn"               -> Enum.all?(opts, fn tile -> tile in state.drawn_reserved_tiles end)
      "tile_not_drawn"           -> Enum.all?(opts, fn tile -> tile not in state.drawn_reserved_tiles end)
      "tile_revealed"            ->
        Enum.all?(opts, fn tile ->
          tile in state.revealed_tiles or if is_integer(tile) do
            (tile - length(state.dead_wall)) in state.revealed_tiles
          else false end
        end)
      "tile_not_revealed"        ->
        Enum.all?(opts, fn tile ->
          tile not in state.revealed_tiles and if is_integer(tile) do
            (tile - length(state.dead_wall)) not in state.revealed_tiles
          else true end
        end)
      "no_tiles_remaining"       -> length(state.wall) - state.wall_index <= 0
      "tiles_remaining"          -> length(state.wall) - state.wall_index >= Enum.at(opts, 0, 0)
      "next_draw_possible"       ->
        draws_left = length(state.wall) - state.wall_index
        case Utils.get_relative_seat(context.seat, state.turn) do
          :shimocha -> draws_left >= 3
          :toimen   -> draws_left >= 2
          :kamicha  -> draws_left >= 1
          :self     -> draws_left >= 4
        end
      "has_score"                -> state.players[context.seat].score >= Actions.interpret_amount(state, context, opts)
      "has_score_below"          -> state.players[context.seat].score < Actions.interpret_amount(state, context, opts)
      "round_wind_is"            ->
        round_wind = Riichi.get_round_wind(state.kyoku, length(state.available_seats))
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
        seat_wind = Riichi.get_seat_wind(state.kyoku, context.seat, state.available_seats)
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
      "aside_tile_count"         -> length(cxt_player.aside) in opts
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
          Utils.count_tiles(cxt_player.cache.winning_hand, doras) == num
        else false end
      "winning_reverse_dora_count" ->
        dora_indicator = from_named_tile(state, Enum.at(opts, 0, :"1m"))
        if dora_indicator != nil do
          num = Enum.at(opts, 1, 1)
          doras = Map.get(state.rules["reverse_dora_indicators"], Utils.tile_to_string(dora_indicator), []) |> Enum.map(&Utils.to_tile/1)
          Utils.count_tiles(cxt_player.cache.winning_hand, doras) == num
        else false end
      "match"                    ->
        hand_calls = get_hand_calls_spec(state, context, Enum.at(opts, 0, []))
        match_definitions = translate_match_definitions(state, Enum.at(opts, 1, []))
        tile_behavior = cxt_player.tile_behavior
        Enum.any?(hand_calls, fn {hand, calls} -> Match.match_hand(hand, calls, match_definitions, tile_behavior) end)
      "winning_hand_consists_of" ->
        tile_mappings = TileBehavior.tile_mappings(cxt_player.tile_behavior)
        tiles = Enum.map(opts, &Utils.to_tile/1)
        non_flower_calls = Enum.reject(cxt_player.calls, fn {call_name, _call} -> call_name in Riichi.flower_names() end)
        winning_hand = cxt_player.hand ++ Enum.flat_map(non_flower_calls, &Utils.call_to_tiles/1)
        winning_tile = if Map.has_key?(context, :winning_tile) do context.winning_tile else state.winners[context.seat].winning_tile end
        Enum.all?(winning_hand ++ [winning_tile], &Utils.has_matching_tile?([&1] ++ Map.get(tile_mappings, &1, []), tiles))
      "winning_hand_not_tile_consists_of" ->
        tile_mappings = TileBehavior.tile_mappings(cxt_player.tile_behavior)
        tiles = Enum.map(opts, &Utils.to_tile/1)
        non_flower_calls = Enum.reject(cxt_player.calls, fn {call_name, _call} -> call_name in Riichi.flower_names() end)
        winning_hand = cxt_player.hand ++ Enum.flat_map(non_flower_calls, &Utils.call_to_tiles/1)
        Enum.all?(winning_hand, &Utils.has_matching_tile?([&1] ++ Map.get(tile_mappings, &1, []), tiles))
      "all_saki_cards_drafted"   -> Map.has_key?(state, :saki) and Saki.check_if_all_drafted(state)
      "has_existing_yaku"        -> Enum.all?(opts, fn opt -> case opt do
          [name, value] -> Enum.any?(context.existing_yaku, fn {name2, value2} -> name == name2 and value == value2 end)
          name          -> Enum.any?(context.existing_yaku, fn {name2, _value} -> name == name2 end)
        end end)
      "has_no_yaku"             -> Enum.empty?(context.existing_yaku)
      "has_points"              -> Enum.sum(Enum.map(context.existing_yaku, fn {_name, value} -> value end)) >= Enum.at(opts, 0, 1)
      "placement"               ->
        placements = get_placements(state)
        Enum.any?(opts, &Enum.at(placements, &1 - 1) == context.seat)
      "last_discard_matches_existing" -> 
        if last_discard_action != nil do
          tile = last_discard_action.tile
          discards = state.players[last_discard_action.seat].discards |> Enum.drop(-1)
          tile_behavior = state.players[last_discard_action.seat].tile_behavior
          Enum.any?(discards, fn discard -> Utils.same_tile(tile, discard, tile_behavior) end)
        else false end
      "called_tile_matches_any_discard" ->
        if last_call_action != nil do
          tile = last_call_action.called_tile
          discards = Enum.flat_map(state.players, fn {_seat, player} -> player.pond end)
          tile_behavior = state.players[context.seat].tile_behavior
          Enum.any?(discards, fn discard -> Utils.same_tile(tile, discard, tile_behavior) end)
        else false end
      "last_discard_exists" ->
        last_discard_action != nil and last_discard_action.tile == Enum.at(state.players[last_discard_action.seat].pond, -1)
      "visible_discard_exists" ->
        last_discard_action != nil and Enum.any?(state.players, fn {_seat, player} -> Enum.any?(player.pond, &not Utils.has_matching_tile?([&1], [:"1x", :"2x"])) end)
      "second_last_visible_discard_exists" ->
        last_discard_action != nil and Enum.any?(Enum.drop(state.players[last_discard_action.seat].pond, -1), &not Utils.has_matching_tile?([&1], [:"1x", :"2x"]))
      "call_would_change_waits" ->
        # context here is %{seat: seat, call_name: name, calls_spec: calls_spec, upgrade_name: upgrades}
        win_definitions = translate_match_definitions(state, opts)
        hand = Utils.add_attr(cxt_player.hand, ["hand"])
        draw = Utils.add_attr(cxt_player.draw, ["hand"])
        calls = cxt_player.calls
        waits = Riichi.get_waits(hand, calls, win_definitions, cxt_player.tile_behavior)
        Enum.all?(Riichi.make_calls(context.calls_spec, hand ++ draw, cxt_player.tile_behavior, []), fn {called_tile, call_choices} ->
          Enum.all?(call_choices, fn call_choice ->
            call_tiles = [called_tile | call_choice]
            call = {context.call_name, call_tiles}
            waits_after_call = Riichi.get_waits((hand ++ draw) -- call_tiles, calls ++ [call], win_definitions, cxt_player.tile_behavior)
            # IO.puts("call: #{inspect(call)}")
            # IO.puts("waits: #{inspect(waits)}")
            # IO.puts("waits after call: #{inspect(waits_after_call)}")
            Enum.sort(waits) != Enum.sort(waits_after_call)
          end)
        end)
      "call_changes_waits" ->
        win_definitions = translate_match_definitions(state, opts)
        hand = cxt_player.hand
        draw = cxt_player.draw
        calls = cxt_player.calls
        call_tiles = [context.choice.chosen_called_tile | context.choice.chosen_call_choice]
        call = {context.choice.name, call_tiles}
        waits_before = Riichi.get_waits(hand, calls, win_definitions, cxt_player.tile_behavior, true)
        [call_removed | _] = Match.try_remove_all_tiles(hand ++ draw, Utils.strip_attrs(call_tiles))
        waits_after = Riichi.get_waits(call_removed, calls ++ [call], win_definitions, cxt_player.tile_behavior, true)
        waits_before != waits_after
      "wait_count_at_least" ->
        number = Enum.at(opts, 0, 1)
        win_definitions = translate_match_definitions(state, Enum.at(opts, 1, []))
        tile_behavior = cxt_player.tile_behavior
        hand = cxt_player.hand
        calls = cxt_player.calls
        waits = Riichi.get_waits(hand, calls, win_definitions, tile_behavior)
        MapSet.size(waits) >= number
      "wait_count_at_most" ->
        number = Enum.at(opts, 0, 1)
        win_definitions = translate_match_definitions(state, Enum.at(opts, 1, []))
        tile_behavior = cxt_player.tile_behavior
        hand = cxt_player.hand
        calls = cxt_player.calls
        waits = Riichi.get_waits(hand, calls, win_definitions, tile_behavior)
        MapSet.size(waits) <= number
      "call_contains" ->
        tiles = Enum.at(opts, 0, []) |> Enum.map(&Utils.to_tile(&1))
        count = Enum.at(opts, 1, 1)
        called_tiles = [context.choice.chosen_called_tile] ++ context.choice.chosen_call_choice
        Utils.count_tiles(called_tiles, tiles) >= count
      "called_tile_contains" ->
        tiles = Enum.at(opts, 0, []) |> Enum.map(&Utils.to_tile(&1))
        count = Enum.at(opts, 1, 1)
        called_tiles = [context.choice.chosen_called_tile]
        Utils.count_tiles(called_tiles, tiles) >= count
      "call_choice_contains" ->
        tiles = Enum.at(opts, 0, []) |> Enum.map(&Utils.to_tile(&1))
        count = Enum.at(opts, 1, 1)
        called_tiles = context.choice.chosen_call_choice
        Utils.count_tiles(called_tiles, tiles) >= count
      "tagged"              ->
        targets = case Enum.at(opts, 0, "tile") do
          "last_discard" -> if last_discard_action != nil do [last_discard_action.tile] else [] end
          _ -> [context.tile]
        end
        tag = Enum.at(opts, 1, "missing_tag")
        tagged_tiles = state.tags[tag]
        tile_behavior = state.players[context.seat].tile_behavior
        Enum.any?(targets, fn target -> Utils.has_matching_tile?(target, tagged_tiles, tile_behavior) end)
      "has_attr"              ->
        targets = get_hand_calls_spec(state, context, [Enum.at(opts, 0, "tile")])
        |> Enum.map(fn {hand, _calls} -> hand end)
        Utils.has_attr?(targets, Enum.drop(opts, 1))
      "has_hell_wait" ->
        wait_definitions = translate_match_definitions(state, opts)
        ukeire = Riichi.get_waits_and_ukeire(cxt_player.hand, cxt_player.calls, wait_definitions, get_visible_tiles(state), cxt_player.tile_behavior)
        |> Map.values()
        |> Enum.sum()
        # IO.puts("Ukeire: #{inspect(ukeire)}")
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
        last_discard_action != nil and Utils.has_matching_tile?(tiles, [Utils.strip_attrs(last_discard_action.tile)])
      "genbutsu_toimen"     ->
        tiles = (Utils.get_seat(context.seat, :toimen) |> Riichi.get_safe_tiles_against(state.players, state.turn))
        last_discard_action != nil and Utils.has_matching_tile?(tiles, [Utils.strip_attrs(last_discard_action.tile)])
      "genbutsu_kamicha"    ->
        tiles = (Utils.get_seat(context.seat, :kamicha) |> Riichi.get_safe_tiles_against(state.players, state.turn))
        last_discard_action != nil and Utils.has_matching_tile?(tiles, [Utils.strip_attrs(last_discard_action.tile)])
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
        break_dir = Riichi.get_break_direction(dice_roll, state.kyoku, context.seat, state.available_seats)
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
        break_dir = Riichi.get_break_direction(dice_roll, state.kyoku, context.seat, state.available_seats)
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
      "shimocha_exists"     -> Utils.get_seat(context.seat, :shimocha) in state.available_seats
      "toimen_exists"       -> Utils.get_seat(context.seat, :toimen) in state.available_seats
      "kamicha_exists"      -> Utils.get_seat(context.seat, :kamicha) in state.available_seats
      "three_winners"       -> map_size(state.winners) == 3
      "hand_length_at_least" -> length(state.players[context.seat].hand ++ state.players[context.seat].draw) >= Enum.at(opts, 0, 0)
      "current_turn_is"     -> state.turn == from_seat_spec(state, context, Enum.at(opts, 0, "self"))
      "hand_is_dead"        ->
        seat = from_seat_spec(state, context, Enum.at(opts, 0, "self"))
        am_match_definitions = Map.get(state.rules, "win_definition", [])
        American.check_dead_hand(state, seat, am_match_definitions)
      "all_calls_deaden_hand" ->
        am_match_definitions = Map.get(state.rules, "win_definition", [])
        for {button_name, {:call, choices}} <- state.players[context.seat].button_choices,
            {called_tile, call_choices} <- choices,
            call_choice <- call_choices,
            reduce: true do
          false -> false
          true  ->
            call_name = Map.get(state.rules["buttons"][button_name], "call_name", button_name)
            call = {call_name, Utils.strip_attrs([called_tile | call_choice])}
            update_player(state, context.seat, &%Player{ &1 | hand: Enum.drop(&1.hand, length(call_choice)), calls: &1.calls ++ [call] })
            |> American.get_viable_am_match_definitions(context.seat, am_match_definitions)
            |> Enum.empty?()
        end
      "is_ai"               -> is_pid(Map.get(state, context.seat))
      "num_players"         -> length(state.available_seats) == Enum.at(opts, 0, 4)
      "is_tenpai_american"  ->
        player = state.players[context.seat]
        Enum.any?(player.cache.closest_american_hands, fn {_am_match_definition, pairing_r, _arranged_hand} -> map_size(pairing_r) == length(player.hand ++ player.draw) end)
      _                     ->
        IO.puts "Unhandled condition #{inspect(cond_spec)}"
        false
    end
    # if Map.has_key?(context, :tile) do
    #   IO.puts("#{context.tile}, #{if negated do "not" else "" end} #{inspect(cond_spec)} => #{result}")
    # end
    # IO.puts("#{inspect(context)}, #{if negated do "not" else "" end} #{inspect(cond_spec)} => #{result}")

    if Debug.debug_conditions() do
      elapsed_time = System.os_time(:millisecond) - t
      if elapsed_time > 100 do
        IO.puts("check_condition: #{inspect(elapsed_time)} ms to check #{inspect([cond_spec | opts])} with context #{inspect(context)}")
      end
    end

    if negated do not result else result end
  end

  def check_dnf_condition(state, cond_spec, context \\ %{}) do
    cond do
      is_binary(cond_spec) -> check_condition(state, cond_spec, context)
      is_map(cond_spec)    ->
        context = if Map.has_key?(cond_spec, "as") do %{context | orig_seat: context.seat, seat: from_seat_spec(state, context, cond_spec["as"])} else context end
        check_condition(state, cond_spec["name"], context, cond_spec["opts"])
      is_list(cond_spec)   ->
        case cond_spec do
          # at most n (but at least 1)
          [n | cond_spec] when is_integer(n) ->
            count = Enum.count(cond_spec, &check_cnf_condition(state, &1, context))
            1 <= count and count <= n
          # at most all (but at least 1)
          _ -> Enum.any?(cond_spec, &check_cnf_condition(state, &1, context))
        end
      true                 ->
        IO.puts "Unhandled condition clause #{inspect(cond_spec)}"
        true
    end
  end

  def check_cnf_condition(state, cond_spec, context \\ %{}) do
    cond do
      is_binary(cond_spec) -> check_condition(state, cond_spec, context)
      is_map(cond_spec)    ->
        context = if Map.has_key?(cond_spec, "as") do %{context | seat: from_seat_spec(state, context, cond_spec["as"])} else context end
        check_condition(state, cond_spec["name"], context, cond_spec["opts"])
      is_list(cond_spec)   ->
        case cond_spec do
          # at least n
          [n | cond_spec] when is_integer(n) -> Enum.count(cond_spec, &check_dnf_condition(state, &1, context)) >= n
          # at least all
          _ -> Enum.all?(cond_spec, &check_dnf_condition(state, &1, context))
        end
      true                 ->
        IO.puts "Unhandled condition clause #{inspect(cond_spec)}"
        true
    end
  end

end
