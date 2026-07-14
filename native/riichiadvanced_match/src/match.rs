use std::cell::RefCell;
use std::collections::{HashMap, BTreeMap, HashSet};
use std::iter::{empty, once};
use std::rc::Rc;
use std::sync::atomic::Ordering;
use std::time::Instant;
use num::abs;
use rustler::{Atom};

use crate::encode::{decode, decode_attrs, encode, encode_aliases, encode_tile, print_group};
use crate::match_info::{prepare_tiles};
use crate::offsets::{__generate_groups, apply_offsets_early_exit, get_base_tiles};
use crate::primes::{is_manzu, is_pinzu, is_souzu};
use crate::profile::{PROFILE_MATCH, CALL_COUNT, MAX_NANOS, TOTAL_NANOS};
use crate::tile_table::{tile1m, tile1p, tile1s, tile1x};
use crate::tileset::{__subtract, __subtract_exhaustive, _check_equivalence, _remove_indices, _subtract_check_attrs_exhaustive, move_jokers_to_end, remove_tileset_indices};
use crate::types::{ANY_PRIME, Aliases, ElixirAliases, ElixirHand, ElixirHandCalls, ElixirTile, FIXED_OFFSETS, Hands, Hash, MatchDefinition, MatchDefinitionElem, MatchDefinitions, MatchGroup, MatchInfo, MatchOffset, RemovableGroup, RowIndex, Tile, TileSet};

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
    let aliases = encode_aliases(elixir_aliases, all_attrs, &empty_hashset, None);
    match _subtract_check_attrs_exhaustive(&hand_set.attrs, &tiles_set.attrs, &aliases) {
      Some(iss) => {
        let mut ret = vec!();
        for is in iss {
          let mut hand = hand.clone();
          _remove_indices(&mut hand, &is);
          ret.push(hand);
        }
        ret
      }
      None => vec!(),
    }
  }
}

fn elim_call_name(hands: &Hands, name: &String, exhaustive: bool) -> Vec<Hands> {
  // group is a call name, remove every corresponding call with that name
  let mut ret = vec!();
  for i in 0..hands.len() {
    if let Some(call_name) = &hands[i].name {
      if call_name == name {
        let mut hands = hands.clone();
        hands.remove(i);
        ret.push(hands);
        if !exhaustive { break; }
      }
    }
  }
  ret
}
fn elim_tileset(
  hands: &Hands, tileset: &TileSet,
  aliases: &Aliases,
  joker_tiles: &HashSet<Tile>,
  exhaustive: bool,
) -> Vec<Hands> {
  let mut ret = vec!();
  // check calls first
  for i in 1..hands.len() {
    if let Some(_) = __subtract_exhaustive(&hands[i], tileset, aliases, joker_tiles) {
      let mut hands = hands.clone();
      hands.remove(i);
      ret.push(hands);
      if !exhaustive { break; }
    }
  }
  if exhaustive {
    // then check hand, for each one make copies of hands, placing results into each one
    if let Some(results) = __subtract_exhaustive(&hands[0], tileset, aliases, joker_tiles) {
      for result in results {
        let mut hands = hands.clone();
        hands[0] = result;
        ret.push(hands);
      }
    }
  } else if ret.is_empty() {
    // then check hand
    if let Some(result) = __subtract(&hands[0], tileset, aliases, joker_tiles) {
      let mut hands = hands.clone();
      hands[0] = result;
      ret.push(hands);
    }
  }
  ret
}

