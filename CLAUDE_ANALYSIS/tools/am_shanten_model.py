"""
A standalone Python model of the "American shanten" metric that
lib/riichi_advanced/game/ai_player.ex computes as:

    shanten = 13 - map_size(pairing_r)

where pairing_r is the maximum bipartite matching between the AI's CONCEALED
hand tiles and the tiles required by an NMJL card hand
(RiichiAdvanced.GameState.American.compute_closest_american_hands/4).

Purpose: quantify how often the AI's call gate at ai_player.ex:142
(`if shanten <= 3 do`) can ever be satisfied.

Modeling notes (documented deliberately -- this is a model, not the real matcher):
  * Card parsed from priv/static/mods/american/am_card_nmjl_2021.jq
  * Suit letters A/B/C -> manzu/pinzu/souzu, dragons DA/DB/DC -> 7z/0z/6z
    (matches lib/riichi_advanced/constants.ex @fixed_offsets).
  * X<n> offsets share ONE base number across all suits (matches the single
    base_tile + rem(v,30) suit encoding in american.ex).
  * Joker eligibility per group replicates
    translate_american_match_definitions_postprocess/1: a group of >= 3
    identical tiles is joker-eligible, singles / pairs / mixed groups are not.
  * Maximum matching is computed greedily (real tiles to their own slots,
    no-joker slots first, then jokers into leftover joker-eligible slots).
    This is optimal here because real tiles only match their own tile type
    and jokers only match joker-eligible slots.
"""

import random, re, sys, itertools
from collections import Counter, defaultdict

CARD = "priv/static/mods/american/am_card_nmjl_2021.jq"

FLOWERS = ["1f", "2f", "3f", "4f", "1g", "2g", "3g", "4g"]
WINDS = {"E": "1z", "S": "2z", "W": "3z", "N": "4z"}
SUIT_OF = {"A": "m", "B": "p", "C": "s"}
DRAGON_OF = {"A": "7z", "B": "0z", "C": "6z"}
JOKER = "1j"

WALL = (
    [f"{n}{s}" for s in "mps" for n in range(1, 10) for _ in range(4)]
    + [t for t in ["1z", "2z", "3z", "4z", "0z", "6z", "7z"] for _ in range(4)]
    + FLOWERS[:]
    + [JOKER] * 8
)
assert len(WALL) == 152, len(WALL)


# ---------------------------------------------------------------- parsing ---

def read_card(path, key):
    src = open(path).read()
    body = src.split(f".{key} = [", 1)[1].split("\n  ]", 1)[0]
    body = re.sub(r"#.*", "", body)
    return re.findall(r'"([^"]+)"', body)


class Group:
    """A group of slots in a target hand.  kind is 'fixed', 'flower' or 'wind'."""
    __slots__ = ("kind", "tiles", "size", "joker_ok")

    def __init__(self, kind, tiles, size, joker_ok):
        self.kind, self.tiles, self.size, self.joker_ok = kind, tiles, size, joker_ok


def parse_definition(defn):
    """Parse one am_match_definition into (static_groups, offset_slots, wind_groups).

    offset_slots is a list of (offset_value, suit_letter or None) that all share
    one base number; wind_groups is a list of sizes for 'Z' groups (free wind).
    Returns None if the definition uses syntax we do not model.
    """
    static, offsets, winds = [], [], []
    for token in defn.split():
        if "|" in token:            # alternatives -- take the first branch
            token = token.split("|")[0]
        head = token[0]
        if head in "FZ0GRNEWSJ":
            for ch, freq in Counter(token).items():
                if ch in "abc":     # e.g. the "0000a" typo on the 2021 card
                    return None
                if ch == "F":
                    static.append(Group("flower", FLOWERS, freq, freq >= 3))
                elif ch == "Z":
                    winds.append(freq)
                elif ch in WINDS:
                    static.append(Group("fixed", [WINDS[ch]], freq, freq >= 3))
                elif ch == "0":
                    static.append(Group("fixed", ["0z"], freq, freq >= 3))
                elif ch == "G":
                    static.append(Group("fixed", ["6z"], freq, freq >= 3))
                elif ch == "R":
                    static.append(Group("fixed", ["7z"], freq, freq >= 3))
                elif ch == "J":
                    static.append(Group("fixed", [JOKER], freq, freq >= 3))
                else:
                    return None
        elif head in "123456789D":
            suit = token[-1] if token[-1] in "abc" else None
            body = token[:-1] if suit else token
            static.append(("suited", body, suit))
        elif head == "X":
            suit = token[-1] if token[-1] in "abc" else None
            body = token[:-1] if suit else token
            shift = int(body[-1])
            count = len(body) - 1
            offsets.extend([(shift, suit)] * count)
        else:
            return None
    return static, offsets, winds


