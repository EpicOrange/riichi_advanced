import random, sys, statistics
from collections import Counter
sys.path.insert(0, "CLAUDE_ANALYSIS/tools")
from am_shanten_model import *

random.seed(20260910)
T_open = build_targets(read_card(CARD, "open_win_definition"))

print("Corrected metric: tiles_still_needed = len(concealed) - matched  (+1 when not on your draw)")
print("i.e. replace the hardcoded 13 with length(hand ++ draw).\n")
for calls in (0, 1, 2, 3):
    concealed = 13 - 3 * calls
    M, d_old, d_new = 2000, Counter(), Counter()
    for _ in range(M):
        hand = random.sample(WALL, concealed)
        c = Counter(t for t in hand if t != JOKER)
        j = sum(1 for t in hand if t == JOKER)
        best = max(best_match(c, j, g) for _d, insts in T_open for g in insts)
        d_old[13 - best] += 1
        d_new[concealed - best + 1] += 1   # tiles still needed to reach 14
    med_o = statistics.median(d_old.elements())
    med_n = statistics.median(d_new.elements())
    print(f"{calls} exposure(s), concealed={concealed:2d}:"
          f"  current metric median={med_o:4.0f} min={min(d_old):2d}"
          f"   |  corrected median={med_n:4.0f} min={min(d_new):2d}")

# what fraction of random deals clear various corrected thresholds
T_closed = build_targets(read_card(CARD, "win_definition"))
N, dist = 4000, Counter()
for _ in range(N):
    hand = random.sample(WALL, 13)
    c = Counter(t for t in hand if t != JOKER)
    j = sum(1 for t in hand if t == JOKER)
    best = max(best_match(c, j, g) for _d, insts in T_closed for g in insts)
    dist[13 - best + 1] += 1
print(f"\nCorrected 'tiles still needed' at deal (N={N}):")
tot = 0
for s in sorted(dist):
    tot += dist[s]
    print(f"  needs {s}: {100*dist[s]/N:5.1f}%   cumulative <= {s}: {100*tot/N:5.1f}%")
