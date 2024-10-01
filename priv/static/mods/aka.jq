(.wall | index("5m")) as $idx | if $idx then .wall[$idx] = "0m" else . end
|
(.wall | index("5p")) as $idx | if $idx then .wall[$idx] = "0p" else . end
|
(.wall | index("5s")) as $idx | if $idx then .wall[$idx] = "0s" else . end
|
.after_start.actions += [
  ["set_tile_alias_all", ["0m"], ["5m"]],
  ["set_tile_alias_all", ["0p"], ["5p"]],
  ["set_tile_alias_all", ["0s"], ["5s"]]
]
|
.extra_yaku += [
  {"display_name": "Aka", "value": 1, "when": [{"name": "status", "opts": ["aka_m"]}]},
  {"display_name": "Aka", "value": 1, "when": [{"name": "status", "opts": ["aka_p"]}]},
  {"display_name": "Aka", "value": 1, "when": [{"name": "status", "opts": ["aka_s"]}]}
]
