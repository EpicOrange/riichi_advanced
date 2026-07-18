use std::sync::atomic::{AtomicU64, Ordering};

pub const PROFILE_MATCH: bool = true;
pub const PROFILE_GET_WAITS: bool = false;
pub const PROFILE_UNNEEDED_TILES: bool = false;

pub static TOTAL_NANOS: AtomicU64 = AtomicU64::new(0);
pub static MAX_NANOS: AtomicU64 = AtomicU64::new(0);
pub static CALL_COUNT: AtomicU64 = AtomicU64::new(0);

#[rustler::nif]
pub fn profile() {
  let total = TOTAL_NANOS.load(Ordering::Relaxed);
  let max = MAX_NANOS.load(Ordering::Relaxed);
  let count = CALL_COUNT.load(Ordering::Relaxed);
  println!("{0} calls, {1} ms total, {2} ms max, {3:.3} ms avg",
    count,
    total / 1000000,
    max / 1000000,
    (total as f64 / count as f64) / 1e6
  );
}