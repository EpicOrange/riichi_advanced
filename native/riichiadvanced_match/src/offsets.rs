use std::collections::{HashMap, HashSet, VecDeque};
use rustler::Atom;

use crate::encode::{decode_tile, decode_tiles, encode};
use crate::tile_table::*;
use crate::types::{ElixirTile, FIXED_OFFSETS, MatchDefinition, MatchDefinitionElem, MatchGroup, MatchInfo, MatchOffset, RemovableGroup, Tile, TileSet};
use crate::primes::{is_any, is_jihai, is_manzu, is_pinzu, is_souzu, shift_suit_mut};
use crate::utils::{get_tile_atom, get_tile_atom_mut, strip_attrs};

// return true if changed
fn apply_ordering_mut(
    tile: &mut ElixirTile, ordering: &HashMap<Atom, Atom>
) -> bool {
  match tile {
    ElixirTile::AtomTile(atom) => {
      match ordering.get(&atom) {
        Some(atom) => { *tile = ElixirTile::AtomTile(*atom); true }
        None => { false }
      }
    }
    ElixirTile::AttrTile(atom, _attrs) => {
      match ordering.get(&atom) {
        Some(atom2) => { *atom = *atom2; true }
        None => { false }
      }
    }
  }
}

fn fetch_offset(
    q: &mut VecDeque<ElixirTile>,
    l: &mut isize, r: &mut isize, target: isize,
    ordering: &HashMap<Atom, Atom>, ordering_r: &HashMap<Atom, Atom>
) -> Option<ElixirTile> {
  if *l <= target && target <= *r {
    // already in queue, just fetch it
    q.get((target - *l) as usize).cloned()
  } else if *r < target && target < 10 {
    // look to the right
    let mut tile = q.back().unwrap().clone();
    loop {
      if apply_ordering_mut(&mut tile, ordering) {
        q.push_back(tile.clone());
        *r += 1;
      } else {
        break;
      }
      if *r >= target { break; }
    }
    if *r == target { Some(tile) } else { None }
  } else if target < *l && -10 < target {
    // look to the left
    let mut tile = q.front().unwrap().clone();
    loop {
      if apply_ordering_mut(&mut tile, ordering_r) {
        q.push_front(tile.clone());
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
        let mut base_tile = q.get(-*l as usize).unwrap().clone();
        if shift_suit_mut(&mut base_tile) {
          let mut q2 = VecDeque::from([base_tile]);
          let mut l2 = 0;
          let mut r2 = 0;
          fetch_offset(&mut q2, &mut l2, &mut r2, target2, ordering, ordering_r)
        } else { None }
      }
      2 => {
        // same deal, just shift suit twice
        let mut base_tile = q.get(-*l as usize).unwrap().clone();
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

fn add_attrs_mut(tile: &mut ElixirTile, mut attrs: &mut Vec<String>) -> () {
  if attrs.is_empty() { return; }
  match tile {
    ElixirTile::AtomTile(atom) => {
      *tile = ElixirTile::AttrTile(*atom, attrs.clone());
    }
    ElixirTile::AttrTile(_atom, attrs2) => {
      attrs2.append(&mut attrs);
    }
  }
}


pub fn apply_fixed_offset(base_tile: &ElixirTile, fixed_offset: &String) -> Option<ElixirTile> {
  FIXED_OFFSETS.get(fixed_offset).and_then(|atom| {
    let mut ret = ElixirTile::AtomTile(atom());
    if is_jihai(&ret) {
      // modify the return tile based on base tile's suit
      let ret_atom = get_tile_atom_mut(&mut ret);
      let base_tile_atom = get_tile_atom(&base_tile);
      let white = tile0z();
      let green = tile6z();
      let red = tile7z();
      if *ret_atom == white { 
        if is_pinzu(&base_tile) || *base_tile_atom == white { *ret_atom = green; }
        else if is_souzu(&base_tile) || *base_tile_atom == green { *ret_atom = red; }
      } else if *ret_atom == green { 
        if is_pinzu(&base_tile) || *base_tile_atom == white { *ret_atom = red; }
        else if is_souzu(&base_tile) || *base_tile_atom == green { *ret_atom = white; }
      } else if *ret_atom == red { 
        if is_pinzu(&base_tile) || *base_tile_atom == white { *ret_atom = white; }
        else if is_souzu(&base_tile) || *base_tile_atom == green { *ret_atom = green; }
      } else { return None; }
    } else {
      // use shift_suit_mut to shift
      if is_manzu(&base_tile) { }
      else if is_pinzu(&base_tile) { shift_suit_mut(&mut ret); }
      else if is_souzu(&base_tile) { shift_suit_mut(&mut ret); shift_suit_mut(&mut ret); }
      else { return None; }
    }
    Some(ret)
  })
}

// returns a pair (a vec of reified tiles for each offset, index of nojoker keyword)
pub fn apply_offsets(
    base_tile: &ElixirTile, offsets: &[MatchOffset],
    ordering: &HashMap<Atom, Atom>, ordering_r: &HashMap<Atom, Atom>,
) -> (Vec<Option<ElixirTile>>, usize) {
  let mut q = VecDeque::from([base_tile.clone()]); // get offset o via q.get(o-l as usize)
  let mut l = 0;
  let mut r = 0;
  let mut nojoker_ix = offsets.len();
  let mut ret = vec!();
  for (i, offset) in offsets.iter().enumerate() {
    ret.push(match offset {
      MatchOffset::Offset(o) => fetch_offset(&mut q, &mut l, &mut r, *o, ordering, ordering_r),
      MatchOffset::AttrsTile(map) => {
        match ATOM_TABLE.get(&map.tile) {
          Some(atom_fn) => Some(ElixirTile::AttrTile(atom_fn(), map.attrs.clone())),
          None => None,
        }
      }
      MatchOffset::AttrsOffset(map) => {
        fetch_offset(&mut q, &mut l, &mut r, map.offset, ordering, ordering_r)
          .map(|mut tile| { add_attrs_mut(&mut tile, &mut map.attrs.clone()); tile })
      }
      MatchOffset::TileOrKeyword(s) => {
        match ATOM_TABLE.get(s) {
          Some(atom_fn) => Some(ElixirTile::AtomTile(atom_fn())), // it's a tile
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
    base_tile: &ElixirTile, offsets: &[MatchOffset],
    ordering: &HashMap<Atom, Atom>, ordering_r: &HashMap<Atom, Atom>,
    mut num_ignorable: usize,
) -> Option<(Vec<ElixirTile>, usize)> {
  let mut q = VecDeque::from([base_tile.clone()]); // get offset o via q.get(o-l as usize)
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
        let Some(atom_fn) = ATOM_TABLE.get(&map.tile)
        else { if num_ignorable == 0 { return None; } else { num_ignorable -= 1; continue; } };
        ret.push(ElixirTile::AttrTile(atom_fn(), map.attrs.clone()))
      }
      MatchOffset::AttrsOffset(map) => {
        let Some(mut tile) = fetch_offset(&mut q, &mut l, &mut r, map.offset, ordering, ordering_r)
        else { if num_ignorable == 0 { return None; } else { num_ignorable -= 1; continue; } };
        add_attrs_mut(&mut tile, &mut map.attrs.clone());
        ret.push(tile);
      }
      MatchOffset::TileOrKeyword(s) => {
        match ATOM_TABLE.get(s) {
          Some(atom_fn) => { ret.push(ElixirTile::AtomTile(atom_fn())); }, // it's a tile
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
    offsets: &Vec<MatchOffset>,
    base_tiles: &mut impl Iterator<Item = &'a ElixirTile>, all_attrs: &[String],
    joker_tiles: &HashSet<Tile>,
    ordering: &HashMap<Atom, Atom>, ordering_r: &HashMap<Atom, Atom>,
    nojoker: &mut bool,
) -> Vec<RemovableGroup> {
  base_tiles.map(|base_tile| {
    let (tiles, nojoker_ix) = apply_offsets(&base_tile, offsets, ordering, ordering_r);
    if nojoker_ix < offsets.len() { *nojoker = true; }
    tiles
      .into_iter().collect::<Option<Vec<_>>>()
      .map(|tiles| RemovableGroup::Group(encode(&tiles, all_attrs, joker_tiles).set_nojoker(*nojoker)))
  }).flatten().collect::<Vec<_>>()
}

// #[rustler::nif]
fn _generate_groups(
    group: MatchGroup,
    base_tiles: Vec<ElixirTile>,
    all_attrs: Vec<String>,
    joker_tiles: Vec<Tile>,
    ordering: HashMap<Atom, Atom>, ordering_r: HashMap<Atom, Atom>,
    nojoker: bool,
) -> Vec<RemovableGroup> {
  __generate_groups(&group, &mut base_tiles.iter(), &all_attrs, &joker_tiles.into_iter().collect(), &ordering, &ordering_r, &mut nojoker.clone())
}
pub fn __generate_groups<'a>(
    group: &MatchGroup,
    base_tiles: &mut impl Iterator<Item = &'a ElixirTile>,
    all_attrs: &[String],
    joker_tiles: &HashSet<Tile>,
    ordering: &HashMap<Atom, Atom>, ordering_r: &HashMap<Atom, Atom>,
    mut nojoker: &mut bool,
) -> Vec<RemovableGroup> {
  let mut ret = match group {
    // special case group-level keywords, which could be call names
    MatchGroup::Offset(MatchOffset::TileOrKeyword(s)) => {
      // first check if it's a tile name or fixed offset,
      match ATOM_TABLE.get(s).or_else(|| FIXED_OFFSETS.get(s)) {
        // in which case we do the same as for MatchGroup::Offset
        Some(_) => generate_groups_from_offsets(&vec!(MatchOffset::TileOrKeyword(s.clone())), base_tiles, all_attrs, joker_tiles, ordering, ordering_r, &mut nojoker),
        None => {
          if s == "nojoker" {
            *nojoker = true;
            vec!()
          } else if s == "unique" {
            vec!()
          } else {
            // otherwise, return as call name
            vec!(RemovableGroup::CallName(s.clone()))
          }
        }
      }
    }
    MatchGroup::Offset(offset) => generate_groups_from_offsets(&vec!(offset.clone()), base_tiles, all_attrs, joker_tiles, ordering, ordering_r, &mut nojoker),
    MatchGroup::Offsets(offsets) => generate_groups_from_offsets(offsets, base_tiles, all_attrs, joker_tiles, ordering, ordering_r, &mut nojoker),
    MatchGroup::Subgroups(subgroupings) => {
      base_tiles.filter_map(|base_tile|
        subgroupings.iter()
          .map(|subgroup| 
            apply_offsets(base_tile, subgroup, ordering, ordering_r)
              .0.into_iter()
              .collect::<Option<Vec<ElixirTile>>>()
              .map(|tiles| encode(&tiles, all_attrs, joker_tiles).set_nojoker(*nojoker)))
          .collect::<Option<Vec<TileSet>>>()
          .map(RemovableGroup::Multigroup)
      ).collect::<Vec<RemovableGroup>>()
    }
  };
  ret.sort_unstable();
  ret.dedup();
  ret
}

// TODO maybe faster to return a HashSet?
pub fn gather_rev_offsets(match_definition: &MatchDefinition) -> Vec<MatchOffset> {
  let mut ret = vec!(MatchOffset::Offset(0));
  for match_elem in match_definition {
    if let MatchDefinitionElem::Group(groups, _n) = match_elem {
      for group in groups {
        ret.append(&mut group.flatten());
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

pub fn get_base_tiles<'a>( 
    match_info: &'a MatchInfo<'a>,
    match_definition: &'a MatchDefinition,
) -> HashSet<ElixirTile> {
  // get all offsets of matchable tiles
  // we need to do this because jokers/offsets could reify into a tile
  //   that we can't otherwise encode, since it's not in hand
  let mut base_tiles: HashSet<ElixirTile> = match_info.relevant_tiles
    .iter()
    .flat_map(|base_tile| decode_tile(*base_tile, match_info.all_attrs))
    .flat_map(|decoded_tile| apply_offsets(&decoded_tile, &gather_rev_offsets(&match_definition), match_info.ordering, match_info.ordering_r).0)
    .flatten()
    .map(|tile| strip_attrs(&tile))
    .filter(|tile| !is_any(tile))
    .collect();

  for tile in &decode_tiles(&match_info.joker_tiles, match_info.all_attrs) { base_tiles.remove(&strip_attrs(&tile)); }

  base_tiles
}
