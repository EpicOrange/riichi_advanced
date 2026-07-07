use std::collections::{HashMap, HashSet};
use crate::types::{AliasEntry, Aliases, BitAttrs, ElixirAliases, ElixirHand, ElixirTile, Tile, TileSet};
use crate::primes::{from_prime, to_prime};

rustler::atoms! { ok }

pub fn encode_attrs(attrs: &mut [String], all_attrs: &[String]) -> BitAttrs {
  attrs.sort_unstable();
  let mut ret: BitAttrs = 0;
  let mut add: BitAttrs = 1;
  let mut it1 = attrs.iter().peekable();
  let mut it2 = all_attrs.iter().peekable();
  loop {
    match (it1.peek(), it2.peek()) {
      // no match
      (Some(l), Some(r)) if l < r => { it1.next(); }
      (Some(l), Some(r)) if l > r => { add *= 2; it2.next(); }
      // match
      (Some(_), Some(_)) => {
        ret += add;
        add *= 2;
        it1.next();
        it2.next();
      }
      _ => break, // out of attrs (on either side)
    }
  }
  ret
}

pub fn encode(hand: &ElixirHand, all_attrs: &[String], encoded_joker_tiles: &HashSet<&Tile>) -> TileSet {
  let mut attrs = vec!();
  let mut hash = 1;
  for tile in hand {
    match tile {
      ElixirTile::AtomTile(atom) => {
        if let Some(prime) = to_prime(atom) {
          let encoded = (*prime, 0);
          if !encoded_joker_tiles.contains(&encoded) { hash *= prime; }
          attrs.push(encoded)
        }
      }
      ElixirTile::AttrTile(atom, tile_attrs) => {
        if let Some(prime) = to_prime(atom) {
          let encoded = (*prime, encode_attrs(&mut tile_attrs.clone(), all_attrs));
          if !encoded_joker_tiles.contains(&encoded) { hash *= prime; }
          attrs.push(encoded)
        }
      }
    }
  }
  TileSet{ hash, attrs, name: None, nojoker: false }
}

pub fn encode_aliases(
    aliases: &ElixirAliases, all_attrs: &[String], encoded_joker_tiles: &HashSet<&Tile>
) -> Aliases {
  let mut ret: Aliases = HashMap::new();
  for (tile, attrs_aliases) in aliases {
    if let Some(prime) = to_prime(tile) {
      let mut entry: AliasEntry = HashMap::new();
      for (attrs, aliases) in attrs_aliases {
        let encoded_attrs = encode_attrs(&mut attrs.clone(), all_attrs);
        let mut encoded_aliases = encode(&aliases, all_attrs, encoded_joker_tiles).attrs;
        match entry.get_mut(&encoded_attrs) {
          Some(existing_aliases) => { existing_aliases.append(&mut encoded_aliases); }
          None => { entry.insert(encoded_attrs, encoded_aliases); }
        }
      }
      ret.insert(*prime, entry);
    }
  }
  ret
}

pub fn decode_attrs(attrs: &[Tile], all_attrs: &[String]) -> ElixirHand {
  let mut ret = vec!();
  for (p, battrs) in attrs {
    if let Some(tile) = from_prime(&p) {
      let mut battrs = *battrs;
      let mut ret_attrs = vec!();
      for attr in all_attrs {
        if battrs & 1 == 1 { ret_attrs.push(attr.clone()); }
        battrs >>= 1;
        if battrs == 0 { break; }
      }
      ret.push(ElixirTile::AttrTile(*tile, ret_attrs))
    }
  }
  ret
}

pub fn decode(tileset: &TileSet, all_attrs: &[String]) -> ElixirHand {
  decode_attrs(&tileset.attrs, all_attrs)
}
