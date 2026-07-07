use std::collections::{HashMap};
use rustler::{NifStruct};

pub type Hash = u128;
pub type BitAttrs = u64;
pub type Tile = (Hash, BitAttrs);

pub type AliasEntry = HashMap<BitAttrs, Vec<Tile>>;
pub type Aliases = HashMap<Hash, AliasEntry>;

pub type Mask = u64;
pub type RowIndex = u8; // index into Mask

#[derive(NifStruct, Clone, Debug)]
#[module = "RiichiAdvanced.Match.TileSet"]
pub struct TileSet {
  pub hash: Hash,
  pub attrs: Vec<Tile>,
  pub name: Option<String>,
  pub nojoker: bool,
}

