def add_aka_status($actions; $type):
  [
    ["when", [{"name": "match", "opts": [["hand", "calls", $type], [[[["0m"], 1]]]]}], [["set_status", "aka_m"]]],
    ["when", [{"name": "match", "opts": [["hand", "calls", $type], [[[["0p"], 1]]]]}], [["set_status", "aka_p"]]],
    ["when", [{"name": "match", "opts": [["hand", "calls", $type], [[[["0s"], 1]]]]}], [["set_status", "aka_s"]]]
  ] + $actions;

# replace first 5m,5p,5s in wall with 0m,0p,0s
(.wall | index("5m")) as $idx | if $idx then .wall[$idx] = "0m" else . end
|
(.wall | index("5p")) as $idx | if $idx then .wall[$idx] = "0p" else . end
|
(.wall | index("5s")) as $idx | if $idx then .wall[$idx] = "0s" else . end
|
# set each aka dora as 5m/p/s-valued jokers
.after_start.actions += [
  ["set_tile_alias_all", ["0m"], ["5m"]],
  ["set_tile_alias_all", ["0p"], ["5p"]],
  ["set_tile_alias_all", ["0s"], ["5s"]]
]
|
# add aka yaku
.extra_yaku += [
  {"display_name": "Aka", "value": 1, "when": [{"name": "status", "opts": ["aka_m"]}]},
  {"display_name": "Aka", "value": 1, "when": [{"name": "status", "opts": ["aka_p"]}]},
  {"display_name": "Aka", "value": 1, "when": [{"name": "status", "opts": ["aka_s"]}]}
]
|
# set aka status
.buttons.ron.actions |= add_aka_status(.; "last_discard")
|
.buttons.chankan.actions |= add_aka_status(.; "last_called_tile")
|
.buttons.tsumo.actions |= add_aka_status(.; "draw")
