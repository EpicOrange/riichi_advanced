use std::sync::atomic::{AtomicU64, Ordering};

pub static TOTAL_NANOS: AtomicU64 = AtomicU64::new(0);
pub static CALL_COUNT: AtomicU64 = AtomicU64::new(0);

#[rustler::nif]
pub fn profile() {
  let total = TOTAL_NANOS.load(Ordering::Relaxed);
  let count = CALL_COUNT.load(Ordering::Relaxed);
  println!("{0} calls, {1} ms total, {2:.3} ms avg",
    count,
    total / 1000000,
    (total as f64 / count as f64) / 1e6
  );
}