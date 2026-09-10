import random, sys, statistics
from collections import Counter
sys.path.insert(0, "CLAUDE_ANALYSIS/tools")
from am_shanten_model import *

random.seed(20260910)
closed = read_card(CARD, "win_definition")
openv  = read_card(CARD, "open_win_definition")
print(f"card hands: closed={len(closed)} open={len(openv)}")

T_closed = build_targets(closed)
T_open   = build_targets(openv)
skipped = [d for d in closed if not list(instantiate(d))]
print(f"modelled: closed={len(T_closed)} open={len(T_open)}  (unmodelled: {skipped})")
print(f"instantiations: closed={sum(len(i) for _,i in T_closed)} open={sum(len(i) for _,i in T_open)}")

N = 4000
dist = Counter()
for _ in range(N):
    hand = random.sample(WALL, 13)
    s, _m = hand_shanten(hand, T_closed)
    dist[s] += 1

print(f"\n=== 'shanten' (13 - matched) at deal, closed hand, N={N} ===")
tot = 0
for s in sorted(dist):
    tot += dist[s]
    print(f"  shanten {s}: {dist[s]:5d}  ({100*dist[s]/N:5.1f}%)   cumulative <= {s}: {100*tot/N:5.1f}%")

le3 = sum(v for k, v in dist.items() if k <= 3)
print(f"\nP(shanten <= 3) at deal (the ai_player.ex:142 call gate) = {100*le3/N:.2f}%")

# --- effect of already having calls: concealed hand shrinks by 3 per exposure
print("\n=== after N exposures (concealed hand shrinks by 3 each) ===")
print("The metric hardcodes 13, but pairing_r only indexes CONCEALED tiles,")
print("so map_size(pairing_r) <= len(concealed hand). Hard floor on 'shanten':")
for calls in range(0, 5):
    concealed = 13 - 3 * calls
    print(f"  {calls} exposure(s): concealed={concealed:2d} tiles -> shanten >= {13-concealed}"
          + ("   <-- gate `shanten <= 3` UNREACHABLE" if 13 - concealed > 3 else ""))

# --- empirical: simulate a hand that has made `c` pungs
print("\n=== empirical shanten with exposures (open card, best case) ===")
for calls in (0, 1, 2):
    concealed = 13 - 3 * calls
    d2 = Counter()
    M = 1500
    for _ in range(M):
        hand = random.sample(WALL, concealed)
        c = Counter(t for t in hand if t != JOKER)
        j = sum(1 for t in hand if t == JOKER)
        best = max(best_match(c, j, g) for _d, insts in T_open for g in insts)
        d2[13 - best] += 1
    le3 = sum(v for k, v in d2.items() if k <= 3)
    print(f"  {calls} exposure(s): min={min(d2)} median={statistics.median(d2.elements()):.0f} "
          f"P(shanten<=3)={100*le3/M:.1f}%")
