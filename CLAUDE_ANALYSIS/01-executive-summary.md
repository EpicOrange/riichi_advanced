# Executive summary

Analysis of the automated player in Riichi Advanced, at commit `2aa1d96`
(branch `claude/intelligent-fermi-tkmbmq`). Primary file:
`lib/riichi_advanced/game/ai_player.ex` (630 lines), plus the American support
code in `lib/riichi_advanced/game/game_state/american.ex` and the AI
notification path in `lib/riichi_advanced/game/game_state.ex`.

## The bug you found is real, and it is worse than a bad constant

`ai_player.ex:142` — `if shanten <= 3 do` — gates every call the American AI can
make. Your read of it is correct: bots pass on nearly every exposure. Two things
are wrong with it, and they compound.

**The threshold is measured against the wrong scale.** The `shanten` in that
comparison is `13 - map_size(pairing_r)`, which counts *tiles not yet part of my
best card hand*, not riichi shanten. Over 4000 simulated deals the median value
is **7**, and `<= 3` admits **0.17%** of hands. The gate sits about four points
below where the distribution lives.

**The hardcoded `13` breaks as soon as a hand opens.** `pairing_r` only indexes
*concealed* tiles — `compute_closest_american_hands` strips called groups from
the target before matching (`american.ex:498-513`). So after `c` exposures the
metric cannot go below `3c`:

| exposures | minimum possible value | `shanten <= 3` satisfiable? |
|---|---|---|
| 0 | 0 | yes, 0.17% of deals |
| 1 | 3 | only when already one tile from mahjong |
| 2 | 6 | **never** |
| 3 | 9 | **never** |

This is arithmetic, not sampling. Since essentially every NMJL hand needs three
to five exposures, a bot that manages one call is locked out of calling for the
rest of the round. Nobody assembles an exposed hand, nobody declares mahjong, and
the round runs to exhaustive draw — exactly the symptom you described.

**Both parts have to change together.** In a 200-game simulation, correcting the
denominator while keeping `<= 3` made things slightly *worse* (0.70 exposures per
game, versus 0.98 today). Correcting the denominator and loosening the threshold
roughly halved the draw rate. Details and caveats in `04-experiments.md`.

## But it is not the only reason the bots are passive

The American call gate is the sharpest problem. Ranked next:

- **Riichi bots never call either** — `ai_player.ex:448-450` has `pon`, `chii`
  and `daiminkan` commented out in the fallthrough branch that every ruleset
  except `fuzhou`/`vietnamese` lands in. Riichi bots play closed hands only, and
  riichi on sight the moment they reach tenpai (`:441`).
- **There is no defence anywhere.** `choose_discard/3` takes `visible_tiles` and
  ignores it (`:41`). The only safety logic in the normal discard path is an
  open-riichi special case under a rule most rulesets do not enable. The suji and
  centralness helpers exist but are wired only into the minefield AI.
- **American discards read a cache that is often cold or stale.** The call path
  recomputes `closest_american_hands` synchronously; the discard and charleston
  paths read `player.cache` (`game_state.ex:1759`, `1857`, `1912`), which an
  async job may not have filled yet. When it is empty the discard heuristic
  degenerates to "discard hand position 0".
- **One pid tracks four sequential computations.**
  `game_state.ex:2131-2134` clears `calculate_closest_american_hands_pid` after
  the first of four seats reports, which both defeats cancellation and makes
  `conditions.ex:693`'s `done_calculating` check report done while three seats
  are still unknown.
- **Which tiles get exposed on a call is `Enum.random`** (`:491-520`). In
  American that choice decides joker usage, the most valuable resource in the
  game.

The full catalogue — 23 findings with file and line references and severity, plus two card-data observations — is in
`03-findings.md`.

## Two things that will slow down any fix

- **`@ai_speed` is a compile-time constant** (`ai_player.ex:11`) driving
  `Process.sleep` on every decision. `Debug.debug_fast_ai()` looks like the
  escape hatch but is only consulted in `init/1` — it shortens startup and
  nothing else. Batch A/B testing of a threshold is wall-clock bound until this
  is made configurable. Worth doing first.
- **There are no AI tests at all.** `choose_discard/3`,
  `choose_american_discard/3` and `choose_american_call/2` are pure given their
  arguments, which makes them cheap to pin down and the obvious place to start.

## Suggested order of work

1. Make bot speed configurable (`C5`) so batches are practical.
2. Fix the American metric and gate together (`A1`, `A2`), then tune the
   threshold empirically.
3. Characterisation tests on the three pure decision functions (`C6`).
4. Fix the cache handshake (`A5`, `A6`, `A7`) — stale data is currently
   indistinguishable from a bad heuristic, which will make step 2 hard to
   measure.
5. Re-enable and gate `pon`/`chii` for the default rulesets (`B1`).
6. Then the strategy work: defence (`B4`), joker-aware call choices (`A9`),
   riichi judgement (`B3`).

Concrete suggested patches for steps 1–3 are in `05-recommended-fixes.md`.
