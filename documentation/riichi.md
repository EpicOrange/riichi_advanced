# Riichi Mahjong in brief

Riichi is a four-player game played with 34 different kinds of tiles:

- numbered 1-9 character tiles ![](tiles/1m.svg)![](tiles/2m.svg)![](tiles/3m.svg)![](tiles/4m.svg)![](tiles/5m.svg)![](tiles/6m.svg)![](tiles/7m.svg)![](tiles/8m.svg)![](tiles/9m.svg) (__manzu__),
- numbered 1-9 circle tiles ![](tiles/1p.svg)![](tiles/2p.svg)![](tiles/3p.svg)![](tiles/4p.svg)![](tiles/5p.svg)![](tiles/6p.svg)![](tiles/7p.svg)![](tiles/8p.svg)![](tiles/9p.svg) (__pinzu__),
- numbered 1-9 bamboo tiles ![](tiles/1s.svg)![](tiles/2s.svg)![](tiles/3s.svg)![](tiles/4s.svg)![](tiles/5s.svg)![](tiles/6s.svg)![](tiles/7s.svg)![](tiles/8s.svg)![](tiles/9s.svg) (__souzu__),
- four wind tiles ![](tiles/1z.svg)![](tiles/2z.svg)![](tiles/3z.svg)![](tiles/4z.svg) (east, south, west, north),
- and three dragon tiles ![](tiles/5z.svg)![](tiles/6z.svg)![](tiles/7z.svg) (white dragon, green dragon, red dragon).

There are four copies of each tile, giving a total of 136 tiles in the __wall__. In addition, one of the four "five" tiles in each suit ![](tiles/5m.svg)![](tiles/5p.svg)![](tiles/5s.svg) is a red five ![](tiles/0m.svg)![](tiles/0p.svg)![](tiles/0s.svg) which is worth extra (explained later). Riichi Advanced mods may add or subtract from this tileset, but this is the default tileset. In the game messages, manzu are notated 1m to 9m, pinzu 1p to 9p, souzu 1s to 9s, wind tiles 1z to 4z, and dragons 5z to 7z, in the order indicated above. Red fives are notated 0m, 0p, or 0s.

The goal of riichi is to maximize your points, which start at 25000. To earn points, you must be the first in each round to complete a 14-tile hand. A hand is defined as one of the following:

- Four sets and a pair,
- Seven pairs, or
- Each 1 and 9 of each suit (terminals) plus one of each wind and dragon (honor tiles), plus a 14th tile that is a copy of one of those tiles.

The latter two are considered special hands, and are difficult to achieve. The majority of hands (>97%) are four sets and a pair.

A __set__ is either a 3-tile sequence, like ![](tiles/1p.svg)![](tiles/2p.svg)![](tiles/3p.svg), or a triplet, like ![](tiles/2z.svg)![](tiles/2z.svg)![](tiles/2z.svg). Your starting hand of 13 tiles might not contain any ready-made sets, so you must progress your hand by drawing and discarding tiles. You do not declare your sets when they are made; they remain hidden in your hand.

The game starts with everyone being dealt 13 tiles from the wall. The East player (also known as the __dealer__) is dealt a 14th tile to start the game. Play starts from the dealer's first discard and continues counterclockwise, with each player drawing and discarding a tile.

## Riichi and winning

Once your hand is one-away from a winning hand (__tenpai__), hovering over a tile shows you your winning tiles if you discard that tile. For example, if your hand is ![](tiles/2m.svg)![](tiles/3m.svg)![](tiles/4m.svg)![](tiles/1p.svg)![](tiles/2p.svg)![](tiles/3p.svg)![](tiles/7p.svg)![](tiles/7p.svg)![](tiles/3s.svg)![](tiles/4s.svg)![](tiles/8s.svg)![](tiles/8s.svg)![](tiles/1z.svg) ![](tiles/7p.svg), then hovering over the ![](tiles/1z.svg) will show that you are __waiting__ for ![](tiles/2s.svg)![](tiles/5s.svg) to complete your hand of four sets and a pair. Once someone discards ![](tiles/2s.svg) or ![](tiles/5s.svg), you may call __ron__ to claim it and complete your hand. Alternatively, if you draw ![](tiles/2s.svg) or ![](tiles/5s.svg) yourself, then you may call __tsumo__ to claim it and complete your hand.

