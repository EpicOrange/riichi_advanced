# add ura yaku
.extra_yaku += [
  {"display_name": "Ura", "value": 1, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": [-10]}, {"name": "winning_dora_count", "opts": [-9, 1]}]},
  {"display_name": "Ura", "value": 2, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": [-10]}, {"name": "winning_dora_count", "opts": [-9, 2]}]},
  {"display_name": "Ura", "value": 3, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": [-10]}, {"name": "winning_dora_count", "opts": [-9, 3]}]},
  {"display_name": "Ura", "value": 4, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": [-10]}, {"name": "winning_dora_count", "opts": [-9, 4]}]},
  {"display_name": "Ura", "value": 1, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": [-12]}, {"name": "winning_dora_count", "opts": [-11, 1]}]},
  {"display_name": "Ura", "value": 2, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": [-12]}, {"name": "winning_dora_count", "opts": [-11, 2]}]},
  {"display_name": "Ura", "value": 3, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": [-12]}, {"name": "winning_dora_count", "opts": [-11, 3]}]},
  {"display_name": "Ura", "value": 4, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": [-12]}, {"name": "winning_dora_count", "opts": [-11, 4]}]},
  {"display_name": "Ura", "value": 1, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": [-14]}, {"name": "winning_dora_count", "opts": [-13, 1]}]},
  {"display_name": "Ura", "value": 2, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": [-14]}, {"name": "winning_dora_count", "opts": [-13, 2]}]},
  {"display_name": "Ura", "value": 3, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": [-14]}, {"name": "winning_dora_count", "opts": [-13, 3]}]},
  {"display_name": "Ura", "value": 4, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": [-14]}, {"name": "winning_dora_count", "opts": [-13, 4]}]},
  {"display_name": "Ura", "value": 1, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": [-16]}, {"name": "winning_dora_count", "opts": [-15, 1]}]},
  {"display_name": "Ura", "value": 2, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": [-16]}, {"name": "winning_dora_count", "opts": [-15, 2]}]},
  {"display_name": "Ura", "value": 3, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": [-16]}, {"name": "winning_dora_count", "opts": [-15, 3]}]},
  {"display_name": "Ura", "value": 4, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": [-16]}, {"name": "winning_dora_count", "opts": [-15, 4]}]},
  {"display_name": "Ura", "value": 1, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": [-18]}, {"name": "winning_dora_count", "opts": [-17, 1]}]},
  {"display_name": "Ura", "value": 2, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": [-18]}, {"name": "winning_dora_count", "opts": [-17, 2]}]},
  {"display_name": "Ura", "value": 3, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": [-18]}, {"name": "winning_dora_count", "opts": [-17, 3]}]},
  {"display_name": "Ura", "value": 4, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": [-18]}, {"name": "winning_dora_count", "opts": [-17, 4]}]}
]
|
# reveal ura after riichi win
.before_win.actions += [
  ["when", [{"name": "status", "opts": ["riichi"]}, {"name": "status_missing", "opts": ["ura_revealed"]}], [
    ["set_status_all", "ura_revealed"],
    ["when", [{"name": "tile_not_revealed", "opts": [-10]}], [["reveal_tile", "1x"]]],
    ["when", [{"name": "tile_not_revealed", "opts": [-12]}], [["reveal_tile", "1x"]]],
    ["when", [{"name": "tile_not_revealed", "opts": [-14]}], [["reveal_tile", "1x"]]],
    ["when", [{"name": "tile_not_revealed", "opts": [-16]}], [["reveal_tile", "1x"]]],
    ["when", [{"name": "tile_not_revealed", "opts": [-18]}], [["reveal_tile", "1x"]]],
    ["when", [{"name": "tile_revealed", "opts": [-10]}], [["reveal_tile", -9]]],
    ["when", [{"name": "tile_revealed", "opts": [-12]}], [["reveal_tile", -11]]],
    ["when", [{"name": "tile_revealed", "opts": [-14]}], [["reveal_tile", -13]]],
    ["when", [{"name": "tile_revealed", "opts": [-16]}], [["reveal_tile", -15]]],
    ["when", [{"name": "tile_revealed", "opts": [-18]}], [["reveal_tile", -17]]],
    ["when", [{"name": "tile_not_revealed", "opts": [-9]}], [["reveal_tile", "1x"]]],
    ["when", [{"name": "tile_not_revealed", "opts": [-11]}], [["reveal_tile", "1x"]]],
    ["when", [{"name": "tile_not_revealed", "opts": [-13]}], [["reveal_tile", "1x"]]],
    ["when", [{"name": "tile_not_revealed", "opts": [-15]}], [["reveal_tile", "1x"]]],
    ["when", [{"name": "tile_not_revealed", "opts": [-17]}], [["reveal_tile", "1x"]]]
  ]]
]