// #[rustler::nif]
// fn elim_group(
//     hands: Hands, group: RemovableGroup,
//     aliases: Aliases,
//     joker_tiles: Vec<Tile>,
//     exhaustive: bool,
// ) -> Vec<Hands> {
//   _elim_group(&hands, &group, &aliases, &joker_tiles.into_iter().collect(), exhaustive)
// }
fn _elim_group(
    hands: &Hands, group_arg: &RemovableGroup,
    aliases: &Aliases,
    joker_tiles: &HashSet<Tile>,
    exhaustive: bool,
) -> Vec<Hands> {
  match group_arg {
    RemovableGroup::CallName(name) => elim_call_name(hands, name, exhaustive),
    RemovableGroup::Group(group) => elim_tileset(hands, &group, aliases, joker_tiles, exhaustive),
    RemovableGroup::Multigroup(subgroups) => {
      // multigroup can only be removed from hand (= hands[0])
      let mut ret = vec!(hands.clone());
      for subgroup in subgroups {
        let results = ret.iter().flat_map(move |hands| {
          _elim_group(hands, &RemovableGroup::Group(subgroup.clone()), aliases, joker_tiles, exhaustive)
        });
        // only retain one result if not exhaustive
        if exhaustive { ret = results.collect(); }
        else { ret = results.take(1).collect(); }
      }
      ret
    }
  }
}

type HandsIterator<'a> = Box<dyn Iterator<Item = Hands> + 'a>;

fn elim_call_name_iter<'a>(
  hands: Hands,
  name: String,
) -> HandsIterator<'a> {
  // group is a call name, remove every corresponding call with that name
  let ret = hands.clone().into_iter().enumerate().flat_map(move |(i, call)| -> HandsIterator<'a> {
    if let Some(call_name) = &call.name {
      if *call_name == name {
        let mut hands = hands.clone();
        hands.remove(i);
        return Box::new(once(hands));
      }
    }
    Box::new(empty())
  });
  Box::new(ret)
}

fn elim_tileset_iter<'a>(
  hands: Hands,
  tileset: TileSet,
  aliases: &'a Aliases,
  joker_tiles: &'a HashSet<Tile>,
  exhaustive: bool,
) -> HandsIterator<'a> {
  // go backwards so we remove calls first
  let ret = hands.clone().into_iter().enumerate().rev().flat_map(move |(i, hand)| -> HandsIterator<'a> {
    let is_call = i > 0;
    if is_call {
      if let Some(_) = __subtract(&hand, &tileset, aliases, joker_tiles) {
        let mut hands = hands.clone();
        hands.remove(i);
        return Box::new(once(hands));
      }
    } else if exhaustive {
      if let Some(results) = __subtract_exhaustive(&hands[0], &tileset, aliases, joker_tiles) {
        let hands = hands.clone();
        return Box::new(results.into_iter().map(move |result| {
          let mut hands = hands.clone();
          hands[0] = result;
          hands
        }));
      }
    } else {
      if let Some(result) = __subtract(&hands[0], &tileset, aliases, joker_tiles) {
        let mut hands = hands.clone();
        hands[0] = result;
        return Box::new(once(hands));
      }
    }
    Box::new(empty())
  });
  Box::new(ret)
}

fn elim_group_iter<'a>(
    hands: Hands, group_arg: RemovableGroup,
    aliases: &'a Aliases,
    joker_tiles: &'a HashSet<Tile>,
    debug: bool, exhaustive: bool,
) -> HandsIterator<'a> {
  match group_arg {
    RemovableGroup::CallName(name) => elim_call_name_iter(hands, name.clone()),
    RemovableGroup::Group(group) => elim_tileset_iter(hands, group, aliases, joker_tiles, exhaustive),
    RemovableGroup::Multigroup(subgroups) => {
      if debug {
        println!("Subgroups in elim_group_iter: {:?}", subgroups);
      }
      // multigroup can only be removed from hand (= hands[0])
      subgroups.clone().into_iter().fold(Box::new(once(hands)) as HandsIterator, move |acc: HandsIterator, subgroup| -> HandsIterator {
        Box::new(acc.flat_map(move |hands| -> HandsIterator<'a> {
          elim_tileset_iter(hands, subgroup.clone(), aliases, joker_tiles, exhaustive)
        }))
      })
    }
  }
}

