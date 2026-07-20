use smallvec::smallvec;
use std::collections::{HashMap, HashSet};
use ruint::aliases::U256;
use rustler::{Encoder, Env, Term};
use crate::n_rooks;
use crate::types::{ANY_PRIME, Aliases, Hash, IndexVec, Mask, Prime, RowIndex, Tile, TileSet};
use crate::utils::remove_indices;

#[rustler::nif]
fn count_factors_fast(n: Hash, primes: Vec<Prime>) -> usize {
  _count_factors_fast(n, &primes)
}
pub fn _count_factors_fast<'a>(mut n: Hash, primes: impl IntoIterator<Item = &'a Prime>) -> usize {
  let mut ret = 0;
  if n == Hash(U256::ONE) {
    return ret;
  } else if n == Hash(U256::ZERO) {
    eprintln!("count_factors_fast: somehow tried to get the prime decomposition of 0");
    return ret;
  }
  for &p in primes {
    if p == 0 {
      eprintln!("count_factors_fast: somehow tried to divide by 0");
      return ret;
    }
    loop {
      let (q, r) = (n / p, n % p);
      if r != 0 { break; }
      n = q;
      ret += 1;
      if n == Hash(U256::ONE) { return ret; }
    }
  }
  ret
}

#[inline]
pub fn check_tile_match((p2, battrs2): &Tile, (p1, battrs1): &Tile) -> bool {
  (*p1 == *p2 || *p1 == ANY_PRIME || *p2 == ANY_PRIME) && (*battrs1 & *battrs2 == *battrs1)
}

// // #[rustler::nif]
// pub fn check_equivalence(l: Tile, r: Tile, aliases: Aliases) -> bool {
//   _check_equivalence(&l, &r, &aliases)
// }
// check whether l and r are the same tile and that l has all of r's aliases
// more importantly, checks that for all aliases as well
// you can think of this as checking l > r
pub fn _check_equivalence(l: &Tile, r: &Tile, aliases: &Aliases) -> bool {
  if l == r || check_tile_match(l, r) { return true; }
  if let Some(entries) = aliases.get(&r.0) {
    if entries.iter().any(|(battrs, aliases)| {
        (r.1 & *battrs == r.1) && aliases.iter().any(|t| check_tile_match(l, t))
    }) { return true; }}
  if let Some(entries) = aliases.get(&ANY_PRIME) {
    if entries.iter().any(|(battrs, aliases)| {
        (r.1 & *battrs == r.1) && aliases.iter().any(|t| check_tile_match(l, t))
    }) { return true; }}
  false
}

pub fn compute_attr_masks(ls: &[Tile], rs: &[Tile], aliases: &Aliases) -> (Vec<(Mask, RowIndex)>, Mask) {
  assert!(rs.len() <= Mask::BITS as usize, "mask size too small for given tiles");
  let mut masks: Vec<(Mask, RowIndex)> = vec![(0,0); ls.len()];
  let mut col_mask: Mask = 0;
  for j in 0..ls.len() {
    masks[j].1 = j as u8;
    for (i, r) in rs.iter().enumerate() {
      if _check_equivalence(&ls[j], r, aliases) {
        masks[j].0 |= 1 << i;
      }
    }
    col_mask |= masks[j].0;
  }
  (masks, col_mask)
}

#[rustler::nif]
pub fn subtract_check_attrs<'a>(env: Env<'a>, l: Vec<Tile>, r: Vec<Tile>, aliases: Aliases) -> Term<'a> {
  match _subtract_check_attrs(&l, &r, &aliases) {
    Some(ret) => (rustler::types::atom::ok(), ret.into_iter().collect::<Vec<_>>()).encode(env),
    None => rustler::types::atom::nil().encode(env),
  }
}
pub fn _subtract_check_attrs(l: &[Tile], r: &[Tile], aliases: &Aliases) -> Option<IndexVec> {
  if l.is_empty() { return None; }
  if r.is_empty() { return Some(smallvec!()); }
  let (masks, col_mask) = compute_attr_masks(l, r, aliases);
  n_rooks::_solve_n_rooks(&masks, col_mask, r.len() as u8)
}

