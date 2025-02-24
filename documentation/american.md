# American Mah-Jongg (NMJL-style)

This documentation file contains the rules of American Mah-Jongg (NMJL-style), as might be implemented in an online client like Riichi Advanced. Some rules for real-life play may be found in the official rulebook published by the National Mah-Jongg League, [*Mah Jongg Made Easy*](https://www.nationalmahjonggleague.org/store.aspx).

See also [MahjongPros' ruleset](https://mahjongpros.com/blogs/how-to-play/beginners-guide-to-american-mahjong).

Note that American Mah-Jongg differs from the "base Asian mahjong variant" presented in [base.md](base.md) in many ways, so your knowledge of those variants may not necessarily transfer. Nevertheless, this ruleset assumes that you have read that one.

---
## TL;DR summary for American Mah-Jongg players:

Here are differences between Riichi Advanced and real life/other mahjong clients:

- Riichi Advanced will not let you draw a tile when you shouldn't, or discard a tile when you shouldn't. If you ever have more or fewer tiles than you're supposed to, that's a bug, and you should report it on the [Issues page](https://github.com/EpicOrange/riichi_advanced/issues) or in the Discord.
- Riichi Advanced will not let you make an incorrect exposure (i.e. one that isn't a Pung, Kong, or Quint) or Mah Jongg in error. It will, however, let you make exposures that would make your hand dead due to no hand on the Card being possible.
- Riichi Advanced requires you to name what kind of exposure you're calling for (Pung/Kong/Quint).
- Once you have made an exposure, Riichi Advanced will not let you edit the tiles in that exposure, even if you have not yet discarded or performed a joker exchange. You may, however, perform a joker exchange with the tiles in that exposure.
- Riichi Advanced will not require you to name your discards.
- Discards in Riichi Advanced are arranged in order in front of each player. (It's **Riichi** Advanced, so everything is a Riichi variant.)
- Riichi Advanced will keep the Window of Opportunity for calling a discard open until each player who can call it decides whether to call it or pass.
- Attempting to declare another player's hand dead may only be done on your turn. This is adjudicated by the game engine immediately. If you are correct, they are immediately disqualified; if you are incorrect, you are immediately disqualified instead. See the **Dead Hand** section below for more information.
- When a player is disqualified, all of their exposures remain exposed and available for joker exchanges (with none of them going back to their hand). This includes any exposures that "caused their hand to be dead", as well as any and all exposures that were made after this happened, and even if that player was playing a concealed hand. Again, see the **Dead Hand** section below for more information.
- Blind passes in the Charleston are evaluated starting with East, rather than with the player with the fewest tiles to blind-pass.
- There are seven buttons in the bottom left of the interface, used for automatic actions. See the **Auto-buttons in Riichi Advanced** section for more.
- Other differences listed in the "TODOS" section below:

---
## TODOS:

- Implement the 75-point hand on the AMJfE Card. Currently it's unimplemented because it would require us to write down 98 different hands.
- Implement Sextets. To be done when we implement a Card that has a Sextet.
- Implement score and exposed/concealed info for each hand in "Show Nearest Hands".

---
## Fundamentals

-  The wall for American consists of the 1-9 character tiles (Craks), 1-9 circle tiles (Dots), 1-9 bamboo tiles (Bams), the four wind tiles, the three dragon tiles, the four flower tiles, the four season tiles, and eight American joker tiles.
- Winning hands are no longer four sets and a pair, but are instead determined by a Card of winning hands (which usually changes annually, depending on which Card you use).
- Upon declaring a Kong or Quint, no replacement tiles are drawn. That is, hands are always exactly 13 tiles large before one's turn begins, winning on exactly 14.
- Chow may not be declared. In fact, sequences of tiles are treated identically to sets of unrelated single tiles.
- Quints may be declared, thanks to the existence of Jokers.
- Flower declarations don't exist.
- Flowers and seasons are all treated as identical flowers, and may form Pungs or Kongs or Quints. Flowers may be discarded.

## Exposures

- A Pung/Kong/Quint is specifically a set of three/four/five **identical** tiles.
- All other groups of tiles are either singles, pairs, or sets of singles. (e.g. NEWS, 2025, 123)
- An exposed Pung/Kong/Quint is called an "exposure".
- Discarded tiles may be called for Pungs, Kongs, Quints, and for Mah Jongg. They may not be called to form singles, pairs, or sets of singles.
- When two players call the same discard, Mah Jongg takes precedence over an exposure. Remaining ties are broken in favour of whoever is next in turn order.
- Unlike in many other Asian variants, you cannot upgrade a Pung to a Kong. Once a Pung/Kong/Quint is made, it must stay as a Pung/Kong/Quint respectively for the rest of the game.
- Unlike in many other Asian variants, you can only declare exposures off of discarded tiles. Concealed Kongs are not a thing.
- **Note that Riichi Advanced's implementation requires you to name what kind of exposure you're calling for, while the rules in *MJME* do not. Riichi Advanced will also not let you edit the tiles in your exposure, even if you have not yet discarded or performed a joker exchange, while the rules in *MJME* allow you to do so.**

## Jokers

- Tiles that aren't jokers are called "naturals".
- Jokers may stand for any tile, but may be used only in Pungs, Kongs, or Quints (and never in singles, pairs, or sets of singles).
- Jokers may be discarded, and discarded jokers may not be called for any reason (whether for exposure or for Mah Jongg).
- As many jokers as desired may be used in a Pung/Kong/Quint, whether it is exposed/concealed. (But an exposed Pung/Kong/Quint must contain at least one natural - the discarded natural that was called for exposure.)
- A player may perform a "joker exchange" on their own turn by swapping a (concealed) natural in their hand with a joker from an exposure matching that natural. (The exposure may belong to any player.)
- Players may perform any number of joker exchanges on their own turn.
- Note that a player's turn only starts after they have drawn a tile or finished making an exposure, so a player cannot perform a joker exchange with a discarded tile; nor can they first perform a joker exchange before calling a discarded tile for exposure.

## Charleston

- After everyone receives their starting hand, players go through up to seven rounds of passing tiles.
    - First Charleston (mandatory):
        - First pass: Each player passes three tiles from their hand to the player to their right.
        - Second pass: Each player passes three tiles from their hand to the player opposite.
        - Third pass: Each player passes three tiles from their hand to the player to their left. Optionally, a player may opt to Blind Pass.
    - Second Charleston (optional; only if everyone agrees to it):
        - Fourth pass: Each player passes three tiles from their hand to the player to their left.
        - Fifth pass: Each player passes three tiles from their hand to the player opposite.
        - Sixth pass: Each player passes three tiles from their hand to the player to their right. Optionally, a player may opt to Blind Pass.
    - Courtesy Pass (mandatory):
        - Seventh pass: Each player names a number of tiles to pass, between 0 and 3. Between them and the player opposite them, they pass the minimum of the two numbers named by them.
- Blind Pass: When a player blind-passes some tiles, they pass fewer than three tiles from their hand, and make up the rest of the three tiles to be passed with tiles that are about to be passed to them.
    - For instance, if a player opts to blind-pass a tile during the third pass, they may pass only two tiles from their hand to pass to their left, and a third tile to pass to their left, which will be randomly chosen from the tiles about to be passed to them by the player to their right.
    - Players do not get to look at the tiles about to be passed to them, or choose which tile about to be passed to them will be passed to their left, until after the third/sixth pass is over.
    - In Riichi Advanced, East always passes first. (This is different from *MJME*, which states that if multiple players wish to blind-pass, the player who blind-passes the fewest tiles passes first.)
    - Players may only draw tiles passed to them after they have passed three tiles themselves.
    - If everyone wishes to blind-pass three tiles, no pass occurs.
- Jokers may not be passed during the Charleston.
- If East has a winning hand before the First Charleston, they may instantly declare a win. The game ends before the First Charleston begins. (This does NOT apply if East obtains a winning hand during the Charleston.)

## Card

The following Cards are supported by Riichi Advanced:

- [NMJL 2024](https://www.nationalmahjonggleague.org/store.aspx) (cost: 14USD)
- [ILoveMahj Card](https://ilovemahj.com/ilmCard) (free)
- [ATeacherFirst Mah Jongg Fake Card](https://www.ateacherfirst.com/bridge/mah-jongg/) (free)
- [MahjLife Mock Card](https://mahjlife.com/document/mahj-life-mock-card-print/) (free, used with permission from Michele Frizzell)
- [American Mah Jongg for Everyone Card](https://americanmahjonggforeveryone.com/our-card-and-tile-set/) (free)

[TODO: implement the 75-point hand on the AMJfE Card.]

(The rest of this ruleset will use the free ILoveMahj Card as examples.)

To read the Card:

- Tiles that are grouped together are a single group, while tiles that are separated are not.
    - For instance, 2468 #1 requires a Kong of flowers, a single 2, a pair of 4, a Pung of 6 and a Kong of 8. This hand cannot be achieved by calling a Pung of flowers, and then having one extra flower in one's hand.
- Exposures do not have to be made in the order shown on the Card.
    - For instance, 2468 #1 may be made with a Kong of 8, then a Kong of Flowers, then a Pung of 6.
- Different colours (red, green, and black/blue) represent different suits. Note that a red number does NOT always correspond to Craks; green does NOT always correspond to Bams, and black/blue does NOT always correspond to Dots.
    - For instance, 2468 #3 requires Pungs of 2 and 4 of one suit (not necessarily Craks), and kongs of 6 and 8 of a second suit (not necessarily Bams, but must be different from the first suit).
- The three dragons are all considered suited; the red dragon belongs to the Craks suit, the green dragon with the Bams suit, and the white dragon with the Dots suit. Winds and flowers are unsuited.
    - For instance, 2468 #6 must have the Kong of Dragons be of a different suit from the Kongs of 4 and 8. If one has a Kong of 4 Bam, and a Kong of 8 Crak, then the Dragons must be of the Dots suit; i.e. it must be a White Dragon.
- A 0 on the Card represents a white dragon. When a white dragon is used as a 0, it is considered suitless (even if the Card represents it in colour).
    - For instance, Singles And Pairs #7 must be formed with three white dragons. Note that because they are separated, this hand cannot be achieved by calling a Pung of white dragons.
- 0s are NOT considered consecutive to 1 or to 9.
- The categories of Any Like Number, Quints, and Consecutive Runs are all "flexible", meaning that unless stated otherwise, any like numbers/consecutive numbers may be used to form these hands.
    - For instance, Consecutive Run #3 may also be formed with 44 5555 6666 7777. (But it can't be formed with 4444 5555 6666 77.)
- By contrast, all other categories are "fixed", meaning that, unless stated, ONLY the numbers shown may be used to form these hands.
    - For instance, 13579 #3 may NOT be formed with 3333 5555 555 777.
- Within a hand, any instance of `+`, `-`, `x`, `/`, `=`, or anything else that isn't a number or letter, is only there for aesthetics and should be ignored. (Usually, in the Math section.)
- To the right of each hand, an `x` indicates that the hand may contain exposures, while a `c` indicates that a hand MUST be concealed (except for the winning tile).
- To the right of each hand, the base score of each hand is shown.

## Scoring

- A hand scores for only the highest-scoring hand on the Card that it satisfies.
    - For instance, the hand 11 2222 333J 44JJ scores 40 for Quints #1 instead of 25 for Consecutive Run #3 (assuming the 3s and 4s are not exposed).
- A hand that is NOT from the Singles and Pairs category, and does not contain any jokers, has its score doubled.
- If the hand was won by a discard, the discarder pays twice this score, while everyone else pays this score.
- If this hand was won by self-draw, everyone pays twice this score.
- If the last move by the winner before declaring Mah Jongg was to perform a joker exchange, this counts as a win by self-draw no matter which exposure the joker was swapped from, or whether the winner's turn started by calling someone's discard.
- The dealer does not get any bonus multipliers for being dealer, unlike in many Asian mahjong variants.

## Dead Hand

- A dead hand is one which can no longer win, based on the contents of the discard pool and the exposures currently visible.
  - For instance, suppose a player has the exposed kongs 2222 Bams and 8888 Craks. They can only win with 2468 #7; their hand needs two more 4 Dots, two more 6 Dots, and two more flowers. If either three of the required 4 Dots, three of the required 6 Dots, or seven of the required flowers are visible in discards or in other player's exposures, their hand is dead.
- On a player's turn, they may declare any opponent's hand to be dead. (In Riichi Advanced, this is done by pressing the "💀❓" button next to that player's exposures.)
  - If the declarer is correct, that opponent is disqualified. The player with the current turn then continues their turn, which may include performing a joker exchange, and/or declaring another opponent's hand dead.
  - If the declarer is incorrect, the declarer is disqualified instead. They immediately end their turn without discarding, and play passes to the next non-disqualified player.
  - Disqualified players may no longer draw, discard, call tiles for exposure, perform joker exchanges, declare another player's hand dead, or declare Mah-Jongg. Their turns are fully skipped.
  - All exposures of a disqualified player remain on the table. Players may still perform joker exchanges with all jokers in such exposures, even if those exposures "caused the hand to become dead".
  - Players may not declare their own hand dead.
- If three players are disqualified, the game ends, with nobody paying anyone.

> #### NOTE: If you play American Mah-Jongg, the rules for dead hands in Riichi Advanced are different from the rules you may be used to. We couldn't find a clear description for how most players rule on dead hands, that also covered the many edge cases we could think of (*MJME* was insufficient). We also couldn't find agreement among experts on how some of these edge cases should be ruled. So, we decided to come up with our own ruleset, which avoids all of the Awful Rules Scenarios™ we came up with, while still allowing players to call other players' hands dead. We think this is the best compromise we can currently reasonably implement.

## Another Game

- Dealership always passes to the next player, regardless of whether the current dealer wins, and regardless of how many players were disqualified.

## Auto-buttons in Riichi Advanced

- In the lower left of the interface, there are seven buttons. These automatically do certain things for you, and they work as follows:
  - A: Auto Sort. This automatically sorts your hand by suit, then by increasing rank, with winds, dragons, jokers, and flowers on the right. This is enabled at the start of every hand by default. Should you wish to manually rearrange your hand by dragging tiles around, turn this off.
  - M: Auto Mah Jongg. This automatically declares Mah Jongg for you if it's possible.
  - C: Skip Calls. This skips all calls, except for Mah Jongg.
  - JC: Skip Joker Calls. Like Skip Calls, but this skips all calls that use only your jokers; i.e. that do not match a natural already in your hand. Useful for if you have two or more jokers in your hand and don't want to keep clicking "Cancel" on every discard.
  - DC: Skip Deadening Calls. Like Skip Calls, but this skips all calls that would result in your hand becoming dead. Enabled by default.
  - D: Auto Discard. Discards the tile you draw, unless you have the ability to swap a joker or declare Mah Jongg.
  - DD: Auto Discard Different. Like Auto Discard, but it only discards tiles that you don't already have in your hand.

---
## Mod list

The following mods are currently available for American:

- Show Waits: When you can discard a tile to become one tile away from winning, hovering over that tile will tell you what your winning tiles are, and will also tell you how many of them are still available. On by default.
- Show Nearest Hands: Shows the five nearest hands to yours, when you hover on the "Show Nearest Hands" button in the bottom right. [TODO: Implement score and exposed/concealed info for each hand in this display.]
- Open Hands: The contents of all hands are revealed to everyone. Primarily useful as a debug or teaching feature.
- Zombie Blanks: Adds four "zombie blanks" to the wall. Zombie blanks may not be passed during the Charleston. On a player's turn, they may swap a zombie blank in their hand with any natural tile in the discard pool. Blanks have no other purpose; they do not act as jokers; players may not declare Mah Jongg if they have a zombie blank in their hand; nor may they make exposures using blanks; or joker exchanges with blanks.
- ILM Card: Play with the free [ILoveMahj Card](https://ilovemahj.com/ilmCard).
- ATF Card: Play with the free [ATeacherFirst Mah Jongg Fake Card](https://www.ateacherfirst.com/bridge/mah-jongg/).
- MahjLife Card: Play with the free [MahjLife Mock Card](https://mahjlife.com/document/mahj-life-mock-card-print/). Introduced along with [this video](https://www.youtube.com/watch?v=7WygnpfFbMQ). (Implemented with permission from Michele Frizzell.)
- AMJFE Card: Play with the free [American Mah Jongg for Everyone Card](https://americanmahjonggforeveryone.com/our-card-and-tile-set/). (The 75-point hand is not yet implemented.)

The following mods are planned to be supported (not necessarily in this order):
- PIE: Each player starts with 600¢. If a player runs out of ¢, they need not pay.
- Stacks: Instead of performing the Charleston with other players, perform the Charleston with 7 stacks of 3 tiles in front of you. After the Charleston is complete, the remaining tiles are all shuffled back into the wall.
- Futures: Each player gets to peek at their next draw.
- Hot Wall: If a player deals in with a previously-undiscarded tile during the last portion of the wall, they pay for the table.
- Cold Wall: During the last portion of the wall, players may only win by self-draw.
- NMJL [Year] Card: Play with an NMJL Card from the year of your choice.
- Siamese [Year] Card: Play with the paid [Siamese Card](https://mahjongg.org/siamese-products/) from the year of your choice.
- Marvelous [Year] Card: Play with the paid [Marvelous Card](https://marvelousmahjongg.com/) from the year of your choice.
- MAHJ-X: Play with [MAHJ-X rules](https://www.mahjx.com/).
- Card Free: Play with [John Burton's Card Free American Mah Jongg rules](https://johnburtongames.com/cardfreemahj/).
- Siamese: Play with [Siamese rules](https://mahjongg.org/siamese-rules/).
- Royale Siamese: Play with [Royale Siamese rules](https://mahjongg.org/siamese-rules/#royale).
