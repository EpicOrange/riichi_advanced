use std::collections::HashMap;

use num::abs;
use smallvec::{SmallVec, smallvec};

use crate::encode::{decode, decode_tiles, encode_tile, encode_tiles};
use crate::r#match::{__match_hand_v3, __pop_group};
use crate::match_info::prepare_tiles;
use crate::offsets::get_base_tiles;
use crate::primes::to_prime;
use crate::tile_table::{TILE_TABLE, tile7x};
use crate::types::{BaseTileVec, ElixirHandCalls, ElixirTile, ElixirTileOrdering, Hands, MatchDefinitionElem, MatchDefinitions, MatchGroup, MatchInfo, MatchOffset, RemovableGroup, Tile, TileSet};

#[rustler::nif(schedule = "DirtyCpu")]
fn _separate_standard_winner_hand(
    hand_calls: ElixirHandCalls,
    all_attrs: Vec<String>,
    ordering: ElixirTileOrdering,
    joker_assignment: HashMap<usize, ElixirTile>,
    win_definitions: MatchDefinitions,
) -> Vec<ElixirTile> {
  // ordering matters a lot here; joker_assignment references original order, and last tile of hand is the winning tile
  let mut match_info = prepare_tiles(
    &hand_calls,
    all_attrs,
    &HashMap::new(),
    &ordering,
  );
  // get winning tile as soon as we can
  let (hand, calls) = hand_calls;
  let Some(winning_tile) = hand.last().and_then(|t| encode_tile(t, &match_info.all_attrs)) else { return vec!(); };

  // make a flattened hand that joker_assignment can make use of
  let mut flattened_elixir_hand: Vec<ElixirTile> = hand;
  for (_, call) in calls { flattened_elixir_hand.extend(call); }
  let flattened_hand: Vec<Tile> = encode_tiles(&flattened_elixir_hand, &match_info.all_attrs).collect();

  // construct aliases/mapping to be precisely the joker assignment
  for (i, to) in joker_assignment.iter() {
    let from = flattened_hand[*i];
    let to = encode_tile(to, &match_info.all_attrs).expect("_separate_standard_winner_hand: failed to encode tile");
    match_info.aliases.entry(to.0)
      .and_modify(|m| {
        m.entry(to.1)
        .and_modify(|v| if !v.contains(&from) { v.push(from); })
        .or_insert(vec!(from));
      })
      .or_insert_with(|| {
        let mut m = HashMap::new();
        m.insert(to.1, vec!(from));
        m
      });
    match_info.mapping.entry(from)
      .and_modify(|v| if !v.contains(&to) { v.push(to); })
      .or_insert_with(|| vec!(to));
    // match_info.joker_tiles.insert(from);
    if !match_info.relevant_tiles.contains(&to) { match_info.relevant_tiles.push(to); }
  }

  // use mapping to unjoker all tiles in hands/calls
  let mut hands = match_info.initial_hands.clone();
  for hand in hands.iter_mut() {
    for tile in hand.attrs.iter_mut() {
      hand.hash /= tile.0;
      *tile = match match_info.mapping.get(tile).and_then(|v| v.first()) {
        None    => *tile,
        Some(t) => *t
      };
      hand.hash *= tile.0;
    }
  }

  // keep track of original index of each Tile in `hands` (not calls)
  // so that we can reconstruct the original hand after rearrangement
  // origin_map = {unjokered deattred tile => vec of indices it appears in}
  // we need to deattr because we later obtain groups by converting from RemovableGroup
  //   which will have no attrs
  let mut origin_map: HashMap<Tile, SmallVec<[u8; 4]>> = HashMap::new();
  for (i, tile) in hands[0].attrs.iter().enumerate() {
    origin_map.entry((tile.0, 0)).and_modify(|v| v.push(i as u8)).or_insert(smallvec!(i as u8));
  }

  // check if the win definition ever mentions offsets of at least 10
  // e.g. [["exhaustive", [[[0, 0]], 1], [[[0, 10, 20], [0, 1, 2], [0, 0, 0]], 4]]]
  let mut use_kontsu_knitted = false;
  for win_definition in win_definitions.iter() {
    for elem in win_definition {
      use_kontsu_knitted = match elem {
        MatchDefinitionElem::Keyword(_) => false,
        MatchDefinitionElem::Group(groups, _) =>
          groups.iter().any(|g| g.flatten().any(|o| {
            match o {
              MatchOffset::Offset(o) => abs(o) >= 10,
              MatchOffset::AttrsOffset(map) => abs(map.offset) >= 10,
              _ => false,
            }
          }))
      };
      if use_kontsu_knitted { break; }
    }
    if use_kontsu_knitted { break; }
  };

  // separate sets in hand
  let groups_to_remove: SmallVec<[MatchGroup; 8]> = if use_kontsu_knitted {
    smallvec!(
      MatchGroup::Offsets(vec!(0,0,0,1,1,1,2,2,2).into_iter().map(MatchOffset::Offset).collect()),
      MatchGroup::Offsets(vec!(0,0,1,1,2,2).into_iter().map(MatchOffset::Offset).collect()),
      MatchGroup::Offsets(vec!(0,1,2).into_iter().map(MatchOffset::Offset).collect()),
      MatchGroup::Offsets(vec!(0,0,0).into_iter().map(MatchOffset::Offset).collect()),
      MatchGroup::Offsets(vec!(0,10,20).into_iter().map(MatchOffset::Offset).collect()),
      MatchGroup::Offsets(vec!(0,11,22).into_iter().map(MatchOffset::Offset).collect()),
      MatchGroup::Offsets(vec!(0,0).into_iter().map(MatchOffset::Offset).collect()),
    )
  } else {
    smallvec!(
      MatchGroup::Offsets(vec!(0,0,0,1,1,1,2,2,2).into_iter().map(MatchOffset::Offset).collect()),
      MatchGroup::Offsets(vec!(0,0,1,1,2,2).into_iter().map(MatchOffset::Offset).collect()),
      MatchGroup::Offsets(vec!(0,1,2).into_iter().map(MatchOffset::Offset).collect()),
      MatchGroup::Offsets(vec!(0,0,0).into_iter().map(MatchOffset::Offset).collect()),
      MatchGroup::Offsets(vec!(0,0).into_iter().map(MatchOffset::Offset).collect()),
    )
  };

  let orig_initial_hands = match_info.initial_hands.clone();
  let mut result: Hands = arrange(hands, groups_to_remove, win_definitions, &mut match_info);
  match_info.initial_hands = orig_initial_hands;

  // hand sorted such that jokers are moved to what their actual values would be sorted to
  let mut flattened_arranged_hand: Vec<Tile> = result.iter().flat_map(|ts| ts.attrs.clone()).collect();
  flattened_arranged_hand.sort_unstable();
  // replace all jokers in flattened_arranged_hand
  let mut origin_map2 = origin_map.clone();
  for tile in flattened_arranged_hand.iter_mut() {
    if let Some(is) = origin_map2.get_mut(tile) {
      if let Some(i) = is.pop() {
        *tile = match_info.initial_hands[0].attrs[i as usize];
      }
    }
  }
  // rejoker the unjokered tiles in result, also sort each group in result
  for group in result.iter_mut() {
    for tile in group.attrs.iter_mut() {
      if let Some(is) = origin_map.get_mut(tile) {
        match is.pop() {
          Some(i) => {
            // println!("Successfully mapped tile {:?} back to original tile {:?} at index {i}",
            //   decode_tile(*tile, &match_info.all_attrs),
            //   decode_tile(match_info.initial_hands[0].attrs[i as usize], &match_info.all_attrs));
            group.hash /= tile.0;
            *tile = match_info.initial_hands[0].attrs[i as usize];
            group.hash *= tile.0;
          }
          None => {
            // println!("Tried to map tile {:?} back to original tile but we are out of indices",
            //   decode_tile(*tile, &match_info.all_attrs));
          }
        }
      }
    }
    group.attrs.sort_unstable();

    // for kanchan jokers, always display them as the second tile
    if let Some(kanchan_prime) = TILE_TABLE.get("31j") {
      if let Some(i) = group.attrs.iter().position(|(p, _)| p == kanchan_prime) {
        let tile = group.attrs.remove(i);
        group.attrs.insert(1, tile);
      }
    }
  }

  // try to maintain ordering of groups from the resulting hand, based on first tile of each group
  let mut ret: Vec<Tile> = vec!();
  let separator = (to_prime(&tile7x()).unwrap(), 0);
  // println!("flattened_hand={:?}", decode_tiles(&flattened_hand, &match_info.all_attrs));
  // println!("flattened_arranged_hand={:?}", decode_tiles(&flattened_arranged_hand, &match_info.all_attrs));
  for orig_tile in flattened_arranged_hand.iter() {
    let mut remove_ix = None;
    for (i, hand) in result.iter().enumerate() {
      if hand.attrs.first().map(|t| orig_tile.0 == t.0).unwrap_or(false) {
        // println!("inserting {:?}", decode(hand, &match_info.all_attrs));
        if !ret.is_empty() { ret.push(separator); }
        ret.extend(&hand.attrs);
        remove_ix = Some(i);
        break;
      }
    }
    if let Some(ix) = remove_ix { result.remove(ix); }
    if result.is_empty() { break; }
  }
  if result.len() > 1 {
    // push any remainder
    println!("WARNING: _separate_standard_winner_hand was unable to reorder all groups:");
    for hand in result {
      println!("{:?}", decode(&hand, &match_info.all_attrs));
      if !ret.is_empty() { ret.push(separator); }
      ret.extend(hand.attrs);
    }
  }
  // attempt to remove last instance of winning tile
  if let Some(ix) = ret.iter().rposition(|t| t.0 == winning_tile.0) { ret.remove(ix); }
  decode_tiles(&ret, &match_info.all_attrs)
}