// (hands, ignore groups left of this index, path, )
type PathItem = RemovableGroup;
type AccItem = (Hands, usize, Vec<PathItem>);
type AccIterator<'a> = Box<dyn Iterator<Item = AccItem> + 'a>;
fn dfs_match<'a>(
  acc: AccItem,
  match_info: &'a MatchInfo,
  reified_groups_by_group: Rc<BTreeMap<usize, Rc<Vec<RemovableGroup>>>>,
  num: i8,
  debug: bool, exhaustive: bool, unique: bool, nojoker: bool,
) -> AccIterator<'a> {
  let actual_num = if num == 0 { 1 } else { abs(num) };
  let visited: Rc<RefCell<HashSet<Vec<PathItem>>>> = Rc::new(RefCell::new(HashSet::new()));
  (0..actual_num).fold(Box::new(once(acc)), move |mut acc, i| -> AccIterator<'a> {
    acc = if exhaustive { acc } else { Box::new(acc.take(1)) };
    let visited = visited.clone();
    let reified = reified_groups_by_group.clone();
    Box::new(acc.flat_map(move |hands| -> AccIterator<'a> {
      _dfs_match(
        hands,
        match_info,
        visited.clone(),
        reified.clone(),
        debug, exhaustive, unique, nojoker,
        i, num,
      )
    }))
  })
}
fn _dfs_match<'a>(
    (hands, ignore_ix, path): AccItem,
    match_info: &'a MatchInfo,
    visited: Rc<RefCell<HashSet<Vec<PathItem>>>>,
    reified: Rc<BTreeMap<usize, Rc<Vec<RemovableGroup>>>>,
    debug: bool, exhaustive: bool, unique: bool, nojoker: bool,
    i: i8, num: i8,
) -> AccIterator<'a> {
  let actual_num = if num == 0 { 1 } else { abs(num) };
  // gather all groups with keys not less than ignore_ix, into a single groups vec
  // if debug { println!("reified: {:?}", reified); }
  let groups: Vec<(usize, RemovableGroup)> = reified
    .iter()
    .filter(|(&j, _)| j >= ignore_ix)
    .flat_map(|(&j, v)| v.iter().cloned().map(|g| (j, g)).collect::<Vec<_>>())
    .collect::<Vec<_>>();
  if debug {
    println!("Removal {0}/{1}{2} from ({3:?}) {4:?} / {5:?} \\ {6:?}{7} {8}{9}{10}",
      i + 1,
      actual_num,
      if num <= 0 { " (lookahead)" } else { "" },
      hands[0].attrs.len(),
      decode(&hands[0], match_info.all_attrs),
      hands[1..].iter().map(|call| decode(&call, match_info.all_attrs)).collect::<Vec<_>>(),
      groups, num,
      if exhaustive { " exhaustive" } else { "" },
      if unique { " unique" } else { "" },
      if nojoker { " nojoker" } else { "" },
    );
    for (j, group) in groups.iter() {
      let mut alternatives: Vec<String> = vec!();
      alternatives.push(print_group(group, &match_info.all_attrs, nojoker));
      if !alternatives.is_empty() {
        println!("{0:4}. {1}{2}", j, alternatives.join(", "), if nojoker { " nojoker" } else { "" });
      }
    }
  }
  let visited = visited.clone();
  Box::new((0..groups.len()).flat_map(move |k| -> AccIterator<'a> {
    let visited = visited.clone();
    let (j, group) = groups[k].clone();
    let mut path = path.clone();
    if is_visited(&path, &group, visited.clone()) {
      if debug {
        let mut key = path.clone();
        key.sort_unstable();
        key.push(group.clone());
        // println!("Skipping path {} for hands {:?}",
        //   key.iter().map(|group| print_group(&group, &match_info.all_attrs, nojoker)).collect::<Vec<_>>().join(", "),
        //   decode(&hands[0], &match_info.all_attrs));
      }
      return Box::new(empty());
    }
    path.push(group.clone());
    let new_path = path.clone();
    let mut ret = Box::new(elim_group_iter(hands.clone(), group.clone(), &match_info.aliases, &match_info.joker_tiles, debug, exhaustive)
      .map(move |hands| (hands, if unique { j + 1 } else { j }, new_path.clone())));
    match ret.next() {
      Some(t) => {
        if debug { println!("Removal of group {0:?} was a success, first result is {1:?} / {2} call(s)", print_group(&group, match_info.all_attrs, false), decode(&t.0[0], match_info.all_attrs), t.0.len() - 1); }
        Box::new(once(t).chain(ret))
      }
      None    => {
        if path.len() <= 4 && i < actual_num - 1 { // no need to store paths for the last iteration
          let mut key = path.clone();
          key.sort_unstable();
          visited.borrow_mut().insert(key.clone());
          // if debug {
          //   println!("We'll skip paths containing {} from now on (visited size: {})", 
          //     key.iter().map(|group| print_group(&group, &match_info.all_attrs, nojoker)).collect::<Vec<_>>().join(", "),
          //     visited.borrow().len());
          // }
        }
        Box::new(empty())
      }
    }
  }))
}