When tenpai, you may declare __riichi__. This means betting 1000 points, locking your hand, and telling everyone that you are near a win, which are all significant downsides. This is indicated on the board by a sideways discard. Once you declare riichi you are locked to discarding every tile you draw until you draw one of your winning tiles, or until someone discards one of your winning tiles. This makes riichi a bit of a gamble. The upside is that riichi is worth 1 han, the basic scoring unit. __All hands require 1 han to win__, making riichi very valuable. Hand conditions that give you han are called __yaku__, and riichi is one of the most common (occuring in around 41% of hands).

If you manage to win before your next discard (after your riichi declaration discard), you earn a bonus yaku associated with riichi is called __ippatsu__, which is worth 1 han.

Some rare conditions in which you cannot riichi: you cannot riichi if you have less than 1000 points or if there are not enough tiles left in the wall for you to have a next draw.

## Calls

One a tile has been discarded, often the next player in turn continues by drawing their tile. However, this process can be interrupted by calling the discarded tile. There are three possible calls on discarded tiles:

- __Chii__: If you are next in turn order, and the discarded tile completes a __sequence__, instead of drawing a tile you may claim the discard and set aside the completed sequence. Then you must discard a tile as usual. All tiles set aside are considered part of your hand, but are visible to all and cannot be discarded.
- __Pon__: Even if you are not next in turn order, if the discarded tile completes a __triplet__, you may claim the discard and set aside the completed triplet. Pon overrides chii, and also changes the turn order (it becomes your turn to discard). Like with chii, all tiles set aside are considered part of your hand, but are visible to all and cannot be discarded.
- __Kan__: If you have a triplet of the discarded tile in hand, you may call kan to claim the discard and set aside the completed __quad__, which is considered to be a triplet for winning purposes. It becomes your turn, and you draw a replacement tile from the back of the wall (the __dead wall__). We will go into detail about kan and quads in a bit.

As soon as you call a discard, your hand is considered __open__, and __you may no longer declare riichi__. This is a big downside of calling, so many players are hesitant to call, even if it means progressing their hand.

As a small bonus, calls also invalidate ippatsu, so if someone declares riichi and you call a tile before their next discard, and they end up winning before their next discard, they do not get ippatsu because of your call.

A triplet of dragons, like ![](tiles/7z.svg)![](tiles/7z.svg)![](tiles/7z.svg), is considered a __value triplet__, or __yakuhai__, and always worth 1 han each. Yakuhai is also one of the most common yaku (occurring in around 50% of hands). This means that dragons are often called, because even though it means you cannot call riichi, the 1 han allows one to achieve a winning hand. A triplet of winds is also yakuhai if it matches either the round marker or your seat marker (or both, totalling 2 han). All games start in the East round, so at the beginning east winds ![](tiles/1z.svg) are often desirable to keep and call.

## Exhaustive draw

The __dead wall__ consists of the 14 tiles at the end of the wall. The game ends (with no winner) once the wall is exhausted and only the dead wall remains.

During an exhaustive draw, players who are tenpai are paid by players who are not tenpai. The payment amount depends on the number of tenpai players:

- 0 tenpai players: no payment
- 1 tenpai player: they are paid 1000 from everyone else
- 2 tenpai players: each non-tenpai player pays one of the tenpai players 1500
- 3 tenpai players: the non-tenpai player pays everyone 1000
- 4 tenpai players: no payment

In addition, the __honba__ counter is increased by one. Each honba adds 300 to the value of the next winning hand. The honba counter also increases by one every time the dealer (East player) wins. If a nondealer wins, honba is reset to zero.

## Dora

