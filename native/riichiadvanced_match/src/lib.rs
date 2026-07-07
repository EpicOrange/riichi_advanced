mod n_rooks;
mod types;
use rustler::{Encoder, Env, Term};
use types::{Prime, Tile, Aliases};
rustler::atoms! { ok }

#[rustler::nif]
fn solve_n_rooks<'a>(env: Env<'a>, masks: Vec<(u64, u8)>, col_mask: u64, num_rooks: u32) -> Term<'a> {
  match n_rooks::solve_n_rooks(&masks, col_mask, num_rooks) {
    Some(rows) => (ok(), rows).encode(env),
    None => rustler::types::atom::nil().encode(env),
  }
}

#[rustler::nif]
fn solve_n_rooks_exhaustive<'a>(env: Env<'a>, masks: Vec<(u64, u8)>, col_mask: u64, num_rooks: u32) -> Term<'a> {
  let solutions = n_rooks::solve_n_rooks_exhaustive(&masks, col_mask, num_rooks);
  (ok(), solutions).encode(env)
}

#[rustler::nif]
fn remove_indices<'a>(xs: Vec<Term<'a>>, is: Vec<usize>) -> Vec<Term<'a>> {
  _remove_indices(xs, is)
}
fn _remove_indices<'a>(xs: Vec<Term<'a>>, mut is: Vec<usize>) -> Vec<Term<'a>> {
  is.sort_unstable();

  let mut is_iter = is.into_iter().peekable();
  let mut i: usize = 0;
  let mut xs = xs;

  xs.retain(|_| {
    let keep = is_iter.peek() != Some(&i);
    if !keep { is_iter.next(); }
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
  if check_tile_match(&l, &r) { true }
  else if let Some(entry) = encoded_aliases.get(&r.0).or_else(|| encoded_aliases.get(&ANY_PRIME)) {
    entry.iter().any(|(battrs, aliases)| {
        (r.1 & *battrs == r.1) && aliases.iter().any(|t| check_tile_match(&l, t))
    })
  } else { false }
}

  // # check that taking `attrs1` out of `attrs2` is possible with attributes
  // # returns a list of indices (if exhaustive, a list of list of indices)
  // # or nil if no solution
  // def subtract_check_attrs(_attrs2, [], _encoded_aliases, exhaustive) do
  //     {:ok, if exhaustive do [[]] else [] end}
  // end
  // def subtract_check_attrs(attrs2, attrs1, encoded_aliases, exhaustive) do
  //   attrs1_indexed = attrs1
  //   |> Enum.filter(fn {p, _} -> is_number(p) end)
  //   |> Enum.with_index()
  //   # compute bitmasks where the ith bitmask has jth bit set iff attrs2[i] covers attrs1[j]}
  //   masks = for tile2 <- attrs2 do
  //     case tile2 do
  //       {p, _} when is_number(p) ->
  //         for {tile1, j} <- attrs1_indexed,
  //             check_equivalence(tile2, tile1, encoded_aliases),
  //             reduce: 0 do
  //           acc -> acc ||| (1 <<< j)
  //         end
  //       _ -> 0
  //     end
  //   end
  //   |> Enum.with_index()

  //   if Enum.empty?(masks) do
  //     nil
  //   else
  //     col_mask = Enum.reduce(masks, 0, fn {mask, _i}, acc -> mask ||| acc end)
  //     # then it's n-rooks on this bit matrix
  //     # returns indices into attrs2
  //     result = if exhaustive do
  //       solve_n_rooks_exhaustive(masks, col_mask, length(attrs1_indexed))
  //     else
  //       solve_n_rooks(masks, col_mask, length(attrs1_indexed))
  //     end
  //     with {:ok, indices} <- result do
  //       cond do
  //         Enum.empty?(indices) -> nil
  //         true -> {:ok, indices}
  //       end
  //     end
  //   end
  // end
  // def subtract_check_attrs(attrs2, attrs1, encoded_aliases, exhaustive) do
  

    // attrs1_indexed = attrs1
    // |> Enum.filter(fn {p, _} -> is_number(p) end)
    // |> Enum.with_index()
    // # compute bitmasks where the ith bitmask has jth bit set iff attrs2[i] covers attrs1[j]}
    // masks = for tile2 <- attrs2 do
    //   case tile2 do
    //     {p, _} when is_number(p) ->
    //       for {tile1, j} <- attrs1_indexed,
    //           check_equivalence(tile2, tile1, encoded_aliases),
    //           reduce: 0 do
    //         acc -> acc ||| (1 <<< j)
    //       end
    //     _ -> 0
    //   end
    // end
    // |> Enum.with_index()

// // #[rustler::nif]
// pub fn subtract_check_attrs(l: Tile, r: Tile, encoded_aliases: Aliases) -> Vec<usize> {
  
// }


rustler::init!("Elixir.RiichiAdvanced.Match");
