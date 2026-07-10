use std::collections::{HashMap, HashSet};
use std::sync::atomic::Ordering;
use std::time::Instant;
use rustler::Atom;

use crate::encode::encode_aliases;
use crate::r#match::remove_match_definition;
use crate::match_info::{prepare_tiles};
use crate::profile::{CALL_COUNT, MAX_NANOS, TOTAL_NANOS};
use crate::tile_table::tile1x;
use crate::types::{ElixirAliases, ElixirHandCalls, ElixirTile, MatchDefinitions, MatchInfo, PROFILE_GET_WAITS};
use crate::utils::{add_joker_to_aliases, get_tile_atom_attrs, get_tile_atom_attrs_mut, print_tile_aliases, remove_joker_from_aliases};

#[rustler::nif]
fn _get_waits_v3(
    hand_calls: ElixirHandCalls,
    match_definitions: MatchDefinitions,
    all_tiles: Vec<ElixirTile>, all_attrs: Vec<String>,
    elixir_aliases: ElixirAliases,
    ordering: HashMap<Atom, Atom>, ordering_r: HashMap<Atom, Atom>,
    game_tiles: Vec<ElixirTile>,
) -> Vec<ElixirTile> {
  let start = Instant::now();
  let ret = __get_waits_v3(
    hand_calls,
    &match_definitions,
    &mut all_tiles.into_iter().collect(),
    &all_attrs,
    &mut elixir_aliases.clone(),
    &ordering,
    &ordering_r,
    &game_tiles,
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
    match_definitions: &MatchDefinitions,
    mut all_tiles: &mut HashSet<ElixirTile>, all_attrs: &Vec<String>,
    mut elixir_aliases: &mut ElixirAliases,
    ordering: &HashMap<Atom, Atom>, ordering_r: &HashMap<Atom, Atom>,
    game_tiles: &Vec<ElixirTile>,
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
  all_tiles.insert(joker.clone());
  add_joker_to_aliases(&mut elixir_aliases, &joker, game_tiles.iter());

  // then let's make match_info based on that joker
  let aliases_copy = elixir_aliases.clone();
  let mut match_info = prepare_tiles(
    &hand_calls,
    &mut all_tiles,
    all_attrs,
    &aliases_copy,
    ordering,
    ordering_r,
  );

  let mut not_waits: HashSet<&ElixirTile> = HashSet::new();
  let game_tiles_refs: Vec<&ElixirTile> = game_tiles.iter().collect::<Vec<&ElixirTile>>();
  // run recursive closure that will populate not_waits
  ___get_waits_v3(&mut match_info, &match_definitions, &mut elixir_aliases, &mut not_waits, &game_tiles_refs, &joker);
  // take complement of not_waits and return
  game_tiles
      .iter()
      .filter(|t| !not_waits.contains(t))
      .cloned()
      .collect()
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

  // test with current aliases (only need to match 1 to succeed)
  print_tile_aliases(aliases, joker);
  match_info.aliases = encode_aliases(aliases, &match_info.all_attrs, &match_info.joker_tiles);
  let all_nonwaits = !match_definitions.iter().any(|match_definition| {
    !remove_match_definition(&match_info, match_definition).is_empty()
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