// if len <= 4, tries to take the power set of path (containing item) and sees if any is in visited
fn is_visited(path: &Vec<PathItem>, last_item: &PathItem, visited: Rc<RefCell<HashSet<Vec<PathItem>>>>) -> bool {
  let len = path.len();
  if len >= 30 { return false; }
  else if len <= 4 {
    let vis = visited.borrow();
    for mask in 1..(1u32 << len) {
      let mut key: Vec<RemovableGroup> = (0..len)
        .filter(|&i| mask & (1 << i) != 0)
        .map(|i| path[i].clone())
        .collect();
      key.sort_unstable();
      key.push(last_item.clone());
      if vis.contains(&key) { return true; }
    }
    false
  } else {
    let mut key = path.clone();
    key.sort_unstable();
    key.push(last_item.clone());
    visited.borrow().contains(&key)
  }
}

fn reify_groups<'a>(
  groups: &[MatchGroup],
  base_tiles: Rc<Vec<ElixirTile>>,
  match_info: &'a MatchInfo,
  debug: bool, mut nojoker: bool,
  // base tile set => group index i => vec of groups
) -> HashMap<Rc<Vec<ElixirTile>>, Rc<BTreeMap<usize, Rc<Vec<RemovableGroup>>>>> {
  let mut reified_bank: Vec<RemovableGroup> = vec!();
  let mut reified_bank_r: HashMap<RemovableGroup, usize> = HashMap::new();
  let mut ret: HashMap<Rc<Vec<ElixirTile>>, Rc<BTreeMap<usize, Rc<Vec<RemovableGroup>>>>> = HashMap::new();
  if debug {
    // println!("\nHand tiles: {0:?}", match_info.tiles_in_hand.iter().collect::<Vec<_>>());
    // println!("Base tiles: {0:?}", base_tiles.iter().collect::<Vec<_>>());
    // println!("Relevant tiles: {0:?}", match_info.relevant_tiles.iter().collect::<Vec<_>>());
  }
  let mut separate_suits = false;
  for (_i, group) in groups.iter().enumerate() {
    for offset in group.flatten() {
      match offset {
        MatchOffset::Offset(o) => {
          if abs(o) >= 10 { separate_suits = true; break; }
        },
        MatchOffset::AttrsTile(_) => {}
        MatchOffset::AttrsOffset(map) => {
          if abs(map.offset) >= 10 { separate_suits = true; break; }
        },
        MatchOffset::TileOrKeyword(s) => {
          if FIXED_OFFSETS.get(&s).is_some() { separate_suits = true; break; }
        }
      }
    }
  }
  let man = ElixirTile::AtomTile(tile1m());
  let pin = ElixirTile::AtomTile(tile1p());
  let sou = ElixirTile::AtomTile(tile1s());
  let all = ElixirTile::AtomTile(tile1x());
  let keys = vec!(
    Rc::new(vec!(man.clone())),
    Rc::new(vec!(pin.clone())),
    Rc::new(vec!(sou.clone())),
    Rc::new(vec!(all.clone()))
  );

  for (i, group) in groups.iter().enumerate() {
    let mut have_fixed_offsets = false;
    let mut have_numeric_offsets = false;
    // if there is a single suit offset, we need to separate base_tiles into suits
    for offset in group.flatten() {
      match offset {
        MatchOffset::Offset(_) => { have_numeric_offsets = true; }
        MatchOffset::AttrsTile(_) => {}
        MatchOffset::AttrsOffset(_) => { have_numeric_offsets = true; }
        MatchOffset::TileOrKeyword(s) => {
          if FIXED_OFFSETS.get(&s).is_some() { have_fixed_offsets = true; }
        }
      }
    }
    let base_tile_sets = if separate_suits {
      // we need to try each suit
      if have_fixed_offsets {
        let base_m: Vec<ElixirTile> = vec!(man.clone());
        let base_p: Vec<ElixirTile> = vec!(pin.clone());
        let base_s: Vec<ElixirTile> = vec!(sou.clone());
        vec!(Rc::new(base_m), Rc::new(base_p), Rc::new(base_s))
      } else if have_numeric_offsets {
        // separate base tiles of the same suit
        let mut base_m: Vec<ElixirTile> = vec!();
        let mut base_p: Vec<ElixirTile> = vec!();
        let mut base_s: Vec<ElixirTile> = vec!();
        for tile in (*base_tiles).clone() {
          if is_manzu(&tile) { base_m.push(tile); }
          else if is_pinzu(&tile) { base_p.push(tile); }
          else if is_souzu(&tile) { base_s.push(tile); }
        }
        vec!(Rc::new(base_m), Rc::new(base_p), Rc::new(base_s), base_tiles.clone())
      } else { keys.clone() }
    } else if have_numeric_offsets {
      vec!(base_tiles.clone())
    } else { keys.clone() };
    for (base_tiles, key) in base_tile_sets.into_iter().zip(keys.iter()) {
      let reified = __generate_groups(
        group,
        &mut base_tiles.iter(),
        &match_info.all_attrs,
        &match_info.joker_tiles,
        &match_info.ordering, &match_info.ordering_r,
        &mut nojoker);
      if reified.is_empty() { continue; }

      if debug { println!("Reified group {0}/{1}: {2:?} using base tiles <{3:?}>{4} into the groups{5}:", i + 1, groups.len(), &group, base_tiles, if nojoker { " (nojoker)" } else { "" }, if separate_suits { " (separate_suits)" } else { "" }); }
      let mut stored_groups = vec!();
      for group in reified.iter() {
        if let Some(&ix) = reified_bank_r.get(&group) {
          stored_groups.push(reified_bank[ix].clone());
        } else {
          let ix = reified_bank.len();
          reified_bank_r.insert(group.clone(), ix);
          reified_bank.push(group.clone());
          stored_groups.push(reified_bank[ix].clone());
        }
      }
      if debug { println!("- {}", stored_groups.iter().map(|group| print_group(&group, match_info.all_attrs, nojoker)).collect::<Vec<_>>().join(", ")); }
      let map = ret.entry(key.clone()).or_insert_with(|| Rc::new(BTreeMap::new()));
      if let Some(m) = Rc::get_mut(map) {
        m.insert(i, Rc::new(stored_groups));
      } else {
        if debug { println!("failed to mutate map"); }
      }
    }
  }
  // if debug { println!("ret = {:?}", ret); }
  ret
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


// we only care about the hand, so calls will pass right through
fn perform_bipartite_match<'a>(
  offsets: Rc<Vec<MatchOffset>>, num: i8,
  acc: HandsIterator<'a>,
  base_tiles: Rc<Vec<ElixirTile>>,
  match_info: &'a MatchInfo,
  debug: bool, _exhaustive: bool, _unique: bool, nojoker: bool,
) -> HandsIterator<'a> {
  // count the number of actual offsets (not keywords)
  let mut num_offsets = 0;
  for o in offsets.iter() {
    match o {
      MatchOffset::TileOrKeyword(s) => {
        if s != "nojoker" && s != "unique" {
          num_offsets += 1;
        }
      }
      _ => { num_offsets += 1; }
    }
  }
  let actual_num = if num == 0 { 1 } else { abs(num) } as usize;
  if actual_num > num_offsets {
    // if debug { println!("Giving up early since there exists only {} of the {} groups we need to remove", num_offsets, num); }
    return Box::new(empty());
  }
  Box::new(acc.flat_map(move |mut hands| -> HandsIterator<'a> {
    if hands.len() == 0 {
      // if debug { println!("Giving up early since hand is empty"); }
      return Box::new(empty());
    }
    if hands[0].attrs.len() < actual_num {
      // if debug { println!("Giving up early since hand only has {} tiles but we need to remove {} groups", hands[0].attrs.len(), num); }
      return Box::new(empty());
    }

    // we always want to choose jokers last, so put them at the end
    move_jokers_to_end(&mut hands[0].attrs, &match_info.joker_tiles);

    if debug {
      println!("Attempting to match and remove {} offsets {:?} from hand {:?}; base tiles <{:?}>",
        num, offsets, decode(&hands[0], match_info.all_attrs), base_tiles);
    }

    let base_tiles = base_tiles.clone();
    let offsets = offsets.clone();
    Box::new((0..base_tiles.len()).flat_map(move |ix| -> HandsIterator<'a> {
      let base_tile = base_tiles[ix].clone();
      let num_ignores = num_offsets - actual_num; // can skip reifying this many tiles
      let Some((offset_elixir_tiles, mut nojoker_ix)) = apply_offsets_early_exit(&base_tile, &offsets, match_info.ordering, match_info.ordering_r, num_ignores)
      else {
        // if debug { println!("Giving up since we cannot reify enough offsets ({}/{}) in {:?} with base tile <{:?}> (num_ignores={})", num, num_offsets, offsets, base_tile, num_ignores); }
        return Box::new(empty());
      };

      if nojoker { nojoker_ix = 0; } // match keyword overrides group keyword

      if debug { println!("nojoker_ix for offsets {:?} is {nojoker_ix:?}", offset_elixir_tiles); }

      let offset_tiles: Vec<Tile> = offset_elixir_tiles.iter().flat_map(|tile| encode_tile(tile, match_info.all_attrs)).collect();

      // enumerate all matchings for offset_tiles via backtracking search
      // once a matching is found, emit it as an iterator value by removing it from hand
      let visited: Rc<RefCell<HashSet<Hash>>> = Rc::new(RefCell::new(HashSet::new()));
      let matching: Rc<RefCell<HashMap<usize, usize>>> = Rc::new(RefCell::new(HashMap::new()));
      bipartite_match(
        hands.clone(),
        Rc::new(offset_tiles),
        actual_num,
        nojoker_ix,
        matching,
        visited,
        0, 0, None, match_info, debug)
    }))
  }))
}

