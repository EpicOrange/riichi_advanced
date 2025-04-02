# this mod allows players to set the number of jokers and flowers in the set. useful for beginners who want extra jokers, or for players who wish to play a historical variation. support for flowers acting as jokers (as in pre-1970s rules) and jokers acting as more-powerful flowers (as in 1960s rules) will come some other day.

# oops, looks like i have no clue how to add a tile n times to the wall in majs, so i'm using jq instead:

# define function for adding n copies of a tile to the wall
def add_n_tiles($tile; $num):
  if $num > 0 then
      . += [$tile]
      |
      add_n_tiles($tile; $num - 1)
  else . end;

# first, remove all flowers and jokers from the wall (it's implemented this way in case some bozo decides to turn the mod off then complain that there aren't any flowers or jokers)
.wall -= ["1f", "2f", "3f", "4f", "1g", "2g", "3g", "4g", "1j", "1j", "1j", "1j", "1j", "1j", "1j", "1j"]
|
# add $jokers number of jokers to the wall
.wall |= add_n_tiles("1j"; $jokers)
|
if $flowers == 8 then
  .wall += ["1f", "2f", "3f", "4f", "1g", "2g", "3g", "4g"]
else
  .wall |= add_n_tiles("1f"; $flowers)
end
