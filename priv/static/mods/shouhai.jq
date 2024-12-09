def add_call_restriction($call):
  if .buttons | has($call) then
    .buttons[$call].call_restrictions += [{"name": "not_call_contains", "opts": [["4x"], 1]}]
  else . end;

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
add_call_restriction("chii")
|
add_call_restriction("pon")
|
add_call_restriction("daiminkan")
|
add_call_restriction("kakan")
|
add_call_restriction("ankan")
|
add_call_restriction("pei")

# TODO saki buttons?
