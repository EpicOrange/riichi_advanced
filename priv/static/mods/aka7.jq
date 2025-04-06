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
  ["add_rule", "Rules", "Wall", "(Aka) \($man)x 7m, \($pin)x 7p, and \($sou)x 7s are replaced with red \"aka dora\" sevens that are worth one extra han each.", -99],
  ["update_rule", "Rules", "Shuugi", "(Aka) If your hand is closed, each aka dora is worth 1 shuugi."]
]
|
# replace 7m,7p,7s in wall with 07m,07p,07s
.wall |= replace_n_tiles("7m"; "07m"; $man)
|
.wall |= replace_n_tiles("7p"; "07p"; $pin)
|
.wall |= replace_n_tiles("7s"; "07s"; $sou)
|
.wall |= replace_n_tiles("7t"; "07t"; $man) # just reuse $man, keep it simple
|
# set each aka dora as 7m/p/s-valued jokers
.after_start.actions += [
  ["set_tile_alias_all", ["07m"], ["7m"]],
  ["set_tile_alias_all", ["07p"], ["7p"]],
  ["set_tile_alias_all", ["07s"], ["7s"]],
  ["tag_tiles", "dora", ["07m", "07p", "07s"]]
]
|
# star suit mod
if any(.wall[]; . == "1t") then
  (.wall | index("7s")) as $idx | if $idx then .wall[$idx] = "07s" else . end
  |
  .after_start.actions += [
    ["set_tile_alias_all", ["07t"], ["7t"]],
    ["tag_tiles", "dora", ["07t"]]
  ]
  |
  .before_win.actions += [
    ["add_counter", "aka", "count_matches", ["hand", "calls", "winning_tile"], [[ "nojoker", [["07t"], 1] ]]]
  ]
  |
  .dora_indicators += {
    "07t": ["8t"]
  }
else . end
|
# count aka
.before_win.actions += [
  ["add_counter", "aka", "count_matches", ["hand", "calls", "winning_tile"], [[ "nojoker", [["07m","07p","07s"], 1] ]]]
]
|
# add aka yaku
.extra_yaku += [
  {"display_name": "Aka", "value": "aka", "when": [{"name": "counter_at_least", "opts": ["aka", 1]}]}
]
|
# add dora indicators
.dora_indicators += {
  "07m": ["8m"],
  "07p": ["8p"],
  "07s": ["8s"]
}
