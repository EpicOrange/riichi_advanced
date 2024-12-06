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
