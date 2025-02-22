# add to initial dora flip
if .revealed_tiles[0] == -6 then
  .revealed_tiles += [-8, -10]
  |
  .after_start.actions += [
    ["tag_dora", "dora", -8],
    ["tag_dora", "dora", -10]
  ]
elif .revealed_tiles[0] == -10 then
  .revealed_tiles += [-12, -14]
  |
  .after_start.actions += [
    ["tag_dora", "dora", -12],
    ["tag_dora", "dora", -14]
  ]
else . end
