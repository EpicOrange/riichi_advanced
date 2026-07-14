use std::cell::RefCell;
use std::collections::{HashMap, BTreeMap, HashSet};
use std::iter::{empty, once};
use std::rc::Rc;
use std::sync::atomic::Ordering;
use std::time::Instant;
use num::abs;
use rustler::{Atom};

use crate::encode::{decode, encode, encode_aliases, print_group};
use crate::match_info::{prepare_tiles};
use crate::offsets::{__generate_groups, get_base_tiles};
use crate::primes::{is_manzu, is_pinzu, is_souzu};
use crate::profile::{PROFILE_MATCH, CALL_COUNT, MAX_NANOS, TOTAL_NANOS};
use crate::tile_table::{tile1m, tile1p, tile1s, tile1x};
use crate::tileset::{__subtract, __subtract_exhaustive, _remove_indices, _subtract_check_attrs_exhaustive};
use crate::types::{ANY_PRIME, Aliases, ElixirAliases, ElixirHand, ElixirHandCalls, ElixirTile, FIXED_OFFSETS, Hands, MatchDefinition, MatchDefinitionElem, MatchDefinitions, MatchGroup, MatchInfo, MatchOffset, RemovableGroup, Tile, TileSet};

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
fn perform_dfs_match<'a>(
    acc: AccItem,
    match_info: &'a MatchInfo,
    reified_groups_by_group: Rc<BTreeMap<usize, Rc<Vec<RemovableGroup>>>>,
    num: i8,
    debug: bool, exhaustive: bool, unique: bool, nojoker: bool,
    match_elem: &'a MatchDefinitionElem, base_tiles: Rc<Vec<ElixirTile>>,
) -> AccIterator<'a> {
  let actual_num = if num == 0 { 1 } else { abs(num) };
  let visited: Rc<RefCell<HashSet<Vec<PathItem>>>> = Rc::new(RefCell::new(HashSet::new()));
  (0..actual_num).fold(Box::new(once(acc)), move |mut acc, i| -> AccIterator<'a> {
    acc = if exhaustive { acc } else { Box::new(acc.take(1)) };
    let visited = visited.clone();
    let reified = reified_groups_by_group.clone();
    let base_tiles = base_tiles.clone();
    Box::new(acc.flat_map(move |hands| -> AccIterator<'a> {
      _perform_dfs_match(
        hands,
        match_info,
        visited.clone(),
        reified.clone(),
        debug, exhaustive, unique, nojoker,
        match_elem,
        i, num, base_tiles.clone()
      )
    }))
  })
}
fn _perform_dfs_match<'a>(
    (hands, ignore_ix, path): AccItem,
    match_info: &'a MatchInfo,
    visited: Rc<RefCell<HashSet<Vec<PathItem>>>>,
    reified: Rc<BTreeMap<usize, Rc<Vec<RemovableGroup>>>>,
    debug: bool, exhaustive: bool, unique: bool, nojoker: bool,
    match_elem: &'a MatchDefinitionElem,
    i: i8, num: i8, base_tile: Rc<Vec<ElixirTile>>,
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
    println!("Removal {0}/{1}{2} from ({3:?}) {4:?} / {5:?} \\ {6:?} <{7:?}> {8}{9}{10}",
      i + 1,
      actual_num,
      if num <= 0 { " (lookahead)" } else { "" },
      hands[0].attrs.len()+1,
      decode(&hands[0], match_info.all_attrs),
      hands[1..].iter().map(|call| decode(&call, match_info.all_attrs)).collect::<Vec<_>>(),
      match_elem,
      base_tile,
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
        println!("Skipping path {} for hands {:?}",
          key.iter().map(|group| print_group(&group, &match_info.all_attrs, nojoker)).collect::<Vec<_>>().join(", "),
          decode(&hands[0], &match_info.all_attrs));
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
          if debug {
            println!("We'll skip paths containing {} from now on (visited size: {})", 
              key.iter().map(|group| print_group(&group, &match_info.all_attrs, nojoker)).collect::<Vec<_>>().join(", "),
              visited.borrow().len());
          }
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
  let keys = if separate_suits {
    vec!(Rc::new(vec!(man.clone())), Rc::new(vec!(pin.clone())), Rc::new(vec!(sou.clone())), Rc::new(vec!(all.clone())))
  } else {
    vec!(Rc::new(vec!(all.clone())))
  };

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
      if have_numeric_offsets {
        // separate base tiles of the same suit
        let mut base_m: Vec<ElixirTile> = (*base_tiles).clone().into_iter().filter(|t| is_manzu(t)).collect();
        let mut base_p: Vec<ElixirTile> = (*base_tiles).clone().into_iter().filter(|t| is_pinzu(t)).collect();
        let mut base_s: Vec<ElixirTile> = (*base_tiles).clone().into_iter().filter(|t| is_souzu(t)).collect();
        if have_fixed_offsets {
          if !base_m.contains(&man) { base_m.push(man.clone()); }
          if !base_p.contains(&pin) { base_p.push(pin.clone()); }
          if !base_s.contains(&sou) { base_s.push(sou.clone()); }
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

      if debug { println!("Reified group {0}/{1}: {2:?} using base tiles <{3:?}>{4} into the groups:", i + 1, groups.len(), &group, base_tiles, if nojoker { " (nojoker)" } else { "" }); }
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
      MatchDefinitionElem::Group(_, n) => if *n > 0 { min_match_length += n; },
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
  match_definition.into_iter().fold(Box::new(once(starting_acc)), move |mut acc, match_elem| {
    match match_elem {
      MatchDefinitionElem::Keyword(s) => {
        if s == "exhaustive" { acc } // already handled
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
        else if s == "debug" { acc } // no-op
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
        } else {
          println!("Unknown match keyword \"{s}\"");
          acc
        }
      }
      MatchDefinitionElem::Group(groups, num) => {
        let mut unique = unique;
        for offset in groups.iter().flat_map(|group| group.flatten()) {
          match offset {
            MatchOffset::TileOrKeyword(s) => {
              if s == "unique" { unique = true; }
            }
            _ => {}
          }
        }

        let reified_groups_by_base_tile_set: Rc<HashMap<Rc<Vec<ElixirTile>>, Rc<BTreeMap<usize, Rc<Vec<RemovableGroup>>>>>> =
          Rc::new(reify_groups(groups, base_tiles.clone(), match_info, debug, nojoker));
        let base_tile_sets = Rc::new(reified_groups_by_base_tile_set.keys().cloned().collect::<Vec<_>>());
        Box::new(acc.flat_map(move |hands| {
          let reified = reified_groups_by_base_tile_set.clone();
          let base_tile_sets = base_tile_sets.clone();
          Box::new((0..base_tile_sets.len()).flat_map(move |i| -> HandsIterator<'a> {
            if let Some(reified_groups) = reified.get(&base_tile_sets[i]) {
              // if debug {
              //   println!("groups {:?} with base tile <{:?}>:", groups, base_tile_sets[i]);
              //   for group in reified_groups.iter() {
              //     println!("- {}", group.1.iter().map(|group| print_group(&group, &match_info.all_attrs, nojoker)).collect::<Vec<_>>().join(", "),);
              //   }
              // }
              _remove_match_definition(
                hands.clone(), reified_groups.clone(), *num, match_info,
                debug, exhaustive, unique, nojoker, match_elem, base_tile_sets[i].clone()
              )
            } else { Box::new(empty()) }
          }))
        }))
      }
    }
  })
}
fn _remove_match_definition<'a>(
  hands: Hands,
  reified_groups_by_group: Rc<BTreeMap<usize, Rc<Vec<RemovableGroup>>>>,
  num: i8,
  match_info: &'a MatchInfo,
  debug: bool, exhaustive: bool, unique: bool, nojoker: bool,
  match_elem: &'a MatchDefinitionElem, base_tiles: Rc<Vec<ElixirTile>>,
) -> HandsIterator<'a> {
  let prev_hands = hands.clone();

  // choose which algorithm to use based on flags
  let mut acc: HandsIterator<'a> =
    Box::new(
      perform_dfs_match(
        (hands.clone(), 0, vec!()), match_info, reified_groups_by_group.clone(), num, debug, exhaustive, unique, nojoker, match_elem, base_tiles
      ).map(move |(hands, _groups_used, _path)| hands)
    );

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
          println!("Result after {0:?}: ({1:?}) {2:?} / {3:?}",
            match_elem,
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
          println!("Result after {0:?}: (empty)", match_elem);
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
    let mut result = remove_match_definition(&match_info, &match_definition);
    let next = result.next();
    if next.is_some() {
      // for elem in match_definition.iter() {
      //   if let MatchDefinitionElem::Keyword(s) = elem {
      //     if s == "debug" {
      //       println!("Final result for match definition {:?}: {:?}", match_definition, next);
      //       break;
      //     }
      //   }
      // }
      return true;
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

