use std::collections::{HashMap, HashSet};
use std::iter::{empty, once};
use std::rc::Rc;
use std::sync::atomic::Ordering;
use std::time::Instant;
use num::abs;
use rustler::{Atom};

use crate::encode::{decode, encode, encode_aliases};
use crate::match_info::{prepare_tiles};
use crate::offsets::{__generate_groups, get_base_tiles};
use crate::primes::{is_manzu, is_pinzu, is_souzu};
use crate::profile::{CALL_COUNT, MAX_NANOS, TOTAL_NANOS};
use crate::tile_table::{tile1m, tile1p, tile1s};
use crate::tileset::{__subtract, __subtract_exhaustive, _remove_indices, _subtract_check_attrs_exhaustive};
use crate::types::{ANY_PRIME, Aliases, ElixirAliases, ElixirHand, ElixirHandCalls, ElixirTile, FIXED_OFFSETS, Hands, MatchDefinition, MatchDefinitionElem, MatchDefinitions, MatchGroup, MatchInfo, MatchOffset, PROFILE_MATCH, RemovableGroup, Tile, TileSet};

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
    exhaustive: bool,
) -> HandsIterator<'a> {
  match group_arg {
    RemovableGroup::CallName(name) => elim_call_name_iter(hands, name.clone()),
    RemovableGroup::Group(group) => elim_tileset_iter(hands, group, aliases, joker_tiles, exhaustive),
    RemovableGroup::Multigroup(subgroups) => {
      // multigroup can only be removed from hand (= hands[0])
      subgroups.clone().into_iter().fold(Box::new(once(hands)) as HandsIterator, move |acc: HandsIterator, subgroup| -> HandsIterator {
        Box::new(acc.flat_map(move |hands| -> HandsIterator<'a> {
          elim_tileset_iter(hands, subgroup.clone(), aliases, joker_tiles, exhaustive)
        }))
      })
    }
  }
}

