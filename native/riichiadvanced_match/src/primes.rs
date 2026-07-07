use std::collections::HashMap;
use rustler::Atom;
use crate::tile_table::{TILE_TABLE, ATOM_TABLE};
use crate::types::Hash;
use std::sync::OnceLock;

static TO_PRIME: OnceLock<HashMap<Atom, Hash>> = OnceLock::new();
static FROM_PRIME: OnceLock<HashMap<Hash, Atom>> = OnceLock::new();

pub fn to_prime(attr: &Atom) -> Option<&'static Hash> {
  let to_prime_table = TO_PRIME.get_or_init(|| {
    TILE_TABLE.entries().map(|(&s, &value)| {
      (ATOM_TABLE.get(s).unwrap()(), value)
    }).collect()
  });
  to_prime_table.get(attr)
}
pub fn from_prime(prime: &Hash) -> Option<&'static Atom> {
  let from_prime_table = FROM_PRIME.get_or_init(|| {
    TILE_TABLE.entries().map(|(&s, &value)| {
      (value, ATOM_TABLE.get(s).unwrap()())
    }).collect()
  });
  from_prime_table.get(prime)
}





