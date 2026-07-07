mod n_rooks;
mod types;
use std::collections::HashSet;

use rustler::{Encoder, Env, Term};
use types::{Prime, Tile, Aliases, Mask, RowIndex, TileSet};
rustler::atoms! { ok }

#[rustler::nif]
fn solve_n_rooks<'a>(env: Env<'a>, masks: Vec<(Mask, RowIndex)>, col_mask: Mask, num_rooks: RowIndex) -> Term<'a> {
  match n_rooks::solve_n_rooks(&masks, col_mask, num_rooks) {
    Some(ret) => (ok(), ret).encode(env),
    None => rustler::types::atom::nil().encode(env),
  }
}

#[rustler::nif]
fn solve_n_rooks_exhaustive<'a>(env: Env<'a>, masks: Vec<(Mask, RowIndex)>, col_mask: Mask, num_rooks: RowIndex) -> Term<'a> {
  let solutions = n_rooks::solve_n_rooks_exhaustive(&masks, col_mask, num_rooks);
  (ok(), solutions).encode(env)
}

// #[rustler::nif]
// fn remove_indices<'a>(xs: Vec<Term<'a>>, is: Vec<usize>) -> Vec<Term<'a>> {
//   _remove_indices(xs, &is)
// }
fn _remove_indices<T>(mut xs: Vec<T>, is: &Vec<usize>) -> Vec<T> {
  let mut is = is.clone();
  is.sort_unstable();

  let mut it = is.into_iter().peekable();
  let mut i: usize = 0;
  xs.retain(|_| {
    let keep = it.peek() != Some(&i);
    if !keep { it.next(); }
    i += 1;
    keep
  });

  xs
}

#[rustler::nif]
fn count_factors_fast(n: Prime, primes: Vec<Prime>) -> usize {
  _count_factors_fast(n, &primes, 0)
}
fn _count_factors_fast(mut n: Prime, primes: &[Prime], mut acc: usize) -> usize {
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

const ANY_PRIME: Prime = 1;

#[inline]
pub fn check_tile_match((p2, battrs2): &Tile, (p1, battrs1): &Tile) -> bool {
  (*p1 == *p2 || *p1 == ANY_PRIME || *p2 == ANY_PRIME) && (*battrs1 & *battrs2 == *battrs1)
}

// #[rustler::nif]
pub fn check_equivalence(l: Tile, r: Tile, encoded_aliases: Aliases) -> bool {
  _check_equivalence(&l, &r, &encoded_aliases)
}
pub fn _check_equivalence(l: &Tile, r: &Tile, encoded_aliases: &Aliases) -> bool {
  if check_tile_match(&l, &r) { true }
  else if let Some(entry) = encoded_aliases.get(&r.0).or_else(|| encoded_aliases.get(&ANY_PRIME)) {
    entry.iter().any(|(battrs, aliases)| {
        (r.1 & *battrs == r.1) && aliases.iter().any(|t| check_tile_match(&l, t))
    })
  } else { false }
}

pub fn compute_attr_masks(l: &Vec<Tile>, r: &Vec<Tile>, encoded_aliases: &Aliases) -> (Vec<(Mask, RowIndex)>, Mask) {
  let mut masks: Vec<(Mask, RowIndex)> = vec![(0,0); l.len()];
  let mut col_mask: Mask = 0;
  for j in 0..l.len() {
    let t = l[j];
    masks[j].1 = j as u8;
    for i in 0..r.len() {
      if _check_equivalence(&t, &r[i], &encoded_aliases) {
        masks[j].0 |= 1 << i;
      }
    }
    col_mask |= masks[j].0;
  }
  (masks, col_mask)
}

#[rustler::nif]
pub fn subtract_check_attrs<'a>(env: Env<'a>, l: Vec<Tile>, r: Vec<Tile>, encoded_aliases: Aliases) -> Term<'a> {
  match _subtract_check_attrs(&l, &r, &encoded_aliases) {
    Some(ret) => (ok(), ret).encode(env),
    None => rustler::types::atom::nil().encode(env),
  }
}
pub fn _subtract_check_attrs(l: &Vec<Tile>, r: &Vec<Tile>, encoded_aliases: &Aliases) -> Option<Vec<RowIndex>> {
  if r.is_empty() { return None; }
  let (masks, col_mask) = compute_attr_masks(l, r, encoded_aliases);
  n_rooks::solve_n_rooks(&masks, col_mask, r.len() as u8)
}

#[rustler::nif]
pub fn subtract_check_attrs_exhaustive<'a>(env: Env<'a>, l: Vec<Tile>, r: Vec<Tile>, encoded_aliases: Aliases) -> Term<'a> {
  match _subtract_check_attrs_exhaustive(&l, &r, &encoded_aliases) {
    Some(ret) => (ok(), ret).encode(env),
    None => rustler::types::atom::nil().encode(env),
  }
}
pub fn _subtract_check_attrs_exhaustive(l: &Vec<Tile>, r: &Vec<Tile>, encoded_aliases: &Aliases) -> Option<Vec<Vec<RowIndex>>> {
  if r.is_empty() { return None; }
  let (masks, col_mask) = compute_attr_masks(l, r, encoded_aliases);
  let ret = n_rooks::solve_n_rooks_exhaustive(&masks, col_mask, r.len() as u8);
  if ret.is_empty() { None }
  else { Some(ret) }
}

