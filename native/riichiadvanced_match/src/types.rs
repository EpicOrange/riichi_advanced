use std::collections::HashMap;
use rustler::{NifStruct};

pub type Prime = u128;
pub type BitAttrs = u64;
pub type Tile = (Prime, BitAttrs);

#[derive(NifStruct, Debug)]
#[module = "Elixir.RiichiAdvanced.Match.TileSet"]
pub struct TileSet {
  pub hash: Prime,
  pub attrs: Vec<Tile>,
  pub name: Option<Vec<u8>>,
  pub nojoker: bool,
}
pub type AliasEntry = HashMap<BitAttrs, Vec<Tile>>;
pub type Aliases = HashMap<Prime, AliasEntry>;

pub type Mask = u64;
pub type RowIndex = u8; // index into Mask
