def fix_calls:
  .show_when += [
    "not_game_start",
    {"name": "counter_equals", "as": "last_discarder", "opts": ["discards", 0]}
  ];

def fix_wins:
  .show_when += [
    "not_game_start",
    {"name": "counter_equals", "opts": ["discards", 1]}
  ]
  |
  .show_when |= map(select(IN("has_draw") | not));

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
  ["subtract_counter", "discards", 1],
  ["ite", [{"name": "counter_at_least", "opts": ["discards", 1]}], [
    ["change_turn", "self"]
  ], [
    ["as", "shimocha", [["set_counter", "discards", 4]]],
    ["change_turn", "shimocha"]
  ]]
]
|
.buttons |= if has("riichi") then
  .riichi |= fix_wins
else . end
|
.buttons |= if has("tsumo") then
  .tsumo |= fix_wins
else . end
|
.buttons |= if has("chii") then
  .chii |= fix_calls
else . end
|
.buttons |= if has("pon") then
  .pon |= fix_calls
else . end
|
.buttons |= if has("daiminkan") then
  .daiminkan |= fix_calls
else . end
|
.functions.kan_draw += [
  ["add_counter", "discards", 1]
]
|
if (.buttons | has("ankan")) then
  .buttons.ankan.call_style = {"self": [0, 1, 2, 3]}
else . end
|
.default_mods |= map(select(IN("yaku/riichi", "kan", "dora", "ura", "kandora") | not))
|
.available_mods |= map(select(type != "object" or (.id | IN("yaku/riichi", "kan") | not)))
