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
  let orig_hands = prepare_hand_calls(hand_calls);
  let mut hand_tiles: Vec<ElixirTile> = vec!();
  for (&ref hand, _) in orig_hands.iter() { hand_tiles.append(&mut hand.clone().into_iter().collect()); }
  let num_tiles_in_hand = hand_tiles.len();
  hand_tiles.sort();
  hand_tiles.dedup();

  // relevant_tiles = nonjoker tiles in hand + tiles mapped to by jokers in hand
  // elixir_joker_tiles = joker tiles in hand
  // (we use relevant_tiles to calculate base tiles)
  let mut relevant_tiles: Vec<ElixirTile> = Vec::with_capacity(num_tiles_in_hand);
  let mut elixir_joker_tiles: HashSet<ElixirTile> = HashSet::new();
  for tile in hand_tiles {
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

  let mut initial_hands = vec!();
  for (hand, name) in &orig_hands {
    let mut ret = encode(hand, &all_attrs, &joker_tiles);
    if name != "" { ret.name = Some(name.to_owned()); }
    initial_hands.push(ret);
  }

  MatchInfo{
    initial_hands,
    num_tiles_in_hand,
    aliases: encode_aliases(&elixir_aliases, &all_attrs, &joker_tiles, None),
    elixir_joker_tiles,
    relevant_tiles,
    joker_tiles,
    all_attrs,
    ordering,
    ordering_r,
  }
}