#[inline]
fn arrange(
  mut hands: Hands,
  groups_to_remove: SmallVec<[MatchGroup; 8]>,
  win_definitions: MatchDefinitions,
  match_info: &mut MatchInfo
) -> Hands {
  let hand = hands.remove(0); // pop front
  let calls = hands;
  let base_tiles = get_base_tiles(match_info, &win_definitions.clone().into_iter().flatten().collect());
  // println!("base_tiles={:?}", decode_tiles(&base_tiles, &match_info.all_attrs));

  let (remaining_hand, groups_removed) = _arrange(hand, &calls, vec!(), &groups_to_remove, 0, &base_tiles, &win_definitions, match_info, 0);

  let mut ret = smallvec!(remaining_hand);
  // convert groups to tilesets
  // don't append calls, we only expect a hand
  ret.extend(groups_removed);
  ret
}

fn group_to_calls(group: RemovableGroup) -> Vec<TileSet> {
  match group {
    RemovableGroup::CallName(_) => vec!(),
    RemovableGroup::Group(g) => vec!(g),
    RemovableGroup::Multigroup(gs) => gs,
  }
}

fn is_valid_arrangement(
  result: (TileSet, Vec<TileSet>),
  calls: Hands, 
  win_definitions: &MatchDefinitions,
  match_info: &mut MatchInfo,
) -> bool {
  match_info.initial_hands = smallvec!(result.0);
  match_info.initial_hands.extend(calls);
  match_info.initial_hands.extend(result.1);
  __match_hand_v3(match_info, win_definitions)
}

