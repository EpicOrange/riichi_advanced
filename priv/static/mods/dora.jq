.max_revealed_tiles = 5
|
# initial dora flip

if .num_players == 3 then
  .revealed_tiles += [-10]
else
  .revealed_tiles += [-6]
end
|
# dora indicator map
.dora_indicators += {
  "1m": ["2m"],
  "2m": ["3m"],
  "3m": ["4m"],
  "4m": ["5m"],
  "5m": ["6m"],
  "6m": ["7m"],
  "7m": ["8m"],
  "8m": ["9m"],
  "9m": ["1m"],
  "0m": ["6m"],
  "1p": ["2p"],
  "2p": ["3p"],
  "3p": ["4p"],
  "4p": ["5p"],
  "5p": ["6p"],
  "6p": ["7p"],
  "7p": ["8p"],
  "8p": ["9p"],
  "9p": ["1p"],
  "0p": ["6p"],
  "1s": ["2s"],
  "2s": ["3s"],
  "3s": ["4s"],
  "4s": ["5s"],
  "5s": ["6s"],
  "6s": ["7s"],
  "7s": ["8s"],
  "8s": ["9s"],
  "9s": ["1s"],
  "0s": ["6s"],
  "1z": ["2z"],
  "2z": ["3z"],
  "3z": ["4z"],
  "4z": ["1z"],
  "5z": ["6z"],
  "6z": ["7z"],
  "7z": ["5z"]
}
|
if .num_players == 3 then
  .dora_indicators["1m"] = ["9m"]
else . end
|
# count dora
.before_win.actions += [
  ["when", [{"name": "tile_revealed", "opts": [-6]}], [["add_counter", "dora", "count_dora", -6, ["hand", "calls", "flowers", "winning_tile"]]]],
  ["when", [{"name": "tile_revealed", "opts": [-8]}], [["add_counter", "dora", "count_dora", -8, ["hand", "calls", "flowers", "winning_tile"]]]],
  ["when", [{"name": "tile_revealed", "opts": [-10]}], [["add_counter", "dora", "count_dora", -10, ["hand", "calls", "flowers", "winning_tile"]]]],
  ["when", [{"name": "tile_revealed", "opts": [-12]}], [["add_counter", "dora", "count_dora", -12, ["hand", "calls", "flowers", "winning_tile"]]]],
  ["when", [{"name": "tile_revealed", "opts": [-14]}], [["add_counter", "dora", "count_dora", -14, ["hand", "calls", "flowers", "winning_tile"]]]],
  ["when", [{"name": "tile_revealed", "opts": [-16]}], [["add_counter", "dora", "count_dora", -16, ["hand", "calls", "flowers", "winning_tile"]]]],
  ["when", [{"name": "tile_revealed", "opts": [-18]}], [["add_counter", "dora", "count_dora", -18, ["hand", "calls", "flowers", "winning_tile"]]]]
]
|
# add dora yaku
.extra_yaku += [
  {"display_name": "Dora", "value": "dora", "when": [{"name": "counter_at_least", "opts": ["dora", 1]}]}
]
|
# tag dora with dora tag
.after_start.actions += [
  ["tag_dora", "dora", -6]
]
