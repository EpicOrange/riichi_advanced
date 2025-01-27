# Base rules of Mahjong (most variants)

This document lists the rules common to most mahjong variants. We list them here so that we don't have to keep repeating the same set of rules in every mahjong variant's documentation we write. For other mahjong variants, we will list the additions and differences from this ruleset.

Note that our rulesets are specific to Riichi Advanced, and do not contain complete information on how mahjong is to be played IRL.

## Mahjong in brief

Mahjong is a four-player game played with 34 different kinds of tiles:

- numbered 1-9 __character__ tiles ![](tiles/1m.svg)![](tiles/2m.svg)![](tiles/3m.svg)![](tiles/4m.svg)![](tiles/5m.svg)![](tiles/6m.svg)![](tiles/7m.svg)![](tiles/8m.svg)![](tiles/9m.svg) (aka __manzu__ or __craks__),
- numbered 1-9 __circle__ tiles ![](tiles/1p.svg)![](tiles/2p.svg)![](tiles/3p.svg)![](tiles/4p.svg)![](tiles/5p.svg)![](tiles/6p.svg)![](tiles/7p.svg)![](tiles/8p.svg)![](tiles/9p.svg) (aka __pinzu__ or __dots__),
- numbered 1-9 __bamboo__ tiles ![](tiles/1s.svg)![](tiles/2s.svg)![](tiles/3s.svg)![](tiles/4s.svg)![](tiles/5s.svg)![](tiles/6s.svg)![](tiles/7s.svg)![](tiles/8s.svg)![](tiles/9s.svg) (aka __souzu__ or __bams__),
- four wind tiles ![](tiles/1z.svg)![](tiles/2z.svg)![](tiles/3z.svg)![](tiles/4z.svg) (east, south, west, north),
- and three dragon tiles ![](tiles/5z.svg)![](tiles/6z.svg)![](tiles/7z.svg) (white dragon, green dragon, red dragon).

Winds and dragons are collectively termed "__honors__". 1s and 9s are collectively termed "__terminals__".

There are four copies of each tile, giving a total of 136 tiles in the __wall__. Riichi Advanced mods may add or subtract from this tileset, but this is the default tileset. In the game messages, manzu are notated 1m to 9m, pinzu 1p to 9p, souzu 1s to 9s, wind tiles 1z to 4z, and dragons 5z to 7z, in the order indicated above. (Most mahjong variants use the variant white dragon ![](tiles/0z.svg), which is notated 0z.)

The goal of mahjong is to maximize your points. To earn points, you must be the first in each round to complete a 14-tile hand. A hand is generally defined as four sets and a pair. A __set__ is either a 3-tile sequence in the same numbered suit, like ![](tiles/1p.svg)![](tiles/2p.svg)![](tiles/3p.svg), or a triplet of the same tile, like ![](tiles/2z.svg)![](tiles/2z.svg)![](tiles/2z.svg). Your starting hand of 13 tiles might not contain any ready-made sets, so you must progress your hand by drawing a tile each turn, and then discarding a tile if you have not completed a hand. You do not declare your sets when they are made; they remain hidden in your hand.

The game starts with everyone being dealt 13 tiles from the wall. The East player (also known as the __dealer__) is dealt a 14th tile to start the game. Play starts from the dealer's first discard and continues counterclockwise, with each player drawing and discarding a tile.

## Calls

One a tile has been discarded, often the next player in turn continues by drawing their tile. However, this process can be interrupted by calling the discarded tile. There are three possible calls on discarded tiles:

- __Chow/Chii/Sheung__: If you are next in turn order, and the discarded tile completes a __sequence__, instead of drawing a tile you may claim the discard and set aside the completed sequence. Then you must discard a tile as usual. All tiles set aside are considered part of your hand, but are visible to all and cannot be discarded.
- __Pung/Pon__: Even if you are not next in turn order, if the discarded tile completes a __triplet__, you may claim the discard and set aside the completed triplet. Pung overrides chow, and also changes the turn order (it becomes your turn to discard). Like with chow, all tiles set aside are considered part of your hand, but are visible to all and cannot be discarded.
- __Kong/Kan/Gong__: If you have a triplet of the discarded tile in hand, you may call kong to claim the discard and set aside the completed __quad__, which is considered to be a triplet for winning purposes. It becomes your turn, and you draw a replacement tile from the back of the wall. We will go into detail about kong and quads in a bit.

As soon as you call a discard, your hand is considered __open__.

## Kong

As discussed previously, you may call kong on a discarded tile if you have three copies of that tile in hand. This opens your hand. 

There are three ways to kong, and they all involve forming quads:

