def replace_n_tiles($tile; $aka; $num):
  if $num > 0 then
    index($tile) as $ix
    |
    if $ix then
      .[$ix] = $aka
      |
      replace_n_tiles($tile; $aka; $num - 1)
    else . end
  else . end;

.after_initialization.actions += [
  ["add_rule", "Aka", "\($man)x 5m, \($pin)x 5p, and \($sou)x 5p are replaced with red \"aka dora\" fives that are worth one extra han each."],
  ["update_rule", "Shuugi", "(Aka) If your hand is closed, each aka dora is worth 1 shuugi."]
]
|
# replace 5m,5p,5s in wall with 0m,0p,0s
.wall |= replace_n_tiles("5m"; "0m"; $man)
|
.wall |= replace_n_tiles("5p"; "0p"; $pin)
|
.wall |= replace_n_tiles("5s"; "0s"; $sou)
|
.wall |= replace_n_tiles("5t"; "0t"; $man) # just reuse $man, keep it simple
|
# set each aka dora as 5m/p/s-valued jokers
.after_start.actions += [
  ["set_tile_alias_all", ["0m"], ["5m"]],
  ["set_tile_alias_all", ["0p"], ["5p"]],
  ["set_tile_alias_all", ["0s"], ["5s"]],
  ["tag_tiles", "dora", ["0m", "0p", "0s"]]
]
|
# star suit mod
if any(.wall[]; . == "1t") then
  (.wall | index("5s")) as $idx | if $idx then .wall[$idx] = "0s" else . end
  |
  .after_start.actions += [
    ["set_tile_alias_all", ["0t"], ["5t"]],
    ["tag_tiles", "dora", ["0t"]]
  ]
else . end
|
# count aka
.before_win.actions += [
  ["add_counter", "aka", "count_matches", ["hand", "calls", "winning_tile"], [[ "nojoker", [["0m","0p","0s"], 1] ]]]
]
|
# add aka yaku
.extra_yaku += [
  {"display_name": "Aka", "value": "aka", "when": [{"name": "counter_at_least", "opts": ["aka", 1]}]}
]
