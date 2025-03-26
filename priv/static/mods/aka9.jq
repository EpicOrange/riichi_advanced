def replace_n_tiles($tile; $aka; $num):
  if $num > 0 then
    (map(if type == "object" then .tile elif type == "array" then .[0] else . end) | index($tile)) as $ix
    |
    if $ix then
      if .[$ix] | type == "object" then
        .[$ix].tile = $aka
      elif .[$ix] | type == "array" then
        .[$ix][0] = $aka
      else
        .[$ix] = $aka
      end
      |
      replace_n_tiles($tile; $aka; $num - 1)
    else . end
  else . end;

.after_initialization.actions += [
  ["add_rule", "Rules", "Wall", "(Aka) \($man)x 9m, \($pin)x 9p, and \($sou)x 9s are replaced with red \"aka dora\" nine that are worth one extra han each.", -99],
  ["update_rule", "Rules", "Shuugi", "(Aka) If your hand is closed, each aka dora is worth 1 shuugi."]
]
|
# replace 9m,9p,9s in wall with 09m,09p,09s
.wall |= replace_n_tiles("9m"; "09m"; $man)
|
.wall |= replace_n_tiles("9p"; "09p"; $pin)
|
.wall |= replace_n_tiles("9s"; "09s"; $sou)
|
.wall |= replace_n_tiles("9t"; "09t"; $man) # just reuse $man, keep it simple
|
# set each aka dora as 9m/p/s-valued jokers
.after_start.actions += [
  ["set_tile_alias_all", ["09m"], ["9m"]],
  ["set_tile_alias_all", ["09p"], ["9p"]],
  ["set_tile_alias_all", ["09s"], ["9s"]],
  ["tag_tiles", "dora", ["09m", "09p", "09s"]]
]
|
# star suit mod
if any(.wall[]; . == "1t") then
  (.wall | index("9s")) as $idx | if $idx then .wall[$idx] = "09s" else . end
  |
  .after_start.actions += [
    ["set_tile_alias_all", ["09t"], ["9t"]],
    ["tag_tiles", "dora", ["09t"]]
  ]
  |
  .before_win.actions += [
    ["add_counter", "aka", "count_matches", ["hand", "calls", "winning_tile"], [[ "nojoker", [["09t"], 1] ]]]
  ]
  |
  .dora_indicators += {
    "09t": ["1t"]
  }
else . end
|
# count aka
.before_win.actions += [
  ["add_counter", "aka", "count_matches", ["hand", "calls", "winning_tile"], [[ "nojoker", [["09m","09p","09s"], 1] ]]]
]
|
# add aka yaku
.extra_yaku += [
  {"display_name": "Aka", "value": "aka", "when": [{"name": "counter_at_least", "opts": ["aka", 1]}]}
]
|
# add dora indicators
.dora_indicators += {
  "09m": ["1m"],
  "09p": ["1p"],
  "09s": ["1s"]
}
