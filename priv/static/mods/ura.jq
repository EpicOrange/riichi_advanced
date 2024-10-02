# add ura yaku
.extra_yaku += [
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
|
# reveal ura after riichi win
.before_win.actions += [
  ["when", [{"name": "status", "opts": ["riichi"]}, {"name": "tile_not_revealed", "opts": ["doraindicator_1"]}], [["reveal_tile", "1x"]]],
  ["when", [{"name": "status", "opts": ["riichi"]}, {"name": "tile_not_revealed", "opts": ["doraindicator_2"]}], [["reveal_tile", "1x"]]],
  ["when", [{"name": "status", "opts": ["riichi"]}, {"name": "tile_not_revealed", "opts": ["doraindicator_3"]}], [["reveal_tile", "1x"]]],
  ["when", [{"name": "status", "opts": ["riichi"]}, {"name": "tile_not_revealed", "opts": ["doraindicator_4"]}], [["reveal_tile", "1x"]]],
  ["when", [{"name": "status", "opts": ["riichi"]}, {"name": "tile_not_revealed", "opts": ["doraindicator_5"]}], [["reveal_tile", "1x"]]],
  ["when", [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": ["doraindicator_1"]}], [["reveal_tile", "uraindicator_1"]]],
  ["when", [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": ["doraindicator_2"]}], [["reveal_tile", "uraindicator_2"]]],
  ["when", [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": ["doraindicator_3"]}], [["reveal_tile", "uraindicator_3"]]],
  ["when", [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": ["doraindicator_4"]}], [["reveal_tile", "uraindicator_4"]]],
  ["when", [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": ["doraindicator_5"]}], [["reveal_tile", "uraindicator_5"]]],
  ["when", [{"name": "status", "opts": ["riichi"]}, {"name": "tile_not_revealed", "opts": ["uraindicator_1"]}], [["reveal_tile", "1x"]]],
  ["when", [{"name": "status", "opts": ["riichi"]}, {"name": "tile_not_revealed", "opts": ["uraindicator_2"]}], [["reveal_tile", "1x"]]],
  ["when", [{"name": "status", "opts": ["riichi"]}, {"name": "tile_not_revealed", "opts": ["uraindicator_3"]}], [["reveal_tile", "1x"]]],
  ["when", [{"name": "status", "opts": ["riichi"]}, {"name": "tile_not_revealed", "opts": ["uraindicator_4"]}], [["reveal_tile", "1x"]]],
  ["when", [{"name": "status", "opts": ["riichi"]}, {"name": "tile_not_revealed", "opts": ["uraindicator_5"]}], [["reveal_tile", "1x"]]]
]
