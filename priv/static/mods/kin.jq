# replace first 5m,5p,5s in wall with 35m,35p,35s
(.wall | index("5m")) as $idx | if $idx then .wall[$idx] = "35m" else . end
|
(.wall | index("5p")) as $idx | if $idx then .wall[$idx] = "35p" else . end
|
(.wall | index("5s")) as $idx | if $idx then .wall[$idx] = "35s" else . end
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
  ["add_counter", "kin", "count_matches", ["hand", "calls", "winning_tile"], [[ "nojoker", [["35m","35p","35s"], 2] ]]]
]
|
# add kin yaku
.extra_yaku += [
  {"display_name": "Kin", "value": "kin", "when": [{"name": "counter_at_least", "opts": ["kin", 1]}]}
]
