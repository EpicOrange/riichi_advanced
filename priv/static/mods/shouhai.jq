.starting_tiles = 12
|
.after_start.actions += [
  ["as", "east", [["set_aside_draw"]]],
  ["as", "everyone", [["draw", 1, "4x"], ["merge_draw"]]],
  ["as", "east", [["draw_from_aside"]]],
  ["set_tile_alias_all", ["4x"], ["any"]]
]
|
.play_restrictions += [[["4x"], []]]
|
[{"name": "not_call_contains", "opts": [["4x"], 1]}] as $call_restriction
|
if .buttons | has("chii") then
  .buttons.chii.call_restrictions += $call_restriction
else . end
|
if .buttons | has("pon") then
  .buttons.pon.call_restrictions += $call_restriction
else . end
|
if .buttons | has("daiminkan") then
  .buttons.daiminkan.call_restrictions += $call_restriction
else . end
|
if .buttons | has("kakan") then
  .buttons.kakan.call_restrictions += $call_restriction
else . end
|
if .buttons | has("ankan") then
  .buttons.ankan.call_restrictions += $call_restriction
else . end
|
if .buttons | has("pei") then
  .buttons.pei.call_restrictions += $call_restriction
else . end
# TODO saki buttons
