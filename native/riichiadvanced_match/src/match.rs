use std::collections::{HashMap, HashSet};
use std::sync::atomic::Ordering;
use std::time::Instant;
use num::abs;
use rustler::{Atom};

use crate::encode::{decode, encode, encode_aliases};
use crate::match_info::{prepare_tiles};
use crate::offsets::{__generate_groups, generate_groups_from_offsets, get_base_tiles};
use crate::profile::{CALL_COUNT, MAX_NANOS, TOTAL_NANOS};
use crate::tileset::{__subtract, __subtract_exhaustive, _remove_indices, _subtract_check_attrs_exhaustive};
use crate::types::{ANY_PRIME, Aliases, ElixirAliases, ElixirHand, ElixirHandCalls, ElixirTile, Hands, MatchDefinition, MatchDefinitionElem, MatchDefinitions, MatchGroup, MatchInfo, MatchOffset, PROFILE_MATCH, RemovableGroup, Tile, TileSet};

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
    RemovableGroup::GroupRef(group) => elim_tileset(hands, group, aliases, joker_tiles, exhaustive),
    RemovableGroup::Multigroup(subgroups) => {
      // multigroup can only be removed from hand (= hands[0])
      let mut ret = vec!(hands.clone());
      for subgroup in subgroups {
        let results = ret.iter().flat_map(move |hands| {
          _elim_group(hands, &RemovableGroup::GroupRef(&subgroup), aliases, joker_tiles, exhaustive)
        });
        // only retain one result if not exhaustive
        if exhaustive { ret = results.collect(); }
        else { ret = results.take(1).collect(); }
      }
      ret
    }
  }
}

fn perform_simple_match(
    acc: &mut Vec<Hands>, match_info: &MatchInfo,
    base_tile: &ElixirTile,
    offsets: &mut Vec<MatchOffset>, num: i8,
    debug: bool, unique: &mut bool, mut nojoker: bool,
) -> () {
  // all groups are single tiles, and exhaustive is false
  // this strategy takes advantage of these facts:
  // - you can early exit if you find yourself with not enough tiles to remove
  // - order of removal doesn't matter

  if offsets.contains(&MatchOffset::TileOrKeyword("unique".to_string())) {
    *unique = true;
  }

  if debug {
    println!("Acc (before removing {0} group{1}) {2:?}", num, if num == 1 { "" } else { "s" }, offsets);
    for hands in &*acc {
      println!("- ({0:?}) {1:?} / {2:?}",
        // _count_factors_fast(hands[0].hash, hands[0].attrs.iter().map(|(p, _)| p), 0),
        hands[0].attrs.len(),
        decode(&hands[0], match_info.all_attrs),
        hands[1..].iter().map(|call| decode(&call, match_info.all_attrs)).collect::<Vec<_>>(),
      );
    }
  }

  if *unique && offsets.len() < num as usize {
    // not enough groups exist to remove `num` of them!
    if debug {
      println!("We only have {0} group{1}, but need at least {2}", offsets.len(), if offsets.len() == 1 { "" } else { "s" }, num);
    }
    acc.clear();
    return;
  }
  let mut base_tile_wrapped: HashSet<ElixirTile> = HashSet::new();
  base_tile_wrapped.insert(base_tile.clone());
  let mut groups: Vec<RemovableGroup> = vec!();
  for offset in offsets.iter() {
    if let MatchOffset::TileOrKeyword(s) = offset {
      if s == "nojoker" { nojoker = true; continue; }
    }
    groups.append(&mut generate_groups_from_offsets(&vec!(offset.clone()), &base_tile_wrapped, &match_info.all_attrs, &match_info.joker_tiles, match_info.ordering, &match_info.ordering_r, nojoker));
  }
  if debug {
    println!("groups: {:?}",
      groups.iter().map(|g| if let RemovableGroup::Group(g) = g { Some(decode(&g, match_info.all_attrs)) } else { None }).flatten().collect::<Vec<_>>());
  }
  acc.retain_mut(|hands| {
    // try to remove exactly `num` of the given groups (in primes_attrs) from hand/calls
    let mut remaining = num;
    let available = groups.len();
    // use offsets to remove `num` groups
    // if we fail to do so, throw out `hands`
    let mut groups = groups.clone();
    while !groups.is_empty() {
      let mut i = 0;
      groups.retain_mut(|group| {
        if remaining == 0 { return false; } 
        if *unique && (available - i) < remaining as usize {
          if debug {
            println!("Stopping early because there are only {available} groups left (unique)");
          }
          return false;
        }
        i += 1;
        // if debug {
        //   println!("Removing group {0} of {1} ({2:?}) from hands {3:?} / {4:?}{5}{6} ({available} available, {7} remaining)",
        //     num - remaining + 1,
        //     num,
        //     decode(&group, match_info.all_attrs),
        //     decode(&hands[0], match_info.all_attrs),
        //     hands[1..].iter().map(|call| decode(&call, match_info.all_attrs)).collect::<Vec<_>>(),
        //     if *unique { " unique" } else { "" },
        //     if nojoker { " nojoker" } else { "" },
        //     remaining as usize - i
        //   );
        //   // let (masks, col_mask) = crate::tileset::compute_attr_masks(&hands[0].attrs, &group.attrs, &match_info.aliases);
        //   // println!("asdf {:?} {:?} {:?}", &masks, col_mask, crate::n_rooks::_solve_n_rooks(&masks, col_mask, 1u8));
        // }

        let result = _elim_group(hands, &group, &match_info.aliases, &match_info.joker_tiles, false)
          .into_iter().next();
        if let Some(new_hands) = result {
          *hands = new_hands;
          remaining -= 1;
          return !*unique; // remove if unique; keep otherwise
        }
        false // group not used
      });
      if *unique { break; }
    }
    // if removed enough, keep this hand/calls
    remaining == 0
  });

  if debug {
    println!("Acc (after removing {0} group{1}) {2:?}{3}", num, if num == 1 { "" } else { "s" }, offsets, if acc.is_empty() { " (empty)" } else { "" });
    for hands in &*acc {
      println!("- ({0:?}) {1:?} / {2:?}",
        // _count_factors_fast(hands[0].hash, hands[0].attrs.iter().map(|(p, _)| p), 0),
        hands[0].attrs.len(),
        decode(&hands[0], match_info.all_attrs),
        hands[1..].iter().map(|call| decode(&call, match_info.all_attrs)).collect::<Vec<_>>(),
      );
    }
  }
}