fn _arrange(
  hand: TileSet,
  calls: &Hands,
  removed: Vec<TileSet>,
  groups: &SmallVec<[MatchGroup; 8]>,
  i: usize,
  base_tiles: &BaseTileVec,
  win_definitions: &MatchDefinitions,
  match_info: &mut MatchInfo,
  depth: u8
) -> (TileSet, Vec<TileSet>) {
  if i >= groups.len() { return (hand, removed); }

  // initialize to best result of removing nothing at this step
  let mut best = _arrange(hand.clone(), calls, removed.clone(), groups, i + 1, base_tiles, win_definitions, match_info, depth);
  let mut best_len = best.0.attrs.len();

  // compare with removing a group in every possible way
  // if i >= 3 { println!("i={i}, __pop_group={:?}", __pop_group(hand.clone(), groups[i].clone(), match_info, false, true, true, base_tiles.clone())); }
  for (new_hand, new_group) in __pop_group(hand.clone(), groups[i].clone(), match_info, false, true, true, base_tiles.clone()) {
    let new_calls = group_to_calls(new_group);
    if new_calls.is_empty() { continue; }
    // println!("new_calls={:?}", decode(&new_calls[0], &match_info.all_attrs));
    let mut removed2 = removed.clone();
    removed2.extend(new_calls);
    
    // for the first group only, prune this possibility if we can't make a winning hand with it
    if depth == 0 && !is_valid_arrangement((new_hand.clone(), removed2.clone()), calls.clone(), win_definitions, match_info) { continue; }

    let next = _arrange(new_hand.clone(), calls, removed2, groups, i, base_tiles, win_definitions, match_info, depth + 1);
    if best_len > next.0.attrs.len() {
      best_len = next.0.attrs.len();
      best = next;
    }
  }
  best
}
