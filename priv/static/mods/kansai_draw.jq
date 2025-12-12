def replace($from; $to):
  if . == $from then $to else . end;

# end the game at the last dora indicator
.after_turn_change.actions |= map(replace(
  ["ite", ["no_tiles_remaining"], [["pause", 1000], ["ryuukyoku"]], [["draw"]]];
  ["ite", [{"name": "tile_revealed", "opts": [0]}], [["pause", 1000], ["ryuukyoku"]], [["draw"]]]
))
|
# change haitei/houtei
.yaku |= map(
  if .display_name == "Haitei" then
    .when = [{"name": "tile_revealed", "opts": [0]}, "won_by_draw"]
  elif .display_name == "Houtei" then
    .when = [{"name": "tile_revealed", "opts": [0]}, "not_won_by_draw"]
  else . end
)
|
if (.buttons | has("daiminkan")) then
  .buttons.ankan.show_when |= map(replace("not_no_tiles_remaining"; {"name": "not_tile_revealed", "opts": [0]}))
else . end
|
if (.buttons | has("kakan")) then
  .buttons.ankan.show_when |= map(replace("not_no_tiles_remaining"; {"name": "not_tile_revealed", "opts": [0]}))
else . end
|
if (.buttons | has("ankan")) then
  .buttons.ankan.show_when |= map(replace("not_no_tiles_remaining"; {"name": "not_tile_revealed", "opts": [0]}))
else . end
|
if (.buttons | has("flower")) then
  .buttons.flower.show_when |= map(replace("not_no_tiles_remaining"; {"name": "not_tile_revealed", "opts": [0]}))
else . end
