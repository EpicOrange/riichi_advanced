def insert_before_kan_action($action; $arr):
  (map(type == "array" and .[0] == $action and (. | index("kan"))) | index(true)) as $ix
  |
  if $ix then (.[:$ix] + $arr + .[$ix:]) else . end;
def insert_after_kan_action($action; $arr):
  (map(type == "array" and .[0] == $action and (. | index("kan"))) | index(true)) as $ix
  |
  if $ix then (.[:$ix+1] + $arr + .[$ix+1:]) else . end;

# reserve dora indicator tiles in dead wall
.reserved_tiles = [
  "doraindicator_5", "uraindicator_5",
  "doraindicator_4", "uraindicator_4",
  "doraindicator_3", "uraindicator_3",
  "doraindicator_2", "uraindicator_2",
  "doraindicator_1", "uraindicator_1"
] + .reserved_tiles
|
.max_revealed_tiles = 5
|
# initial dora flip
.revealed_tiles += ["doraindicator_1"]
|
# add dora yaku
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
  {"display_name": "Dora", "value": 4, "when": [{"name": "tile_revealed", "opts": ["doraindicator_5"]}, {"name": "winning_dora_count", "opts": ["doraindicator_5", 4]}]}
]
|
# flip next dora after non-ankan kan
[
  ["when", [{"name": "status", "opts": ["kan"]}, {"name": "not_status", "opts": ["ankan"]}, {"name": "tile_revealed", "opts": ["doraindicator_4"]}, {"name": "tile_not_revealed", "opts": ["doraindicator_5"]}], [["reveal_tile", "doraindicator_5"]]],
  ["when", [{"name": "status", "opts": ["kan"]}, {"name": "not_status", "opts": ["ankan"]}, {"name": "tile_revealed", "opts": ["doraindicator_3"]}, {"name": "tile_not_revealed", "opts": ["doraindicator_4"]}], [["reveal_tile", "doraindicator_4"]]],
  ["when", [{"name": "status", "opts": ["kan"]}, {"name": "not_status", "opts": ["ankan"]}, {"name": "tile_revealed", "opts": ["doraindicator_2"]}, {"name": "tile_not_revealed", "opts": ["doraindicator_3"]}], [["reveal_tile", "doraindicator_3"]]],
  ["when", [{"name": "status", "opts": ["kan"]}, {"name": "not_status", "opts": ["ankan"]}, {"name": "tile_revealed", "opts": ["doraindicator_1"]}, {"name": "tile_not_revealed", "opts": ["doraindicator_2"]}], [["reveal_tile", "doraindicator_2"]]]
] as $flip_dora
|
.before_turn_change.actions |= insert_before_kan_action("unset_status"; $flip_dora) # dora flip on discard after non-ankan kan
|
.before_call.actions |= insert_before_kan_action("unset_status"; $flip_dora) # dora flip on call after non-ankan kan
|
.buttons.daiminkan.actions |= insert_before_kan_action("set_status"; $flip_dora) # dora flip on daiminkan after non-ankan kan
|
.buttons.kakan.actions |= insert_before_kan_action("set_status"; $flip_dora) # dora flip on kakan after non-ankan kan
|
.buttons.ankan.actions |= insert_before_kan_action("set_status"; $flip_dora) # dora flip on ankan after non-ankan kan
|
# dora flips immediately after ankan
.buttons.ankan.actions |= insert_after_kan_action("set_status"; [
  ["when", [{"name": "tile_revealed", "opts": ["doraindicator_4"]}, {"name": "tile_not_revealed", "opts": ["doraindicator_5"]}], [["reveal_tile", "doraindicator_5"]]],
  ["when", [{"name": "tile_revealed", "opts": ["doraindicator_3"]}, {"name": "tile_not_revealed", "opts": ["doraindicator_4"]}], [["reveal_tile", "doraindicator_4"]]],
  ["when", [{"name": "tile_revealed", "opts": ["doraindicator_2"]}, {"name": "tile_not_revealed", "opts": ["doraindicator_3"]}], [["reveal_tile", "doraindicator_3"]]],
  ["when", [{"name": "tile_revealed", "opts": ["doraindicator_1"]}, {"name": "tile_not_revealed", "opts": ["doraindicator_2"]}], [["reveal_tile", "doraindicator_2"]]]
])
|
# dora flip on win after non-ankan kan
.before_win.actions = $flip_dora + .before_win.actions
