use std::collections::{HashMap, HashSet};
use std::sync::OnceLock;
use rustler::Atom;

use crate::tile_table::{TILE_TABLE, ATOM_TABLE};
use crate::types::{ANY_PRIME, ElixirTile, Prime, Tile, TileOrdering};
use crate::utils::{get_tile_atom};

static TO_PRIME: OnceLock<HashMap<Atom, Prime>> = OnceLock::new();
static FROM_PRIME: OnceLock<HashMap<Prime, Atom>> = OnceLock::new();
static MANZU_PRIMES: OnceLock<HashSet<Prime>> = OnceLock::new();
static SOUZU_PRIMES: OnceLock<HashSet<Prime>> = OnceLock::new();
static PINZU_PRIMES: OnceLock<HashSet<Prime>> = OnceLock::new();
static JIHAI_PRIMES: OnceLock<HashSet<Prime>> = OnceLock::new();
static SHIFT_SUIT: OnceLock<TileOrdering> = OnceLock::new();

pub fn to_prime(atom: &Atom) -> Option<Prime> {
  let to_prime_table = TO_PRIME.get_or_init(|| {
    TILE_TABLE.entries().map(|(&s, &value)| {
      (ATOM_TABLE.get(s).unwrap()(), value)
    }).collect()
  });
  to_prime_table.get(atom).copied()
}
pub fn from_prime(prime: &Prime) -> Option<&'static Atom> {
  let from_prime_table = FROM_PRIME.get_or_init(|| {
    TILE_TABLE.entries().map(|(&s, &value)| {
      (value, ATOM_TABLE.get(s).unwrap()())
    }).collect()
  });
  from_prime_table.get(prime)
}

pub fn is_manzu(tile: &Tile) -> bool {
  let manzu_primes_table = MANZU_PRIMES.get_or_init(|| {
    TILE_TABLE.entries()
      .filter_map(|(&s, &prime)| if s.ends_with('m') { Some(prime) } else { None })
      .collect()
  });
  manzu_primes_table.contains(&tile.0)
}
pub fn is_pinzu(tile: &Tile) -> bool {
  let pinzu_primes_table = PINZU_PRIMES.get_or_init(|| {
    TILE_TABLE.entries()
      .filter_map(|(&s, &prime)| if s.ends_with('p') { Some(prime) } else { None })
      .collect()
  });
  pinzu_primes_table.contains(&tile.0)
}
pub fn is_souzu(tile: &Tile) -> bool {
  let souzu_primes_table = SOUZU_PRIMES.get_or_init(|| {
    TILE_TABLE.entries()
      .filter_map(|(&s, &prime)| if s.ends_with('s') { Some(prime) } else { None })
      .collect()
  });
  souzu_primes_table.contains(&tile.0)
}
pub fn is_jihai(tile: &Tile) -> bool {
  let jihau_primes_table = JIHAI_PRIMES.get_or_init(|| {
    TILE_TABLE.entries()
      .filter_map(|(&s, &prime)| if s.ends_with('z') { Some(prime) } else { None })
      .collect()
  });
  jihau_primes_table.contains(&tile.0)
}
pub fn is_any(tile: &ElixirTile) -> bool {
  match to_prime(get_tile_atom(tile)) {
    Some(prime) => prime == ANY_PRIME,
    None => false,
  }
}

// pub fn shift_suit(tile: &ElixirTile) -> Option<ElixirTile> {
//   let shift_suit_table = SHIFT_SUIT.get_or_init(|| {
//     ATOM_TABLE.entries()
//       .map(|(&s, &atom)| {
//         let mut s2 = s.to_string();
//         match s2.pop() {
//           Some('m') => s2.push('p'),
//           Some('p') => s2.push('s'),
//           Some('s') => s2.push('m'),
//           _         => ()
//         }
//         match ATOM_TABLE.get(s2.as_str()) {
//           Some(atom2) => Some((atom(), atom2())),
//           None => None
//         }
//       }).flatten().collect()
//   });
//   match tile {
//     ElixirTile::AtomTile(_) => {
//       match shift_suit_table.get(get_tile_atom(tile)) {
//         Some(t) => Some(ElixirTile::AtomTile(*t)),
//         None    => None,
//       }
//     },
//     ElixirTile::AttrTile(_, attrs) => {
//       match shift_suit_table.get(get_tile_atom(tile)) {
//         Some(t) => Some(ElixirTile::AttrTile(*t, attrs.clone())),
//         None    => None,
//       }
//     }
//   }
// }

// returns false if failed to shift
pub fn shift_suit_mut(tile: &mut Tile) -> bool {
  let shift_suit_table = SHIFT_SUIT.get_or_init(|| {
    ATOM_TABLE.entries()
      .map(|(&s, &atom)| {
        let mut s2 = s.to_string();
        match s2.pop() {
          Some('m') => s2.push('p'),
          Some('p') => s2.push('s'),
          Some('s') => s2.push('m'),
          _         => ()
        }
        match ATOM_TABLE.get(s2.as_str()) {
          Some(atom2) => to_prime(&atom()).zip(to_prime(&atom2())),
          None => None
        }
      }).flatten().collect()
  });
  match shift_suit_table.get(&tile.0) {
    Some(t) => {tile.0 = *t; true},
    None    => false,
  }
}





