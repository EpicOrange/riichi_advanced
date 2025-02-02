# [WIP] American Mah-Jongg (NMJL-style)

This documentation file contains the rules of American Mah-Jongg (NMJL-style), as might be implemented in an online client like Riichi Advanced. Full rules for real-life play may be found in the official rulebook published by the National Mah-Jongg League, [*Mah Jongg Made Easy*](https://www.nationalmahjonggleague.org/store.aspx).

See also [MahjongPros' ruleset](https://mahjongpros.com/blogs/how-to-play/beginners-guide-to-american-mahjong).

Note that American Mah-Jongg differs from the "base Asian mahjong variant" in many ways, so your knowledge of those variants may not necessarily transfer.

---
## TL;DR summary for American Mah-Jongg players:

Here are differences between Riichi Advanced and real life/other mahjong clients:

- Riichi Advanced will not let you draw a tile when you shouldn't, or discard a tile when you shouldn't.
- Riichi Advanced will not let you make an incorrect exposure (i.e. one that isn't a Pung, Kong, or Quint) or Mah Jongg in error. It will, however, let you make exposures that would make your hand dead due to no hand on the Card being possible.
- Riichi Advanced requires you to name what kind of exposure you're calling for (Pung/Kong/Quint).
- Once you have made an exposure, Riichi Advanced will not let you edit the tiles in that exposure, even if you have not yet discarded or performed a joker exchange.
- Riichi Advanced will not require you to name every discard.
- Riichi Advanced will pause the game and keep the Window of Opportunity for calling a discard open until each player who can call it decides whether to call it or pass it up.
- Blind passes in the Charleston are evaluated starting with East, rather than with the player with the fewest tiles to blind-pass.
- Death Challenges are currently not implemented. But when they are, they will be adjudicated instantly, and an incorrect challenge results in the challenger's hand being dead.
- Other differences listed in the "TODOS" section below:

---
## TODOS:

- Implement Heavenly Hand (East winning before the Charleston begins).
- Implement the 75-point hand on the AMJfE Card. Currently it's unimplemented because it would require us to write down 98 different hands.
- Check how the NMJL rules on the scenario "a player performs a Joker Exchange, then declares Mah Jongg; is it a win by self-draw?", in the following three cases:
  - The Joker Exchange was with someone else's exposure;
  - The Joker Exchange was with their own exposure from a previous turn;
  - The Joker Exchange was with their own exposure that they exposed on the same turn, just prior to attempting the Joker Exchange.
- Death Challenges:
  - Check whether this is implemented at all.
  - Implement the various scenarios of multiple players being declared dead.
  - Confirm with the NMJL as to which exposures may be joker-swapped after a player is declared dead, in the following cases (2024 NMJL Card):
    ![image](https://github.com/user-attachments/assets/52db32f6-744b-4e73-a3e6-9800df815f09)
  - Notes on each column:
    1. NEWS cannot be melded. Players did not notice this exposure was made until the second exposure was called. (Not possible in Riichi Advanced, included for completeness.)
    2. No hand on the 2024 NMJL Card with FFJ. Players did not notice this exposure was made until the second exposure was called.
    3. No hand on the 2024 NMJL Card with 11J 8*. But either exposure on its own would be fine.
    4. Only hand on the 2024 NMJL Card with 33J 66J off-suit must be concealed (369 #7). (But 33J 666J can be exposed CR #7.)
    5. Only hand on the 2024 NMJL Card with NNJ 11J must be concealed (W&D #7). (But NNJ 111J can be W&D #3.)
    6. Only hand on the 2024 NMJL Card with 11J N* must be concealed (W&D #7). (11J NNNJ is not a hand on the card.)
    7. Player is short a tile. (Not possible in Riichi Advanced, included for completeness.)
  - Notes on each row:
    1. Not possible in Riichi Advanced. Included for completeness.
    2. Will be treated differently from IRL, since there is no way to change an exposure after it's called in Riichi Advanced. Will likely be treated like row 3.
    3. Applicable to Riichi Advanced.
    4. Applicable to Riichi Advanced.
    5. Applicable to Riichi Advanced.
    6. Not possible in Riichi Advanced. Included for completeness.

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
- When two players call the same discard, Mah Jongg takes precedence over an exposure. Ties are broken in favour of whoever is next in turn order.
- **Note that Riichi Advanced's implementation requires you to name what kind of exposure you're calling for, while the rules in *MJME* do not. Riichi Advanced will also not let you edit the tiles in your exposure, even if you have not yet discarded or performed a joker exchange, while the rules in *MJME* allow you to do so.** Since we already pause the entire game for calls and don't allow you to misname tiles or draw out of turn, we gotta make some things harder than playing in person. :P

## Jokers

- Tiles that aren't jokers are called "naturals".
- Jokers may be used only in Pungs, Kongs, or Quints (and never in singles, pairs, or sets of singles).
- Jokers may be discarded, and discarded jokers may not be called for any reason (whether for exposure or for Mah Jongg).
- As many jokers as desired may be used in a Pung/Kong/Quint, whether it is exposed/concealed. (But an exposed Pung/Kong/Quint must contain at least one natural - the discarded tile that was called for exposure.)
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
    - If multiple players wish to blind-pass, the player who blind-passes the fewest tiles passes first.
    - If everyone wishes to blind-pass three tiles, no pass occurs.
- Jokers may not be passed during the Charleston.
- If East has a winning hand before the First Charleston, they may instantly declare a win. The game ends before the First Charleston begins. (This does NOT apply if East obtains a winning hand during the Charleston.) [TODO: Implement this.]

## Card

The following Cards are supported by Riichi Advanced:

- [NMJL 2024](https://www.nationalmahjonggleague.org/store.aspx) (cost: 14USD)
- [ILoveMahj Card](https://ilovemahj.com/ilmCard) (free)
- [American Mah Jongg for Everyone Card](https://americanmahjonggforeveryone.com/our-card-and-tile-set/) (free)
- [ATeacherFirst Mah Jongg Fake Card](https://www.ateacherfirst.com/bridge/mah-jongg/) (free)

[TODO: implement the 75-point hand on the AMJfE Card.]

To read the Card (using the free ILoveMahj Card as an example):

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
- By contrast, all other categories are "fixed", meaning that ONLY the numbers shown may be used to form these hands.
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
- If the last move by the winner before declaring Mah Jongg was to perform a joker exchange, this counts as a win by self-draw no matter whose exposure the joker was swapped from, or whether the winner's turn started by calling someone's discard. [TODO: The NMJL's rules aren't actually too clear on this point.]
- The dealer does not get any bonus multipliers for being dealer, unlike in many Asian mahjong variants.

## Death Challenge

[TODO: Check whether implementation of this in Riichi Advanced exists.]

- If one player suspects that a second player can no longer win based on public information (i.e. what has been exposed and discarded, but not the concealed contents of anyone's hands), they may declare that player dead. This is called a Death Challenge. [TODO: Check whether Riichi Advanced has Death Challenges implemented.]
- If the Death Challenge is valid, that player is now dead. If not, the challenger is now dead. (Note that this is different from *MJME*, where an incorrect Death Challenge results in the challenger paying 50¢ to the challenged.)
- Dead players may no longer draw, discard, call discards for exposure or Mah Jongg, perform joker exchanges, or declare other players dead. However, they still pay in the event of someone else winning.

- Any exposures made by a player on any turns prior to them being declared dead may still be used for joker exchanges, but any exposures made on that turn may not. [TODO: Check whether this is the case; specifically, if a player is declared dead after they have made an exposure but before they have discarded. Also check what the NMJL Rules say about being declared dead after making an exposure then a joker exchange but before discard.] [**UPDATE 2025-01-11**: Apparently the NMJL's own rules on this are very unclearly-worded. I'll have to ask someone to send in a letter for clarification.]
- Multiple players can go dead in a round. [TODO: Implement the scenario that if 3 players are declared dead, the hand is aborted.]

## Another Game

- Dealership always passes to the next player, regardless of whether the current dealer wins.

---
## Mod list

The following mods are currently available for American:

- Show Waits: When you can discard a tile to become one tile away from winning, hovering over that tile will tell you what your winning tiles are, and will also tell you how many of them are still available. On by default.
- Show Nearest Hands: Shows the five nearest hands to yours, when you hover on the "Show Nearest Hands" button in the bottom right.
- Open Hands: The contents of all hands are revealed to everyone. Primarily useful as a debug feature.
- ILM Card: Play with the free [ILoveMahj Card](https://ilovemahj.com/ilmCard).
- ATF Card: Play with the free [ATeacherFirst Mah Jongg Fake Card](https://www.ateacherfirst.com/bridge/mah-jongg/).
- AMJFE Card: Play with the free [American Mah Jongg for Everyone Card](https://americanmahjonggforeveryone.com/our-card-and-tile-set/). (The 75-point hand is not yet implemented.)

The following mods are planned to be supported (not necessarily in this order):

- Zombie Blanks: Adds four "zombie blanks" to the wall. Zombie blanks may not be passed during the Charleston. On a player's turn, **any other player** [note: wait, really?! // update: apparently this "only on others' turns" is specific to some playgroups and not others; need to decide how you want to implement this] may swap a zombie blank in their hand with any natural tile in the discard pool. Blanks have no other purpose; they do not act as jokers; players may not declare Mah Jongg if they have a zombie blank in their hand; nor may they make exposures using blanks; or joker exchanges with blanks.
- PIE: Each player starts with 600¢. If a player runs out of ¢, they need not pay.
- Stacks: Instead of performing the Charleston with other players, perform the Charleston with 7 stacks of 3 tiles in front of you. After the Charleston is complete, the remaining tiles are all shuffled back into the wall.
- Futures: Each player gets to peek at their next draw.
- Hot Wall: If a player deals in with a previously-undiscarded tile during the last portion of the wall, they pay for the table.
- Cold Wall: During the last portion of the wall, players may only win by self-draw.
- MAHJ-X: Play with [MAHJ-X rules](https://www.mahjx.com/).
- Card Free: Play with [John Burton's Card Free American Mah Jongg rules](https://johnburtongames.com/cardfreemahj/).
- Siamese: Play with [Siamese rules](https://mahjongg.org/siamese-rules/).
- Royale Siamese: Play with [Royale Siamese rules](https://mahjongg.org/siamese-rules/#royale).
- NMJL [Year] Card: Play with an NMJL Card from the year of your choice.
- Siamese [Year] Card: Play with the paid [Siamese Card](https://mahjongg.org/siamese-products/) from the year of your choice.
- Marvelous [Year] Card: Play with the paid [Marvelous Card](https://marvelousmahjongg.com/) from the year of your choice.
