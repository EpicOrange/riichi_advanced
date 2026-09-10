"""
A simplified American-mahjong game loop driven by faithful re-implementations of
the two AI heuristics in lib/riichi_advanced/game/ai_player.ex:

  choose_american_discard/3  -> discard the playable tile used by the fewest of
                                the closest hands
  choose_american_call/2     -> call only when `shanten <= 3` (line 142),
                                where shanten = 13 - map_size(pairing_r)

The point is to compare exhaustive-draw rates under the current gate against
gates computed from a corrected denominator.  Everything else (charleston,
joker swapping, dead hands, scoring) is deliberately left out: we only want the
relative effect of the call gate.
"""
import random, sys
from collections import Counter
sys.path.insert(0, "CLAUDE_ANALYSIS/tools")
from am_shanten_model import (CARD, WALL, FLOWERS, JOKER, read_card,
                              build_targets, instantiate)

# ------------------------------------------------------- compiled targets ---

def compile_targets(defns):
    """(needs, flower_nj, flower_jk) per instantiation, deduped."""
    seen, out = set(), []
    for d in defns:
        for groups in instantiate(d):
            nj, jk, fnj, fjk = Counter(), Counter(), 0, 0
            for g in groups:
                if g.kind == "flower":
                    if g.joker_ok: fjk += g.size
                    else:          fnj += g.size
                else:
                    (jk if g.joker_ok else nj)[g.tiles[0]] += g.size
            key = (tuple(sorted(nj.items())), tuple(sorted(jk.items())), fnj, fjk)
            if key in seen:
                continue
            seen.add(key)
            needs = tuple((t, nj.get(t, 0), jk.get(t, 0)) for t in set(nj) | set(jk))
            out.append((needs, fnj, fjk))
    return out


def match(counter, jokers, target):
    needs, fnj, fjk = target
    matched, free = 0, 0
    for tile, n_nj, n_jk in needs:
        have = counter.get(tile, 0)
        u_nj = have if have < n_nj else n_nj
        rem = have - u_nj
        u_jk = rem if rem < n_jk else n_jk
        matched += u_nj + u_jk
        free += n_jk - u_jk
    if fnj or fjk:
        hf = sum(counter.get(f, 0) for f in FLOWERS)
        u = hf if hf < fnj else fnj
        matched += u
        hf -= u
        u = hf if hf < fjk else fjk
        matched += u
        free += fjk - u
    return matched + (jokers if jokers < free else free)


def best_over(hand_tiles, targets):
    c = Counter(t for t in hand_tiles if t != JOKER)
    j = len(hand_tiles) - sum(c.values())
    best, arg = -1, None
    for tg in targets:
        m = match(c, j, tg)
        if m > best:
            best, arg = m, tg
    return best, arg


def top_targets(hand_tiles, targets, k=5):
    """The AI keeps the 5 closest hands; mirror that."""
    c = Counter(t for t in hand_tiles if t != JOKER)
    j = len(hand_tiles) - sum(c.values())
    scored = sorted(((match(c, j, tg), i, tg) for i, tg in enumerate(targets)),
                    key=lambda x: -x[0])
    return scored[:k]

# --------------------------------------------------------------- the bots ---

class Bot:
    def __init__(self, hand):
        self.hand = sorted(hand)
        self.calls = []          # list of (tile, size)

    def concealed(self):
        return self.hand

    def matched(self, targets):
        return best_over(self.hand, targets)[0]


def usage_discard(bot, targets):
    """Mirror of choose_american_discard: least-used non-joker tile."""
    best = top_targets(bot.hand, targets, 5)
    if not best:
        return len(bot.hand) - 1
    top = best[0][0]
    keep = [tg for m, _i, tg in best if m == top]
    usage = [0] * len(bot.hand)
    c = Counter(t for t in bot.hand if t != JOKER)
    for tg in keep:
        needs, fnj, fjk = tg
        want = {t: nj + jk for t, nj, jk in needs}
        used = Counter()
        for idx, t in enumerate(bot.hand):
            if t == JOKER:
                usage[idx] += 1        # jokers are always wanted
            elif t in FLOWERS and (fnj + fjk) > used["F"]:
                used["F"] += 1
                usage[idx] += 1
            elif want.get(t, 0) > used[t]:
                used[t] += 1
                usage[idx] += 1
    cands = [i for i, t in enumerate(bot.hand) if t != JOKER]
    if not cands:
        cands = list(range(len(bot.hand)))
    return min(cands, key=lambda i: usage[i])


