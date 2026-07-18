use crate::tile_table::*;
use std::{collections::{HashMap, HashSet}, fmt, ops::{Div, MulAssign, Rem}};
use num_bigint::{BigUint, Sign};
use ruint::aliases::U256;
use rustler::{Atom, BigInt, Decoder, Encoder, Env, Error, NifResult, NifStruct, Term};

pub type BitAttrs = u64;
pub type Prime = u32;
pub type Tile = (Prime, BitAttrs);
pub const ANY_PRIME: Prime = 1;

pub type AliasEntry = HashMap<BitAttrs, Vec<Tile>>;
pub type Aliases = HashMap<Prime, AliasEntry>;

pub type Mask = u64;
pub type RowIndex = u8; // index into Mask

#[derive(PartialEq, Eq, PartialOrd, Ord, Clone, Copy, Debug, Hash)]
#[repr(transparent)]
pub struct Hash(pub U256);

impl MulAssign<Prime> for Hash {
  fn mul_assign(&mut self, rhs: Prime) {
    self.0 *= U256::from(rhs);
  }
}
impl MulAssign<Hash> for Hash {
  fn mul_assign(&mut self, rhs: Hash) {
    self.0 *= rhs.0;
  }
}
impl Div<Prime> for Hash {
  type Output = Hash;
  fn div(self, rhs: Prime) -> Hash {
    Hash(self.0 / U256::from(rhs))
  }
}
impl Div<Hash> for Hash {
  type Output = Hash;
  fn div(self, rhs: Hash) -> Hash {
    Hash(self.0 / rhs.0)
  }
}
impl Rem<Prime> for Hash {
  type Output = Prime;
  fn rem(self, rhs: Prime) -> Prime {
    (self.0 % U256::from(rhs)).to()
  }
}
impl Rem<Hash> for Hash {
  type Output = Hash;
  fn rem(self, rhs: Hash) -> Hash {
    Hash(self.0 % rhs.0)
  }
}
impl Hash {
  pub fn gcd(l: Hash, r: Hash) -> Hash {
    Hash(U256::gcd(l.0, r.0))
  }
}

impl<'a> Decoder<'a> for Hash {
  fn decode(term: Term<'a>) -> NifResult<Self> {
    let big: BigInt = term.decode()?;
    let (sign, uint): (Sign, BigUint) = big.into_parts();
    if sign == Sign::Minus { return Err(Error::Term(Box::new("got nonnegative elixir integer"))); }
    U256::try_from(uint).map(Hash).map_err(|_| Error::Term(Box::new("got elixir integer larger than U256")))
  }
}
impl Encoder for Hash {
  fn encode<'a>(&self, env: Env<'a>) -> Term<'a> {
    let uint: BigUint = self.0.into();
    let big = BigInt::from_biguint(Sign::Plus, uint);
    big.encode(env)
  }
}

#[derive(NifStruct, PartialEq, Eq, PartialOrd, Ord, Clone, Debug, Hash)]
#[module = "RiichiAdvanced.Match.TileSet"]
pub struct TileSet {
  pub hash: Hash,
  pub attrs: Vec<Tile>,
  pub name: Option<String>, // call name
  pub nojoker: bool, // for groups only
}
pub type Hands = Vec<TileSet>;

impl TileSet {
  pub fn set_nojoker(mut self, nojoker: bool) -> Self {
    self.nojoker = nojoker;
    self
  }
}

#[derive(PartialEq, Eq, Clone, Hash)]
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

impl fmt::Debug for ElixirTile {
  fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
    match self {
      ElixirTile::AtomTile(tile) => write!(f, ":{:?}", tile),
      // ElixirTile::AttrTile(tile, _attrs) => write!(f, ":{:?}", tile),
      ElixirTile::AttrTile(tile, attrs) => write!(f, ":{:?}{:?}", tile, attrs),
    }
  }
}

pub type ElixirHand = Vec<ElixirTile>;
pub type ElixirHandCalls = (ElixirHand, Vec<(String, ElixirHand)>);
pub type ElixirAliases = HashMap<ElixirTile, HashMap<Vec<String>, ElixirHand>>;

// match definition spec

#[derive(PartialEq, Eq, PartialOrd, Ord, Clone, Debug)]
pub struct AttrOffsetMap {
  pub offset: isize,
  pub attrs: Vec<String>,
}
#[derive(PartialEq, Eq, PartialOrd, Ord, Clone, Debug)]
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

#[derive(PartialEq, Eq, PartialOrd, Ord, Clone)]
pub enum MatchOffset {
  Offset(isize),
  AttrsTile(AttrTileMap),
  AttrsOffset(AttrOffsetMap),
  TileOrKeyword(String), // group keywords, includes amerijong fixed offsets
}

#[derive(PartialEq, Eq, Clone)]
pub enum MatchGroup {
  Offset(MatchOffset),
  Offsets(Vec<MatchOffset>),
  Subgroups(Vec<Vec<MatchOffset>>),
}

impl MatchGroup {
  // pub fn flatten_move(self) -> Vec<MatchOffset> {
  //   match self {
  //     MatchGroup::Offset(o) => vec!(o),
  //     MatchGroup::Offsets(os) => os,
  //     MatchGroup::Subgroups(oss) => oss.into_iter().flatten().collect(),
  //   }
  // }
  pub fn flatten(&self) -> Vec<MatchOffset> {
    match self {
      MatchGroup::Offset(o) => vec!(o.clone()),
      MatchGroup::Offsets(os) => os.clone(),
      MatchGroup::Subgroups(oss) => oss.iter().flat_map(|os| os.iter().cloned()).collect(),
    }
  }
}