pub fn remove_tileset_indices(
  mut hand: TileSet, ixs: &Vec<usize>, encoded_joker_tiles: HashSet<Tile>
) -> () {
  let mut divisor = 1;
  for i in ixs {
    let tile = hand.attrs[*i];
    if !encoded_joker_tiles.contains(&tile) && tile.0 != ANY_PRIME {
      divisor *= tile.0
    }
  }
  let (q, r) = (hand.hash / divisor, hand.hash % divisor);
  if r != 0 {
    eprintln!("remove_tileset_indices: tried to divide {0} by {divisor}, hand was {hand:?}", hand.hash);
  }
  hand.hash = q;
  hand.attrs = _remove_indices(hand.attrs, &ixs);
}


  // # def subtract_rust(_hash2, _hash1, _attrs2, _attrs1), do: :erlang.nif_error(:nif_not_loaded)
  // defp _subtract(%{hash: hash2, attrs: attrs2} = hand,
  //                %{hash: hash1, attrs: attrs1, nojoker: nojoker} = _group,
  //                tile_behavior,
  //                opts) do
  //   # debug = Keyword.get(opts, :debug, false)
  //   return_indices = Keyword.get(opts, :return_indices, false)
  //   exhaustive = Keyword.get(opts, :exhaustive, false)
  //   hash1 = if nojoker do
  //     Enum.reduce(attrs1, 1, fn {p, _}, acc -> p * acc end)
  //   else hash1 end
  //   encoded_aliases = if nojoker do %{} else Map.get(tile_behavior, :encoded_aliases, %{}) end
  //   encoded_joker_tiles = if nojoker do %{} else Map.get(tile_behavior, :encoded_joker_tiles, %{}) end

  //   # put all jokers at the end, so for non-exhaustive searches we guarantee choosing jokers last
  //   {jokers, nonjokers} = Enum.split_with(attrs2, & &1 in encoded_joker_tiles)
  //   attrs2 = nonjokers ++ jokers
  //   hand = %{hand | attrs: attrs2}

  //   gcd = Integer.gcd(hash2, hash1)

  //   # dbg = decode(group, tile_behavior) == [:any]
  //   # if dbg do
  //   #   IO.inspect({"asdf", hand, group, jokers, gcd, exhaustive})
  //   #   IO.inspect({"asdf", decode(hand, tile_behavior), decode(group, tile_behavior), exhaustive})
  //   #   IO.inspect({"asdfs", length(jokers), length(attrs1), count_factors(gcd, Enum.map(attrs1, fn {p, _} -> p end))})
  //   # end
  //   cond do
  //     length(attrs1) > length(attrs2) ->
  //       # can't remove more tiles than we have
  //       nil
  //     length(jokers) < Enum.count(attrs1, fn {p, _} -> p != @any_prime end) - count_factors(gcd, Enum.map(attrs1, fn {p, _} -> p end)) ->
  //       # not enough jokers to match unmatched tiles
  //       nil
  //     true ->
  //       # if nojoker, try to divide the jokers' primes with the unmatched remainder
  //       gcd = if nojoker do
  //         remainder = Integer.floor_div(hash1, gcd)
  //         hash3 = Enum.reduce(jokers, 1, fn {p, _}, acc -> p * acc end)
  //         gcd * Integer.gcd(hash3, remainder)
  //       else gcd end 
  //       divides = gcd == hash1

  //       # if divides, no need to use jokers
  //       # otherwise, use jokers, but if not exhaustive, prioritize nonjokers-only if possible
  //       encoded_aliases = if divides do %{} else encoded_aliases end

  //       ret = if not exhaustive do
  //         with {:ok, indices} <- subtract_check_attrs(nonjokers, attrs1, %{}) do
  //           if return_indices do indices else
  //             remove_tileset_indices(hand, indices, encoded_joker_tiles)
  //           end
  //         end
  //       else nil end

  //       cond do
  //         ret != nil -> ret
  //         exhaustive ->
  //           with {:ok, indices} <- subtract_check_attrs_exhaustive(attrs2, attrs1, encoded_aliases) do
  //             if return_indices do indices else
  //               for ixs <- indices do remove_tileset_indices(hand, ixs, encoded_joker_tiles) end
  //               |> Enum.uniq()
  //             end
  //           end
  //         true ->
  //           with {:ok, indices} <- subtract_check_attrs_exhaustive(attrs2, attrs1, encoded_aliases) do
  //             if return_indices do indices else
  //               remove_tileset_indices(hand, indices, encoded_joker_tiles)
  //             end
  //           end
  //       end
  //   end
  // end

rustler::init!("Elixir.RiichiAdvanced.Match");
