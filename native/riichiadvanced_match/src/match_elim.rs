use std::collections::HashSet;
use std::iter::{empty, once};
use std::rc::Rc;

use crate::tileset::{__subtract, __subtract_exhaustive};
use crate::types::{Aliases, Hands, HandsIterator, RemovableGroup, Tile, TileSet};

fn elim_call_name<'a>(hands: Hands, name: &'a String, exhaustive: bool) -> HandsIterator<'a> {
  // group is a call name, remove every corresponding call with that name
  let hands = Rc::new(hands);
  let hands_check = Rc::clone(&hands); // just to check names
  let ret = (0..hands.len())
    .filter(move |i| hands_check[*i].name.as_ref() == Some(name))
    .map(move |i| {
        let mut hands = (*hands).clone();
        hands.swap_remove(i);
        hands
    });
  if exhaustive { Box::new(ret) } else { Box::new(ret.take(1)) }
}

fn elim_tileset<'a>(
  hands: Hands, tileset: &TileSet,
  aliases: &Aliases,
  joker_tiles: &HashSet<Tile>,
  exhaustive: bool,
) -> HandsIterator<'a> {
  let mut ret = vec!();
  // check calls first
  for i in 1..hands.len() {
    if __subtract_exhaustive(&hands[i], tileset, aliases, joker_tiles).is_some() {
      let mut hands = hands.clone();
      hands.swap_remove(i);
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
      let mut hands = hands;
      hands[0] = result;
      ret.push(hands);
    }
  }
  Box::new(ret.into_iter())
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
pub fn _elim_group<'a>(
    hands: Hands, group_arg: &'a RemovableGroup,
    aliases: &'a Aliases,
    joker_tiles: &'a HashSet<Tile>,
    exhaustive: bool,
) -> HandsIterator<'a> {
  match group_arg {
    RemovableGroup::CallName(name) => elim_call_name(hands, name, exhaustive),
    RemovableGroup::Group(group) => elim_tileset(hands, group, aliases, joker_tiles, exhaustive),
    RemovableGroup::Multigroup(subgroups) => {
      // multigroup can only be removed from hand (= hands[0])
      let initial: HandsIterator<'a> = Box::new(once(hands.clone()));
      let ret = Box::new(subgroups.iter().fold(initial, move |acc, subgroup| {
        let ret = acc.flat_map(move |hands| {
          elim_tileset(hands, subgroup, aliases, joker_tiles, exhaustive)
        });
        if exhaustive { Box::new(ret) } else { Box::new(ret.take(1)) }
      }));
      if exhaustive { Box::new(ret) } else { Box::new(ret.take(1)) }
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
        hands.swap_remove(i);
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
      if __subtract(&hand, &tileset, aliases, joker_tiles).is_some() {
        let mut hands = hands.clone();
        hands.swap_remove(i);
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
