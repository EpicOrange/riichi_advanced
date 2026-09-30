use smallvec::smallvec;
use std::collections::{HashMap, HashSet};
use std::sync::atomic::Ordering;
use std::time::Instant;

use crate::encode::{decode_tiles, encode_tiles};
use crate::r#match::{__match_hand_v3, __remove_match_definition};
use crate::match_info::{prepare_tiles};
use crate::profile::{PROFILE_GET_WAITS, PROFILE_UNNEEDED_TILES, CALL_COUNT, MAX_NANOS, TOTAL_NANOS};
use crate::tile_table::{TILE_TABLE, tile1x};
use crate::tileset::remove_tileset_indices;
use crate::types::{ANY_PRIME, ElixirAliases, ElixirHandCalls, ElixirTile, ElixirTileOrdering, MatchDefinitionElem, MatchDefinitions, MatchInfo, Tile};
use crate::utils::{add_joker_to_aliases, remove_joker_from_aliases};

#[rustler::nif(schedule = "DirtyCpu")]
fn _get_waits_v3(
    hand_calls: ElixirHandCalls,
    match_definitions: MatchDefinitions,
    all_attrs: Vec<String>,
    elixir_aliases: ElixirAliases,
    ordering: ElixirTileOrdering,
    game_tiles: Vec<ElixirTile>,
) -> Vec<ElixirTile> {

  // // add debug
  // let mut match_definitions = match_definitions.clone();
  // for defn in match_definitions.iter_mut() {
  //   defn.push(MatchDefinitionElem::Keyword("debug".to_owned()));
  // }

  let start = Instant::now();
  let ret = __get_waits_v3(
    hand_calls,
    match_definitions,
    all_attrs,
    &mut elixir_aliases.clone(),
    &ordering,
    game_tiles,
  );
  if PROFILE_GET_WAITS {
    let elapsed = start.elapsed();
    TOTAL_NANOS.fetch_add(elapsed.as_nanos() as u64, Ordering::Relaxed);
    MAX_NANOS.fetch_max(elapsed.as_nanos() as u64, Ordering::Relaxed);
    CALL_COUNT.fetch_add(1, Ordering::Relaxed);
  }
  ret
}

