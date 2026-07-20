use std::collections::{HashSet, VecDeque};
use std::iter::{empty, once};

use smallvec::SmallVec;

use crate::encode::{encode_attrs, encode_tiles, to_tileset};
use crate::tile_table::*;
use crate::types::{ANY_PRIME, BaseTileVec, ElixirTile, FIXED_OFFSETS, GroupIterator, MatchDefinition, MatchDefinitionElem, MatchGroup, MatchInfo, MatchOffset, RemovableGroup, Tile, TileOrdering, TileSet};
use crate::primes::{is_jihai, is_manzu, is_pinzu, is_souzu, shift_suit_mut, to_prime};

// return true if changed
fn apply_ordering_mut(
    tile: &mut Tile, ordering: &TileOrdering
) -> bool {
  match ordering.get(&tile.0) {
    Some(p) => {tile.0 = *p; true},
    None => false
  }
}

fn fetch_offset(
    q: &mut VecDeque<Tile>,
    l: &mut isize, r: &mut isize, target: isize,
    ordering: &TileOrdering, ordering_r: &TileOrdering
) -> Option<Tile> {
  if *l <= target && target <= *r {
    // already in queue, just fetch it
    q.get((target - *l) as usize).cloned()
  } else if *r < target && target < 10 {
    // look to the right
    let mut tile = *q.back().unwrap();
    loop {
      if apply_ordering_mut(&mut tile, ordering) {
        q.push_back(tile);
        *r += 1;
      } else {
        break;
      }
      if *r >= target { break; }
    }
    if *r == target { Some(tile) } else { None }
  } else if target < *l && -10 < target {
    // look to the left
    let mut tile = *q.front().unwrap();
    loop {
      if apply_ordering_mut(&mut tile, ordering_r) {
        q.push_front(tile);
        *l -= 1;
      } else {
        break;
      }
      if target >= *l { break; }
    }
    if *l == target { Some(tile) } else { None }
  } else { // abs(target) >= 10
    // figure out how many suits to shift first, then rerun with div 10
    let target2 = target % 10; // truncate towards 0
    match (target / 10).rem_euclid(3) { // classify into 0,1,2
      1 => {
        // get a new deque that takes original base tile shifted once
        // this is slightly inefficient since each >10 offset generates a new queue
        // TODO make it not have to do that (maintain 3 queues?)
        let mut base_tile = *q.get(-*l as usize).unwrap();
        if shift_suit_mut(&mut base_tile) {
          let mut q2 = VecDeque::from([base_tile]);
          let mut l2 = 0;
          let mut r2 = 0;
          fetch_offset(&mut q2, &mut l2, &mut r2, target2, ordering, ordering_r)
        } else { None }
      }
      2 => {
        // same deal, just shift suit twice
        let mut base_tile = *q.get(-*l as usize).unwrap();
        if shift_suit_mut(&mut base_tile) && shift_suit_mut(&mut base_tile) {
          let mut q2 = VecDeque::from([base_tile]);
          let mut l2 = 0;
          let mut r2 = 0;
          fetch_offset(&mut q2, &mut l2, &mut r2, target2, ordering, ordering_r)
        } else { None }
      }
      _ => fetch_offset(q, l, r, target2, ordering, ordering_r),
    }
  }
}

// fn add_attrs(tile: &ElixirTile, attrs: &Vec<String>) -> ElixirTile {
//   match tile {
//     ElixirTile::AtomTile(atom) => {
//       ElixirTile::AttrTile(*atom, attrs.clone())
//     }
//     ElixirTile::AttrTile(atom, attrs2) => {
//       let mut attrs = attrs.clone();
//       attrs.append(&mut attrs2.clone());
//       ElixirTile::AttrTile(*atom, attrs)
//     }
//   }
// }

#[inline]
fn add_attrs_mut((_p, attrs): &mut Tile, new_attrs: &mut [String], all_attrs: &[String]) {
  let new_attrs = encode_attrs(new_attrs, all_attrs);
  if new_attrs == 0 { return; }
  *attrs |= new_attrs;
}


