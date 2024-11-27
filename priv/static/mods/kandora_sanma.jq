def insert_before_kan_action($action; $arr):
  (map(type == "array" and .[0] == $action and (. | index("kan"))) | index(true)) as $ix
  |
  if $ix then (.[:$ix] + $arr + .[$ix:]) else . end;
def insert_after_kan_action($action; $arr):
  (map(type == "array" and .[0] == $action and (. | index("kan"))) | index(true)) as $ix
  |
  if $ix then (.[:$ix+1] + $arr + .[$ix+1:]) else . end;

# flip next dora after non-ankan kan
[
  ["when", [{"name": "status", "opts": ["kan"]}, {"name": "not_status", "opts": ["ankan"]}, {"name": "tile_revealed", "opts": [-16]}, {"name": "tile_not_revealed", "opts": [-18]}], [["reveal_tile", -18]]],
  ["when", [{"name": "status", "opts": ["kan"]}, {"name": "not_status", "opts": ["ankan"]}, {"name": "tile_revealed", "opts": [-14]}, {"name": "tile_not_revealed", "opts": [-16]}], [["reveal_tile", -16]]],
  ["when", [{"name": "status", "opts": ["kan"]}, {"name": "not_status", "opts": ["ankan"]}, {"name": "tile_revealed", "opts": [-12]}, {"name": "tile_not_revealed", "opts": [-14]}], [["reveal_tile", -14]]],
  ["when", [{"name": "status", "opts": ["kan"]}, {"name": "not_status", "opts": ["ankan"]}, {"name": "tile_revealed", "opts": [-10]}, {"name": "tile_not_revealed", "opts": [-12]}], [["reveal_tile", -12]]]
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
.buttons.pei.actions |= insert_before_kan_action("set_status"; $flip_dora) # dora flip on pei after non-ankan kan
|
# dora flips immediately after ankan
.buttons.ankan.actions |= insert_after_kan_action("set_status"; [
  ["when", [{"name": "tile_revealed", "opts": [-16]}, {"name": "tile_not_revealed", "opts": [-18]}], [["reveal_tile", -18]]],
  ["when", [{"name": "tile_revealed", "opts": [-14]}, {"name": "tile_not_revealed", "opts": [-16]}], [["reveal_tile", -16]]],
  ["when", [{"name": "tile_revealed", "opts": [-12]}, {"name": "tile_not_revealed", "opts": [-14]}], [["reveal_tile", -14]]],
  ["when", [{"name": "tile_revealed", "opts": [-10]}, {"name": "tile_not_revealed", "opts": [-12]}], [["reveal_tile", -12]]]
])
|
# dora flip on win after non-ankan kan
.before_win.actions = $flip_dora + .before_win.actions
