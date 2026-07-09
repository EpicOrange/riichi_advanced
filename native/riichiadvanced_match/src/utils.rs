use rustler::Atom;

use crate::types::ElixirTile;

pub fn get_tile_atom(tile: &ElixirTile) -> &Atom {
   match tile {
    ElixirTile::AtomTile(atom) => atom,
    ElixirTile::AttrTile(atom, _attrs) => atom,
  }
}
pub fn get_tile_atom_mut(tile: &mut ElixirTile) -> &mut Atom {
   match tile {
    ElixirTile::AtomTile(atom) => atom,
    ElixirTile::AttrTile(atom, _attrs) => atom,
  }
}
pub fn strip_attrs(tile: &ElixirTile) -> ElixirTile {
   match tile {
    ElixirTile::AtomTile(_atom) => tile.clone(),
    ElixirTile::AttrTile(atom, _attrs) => ElixirTile::AtomTile(*atom),
  }
}