pub fn apply_fixed_offset(base_tile: &Tile, fixed_offset: &str) -> Option<Tile> {
  FIXED_OFFSETS.get(fixed_offset).and_then(|atom| to_prime(&atom())).and_then(|p| {
    let mut ret: Tile = (p, 0);
    if is_jihai(&ret) {
      // modify the return tile based on base tile's suit
      let white = to_prime(&tile0z())?;
      let green = to_prime(&tile6z())?;
      let red = to_prime(&tile7z())?;
      if ret.0 == white { 
        if is_pinzu(base_tile) || base_tile.0 == white { ret.0 = green; }
        else if is_souzu(base_tile) || base_tile.0 == green { ret.0 = red; }
      } else if ret.0 == green { 
        if is_pinzu(base_tile) || base_tile.0 == white { ret.0 = red; }
        else if is_souzu(base_tile) || base_tile.0 == green { ret.0 = white; }
      } else if ret.0 == red { 
        if is_pinzu(base_tile) || base_tile.0 == white { ret.0 = white; }
        else if is_souzu(base_tile) || base_tile.0 == green { ret.0 = green; }
      } else { return None; }
    } else {
      // use shift_suit_mut to shift
      if is_manzu(base_tile) { }
      else if is_pinzu(base_tile) { shift_suit_mut(&mut ret); }
      else if is_souzu(base_tile) { shift_suit_mut(&mut ret); shift_suit_mut(&mut ret); }
      else { return None; }
    }
    Some(ret)
  })
}

// returns a pair (a vec of reified tiles for each offset, index of nojoker keyword)
pub fn apply_offsets(
    base_tile: &Tile, offsets: &[MatchOffset],
    all_attrs: &[String],
    ordering: &TileOrdering, ordering_r: &TileOrdering,
) -> (Vec<Option<Tile>>, usize) {
  let mut q = VecDeque::from([*base_tile]); // get offset o via q.get(o-l as usize)
  let mut l = 0;
  let mut r = 0;
  let mut nojoker_ix = offsets.len();
  let mut ret = vec!();
  for (i, offset) in offsets.iter().enumerate() {
    ret.push(match offset {
      MatchOffset::Offset(o) => fetch_offset(&mut q, &mut l, &mut r, *o, ordering, ordering_r),
      MatchOffset::AttrsTile(map) => {
        match ATOM_TABLE.get(&map.tile) {
          Some(atom_fn) => to_prime(&atom_fn()).map(|p| (p, encode_attrs(&mut map.attrs.clone(), all_attrs))),
          None => None,
        }
      }
      MatchOffset::AttrsOffset(map) => {
        fetch_offset(&mut q, &mut l, &mut r, map.offset, ordering, ordering_r)
          .map(|mut tile| { add_attrs_mut(&mut tile, &mut map.attrs.clone(), all_attrs); tile })
      }
      MatchOffset::TileOrKeyword(s) => {
        match ATOM_TABLE.get(s).and_then(|atom| to_prime(&atom())) {
          Some(p) => Some((p, 0)), // it's a tile
          None => {
            if s == "nojoker" {
              if nojoker_ix == offsets.len() { nojoker_ix = i; }
              None
            } else {
              // it's either a keyword or a a fixed offset
              // if it's actually a keyword other than nojoker, we ignore it
              // (the other group keyword is unique, which is processed toplevel)
              apply_fixed_offset(q.get(-l as usize).unwrap(), s)
            }
          }
        }
      }
    });
  }
  (ret, nojoker_ix)
}

