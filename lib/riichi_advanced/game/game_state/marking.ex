
defmodule RiichiAdvanced.GameState.Marking do
  alias RiichiAdvanced.GameState.Actions, as: Actions
  alias RiichiAdvanced.GameState.Debug, as: Debug
  alias RiichiAdvanced.GameState.Log, as: Log
  alias RiichiAdvanced.GameState.TileBehavior, as: TileBehavior
  alias RiichiAdvanced.Riichi, as: Riichi
  alias RiichiAdvanced.Utils, as: Utils
  import RiichiAdvanced.GameState

  @special_keys [:done, :cancellable, :post_actions]
  @mark_targets %{
    "hand" => :hand,
    "call" => :calls,
    "aside" => :aside,
    "discard" => :discard,
    "revealed_tile" => :revealed_tile,
    "scry" => :scry,
  }

  def special_keys(), do: @special_keys
  def mark_targets(), do: @mark_targets

  def initialize_marking(state) do
    # give each seat a marking array. for example:
    # east: [
    #   done: false,
    #   cancellable: true,
    #   post_actions: [],
    #   hand: {
    #     marked: [{:"2m", :east, 4}],
    #     needed: 1,
    #     restrictions: ["match_suit"]
    #   },
    #   discard: {
    #     marked: [],
    #     needed: 1,
    #     restrictions: ["match_suit"]
    #   }
    # ]
    Map.put(state, :marking, Map.new(state.available_seats, fn seat -> {seat, []} end))
  end

  def setup_marking(state, seat, to_mark, cancellable, post_actions) do
    init = [done: false, cancellable: cancellable, post_actions: post_actions]
    state = put_in(state.marking[seat], for {target, amount, restrictions} <- to_mark, reduce: init do
      marked_objects ->
        mark_spec = %{marked: [], needed: amount, restrictions: restrictions}
        target = Map.get(@mark_targets, target, nil)
        if target == nil do
          GenServer.cast(self(), {:show_error, "Unknown mark target: #{inspect(target)}"})
          marked_objects
        else
          marked_objects ++ [{target, mark_spec}]
        end
    end)
    state
  end

  def needs_marking?(state, seat) do
    Enum.any?(state.marking[seat], fn {source, mark_info} -> (source not in @special_keys) and length(mark_info.marked) < mark_info.needed end)
  end

  def get_object(state, seat, index, source) do
    case source do
      :hand          -> state.players[seat].hand ++ state.players[seat].draw |> Enum.at(index)
      :calls         -> state.players[seat].calls |> Enum.at(index)
      :aside         -> state.players[seat].aside |> Enum.at(index)
      :discard       -> state.players[seat].pond |> Enum.at(index)
      :revealed_tile -> Enum.at(get_revealed_tiles(state), index)
      :scry          -> state.wall |> Enum.at(state.wall_index + index)
      _              ->
        GenServer.cast(self(), {:show_error, "Unknown mark source: #{inspect(source)}"})
        nil
    end
  end

  defp get_mark_infos(marked_objects, source) do
    Enum.filter(marked_objects, fn {src, _mark_info} -> src == source end)
  end

  def get_marked(marked_objects, source) do
    get_mark_infos(marked_objects, source)
    |> Enum.flat_map(fn {_src, mark_info} -> mark_info.marked end)
  end

  def is_marking?(marked_objects, source) do
    not Enum.empty?(get_mark_infos(marked_objects, source))
  end

  def num_objects_needed(marked_objects) do
    Keyword.values(marked_objects)
    |> Enum.filter(&is_map/1)
    |> Enum.map(fn mark_info -> mark_info.needed end)
    |> Enum.sum()
  end

  def is_done?(state, marking_player) do
    [{:done, val}] = get_mark_infos(state.marking[marking_player], :done)
    val
  end

  def mark_done(state, marking_player) do
    update_in(state.marking[marking_player], &Enum.map(&1, fn {src, mark_info} ->
      if src == :done do {src, true} else {src, mark_info} end
    end))
  end

  defp _can_mark?(state, marking_player, seat, index, source, mark_info) do
    tile = get_object(state, seat, index, source)
    Enum.all?(mark_info.restrictions, fn restriction ->
      case restriction do
        "suited"            -> Riichi.is_suited?(tile)
        "match_suit"        ->
          if Riichi.is_suited?(tile) do
            Keyword.values(state.marking[marking_player])
            |> Enum.filter(&is_map/1)
            |> Enum.map(fn mark_info -> mark_info.marked end)
            |> Enum.concat()
            |> Enum.all?(fn {tile2, _, _} -> Riichi.same_suit?(tile, tile2) end)
          else false end
        "match_number"        ->
          if Riichi.is_suited?(tile) do
            Keyword.values(state.marking[marking_player])
            |> Enum.filter(&is_map/1)
            |> Enum.map(fn mark_info -> mark_info.marked end)
            |> Enum.concat()
            |> Enum.all?(fn {tile2, _, _} -> Riichi.same_number?(tile, tile2) end)
          else false end
        "match_called_tile" -> Utils.same_tile(tile, get_last_call_action(state).called_tile, state.players[marking_player].tile_behavior)
        "match_hand_to_marked_call" ->
          state.marking[marking_player]
          |> Enum.filter(fn {src, _mark_info} -> src == :calls end)
          |> Enum.map(fn {_src, mark_info} -> mark_info.marked end)
          |> Enum.concat()
          |> Enum.all?(fn {call, _, _} ->
            call_tile = Utils.get_joker_meld_tile(call, [:"1j"], state.players[marking_player].tile_behavior)
            Utils.same_tile(tile, Utils.strip_attrs(call_tile), state.players[marking_player].tile_behavior) end)
        "match_call_to_marked_hand" ->
          call_tile = Utils.get_joker_meld_tile(tile, [:"1j"], state.players[marking_player].tile_behavior)
          state.marking[marking_player]
          |> Enum.filter(fn {src, _mark_info} -> src == :hand end)
          |> Enum.map(fn {_src, mark_info} -> mark_info.marked end)
          |> Enum.concat()
          |> Enum.all?(fn {tile, _, _} -> Utils.same_tile(call_tile, Utils.strip_attrs(tile), state.players[marking_player].tile_behavior) end)
        "self"              -> marking_player == seat
        "others"            -> marking_player != seat
        "shimocha"          -> Utils.get_relative_seat(marking_player, seat) == :shimocha
        "toimen"            -> Utils.get_relative_seat(marking_player, seat) == :toimen
        "kamicha"           -> Utils.get_relative_seat(marking_player, seat) == :kamicha
        "current_turn"      -> seat == state.turn
        "open"              ->
          with {call_type, _call} <- tile do
            # TODO don't hardcode these
            call_type in ["chii", "pon", "daiminkan", "kakan"]
          end
        "wind"              -> Riichi.is_wind?(tile)
        "dragon"            -> Riichi.is_dragon?(tile)
        "terminal_honor"    -> Riichi.is_yaochuuhai?(tile)
        "visible"           -> not Utils.has_matching_tile?([tile], [:"1x", :"2x"])
        "not_joker"         -> not TileBehavior.is_any_joker?(tile, state.players[marking_player].tile_behavior)
        "call_has_joker"    -> Enum.any?(Utils.call_to_tiles(tile), &TileBehavior.is_any_joker?(&1, state.players[marking_player].tile_behavior))
        "not_riichi"        -> "riichi" not in state.players[marking_player].status or index >= length(state.players[marking_player].hand)
        "last_discard"      ->
          case source do
            :discard ->
              last_discard_action = get_last_discard_action(state)
              if last_discard_action != nil do
                seat_matches = seat == last_discard_action.seat
                index_matches = index == length(state.players[seat].pond) - 1
                seat_matches and index_matches
              else false end
            _        -> false
          end
        _                   ->
          if Utils.is_tile(restriction) do
            Utils.same_tile(tile, Utils.to_tile(restriction))
          else
            GenServer.cast(self(), {:show_error, "Unknown restriction: #{inspect(restriction)}"})
            true
          end
      end
    end)
  end

  def can_mark?(state, marking_player, seat, index, source) do
    mark_infos = get_mark_infos(state.marking[marking_player], source)
    Enum.any?(mark_infos, fn {_src, mark_info} ->
      marked_enough = mark_info != nil and length(mark_info.marked) >= mark_info.needed
      already_marked = is_marked?(state, marking_player, seat, index, source)
      mark_info != nil and not marked_enough and not already_marked and _can_mark?(state, marking_player, seat, index, source, mark_info)
    end)
  end

  def is_marked?(state, marking_player, seat, index, source) do
    get_mark_infos(state.marking[marking_player], source)
    |> Enum.any?(fn {_src, mark_info} -> 
      Enum.any?(mark_info.marked, fn {_tile, seat2, index2} -> seat2 in [seat, nil] and index == index2 end)
    end)
  end

  def mark_tile(state, marking_player, seat, index, source) do
    if not Enum.empty?(state.marking[marking_player]) do
      valid_mark_info_ix = state.marking[marking_player]
      |> Enum.find_index(fn {src, mark_info} -> src == source and _can_mark?(state, marking_player, seat, index, source, mark_info) end)
      update_in(state.marking[marking_player], &List.update_at(&1, valid_mark_info_ix, fn {src, mark_info} ->
        {src, update_in(mark_info.marked, fn marked -> marked ++ [{get_object(state, seat, index, source), seat, index}] end)}
      end))
    else state end
  end

  def clear_marked_objects(state, marking_player) do
    if not Enum.empty?(state.marking[marking_player]) do
      update_in(state.marking[marking_player], &Enum.map(&1, fn {source, mark_info} -> {source, case source do
        :done                          -> false
        _ when source in @special_keys -> mark_info
        _                              -> Map.put(mark_info, :marked, [])
      end} end))
    else state end
  end

  def reset_marking(state, marking_player) do
    state = put_in(state.marking[marking_player], [])
    state
  end

  # this is called after every marking action
  def adjudicate_marking(state) do
    # only continue if no one needs marking
    if not Enum.any?(state.available_seats, &needs_marking?(state, &1)) do
      state = for seat <- state.available_seats, not Enum.empty?(state.marking[seat]), reduce: state do
        state ->
          # run actions, including the mark action that marks done
          state = Actions.run_deferred_actions(state, %{seat: seat})
          # only reset marking once the mark action marks it done
          if is_done?(state, seat) do
            state = Log.log(state, seat, :mark, %{marking: Log.encode_marking(state.marking[seat])})

            # run post-mark actions
            # remember that some other action must have run to set :done
            # in order for this to run at all
            [{:post_actions, post_actions}] = get_mark_infos(state.marking[seat], :post_actions)
            if Debug.debug_actions() do
              IO.puts("Running post-mark actions for #{seat}: #{inspect(post_actions)}")
            end
            state = Actions.run_actions(state, post_actions, %{seat: seat})

            state = reset_marking(state, seat)
            state
          else state end
      end
      # ensure playable_indices is populated for the new turn
      state = broadcast_state_change(state, true)
      state
    else state end
  end
end
