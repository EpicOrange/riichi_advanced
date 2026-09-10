# CLAUDE_ANALYSIS

Analysis of the automated player (CPU/AI/bot) in Riichi Advanced.

Self-contained: nothing outside this folder was modified, and none of the
suggested fixes have been applied to the source tree.

Analysed at commit `2aa1d96` on branch `claude/intelligent-fermi-tkmbmq`.

## Start here

| file | what it is |
|---|---|
| [`01-executive-summary.md`](01-executive-summary.md) | The short version. Read this first. |
| [`02-american-call-gate.md`](02-american-call-gate.md) | Code-path walkthrough of the `ai_player.ex:142` bug. |
| [`03-findings.md`](03-findings.md) | Full catalogue — 23 findings plus 2 card-data observations, file:line, severity-ranked. |
| [`04-experiments.md`](04-experiments.md) | How the numbers were produced, and what they do and don't show. |
| [`05-recommended-fixes.md`](05-recommended-fixes.md) | Suggested patches for the blocking items. Untested. |

## The headline

Your read of `ai_player.ex:142` was right, and the problem is bigger than the
constant. `if shanten <= 3` tests a quantity that is not shanten — it is
`13 - map_size(pairing_r)`, the count of hand tiles not yet matched into a card
hand. The median freshly dealt American hand scores **7** on that scale, and
`<= 3` admits **0.17%** of deals.

Worse, `pairing_r` indexes only *concealed* tiles, so the value rises by 3 with
every exposure while the hand is actually getting closer to done. After two
exposures `shanten <= 3` is arithmetically unsatisfiable. Since nearly every NMJL
hand needs three to five exposures, bots cannot assemble an open hand at all —
hence the exhaustive draws.

Fixing the constant alone is not enough: in simulation, correcting the
denominator while keeping the `<= 3` threshold made bots call *less*. Both have
to change together.

Beyond American, the largest findings are that riichi bots never call either
(`pon`/`chii`/`daiminkan` are commented out at `ai_player.ex:448-450`), and that
there is no defensive discard logic anywhere in the normal discard path.

## Scope and method

Covered: `lib/riichi_advanced/game/ai_player.ex` in full, plus the AI-facing
parts of `game_state/american.ex`, `game_state.ex`, `game_state/conditions.ex`,
`game_state/buttons.ex` and `game_state/debug.ex`.

Elixir was not available in the environment this was produced in, so nothing was
executed against the real engine. Structural claims come from reading the code;
quantitative claims come from a Python re-implementation of the American matcher
in `tools/`, whose modelling assumptions are documented in `04-experiments.md`.
The exposure-floor result in finding A2 is arithmetic and does not depend on the
model at all.

## Reproducing the numbers

From the repository root:

```
python3 CLAUDE_ANALYSIS/tools/run_am_experiment.py       # ~1 min
python3 CLAUDE_ANALYSIS/tools/run_am_fix_experiment.py   # ~1 min
python3 CLAUDE_ANALYSIS/tools/am_game_sim.py 200         # ~4 min
```

No dependencies beyond the standard library. All seeded. Captured output is in
`data/`.

```
tools/
  am_shanten_model.py       parser + matcher for NMJL card hands
  run_am_experiment.py      Experiments 1 and 2 — the metric's distribution and its exposure floor
  run_am_fix_experiment.py  Experiment 3 — the corrected denominator
  am_game_sim.py            Experiment 4 — draw rates under five different call gates
data/
  shanten_distribution.txt
  corrected_metric.txt
  game_sim_200.txt
```
