use std::collections::{HashMap, HashSet, VecDeque};
use rustler::Atom;

use crate::encode::encode;
use crate::tile_table::*;
use crate::types::{ElixirTile, MatchGroup, MatchOffset, RemovableGroup, Tile, TileSet};
use crate::primes::{is_any, is_jihai, is_manzu, is_pinzu, is_souzu, shift_suit_mut, to_prime};
use crate::utils::{get_tile_atom_mut, strip_attrs};

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
    l: &mut isize,
    r: &mut isize,
    target: isize,
    ordering: &HashMap<Atom, Atom>,
    ordering_r: &HashMap<Atom, Atom>
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

fn add_attrs_mut(tile: &mut ElixirTile, mut attrs: &mut Vec<String>) -> () {
  match tile {
    ElixirTile::AtomTile(atom) => {
      *tile = ElixirTile::AttrTile(*atom, attrs.clone());
    }
    ElixirTile::AttrTile(_atom, attrs2) => {
      attrs2.append(&mut attrs);
    }
  }
}

// fixed offsets, for amerijong
pub static FIXED_OFFSETS: phf::Map<&'static str, fn() -> Atom> = phf::phf_map! {
  "1A"  => tile1m,
  "2A"  => tile2m,
  "3A"  => tile3m,
  "4A"  => tile4m,
  "5A"  => tile5m,
  "6A"  => tile6m,
  "7A"  => tile7m,
  "8A"  => tile8m,
  "9A"  => tile9m,
  "10A" => tile10m,
  "DA"  => tile7z,
  "1B"  => tile1p,
  "2B"  => tile2p,
  "3B"  => tile3p,
  "4B"  => tile4p,
  "5B"  => tile5p,
  "6B"  => tile6p,
  "7B"  => tile7p,
  "8B"  => tile8p,
  "9B"  => tile9p,
  "10B" => tile10p,
  "DB"  => tile0z,
  "1C"  => tile1s,
  "2C"  => tile2s,
  "3C"  => tile3s,
  "4C"  => tile4s,
  "5C"  => tile5s,
  "6C"  => tile6s,
  "7C"  => tile7s,
  "8C"  => tile8s,
  "9C"  => tile9s,
  "10C" => tile10s,
  "DC"  => tile6z,
};

