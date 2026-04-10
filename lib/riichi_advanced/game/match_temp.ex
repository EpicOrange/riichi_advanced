defmodule RiichiAdvanced.Match.Temp do
  alias RiichiAdvanced.GameState.TileBehavior, as: TileBehavior
  alias RiichiAdvanced.Utils, as: Utils
  import Bitwise

  # encode first argument A into a number, using second argument B as a dictionary
  # (first item of B = 1, second = 2, third = 4, etc)
  # assumes both inputs are sorted
  def _encode_attrs(tile_attrs, all_attrs, acc \\ 0, inc \\ 1)
  def _encode_attrs(_tile_attrs, [], acc, _inc), do: acc
  def _encode_attrs([], _all_attrs, acc, _inc), do: acc
  def _encode_attrs([attr | attrs], [attr | all_attrs], acc, inc) do
    _encode_attrs(attrs, all_attrs, acc + inc, inc * 2)
  end
  def _encode_attrs([l_attr | attrs], [r_attr | _] = all_attrs, acc, inc) when l_attr < r_attr do
    _encode_attrs(attrs, all_attrs, acc, inc)
  end
  def _encode_attrs([_l_attr | _] = attrs, [_r_attr | all_attrs], acc, inc) do
    _encode_attrs(attrs, all_attrs, acc, inc * 2)
  end

  # def _decode_attrs(encoded_attrs, all_attrs, acc \\ [])
  # def _decode_attrs(_encoded_attrs, [], acc), do: Enum.reverse(acc)
  # def _decode_attrs(0, _all_attrs, acc), do: Enum.reverse(acc)
  # def _decode_attrs(encoded_attrs, [attr | all_attrs], acc) when (encoded_attrs &&& 1) == 1 do
  #   _decode_attrs(encoded_attrs >>> 1, all_attrs, [attr | acc])
  # end
  # def _decode_attrs(encoded_attrs, [_attr | all_attrs], acc) do
  #   _decode_attrs(encoded_attrs >>> 1, all_attrs, acc)
  # end

  # tile1 must have at least the attributes of tile2
  def same_tile({t1, attrs1}, {t2, attrs2}) do
    same_id = t1 == t2 or t1 == :any or t2 == :any
           or (t2 == :faceup and t1 not in [:"1x", :"2x", :"3x", :"4x"])
    same_id && (attrs1 &&& attrs2) >= attrs2
  end

  def same_number({t1, attrs1}, {t2, attrs2}) do
    same_tile({Utils.to_manzu(t1), attrs1}, {Utils.to_manzu(t2), attrs2})
  end

  # we want to try not to remove :any if possible (important for american hands)
  # the return value is acc, it tries not to remove :any
  # acc2 is the case where we do remove :any for the first time
  # return immediately if we remove a non-:any tile
  # otherwise if we reach [] we return acc2 (i.e. we removed :any)
  defp _remove_tile(num_hand, check, acc \\ [], acc2 \\ nil, index \\ 0)
  defp _remove_tile([], _check, _acc, nil, _index), do: nil # we didn't remove anything, give up
  defp _remove_tile([], _check, _acc, {acc, rest, index}, _index), do: {Enum.reverse(acc, rest), index}
  defp _remove_tile([t | rest], check, acc, acc2, index) do
    do_remove = check.(t)
    cond do
      do_remove and t != {:any, 0} -> {Enum.reverse(acc, rest), index}
      do_remove and acc2 == nil    -> _remove_tile(rest, check, [t | acc], {acc, rest, index}, index + 1)
      true                         -> _remove_tile(rest, check, [t | acc], acc2, index + 1)
    end
  end
  defp remove_tile(num_hand, tile, ignore_suit) do
    _remove_tile(num_hand, if ignore_suit do &same_number(&1, tile) else &same_tile(&1, tile) end)
  end

  # gets all variations of indices you need to delete (in sequence)
  # if you want to remove `num_tiles` from `num_hand`
  # e.g. [[5,5,5]] means delete index 5 three times
  defp get_indices_of_tiles_in_hand(num_hand, num_tiles, ignore_suit) do
    for tile <- num_tiles, reduce: [{num_hand, []}] do
      []               -> []
      num_hands_ixs ->
        for {num_hand, ixs} <- num_hands_ixs do
          case remove_tile(num_hand, tile, ignore_suit) do
            nil       -> []
            {ret, ix} -> [{ret, [ix | ixs]}]
          end
        end |> Enum.concat()
    end |> Enum.map(fn {_num_hand, ixs} -> Enum.reverse(ixs) end)
  end

  def try_remove_all_tiles(hand, tiles, tile_behavior \\ %TileBehavior{}) do
    if length(hand) >= length(tiles) do
      # first collect all attrs across all tiles we care about
      attr_tiles = tiles
      |> Enum.map(&Utils.to_attr_tile/1)
      |> Enum.map(fn {tile, attrs} -> {tile, Enum.reject(attrs, &String.starts_with?(&1, "_"))} end)
      all_attrs = attr_tiles
      |> Enum.flat_map(fn {_tile, attrs} -> attrs end)
      |> Enum.uniq()
      |> Enum.sort()

      # then normalize each tile to {tile_id, tile_attrs}
      # and encode each tile_attrs as a bitset indexing into all_attrs

      num_hand = hand
      |> Enum.map(&Utils.to_attr_tile/1)
      |> Enum.map(fn {tile, attrs} -> {tile, attrs |> Enum.map(&String.replace_prefix(&1, "_", "")) |> Enum.sort() |> _encode_attrs(all_attrs)} end)

      num_tiles = attr_tiles
      |> Enum.flat_map(&Utils.apply_tile_aliases(&1, tile_behavior) |> MapSet.to_list() |> TileBehavior.sort_by_joker_power(tile_behavior))
      |> Enum.map(fn {tile, attrs} -> {tile, attrs |> Enum.sort() |> _encode_attrs(all_attrs)} end)

      # insta-reject if there is any attr in all_attrs not represented in hand
      expected_sum = (2 ** length(all_attrs)) - 1 # could be zero, in which case no need to check
      sum_hand_attrs = if expected_sum == 0 do 0 else Enum.reduce(num_hand, 0, fn {_tile, attr_bits}, acc -> acc ||| attr_bits end) end
      if expected_sum == sum_hand_attrs do
        # now produce the output by removing each index in turn
        for ixs <- get_indices_of_tiles_in_hand(num_hand, num_tiles, tile_behavior.ignore_suit) do
          for ix <- ixs, reduce: hand do
            hand -> List.delete_at(hand, ix)
          end
        end
        # |> IO.inspect(label: "#{inspect(hand)} (#{inspect(num_hand)}) -- #{inspect(tiles)} (#{inspect(num_tiles)}) =")
      else [] end # otherwise we're asking for more attributes than we have altogether
    else [] end # otherwise we'd be trying to remove more tiles than we have altogether
  end

end
