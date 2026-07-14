use std::collections::HashSet;
use std::iter::{empty, once};

use crate::tileset::{__subtract, __subtract_exhaustive};
use crate::types::{Aliases, Hands, HandsIterator, RemovableGroup, Tile, TileSet};

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
pub fn _elim_group(
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

pub fn elim_group_iter<'a>(
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
