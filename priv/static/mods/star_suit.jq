def add_aka_status($actions; $check):
  [
    ["when", [{"name": "match", "opts": [["hand", "calls", $check], [[[["0t"], 1]]]]}], [["set_status", "aka_t"]]]
  ] + $actions;

.wall += [
  "1t", "1t", "1t", "1t",
  "2t", "2t", "2t", "2t",
  "3t", "3t", "3t", "3t",
  "4t", "4t", "4t", "4t",
  "5t", "5t", "5t", "5t",
  "6t", "6t", "6t", "6t",
  "7t", "7t", "7t", "7t",
  "8t", "8t", "8t", "8t",
  "9t", "9t", "9t", "9t"
]
|
.after_start.actions += [
  ["set_tile_ordering", ["1t", "2t", "3t", "4t", "5t", "6t", "7t", "8t", "9t"]]
]
|
# expand dora indicator map, if it exists
if .dora_indicators then
  .dora_indicators += {
    "1t": ["2t"],
    "2t": ["3t"],
    "3t": ["4t"],
    "4t": ["5t"],
    "5t": ["6t"],
    "6t": ["7t"],
    "7t": ["8t"],
    "8t": ["9t"]
  }
else . end
|
# aka support
if any(.wall[]; . == "0m") then
  (.wall | index("5t")) as $idx | if $idx then .wall[$idx] = "0t" else . end
  |
  .after_start.actions += [
    ["set_tile_alias_all", ["0t"], ["5t"]]
  ]
  |
  .extra_yaku += [
    {"display_name": "Aka", "value": 1, "when": [{"name": "status", "opts": ["aka_t"]}]}
  ]
  |
  .buttons.ron.actions |= add_aka_status(.; "last_discard")
  |
  .buttons.chankan.actions |= add_aka_status(.; "last_called_tile")
  |
  .buttons.tsumo.actions |= add_aka_status(.; "draw")
else . end
|
# ten support
if any(.wall[]; . == "10m") then
  .wall += ["10t", "10t", "10t", "10t"]
else . end
