def add_aka_status($actions; $check):
  [
    ["when", [{"name": "match", "opts": [["hand", "calls", $check], [[[["0t"], 1]]]]}], [["set_status", "aka_t"]]]
  ] + $actions;

.after_initialization.actions += [
  ["add_rule", "Tiles", "Star Suit", "There is a fourth suit, stars: %{stars}", {"stars": ["1t", "2t", "3t", "4t", "5t", "6t", "7t", "8t", "9t"]}]
]
|
.custom_style.tile_indices += {
  "1t": "1",
  "2t": "2",
  "3t": "3",
  "4t": "4",
  "5t": "5",
  "6t": "6",
  "7t": "7",
  "8t": "8",
  "9t": "9",
  "10t": "10",
  "0t": "5"
  }
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