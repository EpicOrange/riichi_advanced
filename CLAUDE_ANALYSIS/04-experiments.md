# Experiments

Elixir is not installed in the environment this analysis was produced in, so the
claims below were checked by re-implementing the relevant matcher in Python and
measuring it, rather than by instrumenting the running game. Everything lives in
`tools/`; captured output is in `data/`.

Run them with:

```
python3 CLAUDE_ANALYSIS/tools/run_am_experiment.py       # ~1 min
python3 CLAUDE_ANALYSIS/tools/run_am_fix_experiment.py   # ~1 min
python3 CLAUDE_ANALYSIS/tools/am_game_sim.py 200         # ~4 min
```

All are seeded, so reruns reproduce the numbers quoted in `03-findings.md`.

---

## What was modelled

`tools/am_shanten_model.py` reimplements the quantity that
`ai_player.ex:109` / `ai_player.ex:140` compute as `13 - map_size(pairing_r)`.

The parts it reproduces faithfully:

- Card hands are read from `priv/static/mods/american/am_card_nmjl_2021.jq`
  (80 closed, 60 open) and expanded to concrete 14-tile targets the same way
  `American.preprocess_american_match_definition/1` does — suit letters,
  `X<n>` offsets sharing one base number across suits, free winds for `Z`,
  flowers as a wildcard over all eight flower/season tiles.
- Suit and dragon mapping matches `Constants.@fixed_offsets`
  (`lib/riichi_advanced/constants.ex:407-440`): A→manzu/7z, B→pinzu/0z,
  C→souzu/6z.
- Joker eligibility per group replicates
  `translate_american_match_definitions_postprocess/1` (`american.ex:116-140`):
  a group of ≥3 identical tiles takes jokers; singles, pairs and mixed groups
  (`2021a`, `6676a`) do not.
- The 152-tile American wall from `priv/static/rulesets/american.majs:3-40`.

Deliberate simplifications, stated so the numbers are read correctly:

- Maximum matching is computed greedily instead of by Hopcroft–Karp. This is
  exact for this problem: a real tile only matches its own tile type, and jokers
  only match joker-eligible slots, so assigning real tiles first (no-joker slots
  before joker slots) and then jokers is optimal.
- `"222a 0000a 222b 1111b"` is skipped — see finding D, it does not parse in the
  Elixir either.
- `|` alternatives take the first branch. The 2021 card uses none.

79 of 80 closed hands and 59 of 60 open hands are modelled, producing 1314 and
1086 concrete instantiations respectively.

---

## Experiment 1 — the distribution the gate is tested against

`tools/run_am_experiment.py`, 4000 random 13-tile deals, closed card.
Output: `data/shanten_distribution.txt`.

```
  shanten 2:     1  (  0.0%)   cumulative <= 2:   0.0%
  shanten 3:     6  (  0.1%)   cumulative <= 3:   0.2%
  shanten 4:    56  (  1.4%)   cumulative <= 4:   1.6%
  shanten 5:   312  (  7.8%)   cumulative <= 5:   9.4%
  shanten 6:  1145  ( 28.6%)   cumulative <= 6:  38.0%
  shanten 7:  1713  ( 42.8%)   cumulative <= 7:  80.8%
  shanten 8:   727  ( 18.2%)   cumulative <= 8:  99.0%
  shanten 9:    40  (  1.0%)   cumulative <= 9: 100.0%

P(shanten <= 3) at deal (the ai_player.ex:142 call gate) = 0.17%
```

Read against `ai_player.ex:142`: the gate admits 0.17% of freshly dealt hands.
The charleston improves hands from here, but not by the four points that would
be needed to put the median inside the gate.

## Experiment 2 — the exposure floor

Same script, second section. This part is arithmetic, not sampling, and holds
exactly:

