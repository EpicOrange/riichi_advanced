use std::collections::HashMap;

use rustler::Atom;
use crate::{primes::is_any, types::{ElixirAliases, ElixirTile, IndexVec}};

// precondition: `is` sorted and deduped
#[inline]
pub fn remove_indices<T>(xs: &mut Vec<T>, is: IndexVec) {
  if !is.is_sorted() { panic!("remove_indices: ixs not sorted"); }
  let mut i: u8 = 0;
  let mut it = is.into_iter();
  let mut j = it.next();
  xs.retain(|_| {
    if j == None { return true; }
    let keep = j.unwrap_or(i) != i;
    if !keep { j = it.next(); }
    i += 1;
    keep
  });
}

pub fn get_tile_atom(tile: &ElixirTile) -> &Atom {
  match tile {
    ElixirTile::AtomTile(atom) => atom,
    ElixirTile::AttrTile(atom, _attrs) => atom,
  }
}
// pub fn get_tile_atom_mut(tile: &mut ElixirTile) -> &mut Atom {
//   match tile {
//     ElixirTile::AtomTile(atom) => atom,
//     ElixirTile::AttrTile(atom, _attrs) => atom,
//   }
// }
pub fn get_tile_atom_attrs(tile: &ElixirTile) -> (&Atom, Vec<String>) {
  // this makes a copy of attrs so we can return it owned
  match tile {
    ElixirTile::AtomTile(atom) => (atom, vec!()),
    ElixirTile::AttrTile(atom, attrs) => (atom, attrs.clone()),
  }
}
// pub fn get_tile_atom_attrs_mut(tile: &mut ElixirTile) -> (&mut Atom, Option<&mut Vec<String>>) {
//   match tile {
//     ElixirTile::AtomTile(atom) => (atom, None),
//     ElixirTile::AttrTile(atom, attrs) => (atom, Some(attrs)),
//   }
// }
// pub fn strip_attrs(tile: &ElixirTile) -> ElixirTile {
//   match tile {
//     ElixirTile::AtomTile(_atom) => tile.clone(),
//     ElixirTile::AttrTile(atom, _attrs) => ElixirTile::AtomTile(*atom),
//   }
// }

pub fn add_joker_to_aliases<'a>(
  elixir_aliases: &mut ElixirAliases,
  joker: &ElixirTile,
  tiles: impl IntoIterator<Item = &'a ElixirTile>
) -> () {
  for to in tiles {
    if is_any(to) { continue; }
    let (tile, attrs) = &mut get_tile_atom_attrs(&to);
    for attr in attrs.iter_mut() {
      *attr = attr.trim_start_matches('_').to_owned();
    }
    elixir_aliases.entry(ElixirTile::AtomTile(**tile))
      .and_modify(|attrs_aliases| {
        attrs_aliases.entry(attrs.clone())
          .and_modify(|aliases| aliases.push(joker.clone()))
          .or_insert_with(|| vec!(joker.clone()));
      }).or_insert_with(|| {
        let mut attrs_aliases = HashMap::new();
        attrs_aliases.insert(attrs.clone(), vec!(joker.clone()));
        attrs_aliases
      });
  }
}

pub fn remove_joker_from_aliases<'a>(
  elixir_aliases: &mut ElixirAliases,
  joker: &ElixirTile,
  tiles: impl IntoIterator<Item = &'a ElixirTile>
) -> () {
  for to in tiles {
    let (tile, attrs) = &mut get_tile_atom_attrs(&to);
    for attr in attrs.iter_mut() {
      *attr = attr.trim_start_matches('_').to_owned();
    }
    if let Some(attrs_aliases) = elixir_aliases.get_mut(&ElixirTile::AtomTile(**tile)) {
      if let Some(aliases) = attrs_aliases.get_mut(attrs) {
        if let Some(i) = aliases.iter().position(|t| *t == *joker) {
          aliases.swap_remove(i);
        }
      }
    }
  }
}
