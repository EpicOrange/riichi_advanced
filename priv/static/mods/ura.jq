# add ura yaku
.extra_yaku += [
  {"display_name": "Ura", "value": 1, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": [-6]}, {"name": "winning_dora_count", "opts": [-5, 1]}]},
  {"display_name": "Ura", "value": 2, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": [-6]}, {"name": "winning_dora_count", "opts": [-5, 2]}]},
  {"display_name": "Ura", "value": 3, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": [-6]}, {"name": "winning_dora_count", "opts": [-5, 3]}]},
  {"display_name": "Ura", "value": 4, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": [-6]}, {"name": "winning_dora_count", "opts": [-5, 4]}]},
  {"display_name": "Ura", "value": 1, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": [-8]}, {"name": "winning_dora_count", "opts": [-7, 1]}]},
  {"display_name": "Ura", "value": 2, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": [-8]}, {"name": "winning_dora_count", "opts": [-7, 2]}]},
  {"display_name": "Ura", "value": 3, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": [-8]}, {"name": "winning_dora_count", "opts": [-7, 3]}]},
  {"display_name": "Ura", "value": 4, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": [-8]}, {"name": "winning_dora_count", "opts": [-7, 4]}]},
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
  {"display_name": "Ura", "value": 4, "when": [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": [-14]}, {"name": "winning_dora_count", "opts": [-13, 4]}]}
]
|
# reveal ura after riichi win
.before_win.actions += [
  ["when", [{"name": "status", "opts": ["riichi"]}, {"name": "status_missing", "opts": ["ura_revealed"]}], [
    ["set_status_all", "ura_revealed"],
    ["when", [{"name": "tile_not_revealed", "opts": [-6]}], [["reveal_tile", "1x"]]],
    ["when", [{"name": "tile_not_revealed", "opts": [-8]}], [["reveal_tile", "1x"]]],
    ["when", [{"name": "tile_not_revealed", "opts": [-10]}], [["reveal_tile", "1x"]]],
    ["when", [{"name": "tile_not_revealed", "opts": [-12]}], [["reveal_tile", "1x"]]],
    ["when", [{"name": "tile_not_revealed", "opts": [-14]}], [["reveal_tile", "1x"]]],
    ["when", [{"name": "tile_revealed", "opts": [-6]}], [["reveal_tile", -5]]],
    ["when", [{"name": "tile_revealed", "opts": [-8]}], [["reveal_tile", -7]]],
    ["when", [{"name": "tile_revealed", "opts": [-10]}], [["reveal_tile", -9]]],
    ["when", [{"name": "tile_revealed", "opts": [-12]}], [["reveal_tile", -11]]],
    ["when", [{"name": "tile_revealed", "opts": [-14]}], [["reveal_tile", -13]]],
    ["when", [{"name": "tile_not_revealed", "opts": [-5]}], [["reveal_tile", "1x"]]],
    ["when", [{"name": "tile_not_revealed", "opts": [-7]}], [["reveal_tile", "1x"]]],
    ["when", [{"name": "tile_not_revealed", "opts": [-9]}], [["reveal_tile", "1x"]]],
    ["when", [{"name": "tile_not_revealed", "opts": [-11]}], [["reveal_tile", "1x"]]],
    ["when", [{"name": "tile_not_revealed", "opts": [-13]}], [["reveal_tile", "1x"]]]
  ]]
]
