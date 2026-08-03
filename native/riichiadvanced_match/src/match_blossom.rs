use std::collections::HashMap;
use std::iter::{empty, once};

use blossom::Graph;
use num::abs;
use smallvec::smallvec;

use crate::encode::{decode, decode_mapping, decode_tile, decode_tiles, encode_attrs};
use crate::offsets::{apply_offsets, is_offset_dest};
use crate::tileset::{_check_equivalence, remove_tileset_indices};
use crate::types::{ANY_PRIME, HandsIterator, IndexVec, MatchGroup, MatchInfo, MatchOffset, Tile, TileSet};
use crate::utils::remove_indices_smallvec;

// this is for matching length-2 groups, usually [0, 0] for chiitoitsu
// most of the difficulty is dealing with jokers
// 'blossom' refers to the use of edmond's blossom algorithm

pub fn perform_blossom_match<'a>(
  groups: Vec<MatchGroup>, num: i8,
  acc: HandsIterator<'a>,
  match_info: &'a MatchInfo,
  debug: bool, _exhaustive: bool, _unique: bool, nojoker: bool,
) -> HandsIterator<'a> {
  let mut actual_num = if num == 0 { 1 } else { abs(num) } as usize;
  Box::new(acc.flat_map(move |mut hands| -> HandsIterator<'a> {
    let num_removes_possible = (hands[0].attrs.len() / 2) + hands.len() - 1;
    if num_removes_possible < actual_num {
      if debug { println!("Aborting because not enough tiles to remove {actual_num} groups of size 2; hands = {:?}", hands.iter().map(|h| decode(h, &match_info.all_attrs)).collect::<Vec<_>>()) }
      return Box::new(empty());
    }
    if debug {
      let mapping = if nojoker { &HashMap::new() } else { &match_info.mapping };
      println!("Running blossom with hands = {:?}, groups = {groups:?}, actual_num = {actual_num}, mapping = {:?}",
        hands.iter().map(|h| decode_tiles(&h.attrs, &match_info.all_attrs)).collect::<Vec<_>>(),
        decode_mapping(mapping, &match_info.all_attrs)
      );
    }
    // try to match as many calls as possible
    let mut matching_call_ixs: IndexVec = hands[1..]
      .iter()
      .enumerate()
      .filter(|(_i, call)| !check_pair_match(call, &groups, match_info, debug, nojoker, true).is_empty())
      .map(|(i, _call)| 1 + i as u8)
      .collect();
    matching_call_ixs.truncate(actual_num as usize);
    actual_num -= matching_call_ixs.len();
    if debug { println!("Removing calls at indices {:?}; remaining num = {}", matching_call_ixs, actual_num); }
    remove_indices_smallvec(&mut hands, matching_call_ixs);
    if actual_num == 0 {
      Box::new(once(hands))
    } else {
      if let Some(hand) = run_blossom(hands[0].clone(), &groups, actual_num as i8, match_info, debug, nojoker) {
        hands[0] = hand;
        Box::new(once(hands))
      } else { Box::new(empty()) }
    }
  }))
}