If playing with dora (on by default in Riichi Advanced) the dead wall features a __dora indicator__. In Riichi Advanced, dora indicators are displayed at the top of the screen. If the dora indicator is ![](tiles/1p.svg), then we consider all ![](tiles/2p.svg) in-game to be __dora__. The rule is that the dora indicator indicates the next tile in sequence to be dora. ![](tiles/9p.svg) wraps around to ![](tiles/1p.svg), and for honor tiles, the rule is ![](tiles/1z.svg)→![](tiles/2z.svg)→![](tiles/3z.svg)→![](tiles/4z.svg)→![](tiles/1z.svg) and ![](tiles/5z.svg)→![](tiles/6z.svg)→![](tiles/7z.svg)→![](tiles/5z.svg).

If you win a hand, every dora tile in your hand grants a bonus 1 han. Dora is the most space-efficient way to get han. Keep in mind: it is often said that __dora is not yaku__. This is important because __every hand must have yaku to win__, and dora does not count.

The wall is physically made of two-tile-tall stacks, so the dead wall is 7 stacks with one of the top layer tiles flipped as the dora indicator. The tile under the dora indicator is known as the __ura dora__ indicator. These are not shown until somebody __who has declared riichi__ wins. Players who win with riichi get access to the ura dora indicators, which act the same as the dora indicators by indicating an additional tile that counts as dora, and this is called __ura dora__. Like dora, ura dora is not yaku. Players who win but not in riichi do not get access to ura dora.

Red fives always count as dora, and are known as __aka dora__.

## Kan

As discussed previously, you may call kan on a discarded tile if you have three copies of that tile in hand. This opens your hand (you forgo riichi). In addition, after your kan replacement tile draw and your subsequent discard, an additional dora indicator is revealed in the dead wall. A maximum of four kans can be made in one game, meaning five potential dora indicators maximum. (On the fourth kan, the game ends in an abortive draw.)

Ura dora indicators consist of every tile under a dora indicator, so kans also add ura dora to the game. Therefore, every kan makes riichi even more valuable.

Most players do not kan (<5% call rate) unless they are confident in winning or are desperate for points. This is because the additional dora / ura dora will likely go to your opponents.

There are three ways to kan, and they all involve forming quads:

- __Daiminkan__: This is calling a discard with a triplet of the same tile in hand, as discussed previously.
- __Shouminkan__ or __Kakan__: If you called pon on ![](tiles/6z.svg)![](tiles/6z.svg)![](tiles/6z.svg) and later draw a ![](tiles/6z.svg), you may call kan during your turn to add your drawn ![](tiles/6z.svg) to the existing pon. Like with daiminkan, you draw a replacement tile and reveal a new dora indicator after your discard.
- __Ankan__: If at any point during your turn you have four of the same tile in hand, such as ![](tiles/0p.svg)![](tiles/5p.svg)![](tiles/5p.svg)![](tiles/5p.svg), you may call kan to set those aside and draw a replacement tile. Ankan importantly __does not open your hand__, so you may still call riichi after this. In addition, the new dora indicator is revealed immediately rather than after your discard.

## Yaku

There are a number of yaku in riichi mahjong, but the following six are the most common:

- Yakuhai (~50% of hands): discussed previously. 1 han each.
- Riichi (~41% of hands): discussed previously. 1 han.
- Tsumo (~25% of hands): When your hand is __closed__ (no calls, except ankan) and you win by tsumo (self-draw), you get 1 han.
- Tanyao (~22% of hands): Your hand consists of only tiles 2-8. So no ones, nines, winds, or dragons. 1 han.
- Pinfu (~20% of hands): Closed hand with all sequences. In addition, your pair must not be made of yakuhai tiles, and your final wait must be a two-sided sequence wait (__ryanmen__), such as ![](tiles/7s.svg)![](tiles/8s.svg). 1 han.
- Ippatsu (~7.9% of hands): discussed previously. 1 han.

Yaku stack additively, and that is often the goal: you want to maximize the value of your winning hand.

There are many other yaku -- they will be listed at the bottom in order of frequency.

Riichi Advanced will automatically calculate your yaku and display them under a winning hand.

## Scoring

To score a hand, you add up all your han and consult a scoring table:

