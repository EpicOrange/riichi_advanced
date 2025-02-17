# reveal ura after riichi win and count ura
.before_win.actions += [
  ["when", [{"name": "status", "opts": ["riichi"]}, {"name": "status_missing", "opts": ["ura_revealed"]}], [
    ["set_status_all", "ura_revealed"],
    ["ite", [{"name": "tile_revealed", "opts": [-6]}], [
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
    ], [
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
  ]],
  ["when", [{"name": "tile_revealed", "opts": [-5]}], [["add_counter", "ura", "count_dora", -5, ["hand", "calls", "flowers", "winning_tile"]]]],
  ["when", [{"name": "tile_revealed", "opts": [-7]}], [["add_counter", "ura", "count_dora", -7, ["hand", "calls", "flowers", "winning_tile"]]]],
  ["when", [{"name": "tile_revealed", "opts": [-9]}], [["add_counter", "ura", "count_dora", -9, ["hand", "calls", "flowers", "winning_tile"]]]],
  ["when", [{"name": "tile_revealed", "opts": [-11]}], [["add_counter", "ura", "count_dora", -11, ["hand", "calls", "flowers", "winning_tile"]]]],
  ["when", [{"name": "tile_revealed", "opts": [-13]}], [["add_counter", "ura", "count_dora", -13, ["hand", "calls", "flowers", "winning_tile"]]]],
  ["when", [{"name": "tile_revealed", "opts": [-15]}], [["add_counter", "ura", "count_dora", -15, ["hand", "calls", "flowers", "winning_tile"]]]],
  ["when", [{"name": "tile_revealed", "opts": [-17]}], [["add_counter", "ura", "count_dora", -17, ["hand", "calls", "flowers", "winning_tile"]]]]
]
|
.before_scoring.actions |= [["set_counter", "ura", 0]] + . + [
  ["when", [{"name": "tile_revealed", "opts": [-5]}], [["add_counter", "ura", "count_dora", -5, ["hand", "calls", "flowers", "winning_tile"]]]],
  ["when", [{"name": "tile_revealed", "opts": [-7]}], [["add_counter", "ura", "count_dora", -7, ["hand", "calls", "flowers", "winning_tile"]]]],
  ["when", [{"name": "tile_revealed", "opts": [-9]}], [["add_counter", "ura", "count_dora", -9, ["hand", "calls", "flowers", "winning_tile"]]]],
  ["when", [{"name": "tile_revealed", "opts": [-11]}], [["add_counter", "ura", "count_dora", -11, ["hand", "calls", "flowers", "winning_tile"]]]],
  ["when", [{"name": "tile_revealed", "opts": [-13]}], [["add_counter", "ura", "count_dora", -13, ["hand", "calls", "flowers", "winning_tile"]]]],
  ["when", [{"name": "tile_revealed", "opts": [-15]}], [["add_counter", "ura", "count_dora", -15, ["hand", "calls", "flowers", "winning_tile"]]]],
  ["when", [{"name": "tile_revealed", "opts": [-17]}], [["add_counter", "ura", "count_dora", -17, ["hand", "calls", "flowers", "winning_tile"]]]]
]
|
# add ura yaku
.extra_yaku += [
  {"display_name": "Ura", "value": "ura", "when": [{"name": "counter_at_least", "opts": ["ura", 1]}]}
]
