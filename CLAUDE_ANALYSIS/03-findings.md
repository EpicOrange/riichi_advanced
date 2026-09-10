# Findings: deficiencies in the automated player

Every finding is anchored to a file and line in the tree at commit `2aa1d96`.
Severity is about *effect on how the bots play*, not about crash risk.

Legend: **S1** game-breaking · **S2** materially degrades play · **S3** rough edge

---

## A. American / NMJL

### A1 — The call gate is calibrated against the wrong scale · **S1**

`lib/riichi_advanced/game/ai_player.ex:142`

```elixir
if shanten <= 3 do
```

This is the reported bug, and it is real. The `shanten` it tests is built four
lines above:

```elixir
# ai_player.ex:139-141
shanten = closest_american_hands
|> Enum.map(fn {_am_match_definition, pairing_r, _arranged_hand} -> 13 - map_size(pairing_r) end)
|> Enum.min(&<=/2, fn -> :infinity end)
```

`pairing_r` comes from `American.compute_closest_american_hands/4`
(`lib/riichi_advanced/game/game_state/american.ex:516`) and is the maximum
bipartite matching between the player's tiles and the tiles a card hand
requires. So `13 - map_size(pairing_r)` is **"how many of my tiles are not yet
part of my best card hand"** — a completely different quantity from riichi
shanten, and one that is much larger for the same hand quality.

Measured over 4000 random 13-tile American deals against the NMJL 2021 card
(see `04-experiments.md`):

| metric value | share of deals | cumulative |
|---|---|---|
| 2 | 0.0% | 0.0% |
| 3 | 0.1% | **0.2%** |
| 4 | 1.4% | 1.6% |
| 5 | 7.8% | 9.4% |
| 6 | 28.6% | 38.0% |
| 7 | 42.8% | 80.8% |
| 8 | 18.2% | 99.0% |
| 9 | 1.0% | 100.0% |

The median freshly-dealt hand scores **7**. `shanten <= 3` is satisfied by
**0.17%** of deals. The gate is not "slightly too tight" — it is roughly four
points below where the distribution lives.

### A2 — The hardcoded `13` makes the gate unsatisfiable once a hand is open · **S1**

`ai_player.ex:109` and `ai_player.ex:140` (same expression in
`choose_american_discard/3` and `choose_american_call/2`)