// same as above but, ignoring keywords, returns None if any offset fails to reify
// the returned nojoker_ix points to where it should be after removing all keywords
pub fn apply_offsets_early_exit(
    base_tile: &Tile, offsets: &[MatchOffset],
    all_attrs: &[String],
    ordering: &TileOrdering, ordering_r: &TileOrdering,
    mut num_ignorable: usize,
) -> Option<(Vec<Tile>, usize)> {
  let mut q = VecDeque::from([*base_tile]); // get offset o via q.get(o-l as usize)
  let mut l = 0;
  let mut r = 0;
  let mut nojoker_ix = offsets.len();
  let mut keywords_before_nojoker = 0;
  let mut ret = vec!();
  for (i, offset) in offsets.iter().enumerate() {
    match offset {
      MatchOffset::Offset(o) => {
        let Some(tile) = fetch_offset(&mut q, &mut l, &mut r, *o, ordering, ordering_r)
        else { if num_ignorable == 0 { return None; } else { num_ignorable -= 1; continue; } };
        ret.push(tile);
      }
      MatchOffset::AttrsTile(map) => {
        let Some(p) = ATOM_TABLE.get(&map.tile).and_then(|atom_fn| to_prime(&atom_fn()))
        else { if num_ignorable == 0 { return None; } else { num_ignorable -= 1; continue; } };
        ret.push((p, encode_attrs(&mut map.attrs.clone(), all_attrs)))
      }
      MatchOffset::AttrsOffset(map) => {
        let Some(mut tile) = fetch_offset(&mut q, &mut l, &mut r, map.offset, ordering, ordering_r)
        else { if num_ignorable == 0 { return None; } else { num_ignorable -= 1; continue; } };
        add_attrs_mut(&mut tile, &mut map.attrs.clone(), all_attrs);
        ret.push(tile);
      }
      MatchOffset::TileOrKeyword(s) => {
        match ATOM_TABLE.get(s).and_then(|atom| to_prime(&atom())) {
          Some(p) => { ret.push((p, 0)); }, // it's a tile
          None => {
            if s == "nojoker" {
              if nojoker_ix == offsets.len() { nojoker_ix = i; }
            } else if s == "unique" { // any other keyword
              if nojoker_ix == offsets.len() { keywords_before_nojoker += 1; }
            } else {
              // it's either a keyword or a a fixed offset
              // if it's actually a keyword other than nojoker, we ignore it
              // (the other group keyword is unique, which is processed toplevel)
              let Some(tile) = apply_fixed_offset(q.get(-l as usize).unwrap(), s)
              else { if num_ignorable == 0 { return None; } else { num_ignorable -= 1; continue; } };
              ret.push(tile);
            }
          }
        }
      }
    }
  }
  Some((ret, nojoker_ix - keywords_before_nojoker))
}

// reifies offsets into a TileSet for each base tile
// wraps each in a RemovableGroup::Group
pub fn generate_groups_from_offsets<'a>(
    offsets: Vec<MatchOffset>,
    base_tiles: &'a mut impl Iterator<Item = Tile>, all_attrs: &'a [String],
    joker_tiles: &'a HashSet<Tile>,
    ordering: &'a TileOrdering, ordering_r: &'a TileOrdering,
    nojoker: &'a mut bool,
) -> GroupIterator<'a> {
  Box::new(base_tiles.filter_map(move |base_tile| {
    let (tiles, nojoker_ix) = apply_offsets(&base_tile, &offsets, all_attrs, ordering, ordering_r);
    if nojoker_ix < offsets.len() { *nojoker = true; }
    tiles
      .into_iter().collect::<Option<Vec<_>>>()
      .map(|tiles| RemovableGroup::Group(to_tileset(tiles, joker_tiles).set_nojoker(*nojoker)))
  }))
}

