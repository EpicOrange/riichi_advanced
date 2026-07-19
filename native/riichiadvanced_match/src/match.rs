use std::collections::{HashMap, HashSet};
use std::iter::{empty, once};
use std::rc::Rc;
use std::sync::atomic::Ordering;
use std::time::Instant;
use rustler::Atom;

use crate::encode::{decode, encode, encode_aliases};
use crate::match_bipartite::perform_bipartite_match;
use crate::match_dfs::perform_dfs_match;
use crate::match_elim::_elim_group;
use crate::match_info::prepare_tiles;
use crate::offsets::{__generate_groups, get_base_tiles};
use crate::profile::{PROFILE_MATCH, CALL_COUNT, MAX_NANOS, TOTAL_NANOS};
use crate::tileset::_subtract_check_attrs_exhaustive;
use crate::types::{ANY_PRIME, ElixirAliases, ElixirHand, ElixirHandCalls, ElixirTile, Hands, HandsIterator, MatchDefinition, MatchDefinitionElem, MatchDefinitions, MatchGroup, MatchInfo, MatchOffset, RemovableGroup};
use crate::utils::remove_indices;

// this is used a lot, especially for determining and processing calls
// #[rustler::nif]
// fn try_remove_all_tiles(
//     hand: ElixirHand, tiles: ElixirHand,
//     elixir_aliases: ElixirAliases, all_attrs: Vec<String>
// ) -> Vec<ElixirHand> {
//   _try_remove_all_tiles(hand, tiles, &elixir_aliases, &all_attrs)
// }
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
    let aliases = encode_aliases(elixir_aliases, all_attrs);
    match _subtract_check_attrs_exhaustive(&hand_set.attrs, &tiles_set.attrs, &aliases) {
      Some(iss) => {
        let mut ret = vec!();
        for is in iss {
          let mut hand = hand.clone();
          remove_indices(&mut hand, is);
          ret.push(hand);
        }
        ret
      }
      None => vec!(),
    }
  }
}

pub fn remove_match_definition<'a>(
  match_info: &'a MatchInfo, match_definition: &'a MatchDefinition
) -> HandsIterator<'a> {
  // first walk the definition to check for keywords and sum of group counts
  let mut min_match_length = 0;
  let mut debug = false;
  let mut has_restart = false;
  let mut has_almost = false;
  for elem in match_definition {
    match elem {
      MatchDefinitionElem::Keyword(s) => {
        if s == "debug" {
          if !debug { println!("Debugging: {:?}", match_definition); }
          debug = true;
        }
        else if s == "restart" { has_restart = true; }
        else if s == "almost" { has_almost = true; }
      }
      MatchDefinitionElem::Group(_, n) => if *n > 0 { min_match_length += *n; },
    }
  }
  // early exit if we have more groups than tiles/calls!
  // this is mostly to prevent 14 tile hands, like kokushi, from matching when we have 13 tiles
  if min_match_length as usize > match_info.num_tiles_in_hand && !has_restart && !has_almost {
    if debug {
      println!("match_info.initial_hands: {0:?}", match_info.initial_hands);
      println!("match_definition: {match_definition:?}");
      println!("Since we only have {0} tiles, refusing to match length-{1} match {2:?}",
        match_info.num_tiles_in_hand,
        min_match_length,
        match_definition,
      );
    }
    return Box::new(empty());
  }

  let base_tiles = Rc::new(get_base_tiles(match_info, &match_definition).into_iter().collect::<Vec<_>>());
  let exhaustive = match_definition.contains(&MatchDefinitionElem::Keyword("exhaustive".to_string()));
  let mut unique = false;
  let mut nojoker = false;
  let starting_acc = match_info.initial_hands.clone();
  match_definition.iter().fold(Box::new(once(starting_acc)), move |mut acc, match_elem| {
    match match_elem {
      MatchDefinitionElem::Keyword(s) => {
        if s == "exhaustive" { acc } // already handled above
        else if s == "unique" { unique = true; acc }
        else if s == "nojoker" { nojoker = true; acc }
        else if s == "almost" {
          // simply add an any-joker to hand
          Box::new(acc.map(|mut hands| {
            hands[0].hash *= ANY_PRIME;
            hands[0].attrs.push((ANY_PRIME, 0));
            hands
          }))
        }
        else if s == "debug" { acc } // handled by caller (__match_hand_v3)
        else if s == "restart" {
          if !acc.next().is_none() {
            Box::new(once(match_info.initial_hands.clone()))
          } else { Box::new(empty()) }
        }
        else if s == "dismantle_calls" {
          Box::new(acc.map(|mut hands| {
            let mut hand = hands.remove(0);
            for call in hands.iter_mut() {
              hand.hash *= call.hash;
              hand.attrs.append(&mut call.attrs);
            }
            hands.clear();
            hands.push(hand);
            hands
          }))
        }
        else {
          println!("Unknown match keyword \"{s}\"");
          acc
        }
      }
      MatchDefinitionElem::Group(groups, num) => {
        let groups = Rc::new(groups.clone());
        let base_tiles = base_tiles.clone();
        Box::new(acc.flat_map(move |hands| -> HandsIterator<'a> {
          remove_match_group(hands, groups.clone(), *num, base_tiles.clone(), match_info, debug, exhaustive, unique, nojoker)
        }))
      }
    }
  })
}