- 1 han: 1000 points, 1500 if dealer.
- 2 han: 2000 points, 2900 if dealer.
- 3 han: 3900 points, 5800 if dealer.
- 4 han: 7700 points, 11600 if dealer.
- 5 han: 8000 points, 12000 if dealer. "Mangan"
- 6-7 han: 12000 points, 18000 if dealer. "Haneman"
- 8-10 han: 18000 points, 24000 if dealer. "Baiman"
- 11-12 han: 24000 points, 36000 if dealer. "Sanbaiman"
- 13+ han: 32000 points, 48000 if dealer. "Yakuman"

In addition, you win 300 for every honba, and you pick up all the 1000 riichi bets on the table.

Riichi Advanced will automatically score your hand and distribute the points, but it is useful to know the range of points you can earn. The rough calculation is that a 1 han hand is 1000 points, and each additional han roughly doubles that score, up to 4 han.

## Fu

If you have less than 5 han, then in addition to yaku, you may increase your score by having triplets or quads in hand. Each triplet and quad is worth some amount of __fu__ based on if they are a terminal/honor triplet or not.

- Triplet of 2-8 tiles: 4 fu
- Triplet of 1-9 tiles: 8 fu
- Quad of 2-8 tiles: 16 fu
- Quad of 1-9 tiles: 32 fu

The fu amount is halved if the triplet/quad is open (formed via call or from calling ron). Note that ankan is not considered open, and triplets formed by tsumo (self-draw) are considered closed.

In addition, the following events give bonus fu:

