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
  ["add_rule", "Rules", "Wall", "(Aka) \($man)x 3m, \($pin)x 3p, and \($sou)x 3s are replaced with red \"aka dora\" threes that are worth one extra han each.", -99],
  ["update_rule", "Rules", "Shuugi", "(Aka) If your hand is closed, each aka dora is worth 1 shuugi."]
]
|
# replace 3m,3p,3s in wall with 03m,03p,03s
.wall |= replace_n_tiles("3m"; "03m"; $man)
|
.wall |= replace_n_tiles("3p"; "03p"; $pin)
|
.wall |= replace_n_tiles("3s"; "03s"; $sou)
|
.wall |= replace_n_tiles("3t"; "03t"; $man) # just reuse $man, keep it simple
|
# set each aka dora as 3m/p/s-valued jokers
.after_start.actions += [
  ["set_tile_alias_all", ["03m"], ["3m"]],
  ["set_tile_alias_all", ["03p"], ["3p"]],
  ["set_tile_alias_all", ["03s"], ["3s"]],
  ["tag_tiles", "dora", ["03m", "03p", "03s"]]
]
|
# star suit mod
if any(.wall[]; . == "1t") then
  (.wall | index("3s")) as $idx | if $idx then .wall[$idx] = "03s" else . end
  |
  .after_start.actions += [
    ["set_tile_alias_all", ["03t"], ["3t"]],
    ["tag_tiles", "dora", ["03t"]]
  ]
  |
  .before_win.actions += [
    ["add_counter", "aka", "count_matches", ["hand", "calls", "winning_tile"], [[ "nojoker", [["03t"], 1] ]]]
  ]
  |
  .dora_indicators += {
    "03t": ["4t"]
  }
else . end
|
# count aka
.before_win.actions += [
  ["add_counter", "aka", "count_matches", ["hand", "calls", "winning_tile"], [[ "nojoker", [["03m","03p","03s"], 1] ]]]
]
|
# add aka yaku
.extra_yaku += [
  {"display_name": "Aka", "value": "aka", "when": [{"name": "counter_at_least", "opts": ["aka", 1]}]}
]
|
# add dora indicators
.dora_indicators += {
  "03m": ["4m"],
  "03p": ["4p"],
  "03s": ["4s"]
}
