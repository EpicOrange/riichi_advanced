use std::collections::HashMap;
use std::iter::{empty, once};

use num::abs;

use crate::encode::{decode, decode_tile, decode_tiles};
use crate::tileset::_check_equivalence;
use crate::types::{Hands, HandsIterator, IndexVec, MatchInfo, Tile};
use crate::utils::{remove_indices, remove_indices_smallvec};

// this is for matching a group with exact tiles (e.g. kokushi or milky way)
// in this case there is no need for base tiles
// just find any matching, or enumerate matchings

pub fn perform_exact_match<'a>(
  tiles: Vec<Tile>, num: i8,
  call_names: Vec<String>,
  acc: HandsIterator<'a>,
  match_info: &'a MatchInfo,
  debug: bool, _exhaustive: bool, _unique: bool, nojoker: bool,
) -> HandsIterator<'a> {
  let mut actual_num = if num == 0 { 1 } else { abs(num) } as usize;
  Box::new(acc.flat_map(move |mut hands| -> HandsIterator<'a> {
    if debug { println!("Running exact with hands = {:?}, tiles = {:?}, call_names = {call_names:?}, actual_num = {actual_num}", hands.iter().map(|hand| decode(hand, match_info.all_attrs)).collect::<Vec<_>>(), decode_tiles(&tiles, match_info.all_attrs)); }

    // first remove call names
    let mut call_ixs: IndexVec = hands[1..]
      .iter()
      .enumerate()
      .filter_map(|(i, call)| {
        if let Some(name) = &call.name { if call_names.contains(name) { return Some(1 + i as u8); } };
        None
       })
      .collect();
    call_ixs.truncate(actual_num);
    if !call_ixs.is_empty() {
      actual_num -= call_ixs.len();
      if debug { println!("    Removing calls by name at indices {call_ixs:?}; remaining num = {actual_num}"); }
      remove_indices_smallvec(&mut hands, call_ixs);
      if actual_num == 0 {
        if debug { println!("Returning hands = {hands:?}"); }
        return Box::new(once(hands));
      }
    }
    
    // then remove tiles, recursively 
    exact_match(tiles.clone(), actual_num, hands, match_info, debug, nojoker)
  }))
}

pub fn exact_match<'a>(
  mut tiles: Vec<Tile>, mut num: usize,
  mut hands: Hands,
  match_info: &'a MatchInfo,
  debug: bool, nojoker: bool,
) -> HandsIterator<'a> {
  let hand_tiles_remaining = hands[0].attrs.len() + hands.len() - 1;
  if hand_tiles_remaining < num { return Box::new(empty()); }
  let aliases = if nojoker { &HashMap::new() } else { &match_info.aliases };
  match tiles.pop() {
    None => Box::new(empty()),
    Some(tile) => {
      if debug { println!("  <{:?}> have {hand_tiles_remaining} tiles/calls, of which we need to remove {num} from {:?}", decode_tile(tile, match_info.all_attrs).unwrap(), hands.iter().map(|hand| decode(hand, match_info.all_attrs)).collect::<Vec<_>>()); }
      // check calls first
      let mut call_ixs: IndexVec = hands[1..]
        .iter()
        .enumerate()
        .filter_map(|(i, call)| if call.attrs.iter().any(|t| _check_equivalence(t, &tile, aliases)) { Some(1 + i as u8) } else { None })
        .collect();
      call_ixs.truncate(num);
      if !call_ixs.is_empty() {
        num -= call_ixs.len();
        if debug { println!("    Removing calls at indices {call_ixs:?}; remaining num = {num}"); }
        remove_indices_smallvec(&mut hands, call_ixs);
        if num == 0 {
          if debug { println!("Returning hands = {hands:?}"); }
          return Box::new(once(hands));
        }
      }

      // then remove as many of this tile as we can from hand
      let mut hand_ixs: IndexVec = hands[0].attrs
        .iter()
        .enumerate()
        .filter_map(|(i, t)| { if _check_equivalence(t, &tile, aliases) { Some(i as u8) } else { None } })
        .collect();
      hand_ixs.truncate(num);
      if !hand_ixs.is_empty() {
        num -= hand_ixs.len();
        if debug { println!("    Removing tile {tile:?} at indices {hand_ixs:?}; remaining num = {num}"); }
        remove_indices(&mut hands[0].attrs, hand_ixs);
        if num == 0 {
          if debug { println!("Returning hands = {hands:?}"); }
          return Box::new(once(hands));
        }
      }
      exact_match(tiles, num, hands, match_info, debug, nojoker)
    }
  }
}
