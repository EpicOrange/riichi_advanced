.reserved_tiles = [
  "doraindicator_5", "uraindicator_5",
  "doraindicator_4", "uraindicator_4",
  "doraindicator_3", "uraindicator_3",
  "doraindicator_2", "uraindicator_2",
  "doraindicator_1", "uraindicator_1"
] + .reserved_tiles
|
.revealed_tiles += ["doraindicator_1"]
|
.max_revealed_tiles = 5
|
.extra_yaku += [
  {"display_name": "Dora", "value": 1, "when": [{"name": "tile_revealed", "opts": ["doraindicator_1"]}, {"name": "winning_dora_count", "opts": ["doraindicator_1", 1]}]},
  {"display_name": "Dora", "value": 2, "when": [{"name": "tile_revealed", "opts": ["doraindicator_1"]}, {"name": "winning_dora_count", "opts": ["doraindicator_1", 2]}]},
  {"display_name": "Dora", "value": 3, "when": [{"name": "tile_revealed", "opts": ["doraindicator_1"]}, {"name": "winning_dora_count", "opts": ["doraindicator_1", 3]}]},
  {"display_name": "Dora", "value": 4, "when": [{"name": "tile_revealed", "opts": ["doraindicator_1"]}, {"name": "winning_dora_count", "opts": ["doraindicator_1", 4]}]},
  {"display_name": "Dora", "value": 1, "when": [{"name": "tile_revealed", "opts": ["doraindicator_2"]}, {"name": "winning_dora_count", "opts": ["doraindicator_2", 1]}]},
  {"display_name": "Dora", "value": 2, "when": [{"name": "tile_revealed", "opts": ["doraindicator_2"]}, {"name": "winning_dora_count", "opts": ["doraindicator_2", 2]}]},
  {"display_name": "Dora", "value": 3, "when": [{"name": "tile_revealed", "opts": ["doraindicator_2"]}, {"name": "winning_dora_count", "opts": ["doraindicator_2", 3]}]},
  {"display_name": "Dora", "value": 4, "when": [{"name": "tile_revealed", "opts": ["doraindicator_2"]}, {"name": "winning_dora_count", "opts": ["doraindicator_2", 4]}]},
  {"display_name": "Dora", "value": 1, "when": [{"name": "tile_revealed", "opts": ["doraindicator_3"]}, {"name": "winning_dora_count", "opts": ["doraindicator_3", 1]}]},
  {"display_name": "Dora", "value": 2, "when": [{"name": "tile_revealed", "opts": ["doraindicator_3"]}, {"name": "winning_dora_count", "opts": ["doraindicator_3", 2]}]},
  {"display_name": "Dora", "value": 3, "when": [{"name": "tile_revealed", "opts": ["doraindicator_3"]}, {"name": "winning_dora_count", "opts": ["doraindicator_3", 3]}]},
  {"display_name": "Dora", "value": 4, "when": [{"name": "tile_revealed", "opts": ["doraindicator_3"]}, {"name": "winning_dora_count", "opts": ["doraindicator_3", 4]}]},
  {"display_name": "Dora", "value": 1, "when": [{"name": "tile_revealed", "opts": ["doraindicator_4"]}, {"name": "winning_dora_count", "opts": ["doraindicator_4", 1]}]},
  {"display_name": "Dora", "value": 2, "when": [{"name": "tile_revealed", "opts": ["doraindicator_4"]}, {"name": "winning_dora_count", "opts": ["doraindicator_4", 2]}]},
  {"display_name": "Dora", "value": 3, "when": [{"name": "tile_revealed", "opts": ["doraindicator_4"]}, {"name": "winning_dora_count", "opts": ["doraindicator_4", 3]}]},
  {"display_name": "Dora", "value": 4, "when": [{"name": "tile_revealed", "opts": ["doraindicator_4"]}, {"name": "winning_dora_count", "opts": ["doraindicator_4", 4]}]},
  {"display_name": "Dora", "value": 1, "when": [{"name": "tile_revealed", "opts": ["doraindicator_5"]}, {"name": "winning_dora_count", "opts": ["doraindicator_5", 1]}]},
  {"display_name": "Dora", "value": 2, "when": [{"name": "tile_revealed", "opts": ["doraindicator_5"]}, {"name": "winning_dora_count", "opts": ["doraindicator_5", 2]}]},
  {"display_name": "Dora", "value": 3, "when": [{"name": "tile_revealed", "opts": ["doraindicator_5"]}, {"name": "winning_dora_count", "opts": ["doraindicator_5", 3]}]},
  {"display_name": "Dora", "value": 4, "when": [{"name": "tile_revealed", "opts": ["doraindicator_5"]}, {"name": "winning_dora_count", "opts": ["doraindicator_5", 4]}]},
  {"display_name": "Ura", "value": 1, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": ["doraindicator_1"]}, {"name": "winning_dora_count", "opts": ["uraindicator_1", 1]}]},
  {"display_name": "Ura", "value": 2, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": ["doraindicator_1"]}, {"name": "winning_dora_count", "opts": ["uraindicator_1", 2]}]},
  {"display_name": "Ura", "value": 3, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": ["doraindicator_1"]}, {"name": "winning_dora_count", "opts": ["uraindicator_1", 3]}]},
  {"display_name": "Ura", "value": 4, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": ["doraindicator_1"]}, {"name": "winning_dora_count", "opts": ["uraindicator_1", 4]}]},
  {"display_name": "Ura", "value": 1, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": ["doraindicator_2"]}, {"name": "winning_dora_count", "opts": ["uraindicator_2", 1]}]},
  {"display_name": "Ura", "value": 2, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": ["doraindicator_2"]}, {"name": "winning_dora_count", "opts": ["uraindicator_2", 2]}]},
  {"display_name": "Ura", "value": 3, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": ["doraindicator_2"]}, {"name": "winning_dora_count", "opts": ["uraindicator_2", 3]}]},
  {"display_name": "Ura", "value": 4, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": ["doraindicator_2"]}, {"name": "winning_dora_count", "opts": ["uraindicator_2", 4]}]},
  {"display_name": "Ura", "value": 1, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": ["doraindicator_3"]}, {"name": "winning_dora_count", "opts": ["uraindicator_3", 1]}]},
  {"display_name": "Ura", "value": 2, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": ["doraindicator_3"]}, {"name": "winning_dora_count", "opts": ["uraindicator_3", 2]}]},
  {"display_name": "Ura", "value": 3, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": ["doraindicator_3"]}, {"name": "winning_dora_count", "opts": ["uraindicator_3", 3]}]},
  {"display_name": "Ura", "value": 4, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": ["doraindicator_3"]}, {"name": "winning_dora_count", "opts": ["uraindicator_3", 4]}]},
  {"display_name": "Ura", "value": 1, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": ["doraindicator_4"]}, {"name": "winning_dora_count", "opts": ["uraindicator_4", 1]}]},
  {"display_name": "Ura", "value": 2, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": ["doraindicator_4"]}, {"name": "winning_dora_count", "opts": ["uraindicator_4", 2]}]},
  {"display_name": "Ura", "value": 3, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": ["doraindicator_4"]}, {"name": "winning_dora_count", "opts": ["uraindicator_4", 3]}]},
  {"display_name": "Ura", "value": 4, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": ["doraindicator_4"]}, {"name": "winning_dora_count", "opts": ["uraindicator_4", 4]}]},
  {"display_name": "Ura", "value": 1, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": ["doraindicator_5"]}, {"name": "winning_dora_count", "opts": ["uraindicator_5", 1]}]},
  {"display_name": "Ura", "value": 2, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": ["doraindicator_5"]}, {"name": "winning_dora_count", "opts": ["uraindicator_5", 2]}]},
  {"display_name": "Ura", "value": 3, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": ["doraindicator_5"]}, {"name": "winning_dora_count", "opts": ["uraindicator_5", 3]}]},
  {"display_name": "Ura", "value": 4, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": ["doraindicator_5"]}, {"name": "winning_dora_count", "opts": ["uraindicator_5", 4]}]}
]
