# [WIP] American Mah-Jongg (NMJL-style)

This documentation file contains the rules of American Mah-Jongg (NMJL-style), as might be implemented in an online client like Riichi Advanced. Full rules for real-life play may be found in the official rulebook published by the National Mah-Jongg League, [*Mah Jongg Made Easy*](https://www.nationalmahjonggleague.org/store.aspx).

Note that American Mah-Jongg differs from the "base Asian mahjong variant" in many ways, so your knowledge of those variants may not necessarily transfer.

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
    - Second Charleston (optional; any player may prevent the Second Charleston for the entire table, and move straight to the Courtesy Pass):
        - Fourth pass: Each player passes three tiles from their hand to the player to their left.
        - Fifth pass: Each player passes three tiles from their hand to the player opposite.
        - Sixth pass: Each player passes three tiles from their hand to the player to their right. Optionally, a player may opt to Blind Pass.
    - Courtesy Pass:
        - Seventh pass: Each player names a number of tiles to pass, between 0 and 3. Between them and the player opposite them, they pass the minimum of the two numbers named by them.
- Blind Pass: When a player blind-passes some tiles, they pass fewer than three tiles from their hand, and make up the rest of the three tiles to be passed with tiles that are about to be passed to them.
    - For instance, if a player opts to blind-pass a tile during the third pass, they may pass only two tiles from their hand to pass to their left, and a third tile to pass to their left, which will be randomly chosen from the tiles about to be passed to them by the player to their right.
    - Players do not get to look at the tiles about to be passed to them, or choose which tile about to be passed to them will be passed to their left, until after the third/sixth pass is over.
    - If multiple players wish to blind-pass, the player who blind-passes the fewest tiles passes first.
    - If everyone wishes to blind-pass three tiles, no pass occurs.
- Jokers may not be passed during the Charleston.
- If East has a winning hand before the First Charleston, they may instantly declare a win. The game ends before the First Charleston begins. (This does NOT apply if East obtains a winning hand during the Charleston.)

## Card

The following Cards are supported by Riichi Advanced:

- [NMJL 2024](https://www.nationalmahjonggleague.org/store.aspx) (cost: 14USD)
- [ILoveMahj Card](https://ilovemahj.com/ilmCard) (free)
- [American Mah Jongg for Everyone Card](https://americanmahjonggforeveryone.com/our-card-and-tile-set/) (free)
- [ATeacherFirst Mah Jongg Fake Card](https://www.ateacherfirst.com/bridge/mah-jongg/) (free)

To read the Card (using the free ILoveMahj Card as an example):

- Tiles that are grouped together are a single group, while tiles that are separated are not.
    - For instance, 2468 #1 requires a Kong of flowers, a single 2, a pair of 4, a Pung of 6 and a Kong of 8. This hand cannot be achieved by calling a Pung of flowers, and then having one extra flower in one's hand.
- Exposures do not have to be made in the order shown on the card.
    - For instance, 2468 #1 may be made with a Kong of 8, then a Kong of Flowers, then a Pung of 6.
- Different colours (red, green, and black/blue) represent different suits. Note that a red number does NOT always correspond to Craks; green does NOT always correspond to Bams, and black/blue does NOT always correspond to Dots.
    - For instance, 2468 #3 requires Pungs of 2 and 4 of one suit (not necessarily Craks), and kongs of 6 and 8 of a second suit (not necessarily Bams, but must be different from the first suit).
- The three dragons are all considered suited; the red dragon belongs to the Craks suit, the green dragon with the Bams suit, and the white dragon with the Dots suit. Winds and flowers are unsuited.
    - For instance, 2468 #6 must have the Kong of Dragons be of a different suit from the Kongs of 4 and 8. If one has a Kong of 4 Bam, and a Kong of 8 Crak, then the Dragons must be of the Dots suit; i.e. it must be a White Dragon.
- A 0 on the card represents a white dragon. When a white dragon is used this way, it is whichever suit it needs to be to fit that winning hand on the Card.
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

- A hand that is NOT from the Singles and Pairs category, and does not contain any jokers, has its score doubled.
- If the hand was won by a discard, the discarder pays twice this score, while everyone else pays this score.
- If this hand was won by self-draw, everyone pays twice this score.
- If the last move by the winner before declaring Mah Jongg was to perform a joker exchange, this counts as a win by self-draw no matter whose exposure the joker was swapped from, or whether that player's turn started by calling someone's discard. [TODO: The NMJL's rules aren't actually too clear on this point. I've asked someone to send in a letter for clarification.]
- The dealer does not get any bonus multipliers for being dealer, unlike in many Asian mahjong variants.

## Death Challenge

- If one player suspects that a second player can no longer win based on public information (i.e. what has been exposed and discarded, but not the concealed contents of anyone's hands), they may declare that player dead. This is called a Death Challenge.
- If the Death Challenge is valid, that player no longer draws or discards. Any exposures made on any turns prior to them being declared dead may still be used for joker exchanges, but any exposures made on that turn may not.
- If it is invalid, the challenger pays 50¢ to the defender, and the game continues. (Note that Riichi Advanced's implementation is different from the *MJME* rules.) [TODO: Check whether this is in fact how this is implemented in Riichi Advanced.]
- Multiple players can go dead in a round. [TODO: Check whether these scenarios are implemented in Riichi Advanced.]

## Another Game

- Dealership always passes to the next player, regardless of whether the current dealer wins.
