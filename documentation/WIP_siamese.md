# Siamese Mah-Jongg

This documentation file contains the rules of American Mah-Jongg (NMJL-style), as might be implemented in an online client like Riichi Advanced. The official rules for real-life play may be found [here](https://mahjongg.org/siamese-rules/).

This ruleset assumes that you have read [american.md](documentation/american.md).

---
## TL;DR summary for Siamese Mah-Jongg players:

Here are differences between Riichi Advanced and real life/other mahjong clients:

- Riichi Advanced will not let you draw a tile when you shouldn't, or discard a tile when you shouldn't. If you ever have more or fewer tiles than you're supposed to, that's a bug, and you should report it on the [Issues page](https://github.com/EpicOrange/riichi_advanced/issues) or in the Discord.
- Riichi Advanced will not let you make an incorrect exposure (i.e. one that isn't a Pung, Kong, or Quint) or Mah Jongg in error. It will, however, let you make exposures that would make your hand dead due to no hand on the Card being possible.
- Riichi Advanced requires you to name what kind of exposure you're calling for (Pung/Kong/Quint).
- Once you have made an exposure, Riichi Advanced will not let you edit the tiles in that exposure, even if you have not yet discarded or performed a joker exchange. You may, however, perform a joker exchange with the tiles in that exposure.
- Riichi Advanced will not require you to name your discards.
- Discards in Riichi Advanced are arranged in order in front of each player. (It's **Riichi** Advanced, so everything is a Riichi variant.)
- Riichi Advanced will keep the Window of Opportunity for calling a discard open until each player who can call it decides whether to call it or pass.
- Attempting to declare another player's hand dead may only be done on your turn. This is adjudicated by the game engine immediately. If you are correct, that hand is immediately disqualified; if you are incorrect, you are immediately disqualified instead. See the **Dead Hand** section below for more information. <<TODO: update this when you find out what happens if you incorrectly declare another player's hand dead>>
- When a hand is disqualified, all of its exposures remain exposed and available for joker exchanges (with none of them going back to their hand). This includes any exposures that "caused that hand to be dead", as well as any and all exposures that were made after this happened, and even if that player was playing a concealed hand. Again, see the **Dead Hand** section below for more information. <<TODO: check this one>>
- There are seven buttons in the bottom left of the interface, used for automatic actions. See the **Auto-buttons in Riichi Advanced** section for more. <<TODO: check this one>>
- Other differences listed in the "TODOS" section below:

---
## TODOS:

- Implement Siamese Mah-Jongg.

as well as the following TODOs from American Mah-Jongg:
- Implement the Marvelous, and Mahjong Press Cards. Currently waiting to acquire copies of their Cards.
- Implement the 75-point hand on the AMJfE Card. Currently it's unimplemented because it would require us to write down 98 different hands.
- Implement the six missing hands on the MahjForAll Evergreen Card. Currently we need:
  - Some way for players to specify a year before drawing a Card;
  - Some way to indicate that jokers MAY NOT be used in a given grouping; and
  - Some way to indicate that flowers MAY be used as jokers in a given grouping.
- Double-check rules differences on the Mah Jongg Network and Mah Jongg Network Junior Cards.
- Implement Sextets. To be done when we implement a Card that has a Sextet.
- Implement score and exposed/concealed info for each hand in "Show Nearest Hands".

---
## Rules

Rules are similar to American Mah-Jongg, except with the following differences:
- Siamese Mah-Jongg is a 2-player game. Each player has two hands of tiles instead of one, and the goal is to Mah Jongg with both hands.
- Instead of rolling two dice to break the wall, East rolls a single die.
- Each player draws 27 tiles and places them within their two hands of tiles. There is no Charleston. East then draws a 28th tile.
- At any point, players may move tiles from either one of their hands to the other.
- On their turn, or after an opponent's discard, a player may declare Mah Jongg if either of their hands is Mah Jongg.
- Exposures are tied to a hand; e.g. if a player exposes 2222m and RRR on one hand, the player may not then move either exposure to the other hand, and any Mah Jongg on this hand must use both exposures.
- Tiles used in a Mah Jongg may not be moved to the other hand. Jokers used in a Mah Jongg may not be exchanged.
- A player may claim two Mah Jonggs at once, if both their hands are simultaneously Mah Jongg.
- The game ends either when one player has declared Mah Jongg with both hands, or when a player attempts to draw from an empty wall.

## Scoring

- The first Mah Jongg by a player scores the value on the Card, while the second Mah Jongg scores double the value on the Card. If both Mah Jonggs are declared simultaneously, both score double.
- A hand that is NOT from the Singles and Pairs category, and does not contain any jokers, has its score doubled.
- If a player discards a tile, and their opponent calls that tile for Mah Jongg, and their opponent wins on that same turn, the player pays an additional 25 points.
- If a player discards a tile, and their opponent calls that tile for exposure, and their opponent then declares Mah Jongg twice on that same turn, the player pays an additional 25 points.
- Unlike American Mah-Jongg, there is no bonus for self-picking, and players do not pay double on discarding a tile that gives another player Mah Jongg.

> #### NOTE: If you play Siamese Mah-Jongg, the scoring rules for Siamese Mah-Jongg in Riichi Advanced may look different from the official scoring rules. Since the official scoring rules suggest that the player with the lesser score pays the winner the difference between the two scores, they are mathematically the same. 

## Dead Hand

- A dead hand is one which can no longer win, based on the contents of the discard pool and the exposures currently visible.
- On a player's turn, they may declare any opponent's hand to be dead. (In Riichi Advanced, this is done by pressing the "💀❓" button next to that player's exposures.)
  - If the declarer is correct, that opponent's hand is disqualified. The player with the current turn then continues their turn, which may include performing a joker exchange, and/or declaring another opponent's hand dead.
  - If the declarer is incorrect, the declarer is disqualified instead. They immediately end their turn without discarding, and play passes to the next non-disqualified player. <<TODO: figure out if this is true in Siamese Mah-Jongg.>>
  - All exposures of a disqualified hand remain on the table. Players may still perform joker exchanges with all jokers in such exposures, even if those exposures "caused the hand to become dead".
  - Players may not declare their own hand dead.
- If both hands of a player are disqualified, the game ends, with the disqualified player paying their opponent four times the minimum of: the value of their opponent's existing Mah Jongg; or the lowest value on the Card.
- If a player has one dead hand and one Mah Jongg, they may no longer draw, discard, call tiles for exposure, perform joker exchanges, declare another player's hand dead, or declare Mah-Jongg. Their turn is fully skipped. Their opponent continues to play until the game ends normally.
- If a player has one dead hand and one alive hand, they continue to play, and may still move tiles between racks.
- If both players have one dead hand and one Mah Jongg, <<TODO: figure out what's supposed to happen here>>

> #### NOTE: If you play Siamese Mah-Jongg, the rules for dead hands in Riichi Advanced are different from the rules you may be used to. See [the corresponding note for American Mah-Jongg](documentation/american.md#note-if-you-play-american-mah-jongg-the-rules-for-dead-hands-in-riichi-advanced-are-different-from-the-rules-you-may-be-used-to-we-couldnt-find-a-clear-description-for-how-most-players-rule-on-dead-hands-that-also-covered-the-many-edge-cases-we-could-think-of-mjme-was-insufficient-we-also-couldnt-find-agreement-among-experts-on-how-some-of-these-edge-cases-should-be-ruled-so-we-decided-to-come-up-with-our-own-ruleset-which-avoids-all-of-the-awful-rules-scenarios-we-came-up-with-while-still-allowing-players-to-call-other-players-hands-dead-we-think-this-is-the-best-compromise-we-can-currently-reasonably-implement). 

## Royale Siamese

Royale Siamese is 3- or 4-player variant of Siamese Mah-Jongg. Rules are as Siamese Mah-Jongg, with the following changes:
- For 3-player Royale Siamese, the wall uses eight copies of each tile, except for flowers and jokers, of which there are twelve and zero respectively, for a total of 284 tiles. For 4-player, the wall uses eight copies of each tile, except for flowers and jokers, of which there are sixteen and zero respectively, for a total of 288 tiles. <<TODO: check if this is correct>>
- The scoring is different and is based on a pot, split equally between all players. <<TODO: scrap this and replace it with something better, because implementing this sounds like a nightmare.>>
- When multiple players wish to claim a tile, Double Mah Jongg takes precedence over all other calls, which are of equal precedence. Ties are broken by turn order.
- Atomic Hand. <<TODO: investigate this, the description on the Siamese Rules page is clear as mud.>>
