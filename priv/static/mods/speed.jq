.yaku |= walk(if type == "array" and .[0] == "exhaustive" then ["nojoker"] + . else . end)
|
.after_start.actions += [
  ["set_tile_alias_all", ["2z", "3z", "4z"], ["1z"]],
  ["set_tile_alias_all", ["6z", "7z"], ["5z"]],
  ["as", "south", [["set_status", "opposite_end"]]],
  ["as", "north", [["set_status", "opposite_end"]]],
  ["as", "east", [["set_counter", "discards", 4], ["draw", 4]]]
]
|
.after_turn_change.actions |= map(if . == ["ite", ["no_tiles_remaining"], [["pause", 1000], ["ryuukyoku"]], [["draw"]]] then
  ["ite", ["no_tiles_remaining"], [["pause", 1000], ["ryuukyoku"]], [
    ["when", [{"name": "counter_at_least", "opts": ["discards", 4]}], [
      ["ite", [{"name": "status", "opts": ["opposite_end"]}], [["draw", 4, "opposite_end"]], [["draw", 4]]]
    ]]
  ]]
else . end)
|
.before_turn_change.actions += [
  ["ite", [{"name": "counter_at_least", "opts": ["discards", 2]}], [
    ["subtract_counter", "discards", 1], ["change_turn", "self"]
  ], [
    ["recalculate_buttons"],
    ["as", "shimocha", [["set_counter", "discards", 4]]],
    ["change_turn", "shimocha"]
  ]]
]
|
.buttons.riichi.show_when += [
  "not_game_start",
  {"name": "counter_at_most", "opts": ["discards", 1]}
]
|
.functions.kan_draw += [
  ["add_counter", "discards", 1]
]
|
.default_mods |= map(select(IN("kan", "dora", "ura", "kandora") | not))
|
.available_mods |= map(select(type != "object" or (.id | IN("kan") | not)))
|
.interruptible_actions |= map(select(IN("play_tile", "advance_turn") | not))
