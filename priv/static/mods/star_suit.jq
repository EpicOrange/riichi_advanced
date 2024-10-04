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