#[rustler::nif]
pub fn subtract_check_attrs_exhaustive<'a>(env: Env<'a>, l: Vec<Tile>, r: Vec<Tile>, aliases: Aliases) -> Term<'a> {
  match _subtract_check_attrs_exhaustive(&l, &r, &aliases) {
    Some(ret) => (rustler::types::atom::ok(), ret.into_iter().map(|v| v.to_vec()).collect::<Vec<_>>()).encode(env),
    None => rustler::types::atom::nil().encode(env),
  }
}
pub fn _subtract_check_attrs_exhaustive(ls: &[Tile], rs: &[Tile], aliases: &Aliases) -> Option<Vec<IndexVec>> {
  if ls.is_empty() { return None; }
  if rs.is_empty() { return Some(vec!()); }
  let (masks, col_mask) = compute_attr_masks(ls, rs, aliases);
  let ret = n_rooks::_solve_n_rooks_exhaustive(&masks, col_mask, rs.len() as u8);
  if ret.is_empty() { None }
  else { Some(ret) }
}


  // def subtract_check_attrs_exhaustive([], _attrs1, _encoded_aliases), do: nil
  // def subtract_check_attrs_exhaustive(_attrs2, [], _encoded_aliases), do: {:ok, [[]]}
  // def subtract_check_attrs_exhaustive(attrs2, attrs1, encoded_aliases) do
  //   # compute bitmasks where the ith bitmask has jth bit set iff attrs2[i] covers attrs1[j]}
  //   masks = compute_masks(attrs2, attrs1, encoded_aliases)
  //   |> Enum.with_index()
  //   col_mask = Enum.reduce(masks, 0, fn {mask, _i}, acc -> mask ||| acc end)
  //   # then it's n-rooks on this bit matrix
  //   # returns indices into attrs2
  //   with {:ok, indices} <- solve_n_rooks_exhaustive(masks, col_mask, length(attrs1)) do
  //     cond do
  //       Enum.empty?(indices) -> nil
  //       true -> {:ok, indices}
  //     end
  //   end
  // end

// precondition: `is` sorted and deduped
pub fn remove_tileset_indices(hand: &mut TileSet, ixs: IndexVec, joker_tiles: &HashSet<Tile>) {
  let mut divisor = Hash(U256::ONE);
  for i in &ixs {
    let tile = hand.attrs[*i as usize];
    if !joker_tiles.contains(&tile) && tile.0 != ANY_PRIME {
      divisor *= tile.0
    }
  }
  let (q, r) = (hand.hash / divisor, hand.hash % divisor);
  if r != Hash(U256::ZERO) {
    eprintln!("remove_tileset_indices: tried to divide {0} by {1}, hand was {hand:?} with jokers {2:?}", hand.hash.0, divisor.0, joker_tiles.iter().collect::<Vec<_>>());
  }
  hand.hash = q;
  remove_indices(&mut hand.attrs, ixs);
}

// modifies attrs to put joker tiles at the end
// returns index of first joker, which is equal to the number of nonjokers
// also returns product of all jokers' primes
pub fn move_jokers_to_end(attrs: &mut [Tile], joker_tiles: &HashSet<Tile>) -> (usize, Hash) {
  let hand_len = attrs.len();
  if hand_len == 0 { return (0, Hash(U256::ONE)); }
  let mut i = 0;
  let mut j = hand_len - 1;
  let mut joker_hash = U256::ONE;
  while i < j {
    while i < j && !joker_tiles.contains(&attrs[i]) { i += 1 }
    while i < j && joker_tiles.contains(&attrs[j]) {
      joker_hash *= U256::from(attrs[j].0);
      j -= 1;
    }
    if i < j {
      joker_hash *= U256::from(attrs[i].0);
      attrs.swap(i, j);
      i += 1;
      j -= 1;
    }
  }
  if i == j && joker_tiles.contains(&attrs[i]) {
    joker_hash *= U256::from(attrs[i].0);
  }
  (i, Hash(joker_hash))
}

