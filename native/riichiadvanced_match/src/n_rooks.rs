use rustler::{Encoder, Env, Term};
use smallvec::{smallvec};
use crate::types::{IndexVec, Mask, RowIndex};

#[inline]
fn get_lowest_bit(x: Mask) -> Mask {
  x & x.wrapping_neg()
}

#[rustler::nif]
fn solve_n_rooks<'a>(env: Env<'a>, masks: Vec<(Mask, RowIndex)>, col_mask: Mask, num_rooks: RowIndex) -> Term<'a> {
  match _solve_n_rooks(&masks, col_mask, num_rooks) {
    Some(ret) => (rustler::types::atom::ok(), ret.into_iter().collect::<Vec<_>>()).encode(env),
    None => rustler::types::atom::nil().encode(env),
  }
}
pub fn _solve_n_rooks(masks: &[(Mask, RowIndex)], col_mask: Mask, num_rooks: RowIndex) -> Option<IndexVec> {
  let mut mask_arr: Vec<Mask> = masks.iter().map(|(m, _)| *m).collect();
  let mut row_arr: IndexVec = masks.iter().map(|(_, r)| *r).collect();
  let len = mask_arr.len();
  let mut acc: IndexVec = smallvec!();
  _solve_n_rooks_rec(&mut mask_arr, &mut row_arr, len, col_mask, num_rooks, &mut acc)
}
fn _solve_n_rooks_rec(
  masks: &mut [Mask], rows: &mut [RowIndex],
  len: usize, col_mask: Mask, num_rooks: RowIndex,
  acc: &mut IndexVec
) -> Option<IndexVec> {
  if num_rooks == 0 { return Some(acc.clone()); }
  if col_mask == 0 { return None; }
  let col = get_lowest_bit(col_mask);
  for i in 0..len {
    if masks[i] & col_mask & col == 0 { continue; }
    let row = rows[i];

    masks.swap(i, len - 1);
    rows.swap(i, len - 1);
    acc.push(row);
    let result = _solve_n_rooks_rec(masks, rows, len - 1, col_mask ^ col, num_rooks - 1, acc);
    acc.pop();
    masks.swap(i, len - 1);
    rows.swap(i, len - 1);

    if result.is_some() { return result; }
  }
  None
}

#[rustler::nif]
fn solve_n_rooks_exhaustive<'a>(env: Env<'a>, masks: Vec<(Mask, RowIndex)>, col_mask: Mask, num_rooks: RowIndex) -> Term<'a> {
  let solutions = _solve_n_rooks_exhaustive(&masks, col_mask, num_rooks);
  (rustler::types::atom::ok(), solutions.into_iter().map(|v| v.to_vec()).collect::<Vec<_>>()).encode(env)
}
pub fn _solve_n_rooks_exhaustive(masks: &[(Mask, RowIndex)], col_mask: Mask, num_rooks: RowIndex) -> Vec<IndexVec> {
  let mut mask_arr: Vec<Mask> = masks.iter().map(|(m, _)| *m).collect();
  let mut row_arr: IndexVec = masks.iter().map(|(_, r)| *r).collect();
  let len = mask_arr.len();
  let mut acc: IndexVec = smallvec!();
  let mut out = Vec::new();
  _solve_n_rooks_exhaustive_rec(&mut mask_arr, &mut row_arr, len, col_mask, num_rooks, &mut acc, &mut out);
  out
}
fn _solve_n_rooks_exhaustive_rec(
  masks: &mut [Mask], rows: &mut [RowIndex],
  len: usize, col_mask: Mask, num_rooks: RowIndex,
  acc: &mut IndexVec, out: &mut Vec<IndexVec>,
) {
  if num_rooks == 0 { out.push(acc.clone()); return; }
  if col_mask == 0 { return; }
  let col = get_lowest_bit(col_mask);
  for i in 0..len {
    if masks[i] & col_mask & col == 0 { continue; }
    let row = rows[i];
    masks.swap(i, len - 1);
    rows.swap(i, len - 1);
    acc.push(row);
    _solve_n_rooks_exhaustive_rec(masks, rows, len - 1, col_mask ^ col, num_rooks - 1, acc, out);
    acc.pop();
    masks.swap(i, len - 1);
    rows.swap(i, len - 1);
  }
}
