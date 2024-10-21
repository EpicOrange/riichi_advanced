.max_revealed_tiles = 5
|
# initial dora flip
.revealed_tiles += [-6]
|
# dora indicator map
.dora_indicators = {
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
# add dora yaku
.extra_yaku += [
  {"display_name": "Dora", "value": 1, "when": [{"name": "tile_revealed", "opts": [-6]}, {"name": "winning_dora_count", "opts": [-6, 1]}]},
  {"display_name": "Dora", "value": 2, "when": [{"name": "tile_revealed", "opts": [-6]}, {"name": "winning_dora_count", "opts": [-6, 2]}]},
  {"display_name": "Dora", "value": 3, "when": [{"name": "tile_revealed", "opts": [-6]}, {"name": "winning_dora_count", "opts": [-6, 3]}]},
  {"display_name": "Dora", "value": 4, "when": [{"name": "tile_revealed", "opts": [-6]}, {"name": "winning_dora_count", "opts": [-6, 4]}]},
  {"display_name": "Dora", "value": 1, "when": [{"name": "tile_revealed", "opts": [-8]}, {"name": "winning_dora_count", "opts": [-8, 1]}]},
  {"display_name": "Dora", "value": 2, "when": [{"name": "tile_revealed", "opts": [-8]}, {"name": "winning_dora_count", "opts": [-8, 2]}]},
  {"display_name": "Dora", "value": 3, "when": [{"name": "tile_revealed", "opts": [-8]}, {"name": "winning_dora_count", "opts": [-8, 3]}]},
  {"display_name": "Dora", "value": 4, "when": [{"name": "tile_revealed", "opts": [-8]}, {"name": "winning_dora_count", "opts": [-8, 4]}]},
  {"display_name": "Dora", "value": 1, "when": [{"name": "tile_revealed", "opts": [-10]}, {"name": "winning_dora_count", "opts": [-10, 1]}]},
  {"display_name": "Dora", "value": 2, "when": [{"name": "tile_revealed", "opts": [-10]}, {"name": "winning_dora_count", "opts": [-10, 2]}]},
  {"display_name": "Dora", "value": 3, "when": [{"name": "tile_revealed", "opts": [-10]}, {"name": "winning_dora_count", "opts": [-10, 3]}]},
  {"display_name": "Dora", "value": 4, "when": [{"name": "tile_revealed", "opts": [-10]}, {"name": "winning_dora_count", "opts": [-10, 4]}]},
  {"display_name": "Dora", "value": 1, "when": [{"name": "tile_revealed", "opts": [-12]}, {"name": "winning_dora_count", "opts": [-12, 1]}]},
  {"display_name": "Dora", "value": 2, "when": [{"name": "tile_revealed", "opts": [-12]}, {"name": "winning_dora_count", "opts": [-12, 2]}]},
  {"display_name": "Dora", "value": 3, "when": [{"name": "tile_revealed", "opts": [-12]}, {"name": "winning_dora_count", "opts": [-12, 3]}]},
  {"display_name": "Dora", "value": 4, "when": [{"name": "tile_revealed", "opts": [-12]}, {"name": "winning_dora_count", "opts": [-12, 4]}]},
  {"display_name": "Dora", "value": 1, "when": [{"name": "tile_revealed", "opts": [-14]}, {"name": "winning_dora_count", "opts": [-14, 1]}]},
  {"display_name": "Dora", "value": 2, "when": [{"name": "tile_revealed", "opts": [-14]}, {"name": "winning_dora_count", "opts": [-14, 2]}]},
  {"display_name": "Dora", "value": 3, "when": [{"name": "tile_revealed", "opts": [-14]}, {"name": "winning_dora_count", "opts": [-14, 3]}]},
  {"display_name": "Dora", "value": 4, "when": [{"name": "tile_revealed", "opts": [-14]}, {"name": "winning_dora_count", "opts": [-14, 4]}]}
]