#[rustler::nif]
pub fn _subtract(
  hand: TileSet, group: TileSet,
  aliases: Aliases, joker_tiles: Vec<Tile>
) -> Option<TileSet> {
  __subtract(&hand, &group, &aliases, &joker_tiles.into_iter().collect())
}
pub fn __subtract(
  hand: &TileSet, group: &TileSet,
  aliases: &Aliases, joker_tiles: &HashSet<Tile>
) -> Option<TileSet> {
  if group.attrs.len() > hand.attrs.len() {
    return None;
  }
  // assume return_indices and exhaustive are both false here
  let nojoker = group.nojoker;
  let hand_hash: Hash = hand.hash;
  let mut group_hash: Hash = group.hash;
  if nojoker {
    group_hash = Hash(U256::ONE);
    for (p, _) in &group.attrs {
      group_hash *= *p;
    }
  }
  let mut hand_attrs = hand.attrs.clone();
  let group_attrs = &group.attrs;

  let empty_aliases: Aliases = HashMap::new();
  let aliases = if nojoker { &empty_aliases } else { aliases }; 

  let mut gcd = Hash::gcd(hand_hash, group_hash);
  let num_group_tiles = group_attrs.iter().filter(|(p, _)| *p != ANY_PRIME).count();
  let group_primes: Vec<Prime> = group_attrs.iter().map(|(p, _)| *p).collect();
  // need to get the product of joker primes
  // put all jokers at the end, so we guarantee choosing jokers last
  let (mut num_nonjokers, joker_hash) = move_jokers_to_end(&mut hand_attrs, joker_tiles);

  if nojoker {
    // if nojoker, include joker tiles themselves in the gcd,
    //   by multiplying by gcd of jokers and unmatched tiles
    // this is because we don't do a second joker processing step
    num_nonjokers = hand_attrs.len();
    let unmatched = group_hash / gcd;
    gcd *= Hash::gcd(joker_hash, unmatched)
  } else {
    let num_jokers = hand_attrs.len() - num_nonjokers;
    let num_matching_tiles = _count_factors_fast(gcd, &group_primes);
    if num_jokers < num_group_tiles - num_matching_tiles {
      // not enough jokers to match remaining unmatched tiles
      return None;
    }
  }
  let divides = gcd == group_hash;

  // if divides, no need to use jokers
  // otherwise, use jokers, but if not exhaustive, prioritize nonjokers-only if possible
  let aliases = if divides { &empty_aliases } else { aliases };

  match _subtract_check_attrs(&hand_attrs[0..num_nonjokers], group_attrs, &empty_aliases) {
    Some(mut indices) => {
      let mut hand = TileSet{
        hash: hand.hash,
        attrs: hand_attrs,
        name: None,
        nojoker: false
      };
      indices.sort_unstable();
      indices.dedup();
      remove_tileset_indices(&mut hand, indices, joker_tiles);
      Some(hand)
    },
    None if nojoker => None,
    None => match _subtract_check_attrs(&hand_attrs, group_attrs, aliases) {
      Some(mut indices) => {
        let mut hand = TileSet{
          hash: hand.hash,
          attrs: hand_attrs,
          name: None,
          nojoker: false
        };
        indices.sort_unstable();
        indices.dedup();
        remove_tileset_indices(&mut hand, indices, joker_tiles);
        Some(hand)
      },
      None => None,
    }
  }
}

#[rustler::nif]
pub fn _subtract_exhaustive(
  hand: TileSet, group: TileSet,
  aliases: Aliases, joker_tiles: Vec<Tile>
) -> Option<Vec<TileSet>> {
  __subtract_exhaustive(&hand, &group, &aliases, &joker_tiles.into_iter().collect())
}
pub fn __subtract_exhaustive(
  hand: &TileSet, group: &TileSet,
  aliases: &Aliases, joker_tiles: &HashSet<Tile>
) -> Option<Vec<TileSet>> {
  if group.attrs.len() > hand.attrs.len() {
    return None;
  }

  // assume return_indices and exhaustive are both false here
  let nojoker = group.nojoker;
  let hand_hash: Hash = hand.hash;
  let mut group_hash: Hash = group.hash;
  if nojoker {
    group_hash = Hash(U256::ONE);
    for (p, _) in &group.attrs {
      group_hash *= *p;
    }
  }
  let mut hand_attrs = hand.attrs.clone();
  let group_attrs = &group.attrs;

  let empty_aliases: Aliases = HashMap::new();
  let aliases = if nojoker { &empty_aliases } else { aliases }; 

  // this is mostly just to calculate num_nonjokers and joker_hash, not sorting jokers to the end
  let (num_nonjokers, joker_hash) = move_jokers_to_end(&mut hand_attrs, joker_tiles);
  let num_jokers = hand_attrs.len() - num_nonjokers;

  let mut gcd = Hash::gcd(hand_hash, group_hash);
  let num_group_tiles = group_attrs.iter().filter(|(p, _)| *p != ANY_PRIME).count();
  let group_primes: Vec<Prime> = group_attrs.iter().map(|(p, _)| *p).collect();
  let num_matching_tiles = _count_factors_fast(gcd, &group_primes);

  // if nojoker, try to divide the jokers' primes with the unmatched remainder
  if nojoker {
    let unmatched = group_hash / gcd;
    gcd *= Hash::gcd(joker_hash, unmatched)
  } else if num_jokers < num_group_tiles - num_matching_tiles {
    // not enough jokers to match remaining unmatched tiles
    return None;
  }
  let divides = gcd == group_hash;

  // if divides, no need to use jokers
  // otherwise, use jokers, but if not exhaustive, prioritize nonjokers-only if possible
  let aliases = if divides { &empty_aliases } else { aliases };

  match _subtract_check_attrs_exhaustive(&hand_attrs, group_attrs, aliases) {
    Some(mut indicess) => {
      indicess.sort_unstable();
      indicess.dedup();
      let mut hands = HashSet::new();
      for mut indices in indicess {
        let mut hand = TileSet{
          hash: hand.hash,
          attrs: hand_attrs.clone(),
          name: None,
          nojoker: false
        };
        indices.sort_unstable();
        indices.dedup();
        remove_tileset_indices(&mut hand, indices, joker_tiles);
        hands.insert(hand);
      }
      Some(hands.into_iter().collect())
    },
    None => None,
  }
}