```
  0 exposure(s): concealed=13 tiles -> shanten >= 0
  1 exposure(s): concealed=10 tiles -> shanten >= 3
  2 exposure(s): concealed= 7 tiles -> shanten >= 6   <-- gate `shanten <= 3` UNREACHABLE
  3 exposure(s): concealed= 4 tiles -> shanten >= 9   <-- gate `shanten <= 3` UNREACHABLE
  4 exposure(s): concealed= 1 tiles -> shanten >= 12   <-- gate `shanten <= 3` UNREACHABLE
```

The sampled version agrees — over 1500 random concealed hands per row against
the open card, `P(shanten <= 3)` is 0.0% at every exposure count including zero.

This is the finding that matters most. Even a perfectly tuned threshold cannot
rescue the current expression, because the quantity it measures drifts by +3 per
exposure while the hand is actually getting closer to done.

## Experiment 3 — the corrected denominator

`tools/run_am_fix_experiment.py`. Output: `data/corrected_metric.txt`.

Replacing the constant `13` with `length(hand ++ draw)` gives "concealed tiles
still unaccounted for", which behaves monotonically:

```
0 exposure(s), concealed=13:  current metric median=   7 min= 2   |  corrected median=   8 min= 3
1 exposure(s), concealed=10:  current metric median=   8 min= 4   |  corrected median=   6 min= 2
2 exposure(s), concealed= 7:  current metric median=   9 min= 6   |  corrected median=   4 min= 1
3 exposure(s), concealed= 4:  current metric median=  10 min= 9   |  corrected median=   2 min= 1
```

The corrected column is what a threshold can meaningfully be set against.

## Experiment 4 — effect on exhaustive draws

`tools/am_game_sim.py`, 200 seeded four-bot games per gate.
Output: `data/game_sim_200.txt`.

The loop is deliberately minimal — draw, discard by the `usages` heuristic, offer
the discard to the other three, call if the gate allows. No charleston, no joker
swapping, no dead hands, no scoring. It exists to isolate the effect of the gate,
so treat the absolute percentages as directional and the *ordering* as the
result.

```
call gate                          wins  draws   win %  avg exposures
----------------------------------------------------------------------
current (13 - matched <= 3)          54    146   27.0%           0.98
fixed denom, needs <= 3              50    150   25.0%           0.70
fixed denom, needs <= 5              86    114   43.0%           1.65
fixed denom, needs <= 7             115     85   57.5%           2.15
always call when useful             126     74   63.0%           2.30
```

Three things to take from this:

1. The current gate leaves the table at **0.98 exposures per game across all
   four players** — under one call per game, table-wide. That is the shape of
   the symptom you described.
2. Fixing the denominator alone but keeping `<= 3` makes things slightly
   *worse* (0.70 exposures), because a correct metric with a wrong threshold is
   still a wrong gate. Both parts of A1/A2 have to change together.
3. Loosening toward "call whenever the tile completes a group in a live hand"
   roughly halves the draw rate. Somewhere around `needs <= 5..7` captures most
   of the benefit; the exact number is worth tuning in the real engine, since
   this simulation has no charleston and no joker swapping and both push hands
   forward faster than modelled here.

---

## How to confirm this in the real engine

The model says what to expect; the engine should be made to say it too.

1. Set `@debug_ai` to `true` in
   `lib/riichi_advanced/game/game_state/debug.ex:17`. Bots then print the
   `13 - map_size(pairing_r)` value each turn via `ai_player.ex:96` and `:123`.
   Expect 4–8 on freshly dealt hands, and expect it to *rise* by 3 whenever a
   bot manages an exposure — that rise is finding A2 made visible.
2. Watch a table of four bots with the Open Hands mod and confirm callable
   discards go by untouched.
3. Change `ai_player.ex:142` and the two `13 -` expressions together
   (`:109`, `:140`), then re-run a batch. Note finding C5 first: `@ai_speed`
   is a compile-time constant and `Debug.debug_fast_ai()` does not shorten the
   per-decision sleeps, so a large batch needs that made configurable or the
   batch will be bound by wall-clock sleeps rather than compute.