- Always: +20 fu
- Closed hand ron: +10 fu
- Tsumo (self-draw win): +2 fu
- Final wait can be considered as a single tile wait: +2 fu
- Pair is a yakuhai tile: +2 fu (+4 fu if it's both the round wind and seat wind)

Fu is then rounded up to the nearest 10. This calculation is a bit involved, but in most cases, fu is 30, leading to the scoring table above. In reality, the score (below 5 han, "mangan") is calculated as follows:

    fu * 4 * 2^han

times 4 if non-dealer, or 6 if dealer. The result is rounded up to the nearest 100, and capped at 8000 (if non-dealer) or 12000 (if dealer). For han ≥ 5, fu is irrelevant, consult the scoring table above.

As an example, if you have 1 han 30 fu as non-dealer then it's `4 * 30 * 4 * 2^1 = 960`, which rounds up to 1000. Every han doubles the 960 figure, which explains why the score progression above is 1000 → 2000 → 3900 → 7700 instead of an exact doubling.

A full scoring table for riichi can be found online, but the above scoring table is recommended for beginners, since most hands are 30 fu.

## Ending the game

A game of riichi consists of a four-round East round, plus a four-round South round. During each four-round cycle, each player has the opportunity to be dealer once. Games can go on longer because if the dealer wins, they stay dealer for the next round (a __repeat__). A game of riichi typically lasts 10 rounds (meaning 2 repeats).

The game also ends once someone goes below zero points, though this is not common.

## Yaku list

- Yakuhai (~50% of hands): Have a value triplet in hand, defined as either a dragon triplet, a round wind triplet, or a seat wind triplet. 1 han each.
- Riichi (~41% of hands): Declare riichi, and win. 1 han.
- Tsumo (~25% of hands): When your hand is __closed__ (no calls, except ankan) and you win by tsumo (self-draw), you get 1 han.
- Tanyao (~22% of hands): Your hand consists of only tiles 2-8. So no ones, nines, winds, or dragons. 1 han.
- Pinfu (~20% of hands): Closed hand with all sequences. In addition, your pair must not be made of yakuhai tiles, and your final wait must be a two-sided sequence wait (__ryanmen__), such as ![](tiles/7s.svg)![](tiles/8s.svg). 1 han.
- Ippatsu (~7.9% of hands): Declare riichi, and win before your next discard after your riichi discard, with nobody making any calls in between. 1 han.
- Honitsu (~4.7% of hands): Your hand consists of only one suit plus honor tiles. 3 han if closed, 2 han if open.
- Iipeikou (~3.8% of hands): Your hand contains two identical sequences of the same suit, like ![](tiles/1p.svg)![](tiles/1p.svg)![](tiles/2p.svg)![](tiles/2p.svg)![](tiles/3p.svg)![](tiles/3p.svg). 1 han if closed, does not count if open.
- Sanshoku Doujun (~3.7% of hands): You have the same sequence in all three suits, like ![](tiles/1m.svg)![](tiles/2m.svg)![](tiles/3m.svg) ![](tiles/1p.svg)![](tiles/2p.svg)![](tiles/3p.svg) ![](tiles/1s.svg)![](tiles/2s.svg)![](tiles/3s.svg). 2 han if closed, 1 han if open.
- Chiitoitsu (~2.8% of hands): Your hand is seven pairs. 2 han.
- Ittsu (~1.5% of hands): You have the sequences 123 456 879 of a single suit in hand. 2 han if closed, 1 han if open.
- Toitoi (~1.4% of hands): Your hand is all triplets. 2 han.
- Haitei/Houtei (~0.82% of hands): You won off the last tile in the wall, or the last discard of the game, respectively. 1 han.
- Chanta (~0.80% of hands): Every set/pair in your hand contains a terminal or honor tile. 2 han if closed, 1 han if open.
- Sanankou (~0.62% of hands): Your hand contains three closed triplets. 2 han.
- Chinitsu (~0.55% of hands): Your hand consists of only one suit, no honor tiles. Overrides honitsu. 6 han if closed, 5 han if open.
- Junchan (~0.28% of hands): Every set/pair in your hand contains a terminal tile, no honors. Overrides chanta. 3 han if closed, 2 han if open.
- Rinshan (~0.26% of hands): You won by tsumo off the replacement tile after a kan. 1 han.
- Double Riichi (~0.19% of hands): You declared riichi on your first discard and won. 2 han instead of the typical 1 han.

The following are exceedingly rare yaku:

- Shousangen (~0.067% of hands): You have two dragon triplets and a dragon pair. 2 han (plus the 2 han from the dragon triplets).
- Ryanpeikou (~0.031% of hands): You have two sets of identical sequences (iipeikou). Overrides iipeikou and chiitoitsu. 3 han.
- Sanshoku Doukou (~0.022% of hands): You have the same triplet in all three suits, like ![](tiles/1m.svg)![](tiles/1m.svg)![](tiles/1m.svg) ![](tiles/1p.svg)![](tiles/1p.svg)![](tiles/1p.svg) ![](tiles/1s.svg)![](tiles/1s.svg)![](tiles/1s.svg). 2 han.
- Honroutou (~0.018% of hands): Your hand consists of 1, 9, and honor tiles. Basically the opposite of tanyao. 2 han, plus you have to get this with toitoi (2 han).
- Chankan (~0.015% of hands): When someone calls kakan, you have the option to call ron on that tile, and you get this yaku as a result. 1 han.
- Sankantsu (~0.002% of hands): You have three kans (of any kind). 2 han.

The percentage stats are pulled from [here](http://tenhou.net/sc/prof.html).

## Yakuman

The following nine rare yaku are considered __yakuman__, which immediately gives you 32000 (non-dealer)/48000 (dealer) points. Yakuman also stack, multiplying e.g. 32000 into 64000.

- Suuankou (~0.026% of hands): All four of your sets are concealed triplets. Yakuman.
- Daisangen (~0.019% of hands): You have all three dragon triplets. Yakuman.
- Kokushi Musou (~0.018% of hands): You have each terminal and honor tile, with one of them forming a pair. Yakuman.
- Shousuushii: You have three wind triplets and a wind pair. Yakuman.
- Tenhou/Chiihou: You win off your first draw, with no intervening calls between the start of the round and your draw. Yakuman.
- Tsuuiisou: Your hand consists only of honor tiles. Yakuman.
- Ryuuiisou: Your hand consists only of all-green tiles: ![](2s.svg)![](3s.svg)![](4s.svg)![](6s.svg)![](8s.svg)![](6z.svg). Yakuman.
- Chinroutou: Your hand consists only of 1 and 9. Yakuman.

The following three yaku are considered __double yakuman__, and are exceedingly rare:

- Suuankou Tanki: All four of your sets are concealed triplets, and your final wait is for your pair. Double yakuman.
- Kokushi Musou Juusan Menmachi: You have each terminal and honor tile, and your final wait is for your pair. Double yakuman.
- Daisuushii: You have all four wind triplets. Double yakuman.
