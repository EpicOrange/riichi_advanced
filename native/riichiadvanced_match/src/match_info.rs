use smallvec::smallvec;
use std::collections::{HashMap, HashSet};
use rustler::Atom;

use crate::encode::{encode, encode_aliases, encode_tiles};
use crate::primes::to_prime;
use crate::types::{ElixirAliases, ElixirHand, ElixirHandCalls, ElixirTile, MatchInfo, Tile};

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
  let mut num_tiles_in_hand = 0;
  let hand_tiles: HashSet<&ElixirTile> = orig_hands.iter().flat_map(|(&ref tiles, _)| {
    num_tiles_in_hand += tiles.len();
    tiles
  }).collect();

  let (aliases, mapping) = encode_aliases(&elixir_aliases, &all_attrs);

  // relevant_tiles = nonjoker tiles in hand + tiles mapped to by jokers in hand
  // elixir_joker_tiles = joker tiles in hand
  // (we use relevant_tiles to calculate base tiles)
  let mut relevant_tiles: Vec<Tile> = Vec::with_capacity(num_tiles_in_hand);
  let mut joker_tiles: HashSet<Tile> = HashSet::new();
  for tile in encode_tiles(hand_tiles, &all_attrs) {
    if let Some(aliases) = mapping.get(&tile) {
      joker_tiles.insert(tile);
      relevant_tiles.extend(aliases);
    }
    relevant_tiles.push(tile);
  }
  relevant_tiles.sort_unstable();
  relevant_tiles.dedup();

  let mut initial_hands = smallvec!();
  for (hand, name) in &orig_hands {
    let mut ret = encode(hand, &all_attrs, &joker_tiles);
    if name != "" { ret.name = Some(name.to_owned()); }
    initial_hands.push(ret);
  }

  // map ordering and ordering_r to primes
  let map_to_prime = |(k, v)| {
    let k = to_prime(k)?;
    let v = to_prime(v)?;
    Some((k, v))
  };
  let ordering = ordering.into_iter().filter_map(map_to_prime).collect();
  let ordering_r = ordering_r.into_iter().filter_map(map_to_prime).collect();

  MatchInfo{
    initial_hands,
    num_tiles_in_hand,
    aliases,
    mapping,
    relevant_tiles,
    joker_tiles,
    all_attrs,
    ordering,
    ordering_r,
  }
}