pub fn __get_waits_v3(
    mut hand_calls: ElixirHandCalls,
    match_definitions: MatchDefinitions,
    all_attrs: Vec<String>,
    elixir_aliases: &mut ElixirAliases,
    ordering: &ElixirTileOrdering,
    elixir_game_tiles: Vec<ElixirTile>,
) -> Vec<ElixirTile> {
  // basic strategy is to add a custom joker 1x that starts off being "all tiles"
  // we can test a set of tiles at a time by setting the joker to that set
  //   and then calling match to see if it matches the match_definitions
  // if the match succeeds, that tells us nothing
  // if the match fails, that proves the set of tiles tested are nonwaits
  // we want to take the transitive closure of all nonwaits, then take complement

  // first let's make that joker
  let elixir_joker = ElixirTile::AtomTile(tile1x());
  hand_calls.0.push(elixir_joker);

  // then let's make match_info based on that joker
  let mut match_info = prepare_tiles(
    &hand_calls,
    all_attrs,
    elixir_aliases,
    ordering,
  );
  let joker = (*TILE_TABLE.get("1x").unwrap(), 0);
  let mut not_waits: HashSet<Tile> = HashSet::new();
  not_waits.insert(joker);
  match_info.joker_tiles.insert(joker);

  // println!("elixir_game_tiles={:?}", &elixir_game_tiles);
  // add all nonjoker tiles as possible waits (we will add in jokers at the end)
  let mut possible_waits: Vec<Tile> =
    encode_tiles(&elixir_game_tiles, &match_info.all_attrs)
    .filter(|tile| !match_info.joker_tiles.contains(tile))
    .collect();
  possible_waits.sort_unstable();
  possible_waits.dedup();

  // we also need to include nonjoker tiles that all existing jokers might map to, but aren't in the wall
  // call these hidden possible waits
  // e.g. if all four 5-pins are aka, leaving zero non-aka 5-pin, we want to show non-aka 5-pin as a possible wait
  let mut hidden_possible_waits: HashSet<Tile> = HashSet::new();
  for tile in match_info.aliases.iter().flat_map(|(k, vs)| vs.keys().map(|v| (*k, *v))) {
    // only add hidden waits
    if let Err(i) = possible_waits.binary_search(&tile) {
      possible_waits.insert(i, tile);
      hidden_possible_waits.insert(tile);
    } else { continue };
  }

  // save aliases first
  let aliases_backup = match_info.aliases.clone();

  // println!("possible_waits={:?}", decode_tiles(&possible_waits, &match_info.all_attrs));
  add_joker_to_aliases(&mut match_info.aliases, &mut match_info.mapping, joker, &possible_waits);
  // println!("starting aliases for 1x: {:?}", decode_tiles(match_info.mapping.get(&joker).unwrap(), &match_info.all_attrs));
  // println!("joker_tiles: {:?}", decode_tiles(&match_info.joker_tiles, &match_info.all_attrs));

  // populate not_waits with the closure of non-wait tiles
  ___get_waits_v3(&mut match_info, &match_definitions, &mut not_waits, &possible_waits, &joker);

  // take complement of not_waits
  possible_waits.retain(|tile| !not_waits.contains(tile));

  // add all joker tiles that map to something in possible_waits
  let ret_jokers: HashSet<Tile> = possible_waits
    .iter()
    .flat_map(|t| aliases_backup.get(&t.0)?.get(&t.1))
    .flatten()
    .copied()
    .collect();
  let mut any_jokers: Vec<Tile> = aliases_backup
    .get(&ANY_PRIME)
    .unwrap_or(&HashMap::new())
    .values()
    .flatten()
    .cloned()
    .collect();
  any_jokers.sort_unstable();
  any_jokers.dedup();
  // println!("possible_waits: {:?}", &possible_waits);
  // println!("elixir_aliases: {:?}", &elixir_aliases);
  // println!("aliases_backup: {:?}", &aliases_backup);
  // println!("ret_jokers: {:?}", &ret_jokers);

  possible_waits.extend(ret_jokers);
  possible_waits.extend(any_jokers);
  possible_waits.retain(|t| !hidden_possible_waits.contains(t));
  decode_tiles(&possible_waits, &match_info.all_attrs)
}
pub fn ___get_waits_v3(
  match_info: &mut MatchInfo,
  match_definitions: &MatchDefinitions,
  not_waits: &mut HashSet<Tile>,
  current_tiles: &[Tile],
  joker: &Tile,
) {
  if current_tiles.is_empty() {
    // println!("Empty, so we're done");
    return;
  }
  // println!("\ntiles: {:?}", decode_tiles(current_tiles, &match_info.all_attrs));
  // println!("current aliases for 1x: {:?}", decode_tiles(match_info.mapping.get(joker).unwrap(), &match_info.all_attrs));

  // test with current aliases (only need to match 1 to succeed)
  // println!("before removing: {:?}", match_info.initial_hands.iter().map(|t| decode(t, &match_info.all_attrs)).collect::<Vec<_>>());
  let all_nonwaits = match_definitions.iter().all(|match_definition| {
    // println!("after removing: {:?}", __remove_match_definition(match_info, match_definition).map(|ts| ts.iter().map(|t| decode(t, &match_info.all_attrs)).collect::<Vec<_>>()).collect::<Vec<_>>());
    __remove_match_definition(match_info, match_definition).next().is_none()
  });

  // if all nonwaits, mark current_tiles and return, as we're done
  // (no need to remove any aliases)
  if all_nonwaits {
    // println!("Not waits: {:?}", current_tiles);
    for &tile in current_tiles {
      not_waits.insert(tile);
    }
    return;
  }

  // if that was one tile, no more recursing
  if current_tiles.len() == 1 {
    remove_joker_from_aliases(&mut match_info.aliases, &mut match_info.mapping, *joker, current_tiles);
    return;
  }

  // otherwise, split current_tiles in half
  let m = current_tiles.len() / 2;
  let left = &current_tiles[..m].to_vec();
  let right = &current_tiles[m..].to_vec();
  // remove the right half aliases
  remove_joker_from_aliases(&mut match_info.aliases, &mut match_info.mapping, *joker, right);
  // println!("after removing {:?} from right: {:?}", decode_tiles(right, &match_info.all_attrs), decode_tiles(match_info.mapping.get(joker).unwrap(), &match_info.all_attrs));
  // recurse with left half
  ___get_waits_v3(match_info, match_definitions, not_waits, left, joker);
  // remove the left half aliases
  // (not strictly needed for correctness, but less powerful jokers are faster to solve for)
  remove_joker_from_aliases(&mut match_info.aliases, &mut match_info.mapping, *joker, left);
  // println!("after removing {:?} from left: {:?}", decode_tiles(left, &match_info.all_attrs), decode_tiles(match_info.mapping.get(joker).unwrap(), &match_info.all_attrs));
  // re-add the right half aliases
  add_joker_to_aliases(&mut match_info.aliases, &mut match_info.mapping, *joker, right);
  // println!("after restoring {:?} to right: {:?}", decode_tiles(right, &match_info.all_attrs), decode_tiles(match_info.mapping.get(joker).unwrap(), &match_info.all_attrs));
  // recurse with right half
  ___get_waits_v3(match_info, match_definitions, not_waits, right, joker);
  // remove the right half aliases (also an optimization)
  remove_joker_from_aliases(&mut match_info.aliases, &mut match_info.mapping, *joker, right);
  // println!("after removing {:?} from right again: {:?}", decode_tiles(right, &match_info.all_attrs), decode_tiles(match_info.mapping.get(joker).unwrap(), &match_info.all_attrs));
}

