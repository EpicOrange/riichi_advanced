use std::collections::{HashMap, HashSet};
use std::sync::atomic::Ordering;
use std::time::Instant;
use rustler::Atom;

use crate::encode::{decode_tiles, encode_aliases, encode_tile};
use crate::r#match::remove_match_definition;
use crate::match_info::{prepare_tiles};
use crate::profile::{PROFILE_GET_WAITS, PROFILE_UNNEEDED_TILES, CALL_COUNT, MAX_NANOS, TOTAL_NANOS};
use crate::tile_table::tile1x;
use crate::types::{ElixirAliases, ElixirHandCalls, ElixirTile, MatchDefinitionElem, MatchDefinitions, MatchInfo, Tile};
use crate::utils::{add_joker_to_aliases, remove_joker_from_aliases};

#[rustler::nif(schedule = "DirtyCpu")]
fn _get_waits_v3(
    hand_calls: ElixirHandCalls,
    match_definitions: MatchDefinitions,
    all_attrs: Vec<String>,
    elixir_aliases: ElixirAliases,
    ordering: HashMap<Atom, Atom>, ordering_r: HashMap<Atom, Atom>,
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
    &all_attrs,
    &mut elixir_aliases.clone(),
    &ordering,
    &ordering_r,
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
    all_attrs: &Vec<String>,
    mut elixir_aliases: &mut ElixirAliases,
    ordering: &HashMap<Atom, Atom>, ordering_r: &HashMap<Atom, Atom>,
    game_tiles: Vec<ElixirTile>,
) -> Vec<ElixirTile> {
  // basic strategy is to add a custom joker 1x that starts of being "all tiles"
  // we can test a set of tiles at a time by setting the joker to that set
  //   and then calling match to see if it matches the match_definitions
  // if the match succeeds, that tells us nothing
  // if the match fails, that proves the set of tiles tested are nonwaits
  // we want to take the transitive closure of all nonwaits, then take complement

  // first let's make that joker
  let joker = ElixirTile::AtomTile(tile1x());
  hand_calls.0.push(joker.clone());
  add_joker_to_aliases(&mut elixir_aliases, &joker, game_tiles.iter());
  let all_joker_tiles: HashSet<&ElixirTile> = elixir_aliases
    .values()
    .flat_map(|attrs_aliases| attrs_aliases.values().flatten())
    .collect();

  // then let's make match_info based on that joker
  let mut match_info = prepare_tiles(
    &hand_calls,
    all_attrs,
    &elixir_aliases,
    ordering,
    ordering_r,
  );

  let mut not_waits: HashSet<&ElixirTile> = HashSet::new();
  not_waits.insert(&joker);
  // this differs from match_info.joker_tiles since that only contains jokers in hand
  // whereas this one contains all jokers in alias table

  // let (joker_game_tiles, nonjoker_game_tiles): (Vec<ElixirTile>, Vec<ElixirTile>) = game_tiles
  //   .into_iter()
  //   .partition(|tile| match_info.elixir_joker_tiles.contains(tile));
  //   // .collect::<Vec<&ElixirTile>>();

  // populate not_waits with the closure of non-wait tiles
  let mut aliases_copy = elixir_aliases.clone();
  ___get_waits_v3(&mut match_info, &match_definitions, &mut aliases_copy, &mut not_waits, &game_tiles.iter().collect::<Vec<_>>(), &joker);
  // take complement of not_waits and return
  let mut ret: Vec<ElixirTile> = game_tiles
      .iter()
      .filter(|t| !not_waits.contains(t))
      .cloned()
      .collect();

  // now deal with jokers,
  // replacing the final 1x in match_info.initial_hands by each in turn
  let not_waits2: Vec<&ElixirTile> = all_joker_tiles
    .iter()
    .filter(|joker| {
      // first do the replacement
      let hand = &mut match_info.initial_hands[0];
      if let Some(last_tile) = hand.attrs.last_mut() {
        if let Some(encoded_joker) = encode_tile(joker, &match_info.all_attrs) {
          *last_tile = encoded_joker;
          match_info.joker_tiles.insert(encoded_joker);
        } else { return false; } // impossible (encode_tile only fails on unknown tiles)
      } else { return false; } // impossible (we always insert 1x)
      // println!("hand: {:?}", decode(hand, &match_info.all_attrs));
      
      // then check against match definitions
      match_definitions.iter().all(|match_definition| {
        remove_match_definition(&match_info, match_definition).next().is_none()
      })
    })
    .cloned()
    .collect();

  let mut ret2: Vec<ElixirTile> = all_joker_tiles
      .iter()
      .copied()
      .filter(|t| !not_waits2.contains(t))
      .cloned()
      .collect();

  ret.append(&mut ret2);
  ret
}
pub fn ___get_waits_v3<'a>(
    mut match_info: &mut MatchInfo,
    match_definitions: &MatchDefinitions,
    mut aliases: &mut ElixirAliases,
    mut not_waits: &mut HashSet<&'a ElixirTile>,
    current_tiles: &[&'a ElixirTile],
    joker: &ElixirTile,
) -> () {
  if current_tiles.is_empty() {
    // println!("Empty, so we're done");
    return;
  }
  // println!("tiles: {:?}", current_tiles);

  // test with current aliases (only need to match 1 to succeed)
  match_info.aliases = encode_aliases(aliases, &match_info.all_attrs);
  let all_nonwaits = match_definitions.iter().all(|match_definition| {
    remove_match_definition(&match_info, match_definition).next().is_none()
  });

  // if all nonwaits, mark current_tiles and return, as we're done
  // (no need to remove any aliases)
  if all_nonwaits {
    for &tile in current_tiles {
      not_waits.insert(tile);
    }
    return;
  }

  // if that was one tile, no more recursing
  if current_tiles.len() == 1 {
    remove_joker_from_aliases(&mut aliases, joker, current_tiles.iter().copied());
    return;
  }

  // otherwise, split current_tiles in half
  let m = current_tiles.len() / 2;
  let left = &current_tiles[..m];
  let right = &current_tiles[m..];
  // remove the right half aliases
  remove_joker_from_aliases(&mut aliases, joker, right.iter().copied());
  // recurse with left half
  ___get_waits_v3(&mut match_info, &match_definitions, &mut aliases, &mut not_waits, &left, &joker);
  // remove the left half aliases
  // (not strictly needed for correctness, but less powerful jokers are faster to solve for)
  remove_joker_from_aliases(&mut aliases, joker, left.iter().copied());
  // re-add the right half aliases
  add_joker_to_aliases(&mut aliases, joker, right.iter().copied());
  // recurse with right half
  ___get_waits_v3(&mut match_info, &match_definitions, &mut aliases, &mut not_waits, &right, &joker);
}

