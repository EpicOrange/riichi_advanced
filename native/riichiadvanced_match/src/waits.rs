use std::collections::{HashMap, HashSet};
use std::sync::atomic::Ordering;
use std::time::Instant;
use rustler::Atom;

use crate::r#match::remove_match_definition;
use crate::match_info::{prepare_tiles};
use crate::profile::{CALL_COUNT, TOTAL_NANOS};
use crate::tile_table::tile1x;
use crate::types::{ElixirAliases, ElixirHandCalls, ElixirTile, MatchDefinitions, MatchInfo, PROFILE_GET_WAITS};
use crate::utils::{add_joker_to_aliases, remove_joker_from_aliases};

#[rustler::nif]
fn _get_waits_v3(
    hand_calls: ElixirHandCalls,
    match_definitions: MatchDefinitions,
    all_tiles: Vec<ElixirTile>, all_attrs: Vec<String>,
    elixir_aliases: ElixirAliases,
    ordering: HashMap<Atom, Atom>, ordering_r: HashMap<Atom, Atom>,
) -> Vec<ElixirTile> {
  let start = Instant::now();
  let ret = __get_waits_v3(
    &hand_calls,
    &match_definitions,
    &mut all_tiles.into_iter().collect(),
    &all_attrs,
    &mut elixir_aliases.clone(),
    &ordering,
    &ordering_r,
  );
  if PROFILE_GET_WAITS {
    let elapsed = start.elapsed();
    TOTAL_NANOS.fetch_add(elapsed.as_nanos() as u64, Ordering::Relaxed);
    CALL_COUNT.fetch_add(1, Ordering::Relaxed);
  }
  ret
}

pub fn __get_waits_v3(
    hand_calls: &ElixirHandCalls,
    match_definitions: &MatchDefinitions,
    all_tiles: &mut HashSet<ElixirTile>, all_attrs: &Vec<String>,
    mut elixir_aliases: &mut ElixirAliases,
    ordering: &HashMap<Atom, Atom>, ordering_r: &HashMap<Atom, Atom>,
) -> Vec<ElixirTile> {
  // basic strategy is to add a custom joker 1x that starts of being "all tiles"
  // we can test a set of tiles at a time by setting the joker to that set
  //   and then calling match to see if it matches the match_definitions
  // if the match succeeds, that tells us nothing
  // if the match fails, that proves the set of tiles tested are nonwaits
  // we want to take the transitive closure of all nonwaits, then take complement

  // first let's make that joker
  let joker = ElixirTile::AtomTile(tile1x());
  add_joker_to_aliases(&mut elixir_aliases, &joker, all_tiles.iter());

  // then let's make match_info based on that joker
  let mut all_tiles_copy = all_tiles.clone();
  let aliases_copy = elixir_aliases.clone();
  let mut match_info = prepare_tiles(
    hand_calls,
    &mut all_tiles_copy,
    all_attrs,
    &aliases_copy,
    ordering,
    ordering_r,
  );

  let mut not_waits: HashSet<&ElixirTile> = HashSet::new();
  let all_tiles_refs: Vec<&ElixirTile> = all_tiles.iter().collect::<Vec<&ElixirTile>>();
  // run recursive closure that will populate not_waits
  ___get_waits_v3(&mut match_info, &match_definitions, &mut elixir_aliases, &mut not_waits, &all_tiles_refs, &joker);
  // take complement of not_waits and return
  all_tiles
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
    all_tiles: &[&'a ElixirTile],
    joker: &ElixirTile,
) -> () {
  // test with current aliases
  let mut all_nonwaits = true;
  for match_definition in match_definitions {
    let result = remove_match_definition(&match_info, match_definition);
    if !result.is_empty() {
      all_nonwaits = false;
      break;
    }
  }

  // if all nonwaits, mark all_tiles and return, as we're done
  // (no need to remove any aliases)
  if all_nonwaits {
    for &tile in all_tiles {
      not_waits.insert(tile);
    }
    return;
  }
  // otherwise, split all_tiles in half
  let m = all_tiles.len() / 2;
  let left = &all_tiles[..m];
  let right = &all_tiles[m..];
  // remove the right half aliases
  remove_joker_from_aliases(&mut aliases, joker, right.iter().copied());
  // recurse with left half
  ___get_waits_v3(&mut match_info, &match_definitions, &mut aliases, &mut not_waits, &left, &joker);
  // then re-add the right half into aliases
  add_joker_to_aliases(&mut aliases, joker, right.iter().copied());
  // recurse with right half
  ___get_waits_v3(&mut match_info, &match_definitions, &mut aliases, &mut not_waits, &right, &joker);
}