#[rustler::nif(schedule = "DirtyCpu")]
fn _get_unneeded_tiles_v2(
    hand_calls: ElixirHandCalls,
    match_definitions: MatchDefinitions,
    all_attrs: Vec<String>,
    elixir_aliases: ElixirAliases,
    ordering: ElixirTileOrdering,
) -> Vec<ElixirTile> {
  let start = Instant::now();
  let ret = __get_unneeded_tiles_v2(
    hand_calls,
    match_definitions,
    all_attrs,
    &elixir_aliases,
    &ordering,
  );
  if PROFILE_UNNEEDED_TILES {
    let elapsed = start.elapsed();
    TOTAL_NANOS.fetch_add(elapsed.as_nanos() as u64, Ordering::Relaxed);
    MAX_NANOS.fetch_max(elapsed.as_nanos() as u64, Ordering::Relaxed);
    CALL_COUNT.fetch_add(1, Ordering::Relaxed);
  }
  ret
}

// given a 14-tile hand, and match definitions for 13-tile hands,
// return all the (unique) tiles that are not needed to match the definitions
#[inline]
pub fn __get_unneeded_tiles_v2(
    hand_calls: ElixirHandCalls,
    match_definitions: MatchDefinitions,
    all_attrs: Vec<String>,
    elixir_aliases: &ElixirAliases,
    ordering: &ElixirTileOrdering,
) -> Vec<ElixirTile> {
  let mut match_info = prepare_tiles(
    &hand_calls,
    all_attrs,
    elixir_aliases,
    ordering,
  );
  let mut ret: HashSet<Tile> = HashSet::new();

  // first get leftover tiles from removing a non-exhaustive version of the match definitions
  for mut match_definition in match_definitions.clone() {
    match_definition.retain(|e| *e != MatchDefinitionElem::Keyword("exhaustive".to_owned()));
    for hands in __remove_match_definition(&match_info, &match_definition) {
      ret.extend(hands[0].attrs.iter());
    }
  }
  // println!("ret starts as {:?}", decode_tiles(&ret.iter().cloned().collect::<Vec<_>>(), &match_info.all_attrs));

  // then try removing each tile in turn and see if the match succeeds without that tile
  let prev_hash = match_info.initial_hands[0].hash;
  for _ in 0..match_info.initial_hands[0].attrs.len() {
    // println!("initial_hands is now {:?}", crate::encode::decode(&match_info.initial_hands[0], &match_info.all_attrs));
    // println!("ret is now {:?}", decode_tiles(&ret.iter().cloned().collect::<Vec<_>>(), &match_info.all_attrs));
    let tile = match_info.initial_hands[0].attrs.first().copied().unwrap();
    if ret.contains(&tile) {
      // println!("skipping tile {:?}", crate::encode::decode_tile(tile, &match_info.all_attrs));
      match_info.initial_hands[0].attrs.rotate_left(1);
      continue;
    }
    // remove first element, we'll push it later to the back
    // (can't use swap_remove since this is basically a queue)
    remove_tileset_indices(&mut match_info.initial_hands[0], smallvec!(0), &match_info.joker_tiles);

    // println!("trying tile {:?}", crate::encode::decode_tile(tile, &match_info.all_attrs));
    // println!("hand is now {:?}", crate::encode::decode(&match_info.initial_hands[0], &match_info.all_attrs));

    // check if it matches
    if __match_hand_v3(&match_info, &match_definitions) { ret.insert(tile); }
    // else { println!("failed to match any match definition"); }
    // push the first element back in, but at the back
    match_info.initial_hands[0].hash = prev_hash;
    match_info.initial_hands[0].attrs.push(tile);
  }

  // need to convert to vector to pass NIF boundary
  // also need to convert from encoded tile to elixir tile
  decode_tiles(ret.iter().collect::<Vec<_>>(), &match_info.all_attrs)
}