#[rustler::nif(schedule = "DirtyCpu")]
fn _get_unneeded_tiles_v2(
    hand_calls: ElixirHandCalls,
    match_definitions: MatchDefinitions,
    all_attrs: Vec<String>,
    elixir_aliases: ElixirAliases,
    ordering: HashMap<Atom, Atom>, ordering_r: HashMap<Atom, Atom>,
) -> Vec<ElixirTile> {
  let start = Instant::now();
  let ret = __get_unneeded_tiles_v2(
    hand_calls,
    &mut match_definitions.clone(),
    &all_attrs,
    &elixir_aliases,
    &ordering,
    &ordering_r,
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
pub fn __get_unneeded_tiles_v2(
    hand_calls: ElixirHandCalls,
    mut match_definitions: &mut MatchDefinitions,
    all_attrs: &Vec<String>,
    elixir_aliases: &ElixirAliases,
    ordering: &HashMap<Atom, Atom>, ordering_r: &HashMap<Atom, Atom>,
) -> Vec<ElixirTile> {
  // just try removing each tile in turn and seeing the resulting match fails

  let mut match_info = prepare_tiles(
    &hand_calls,
    all_attrs,
    &elixir_aliases,
    ordering,
    ordering_r,
  );

  // first use a non-exhaustive version of match_definitions
  // if it still matches after removing a tile, then that tile is definitely not needed
  let mut all_defns = vec!();
  for match_definition in match_definitions.iter() {
    for match_elem in match_definition {
      match match_elem {
        MatchDefinitionElem::Keyword(s) => {
          if s == "exhaustive" { 
            all_defns.push(match_definition.clone());
            all_defns.last_mut().map(|defn| defn.retain(|elem| {
              *elem != MatchDefinitionElem::Keyword("exhaustive".to_owned())
            }));
            break;
          }
        }
        _ => ()
      }
    }
  }
  all_defns.append(&mut match_definitions);

  // remove each tile in turn
  let mut ret: HashSet<Tile> = HashSet::new();
  for _ in 0..match_info.initial_hands[0].attrs.len() {
    if ret.contains(match_info.initial_hands[0].attrs.first().unwrap()) { continue; }

    // remove the first element
    // (can't use swap-remove since this is basically a queue)
    let tile = match_info.initial_hands[0].attrs.remove(0);

    // check against defns
    if all_defns.iter().any(|match_definition| {
        remove_match_definition(&match_info, match_definition).next().is_none()
      }) {
      // add tile to solution set, since hand still matches without tile
      ret.insert(tile);
    }

    // push the first element back in
    match_info.initial_hands[0].attrs.push(tile);
  }
  // need to convert to vector to pass NIF boundary
  // also need to convert from encoded tile to elixir tile
  decode_tiles(ret.iter().collect::<Vec<_>>(), &match_info.all_attrs)
}