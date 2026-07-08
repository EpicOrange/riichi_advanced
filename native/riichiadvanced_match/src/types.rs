use std::collections::{HashMap};
use rustler::{Atom, Decoder, Encoder, Env, Error, NifResult, NifStruct, Term};

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
  pub name: Option<String>, // call name
  pub nojoker: bool, // for groups only
}
pub type Hands = Vec<TileSet>;

#[derive(PartialEq, Eq, Clone, Debug)]
pub enum ElixirTile {
  AtomTile(Atom),
  AttrTile(Atom, Vec<String>),
}

fn extract_tile(tile: &ElixirTile) -> &Atom {
  match tile {
    ElixirTile::AtomTile(tile) => tile,
    ElixirTile::AttrTile(tile, _) => tile,
  }
}

impl PartialOrd for ElixirTile {
  fn partial_cmp(&self, other: &Self) -> Option<std::cmp::Ordering> {
    Some(self.cmp(other))
  }
}

impl Ord for ElixirTile {
  fn cmp(&self, other: &Self) -> std::cmp::Ordering {
    let l = (*extract_tile(self)).as_c_arg();
    let r = (*extract_tile(other)).as_c_arg();
    l.cmp(&r)
  }
}

impl Encoder for ElixirTile {
  fn encode<'a>(&self, env: Env<'a>) -> Term<'a> {
    match self {
      ElixirTile::AtomTile(tile) => tile.encode(env),
      ElixirTile::AttrTile(tile, attrs) => (tile, attrs).encode(env)
    }
  }
}

impl<'a> Decoder<'a> for ElixirTile {
  fn decode(term: Term<'a>) -> NifResult<Self> {
    if let Ok(tile) = term.decode::<Atom>() {
      Ok(ElixirTile::AtomTile(tile))
    } else if let Ok((tile, attrs)) = term.decode::<(Atom, Vec<String>)>() {
      Ok(ElixirTile::AttrTile(tile, attrs))
    } else {
      Err(Error::BadArg)
    }
  }
}

pub type ElixirHand = Vec<ElixirTile>;

pub type ElixirAliases = HashMap<Atom, HashMap<Vec<String>, ElixirHand>>;

// match definition spec

#[derive(Clone, Debug)]
pub enum MatchOffset {
  Numeric(u64),
  Tile(ElixirTile),
  Fixed(Atom), // for amerijong
  Keyword(String),
}

#[derive(Clone, Debug)]
pub enum MatchGroup {
  CallName(String),
  Offsets(Vec<MatchOffset>),
  Subgroups(Vec<Vec<MatchOffset>>),
}

#[derive(Clone, Debug)]
pub enum MatchDefinitionElem {
  Keyword(String),
  Group(MatchGroup, i8),
}

pub type MatchDefinition = Vec<MatchDefinitionElem>;
pub type MatchDefinitions = Vec<MatchDefinition>;

#[derive(Clone, Debug)]
pub enum RemovableGroup<'a> {
  CallName(String),
  Group(TileSet),
  GroupRef(&'a TileSet),
  Multigroup(Vec<RemovableSubgroup>),
}
#[derive(Clone, Debug)]
pub enum RemovableSubgroup {
  Subgroup(TileSet),
  SubgroupSet(Vec<TileSet>),
}


impl<'a> Encoder for RemovableGroup<'a> {
  fn encode<'b>(&self, env: Env<'b>) -> Term<'b> {
    match self {
      RemovableGroup::CallName(name) => name.encode(env),
      RemovableGroup::Group(group) => group.encode(env),
      RemovableGroup::GroupRef(group) => group.encode(env),
      RemovableGroup::Multigroup(subgroups) => subgroups.encode(env),
    }
  }
}
impl Encoder for RemovableSubgroup {
  fn encode<'b>(&self, env: Env<'b>) -> Term<'b> {
    match self {
      RemovableSubgroup::Subgroup(subgroup) => subgroup.encode(env),
      RemovableSubgroup::SubgroupSet(subgroups) => subgroups.encode(env),
    }
  }
}

impl<'a> Decoder<'a> for RemovableGroup<'a> {
  fn decode(term: Term<'a>) -> NifResult<Self> {
    if let Ok(name) = term.decode::<String>() {
      Ok(RemovableGroup::CallName(name))
    } else if let Ok(group) = term.decode::<TileSet>() {
      Ok(RemovableGroup::Group(group))
    } else if let Ok(subgroups) = term.decode::<Vec<RemovableSubgroup>>() {
      Ok(RemovableGroup::Multigroup(subgroups))
    } else {
      Err(Error::BadArg)
    }
  }
}

impl<'a> Decoder<'a> for RemovableSubgroup {
  fn decode(term: Term<'a>) -> NifResult<Self> {
    if let Ok(subgroup) = term.decode::<TileSet>() {
      Ok(RemovableSubgroup::Subgroup(subgroup))
    } else if let Ok(subgroups) = term.decode::<Vec<TileSet>>() {
      Ok(RemovableSubgroup::SubgroupSet(subgroups))
    } else {
      Err(Error::BadArg)
    }
  }
}
