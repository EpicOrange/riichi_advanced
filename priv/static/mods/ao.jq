# replace first 5m,5p,5s in wall with 25m,25p,25s
(.wall | index("5m")) as $idx | if $idx then .wall[$idx] = "25m" else . end
|
(.wall | index("5p")) as $idx | if $idx then .wall[$idx] = "25p" else . end
|
(.wall | index("5s")) as $idx | if $idx then .wall[$idx] = "25s" else . end
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
  ["add_counter", "ao", "count_matches", ["hand", "calls", "winning_tile"], [[ "nojoker", [["25m","25p","25s"], 2] ]]]
]
|
# add ao yaku
.extra_yaku += [
  {"display_name": "Ao", "value": "ao", "when": [{"name": "counter_at_least", "opts": ["ao", 1]}]}
]
