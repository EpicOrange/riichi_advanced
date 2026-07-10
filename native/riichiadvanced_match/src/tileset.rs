use std::collections::{HashMap, HashSet};
use num::integer;
use rustler::{Encoder, Env, Term};
use crate::n_rooks;
use crate::types::{ANY_PRIME, Aliases, Hash, Mask, RowIndex, Tile, TileSet};

// #[rustler::nif]
// fn remove_indices<'a>(xs: Vec<Term<'a>>, is: Vec<RowIndex>) -> Vec<Term<'a>> {
//   let mut xs = xs;
//   _remove_indices(&mut xs, &is);
//   xs
// }
pub fn _remove_indices<T>(xs: &mut Vec<T>, is: &Vec<RowIndex>) -> () {
  let mut is = is.clone();
  is.sort_unstable();

  let mut it = is.into_iter().peekable();
  let mut i: u8 = 0;
  xs.retain(|_| {
    let keep = it.peek() != Some(&i);
    if !keep { it.next(); }
    i += 1;
    keep
  });
}

#[rustler::nif]
fn count_factors_fast(n: Hash, primes: Vec<Hash>) -> usize {
  _count_factors_fast(n, &primes, 0)
}
pub fn _count_factors_fast<'a>(mut n: Hash, primes: impl IntoIterator<Item = &'a Hash>, mut acc: usize) -> usize {
  if n == 1 { return acc; }
  if n == 0 {
    eprintln!("count_factors_fast: somehow tried to get the prime decomposition of 0");
    return acc;
  }
  for &p in primes {
    if p == 0 {
      eprintln!("count_factors_fast: somehow tried to divide by 0");
      return acc;
    }
    loop {
      let (q, r) = (n / p, n % p);
      if r != 0 { break; }
      n = q;
      acc += 1;
      if n == 1 { return acc; }
    }
  }
  acc + 1
}

#[inline]
pub fn check_tile_match((p2, battrs2): &Tile, (p1, battrs1): &Tile) -> bool {
  (*p1 == *p2 || *p1 == ANY_PRIME || *p2 == ANY_PRIME) && (*battrs1 & *battrs2 == *battrs1)
}

// // #[rustler::nif]
// pub fn check_equivalence(l: Tile, r: Tile, aliases: Aliases) -> bool {
//   _check_equivalence(&l, &r, &aliases)
// }
pub fn _check_equivalence(l: &Tile, r: &Tile, aliases: &Aliases) -> bool {
  if check_tile_match(&l, &r) { return true; }
  if let Some(entries) = aliases.get(&r.0) {
    if entries.iter().any(|(battrs, aliases)| {
        (r.1 & *battrs == r.1) && aliases.iter().any(|t| check_tile_match(&l, t))
    }) { return true; }}
  if let Some(entries) = aliases.get(&ANY_PRIME) {
    if entries.iter().any(|(battrs, aliases)| {
        (r.1 & *battrs == r.1) && aliases.iter().any(|t| check_tile_match(&l, t))
    }) { return true; }}
  false
}

