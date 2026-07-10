use std::collections::{HashMap, HashSet};
use rustler::Atom;

use crate::encode::{encode, encode_aliases, encode_tile};
use crate::tile_table::*;
use crate::tileset::check_tile_match;
use crate::types::{ElixirAliases, ElixirHand, ElixirHandCalls, ElixirTile, MatchInfo, Tile};
use crate::primes::is_any;
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
    all_tiles: &'a mut HashSet<ElixirTile>, all_attrs: &'a Vec<String>,
    elixir_aliases: &'a ElixirAliases,
    ordering: &'a HashMap<Atom, Atom>, ordering_r: &'a HashMap<Atom, Atom>,
) -> MatchInfo<'a> {
  // println!("  hand_calls: {0:?}", hand_calls);
  let orig_hands = prepare_hand_calls(hand_calls);
  // println!("  orig_hands: {0:?}", orig_hands);
  let mut tiles_in_hand: Vec<&ElixirTile> = vec!();
  for (hand, _) in &orig_hands { tiles_in_hand.append(&mut hand.iter().collect()); }
  // println!("  tiles_in_hand: {0:?}", tiles_in_hand);
  let no_attrs = tiles_in_hand.iter().all(|tile| {
    match &tile {
      ElixirTile::AtomTile(_) => true,
      ElixirTile::AttrTile(_, _) => false,
    }
  });
  // println!("  no_attrs: {0:?}", no_attrs);

  // first make a mapping {encoding <=> tile in hand}
  let mut encoding: HashMap<&ElixirTile, Tile> = HashMap::new();
  for tile in tiles_in_hand.iter().copied() {
    if let Some(encoded) = encode_tile(tile, all_attrs) {
      encoding.insert(tile, encoded);
    }
  }
  // the jokers are the tiles in hand whose corresponding encoding is an alias for some tile
  // first, collect all such mapped-to tiles
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
  // then, populate joker tiles
  let mut elixir_joker_tiles: HashSet<ElixirTile> = HashSet::new();
  let mut joker_tiles: HashSet<Tile> = HashSet::new();
  let mut matchable_tiles: HashSet<ElixirTile> = HashSet::new();
  for (&orig_tile, encoded) in encoding.iter() {
    matchable_tiles.insert(orig_tile.clone());
    for encoded_alias in encoded_alias_tiles.iter() {
      if check_tile_match(&encoded, encoded_alias) {
        elixir_joker_tiles.insert(orig_tile.clone());
        joker_tiles.insert(encoded.clone());
        break;
      }
    }
  }
  // for every joker, add its mappings set to matchable tiles
  // so matchable tiles = tiles in hand + tiles mapped to by jokers in hand
  // (we use this to calculate base tiles)
  for tile in elixir_joker_tiles.iter() {
    for alias in fetch_tile_aliases(elixir_aliases, tile) {
      matchable_tiles.insert(alias.clone());
    }
  }

  // generate new TileSets from the above
  let mut initial_hands = vec!();
  for (hand, name) in &orig_hands {
    let mut ret = encode(hand, &all_attrs, &joker_tiles);
    if name != "" { ret.name = Some(name.to_owned()); }
    initial_hands.push(ret);
  }
  let aliases = encode_aliases(&elixir_aliases, &all_attrs, &joker_tiles, Some(&encoding));

  // get all hand tiles + aliasable tiles
  for tile in tiles_in_hand.iter().copied().chain(elixir_aliases.keys()).filter(|t| !is_any(t)) {
    all_tiles.insert(tile.clone());
  }
  all_tiles.remove(&ElixirTile::AtomTile(tileany()));

  MatchInfo{
    // orig_hands,
    tiles_in_hand,
    initial_hands,
    all_tiles,
    all_attrs,
    aliases,
    elixir_joker_tiles,
    matchable_tiles,
    joker_tiles,
    // encoding,
    ordering,
    ordering_r,
    no_attrs,
  }
}
