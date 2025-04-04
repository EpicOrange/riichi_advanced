def add_call_conditions($call):
  if .buttons | has($call) then
    .buttons[$call].call_conditions += [{"name": "not_call_contains", "opts": [["4x"], 1]}]
  else . end;

.after_initialization.actions += [["add_rule", "Rules", "Shouhai", "Reduces tiles in hand from 13 to 12. The goal is to achieve a tenpai hand rather than a winning hand. The idea is that your 13th tile is replaced with an invisible 'joker' tile that can be used to complete any hand."]]
|
if .starting_tiles == 34 and (.buttons | has("build")) then
  # for minefield, change the required hand size instead
  .buttons.build.display_name = "Select 12 tiles to form a tenpai hand"
  |
  .buttons.build.actions |= map(if .[0] == "mark" then .[1] = [["hand", 12, ["self"]]] else . end)
  |
  .buttons.build.actions += [["uninterruptible_draw", 1, ["4x", "hidden"]], ["merge_draw"]]
else
  .starting_tiles = 12
  |
  .after_start.actions += [
    ["as", "east", [["move_tiles", "draw", "aside"]]],
    ["as", "everyone", [["uninterruptible_draw", 1, ["4x", "hidden"]], ["merge_draw"]]],
    ["as", "east", [["draw_from_aside"]]]
  ]
end
|
.after_start.actions += [
  ["set_tile_alias_all", ["4x"], ["any"]]
]
|
# TODO never let the 4x count as dora
.before_scoring.actions += [
  # ["when", [{"name": "tagged", "opts": [["4x", "dora"]] [["subtract_counter", "dora", 1]]]
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
|
# cosmic buttons
add_call_conditions("ton")
|
add_call_conditions("chon")
|
add_call_conditions("chon_honors")
|
add_call_conditions("daiminfuun")
|
add_call_conditions("anfuun")
|
add_call_conditions("kapon")
|
add_call_conditions("kakakan")
|
add_call_conditions("kafuun")

# TODO saki buttons?
