# Deep dive: the American call path

A full trace of what happens between "an opponent discards a tile" and "the bot
does not call it", so the fix can be aimed precisely. All line numbers are at
commit `2aa1d96`.

## The path

**1. A tile is discarded.** `Buttons.recalculate_buttons/1` gives every other
seat its button list. For American that includes `1_am_pung`, `2_am_kong`,
`3_am_quint`, `4_am_sextet` as applicable, plus `skip`
(`buttons.ex:14-19` — `skip` is appended unless an unskippable button exists).

**2. The AI is notified.** `game_state.ex:1790-1806`. For American specifically
the notification is wrapped in a task that recomputes the player's closest hands
*synchronously* first:

```elixir
closest_american_hands = American.compute_closest_american_hands(state, seat, win_definition, 5)
GenServer.cast(self, {:set_closest_american_hands, seat, closest_american_hands})
params = %{ ..., closest_american_hands: closest_american_hands,
            open_am_match_definitions: Rules.get(state.rules_ref, "open_win_definition", []) }
send(Map.get(state, seat), {:buttons, params})
```

So on the **call** path the data is fresh. (The discard path is not — see
finding A5.)

**3. `compute_closest_american_hands/4` builds `pairing_r`.**
`american.ex:516-621`. For each hand on the card it instantiates the target,
builds a bipartite graph between the player's tiles and the target's tiles, and
runs `Utils.maximum_bipartite_matching/1`. It returns the best five as
`{am_match_definition, pairing_r, arranged_hand}`.

The critical detail is at `american.ex:498-513`, in `instantiate_match_definition`:

```elixir
# remove calls from the instantiation -- any american hand must use every existing call
joker = for call <- calls, reduce: joker do
  ...
  case Enum.find_index(joker, &Match.remove_group(...)) do
    nil -> []   # call not found, abort
    i   -> List.delete_at(joker, i)
  end
end
```

Called groups are **deleted from the target** before matching. And the hand side
is `Utils.strip_attrs(hand ++ draw)` (`american.ex:517-522`), which is the
concealed hand only. So `pairing_r` is a map from *concealed hand indices* to
*concealed target slots*, and `map_size(pairing_r) <= length(concealed hand)`.

**4. The bot decides.** `ai_player.ex:408-425`:

```elixir
"1_am_pung" in player.buttons -> case choose_american_call(params, 3) do
  3 -> "1_am_pung"
  _ -> "skip"
end
```

**5. `choose_american_call/2` — the gate.** `ai_player.ex:128-161`:

```elixir
shanten = closest_american_hands
|> Enum.map(fn {_am, pairing_r, _arranged} -> 13 - map_size(pairing_r) end)
|> Enum.min(&<=/2, fn -> :infinity end)
if shanten <= 3 do
  closest_american_hands
  |> Enum.filter(...)          # only hands at that best shanten
  |> Enum.filter(...)          # only hands legal while open
  |> Enum.filter(...)          # only hands where the discard fills an "inactive" slot
  |> Enum.map(...)             # how many copies that hand wants
  |> Enum.filter(fn len -> len <= max_len end)
  |> Enum.max(&>=/2, fn -> 0 end)
else 0 end
```

Everything after `if shanten <= 3 do` is sound. The three filters and the
group-size logic correctly identify whether the discarded tile completes a group
in a hand the player can legally win while open. The problem is entirely that
control almost never reaches them.

## Why the gate almost never opens

### Scale mismatch

`13 - map_size(pairing_r)` counts tiles **not yet matched**. It is not shanten,
and it does not share shanten's range. Simulated over 4000 random deals against
the NMJL 2021 card, the median freshly dealt hand scores 7 and only 0.17% of
hands score ≤ 3. See `04-experiments.md`, Experiment 1.

Intuitively: a 13-tile American hand facing a 14-slot target typically has 5–6
tiles that fit somewhere in its best card hand, leaving 7–8 that do not.

### The exposure floor

This is the part that turns a badly tuned constant into a hard lock. Because
`map_size(pairing_r) <= length(concealed hand) = 13 - 3c` for `c` exposures:

```
13 - map_size(pairing_r)  >=  13 - (13 - 3c)  =  3c
```

| exposures | concealed | floor | `shanten <= 3`? |
|---|---|---|---|
| 0 | 13 | 0 | possible |
| 1 | 10 | 3 | requires all 10 concealed tiles matched |
| 2 | 7 | 6 | impossible |
| 3 | 4 | 9 | impossible |
| 4 | 1 | 12 | impossible |

A hand like `FF 2222a 44b 66b 8888a` needs two exposures. `NNNN EEE WWW SSSS`
needs three or four. The bot can reach the first and then, structurally, cannot
call again.

Note the direction of the error: the metric **increases by 3 with every
exposure**, while the hand is actually getting closer to complete. The corrected
form moves the opposite way, as it should:

| exposures | `13 - matched` (median) | `length(hand) - matched` (median) |
|---|---|---|
| 0 | 7 | 8 |
| 1 | 8 | 6 |
| 2 | 9 | 4 |
| 3 | 10 | 2 |

### The same expression is used for discards

`choose_american_discard/3` at `ai_player.ex:107-110` computes the identical
quantity. It only uses it for the debug print and to pick which of the five
closest hands to weight, so the damage is smaller — but the number printed by
`ai_player.ex:96` and `:123` as "N-shanten" is this same wrong quantity. Anyone
tuning the threshold by watching that print is reading the bug, not the hand.

## What a fix looks like

The metric wants to answer "how many more tiles do I need". With the target at
14 slots and calls filling `3c` of them:

```
tiles_still_needed = 14 - 3c - map_size(pairing_r)
                   = length(hand ++ draw) - map_size(pairing_r)   # on your draw
                   = length(hand ++ draw) - map_size(pairing_r) + 1  # otherwise
```

i.e. replace the constant `13` with `length(hand ++ draw)`. Because
`choose_american_call/2` is evaluated on someone else's discard, the `+1` form
applies there.

Then re-tune the threshold against the corrected distribution. At deal it runs
6–9 (`data/corrected_metric.txt`), and in the 200-game simulation gates around
`needs <= 5` to `needs <= 7` roughly halved the exhaustive-draw rate. Do not
carry the `3` across: `04-experiments.md` Experiment 4 shows that fixing the
denominator while keeping `<= 3` is slightly worse than the status quo.

A suggested patch is in `05-recommended-fixes.md`.

## One thing worth checking before tuning

`closest_american_hands` is capped at **five** hands (`game_state.ex:1793`, the
`5` argument). The list is correctly filtered for reachability — `win_definition`
switches to `open_win_definition` once the player has calls, and
`instantiate_match_definition` returns `nil` for any hand whose groups cannot
absorb the existing exposures (`american.ex:506-511`), leaving an empty
`pairing_r` that `american.ex:583` rejects.

What the cap does affect is ties. `american.ex:579` sorts by
`map_size(pairing_r)` descending and `american.ex:616` takes the first five;
Elixir's sort is stable, so when eight hands tie at the same match count the
surviving five are decided by card order. `choose_american_discard/3` then builds
its `usages` weights from that arbitrary subset. Not a correctness bug, but it
adds noise to exactly the signal you would be tuning against, so it is worth
raising the cap while measuring.
