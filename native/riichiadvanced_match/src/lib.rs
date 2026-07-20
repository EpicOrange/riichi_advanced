mod n_rooks;
mod tileset;
mod types;
mod encode;
mod primes;
mod tile_table;
mod r#match;
mod offsets;
mod utils;
mod match_info;
mod profile;
mod waits;
mod match_elim;
mod match_dfs;
mod match_bipartite;
mod match_blossom;

rustler::init!("Elixir.RiichiAdvanced.Match");