fn apply_fixed_offset(base_tile: &ElixirTile, fixed_offset: &String) -> Option<ElixirTile> {
  FIXED_OFFSETS.get(fixed_offset).and_then(|atom| {
    let mut ret = ElixirTile::AtomTile(atom());
    if is_jihai(&ret) {
      // modify the return tile based on base tile's suit
      let atom = get_tile_atom_mut(&mut ret);
      if let Some(prime) = to_prime(atom) {
        if TILE_TABLE["0z"] == *prime { 
          if is_pinzu(&base_tile) { *atom = ATOM_TABLE.get("6z").unwrap()(); }
          else if is_souzu(&base_tile) { *atom = ATOM_TABLE.get("7z").unwrap()(); }
        } else if TILE_TABLE["6z"] == *prime { 
          if is_pinzu(&base_tile) { *atom = ATOM_TABLE.get("7z").unwrap()(); }
          else if is_souzu(&base_tile) { *atom = ATOM_TABLE.get("0z").unwrap()(); }
        } else if TILE_TABLE["7z"] == *prime { 
          if is_pinzu(&base_tile) { *atom = ATOM_TABLE.get("0z").unwrap()(); }
          else if is_souzu(&base_tile) { *atom = ATOM_TABLE.get("6z").unwrap()(); }
        } else { return None; }
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

fn apply_offsets(
    base_tile: ElixirTile,
    offsets: &Vec<MatchOffset>,
    ordering: &HashMap<Atom, Atom>,
    ordering_r: &HashMap<Atom, Atom>,
) -> Option<Vec<ElixirTile>> { // TODO return an iterator!!
  let mut q = VecDeque::from([base_tile]); // get offset o via q.get(o-l as usize)
  let mut l = 0;
  let mut r = 0;
  let mut offsets = offsets.clone();
  offsets.iter_mut().map(|offset| {
    match offset {
      MatchOffset::Offset(o) => {
        fetch_offset(&mut q, &mut l, &mut r, *o, ordering, ordering_r)
      }
      MatchOffset::AttrsTile(map) => {
        match ATOM_TABLE.get(&map.tile) {
          Some(atom_fn) => Some(ElixirTile::AttrTile(atom_fn(), map.attrs.clone())),
          None => None,
        }
      }
      MatchOffset::AttrsOffset(map) => {
        fetch_offset(&mut q, &mut l, &mut r, map.offset, ordering, ordering_r)
          .map(|mut tile| { add_attrs_mut(&mut tile, &mut map.attrs); tile })
      }
      // MatchOffset::TileOrKeyword("nojoker") => {
      MatchOffset::TileOrKeyword(s) => {
        match ATOM_TABLE.get(s) {
          Some(atom_fn) => Some(ElixirTile::AtomTile(atom_fn())), // it's a tile
          None => apply_fixed_offset(q.get(-l as usize).unwrap(), s), // it's a fixed offset
          // if it's actually a keyword, ignore it, we process it at toplevel
        }
      }
    }
  }).collect()
}

fn generate_groups_from_offsets<'a>(
    offsets: &Vec<MatchOffset>,
    base_tiles: &[ElixirTile], all_attrs: &[String],
    encoded_joker_tiles: &HashSet<&Tile>,
    ordering: &HashMap<Atom, Atom>, ordering_r: &HashMap<Atom, Atom>
) -> Vec<RemovableGroup<'a>> {
  base_tiles.iter().map(|base_tile| {
    apply_offsets(base_tile.clone(), offsets, ordering, ordering_r)
      .map(|tiles| RemovableGroup::Group(encode(&tiles, all_attrs, encoded_joker_tiles)))
  }).flatten().collect::<Vec<_>>()
}

#[rustler::nif]
fn _generate_groups<'a>(
    group: MatchGroup,
    base_tiles: Vec<ElixirTile>, all_tiles: Vec<ElixirTile>, all_attrs: Vec<String>,
    encoded_joker_tiles: Vec<Tile>,
    ordering: HashMap<Atom, Atom>, ordering_r: HashMap<Atom, Atom>
) -> Vec<RemovableGroup<'a>> {
  __generate_groups(&group, &base_tiles, &all_tiles.iter().collect(), &all_attrs, &encoded_joker_tiles.iter().collect(), &ordering, &ordering_r)
}
fn __generate_groups<'a>(
    group: &MatchGroup,
    base_tiles: &[ElixirTile], all_tiles: &HashSet<&ElixirTile>, all_attrs: &[String],
    encoded_joker_tiles: &HashSet<&Tile>,
    ordering: &HashMap<Atom, Atom>, ordering_r: &HashMap<Atom, Atom>
) -> Vec<RemovableGroup<'a>> {
  let mut ret = match group {
    // special case group-level keywords, which could be call names
    MatchGroup::Offset(MatchOffset::TileOrKeyword(s)) => {
      // first check if it's a tile name or fixed offset,
      match ATOM_TABLE.get(s).or_else(|| FIXED_OFFSETS.get(s)) {
        // in which case we do the same as for MatchGroup::Offset
        Some(_) => generate_groups_from_offsets(&vec!(MatchOffset::TileOrKeyword(s.clone())), base_tiles, all_attrs, encoded_joker_tiles, ordering, ordering_r),
        // otherwise, return as call name
        None => vec!(RemovableGroup::CallName(s.clone())),
      }
    }
    MatchGroup::Offset(offset) => generate_groups_from_offsets(&vec!(offset.clone()), base_tiles, all_attrs, encoded_joker_tiles, ordering, ordering_r),
    MatchGroup::Offsets(offsets) => generate_groups_from_offsets(offsets, base_tiles, all_attrs, encoded_joker_tiles, ordering, ordering_r),
    MatchGroup::Subgroups(subgroupings) => {
      base_tiles.iter().map(|base_tile| {
        // make a subgroup from this base tile
        // it should be a Some(vec of tilesets),
        subgroupings.iter().map(|subgroup| {
          apply_offsets(base_tile.clone(), subgroup, ordering, ordering_r)
            .filter(|tiles| tiles.iter().all(|tile| all_tiles.contains(&strip_attrs(tile)) || is_any(tile)))
            .map(|tiles| encode(&tiles, all_attrs, encoded_joker_tiles))
        }).collect::<Option<Vec<TileSet>>>()
      })
      // should be an iterator of Option<Vec<TileSet>>
      // discard all the Nones, wrap with Multigroup, and collect into a Vec
      .flatten()
      .map(|subgroups| RemovableGroup::Multigroup(subgroups))
      .collect::<Vec<RemovableGroup>>()
    }
  };
  ret.dedup();
  ret
}
