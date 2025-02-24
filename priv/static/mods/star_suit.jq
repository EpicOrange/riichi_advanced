def add_aka_status($actions; $check):
  [
    ["when", [{"name": "match", "opts": [["hand", "calls", $check], [[[["0t"], 1]]]]}], [["set_status", "aka_t"]]]
  ] + $actions;

.after_initialization.actions += [["add_rule", "Wall", "(Star Suit) There is a fourth star suit.", -99]]
|
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
# ten support
if any(.wall[]; . == "10m") then
  .wall += ["10t", "10t", "10t", "10t"]
else . end
