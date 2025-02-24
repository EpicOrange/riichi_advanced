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
  ["add_rule", "Wall", "(Kin) \($man)x 5m, \($pin)x 5p, and \($sou)x 5p are replaced with gold \"kin dora\" fives that are worth three extra han each.", -99],
  ["update_rule", "Shuugi", "(Kin) If your hand is closed, each kin dora is worth 3 shuugi."]
]
|
# replace 5m,5p,5s in wall with 35m,35p,35s
.wall |= replace_n_tiles("5m"; "35m"; $man)
|
.wall |= replace_n_tiles("5p"; "35p"; $pin)
|
.wall |= replace_n_tiles("5s"; "35s"; $sou)
|
.wall |= replace_n_tiles("5t"; "35t"; $man) # just reuse $man, keep it simple
|
# set each kin dora as 5m/p/s-valued jokers
.after_start.actions += [
  ["set_tile_alias_all", ["35m"], ["5m"]],
  ["set_tile_alias_all", ["35p"], ["5p"]],
  ["set_tile_alias_all", ["35s"], ["5s"]],
  ["tag_tiles", "dora", ["35m", "35p", "35s"]]
]
|
# count kin
.before_win.actions += [
  ["add_counter", "kin", "count_matches", ["hand", "calls", "winning_tile"], [[ "nojoker", [["35m","35p","35s"], 1] ]]],
  ["multiply_counter", "kin", 3]
]
|
# add kin yaku
.extra_yaku += [
  {"display_name": "Kin", "value": "kin", "when": [{"name": "counter_at_least", "opts": ["kin", 1]}]}
]
|
# add dora indicators
.dora_indicators += {
  "35m": ["6m"],
  "35p": ["6p"],
  "35s": ["6s"]
}