// since groups are size 2, we can 'simply' check if shifting first tile results in second tile
fn check_pair_match(hand: &TileSet, groups: &[MatchGroup], match_info: &MatchInfo, debug: bool, nojoker: bool, stop_early: bool) -> HashMap<usize, Vec<usize>> {
  let mut ret: HashMap<usize, Vec<usize>> = HashMap::new();
  let aliases = if nojoker { &HashMap::new() } else { &match_info.aliases };
  let mapping = if nojoker { &HashMap::new() } else { &match_info.mapping };
  // println!("aliases: {aliases:?}");
  // println!("mapping: {mapping:?}");
  for group in groups {
    if let MatchGroup::Offsets(os) = group {
      // first, find the first numeric offset and use it to offset the other offset
      if let Some((offset, from_attrs, to_attrs)) = match (os[0].clone(), os[1].clone()) {
        (MatchOffset::Offset(a), MatchOffset::Offset(b)) => Some((b - a, 0, 0)),
        (MatchOffset::Offset(a), MatchOffset::AttrsOffset(mut map)) => Some((map.offset - a, 0, encode_attrs(&mut map.attrs, &match_info.all_attrs))),
        (MatchOffset::AttrsOffset(mut map), MatchOffset::Offset(a)) => Some((map.offset - a, encode_attrs(&mut map.attrs, &match_info.all_attrs), 0)),
        (MatchOffset::AttrsOffset(mut map1), MatchOffset::AttrsOffset(mut map2)) => Some((map2.offset - map1.offset, encode_attrs(&mut map1.attrs, &match_info.all_attrs), encode_attrs(&mut map2.attrs, &match_info.all_attrs))),
        _ => None,
      } {
        let required_attr_tile1 = (ANY_PRIME, from_attrs);
        let required_attr_tile2 = (ANY_PRIME, to_attrs);
        // then see if applying the combined offset to one tile gets you one of the other tiles in the hand
        let offsets = vec!(MatchOffset::Offset(offset));
        for (i, tile1) in hand.attrs.iter().enumerate() {
          // if tile1 doesn't have the required attrs, skip it
          if !_check_equivalence(tile1, &required_attr_tile1, aliases) { continue; }
          if let Some(mut target) = apply_offsets(tile1, &offsets, &match_info.all_attrs, &match_info.ordering).0[0] {
            target.1 &= !from_attrs;
            target.1 |= to_attrs;
            for (j, tile2) in hand.attrs.iter().enumerate() {
              if i == j { continue; }
              // if tile2 doesn't have the required attrs, skip it
              if !_check_equivalence(tile2, &required_attr_tile2, aliases) { continue; }
              // draw an edge between two tiles iff they share any aliases
              let tile2_vec = vec!(*tile2);
              let tile2_mappings = mapping.get(tile2).unwrap_or(&tile2_vec);
              if debug {
                println!("{:?} == {:?} == {:?} == {:?} == {:?}",
                  decode_tile(required_attr_tile1, &match_info.all_attrs),
                  decode_tile(*tile1, &match_info.all_attrs),
                  decode_tile(target, &match_info.all_attrs),
                  decode_tiles(tile2_mappings, &match_info.all_attrs),
                  decode_tile(required_attr_tile2, &match_info.all_attrs),
                  );
              }
              if tile2_mappings.iter().any(|t| _check_equivalence(&target, t, aliases)) {
                if debug { println!("true"); }
                ret.entry(i)
                  .and_modify(|ixs| ixs.push(j))
                  .or_insert_with(|| vec!(j));
                if stop_early { return ret; }
                ret.entry(j)
                  .and_modify(|ixs| ixs.push(i))
                  .or_insert_with(|| vec!(i));
              }
            }
          }
        }
      } else {
        // if offsets are not both numeric,
        // then we just look for two indices that match the offsets
        // first collect all tiles that could match os[0]
        let matched_tiles: Vec<(usize, &Tile)> = hand.attrs.iter().enumerate().filter(|&(_i, &t)| is_offset_dest(t, os[0].clone(), match_info)).collect();
        if matched_tiles.is_empty() { continue; }
        // then find all tiles that could match os[1]
        // this only works since it's not the case that both offsets are numeric
        for (i, &t) in hand.attrs.iter().enumerate() {
          let Some(&(j, _t2)) = matched_tiles.iter().find(|(j, _)| i != *j) else { continue; };
          if is_offset_dest(t, os[1].clone(), match_info) {
            ret.entry(i)
              .and_modify(|ixs| ixs.push(j))
              .or_insert_with(|| vec!(j));
            if stop_early { return ret; }
            ret.entry(j)
              .and_modify(|ixs| ixs.push(i))
              .or_insert_with(|| vec!(i));
          }
        }
      }
    }
  }
  ret
}

fn run_blossom<'a>(
  mut hand: TileSet,
  groups: &'a[MatchGroup], num: i8,
  match_info: &'a MatchInfo,
  debug: bool, nojoker: bool,
) -> Option<TileSet> {
  let graph: Graph = check_pair_match(&hand, groups, match_info, debug, nojoker, false).into_iter().collect();
  if debug { println!("Graph: {graph:?}"); }
  let mut matching = graph.maximum_matching().edges();
  if debug { println!("Matching: {matching:?} ({}/{num})", matching.len()); }
  if matching.len() < num as usize { return None; }
  matching.truncate(num as usize);
  let mut ixs: IndexVec = smallvec!();
  for (a, b) in matching {
    ixs.push(a as u8);
    ixs.push(b as u8);
  }
  ixs.sort();
  ixs.dedup();
  remove_tileset_indices(&mut hand, ixs, &match_info.joker_tiles);
  if debug { println!("After removal: {:?}", decode(&hand, &match_info.all_attrs)); }
  Some(hand)
}