fn perform_standard_match(
    acc: &mut Vec<Hands>, match_info: &MatchInfo,
    base_tiles: &HashSet<ElixirTile>,
    groups: &Vec<MatchGroup>, num: i8,
    debug: bool, exhaustive: bool, unique: &mut bool, nojoker: &mut bool,
) -> () {
  if groups.contains(&MatchGroup::Offset(MatchOffset::TileOrKeyword("unique".to_string()))) {
    *unique = true;
  }

  // reify all groups into removable groups
  let mut reified_groups: Vec<(Vec<RemovableGroup>, usize)> = vec!();
  for i in 0..groups.len() {
    let reified = __generate_groups(
      &groups[i],
      base_tiles,
      &match_info.all_tiles.iter().collect(), &match_info.all_attrs,
      &match_info.joker_tiles,
      &match_info.ordering, &match_info.ordering_r,
      *nojoker);
    reified_groups.push((reified, i));
    // if debug {
    //   println!("Hand tiles: {0:?}", match_info.tiles_in_hand.iter().collect::<Vec<_>>());
    //   println!("Matchable tiles: {0:?}", match_info.matchable_tiles.iter().collect::<Vec<_>>());
    //   println!("Base tiles: {0:?}", base_tiles.iter().collect::<Vec<_>>());
    //   println!("All tiles: {0:?}", match_info.all_tiles.iter().collect::<Vec<_>>());
    //   for (reified, i) in &reified_groups {
    //     println!("Reified group {i}:");
    //     println!("  {0:?}", &groups[*i]);
    //     println!("Into the groups:");
    //     for group in reified {
    //       match group {
    //         RemovableGroup::CallName(name) => println!("- \"{0:?}\"", name),
    //         RemovableGroup::Group(group) => println!("- {0:?}", decode(group, match_info.all_attrs)),
    //         RemovableGroup::GroupRef(group) => println!("- {0:?}", decode(group, match_info.all_attrs)),
    //         RemovableGroup::Multigroup(subgroups) => println!("- {0:?}", subgroups.iter().map(|subgroup| decode(subgroup, match_info.all_attrs)).collect::<Vec<_>>()),
    //       }
    //     }
    //   }
    // }
  }

  let range = if num == 0 { 0..1 /* just 0 */ } else { 0..abs(num) };
  type Acc = Vec<(Hands, HashSet<usize>)>;
  let mut acc2: Acc = acc.into_iter().map(|hands| (hands.clone(), HashSet::new())).collect();
  for j in range {
    if acc2.is_empty() { break; }
    if debug {
      println!("Acc (before removal {0}/{num}):", j+1);
      for (hands, groups_used) in &*acc2 {
        let gs = reified_groups
          .iter()
          .filter(|(_, i)| !groups_used.contains(&i))
          .map(|(_, i)| groups[*i].clone())
          .collect::<Vec<_>>();
        println!("- ({0:?}) {1:?} / {2:?} \\\\ {3:?}{4}{5}{6}",
          // _count_factors_fast(hands[0].hash, hands[0].attrs.iter().map(|(p, _)| p), 0),
          hands[0].attrs.len(),
          decode(&hands[0], match_info.all_attrs),
          hands[1..].iter().map(|call| decode(&call, match_info.all_attrs)).collect::<Vec<_>>(),
          gs,
          if *unique { " unique" } else { "" },
          if exhaustive { " exhaustive" } else { "" },
          if *nojoker { " nojoker" } else { "" },
        );
      }
    }

    if exhaustive {
      let mut acc3: Acc = vec!();
      for (groups, k) in &mut *reified_groups {
        // if a group _doesn't_ match any hand in acc,
        // it will never match (within this group set)
        // so delete it
        groups.retain(|group| {
          let mut matched = false;
          for (hands, groups_used) in &acc2 {
            if groups_used.contains(&k) { continue; }
            for hands in _elim_group(hands, &group, &match_info.aliases, &match_info.joker_tiles, true) {
              matched = true;
              // probably highly inefficient to clone a vec of indices for every Hands
              // not sure how to do it better though
              let mut groups_used = groups_used.clone();
              if *unique { groups_used.insert(*k); }
              acc3.push((hands, groups_used));
            }
          }
          matched
        });
      }
      acc2 = acc3;
      acc2.dedup();
    } else if let Some((hands, mut groups_used)) = acc2.pop() {
      let mut result: Option<Hands> = None;
      for (groups, k) in &mut *reified_groups {
        if !groups_used.contains(&k) {
          let mut matched = false;
          groups.retain(|group| {
            if matched { return true; }
            for hands in _elim_group(&hands, &group, &match_info.aliases, &match_info.joker_tiles, true) {
              matched = true;
              result = Some(hands);
              if *unique { groups_used.insert(*k); }
              break;
            }
            matched
          });
        }
        if result.is_some() { break; }
      }
      acc2.clear();
      if let Some(hands) = result { acc2.push((hands, groups_used)); }
    }

    if debug {
      println!("Acc (after removal {0}/{num}):{1}", j+1, if acc2.is_empty() { " (empty)" } else { "" });
      for (hands, groups_used) in &*acc2 {
        let gs = reified_groups
          .iter()
          .filter(|(_, i)| !groups_used.contains(&i))
          .map(|(_, i)| groups[*i].clone())
          .collect::<Vec<_>>();
        println!("- ({0:?}) {1:?} / {2:?} \\\\ {3:?}{4}{5}{6}",
          // _count_factors_fast(hands[0].hash, hands[0].attrs.iter().map(|(p, _)| p), 0),
          hands[0].attrs.len(),
          decode(&hands[0], match_info.all_attrs),
          hands[1..].iter().map(|call| decode(&call, match_info.all_attrs)).collect::<Vec<_>>(),
          gs,
          if *unique { " unique" } else { "" },
          if exhaustive { " exhaustive" } else { "" },
          if *nojoker { " nojoker" } else { "" },
        );
      }
    }
  }
  *acc = acc2.into_iter().map(|(hands, _)| hands).collect();
}