fn bipartite_match<'a>(
  mut hands: Hands,
  offset_tiles: Rc<Vec<Tile>>,
  num: usize,
  nojoker_ix: usize,
  matching: Rc<RefCell<HashMap<usize, usize>>>, // hand ix => offset ix
  visited: Rc<RefCell<HashSet<Hash>>>,
  i: usize, // incrementing ctr indexing into offset_tiles
  skipped: usize, // how many indices i we've skipped
  last_j: Option<usize>, // last j indexing into hands[0].attrs
  match_info: &'a MatchInfo,
  debug: bool,
) -> HandsIterator<'a> {
  // basically just backtracking search, same as the dfs tbh
  // except we enjoy a lot more caching in the form of `all_edges`
  if offset_tiles.len() < num + skipped {
    if debug { println!("Giving up because we've skipped {skipped} of {} offset tiles and cannot reach {num} matches", offset_tiles.len()); }
    if let Some(j) = last_j { matching.borrow_mut().remove(&j); };
    return Box::new(empty());
  } else if i == num + skipped {
    // done, remove matching from hand and emit the hand
    let mut ixs: Vec<RowIndex> = matching.borrow().keys().map(|&n| n as RowIndex).collect();
    ixs.sort_unstable();
    remove_tileset_indices(&mut hands[0], &ixs, &match_info.joker_tiles);
    if visited.borrow_mut().insert(hands[0].hash) {
      if debug { println!("Matched {}/{} offset tiles at {:?} (total {}, skipping {}), returning {:?}", i, num, ixs, offset_tiles.len(), skipped, decode(&hands[0], match_info.all_attrs)); }
      let ret = Box::new(once(hands));
      if let Some(j) = last_j { matching.borrow_mut().remove(&j); };
      return ret;
    } else {
      if debug { println!("Matched {}/{} offset tiles, skipping (visited size: {})", i, num, visited.borrow().len()); }
      if let Some(j) = last_j { matching.borrow_mut().remove(&j); };
      return Box::new(empty());
    }
  }

  if debug { println!("{i} = {:?}, {nojoker_ix}", decode_attrs(&vec!(offset_tiles[i]), match_info.all_attrs)); }

  // precompute hand indices j to recurse on
  let attrs = Rc::new(hands[0].attrs.clone());
  let aliases = if i < nojoker_ix { &match_info.aliases } else { &HashMap::new() };
  let ixs: Vec<usize> = (0..attrs.len())
    .filter(|j| !matching.borrow().contains_key(j) && _check_equivalence(&attrs[*j], &offset_tiles[i], aliases))
    .collect();

  if ixs.is_empty() {
    // skip this i
    return bipartite_match(hands, offset_tiles, num, nojoker_ix, matching, visited, i + 1, skipped + 1, last_j, match_info, debug)
  }

  Box::new(ixs.into_iter().flat_map(move |j| -> HandsIterator<'a> {
    matching.borrow_mut().insert(j, i);
    // if debug { println!("Recursing ({i}/{num}) after inserting {j}->{i}"); }
    bipartite_match(hands.clone(), offset_tiles.clone(), num, nojoker_ix, matching.clone(), visited.clone(), i + 1, skipped, Some(j), match_info, debug)
  }))
}

