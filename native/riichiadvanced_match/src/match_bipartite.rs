use std::cell::RefCell;
use std::collections::{HashMap, HashSet};
use std::iter::{empty, once};
use std::rc::Rc;
use num::abs;

use crate::encode::{decode, decode_tiles};
use crate::offsets::{apply_offsets_early_exit};
use crate::tileset::{_check_equivalence, move_jokers_to_end, remove_tileset_indices};
use crate::types::{BaseTileVec, Hands, HandsIterator, Hash, IndexVec, MatchInfo, MatchOffset, RowIndex, Tile};

// we only care about the hand, so calls will pass right through
pub fn perform_bipartite_match<'a>(
  offsets: Rc<Vec<MatchOffset>>, num: i8,
  acc: HandsIterator<'a>,
  base_tiles: Rc<BaseTileVec>,
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
    if hands.is_empty() {
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
      let base_tile = base_tiles[ix];
      let num_ignores = num_offsets - actual_num; // can skip reifying this many tiles
      let Some((offset_tiles, mut nojoker_ix)) = apply_offsets_early_exit(&base_tile, &offsets, match_info.all_attrs, &match_info.ordering, &match_info.ordering_r, num_ignores)
      else {
        // if debug { println!("Giving up since we cannot reify enough offsets ({}/{}) in {:?} with base tile <{:?}> (num_ignores={})", num, num_offsets, offsets, base_tile, num_ignores); }
        return Box::new(empty());
      };

      if nojoker { nojoker_ix = 0; } // match keyword overrides group keyword

      if debug { println!("nojoker_ix for offsets {offset_tiles:?} is {nojoker_ix:?}"); }

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
    let mut ixs: IndexVec = matching.borrow().keys().map(|&n| n as RowIndex).collect();
    ixs.sort_unstable();
    remove_tileset_indices(&mut hands[0], ixs, &match_info.joker_tiles);
    if visited.borrow_mut().insert(hands[0].hash) {
      if debug { println!("Matched {}/{} offset tiles (total {}, skipping {}), returning {:?}", i, num, offset_tiles.len(), skipped, decode(&hands[0], match_info.all_attrs)); }
      let ret = Box::new(once(hands));
      if let Some(j) = last_j { matching.borrow_mut().remove(&j); };
      return ret;
    } else {
      if debug { println!("Matched {}/{} offset tiles, skipping (visited size: {})", i, num, visited.borrow().len()); }
      if let Some(j) = last_j { matching.borrow_mut().remove(&j); };
      return Box::new(empty());
    }
  }

  if debug { println!("{i} = {:?}, {nojoker_ix}", decode_tiles(&vec!(offset_tiles[i]), match_info.all_attrs)); }

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