#[derive(PartialEq, Eq, Clone, Debug)]
pub enum MatchDefinitionElem {
  Keyword(String),
  Group(Vec<MatchGroup>, i8),
}

pub type MatchDefinition = Vec<MatchDefinitionElem>;
pub type MatchDefinitions = Vec<MatchDefinition>;

#[derive(PartialEq, Eq, PartialOrd, Ord, Clone, Debug, Hash)]
pub enum RemovableGroup {
  CallName(String),
  Group(TileSet),
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

impl fmt::Debug for MatchOffset {
  fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
    match self {
      MatchOffset::Offset(o) => write!(f, "{o}"),
      MatchOffset::AttrsTile(map) => write!(f, "{:?}{:?}", map.tile, map.attrs),
      MatchOffset::AttrsOffset(map) => write!(f, "{:?}{:?}", map.offset, map.attrs),
      MatchOffset::TileOrKeyword(s) => write!(f, "{s:?}"),
    }
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

impl fmt::Debug for MatchGroup {
  fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
    match self {
      MatchGroup::Offset(o) => write!(f, "{:?}", o),
      MatchGroup::Offsets(os) => write!(f, "{:?}", os),
      MatchGroup::Subgroups(oss) => write!(f, "{:?}", oss),
    }
  }
}

impl Encoder for MatchDefinitionElem {
  fn encode<'a>(&self, env: Env<'a>) -> Term<'a> {
    match self {
      MatchDefinitionElem::Keyword(s) => s.encode(env),
      MatchDefinitionElem::Group(groups, num) => vec!(groups.encode(env), num.encode(env)).encode(env),
    }
  }
}

impl<'a> Decoder<'a> for MatchDefinitionElem {
  fn decode(term: Term<'a>) -> NifResult<Self> {
    if let Ok(s) = term.decode::<String>() { Ok(MatchDefinitionElem::Keyword(s)) }
    else if let Ok(groups_num) = term.decode::<Vec<Term<'a>>>() {
      if groups_num.len() != 2 { return Err(Error::BadArg); }
      let groups = groups_num[0].decode()?;
      let num = groups_num[1].decode()?;
      Ok(MatchDefinitionElem::Group(groups, num))
    }
    else { Err(Error::BadArg) }
  }
}

impl Encoder for RemovableGroup {
  fn encode<'a>(&self, env: Env<'a>) -> Term<'a> {
    match self {
      RemovableGroup::CallName(name) => name.encode(env),
      RemovableGroup::Group(group) => group.encode(env),
      RemovableGroup::Multigroup(subgroups) => subgroups.encode(env),
    }
  }
}

impl<'a> Decoder<'a> for RemovableGroup {
  fn decode(term: Term<'a>) -> NifResult<Self> {
    if let Ok(name) = term.decode::<String>() { Ok(RemovableGroup::CallName(name)) }
    else if let Ok(group) = term.decode::<TileSet>() { Ok(RemovableGroup::Group(group)) }
    else if let Ok(subgroups) = term.decode::<Vec<TileSet>>() { Ok(RemovableGroup::Multigroup(subgroups)) }
    else { Err(Error::BadArg) }
  }
}

// impl RemovableGroup {
//   pub fn unwrap_group(self) -> Option<TileSet> {
//     match self {
//       RemovableGroup::Group(group) => Some(group),
//       _ => None
//     }
//   }
// }

// fixed offsets, for amerijong
pub static FIXED_OFFSETS: phf::Map<&'static str, fn() -> Atom> = phf::phf_map! {
  "1A"  => tile1m,
  "2A"  => tile2m,
  "3A"  => tile3m,
  "4A"  => tile4m,
  "5A"  => tile5m,
  "6A"  => tile6m,
  "7A"  => tile7m,
  "8A"  => tile8m,
  "9A"  => tile9m,
  "10A" => tile10m,
  "DA"  => tile7z,
  "1B"  => tile1p,
  "2B"  => tile2p,
  "3B"  => tile3p,
  "4B"  => tile4p,
  "5B"  => tile5p,
  "6B"  => tile6p,
  "7B"  => tile7p,
  "8B"  => tile8p,
  "9B"  => tile9p,
  "10B" => tile10p,
  "DB"  => tile0z,
  "1C"  => tile1s,
  "2C"  => tile2s,
  "3C"  => tile3s,
  "4C"  => tile4s,
  "5C"  => tile5s,
  "6C"  => tile6s,
  "7C"  => tile7s,
  "8C"  => tile8s,
  "9C"  => tile9s,
  "10C" => tile10s,
  "DC"  => tile6z,
};

#[derive(Debug)]
pub struct MatchInfo<'a> {
  pub initial_hands: Vec<TileSet>,
  pub num_tiles_in_hand: usize,
  pub aliases: Aliases,
  pub relevant_tiles: Vec<Tile>,
  pub joker_tiles: HashSet<Tile>,
  pub all_attrs: &'a Vec<String>,
  pub ordering: &'a HashMap<Atom, Atom>,
  pub ordering_r: &'a HashMap<Atom, Atom>,
}


// dfs match
pub type PathItem = RemovableGroup;
pub type AccItem = (Hands, usize, Vec<PathItem>);
pub type AccIterator<'a> = Box<dyn Iterator<Item = AccItem> + 'a>;

// elim match
pub type HandsIterator<'a> = Box<dyn Iterator<Item = Hands> + 'a>;