def _suited_groups(body, suit_letter):
    """Turn e.g. ('2021', 'A') into concrete Group objects."""
    tiles = []
    for ch in body:
        if ch == "D":
            tiles.append(DRAGON_OF[suit_letter])
        elif ch == "0":
            tiles.append("0z")
        else:
            tiles.append(f"{ch}{SUIT_OF[suit_letter]}")
    same = len(set(tiles)) == 1
    if same:
        return [Group("fixed", [tiles[0]], len(tiles), len(tiles) >= 3)]
    # mixed group: every slot is its own no-joker slot
    return [Group("fixed", [t], 1, False) for t in tiles]


def instantiate(defn):
    """Yield every concrete target hand (list of Group) for a definition."""
    parsed = parse_definition(defn)
    if parsed is None:
        return
    static, offsets, wind_sizes = parsed
    suit_perms = [{"a": "A", "b": "B", "c": "C"}, {"a": "A", "b": "C", "c": "B"},
                  {"a": "B", "b": "A", "c": "C"}, {"a": "B", "b": "C", "c": "A"},
                  {"a": "C", "b": "A", "c": "B"}, {"a": "C", "b": "B", "c": "A"}]
    # base numbers valid for every offset
    if offsets:
        shifts = sorted({s for s, _ in offsets})
        bases = [b for b in range(1, 10) if all(1 <= b + (s - shifts[0]) <= 9 for s in shifts)]
    else:
        bases = [None]
    wind_choices = list(itertools.product(*[list(WINDS.values()) for _ in wind_sizes])) or [()]

    for perm in suit_perms:
        for base in bases:
            for wc in wind_choices:
                groups = []
                for item in static:
                    if isinstance(item, Group):
                        groups.append(item)
                    else:
                        _, body, suit = item
                        letter = perm[suit] if suit else "A"
                        groups.extend(_suited_groups(body, letter))
                for size, wind in zip(wind_sizes, wc):
                    groups.append(Group("fixed", [wind], size, size >= 3))
                if offsets:
                    shifts = sorted({s for s, _ in offsets})
                    freq = Counter(offsets)
                    for (shift, suit), n in freq.items():
                        letter = perm[suit] if suit else "A"
                        num = base + (shift - shifts[0])
                        groups.append(Group("fixed", [f"{num}{SUIT_OF[letter]}"], n, n >= 3))
                if sum(g.size for g in groups) == 14:
                    yield groups


# --------------------------------------------------------------- matching ---

def best_match(hand_counter, jokers, groups):
    """Max number of concealed hand tiles that can be paired into `groups`."""
    nojoker_need, joker_need = Counter(), Counter()
    flower_nojoker = flower_joker = 0
    for g in groups:
        if g.kind == "flower":
            if g.joker_ok:
                flower_joker += g.size
            else:
                flower_nojoker += g.size
        else:
            (joker_need if g.joker_ok else nojoker_need)[g.tiles[0]] += g.size

    matched = 0
    free_joker_slots = 0
    for tile in set(nojoker_need) | set(joker_need):
        have = hand_counter.get(tile, 0)
        nj, jk = nojoker_need[tile], joker_need[tile]
        use_nj = min(have, nj)
        use_jk = min(have - use_nj, jk)
        matched += use_nj + use_jk
        free_joker_slots += jk - use_jk

    have_f = sum(hand_counter.get(f, 0) for f in FLOWERS)
    use_f_nj = min(have_f, flower_nojoker)
    use_f_jk = min(have_f - use_f_nj, flower_joker)
    matched += use_f_nj + use_f_jk
    free_joker_slots += flower_joker - use_f_jk

    matched += min(jokers, free_joker_slots)
    return matched


def build_targets(defns):
    out = []
    for d in defns:
        insts = list(instantiate(d))
        if insts:
            out.append((d, insts))
    return out


def hand_shanten(hand, targets, hand_size=13):
    """Replicates ai_player.ex: 13 - map_size(pairing_r), minimised over hands."""
    c = Counter(t for t in hand if t != JOKER)
    j = sum(1 for t in hand if t == JOKER)
    best = 0
    for _d, insts in targets:
        for groups in insts:
            m = best_match(c, j, groups)
            if m > best:
                best = m
    return 13 - best, best