`pairing_r` indexes only the **concealed** hand. `compute_closest_american_hands`
builds it from `state.players[seat].hand ++ draw` (`american.ex:517-522`), and
`instantiate_match_definition` explicitly removes called groups from the target
before matching (`american.ex:498-513`, *"any american hand must use every
existing call"*). Called tiles are therefore never in `pairing_r`.

That gives an exact, non-statistical floor. With `c` exposures of 3 tiles the
concealed hand holds `13 - 3c` tiles, so `map_size(pairing_r) <= 13 - 3c` and:

| exposures | concealed tiles | minimum possible `13 - map_size` | can `shanten <= 3` ever be true? |
|---|---|---|---|
| 0 | 13 | 0 | yes (0.17% of deals) |
| 1 | 10 | 3 | only if *all ten* concealed tiles already match |
| 2 | 7 | 6 | **never** |
| 3 | 4 | 9 | **never** |
| 4 | 1 | 12 | **never** |

Almost every NMJL hand needs three to five exposures. A bot that somehow makes
one call can only ever make a second while it is already one tile from mahjong,
and after two calls it is locked out of calling permanently. This is the
mechanism behind "games routinely go to exhaustive draw": the bots cannot
assemble an exposed hand at all, so nobody ever declares mahjong.

The fix is to divide by the actual hand length rather than the constant 13.
`length(hand ++ draw) - map_size(pairing_r)` is the number of concealed tiles
still unaccounted for, and it stays on the same scale as exposures accumulate:

| exposures | current metric (median) | corrected metric (median) |
|---|---|---|
| 0 | 7 | 8 |
| 1 | 8 | 6 |
| 2 | 9 | 4 |
| 3 | 10 | 2 |

Note the directions: the current metric gets *worse* as the hand gets closer to
done, which is exactly backwards.

### A3 — The debug output that would reveal this is itself mislabelled · **S2**

`ai_player.ex:96` and `ai_player.ex:123`

```elixir
IO.puts(" >> #{state.seat}: I'm currently #{shanten}-shanten!")
```

Turning on `@debug_ai` prints the same wrong quantity under the name "shanten",
so watching bots print `7-shanten` on a perfectly reasonable American hand reads
as "the bots have terrible hands" rather than "this number is not shanten". Any
threshold tuning done against this print will be tuned against the bug.

### A4 — `choose_american_discard` has no tie-break, and degenerates completely when the cache is cold · **S2**

`ai_player.ex:106-127`

```elixir
ret = playables
|> Enum.reject(fn {tile, _i} -> tile == :"1j" end)
|> Enum.min_by(fn {_tile, i} -> usages[i] end, &<=/2, fn -> nil end)
```

`usages[i]` counts how many of the (at most five) closest hands use hand index
`i`. Two problems:

1. `Enum.min_by` with `&<=/2` returns the **first** minimum. Ties — which are
   the common case, since most tiles are used by zero or all of five nearly
   identical hands — always resolve to the leftmost hand position. Bot hands are
   not sorted during live play (`actions.ex:299-302` only sorts when
   `Debug.debug()` is on; `:sort_hands` at `game_state.ex:1524` is only cast from
   log replay), so this is a positional bias rather than a tile-value decision,
   and it is stable turn over turn.
2. When `closest_american_hands` is `[]`, `usages` is all zeros and *every*
   playable ties, so the bot discards `Enum.at(playables, 0)` unconditionally.
   See A5 for how often that happens.

### A5 — Discards and calls read `closest_american_hands` from two different sources · **S2**

- Call path: `game_state.ex:1790-1806` recomputes `closest_american_hands`
  synchronously inside the notification task and passes the fresh value.
- Discard path: `game_state.ex:1759`, `1857`, `1912` pass
  `state.players[seat].cache.closest_american_hands`, i.e. whatever the async
  job last wrote.

The cache is refreshed by `GenServer.cast(self(), :calculate_closest_american_hands)`
after every draw (`actions.ex:246`) and on every `send_async_tasks`
(`game_state.ex:1202`), and the AI only waits `trunc(1200 / @ai_speed)` = 300 ms
before committing to a discard (`ai_player.ex:295`). Whenever the job has not
landed, the bot discards by A5's degenerate rule. This also covers the
**charleston**, where `mark_tiles` (`game_state.ex:1912`) is the very first thing
that happens in a round and the cache is most likely to still be empty — so bots
pass their first three hand positions rather than their three least useful tiles.

### A6 — One pid tracks four sequential computations · **S2**

`game_state.ex:2095-2117` starts a *single* task that loops over all four seats
and casts a result per seat. `game_state.ex:2131-2134` handles each of those
casts:

```elixir
def handle_cast({:set_closest_american_hands, seat, closest_american_hands}, state) do
  state = state
  |> update_player(seat, &%{ &1 | cache: %{ &1.cache | closest_american_hands: closest_american_hands } })
  |> Map.put(:calculate_closest_american_hands_pid, nil)
```

The pid is cleared after the **first** seat reports, while three seats are still
being computed. Two consequences:

- `kill_all_tasks/1` (`game_state.ex:1235`) and the guard at `game_state.ex:2100`
  can no longer cancel the in-flight task, so a second computation can start and
  run concurrently. Their per-seat casts interleave, and an older result can land
  after a newer one and overwrite it.
- `conditions.ex:693` uses exactly this pid as its "am I done" signal:

  ```elixir
  done_calculating = state.calculate_closest_american_hands_pid == nil
  ```

  so `is_tenpai_american` reports a verdict based on three stale caches. That
  condition gates the mahjong/tenpai buttons.

### A7 — Acknowledged race between the AI and the async calculation · **S2**

`game_state.ex:2141`, in the code's own words:

```elixir
# note that this races the AI: the AI might act before closest_american_hands is calculated, so they may miss buttons that should be there
# TODO maybe fix this by pausing the game at the start of this particular async calculation, and unpausing after
```

Worth fixing together with A6, since both are about the same handshake.

### A8 — Calling is evaluated with no notion of cost · **S3**

`ai_player.ex:128-161`. `choose_american_call/2` filters for hands in
`open_am_match_definitions`, so it will not call itself out of legality. But it
never weighs that an exposure *permanently* removes every concealed-only hand
from the search, nor that it burns a tile from a hand that may be closer to a
concealed target. Once A1/A2 are fixed and bots actually call, this becomes the
next thing to look at.

### A9 — Which tiles get exposed is chosen at random · **S2**

`ai_player.ex:491-521`

```elixir
called_tile = player.call_buttons |> Map.keys() |> Enum.filter(...) |> Enum.random()
...
{called_tile, Enum.random(player.call_buttons[called_tile])}
```

In American this choice decides **joker usage** — the same pung can be formed
from two real tiles or from a real tile plus a joker. Picking uniformly at random
means bots burn jokers they did not need to spend, and hold jokers they should
have spent. Jokers are the single most valuable resource in NMJL.

---

## B. Riichi and the other rulesets

### B1 — Bots never pon, chii, or daiminkan in any default ruleset · **S1 for open-hand rulesets**

`ai_player.ex:447-450`

```elixir
"ankan" in player.buttons -> "ankan"
# "daiminkan" in player.buttons -> "daiminkan"
# "pon" in player.buttons -> "pon"
# "chii" in player.buttons -> "chii"
```

This `cond` is the fallthrough for every ruleset without a dedicated branch —
including `riichi` itself. With the three call clauses commented out, execution
reaches `"skip" in player.buttons and state.seat != turn -> "skip"`
(`ai_player.ex:460`) and the bot passes. Riichi bots therefore play *only* closed
hands, forever. `fuzhou`/`vietnamese` get the real behaviour at
`ai_player.ex:430-434`; nothing else does.

### B2 — Always ankan · **S2**

`ai_player.ex:447` (and `:420` for chinitsu). The bot kans whenever it can, with
no check on whether the kan destroys a wait, breaks a hand shape, or hands the
table an extra dora indicator.

### B3 — Always riichi the instant tenpai is reached · **S2**

`ai_player.ex:441`

```elixir
"riichi" in player.buttons and Match.match_hand(player.hand ++ player.draw, player.calls, state.shanten_definitions.tenpai, player.tile_behavior) -> "riichi"
```

No consideration of wait quality, existing yaku, turn number, score situation,
or damaten value. Combined with B1 this makes every riichi bot play one fixed
line: stay closed, riichi on sight.

### B4 — There is no defence · **S1 for realism, S2 for play strength**

`ai_player.ex:41`

```elixir
defp choose_discard(state, playables, _visible_tiles) do
```

`visible_tiles` is passed in from `game_state.ex:1758` and then discarded. The
only safety logic anywhere in the normal discard path is the open-riichi block at
`ai_player.ex:246-255`, which applies only under a rule most rulesets do not
enable. The building blocks exist and are unused here —
`Riichi.genbutsu_to_suji/2` and `Riichi.get_centralness/1` are called only by the
minefield heuristic at `ai_player.ex:149-158`, which its own comment calls
*"really dumb"*. Against a riichi, bots push every tile.

### B5 — The discard ordering is efficiency-first, which leaves bots holding the dangerous tiles · **S3**

`ai_player.ex:27-39`. `choose_playable_tile/2` splits candidates into
yaochuuhai → 2/8 → 3/7 → rest and takes a random tile from the first non-empty
tier. That is the right *efficiency* order, but it means bots shed their safest
tiles in the opening and enter the dangerous turns holding nothing but middle
tiles. Fixing B4 without revisiting this will not help much.

### B6 — Nothing plays for tenpai at exhaustive draw · **S2**

There is no branch anywhere that changes behaviour as the wall runs down. Bots
neither push for tenpai payments nor fold to keep noten small.

### B7 — `declare_yaku` is hardcoded · **S3**

`ai_player.ex:619-629` always declares `["Riichi"]` regardless of ruleset or
actual hand.

---

## C. Structural and infrastructural

### C1 — Shanten can only improve one step per decision · **S2**

`ai_player.ex:72`

```elixir
shanten_definitions = Enum.drop(shanten_definitions, max(0, shanten))
```

`state.shanten` is last turn's answer (stored at `ai_player.ex:290`). Dropping
that many definitions means the search starts one level better than last turn and
walks upward — it can never recognise that the hand jumped two or more steps
closer, so the AI's belief about its own hand lags reality and it stays in the
crude `shanten >= 4` "discard disconnected tiles" branch (`ai_player.ex:75-84`)
longer than it should. It resets to `-1` per round via `:initialize`
(`game_state.ex:1832`, `ai_player.ex:196`), so the drift is bounded to one hand.

### C2 — Three handlers silently drop messages before initialisation · **S2**

`init/1` leaves `initialized: false` for 500 ms (`ai_player.ex:17-25`).
`{:your_turn, ...}` and `{:buttons, ...}` handle that by rescheduling
(`ai_player.ex:337`, `486`). But `{:call_buttons, ...}` (`:491`),
`{:mark_tiles, ...}` (`:533`) and `{:declare_yaku, ...}` (`:619`) just return
`{:noreply, state}` and the message is gone. Nothing re-sends it, so the game
waits on a bot that will never answer.

### C3 — Rescheduling replays a stale snapshot · **S3**

`ai_player.ex:337` and `:486` re-send the *original* `params` after 1000 ms. Those
params carry a full copy of the player's hand, buttons and visible tiles from a
second earlier; the AI then acts on that snapshot rather than current state.

### C4 — One synchronous call per tile per turn · **S3**

`ai_player.ex:235`

```elixir
|> Enum.filter(fn {tile, _i} -> GenServer.call(state.game_state, {:is_playable, state.seat, tile}, :infinity) end)
```

Fourteen blocking round-trips into the single `game_state` process that also
drives every other player, on every discard, with `:infinity` timeout.

### C5 — Bot speed is a compile-time constant, so batch testing is wall-clock bound · **S2 for your workflow**

`@ai_speed 4` (`ai_player.ex:11`) feeds `Process.sleep` at `ai_player.ex:293-301`,
`467-476`, `508`, `515` and `540`. `Debug.debug_fast_ai()` sounds like the escape
hatch but is only consulted once, in `init/1` (`ai_player.ex:19`) — it shortens
the startup delay and nothing else. A batch of bot games therefore costs real
seconds per discard. If you want to A/B a threshold over hundreds of games, this
is the first thing to make configurable.

### C6 — There are no tests for the AI · **S2**

`grep -rl "AIPlayer" test/` returns nothing. Nothing pins the behaviour of
`choose_discard/3`, `choose_american_discard/3` or `choose_american_call/2`, so a
regression like A1 can sit in the tree indefinitely. These three functions are
pure given their arguments and are the easy, high-value place to start.

### C7 — Debug switches committed in the "on" position · **S3**

`lib/riichi_advanced/game/game_state/debug.ex:16` `@debug_conditions true` and
`:28` `@print_txns true`. Also an unguarded `IO.inspect` in the chinitsu marking
path at `ai_player.ex:592`, and a print in `american.ex:603` guarded only by
`if seat == :east`.

---

## D. Observations outside the AI, noticed in passing

Not AI bugs, but they affect what the American AI can see:

- `priv/static/mods/american/am_card_nmjl_2021.jq:4` — `"222a 0000a 222b 1111b"`
  carries the card author's own `# <TODO: check whether 0000a here is a typo>`.
  `0000a` starts with `0`, so `preprocess_american_match_definition/1`
  (`american.ex:39`) routes it down the *unsuited* branch, where the trailing `a`
  hits `IO.inspect("Unknown character ...")` at `american.ex:55`. The hand is
  effectively unusable and prints noise.
- `priv/static/mods/american/am_card_nmjl_2021.jq:56` — `"FF 3333a 6676a 9999a"`.
  `6676a` parses as the mixed group 6-6-7-6, which makes it joker-ineligible and
  almost certainly is not the intended 369 hand.
