use smallvec::{SmallVec, smallvec};
use std::cell::RefCell;
use std::collections::{HashMap, BTreeMap, HashSet};
use std::iter::{empty, once};
use std::rc::Rc;
use num::abs;

use crate::encode::{decode, print_group};
use crate::match_elim::elim_group_iter;
use crate::offsets::{__generate_groups};
use crate::primes::{is_manzu, is_pinzu, is_souzu, to_prime};
use crate::tile_table::{tile1m, tile1p, tile1s, tile1x};
use crate::types::{AccItem, AccIterator, BaseTileVec, FIXED_OFFSETS, HandsIterator, MatchGroup, MatchInfo, MatchOffset, PathItem, RemovableGroup};

#[inline]
pub fn perform_dfs_match<'a>(
  groups: Vec<MatchGroup>, num: i8,
  acc: HandsIterator<'a>,
  base_tiles: Rc<BaseTileVec>,
  match_info: &'a MatchInfo,
  debug: bool, exhaustive: bool, unique: bool, nojoker: bool,
) -> HandsIterator<'a> {
  let reified_groups_by_base_tile_set: Rc<HashMap<Rc<BaseTileVec>, Rc<BTreeMap<usize, Rc<Vec<RemovableGroup>>>>>> =
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

#[inline]
fn reify_groups(
  groups: Vec<MatchGroup>,
  base_tiles: Rc<BaseTileVec>,
  match_info: &MatchInfo,
  debug: bool, mut nojoker: bool,
  // base tile set => group index i => vec of groups
) -> HashMap<Rc<BaseTileVec>, Rc<BTreeMap<usize, Rc<Vec<RemovableGroup>>>>> {
  let mut reified_bank: Vec<RemovableGroup> = vec!();
  let mut reified_bank_r: HashMap<RemovableGroup, usize> = HashMap::new();
  let mut ret: HashMap<Rc<BaseTileVec>, Rc<BTreeMap<usize, Rc<Vec<RemovableGroup>>>>> = HashMap::new();
  if debug {
    // println!("\nHand tiles: {0:?}", match_info.tiles_in_hand.iter().collect::<Vec<_>>());
    // println!("Base tiles: {0:?}", base_tiles.iter().collect::<Vec<_>>());
    // println!("Relevant tiles: {0:?}", match_info.relevant_tiles.iter().collect::<Vec<_>>());
  }
  let mut separate_suits = false;
  for group in groups.iter() {
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
  let man = (to_prime(&tile1m()).unwrap(), 0);
  let pin = (to_prime(&tile1p()).unwrap(), 0);
  let sou = (to_prime(&tile1s()).unwrap(), 0);
  let all = (to_prime(&tile1x()).unwrap(), 0);
  type KeysVec = SmallVec<[Rc<BaseTileVec>; 4]>;
  let keys: KeysVec = smallvec!(
    Rc::new(smallvec!(man)),
    Rc::new(smallvec!(pin)),
    Rc::new(smallvec!(sou)),
    Rc::new(smallvec!(all))
  );

  let num_groups = groups.len();
  for (i, group) in groups.into_iter().enumerate() {
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
        let base_m: BaseTileVec = smallvec!(man);
        let base_p: BaseTileVec = smallvec!(pin);
        let base_s: BaseTileVec = smallvec!(sou);
        smallvec!(Rc::new(base_m), Rc::new(base_p), Rc::new(base_s))
      } else if have_numeric_offsets {
        // separate base tiles of the same suit
        let mut base_m: BaseTileVec = smallvec!();
        let mut base_p: BaseTileVec = smallvec!();
        let mut base_s: BaseTileVec = smallvec!();
        for tile in (*base_tiles).clone() {
          if is_manzu(&tile) { base_m.push(tile); }
          else if is_pinzu(&tile) { base_p.push(tile); }
          else if is_souzu(&tile) { base_s.push(tile); }
        }
        smallvec!(Rc::new(base_m), Rc::new(base_p), Rc::new(base_s), base_tiles.clone())
      } else { keys.clone() }
    } else if have_numeric_offsets {
      smallvec!(base_tiles.clone())
    } else { keys.clone() };
    for (base_tiles, key) in base_tile_sets.into_iter().zip(keys.iter()) {
      let mut base_tile_iter = base_tiles.iter().copied();
      let reified = __generate_groups(
        group.clone(),
        &mut base_tile_iter,
        match_info.all_attrs,
        &match_info.joker_tiles,
        &match_info.ordering, &match_info.ordering_r,
        &mut nojoker);

      if debug { println!("Reified group {0}/{1}: {2:?} using base tiles <{3:?}> into the groups{4}:", i + 1, num_groups, &group, base_tiles, if separate_suits { " (separate_suits)" } else { "" }); }
      let mut stored_groups = vec!();
      for group in reified {
        if let Some(&ix) = reified_bank_r.get(&group) {
          stored_groups.push(reified_bank[ix].clone());
        } else {
          let ix = reified_bank.len();
          reified_bank_r.insert(group.clone(), ix);
          reified_bank.push(group.clone());
          stored_groups.push(reified_bank[ix].clone());
        }
      }
      if debug { println!("- {}", stored_groups.iter().map(|group| print_group(group, match_info.all_attrs, nojoker)).collect::<Vec<_>>().join(", ")); }
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

// (hands, ignore groups left of this index, path)
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
    println!("Removal {0}/{1}{2} from ({3:?}) {4:?} / {5:?} \\ {6:?} x{7} {8}{9}{10}",
      i + 1,
      actual_num,
      if num <= 0 { " (lookahead)" } else { "" },
      hands[0].attrs.len(),
      decode(&hands[0], match_info.all_attrs),
      hands[1..].iter().map(|call| decode(call, match_info.all_attrs)).collect::<Vec<_>>(),
      groups.iter().map(|g| print_group(&g.1, match_info.all_attrs, nojoker)).collect::<Vec<_>>().join(","), num,
      if exhaustive { " exhaustive" } else { "" },
      if unique { " unique" } else { "" },
      if nojoker { " nojoker" } else { "" },
    );
    for (j, group) in groups.iter() {
      let mut alternatives: Vec<String> = vec!();
      alternatives.push(print_group(group, match_info.all_attrs, nojoker));
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
fn is_visited(path: &[PathItem], last_item: &PathItem, visited: Rc<RefCell<HashSet<Vec<PathItem>>>>) -> bool {
  let len = path.len();
  if len >= 30 { false }
  else if len <= 4 {
    let vis = visited.borrow();
    for mask in 1..(1u32 << len) {
      let mut key: Vec<RemovableGroup> = (0..len)
        .filter_map(|i| if mask & (1 << i) != 0 { Some(path[i].clone()) } else { None } )
        .collect();
      key.sort_unstable();
      key.push(last_item.clone());
      if vis.contains(&key) { return true; }
    }
    false
  } else {
    let mut key = path.to_vec();
    key.sort_unstable();
    key.push(last_item.clone());
    visited.borrow().contains(&key)
  }
}