pub fn remove_match_definition(match_info: &MatchInfo, match_definition: &MatchDefinition) -> Vec<Hands> {
  // first walk the definition to check for keywords and sum of group counts
  let mut min_match_length = 0;
  let mut debug = false;
  let mut has_restart = false;
  let mut has_almost = false;
  for elem in match_definition {
    match elem {
      MatchDefinitionElem::Keyword(s) => {
        if s == "debug" { debug = true; }
        else if s == "restart" { has_restart = true; }
        else if s == "almost" { has_almost = true; }
      }
      MatchDefinitionElem::Group(_, n) => if *n > 0 { min_match_length += n; },
    }
  }
  // early exit if we have more groups than tiles/calls!
  // this is mostly to prevent 14 tile hands, like kokushi, from matching when we have 13 tiles
  if min_match_length as usize > match_info.tiles_in_hand.len() && !has_restart && !has_almost {
    if debug {
      println!("match_info.tiles_in_hand: {0:?}", match_info.tiles_in_hand);
      println!("match_info.initial_hands: {0:?}", match_info.initial_hands);
      println!("match_definition: {match_definition:?}");
      println!("Since we only have {0} tiles, refusing to match length-{1} match {2:?}",
        match_info.tiles_in_hand.len(),
        min_match_length,
        match_definition,
      );
    }
    return vec!();
  }

  let base_tiles = get_base_tiles(match_info, &match_definition);
  let mut exhaustive = false;
  let mut unique = false;
  let mut nojoker = false;
  let mut acc = vec!(match_info.initial_hands.clone());
  for match_elem in match_definition {
    if acc.is_empty() { return acc; }
    match match_elem {
      MatchDefinitionElem::Keyword(s) => {
        if s == "exhaustive" { exhaustive = true; }
        else if s == "unique" { unique = true; }
        else if s == "nojoker" { nojoker = true; }
        else if s == "almost" {
          // simply add an any-joker to hand
          for hands in &mut acc {
            hands[0].hash *= ANY_PRIME;
            hands[0].attrs.push((ANY_PRIME, 0));
          }
        }
        else if s == "debug" {} // no-op
        else if s == "restart" {
          acc = vec!(match_info.initial_hands.clone());
        }
        else if s == "dismantle_calls" {
          for hands in &mut acc {
            let mut hand = hands.remove(0);
            for call in hands.iter_mut() {
              hand.hash *= call.hash;
              hand.attrs.append(&mut call.attrs);
            }
            hands.clear();
            hands.push(hand);
          }
        } else {
          println!("Unknown match keyword \"{s}\"");
        }
      }
      MatchDefinitionElem::Group(groups, num) => {
        // for lookaheads we need to store the previous acc
        let prev_acc = if *num <= 0 { acc.clone() } else { vec!() };

        // check if we have fixed offsets (amerijong)
        // if so, pass in 3 kinds of base suit tiles
        // otherwise just pass 1
        let mut offsets: Vec<MatchOffset> = groups
          .iter()
          .flat_map(|group| group.flatten())
          .collect::<Vec<_>>();
        // choose which algorithm to use based on flags
        if match_info.no_attrs && !exhaustive
            // and all groups are single offsets
            && groups.iter().all(|group| {
              match group {
                MatchGroup::Offset(_) => true,
                _ => false,
              }
            }) {
          // use simpler algo
          let mut ret = vec!();
          let prev_acc = acc.clone();
          for base_tile in base_tiles.iter() {
            if debug { println!("base_tile: {:?}", base_tile); }
            perform_simple_match(&mut acc, match_info, base_tile, &mut offsets, *num, debug, &mut unique, nojoker);
            // early exit if any hand is empty, by leaving only the empty hand
            if let Some(i) = acc.iter().position(|hands| hands.len() == 1 && hands[0].attrs.len() == 0) {
              ret.push(acc.swap_remove(i));
              break;
            }
            // otherwise prep to start again
            ret.append(&mut acc);
            acc = prev_acc.clone();
          }
          acc.clear();
          acc.append(&mut ret);
        } else {
          let mut unique = unique;
          let mut nojoker = nojoker;
          perform_standard_match(&mut acc, match_info, &base_tiles, groups, *num, debug, exhaustive, &mut unique, &mut nojoker);
        }

        // process lookaheads
        if *num == 0 { // forward lookahead
          if acc.is_empty() {
            return acc;
          } else {
            if debug { println!("Reverting due to last group being a successful forward lookahead (num=0)"); }
            acc = prev_acc;
          }
        } else if *num < 0 { // negative lookahead
          if acc.is_empty() {
            if debug { println!("Reverting due to last group being a successful negative lookahead (num={num})"); }
            acc = prev_acc;
          } else {
            return vec!();
          }
        } else { // it was a normal match
          acc.sort();
          acc.dedup();
          if debug {
            if !acc.is_empty() {
              println!("\nFinal result after {0:?}:", &match_elem);
              for hands in &acc {
                println!("- ({0:?}) {1:?} / {2:?}",
                  // _count_factors_fast(hands[0].hash, hands[0].attrs.iter().map(|(p, _)| p), 0),
                  hands[0].attrs.len(),
                  decode(&hands[0], match_info.all_attrs),
                  hands[1..].iter().map(|call| decode(&call, match_info.all_attrs)).collect::<Vec<_>>(),
                );
              }
            } else {
              println!("\nFinal result after {0:?}: (empty)\n", &match_elem);
            }
            println!("");
          }
        }
      }
    }
  }
  acc
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn _match_hand_v3(
    hand_calls: ElixirHandCalls,
    match_definitions: MatchDefinitions,
    all_tiles: Vec<ElixirTile>, all_attrs: Vec<String>,
    elixir_aliases: ElixirAliases,
    ordering: HashMap<Atom, Atom>, ordering_r: HashMap<Atom, Atom>,
) -> bool {
  let start = Instant::now();
  let ret = __match_hand_v3(
    &hand_calls,
    match_definitions,
    &mut all_tiles.into_iter().collect(),
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
    all_tiles: &'a mut HashSet<ElixirTile>, all_attrs: &'a Vec<String>,
    elixir_aliases: &'a ElixirAliases,
    ordering: &'a HashMap<Atom, Atom>, ordering_r: &'a HashMap<Atom, Atom>,
) -> bool {
  let match_info = prepare_tiles(
    hand_calls,
    all_tiles,
    all_attrs,
    elixir_aliases,
    ordering,
    ordering_r,
  );
  for match_definition in match_definitions {
    let result = remove_match_definition(&match_info, &match_definition);
    if !result.is_empty() {
      return true;
    }
  }
  false
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn _remove_group(
    hand: ElixirHand, group: MatchGroup, 
    all_tiles: Vec<ElixirTile>, all_attrs: Vec<String>,
    elixir_aliases: ElixirAliases,
    ordering: HashMap<Atom, Atom>, ordering_r: HashMap<Atom, Atom>,
    exhaustive: bool, nojoker: bool,
    base_tiles: Option<Vec<ElixirTile>>,
) -> Vec<ElixirHand> {
  __remove_group(
    hand, group,
    &mut all_tiles.into_iter().collect(),
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
    all_tiles: &'a mut HashSet<ElixirTile>, all_attrs: &'a Vec<String>,
    elixir_aliases: &'a ElixirAliases,
    ordering: &'a HashMap<Atom, Atom>, ordering_r: &'a HashMap<Atom, Atom>,
    exhaustive: bool, nojoker: bool,
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
    all_tiles,
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
    base_tiles,
    &match_info.all_tiles.iter().collect(), &match_info.all_attrs,
    &match_info.joker_tiles,
    &match_info.ordering, &match_info.ordering_r,
    nojoker,
  );

  // println!("Hand tiles: {0:?}", match_info.tiles_in_hand.iter().collect::<Vec<_>>());
  // println!("Base tiles: {0:?}", base_tiles.iter().collect::<Vec<_>>());
  // println!("All tiles: {0:?}", match_info.all_tiles.iter().collect::<Vec<_>>());
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

