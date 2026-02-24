# Zung Jung

This ruleset assumes that you have read [base.md](base.md). The primary source for this guide is [Alan Kwan's site](https://www.zj-mahjong.info/index.html#English).

The wall for HKOS consists of the 1-9 character tiles, 1-9 circle tiles, 1-9 bamboo tiles, the four wind tiles, and the three dragon tiles.

To win, you must achieve one of the following:

- Four sets and a pair (as usual)
- One of each terminal/honor tile, plus one extra among these (aka "Thirteen Terminals")
- Seven pairs

---
## Yaku List

Indented yaku override their prerequisite yaku.

- All Sequences: Your hand consists of four squences and a pair. No other restrictions. 5 points.
- Concealed Hand: Your hand is concealed. (Concealed kong and winning on discards are allowed.) 5 points.
- No Terminals: Your hand consists of only tiles 2~8. No terminals or honours. 5 points.

- Mixed One-Suit: Your hand consists of only tiles of one suit, plus honour tiles. 40 points.
  - Pure One-Suit: Your hand consists of only tiles of one suit. 80 points.
- Nine Gates: Your hand consists of 1112345678999 in one suit, plus an extra winning tile. You must have a nine-sided wait to score this hand. 480 points.

- Value Honor: Your hand has a triplet/kong of your seat wind, or a triplet/kong of dragons. (There is no prevailing wind.) 10 points per triplet/kong.
- Small Three Dragons: Your hand has two triplets/kongs of dragons, and a pair of the third. 40 points.
  - Big Three Dragons: Your hand has three triplets/kongs of dragons. 130 points.
- Small Three Winds: Your hand has two triplets/kongs of winds, and a pair of a third. 30 points.
  - Big Three Winds: Your hand has three triplets/kongs of winds. 120 points.
    - Small Four Winds: Your hand has three triplets/kongs of winds, and a pair of the fourth. 320 points.
      - Big Four Winds: Your hand has four triplets/kongs of winds. 400 points.
- All Honors: Your hand consists of only honour tiles. 320 points.

- All Triplets: Your hand consists of four triplets and a pair. 30 points.
- Two Concealed Triplets: Your hand has two concealed triplets/kongs. 5 points.
  - Three Concealed Triplets: Your hand has three concealed triplets/kongs. 30 points.
    - Four Concealed Triplets: Your hand has four concealed triplets/kongs. 125 points.
- One Kong: Your hand has one kong. 5 points.
  - Two Kongs: Your hand has two kongs. 20 points.
    - Three Kongs: Your hand has three kongs. 120 points.
      - Four Kongs: Your hand has four kongs. 480 points.
      
- Two Identical Sequences: Your hand contains two sequences of the same numbers in the same suit. 10 points.
  - Two Identical Sequences Twice: Your hand contains two disjoint instances of the above configuration. 60 points.
    - Three Identical Sequences: Your hand contains three sequences of the same numbers in the same suit. 120 points.
      - Four Identical Sequences: Your hand contains four sequences of the same numbers in the same suit. 480 points.

- Three Similar Sequences: Your hand contains three sequences of the same numbers in three different suits. 35 points.
- Small Three Similar Triplets: Your hand contains two triplets/kongs of the same number in two different suits, and a pair of that number in the third suit. 30 points.
  - Three Similar Triplets: Your hand contains three triplets/kongs of the same number in three different suits. 120 points.

- Nine-Tile Straight: Your hand contains the sequences 123, 456, and 789 in the same suit. 40 points.
- Three Consecutive Triplets: Your hand contains three triplets/kongs in consecutive numbers, in the same suit. 100 points.
  - Four Consecutive Triplets: Your hand contains four triplets/kongs in consecutive numbers, in the same suit. 200 points.
  
- Mixed Lesser Terminals: Each meld of your hand, including the pair, contains a terminal or honour. 40 points.
  - Pure Lesser Terminals: Each meld of your hand, including the pair, contains a terminal. 50 points.
    - Mixed Greater Terminals: Your hand consists entirely of terminal and honour tiles (and isn't Thirteen Terminals). 100 points.
      - Pure Greater Terminals: Your hand consists entirely of terminal tiles. 400 points.
      
- Final Draw: Win off the final draw of the wall. 10 points.
  - Final Discard: Win off the final discard of the game. 10 points.
- Win on Kong: Win off the replacement tile after declaring a kong. 10 points.
- Robbing a Kong: Win by robbing a kong. 10 points.
- Blessing of Heaven: As East, win on your first draw. Calling a Kong invalidates this. 155 points.
  - Blessing of Earth: As any player other than East, win off East's first discard. East calling a Kong invalidates this. 155 points.
  
- Thirteen Terminals: Your hand consists of one of each terminal/honor tile, plus one extra among these. 160 points.
- Seven Pairs: Your hand consists of seven pairs. Four of the same tile can be used as two pairs (as long as they aren't declared as a kong). 30 points.

---
## Scoring scheme

There is no minimum point requirement. However, hands are capped at a limit of 320 points, unless they satisfy a yaku worth more than 320 points (in which case, they score for their highest-scoring yaku).

When a player wins by self-draw, each opponent pays the value of the winner's hand.

When a player wins by discard:

* If the hand scores 25 points or less, or if the winner is the "responsible player", each opponent pays the value of the winner's hand.

* Otherwise, the "responsible player" pays three times the value of the winner's hand, less 50 points; the other two players each pay 25 points.

The responsible player is the first person to have discarded the tile the winner won off of, during the same go-around. (The motivation is that you should never be "responsible" if you discard the same tile as the player to your left.)

In every case, the winner gains three times the value of their hand.

---
## Mods

* Bonus Tiles: Adds flower/season tiles to the game. Seat flowers/seasons are worth 4 each, guest flowers/seasons are worth 2 each. A set of four flowers/seasons is worth 10 each.

* 5 Point Minimum: Adds a 5 point minimum requirement to win.

* Uniform Payoff Scheme (not yet implemented): On every win, everyone pays the winner the value of the winner's hand.
