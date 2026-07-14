use std::collections::{HashMap, HashSet};
use rustler::Atom;

use crate::encode::{encode, encode_aliases, encode_tile};
use crate::types::{ElixirAliases, ElixirHand, ElixirHandCalls, ElixirTile, MatchInfo, Tile};
use crate::utils::{fetch_tile_aliases};

// move all tiles from (hand, calls) into two structures:
// - orig_hands, basically a copy of what was passed in minus call names
// - tiles_in_hand, references to all tiles in orig_hands
fn prepare_hand_calls((hand, calls): &ElixirHandCalls) -> Vec<(&ElixirHand, String)> {
  vec!((hand, "".to_owned())).into_iter().chain(
    calls.into_iter().map(|(name, call)| (call, name.to_owned()))
  ).collect::<Vec<_>>()
}

pub fn prepare_tiles<'a>(
    hand_calls: &'a ElixirHandCalls,
    all_attrs: &'a Vec<String>,
    elixir_aliases: &'a ElixirAliases,
    ordering: &'a HashMap<Atom, Atom>, ordering_r: &'a HashMap<Atom, Atom>,
) -> MatchInfo<'a> {
  // println!("  hand_calls: {0:?}", hand_calls);
  let orig_hands = prepare_hand_calls(hand_calls);
  // println!("  orig_hands: {0:?}", orig_hands);
  let mut tiles_in_hand: Vec<&ElixirTile> = vec!();
  for (hand, _) in &orig_hands { tiles_in_hand.append(&mut hand.iter().collect()); }
  let num_tiles_in_hand = tiles_in_hand.len();
  // println!("  tiles_in_hand: {0:?}", tiles_in_hand);



  // relevant_tiles = nonjoker tiles in hand + tiles mapped to by jokers in hand
  // elixir_joker_tiles = joker tiles in hand
  // (we use relevant_tiles to calculate base tiles)
  let mut relevant_tiles: Vec<ElixirTile> = Vec::with_capacity(num_tiles_in_hand);
  let mut elixir_joker_tiles: HashSet<ElixirTile> = HashSet::new();
  for tile in tiles_in_hand.clone() {
    let aliases = fetch_tile_aliases(elixir_aliases, &tile);
    if !aliases.is_empty() {
      elixir_joker_tiles.insert(tile.clone());
      relevant_tiles.extend(aliases);
    }
    relevant_tiles.push(tile.clone());
  }
  relevant_tiles.sort();
  relevant_tiles.dedup();

  let joker_tiles: HashSet<Tile> = elixir_joker_tiles
    .iter()
    .flat_map(|t| encode_tile(t, all_attrs))
    .collect();

  // first make a mapping {encoding <=> tile in hand}
  let mut encoding: HashMap<&ElixirTile, Tile> = HashMap::new();
  for tile in tiles_in_hand.iter().copied() {
    if let Some(encoded) = encode_tile(tile, all_attrs) {
      encoding.insert(tile, encoded);
    }
  }
  // the jokers are the tiles in hand whose corresponding encoding is an alias for some tile
  // first, collect all such tiles
  let mut encoded_alias_tiles: Vec<Tile> = vec!();
  for attrs_aliases in elixir_aliases.values() {
    for elixir_aliases in attrs_aliases.values() {
      for elixir_alias in elixir_aliases {
        if let Some(encoded_alias) = encode_tile(elixir_alias, all_attrs) {
          encoded_alias_tiles.push(encoded_alias);
        }
      }
    }
  }

  // generate new TileSets from the above
  let mut initial_hands = vec!();
  for (hand, name) in &orig_hands {
    let mut ret = encode(hand, &all_attrs, &joker_tiles);
    if name != "" { ret.name = Some(name.to_owned()); }
    initial_hands.push(ret);
  }


  // println!("relevant_tiles: {:?}\n", relevant_tiles);
  // println!("all_tiles: {:?}\n", all_tiles);

  // println!("initial_hands: {:?}", initial_hands.iter().map(|t| decode(t, all_attrs)).collect::<Vec<_>>());
  // println!("elixir_joker_tiles: {:?}", elixir_joker_tiles);
  // println!("joker_tiles: {:?}\n", joker_tiles);

  MatchInfo{
    // orig_hands,
    tiles_in_hand,
    initial_hands,
    num_tiles_in_hand,
    all_attrs,
    aliases: encode_aliases(&elixir_aliases, &all_attrs, &joker_tiles, None),
    elixir_joker_tiles,
    relevant_tiles,
    joker_tiles,
    // encoding,
    ordering,
    ordering_r,
  }
}



// pub fn prepare_tiles_v2<'a>(
//     hand_calls: &'a ElixirHandCalls,
//     all_attrs: &'a Vec<String>, elixir_aliases: &'a ElixirAliases,
//     ordering: &'a HashMap<Atom, Atom>, ordering_r: &'a HashMap<Atom, Atom>,
// ) -> MatchInfo<'a> {
//   let orig_hands = prepare_hand_calls(hand_calls);
//   let mut hand_tiles: Vec<ElixirTile> = vec!();
//   for (&ref hand, _) in orig_hands.iter() { hand_tiles.append(&mut hand.clone().into_iter().collect()); }
//   let num_tiles_in_hand = hand_tiles.len();
//   hand_tiles.sort();
//   hand_tiles.dedup();

//   // relevant_tiles = nonjoker tiles in hand + tiles mapped to by jokers in hand
//   // elixir_joker_tiles = joker tiles in hand
//   // (we use relevant_tiles to calculate base tiles)
//   let mut relevant_tiles: Vec<ElixirTile> = Vec::with_capacity(hand_tiles.len());
//   let mut elixir_joker_tiles: HashSet<ElixirTile> = HashSet::new();
//   for tile in hand_tiles {
//     let aliases = fetch_tile_aliases(elixir_aliases, &tile);
//     if aliases.is_empty() { elixir_joker_tiles.insert(tile.clone()); }
//     else { relevant_tiles.extend(aliases); }
//     relevant_tiles.push(tile);
//   }
//   relevant_tiles.sort();
//   relevant_tiles.dedup();

//   // convert each hand into a TileSet (now that we have joker identities)
//   let joker_tiles: HashSet<Tile> = elixir_joker_tiles
//     .iter()
//     .flat_map(|t| encode_tile(t, all_attrs))
//     .collect();
//   let mut initial_hands = vec!();
//   for (hand, name) in &orig_hands {
//     let mut ret = encode(hand, &all_attrs, &joker_tiles);
//     if name != "" { ret.name = Some(name.to_owned()); }
//     initial_hands.push(ret);
//   }

//   let aliases = encode_aliases(&elixir_aliases, &all_attrs, &joker_tiles, None);

//   MatchInfo{
//     initial_hands,
//     num_tiles_in_hand,
//     relevant_tiles,
//     aliases,
//     elixir_joker_tiles,
//     joker_tiles,
//     all_attrs,
//     ordering,
//     ordering_r,
//   }
// }