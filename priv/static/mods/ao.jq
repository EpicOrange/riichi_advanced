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
  ["add_rule", "Rules", "Wall", "(Ao) \($man)x 5m, \($pin)x 5p, and \($sou)x 5p are replaced with blue \"ao dora\" fives that are worth two extra han each.", -99],
  ["update_rule", "Rules", "Shuugi", "(Ao) If your hand is closed, each ao dora is worth 2 shuugi."]
]
|
# replace 5m,5p,5s in wall with 25m,25p,25s
.wall |= replace_n_tiles("1m"; "15m"; $man)
|
.wall |= replace_n_tiles("5p"; "25p"; $pin)
|
.wall |= replace_n_tiles("5s"; "25s"; $sou)
|
.wall |= replace_n_tiles("5t"; "25t"; $man) # just reuse $man, keep it simple
|
# set each ao dora as 5m/p/s-valued jokers
.after_start.actions += [
  ["set_tile_alias_all", ["25m"], ["5m"]],
  ["set_tile_alias_all", ["25p"], ["5p"]],
  ["set_tile_alias_all", ["25s"], ["5s"]],
  ["tag_tiles", "dora", ["25m", "25p", "25s"]]
]
|
# count ao
.before_win.actions += [
  ["add_counter", "ao", "count_matches", ["hand", "calls", "winning_tile"], [[ "nojoker", [["25m","25p","25s"], 1] ]]],
  ["multiply_counter", "ao", 2]
]
|
# add ao yaku
.extra_yaku += [
  {"display_name": "Ao", "value": "ao", "when": [{"name": "counter_at_least", "opts": ["ao", 1]}]}
]
|
# add dora indicators
.dora_indicators += {
  "25m": ["6m"],
  "25p": ["6p"],
  "25s": ["6s"]
}