// #[rustler::nif]
fn _generate_groups(
    group: MatchGroup,
    base_tiles: Vec<ElixirTile>,
    all_attrs: Vec<String>,
    joker_tiles: Vec<Tile>,
    ordering: TileOrdering, ordering_r: TileOrdering,
    nojoker: bool,
) -> Vec<RemovableGroup> {
  __generate_groups(group, &mut encode_tiles(&base_tiles, &all_attrs), &all_attrs, &joker_tiles.into_iter().collect(), &ordering, &ordering_r, &mut nojoker.clone()).collect()
}
pub fn __generate_groups<'a>(
    group: MatchGroup,
    base_tiles: &'a mut impl Iterator<Item = Tile>,
    all_attrs: &'a [String],
    joker_tiles: &'a HashSet<Tile>,
    ordering: &'a TileOrdering, ordering_r: &'a TileOrdering,
    nojoker: &'a mut bool,
) -> GroupIterator<'a> {
  match group {
    // special case group-level keywords, which could be call names
    MatchGroup::Offset(MatchOffset::TileOrKeyword(s)) => {
      // first check if it's a tile name or fixed offset,
      match ATOM_TABLE.get(&s).or_else(|| FIXED_OFFSETS.get(&s)) {
        // in which case we do the same as for MatchGroup::Offset
        Some(_) => generate_groups_from_offsets(vec!(MatchOffset::TileOrKeyword(s)), base_tiles, all_attrs, joker_tiles, ordering, ordering_r, nojoker),
        None => {
          if s == "nojoker" {
            *nojoker = true;
            Box::new(empty()) as GroupIterator<'a>
          } else if s == "unique" {
            Box::new(empty()) as GroupIterator<'a>
          } else {
            // otherwise, return as call name
            Box::new(once(RemovableGroup::CallName(s.clone())))
          }
        }
      }
    }
    MatchGroup::Offset(offset) => generate_groups_from_offsets(vec!(offset), base_tiles, all_attrs, joker_tiles, ordering, ordering_r, nojoker),
    MatchGroup::Offsets(offsets) => generate_groups_from_offsets(offsets, base_tiles, all_attrs, joker_tiles, ordering, ordering_r, nojoker),
    MatchGroup::Subgroups(subgroupings) => {
      Box::new(base_tiles.filter_map(move |base_tile|
        subgroupings.iter()
          .map(|subgroup| 
            apply_offsets(&base_tile, subgroup, all_attrs, ordering, ordering_r)
              .0.into_iter()
              .collect::<Option<Vec<Tile>>>()
              .map(|tiles| to_tileset(tiles, joker_tiles).set_nojoker(*nojoker)))
          .collect::<Option<Vec<TileSet>>>()
          .map(RemovableGroup::Multigroup)
      ))
    }
  }
}

pub fn gather_rev_offsets(match_definition: &MatchDefinition) -> Vec<MatchOffset> {
  let mut ret = vec!(MatchOffset::Offset(0));
  for match_elem in match_definition {
    if let MatchDefinitionElem::Group(groups, _n) = match_elem {
      for group in groups {
        ret.extend(group.flatten());
      }
    }
  }
  ret.sort_unstable();
  ret.dedup();
  for offset in ret.iter_mut() {
    // negate all numeric offsets
    if let MatchOffset::Offset(o) = offset { *o = -*o; }
    else if let MatchOffset::AttrsOffset(m) = offset { m.offset = -m.offset; }
  }
  ret
}

// returns a sorted vec of base tiles
pub fn get_base_tiles<'a>( 
    match_info: &'a MatchInfo<'a>,
    match_definition: &'a MatchDefinition,
) -> BaseTileVec {
  // get all offsets of matchable tiles
  // we need to do this because jokers/offsets could reify into a tile
  //   that we can't otherwise encode, since it's not in hand
  let mut base_tiles: HashSet<Tile> = match_info.relevant_tiles
    .iter()
    .flat_map(|tile| apply_offsets(tile, &gather_rev_offsets(match_definition), match_info.all_attrs, &match_info.ordering, &match_info.ordering_r).0)
    .flatten()
    .filter_map(|(tile, _attrs)| if tile != ANY_PRIME { Some((tile, 0)) } else { None })
    .collect();

  for (p, _) in &match_info.joker_tiles { base_tiles.remove(&(*p, 0)); }

  let mut base_tiles = base_tiles.into_iter().collect::<SmallVec<_>>();
  base_tiles.sort_unstable();
  base_tiles.dedup();
  base_tiles
}
