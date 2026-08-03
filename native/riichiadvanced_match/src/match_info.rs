use smallvec::smallvec;
use std::collections::HashSet;

use crate::encode::{convert_to_mapping, encode, encode_aliases, encode_tiles};
use crate::primes::to_prime;
use crate::tileset::_check_equivalence;
use crate::types::{ElixirAliases, ElixirHand, ElixirHandCalls, ElixirTile, ElixirTileOrdering, MatchInfo, Tile, TileOrdering};

// move all tiles from (hand, calls) into two structures:
// - orig_hands, basically a copy of what was passed in minus call names
// - tiles_in_hand, references to all tiles in orig_hands
fn prepare_hand_calls((hand, calls): &ElixirHandCalls) -> Vec<(&ElixirHand, String)> {
  vec!((hand, "".to_owned())).into_iter().chain(
    calls.iter().map(|(name, call)| (call, name.to_owned()))
  ).collect::<Vec<_>>()
}

pub fn prepare_tiles<'a>(
  hand_calls: &'a ElixirHandCalls,
  mut all_attrs: Vec<String>,
  elixir_aliases: &'a ElixirAliases,
  ordering: &'a ElixirTileOrdering,
) -> MatchInfo {
  let orig_hands = prepare_hand_calls(hand_calls);
  let mut num_tiles_in_hand = 0;
  let hand_tiles: HashSet<&ElixirTile> = orig_hands.iter().flat_map(|(tiles, _)| {
    num_tiles_in_hand += tiles.len();
    tiles.iter()
  }).collect();

  for attr in all_attrs.iter_mut() { *attr = attr.trim_start_matches('_').to_owned(); }
  all_attrs.sort_unstable();
  all_attrs.dedup();

  let aliases = encode_aliases(elixir_aliases, &all_attrs);
  let mapping = convert_to_mapping(&aliases);

  // relevant_tiles = nonjoker tiles in hand + tiles mapped to by jokers in hand
  // elixir_joker_tiles = joker tiles in hand
  // (we use relevant_tiles to calculate base tiles)
  let mut relevant_tiles: Vec<Tile> = Vec::with_capacity(num_tiles_in_hand);
  let mut joker_tiles: HashSet<Tile> = HashSet::new();
  for tile in encode_tiles(hand_tiles, &all_attrs) {
    relevant_tiles.push(tile);
    for (tile2, tile2_aliases) in mapping.iter() {
      if _check_equivalence(&tile, tile2, &aliases) {
        joker_tiles.insert(tile);
        relevant_tiles.extend(tile2_aliases.clone());
      }
    }
  }
  relevant_tiles.sort_unstable();
  relevant_tiles.dedup();
  let mut initial_hands = smallvec!();
  for (hand, name) in &orig_hands {
    let mut ret = encode(hand, &all_attrs, &joker_tiles);
    if !name.is_empty() { ret.name = Some(name.to_owned()); }
    initial_hands.push(ret);
  }

  // map ordering and ordering_r to primes
  let map_to_prime = |(k, v)| {
    let k = to_prime(k)?;
    let v = to_prime(v)?;
    Some((k, v))
  };
  let ordering = TileOrdering{
    ordering: ordering.ordering.iter().filter_map(map_to_prime).collect(),
    ordering_r: ordering.ordering_r.iter().filter_map(map_to_prime).collect(),
    suit_ordering: ordering.suit_ordering.iter().filter_map(map_to_prime).collect(),
    suit_ordering_r: ordering.suit_ordering_r.iter().filter_map(map_to_prime).collect(),
  };

  MatchInfo{
    initial_hands,
    num_tiles_in_hand,
    aliases,
    mapping,
    relevant_tiles,
    joker_tiles,
    all_attrs,
    ordering,
  }
}