type AccIterator<'a> = Box<dyn Iterator<Item = (Hands, HashSet<usize>)> + 'a>;
fn perform_dfs_match<'a>(
    hands: (Hands, HashSet<usize>),
    match_info: &'a MatchInfo,
    reified_groups_by_group: Rc<Vec<(Vec<RemovableGroup>, usize)>>, num: i8,
    debug: bool, exhaustive: bool, unique: bool, nojoker: bool,
    match_elem: &'a MatchDefinitionElem,
) -> AccIterator<'a> {
  let actual_num = if num == 0 { 1 } else { abs(num) };
  (0..actual_num).fold(Box::new(once(hands)), move |mut acc, i| {
    let reified_groups_by_group = reified_groups_by_group.clone();
    acc = if exhaustive { acc } else { Box::new(acc.take(1)) };
    Box::new(acc.flat_map(move |hands| _perform_dfs_match(
      hands,
      match_info, 
      &reified_groups_by_group,
      debug, exhaustive, unique, nojoker, match_elem, i, actual_num,
    )))
  })
}
fn _perform_dfs_match<'a>(
    hands: (Hands, HashSet<usize>),
    match_info: &'a MatchInfo,
    reified_groups_by_group: &Vec<(Vec<RemovableGroup>, usize)>,
    debug: bool, exhaustive: bool, unique: bool, nojoker: bool,
    match_elem: &'a MatchDefinitionElem,
    i: i8, num: i8,
) -> AccIterator<'a> {
  let (hands, groups_used) = hands;
  if debug {
    println!("Removal {i}/{num} from ({0:?}) {1:?} / {2:?} \\ {3:?}{4}{5}{6}",
      hands[0].attrs.len(),
      decode(&hands[0], match_info.all_attrs),
      hands[1..].iter().map(|call| decode(&call, match_info.all_attrs)).collect::<Vec<_>>(),
      match_elem,
      if exhaustive { " exhaustive" } else { "" },
      if unique { " unique" } else { "" },
      if nojoker { " nojoker" } else { "" },
    );
    // for (reified, i) in reified_groups_by_group.iter() {
    //   if groups_used.contains(&i) { continue; }
    //   // for group in reified {
    //   //   match group {
    //   //     RemovableGroup::CallName(name) => println!("- \"{0:?}\"", name),
    //   //     RemovableGroup::Group(group) => println!("- {0:?}{1}", decode(group, match_info.all_attrs), if group.nojoker { " nojoker" } else { "" }),
    //   //     RemovableGroup::Multigroup(subgroups) => println!("- {0:?}", subgroups.iter().map(|subgroup| decode(subgroup, match_info.all_attrs)).collect::<Vec<_>>()),
    //   //   }
    //   // }
    //   let mut nojoker = nojoker;
    //   let mut alternatives: Vec<String> = vec!();
    //   for group in reified {
    //     match group {
    //       RemovableGroup::CallName(name) => {
    //         alternatives.push(name.to_owned());
    //       }
    //       RemovableGroup::Group(group) => {
    //         if group.nojoker { nojoker = true; }
    //         alternatives.push(format!("{:?}", decode(group, match_info.all_attrs)));
    //       }
    //       RemovableGroup::Multigroup(subgroups) => {
    //         for subgroup in subgroups {
    //           alternatives.push(format!("{:?}", decode(subgroup, match_info.all_attrs)));
    //         }
    //       }
    //     }
    //   }
    //   if !alternatives.is_empty() {
    //     println!("- {0}{1}", alternatives.join(", "), if nojoker { " nojoker" } else { "" });
    //   }
    // }
  }
  // TODO not sure if Cow<_> can be used to make the clones below cheaper
  Box::new(reified_groups_by_group.clone().into_iter().flat_map(move |(groups, i)| -> AccIterator<'a> {
    let hands = hands.clone();
    let mut groups_used = groups_used.clone(); // clone #1
    if groups_used.contains(&i) { return Box::new(empty()); }
    if unique { groups_used.insert(i); }
    // TODO optimization: if a group fails to match,
    // skip its copies in `groups` (requires some cache + lookahead)
    Box::new(groups.into_iter().flat_map(move |group| {
      let groups_used = groups_used.clone(); // clone #2
      elim_group_iter(hands.clone(), group, &match_info.aliases, &match_info.joker_tiles, exhaustive)
        .map(move |hands| (hands, groups_used.clone())) // clone #3
    }))
  }))
}

