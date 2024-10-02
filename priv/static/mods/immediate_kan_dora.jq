def remove_dora_flip_action:
  map(select(type != "array" or .[0] != "when" or .[1][0] != {"name": "status", "opts": ["kan"]} or .[1][1] != {"name": "not_status", "opts": ["ankan"]} or .[2][0][0] != "reveal_tile"));

def insert_after_kan_action($action; $arr):
  (map(type == "array" and .[0] == $action and (. | index("kan"))) | index(true)) as $ix
  |
  if $ix then (.[:$ix+1] + $arr + .[$ix+1:]) else . end;

# remove all "flip dora on X after non-ankan kan" actions
.before_turn_change.actions |= remove_dora_flip_action
|
.before_call.actions |= remove_dora_flip_action
|
.buttons.daiminkan.actions |= remove_dora_flip_action
|
.buttons.kakan.actions |= remove_dora_flip_action
|
.buttons.ankan.actions |= remove_dora_flip_action
|
# immediate dora flip
[
  ["when", [{"name": "tile_revealed", "opts": ["doraindicator_4"]}, {"name": "tile_not_revealed", "opts": ["doraindicator_5"]}], [["reveal_tile", "doraindicator_5"]]],
  ["when", [{"name": "tile_revealed", "opts": ["doraindicator_3"]}, {"name": "tile_not_revealed", "opts": ["doraindicator_4"]}], [["reveal_tile", "doraindicator_4"]]],
  ["when", [{"name": "tile_revealed", "opts": ["doraindicator_2"]}, {"name": "tile_not_revealed", "opts": ["doraindicator_3"]}], [["reveal_tile", "doraindicator_3"]]],
  ["when", [{"name": "tile_revealed", "opts": ["doraindicator_1"]}, {"name": "tile_not_revealed", "opts": ["doraindicator_2"]}], [["reveal_tile", "doraindicator_2"]]]
] as $immediate_flip_dora
|
.buttons.daiminkan.actions |= insert_after_kan_action("set_status"; $immediate_flip_dora)
|
.buttons.kakan.actions |= insert_after_kan_action("set_status"; $immediate_flip_dora)
