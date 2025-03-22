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
  ["add_rule", "Rules", "Wall", "(Aka) \($man)x 1m, \($pin)x 1p, and \($sou)x 1s are replaced with red \"aka dora\" ones that are worth one extra han each.", -99],
  ["update_rule", "Rules", "Shuugi", "(Aka) If your hand is closed, each aka dora is worth 1 shuugi."]
]
|
# replace 1m,1p,1s in wall with 01m,01p,01s
.wall |= replace_n_tiles("1m"; "01m"; $man)
|
.wall |= replace_n_tiles("1p"; "01p"; $pin)
|
.wall |= replace_n_tiles("1s"; "01s"; $sou)
|
.wall |= replace_n_tiles("1t"; "01t"; $man) # just reuse $man, keep it simple
|
# set each aka dora as 1m/p/s-valued jokers
.after_start.actions += [
  ["set_tile_alias_all", ["01m"], ["1m"]],
  ["set_tile_alias_all", ["01p"], ["1p"]],
  ["set_tile_alias_all", ["01s"], ["1s"]],
  ["tag_tiles", "dora", ["01m", "01p", "01s"]]
]
|
# star suit mod
if any(.wall[]; . == "1t") then
  (.wall | index("1s")) as $idx | if $idx then .wall[$idx] = "01s" else . end
  |
  .after_start.actions += [
    ["set_tile_alias_all", ["01t"], ["1t"]],
    ["tag_tiles", "dora", ["01t"]]
  ]
  .before_win.actions += [
    ["add_counter", "aka", "count_matches", ["hand", "calls", "winning_tile"], [[ "nojoker", [["01t"], 1] ]]]
  ]
  .dora_indicators += {
    "01t": ["2t"]
  }
else . end
|
# count aka
.before_win.actions += [
  ["add_counter", "aka", "count_matches", ["hand", "calls", "winning_tile"], [[ "nojoker", [["01m","01p","01s"], 1] ]]]
]
|
# add aka yaku
.extra_yaku += [
  {"display_name": "Aka", "value": "aka", "when": [{"name": "counter_at_least", "opts": ["aka", 1]}]}
]
|
# add dora indicators
.dora_indicators += {
  "01m": ["2m"],
  "01p": ["2p"],
  "01s": ["2s"]
}