fn reify_groups<'a>(
  groups: &[MatchGroup],
  base_tiles: &Vec<ElixirTile>,
  match_info: &'a MatchInfo,
  _debug: bool, mut nojoker: bool,
) -> Vec<(Vec<RemovableGroup>, usize)> {
  let mut reified_ixs: Vec<Vec<usize>> = vec!();
  let mut reified_bank: Vec<RemovableGroup> = vec!();
  let mut reified_bank_r: HashMap<RemovableGroup, usize> = HashMap::new();
  for group in groups {
    let reified = __generate_groups(
      group,
      &mut base_tiles.iter(),
      &match_info.all_tiles.iter().collect(), &match_info.all_attrs,
      &match_info.joker_tiles,
      &match_info.ordering, &match_info.ordering_r,
      &mut nojoker);
    let mut ixs = vec!();
    for group in reified {
      if let Some(&ix) = reified_bank_r.get(&group) {
        ixs.push(ix);
      } else {
        let ix = reified_bank.len();
        reified_bank_r.insert(group.clone(), ix);
        reified_bank.push(group);
        ixs.push(ix);
      }
    }
    let mut refs = vec!();
    for ix in ixs.iter() {
      refs.push(&reified_bank[*ix]);
    }
    reified_ixs.push(ixs);
  }
  let mut reified_groups_by_group: Vec<(Vec<RemovableGroup>, usize)> = vec!();
  for (i, ixs) in reified_ixs.iter().enumerate() {
    let mut reified_groups = vec!();
    for ix in ixs { reified_groups.push(reified_bank[*ix].clone()); }
    reified_groups_by_group.push((reified_groups, i));
    // if debug {
    //   println!("\nHand tiles: {0:?}", match_info.tiles_in_hand.iter().collect::<Vec<_>>());
    //   println!("Matchable tiles: {0:?}", match_info.matchable_tiles.iter().collect::<Vec<_>>());
    //   println!("Base tiles: {0:?}", base_tiles.iter().collect::<Vec<_>>());
    //   println!("All tiles: {0:?}", match_info.all_tiles.iter().collect::<Vec<_>>());
    //   for (reified, i) in &reified_groups_by_group {
    //     println!("Reified group {0}/{1} unique/{2} total:", i + 1, reified_ixs.len(), groups.len());
    //     println!("  {0:?}", &groups[*i]);
    //     println!("Into the groups:");
    //     for group in reified {
    //       match group {
    //         RemovableGroup::CallName(name) => println!("- \"{0:?}\"", name),
    //         RemovableGroup::Group(group) => println!("- {0:?}", decode(group, match_info.all_attrs)),
    //         RemovableGroup::Multigroup(subgroups) => println!("- {0:?}", subgroups.iter().map(|subgroup| decode(subgroup, match_info.all_attrs)).collect::<Vec<_>>()),
    //       }
    //     }
    //   }
    // }
  }
  reified_groups_by_group
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
        // check 3 things:
        // - is "unique" in groups? if so, set unique now
        // - are there any fixed offsets in groups?
        // - are there any numeric offsets in groups?
        // - are there any suit offsets in groups? (including fixed offsets)
        // - (TODO) maybe also check if there are nonzero offsets?
        //   in which case you can filter out base tiles not in match_info.ordering
        let mut unique = unique;
        let mut have_fixed_offsets = false;
        let mut have_numeric_offsets = false;
        let mut have_suit_offsets = false;
        for offset in groups.iter().flat_map(|group| group.flatten()) {
          match offset {
            MatchOffset::Offset(o) => {
              have_numeric_offsets = true;
              if abs(o) >= 10 { have_suit_offsets = true; }
            },
            MatchOffset::AttrsTile(_) => {}
            MatchOffset::AttrsOffset(map) => {
              have_numeric_offsets = true;
              if abs(map.offset) >= 10 { have_suit_offsets = true; }
            },
            MatchOffset::TileOrKeyword(s) => {
              if s == "unique" {
                unique = true;
              } else if FIXED_OFFSETS.get(&s).is_some() {
                have_fixed_offsets = true;
                have_suit_offsets = true
              }
            }
          }
        }
        let base_tile_sets = if have_suit_offsets {
          // we need to try each suit
          if have_numeric_offsets {
            // separate base tiles of the same suit
            let mut base_m: Vec<ElixirTile> = (*base_tiles).clone().into_iter().filter(|t| is_manzu(t)).collect();
            let mut base_p: Vec<ElixirTile> = (*base_tiles).clone().into_iter().filter(|t| is_pinzu(t)).collect();
            let mut base_s: Vec<ElixirTile> = (*base_tiles).clone().into_iter().filter(|t| is_souzu(t)).collect();
            if have_fixed_offsets {
              base_m.push(ElixirTile::AtomTile(tile1m()));
              base_p.push(ElixirTile::AtomTile(tile1p()));
              base_s.push(ElixirTile::AtomTile(tile1s()));
            }
            vec!(Rc::new(base_m), Rc::new(base_p), Rc::new(base_s), base_tiles.clone())
          } else {
            vec!(
              Rc::new(vec!(ElixirTile::AtomTile(tile1m()))),
              Rc::new(vec!(ElixirTile::AtomTile(tile1p()))),
              Rc::new(vec!(ElixirTile::AtomTile(tile1s())))
            )
          }
        } else if have_numeric_offsets {
          vec!(base_tiles.clone())
        } else {
          vec!(Rc::new(vec!(ElixirTile::AtomTile(tile1m()))))
        };

        if debug {
          println!("For groups {:?}", groups);
          println!("have_fixed_offsets: {:?}", have_fixed_offsets);
          println!("have_numeric_offsets: {:?}", have_numeric_offsets);
          println!("have_suit_offsets: {:?}", have_suit_offsets);
          println!("Resulting base_tile_sets: {:?}", base_tile_sets);
        }
        let reified_groups_by_group_by_base_tile_sets: Rc<Vec<_>> = Rc::new(
          base_tile_sets
            .into_iter()
            // use base tiles to reify all groups into removable groups
            .map(move |base_tiles| Rc::new(reify_groups(groups, &base_tiles, match_info, debug, nojoker)))
            .collect());
        Box::new(acc.flat_map(move |hands| {
          let reified = reified_groups_by_group_by_base_tile_sets.clone();
          Box::new((0..reified.len()).flat_map(move |i| {
            _remove_match_definition(
              hands.clone(), &reified[i], *num, match_info,
              debug, exhaustive, unique, nojoker, match_elem
            )
          }))
        }))
        
        // // no idea why this equivalent looking version does not work
        // Box::new(acc.flat_map(move |hands| {
        //   reified_groups_by_group_by_base_tile_sets.clone()
        //     .iter()
        //     .flat_map(move |reified_groups_by_group| {
        //       _remove_match_definition(
        //         hands.clone(), &reified_groups_by_group, *num, match_info,
        //         debug, exhaustive, unique, nojoker, match_elem
        //       )
        //     })
        // }))
      }
    }
  })
}
fn _remove_match_definition<'a>(
  hands: Hands,
  reified_groups_by_group: &Rc<Vec<(Vec<RemovableGroup>, usize)>>,
  num: i8,
  match_info: &'a MatchInfo,
  debug: bool, exhaustive: bool, unique: bool, nojoker: bool,
  match_elem: &'a MatchDefinitionElem,
) -> HandsIterator<'a> {
  let prev_hands = hands.clone();

  // choose which algorithm to use based on flags
  let mut acc: HandsIterator<'a> =
    Box::new(
      perform_dfs_match(
        (hands.clone(), HashSet::new()), match_info, reified_groups_by_group.clone(), num, debug, exhaustive, unique, nojoker, match_elem
      ).map(move |(hands, _groups_used)| hands)
    );

  // process lookaheads
  if num == 0 { // forward lookahead
    match acc.next() {
      Some(_) => {
        if debug { println!("Reverting due to last group being a successful forward lookahead (num=0)"); }
        Box::new(once(prev_hands)) as HandsIterator<'a>
      }
      None => Box::new(empty()) as HandsIterator<'a>
    }
  } else if num < 0 { // negative lookahead
    match acc.next() {
      Some(_) => {
        if debug { println!("Reverting due to last group being a successful negative lookahead (num={num})"); }
        Box::new(empty()) as HandsIterator<'a>
      }
      None => Box::new(once(prev_hands)) as HandsIterator<'a>
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
        Box::new(once(hands).chain(acc)) as HandsIterator<'a>
      }
      None => {
        if debug {
          println!("Result after {0:?}: (empty)", match_elem);
        }
        Box::new(empty()) as HandsIterator<'a>
      }
    }
  }
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
    let mut result = remove_match_definition(&match_info, &match_definition);
    let next = result.next();
    // println!("Final result for match definition {:?}: {:?}", match_definition, next);
    if next.is_some() { return true; }
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
    &mut base_tiles.iter(),
    &match_info.all_tiles.iter().collect(), &match_info.all_attrs,
    &match_info.joker_tiles,
    &match_info.ordering, &match_info.ordering_r,
    &mut nojoker,
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

