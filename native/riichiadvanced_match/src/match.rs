use std::collections::{HashSet};
use crate::encode::{encode, encode_aliases};
use crate::tileset::{_remove_indices, __subtract, __subtract_exhaustive, _subtract_check_attrs_exhaustive};
use crate::types::{Aliases, ElixirAliases, ElixirHand, Hands, RemovableGroup, Tile, TileSet};

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

fn elim_call_name(hands: &Hands, name: &String, exhaustive: bool) -> Vec<Hands> {
  // group is a call name, remove every corresponding call with that name
  let mut ret = vec!();
  for i in 0..hands.len() {
    if let Some(call_name) = &hands[i].name {
      if call_name == name {
        let mut hands = hands.clone();
        hands.remove(i);
        ret.push(hands);
        if !exhaustive { break; }
      }
    }
  }
  ret
}
fn elim_tileset(
  hands: &Hands, tileset: &TileSet,
  encoded_aliases: &Aliases,
  encoded_joker_tiles: &HashSet<&Tile>,
  exhaustive: bool,
) -> Vec<Hands> {
  let mut ret = vec!();
  // check calls first
  for i in 1..hands.len() {
    if let Some(_) = __subtract_exhaustive(&hands[i], tileset, encoded_aliases, encoded_joker_tiles) {
      let mut hands = hands.clone();
      hands.remove(i);
      ret.push(hands);
      if !exhaustive { break; }
    }
  }
  if exhaustive {
    // then check hand, for each one make copies of hands, placing results into each one
    if let Some(results) = __subtract_exhaustive(&hands[0], tileset, encoded_aliases, encoded_joker_tiles) {
      for result in results {
        let mut hands = hands.clone();
        hands[0] = result;
        ret.push(hands);
      }
    }
  } else {
    // then check hand
    if let Some(result) = __subtract(&hands[0], tileset, encoded_aliases, encoded_joker_tiles) {
      let mut hands = hands.clone();
      hands[0] = result;
      ret.push(hands);
    }
  }
  ret
}

// #[rustler::nif]
fn elim_group(
    hands: Hands, group: RemovableGroup,
    encoded_aliases: Aliases,
    encoded_joker_tiles: Vec<Tile>,
    exhaustive: bool,
) -> Vec<Hands> {
  _elim_group(&hands, &group, &encoded_aliases, &encoded_joker_tiles.iter().collect(), exhaustive)
}
fn _elim_group(
    hands: &Hands, group_arg: &RemovableGroup,
    encoded_aliases: &Aliases,
    encoded_joker_tiles: &HashSet<&Tile>,
    exhaustive: bool,
) -> Vec<Hands> {
  match group_arg {
    RemovableGroup::CallName(name) => elim_call_name(hands, name, exhaustive),
    RemovableGroup::Group(group) => elim_tileset(hands, &group, encoded_aliases, encoded_joker_tiles, exhaustive),
    RemovableGroup::GroupRef(group) => elim_tileset(hands, group, encoded_aliases, encoded_joker_tiles, exhaustive),
    RemovableGroup::Multigroup(subgroups) => {
      // multigroup can only be removed from hand (= hands[0])
      let mut ret = vec!(hands.clone());
      for subgroup in subgroups {
        let results = ret.iter().flat_map(move |hands| {
          _elim_group(hands, &RemovableGroup::GroupRef(&subgroup), encoded_aliases, encoded_joker_tiles, exhaustive)
        });
        // only retain one result if not exhaustive
        if exhaustive { ret = results.collect(); }
        else { ret = results.take(1).collect(); }
      }
      ret
    }
  }
}