fn perform_dfs_match<'a>(
  groups: &[MatchGroup], num: i8,
  acc: HandsIterator<'a>,
  base_tiles: Rc<Vec<ElixirTile>>,
  match_info: &'a MatchInfo,
  debug: bool, exhaustive: bool, unique: bool, nojoker: bool,
) -> HandsIterator<'a> {
  let reified_groups_by_base_tile_set: Rc<HashMap<Rc<Vec<ElixirTile>>, Rc<BTreeMap<usize, Rc<Vec<RemovableGroup>>>>>> =
    Rc::new(reify_groups(groups, base_tiles.clone(), match_info, debug, nojoker));
  let base_tile_sets = Rc::new(reified_groups_by_base_tile_set.keys().cloned().collect::<Vec<_>>());
  Box::new(acc.flat_map(move |hands| {
    let reified = reified_groups_by_base_tile_set.clone();
    let base_tile_sets = base_tile_sets.clone();
    Box::new((0..base_tile_sets.len()).flat_map(move |i| -> HandsIterator<'a> {
      let Some(reified_groups) = reified.get(&base_tile_sets[i]) else { return Box::new(empty()) };
      // if debug {
      //   println!("groups {:?} with base tile <{:?}>:", groups, base_tile_sets[i]);
      //   for group in reified_groups.iter() {
      //     println!("- {}", group.1.iter().map(|group| print_group(&group, &match_info.all_attrs, nojoker)).collect::<Vec<_>>().join(", "),);
      //   }
      // }
      Box::new(
        dfs_match(
          (hands.clone(), 0, vec!()), match_info, reified_groups.clone(), num, debug, exhaustive, unique, nojoker
        ).map(move |(hands, _groups_used, _path)| hands)
      )
    }))
  }))
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

pub fn __remove_group<'a>(
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