def wants_call(bot, tile, targets, gate):
    """Mirror of choose_american_call. `gate` decides the threshold.

    Returns the call size (3/4/5/6) or 0.
    """
    if tile == JOKER:
        return 0
    have = sum(1 for t in bot.hand if t == tile)
    if have < 2:
        return 0
    best = top_targets(bot.hand, targets, 5)
    if not best:
        return 0
    top = best[0][0]
    if not gate(top, len(bot.hand)):
        return 0
    for m, _i, (needs, _fnj, _fjk) in best:
        if m != top:
            continue
        for t, nj, jk in needs:
            if t == tile and jk >= 3 and jk <= have + 1:
                return jk
    return 0


GATES = {
    # current code: shanten = 13 - matched, gate is shanten <= 3
    "current (13 - matched <= 3)":
        lambda matched, hlen: (13 - matched) <= 3,
    # corrected denominator, still a tight gate
    "fixed denom, needs <= 3":
        lambda matched, hlen: (hlen - matched + 1) <= 3,
    "fixed denom, needs <= 5":
        lambda matched, hlen: (hlen - matched + 1) <= 5,
    "fixed denom, needs <= 7":
        lambda matched, hlen: (hlen - matched + 1) <= 7,
    "always call when useful":
        lambda matched, hlen: True,
}

# ------------------------------------------------------------- game loop ----

def play_game(rng, closed_t, open_t, gate):
    wall = WALL[:]
    rng.shuffle(wall)
    bots = [Bot([wall.pop() for _ in range(13)]) for _ in range(4)]
    turn = 0
    while wall:
        b = bots[turn]
        b.hand.append(wall.pop())
        b.hand.sort()
        tg = open_t if b.calls else closed_t
        need = 14 - 3 * len(b.calls)
        if best_over(b.hand, tg)[0] >= need:
            return "win", sum(len(x.calls) for x in bots)
        idx = usage_discard(b, tg)
        disc = b.hand.pop(idx)

        called = None
        for off in range(1, 4):
            o = (turn + off) % 4
            ob = bots[o]
            ot = open_t if ob.calls else closed_t
            size = wants_call(ob, disc, ot, gate)
            if size:
                used = min(size - 1, sum(1 for t in ob.hand if t == disc))
                for _ in range(used):
                    ob.hand.remove(disc)
                for _ in range(size - 1 - used):
                    if JOKER in ob.hand:
                        ob.hand.remove(JOKER)
                ob.calls.append((disc, size))
                called = o
                break
        if called is not None:
            cb = bots[called]
            ct = open_t if cb.calls else closed_t
            need = 14 - 3 * len(cb.calls)
            if len(cb.hand) and best_over(cb.hand, ct)[0] >= need - 1:
                return "win", sum(len(x.calls) for x in bots)
            if cb.hand:
                cb.hand.pop(usage_discard(cb, ct))
            turn = called
        turn = (turn + 1) % 4
    return "draw", sum(len(b.calls) for b in bots)


def main(games=60):
    closed_t = compile_targets(read_card(CARD, "win_definition"))
    open_t = compile_targets(read_card(CARD, "open_win_definition"))
    print(f"compiled instantiations: closed={len(closed_t)} open={len(open_t)}\n")
    print(f"{'call gate':<32} {'wins':>6} {'draws':>6} {'win %':>7} {'avg exposures':>14}")
    print("-" * 70)
    for name, gate in GATES.items():
        rng = random.Random(1234)
        wins = draws = 0
        exposures = []
        for _ in range(games):
            res, ncalls = play_game(rng, closed_t, open_t, gate)
            exposures.append(ncalls)
            if res == "win":
                wins += 1
            else:
                draws += 1
        avg = sum(exposures) / len(exposures)
        print(f"{name:<32} {wins:>6} {draws:>6} {100*wins/games:>6.1f}% {avg:>14.2f}")


if __name__ == "__main__":
    main(int(sys.argv[1]) if len(sys.argv) > 1 else 60)