- __Open Kong / Daiminkan__: This is calling a discard with a triplet of the same tile in hand, as discussed previously. After calling an open kong, you draw a replacement tile, and then discard to end your turn.
- __Added Kong / Shouminkan / Kakan__: If you called pung on e.g. ![](tiles/6z.svg)![](tiles/6z.svg)![](tiles/6z.svg) and later draw a ![](tiles/6z.svg), you may call kong during your turn to add your drawn ![](tiles/6z.svg) to the existing pung. Like with an open kong, you draw a replacement tile, and then discard to end your turn.
- __Closed Kong / Ankan__: If at any point during your turn you have four of the same tile in hand, such as ![](tiles/5p.svg)![](tiles/5p.svg)![](tiles/5p.svg)![](tiles/5p.svg), you may call kong to set those aside (in some variants, they are set aside face-up, and in others, face-down). A closed kong importantly __does not open your hand__. Like with an open kong, you draw a replacement tile, and then discard to end your turn.

## Dealership, round wind, and seat wind

One player is designated the dealer. They get the first turn (and they draw their 14th tile in advance of any pre-round actions). When the dealer wins, they remain as dealer; when they fail to win, dealership passes to the player to their right.

As previously mentioned, the dealer is East. The player seated to East's right is South; the player opposite East is West, and the player to East's left is North. Note that this is in reverse of the directions on a compass. A player's seat wind is the one associated with their position relative to the dealer.

The round wind starts off as East. After dealership has passed four times, the round wind changes to South; then to West; and finally to North. After dealership passes four times during North rounds, the game ends. (Some variants end the game before this.)

## Flower tiles

Some variants include the following tiles:

- Flowers: ![](tiles/1f.svg)![](tiles/2f.svg)![](tiles/3f.svg)![](tiles/4f.svg)
- Seasons: ![](tiles/1g.svg)![](tiles/2g.svg)![](tiles/3g.svg)![](tiles/4g.svg)

In such variants, the following usually happens:

- At the start of the game, there is a "flower declaration phase". Starting with East, each player declares all the flowers in their hand, sets them aside face-up, and draws that many replacement tiles, repeating until they have no more flowers in their hand.
- When a player draws a flower, they must declare it immediately, set it aside face-up, and draw a replacement tile. This is true even if the player draws their flower from a replacement draw from a previous flower or a kong.

Flowers are generally worth points in variants that use them. East's associated flowers and seasons are those numbered 1; South's 2, and so on.

## Dead wall and exhaustive draw

Some variants have a "dead wall". This is the last 14~30 tiles of the wall, depending on variant. The round ends when someone has won, or when all the "live" tiles of the wall have been drawn; in the latter case, generally, nobody wins. When a player declares a kong or declares a flower, the replacement tile is drawn from the dead wall, and the last tile of the "live" wall moves to the dead wall. Players cannot generally draw a tile from the dead wall if the live wall is empty.

## Scoring

Generally, hands are scored by which "winning criteria" or __yaku__ they satisfy. Each yaku has a certain score (usually measured in __faan/fan/han/tai__) associated with it. A hand scores the total faan of the yaku it satisfies, converted into points with a faan-to-points table.

The list of yaku, as well as their associated faan, varies by variant. The following yaku are recognised in most variants, in some form:

- Winning by self-draw
- Winning by a replacement tile after a kong
- Having four sequences and a pair (aka "All Sequences")
- Having four triplets and a pair (aka "All Triplets")
- Having a triplet of dragons
- Having a triplet of the round wind or your seat wind
- Having your seat's flower or season
- Having all four flowers, or all four seasons
- Having no flowers and no seasons
- Hand comprises tiles of only one suit, plus honors (aka "Half Flush" or "Mixed Flush")
- Hand comprises tiles of only one suit, without honors (aka "Full Flush" or "Pure Flush")
- Hand comprises only honor tiles (aka "All Honors")
- Winning on one's first draw as dealer (aka "Heavenly Hand")
- Winning on one's first draw as non-dealer (aka "Earthly Hand")
- Winning on the dealer's first discard (aka "Hand of Man")
- Hand comprises exactly the following tiles: 19m19p19s1234567z, and one duplicate among these thirteen. (aka "Thirteen Orphans")

In many variants, a hand MUST attain a minimum score in order to be able to win. (This is in addition to the "four sets and a pair" criterion mentioned earlier.)

## TODOS:

- Make sure the tile SVGs are showing correctly (for flowers/seasons/0z).
- Add more pictures to this guide where necessary (e.g. to show where points/round wind/seat wind/other UI elements are indicated).
- Proofreading.
