# [WIP] American Mah-Jongg (NMJL-style)

The wall for American consists of the 1-9 character tiles (Craks), 1-9 circle tiles (Dots), 1-9 bamboo tiles (Bams), the four wind tiles, the three dragon tiles, the four flower tiles, the four season tiles, and eight American joker tiles.

American Mah-Jongg differs from the "base Asian mahjong variant" many ways:

## Fundamentals

- Winning hands are no longer four sets and a pair, but are instead determined by a Card of winning hands (which usually changes annually, depending on which Card you use).
- Upon declaring a Kong or Quint, no replacement tiles are drawn. That is, hands are always exactly 13 tiles large before one's turn begins, winning on exactly 14.
- Chow may not be declared. In fact, sequences of tiles are treated identically to sets of unrelated single tiles.
- Quints may be declared, thanks to the existence of Jokers.
- Flower declarations don't exist. Instead, flowers are all treated identically, like any other tile, and may form Pungs or Kongs or Quints.

## Exposures

- A Pung/Kong/Quint is specifically a set of three/four/five **identical** tiles.
- An exposed Pung/Kong/Quint is called an "exposure".
- All other groups of tiles are either singles, pairs, or sets of singles. (e.g. NEWS, 2025, 123)

## Jokers

- Tiles that aren't jokers are called "naturals".
- American jokers may be used only in Pungs, Kongs, or Quints (and never in singles, pairs, or sets of singles).
- Jokers may be discarded, and discarded jokers may not be called for exposure or for Mah Jongg.
- An exposure must be made from a discarded natural, plus matching naturals/jokers from a player's hand.
- As many jokers as desired may be used in a Pung/Kong/Quint, whether it is exposed/concealed.
- Suppose a player has an exposure containing a joker. A player who has a (concealed) natural in their hand matching that exposure may, on their turn, swap their natural with that joker. (This includes swapping a natural from one's own hand with a joker from one's own exposure.)

## Card

The following Cards are supported by Riichi Advanced:

- [NMJL 2024](https://www.nationalmahjonggleague.org/store.aspx#) (cost: 14USD)
- [ILoveMahj Card](https://ilovemahj.com/ilmCard) (free)
- [American Mah Jongg for Everyone Card](https://americanmahjonggforeveryone.com/our-card-and-tile-set/) (free)
- [ATeacherFirst Mah Jongg Fake Card](https://www.ateacherfirst.com/bridge/mah-jongg/) (free)

To read the Card (using the free ILoveMahj Card as an example):

- Tiles that are grouped together are a single group, while tiles that are separated are not.
    - For instance, 2468 #1 requires a Kong of flowers, a single 2, a pair of 4, a Pung of 6 and a Kong of 8. This hand cannot be achieved by calling a Pung of flowers, and then having one extra flower in one's hand.
- Different colours (red, green, and black/blue) represent different suits. Note that a red number does NOT always correspond to Craks; green does NOT always correspond to Bams, and black/blue does NOT always correspond to Dots.
    - For instance, 2468 #3 requires Pungs of 2 and 4 of one suit (not necessarily Craks), and kongs of 6 and 8 of a second suit (not necessarily Bams, but must be different from the first suit).
- The three dragons are all considered suited; the red dragon belongs to the Craks suit, the green dragon with the Bams suit, and the white dragon with the Dots suit. Winds and flowers are unsuited.
    - For instance, 2468 #6 must have the Kong of Dragons be of a different suit from the Kongs of 4 and 8. If one has a Kong of 4 Bam, and a Kong of 8 Crak, then the Dragons must be of the Dots suit; i.e. it must be a White Dragon.
- A 0 on the card represents a white dragon. When a white dragon is used this way, it is whichever suit it needs to be to fit that winning hand on the Card.
    - For instance, Singles And Pairs #7 must be formed with three white dragons. Note that because they are separated, this hand cannot be achieved by calling a Pung of white dragons.
- The categories of Any Like Number, Quints, and Consecutive Runs are all "flexible", meaning that unless stated otherwise, any like numbers/consecutive numbers may be used to form these hands.
    - For instance, Consecutive Run #3 may also be formed with 44 5555 6666 7777. (But it can't be formed with 4444 5555 6666 77.)
- By contrast, all other categories are "fixed", meaning that ONLY the numbers shown may be used to form these hands.
    - For instance, 13579 #3 may NOT be formed with 3333 5555 555 777 (even if they would be in the correct suits).
- Within a hand, any instance of `+`, `-`, `x`, `/`, `=`, or anything else that isn't a number or letter, is only there for aesthetics and should be ignored. (Usually, in the Math section.)
- To the right of each hand, an `x` indicates that the hand may contain exposures, while a `c` indicates that a hand MUST be concealed (except for the winning tile).
- To the right of each hand, the base score of each hand is shown.

## Scoring

- If the hand was won by a discard, the discarder pays twice this score, while everyone else pays this score.
- If this hand was won by self-draw, everyone pays twice this score.
- A hand that is NOT from the Singles and Pairs category, and does not contain any jokers, has its score doubled.
- If the last move by the winner before declaring Mah Jongg was to perform a joker exchange, this counts as a win by self-draw no matter whose exposure the joker was swapped from, or whether that player's turn started by calling someone's discard.
[comment]: # The NMJL's rules aren't actually too clear on this point. I've asked someone to send in a letter for clarification.



