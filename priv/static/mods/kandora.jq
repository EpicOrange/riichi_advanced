def insert_after_kan_draw($arr):
  (map(.[:2] == ["run", "do_kan_draw"]) | index(true)) as $ix
  |
  if $ix then (.[:$ix+1] + $arr + .[$ix+1:]) else . end;

.after_initialization.actions += [["add_rule", "Rules", "Kandora", "Every kan reveals another dora indicator after the discard, except for concealed kan, which reveals one immediately."]]
|
# flip next dora after non-ankan kan
.functions.flip_dora = [
  ["when", [{"name": "tile_revealed", "opts": [-16]}, {"name": "tile_not_revealed", "opts": [-18]}], [["reveal_tile", -18], ["tag_dora", "dora", -18]]],
  ["when", [{"name": "tile_revealed", "opts": [-14]}, {"name": "tile_not_revealed", "opts": [-16]}], [["reveal_tile", -16], ["tag_dora", "dora", -16]]],
  ["when", [{"name": "tile_revealed", "opts": [-12]}, {"name": "tile_not_revealed", "opts": [-14]}], [["reveal_tile", -14], ["tag_dora", "dora", -14]]],
  ["when", [{"name": "tile_revealed", "opts": [-10]}, {"name": "tile_not_revealed", "opts": [-12]}], [["reveal_tile", -12], ["tag_dora", "dora", -12]]],
  ["when", [{"name": "tile_revealed", "opts": [-8]}, {"name": "tile_not_revealed", "opts": [-10]}], [["reveal_tile", -10], ["tag_dora", "dora", -10]]],
  ["when", [{"name": "tile_revealed", "opts": [-6]}, {"name": "tile_not_revealed", "opts": [-8]}], [["reveal_tile", -8], ["tag_dora", "dora", -8]]]
]
|
[["when", [{"name": "status", "opts": ["kan"]}, {"name": "status_missing", "opts": ["skip_kan_dora_flip"]}], [["run", "flip_dora"]]]] as $flip_after_kan
|
# dora flip on turn change
.functions.turn_cleanup += $flip_after_kan
|
# dora flip on win
.before_win.actions = $flip_after_kan + .before_win.actions
|
# reset the new ankan status
.before_turn_change.actions += [["when", ["not_just_called"], [["unset_status", "skip_kan_dora_flip"]]]]
|
# dora flips immediately after ankan
# set status to prevent dora flip after turn change
if (.buttons | has("ankan")) then
  .buttons.ankan.actions |= insert_after_kan_draw([["run", "flip_dora"], ["set_status", "skip_kan_dora_flip"]])
else . end