pub fn compute_attr_masks(l: &[Tile], r: &[Tile], aliases: &Aliases) -> (Vec<(Mask, RowIndex)>, Mask) {
  let mut masks: Vec<(Mask, RowIndex)> = vec![(0,0); l.len()];
  let mut col_mask: Mask = 0;
  for j in 0..l.len() {
    let t = l[j];
    masks[j].1 = j as u8;
    for i in 0..r.len() {
      if _check_equivalence(&t, &r[i], &aliases) {
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
    Some(ret) => (rustler::types::atom::ok(), ret).encode(env),
    None => rustler::types::atom::nil().encode(env),
  }
}
pub fn _subtract_check_attrs(l: &[Tile], r: &[Tile], aliases: &Aliases) -> Option<Vec<RowIndex>> {
  if l.is_empty() { return None; }
  if r.is_empty() { return Some(vec!()); }
  let (masks, col_mask) = compute_attr_masks(l, r, aliases);
  n_rooks::_solve_n_rooks(&masks, col_mask, r.len() as u8)
}

#[rustler::nif]
pub fn subtract_check_attrs_exhaustive<'a>(env: Env<'a>, l: Vec<Tile>, r: Vec<Tile>, aliases: Aliases) -> Term<'a> {
  match _subtract_check_attrs_exhaustive(&l, &r, &aliases) {
    Some(ret) => (rustler::types::atom::ok(), ret).encode(env),
    None => rustler::types::atom::nil().encode(env),
  }
}
pub fn _subtract_check_attrs_exhaustive(l: &Vec<Tile>, r: &Vec<Tile>, aliases: &Aliases) -> Option<Vec<Vec<RowIndex>>> {
  if l.is_empty() { return None; }
  if r.is_empty() { return Some(vec!()); }
  let (masks, col_mask) = compute_attr_masks(l, r, aliases);
  let ret = n_rooks::_solve_n_rooks_exhaustive(&masks, col_mask, r.len() as u8);
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


pub fn remove_tileset_indices(
  hand: &mut TileSet, ixs: &[RowIndex], joker_tiles: &HashSet<Tile>
) -> () {
  let mut divisor = 1;
  for i in ixs {
    let tile = hand.attrs[*i as usize];
    if !joker_tiles.contains(&tile) && tile.0 != ANY_PRIME {
      divisor *= tile.0
    }
  }
  let (q, r) = (hand.hash / divisor, hand.hash % divisor);
  if r != 0 {
    eprintln!("remove_tileset_indices: tried to divide {0} by {divisor}, hand was {hand:?} with jokers {1:?}", hand.hash, joker_tiles.iter().collect::<Vec<_>>());
  }
  hand.hash = q;
  _remove_indices(&mut hand.attrs, &ixs.to_vec());
}

// modifies attrs to put joker tiles at the end
// returns index of first joker, which is equal to the number of nonjokers
// also returns product of all jokers' primes
pub fn move_jokers_to_end(attrs: &mut Vec<Tile>, joker_tiles: &HashSet<Tile>) -> (usize, Hash) {
  let hand_len = attrs.len();
  let mut i = 0;
  let mut j = hand_len - 1;
  let mut joker_hash = 1;
  while i < j {
    let i_is_joker = joker_tiles.contains(&attrs[i]);
    let j_is_nonjoker = !joker_tiles.contains(&attrs[j]);
    if i_is_joker { joker_hash *= &attrs[i].0; }
    if !j_is_nonjoker { joker_hash *= &attrs[j].0; }
    if i_is_joker && j_is_nonjoker {
      attrs.swap(i, j);
      i += 1;
      j -= 1;
    } else {
      // TODO use while instead, to avoid repeated contains calls above
      if !i_is_joker { i += 1 }
      if !j_is_nonjoker { j -= 1 }
    }
  }
  if i == j && joker_tiles.contains(&attrs[i]) {
    joker_hash *= &attrs[i].0;
  }
  (i, joker_hash)
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
  let nojoker = &group.nojoker;
  let hand_hash: Hash = hand.hash;
  let mut group_hash: Hash = group.hash.clone();
  if *nojoker {
    group_hash = 1;
    for (p, _) in &group.attrs {
      group_hash *= p;
    }
  }
  let mut hand_attrs = hand.attrs.clone();
  let group_attrs = &group.attrs;

  let empty_aliases: Aliases = HashMap::new();
  let aliases = if *nojoker { &empty_aliases } else { aliases }; 

  // put all jokers at the end, so for non-exhaustive searches we guarantee choosing jokers last
  
  let (num_nonjokers, joker_hash) = move_jokers_to_end(&mut hand_attrs, joker_tiles);
  let num_jokers = hand_attrs.len() - num_nonjokers;

  let mut gcd = integer::gcd(hand_hash, group_hash);
  let num_group_tiles = group_attrs.iter().filter(|(p, _)| *p != ANY_PRIME).count();
  let group_primes: Vec<Hash> = group_attrs.iter().map(|(p, _)| *p).collect();
  let num_matching_tiles = _count_factors_fast(gcd, &group_primes, 0);
  if num_jokers < num_group_tiles - num_matching_tiles {
    // not enough jokers to match remaining unmatched tiles
    return None;
  }

  // if nojoker, try to divide the jokers' primes with the unmatched remainder
  if *nojoker {
    let unmatched = group_hash / gcd;
    gcd *= integer::gcd(joker_hash, unmatched)
  }
  let divides = gcd == group_hash;

  // if divides, no need to use jokers
  // otherwise, use jokers, but if not exhaustive, prioritize nonjokers-only if possible
  let aliases = if divides { &empty_aliases } else { aliases };

  match _subtract_check_attrs(&hand_attrs[0..num_nonjokers], &group_attrs, &empty_aliases) {
    Some(indices) => {
      let mut hand = TileSet{
        hash: hand.hash,
        attrs: hand_attrs,
        name: None,
        nojoker: false
      };
      remove_tileset_indices(&mut hand, &indices, joker_tiles);
      Some(hand)
    },
    None => match _subtract_check_attrs(&hand_attrs, &group_attrs, aliases) {
      Some(indices) => {
        let mut hand = TileSet{
          hash: hand.hash,
          attrs: hand_attrs,
          name: None,
          nojoker: false
        };
        remove_tileset_indices(&mut hand, &indices, joker_tiles);
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
  let nojoker = &group.nojoker;
  let hand_hash: Hash = hand.hash;
  let mut group_hash: Hash = group.hash.clone();
  if *nojoker {
    group_hash = 1;
    for (p, _) in &group.attrs {
      group_hash *= p;
    }
  }
  let mut hand_attrs = hand.attrs.clone();
  let group_attrs = &group.attrs;

  let empty_aliases: Aliases = HashMap::new();
  let aliases = if *nojoker { &empty_aliases } else { aliases }; 

  // put all jokers at the end, so for non-exhaustive searches we guarantee choosing jokers last
  
  let (num_nonjokers, joker_hash) = move_jokers_to_end(&mut hand_attrs, joker_tiles);
  let num_jokers = hand_attrs.len() - num_nonjokers;

  let mut gcd = integer::gcd(hand_hash, group_hash);
  let num_group_tiles = group_attrs.iter().filter(|(p, _)| *p != ANY_PRIME).count();
  let group_primes: Vec<Hash> = group_attrs.iter().map(|(p, _)| *p).collect();
  let num_matching_tiles = _count_factors_fast(gcd, &group_primes, 0);
  if num_jokers < num_group_tiles - num_matching_tiles {
    // not enough jokers to match remaining unmatched tiles
    return None;
  }

  // if nojoker, try to divide the jokers' primes with the unmatched remainder
  if *nojoker {
    let unmatched = group_hash / gcd;
    gcd *= integer::gcd(joker_hash, unmatched)
  }
  let divides = gcd == group_hash;

  // if divides, no need to use jokers
  // otherwise, use jokers, but if not exhaustive, prioritize nonjokers-only if possible
  let aliases = if divides { &empty_aliases } else { aliases };

  match _subtract_check_attrs_exhaustive(&hand_attrs, &group_attrs, aliases) {
    Some(indicess) => {
      let mut hands = vec!();
      for indices in indicess {
        let mut hand = TileSet{
          hash: hand.hash,
          attrs: hand_attrs.clone(),
          name: None,
          nojoker: false
        };
        remove_tileset_indices(&mut hand, &indices, joker_tiles);
        hands.push(hand);
      }
      // |> Enum.uniq()
      Some(hands)
    },
    None => None,
  }
}