fn remove_match_group<'a>(
  hands: Hands,
  groups: Rc<Vec<MatchGroup>>, num: i8,
  base_tiles: Rc<Vec<ElixirTile>>,
  match_info: &'a MatchInfo,
  debug: bool, exhaustive: bool, unique: bool, nojoker: bool,
) -> HandsIterator<'a> {
  let prev_hands = hands.clone(); // for lookaheads

  // decide on which algorithm to use
  // bipartite requires:
  // - unique
  // - single-tile groups only
  // - no calls (not supported yet)
  // anything else is dfs
  let mut unique = unique;
  let mut bipartite = true;
  for elem in groups.iter() {
    match elem {
      MatchGroup::Offset(o) => {
        if let MatchOffset::TileOrKeyword(s) = o {
          if *s == "unique" { unique = true; }
          else if *s == "nojoker" {} // no-op
          else { bipartite = false; } // call name
        }
      }
      _ => { bipartite = false; },
    }
  }
  if !unique || hands.len() > 1 { bipartite = false; }

  // transform acc
  let base_tiles = base_tiles.clone();
  let mut acc = if bipartite {
    let offsets = Rc::new(groups.iter().flat_map(|g| g.flatten()).collect());
    if debug { println!("Starting bipartite match for {num} offsets from {:?}", offsets); }
    perform_bipartite_match(offsets, num, Box::new(once(hands)), base_tiles, match_info, debug, exhaustive, unique, nojoker)
  } else {
    if debug { println!("Starting dfs match for {num} groups from {:?}", groups); }
    perform_dfs_match(&groups, num, Box::new(once(hands)), base_tiles, match_info, debug, exhaustive, unique, nojoker)
  };

  // process lookaheads
  if num == 0 { // forward lookahead
    match acc.next() {
      Some(_) => {
        if debug { println!("Reverting due to last group being a successful forward lookahead (num=0)"); }
        Box::new(once(prev_hands))
      }
      None => Box::new(empty())
    }
  } else if num < 0 { // negative lookahead
    match acc.next() {
      Some(_) => {
        if debug { println!("Reverting due to last group being a successful negative lookahead (num={num})"); }
        Box::new(empty())
      }
      None => Box::new(once(prev_hands))
    }
  } else { // it was a normal match
    match acc.next() {
      Some(hands) => {
        if debug {
          println!("Result after [{0:?}, {1}]: ({2:?}) {3:?} / {4:?}",
            groups, num,
            hands[0].attrs.len(),
            decode(&hands[0], match_info.all_attrs),
            hands[1..].iter().map(|call| decode(&call, match_info.all_attrs)).collect::<Vec<_>>(),
          );
          println!("");
        }
        Box::new(once(hands).chain(acc))
      }
      None => {
        if debug {
          println!("Result after [{0:?}, {1}]: (empty)", groups, num);
        }
        Box::new(empty())
      }
    }
  }
}


