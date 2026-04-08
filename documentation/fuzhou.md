# Fuzhou Mahjong

This ruleset assumes that you have read [base.md](base.md).

The wall for Fuzhou consists of the 1-9 character tiles, 1-9 circle tiles, 1-9 bamboo tiles, the four wind tiles, the three dragon tiles, the four flower tiles, and the four season tiles.

Honours, flowers, and seasons are all treated as flower tiles. When drawn, they are immediately declared and replaced with a tile from the dead wall.

Players' hands are 16 tiles long, winning on 17 tiles.

When the starting hands are dealt, and all players have declared flowers and drawn replacement tiles, the second tile of the dead wall is flipped over, and placed atop the ninth stack from the dead end of the wall. These eighteen tiles form the dead wall. 

(NOTE: Normally, the tile of the dead wall that's flipped over is determined by the dice rolls. This implementation difference in Riichi Advanced is due to technical limitations.)

This revealed tile is known the "Gold Tile". If, at this point, any player is in tenpai and waiting on the Gold Tile, they may instantly declare a win by "Robbing The Gold" (aka "Qiangjin"). (NOTE: Due to technical limitations, this is not displayed correctly on the win screen, and Qiangjin occurs after East has drawn their first tile.)

Otherwise, all copies of the Gold Tile become an any-joker. Gold Tiles cannot be used in calls. Discarding a Gold Tile restricts a player to only winning via self-draw.

To win, you must achieve one of the following:

- Five sets and a pair (as usual)

For the yaku and scoring, consult [this guide](https://mahjongpros.com/blogs/how-to-play/beginners-guide-to-fuzhou-mahjong).
