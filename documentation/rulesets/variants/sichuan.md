# Sichuan Bloody Rules (SBR)

This ruleset assumes that you have read [base.md](/documentation/base.md).

The wall for SBR consists of the 1-9 character tiles, 1-9 circle tiles, and 1-9 bamboo tiles. Winds, dragons, flowers, and seasons are not used in this variant.

To win, you must achieve 4 sets and a pair (as usual), or seven pairs (may contain identical pairs).

Calling Chow is not allowed, but sequences still count as sets.

At the start of each round, each player names a "voided suit" that their winning hand will NOT contain. Players cannot win with their voided suit in hand.

Kong replacements are drawn from the live end of the wall.

When a player declares Hu, they stop playing. Multiple players can win on the same discard. All remaining players continue the round, until either one player is left, or the wall is exhausted. Players who have declared Hu are paid only by players who were still in the game when they declared Hu.

Players who are "ready" at an exhaustive draw are paid by non-winning non-ready players as if they had declared Hu after the last tile.

Players who have their voided suit in their hand at the end of the round pay a penalty of 48 points to the rest of the table, unless all their discards are of the voided suit.

---
Scoring may be found [here](https://www.mahjongpictureguide.com/pdf/SBR-Reference.pdf). Note that Riichi Advanced's implementation of SBR differs from the condensed rules found in the PDF, in the following ways:

* A player's first discard need not be of the voided suit. The voided suit of each player is displayed in the top left.
* Players who declare Hu have their hands revealed and paid for immediately, rather than at the end of the round.
* Kongs yield instant payments, instead of payments at the end of the round.
* The dealer for the next hand is always the first winner, even if multiple players win on the same discard. [TODO: Check who has priority in the latter case.]
* Temporary furiten might not be implemented yet. [TODO: Check if temporary furiten is implemented.]