#[rustler::nif(schedule = "DirtyCpu")]
pub fn _match_hand_v3(
  hand_calls: ElixirHandCalls,
  match_definitions: MatchDefinitions,
  all_attrs: Vec<String>,
  elixir_aliases: ElixirAliases,
  ordering: HashMap<Atom, Atom>, ordering_r: HashMap<Atom, Atom>,
) -> bool {
  let start = Instant::now();
  let ret = __match_hand_v3(
    &hand_calls,
    match_definitions,
    &all_attrs,
    &elixir_aliases,
    &ordering,
    &ordering_r,
  );
  if PROFILE_MATCH {
    let elapsed = start.elapsed();
    TOTAL_NANOS.fetch_add(elapsed.as_nanos() as u64, Ordering::Relaxed);
    MAX_NANOS.fetch_max(elapsed.as_nanos() as u64, Ordering::Relaxed);
    CALL_COUNT.fetch_add(1, Ordering::Relaxed); 
  }
  ret
}
pub fn __match_hand_v3<'a>(
  hand_calls: &'a ElixirHandCalls,
  match_definitions: MatchDefinitions,
  all_attrs: &'a Vec<String>,
  elixir_aliases: &'a ElixirAliases,
  ordering: &'a HashMap<Atom, Atom>, ordering_r: &'a HashMap<Atom, Atom>,
) -> bool {
  let match_info = prepare_tiles(
    hand_calls,
    all_attrs,
    elixir_aliases,
    ordering,
    ordering_r,
  );
  for match_definition in match_definitions {
    let mut debug = false;
    for elem in match_definition.iter() {
      if let MatchDefinitionElem::Keyword(s) = elem {
        if s == "debug" { debug = true; break; }
      }
    }
    let mut result = remove_match_definition(&match_info, &match_definition);
    let next = result.next();
    if next.is_some() {
      if debug { println!("Final result for match definition {:?}: {:?}", match_definition, next); }
      return true;
    } else {
      if debug { println!("Final result for match definition {:?}: (none)", match_definition); }
    }
  }
  false
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn _remove_group(
  hand: ElixirHand, group: MatchGroup,
  all_attrs: Vec<String>,
  elixir_aliases: ElixirAliases,
  ordering: HashMap<Atom, Atom>, ordering_r: HashMap<Atom, Atom>,
  exhaustive: bool, nojoker: bool,
  base_tiles: Option<Vec<ElixirTile>>,
) -> Vec<ElixirHand> {
  __remove_group(
    hand, group,
    &all_attrs,
    &elixir_aliases,
    &ordering,
    &ordering_r,
    exhaustive,
    nojoker,
    &base_tiles.map(|v| v.into_iter().collect()),
  )
} 

fn __remove_group<'a>(
  hand: ElixirHand, group: MatchGroup, 
  all_attrs: &'a Vec<String>,
  elixir_aliases: &'a ElixirAliases,
  ordering: &'a HashMap<Atom, Atom>, ordering_r: &'a HashMap<Atom, Atom>,
  exhaustive: bool, mut nojoker: bool,
  base_tiles: &'a Option<HashSet<ElixirTile>>,
) -> Vec<ElixirHand> {
  // special case: if we are trying to remove the empty group,
  // simply return hand in a singleton vec
  if let MatchGroup::Offsets(os) = &group {
    if os.is_empty() {
      return vec!(hand);
    }
  }
  // otherwise do all the prep work
  let hand_calls = (hand, vec!());
  let match_info = prepare_tiles(
    &hand_calls,
    all_attrs,
    elixir_aliases,
    ordering,
    ordering_r,
  );
  let base_tiles = if let Some(base_tiles) = base_tiles {
    base_tiles
  } else {
    let match_definition = vec!(MatchDefinitionElem::Group(vec!(group.clone()), 1));
    &get_base_tiles(&match_info, &match_definition)
  };

  // reify all groups into removable groups
  let reified_groups: Vec<RemovableGroup> = __generate_groups(
    &group,
    &mut base_tiles.iter(),
    &match_info.all_attrs,
    &match_info.joker_tiles,
    &match_info.ordering, &match_info.ordering_r,
    &mut nojoker,
  );

  // println!("Hand tiles: {0:?}", match_info.tiles_in_hand.iter().collect::<Vec<_>>());
  // println!("Base tiles: {0:?}", base_tiles.iter().collect::<Vec<_>>());
  // println!("Relevant tiles: {0:?}", match_info.relevant_tiles.iter().collect::<Vec<_>>());
  // for group in &reified_groups {
  //   println!("Reified group:");
  //   println!("  {0:?}", &group);
  //   println!("Into the groups:");
  //   match group {
  //     RemovableGroup::CallName(name) => println!("- \"{0:?}\"", name),
  //     RemovableGroup::Group(group) => println!("- {0:?}", decode(group, match_info.all_attrs)),
  //     RemovableGroup::GroupRef(group) => println!("- {0:?}", decode(group, match_info.all_attrs)),
  //     RemovableGroup::Multigroup(subgroups) => println!("- {0:?}", subgroups.iter().map(|subgroup| decode(subgroup, match_info.all_attrs)).collect::<Vec<_>>()),
  //   }
  // }
  let mut ret: Vec<ElixirHand> = vec!();
  for group in reified_groups {
    let result = _elim_group(&match_info.initial_hands, &group, &match_info.aliases, &match_info.joker_tiles, exhaustive);
    if !result.is_empty() {
      // println!("result, {:?}", result[0][0]);
      // println!("result, {:?}", decode(&result[0][0], &match_info.all_attrs));
      if exhaustive {
        ret.push(decode(&result[0][0], &match_info.all_attrs));
        return ret;
      } else {
        ret.append(&mut result.into_iter().map(|hands| decode(&hands[0], &match_info.all_attrs)).collect());
      }
    }
  }
  ret
}
