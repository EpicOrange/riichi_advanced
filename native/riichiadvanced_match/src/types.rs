use std::collections::{HashMap};
use rustler::{Atom, Decoder, Encoder, Env, Error, NifResult, NifStruct, Term};

pub type Hash = u128;
pub type BitAttrs = u64;
pub type Tile = (Hash, BitAttrs);
pub const ANY_PRIME: Hash = 1;

pub type AliasEntry = HashMap<BitAttrs, Vec<Tile>>;
pub type Aliases = HashMap<Hash, AliasEntry>;

pub type Mask = u64;
pub type RowIndex = u8; // index into Mask

#[derive(NifStruct, PartialEq, Eq, Clone, Debug, Hash)]
#[module = "RiichiAdvanced.Match.TileSet"]
pub struct TileSet {
  pub hash: Hash,
  pub attrs: Vec<Tile>,
  pub name: Option<String>, // call name
  pub nojoker: bool, // for groups only
}
pub type Hands = Vec<TileSet>;

#[derive(PartialEq, Eq, Clone, Debug, Hash)]
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
pub struct AttrOffsetMap {
  pub offset: isize,
  pub attrs: Vec<String>,
}
#[derive(Clone, Debug)]
pub struct AttrTileMap {
  pub tile: String,
  pub attrs: Vec<String>,
}
// since NifMap deriving only works if the keys are atoms, we gotta roll our own
impl<'a> Decoder<'a> for AttrOffsetMap {
  fn decode(term: Term<'a>) -> NifResult<Self> {
    let env = term.get_env();
    let offset: isize = term.map_get("offset".encode(env))?.decode()?;
    let attrs: Vec<String> = term.map_get("attrs".encode(env))?.decode()?;
    Ok(AttrOffsetMap{ offset, attrs })
  }
}
impl Encoder for AttrOffsetMap {
  fn encode<'a>(&self, env: Env<'a>) -> Term<'a> {
    Term::map_from_pairs(env, &[
      ("offset".encode(env), self.offset.encode(env)),
      ("attrs".encode(env), self.attrs.encode(env))
    ]).unwrap()
  }
}
impl<'a> Decoder<'a> for AttrTileMap {
  fn decode(term: Term<'a>) -> NifResult<Self> {
    let env = term.get_env();
    let tile: String = term.map_get("tile".encode(env))?.decode()?;
    let attrs: Vec<String> = term.map_get("attrs".encode(env))?.decode()?;
    Ok(AttrTileMap{ tile, attrs })
  }
}
impl Encoder for AttrTileMap {
  fn encode<'a>(&self, env: Env<'a>) -> Term<'a> {
    Term::map_from_pairs(env, &[
      ("tile".encode(env), self.tile.encode(env)),
      ("attrs".encode(env), self.attrs.encode(env))
    ]).unwrap()
  }
}


#[derive(Clone, Debug)]
pub enum MatchOffset {
  Offset(isize),
  AttrsTile(AttrTileMap),
  AttrsOffset(AttrOffsetMap),
  TileOrKeyword(String), // group keywords, includes amerijong fixed offsets
}

#[derive(Clone, Debug)]
pub enum MatchGroup {
  Offset(MatchOffset),
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

#[derive(PartialEq, Eq, Clone, Debug, Hash)]
pub enum RemovableGroup<'a> {
  CallName(String),
  Group(TileSet),
  GroupRef(&'a TileSet), // only used internally
  Multigroup(Vec<TileSet>),
}

impl Encoder for MatchOffset {
  fn encode<'a>(&self, env: Env<'a>) -> Term<'a> {
    match self {
      MatchOffset::Offset(o) => o.encode(env),
      MatchOffset::AttrsTile(map) => map.encode(env),
      MatchOffset::AttrsOffset(map) => map.encode(env),
      MatchOffset::TileOrKeyword(s) => s.encode(env),
    }
  }
}

impl<'a> Decoder<'a> for MatchOffset {
  fn decode(term: Term<'a>) -> NifResult<Self> {
    if let Ok(o) = term.decode::<isize>() { Ok(MatchOffset::Offset(o)) }
    else if let Ok(map) = term.decode::<AttrTileMap>() { Ok(MatchOffset::AttrsTile(map)) }
    else if let Ok(map) = term.decode::<AttrOffsetMap>() { Ok(MatchOffset::AttrsOffset(map)) }
    else if let Ok(s) = term.decode::<String>() { Ok(MatchOffset::TileOrKeyword(s)) }
    else { Err(Error::BadArg) }
  }
}

impl Encoder for MatchGroup {
  fn encode<'a>(&self, env: Env<'a>) -> Term<'a> {
    match self {
      MatchGroup::Offset(offset) => offset.encode(env),
      MatchGroup::Offsets(offsets) => offsets.encode(env),
      MatchGroup::Subgroups(subgroupings) => subgroupings.encode(env),
    }
  }
}

impl<'a> Decoder<'a> for MatchGroup {
  fn decode(term: Term<'a>) -> NifResult<Self> {
    if let Ok(offset) = term.decode::<MatchOffset>() { Ok(MatchGroup::Offset(offset)) }
    else if let Ok(offsets) = term.decode::<Vec<MatchOffset>>() { Ok(MatchGroup::Offsets(offsets)) }
    else if let Ok(subgroupings) = term.decode::<Vec<Vec<MatchOffset>>>() { Ok(MatchGroup::Subgroups(subgroupings)) }
    else { Err(Error::BadArg) }
  }
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

impl<'a> Decoder<'a> for RemovableGroup<'a> {
  fn decode(term: Term<'a>) -> NifResult<Self> {
    if let Ok(name) = term.decode::<String>() { Ok(RemovableGroup::CallName(name)) }
    else if let Ok(group) = term.decode::<TileSet>() { Ok(RemovableGroup::Group(group)) }
    else if let Ok(subgroups) = term.decode::<Vec<TileSet>>() { Ok(RemovableGroup::Multigroup(subgroups)) }
    else { Err(Error::BadArg) }
  }
}
