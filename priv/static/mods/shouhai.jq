def add_call_conditions($call):
  if .buttons | has($call) then
    .buttons[$call].call_conditions += [{"name": "not_call_contains", "opts": [["4x"], 1]}]
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
add_call_conditions("chii")
|
add_call_conditions("pon")
|
add_call_conditions("daiminkan")
|
add_call_conditions("kakan")
|
add_call_conditions("ankan")
|
add_call_conditions("pei")

# TODO saki buttons?
