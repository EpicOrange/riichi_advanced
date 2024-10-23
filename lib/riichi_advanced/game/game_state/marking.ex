
defmodule RiichiAdvanced.GameState.Marking do
  import RiichiAdvanced.GameState

  def initialize_marking(state) do
    state = Map.put(state, :marking, %{
      # for example: 
      # east: {
      #   done: false,
      #   hand: {
      #     marked: [{:"2m", :east, 4}],
      #     needed: 1,
      #     restrictions: ["same_suit_as_marked_discard"]
      #   },
      #   discard: {
      #     marked: [],
      #     needed: 1,
      #     restrictions: ["same_suit_as_marked_hand"]
      #   },
      # }
      east: %{},
      south: %{},
      west: %{},
      north: %{}
    })
    state
  end

  def setup_marking(state, seat, to_mark) do
    state = put_in(state.marking[seat], for {target, amount, restrictions} <- to_mark, reduce: %{done: false} do
      marked ->
        mark_spec = %{marked: [], needed: amount, restrictions: restrictions}
        case target do
          "hand"          -> Map.put(marked, :hand, mark_spec)
          "aside"         -> Map.put(marked, :aside, mark_spec)
          "discard"       -> Map.put(marked, :discard, mark_spec)
          "revealed_tile" -> Map.put(marked, :revealed_tile, mark_spec)
          "scry"          -> Map.put(marked, :scry, mark_spec)
          _               ->
            GenServer.cast(self(), {:show_error, "Unknown mark target: #{inspect(target)}"})
            marked
        end
    end)
    state
  end

  def needs_marking?(state, seat) do
    Enum.any?(state.marking[seat], fn {source, mark_info} -> not (source == :done) && length(mark_info.marked) < mark_info.needed end)
  end

  defp get_tile(state, seat, index, source) do
    case source do
      :hand          -> state.players[seat].hand ++ state.players[seat].draw |> Enum.at(index)
      :aside         -> state.players[seat].aside |> Enum.at(index)
      :discard       -> state.players[seat].pond |> Enum.at(index)
      :revealed_tile -> Enum.at(get_revealed_tiles(state), index)
      :scry          -> state.wall |> Enum.at(state.wall_index + index)
      _              ->
        GenServer.cast(self(), {:show_error, "Unknown mark source: #{inspect(source)}"})
        nil
    end
  end

  def can_mark?(state, marking_player, seat, index, source) do
    tile = get_tile(state, seat, index, source)
    mark_info = state.marking[marking_player][source]
    marked_enough = mark_info != nil && length(mark_info.marked) >= mark_info.needed
    already_marked = is_marked?(state, marking_player, seat, index, source)
    mark_info != nil && not marked_enough && not already_marked && Enum.all?(mark_info.restrictions, fn restriction ->
      case restriction do
        "suited"            -> Riichi.is_suited?(tile)
        "match_suit"        ->
          if Riichi.is_suited?(tile) do
            Map.values(state.marking[marking_player])
            |> Enum.filter(&Kernel.is_map/1)
            |> Enum.map(fn mark_info -> mark_info.marked end)
            |> Enum.concat()
            |> Enum.all?(fn {tile2, _, _} -> Riichi.same_suit?(tile, tile2) end)
          else false end
        "match_number"        ->
          if Riichi.is_suited?(tile) do
            Map.values(state.marking[marking_player])
            |> Enum.filter(&Kernel.is_map/1)
            |> Enum.map(fn mark_info -> mark_info.marked end)
            |> Enum.concat()
            |> Enum.all?(fn {tile2, _, _} -> Riichi.same_number?(tile, tile2) end)
          else false end
        "match_called_tile" -> Utils.same_tile(tile, get_last_call_action(state).called_tile, state.players[marking_player].tile_aliases)
        "self"              -> marking_player == seat
        "others"            -> marking_player != seat
        "shimocha"          -> Utils.get_relative_seat(marking_player, seat) == :shimocha
        "toimen"            -> Utils.get_relative_seat(marking_player, seat) == :toimen
        "kamicha"           -> Utils.get_relative_seat(marking_player, seat) == :kamicha
        "current_turn"      -> seat == state.turn
        "7z"                -> tile == :"7z"
        "wind"              -> Riichi.is_wind?(tile)
        "dragon"            -> Riichi.is_dragon?(tile)
        "terminal_honor"    -> Riichi.is_yaochuuhai?(tile)
        "not_riichi"        -> 
          case source do
            :discard -> "riichi" not in state.players[marking_player].status || index >= length(state.players[marking_player].hand)
            _        -> true
          end

        "last_discard"      ->
          case source do
            :discard ->
              last_discard_action = get_last_discard_action(state)
              if last_discard_action != nil do
                seat_matches = seat == last_discard_action.seat
                index_matches = index == length(state.players[seat].pond) - 1
                seat_matches && index_matches
              else false end
            _        -> false
          end
        _                   ->
          GenServer.cast(self(), {:show_error, "Unknown restriction: #{inspect(restriction)}"})
          true
      end
    end)
  end

  def is_marked?(state, marking_player, seat, index, source) do
    case source do
      :hand          -> Map.has_key?(state.marking[marking_player], :hand) && Enum.any?(state.marking[marking_player].hand.marked, fn {_tile, seat2, index2} -> seat == seat2 && index == index2 end)
      :aside         -> Map.has_key?(state.marking[marking_player], :aside) && Enum.any?(state.marking[marking_player].aside.marked, fn {_tile, seat2, index2} -> seat == seat2 && index == index2 end)
      :discard       -> Map.has_key?(state.marking[marking_player], :discard) && Enum.any?(state.marking[marking_player].discard.marked, fn {_tile, seat2, index2} -> seat == seat2 && index == index2 end)
      :revealed_tile -> Map.has_key?(state.marking[marking_player], :revealed_tile) && Enum.any?(state.marking[marking_player].revealed_tile.marked, fn {_tile, _, index2} -> index == index2 end)
      :scry          -> Map.has_key?(state.marking[marking_player], :scry) && Enum.any?(state.marking[marking_player].scry.marked, fn {_tile, _, index2} -> index == index2 end)
      _        ->
        GenServer.cast(self(), {:show_error, "Unknown mark source: #{inspect(source)}"})
        false
    end
  end

  def mark_tile(state, marking_player, seat, index, source) do
    case source do
      :hand          -> update_in(state.marking[marking_player].hand.marked, fn marked -> marked ++ [{get_tile(state, seat, index, source), seat, index}] end)
      :aside         -> update_in(state.marking[marking_player].aside.marked, fn marked -> marked ++ [{get_tile(state, seat, index, source), seat, index}] end)
      :discard       -> update_in(state.marking[marking_player].discard.marked, fn marked -> marked ++ [{get_tile(state, seat, index, source), seat, index}] end)
      :revealed_tile -> update_in(state.marking[marking_player].revealed_tile.marked, fn marked -> marked ++ [{get_tile(state, seat, index, source), nil, index}] end)
      :scry          -> update_in(state.marking[marking_player].scry.marked, fn marked -> marked ++ [{get_tile(state, seat, index, source), nil, index}] end)
      _              ->
        GenServer.cast(self(), {:show_error, "Unknown mark source: #{inspect(source)}"})
        state
    end
  end

  def clear_marked_objects(state, seat) do
    update_in(state.marking[seat], &Map.new(&1, fn {source, mark_info} -> {source, if source == :done do false else Map.put(mark_info, :marked, []) end} end))
  end

  def reset_marking(state, marking_player) do
    state = put_in(state.marking[marking_player], %{})
    state
  end
end
