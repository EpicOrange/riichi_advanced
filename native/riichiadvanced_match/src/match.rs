use std::collections::{HashSet};
use crate::encode::{encode, encode_aliases};
use crate::tileset::{_remove_indices, _subtract_check_attrs_exhaustive};
use crate::types::{Aliases, ElixirAliases, ElixirHand, Hands, MatchGroup, Tile};

// this is used a lot, especially for determining and processing calls
// #[rustler::nif]
fn try_remove_all_tiles(
    hand: ElixirHand, tiles: ElixirHand,
    elixir_aliases: ElixirAliases, all_attrs: Vec<String>
) -> Vec<ElixirHand> {
  _try_remove_all_tiles(hand, tiles, &elixir_aliases, &all_attrs)
}
fn _try_remove_all_tiles(
    hand: ElixirHand, tiles: ElixirHand,
    elixir_aliases: &ElixirAliases, all_attrs: &[String]
) -> Vec<ElixirHand> {
  let hand_length = hand.len();
  let tiles_length = tiles.len();
  if hand_length < tiles_length {
    vec!()
  } else if hand_length < tiles_length {
    // we can simply sort and compare pairwise
    let mut hand = hand.clone();
    let mut tiles = tiles.clone();
    hand.sort_unstable();
    tiles.sort_unstable();
    if hand.iter().zip(tiles.iter()).all(|(l, r)| l == r) {
      vec!(vec!())
    } else {
      vec!()
    }
  } else {
    // encode every tile into a TileSet
    let empty_hashset = HashSet::new();
    let hand_set = encode(&hand, all_attrs, &empty_hashset);
    let tiles_set = encode(&tiles, all_attrs, &empty_hashset);
    let aliases = encode_aliases(elixir_aliases, all_attrs, &empty_hashset);
    match _subtract_check_attrs_exhaustive(&hand_set.attrs, &tiles_set.attrs, &aliases) {
      Some(iss) => {
        let mut ret = vec!();
        for is in iss {
          let mut hand = hand.clone();
          _remove_indices(&mut hand, &is);
          ret.push(hand);
        }
        ret
      }
      None => vec!(),
    }
  }
}

// fn elim_group(
//     hands: &Hands, group: &MatchGroup,
//     all_attrs: &[String],
//     encoded_aliases: &Aliases,
//     encoded_joker_tiles: &HashSet<&Tile>
// ) -> Vec<Hands> {
//   match group {
//     MatchGroup::CallName(name) => {
//       // group is a call name, remove every corresponding call with that name
//       let mut ret = vec!();
//       for i in 0..hands.len() {
//         if let Some(call_name) = &hands[i].name {
//           if call_name == name {
//             let mut hands = hands.clone();
//             hands.remove(i);
//             ret.push(hands);
//           }
//         }
//       }
//       ret
//     }
//     MatchGroup::Offsets(match_offsets) => {

//     }
//     MatchGroup::Subgroups(items) => todo!(),
//   }
// }

  // def elim_group([hand | calls], group, tile_behavior) do
  //   cond do
  //     is_list(group) ->
  //       for subgroup <- group, reduce: [[hand | calls]] do
  //         acc when is_list(subgroup) ->
  //           # subgroup contains multiple parts that can be removed independently
  //           for part <- subgroup, reduce: acc do
  //             nil -> []
  //             acc -> Enum.flat_map(acc, &elim_group(&1, part, tile_behavior))
  //           end
  //         acc -> Enum.flat_map(acc, &elim_group(&1, subgroup, tile_behavior))
  //       end
  //     true ->
  //        
  // end

  //       # for subgroup <- group, reduce: [[hand | calls]] do
  //       #   acc ->
  //       #     IO.inspect(Enum.map(acc, fn x -> Enum.map(x, &decode/1) end), label: inspect(decode(subgroup)))
  //       #     Enum.flat_map(acc, &elim_group(&1, subgroup))
  //       # end |> IO.inspect(label: inspect(Enum.map(group, &decode/1)))
  //     true ->
  //       from_calls = for {call, i} <- Enum.with_index(calls), is_subset?(group, call, tile_behavior), do: [hand | List.delete_at(calls, i)]
  //       # if length(group.attrs) == 3 do IO.puts("#{inspect(hand)}\n- #{inspect(group)}\n= #{inspect(subtract(hand, group))}") end
  //       case subtract_exhaustive(hand, group, tile_behavior.encoded_aliases, tile_behavior.encoded_joker_tiles |> Enum.to_list()) do
  //         nil -> from_calls
  //         ret ->
  //           for new_hand <- ret do
  //             # IO.inspect({hand.attrs, "-", group.attrs, "=", new_hand.attrs}, label: "Subtracting", limit: :infinity)
  //             # IO.inspect({length(hand.attrs), "-", length(group.attrs), "=", length(new_hand.attrs)}, label: "Subtracting")
  //             [new_hand | calls]
  //           end ++ from_calls
  //       end
  //   end
