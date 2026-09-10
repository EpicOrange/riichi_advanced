# Recommended fixes

Suggested patches for the findings that block everything else. **Nothing here
has been applied to the source tree** — this folder is analysis only, and none
of these have been run against the real engine (Elixir was not available in the
environment this analysis was produced in). Treat them as starting points to
test, not as verified diffs.

---

## Fix 1 — make bot speed configurable (finding C5)

Do this first: without it, every A/B measurement below is bound by wall-clock
sleeps rather than compute.

`ai_player.ex:11` is a module attribute:

```elixir
@ai_speed 4
```

and `Debug.debug_fast_ai()` is consulted only in `init/1` (`ai_player.ex:19`), so
it shortens the 500 ms startup delay and nothing else. The five sleep sites are
`ai_player.ex:293-301`, `467-476`, `508`, `515` and `540`.

The smallest change that unblocks batch testing is to have
`Debug.debug_fast_ai()` mean what its name suggests — skip the pacing sleeps
entirely — rather than adding a new knob:

```elixir
defp pace(t, ms) do
  unless Debug.debug_fast_ai() do
    elapsed = System.os_time(:millisecond) - t
    wait = trunc(ms / @ai_speed)
    if elapsed < wait, do: Process.sleep(wait - elapsed)
  end
end
```

and call `pace(t, 1200)` / `pace(t, 120)` / `pace(t, 500)` at the five sites.
Note that `Debug` reads through `Process.get(:ignore_type_error, @default)`, so
the flag is per-process — check that it is actually set in the AI processes, not
just in `game_state`, before relying on it.

## Fix 2 — correct the American metric (findings A1, A2)

The quantity wanted is "how many more tiles do I need", which is
`length(hand ++ draw) - map_size(pairing_r)`, plus one when it is not your draw.
The two sites must change together.

`ai_player.ex:107-110`, in `choose_american_discard/3` (this one *is* on your
draw, so no `+1`):

```elixir
  defp choose_american_discard(state, playables, closest_american_hands) do
    # how many tiles are still missing from our closest hand
-   shanten = closest_american_hands
-   |> Enum.map(fn {_am_match_definition, pairing_r, _arranged_hand} -> 13 - map_size(pairing_r) end)
-   |> Enum.min(&<=/2, fn -> :infinity end)
+   hand_size = length(state.player.hand ++ state.player.draw)
+   shanten = closest_american_hands
+   |> Enum.map(fn {_am_match_definition, pairing_r, _arranged_hand} -> hand_size - map_size(pairing_r) end)
+   |> Enum.min(&<=/2, fn -> :infinity end)
```

and the filter three lines down that re-derives the same expression must use
`hand_size` too, or it will select the wrong subset of hands.

`ai_player.ex:139-142`, in `choose_american_call/2` (evaluated on someone else's
discard, so `+1`):

```elixir
-   shanten = closest_american_hands
-   |> Enum.map(fn {_am_match_definition, pairing_r, _arranged_hand} -> 13 - map_size(pairing_r) end)
-   |> Enum.min(&<=/2, fn -> :infinity end)
-   if shanten <= 3 do
+   hand_size = length(player.hand ++ player.draw)
+   needed = closest_american_hands
+   |> Enum.map(fn {_am_match_definition, pairing_r, _arranged_hand} -> hand_size - map_size(pairing_r) + 1 end)
+   |> Enum.min(&<=/2, fn -> :infinity end)
+   if needed <= @am_call_threshold do
```

`choose_american_call/2` currently destructures only `last_discard`,
`closest_american_hands` and `open_am_match_definitions` from `params`
(`ai_player.ex:129-133`), so `player` has to be added to that destructuring —
`game_state.ex:1797` already puts it in the map.

Then introduce the threshold as a named attribute so it is tunable in one place:

```elixir
@am_call_threshold 6
```

**Do not reuse `3`.** Experiment 4 in `04-experiments.md` shows that fixing the
denominator while keeping `<= 3` gives 0.70 exposures per game, slightly *worse*
than the 0.98 the bug currently produces. The simulation put the useful range
around 5–7; 6 is a reasonable starting point, and the real engine has a
charleston and joker swapping that the simulation does not, both of which advance
hands faster and may argue for a tighter number.

Fix the debug prints at `ai_player.ex:96` and `:123` at the same time — they
currently label this quantity "shanten", which is what makes the bug invisible
when you turn `@debug_ai` on.

## Fix 3 — characterisation tests (finding C6)

There are none today. The three decision functions are pure given their
arguments, so they can be tested without standing up a game. They are currently
`defp`; the usual options are to make them public with `@doc false`, or to test
through a thin wrapper.

The regression that matters most is A2's exposure floor, which is deterministic
and needs no randomness:

```elixir
test "an American bot with two exposures can still call" do
  # a hand that wants NNNN EEE WWW SSSS, with EEE and WWW already exposed
  # and two N in hand: a discarded N must be callable.
  assert AIPlayer.choose_american_call(params, 4) == 4
end
```

Worth pinning alongside it:

- `choose_american_discard/3` with `closest_american_hands: []` — today it
  silently returns hand position 0 (finding A4). Decide what it *should* do and
  assert that.
- `choose_discard/4` returns a playable index for a hand at each shanten from 0
  to 6, so the `Enum.drop` walk in `ai_player.ex:72` stays honest.

## Fix 4 — the cache handshake (findings A5, A6, A7)

Do this before tuning the threshold in Fix 2, not after: stale
`closest_american_hands` is currently indistinguishable from a bad heuristic, and
will make the tuning unmeasurable.

`game_state.ex:2131-2134` clears the pid after the first of four seats reports.
Track completion per seat instead, mirroring how playable indices already work —
`calculate_playable_indices_pids` is a map keyed by seat
(`game_state.ex:2090`, cleared per seat at `game_state.ex:2123`). The same shape
applied to `calculate_closest_american_hands_pid` fixes cancellation in
`kill_all_tasks/1` (`game_state.ex:1235`) and makes `conditions.ex:693`'s
`done_calculating` check mean what it says.

The `TODO` already in the tree at `game_state.ex:2142` proposes pausing the game
around the calculation. An alternative that avoids a pause: have the discard path
recompute synchronously the way the call path already does at
`game_state.ex:1793`, and treat the cache as display-only.

## Fix 5 — let default-ruleset bots call (finding B1)

`ai_player.ex:448-450` has `daiminkan`, `pon` and `chii` commented out in the
branch every ruleset except `fuzhou`/`vietnamese` falls into. Uncommenting them
as-is would make bots call unconditionally, which is worse than never calling —
`fuzhou`/`vietnamese` get away with it (`ai_player.ex:430-434`) because those
rulesets want maximal calling.

For riichi the call needs a gate of its own: call only if the call reduces
shanten, and only if the resulting hand can still have a yaku. `state.shanten` is
already tracked (`ai_player.ex:290`) and `Match.get_waits/4` is already used at
`ai_player.ex:250`, so the pieces are there. This is a design change rather than
a bug fix — worth its own pass, after the American work lands.
