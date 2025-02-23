.after_initialization.actions += [["add_rule", "Wareme", "The player whose wall is broken is wareme: if they win, they win 2x points, but if they pay, they pay 2x points."]]
|
if .num_players == 2 then
  .after_start.actions += [
    ["when", [{"name": "dice_equals", "opts": [3, 5, 7, 9, 11]}], [["as", "east", [["set_status", "wareme"]]]]],
    ["when", [{"name": "dice_equals", "opts": [2, 4, 6, 8, 10, 12]}], [["as", "west", [["set_status", "wareme"]]]]]
  ]
else . end
|
if .num_players == 3 then
  .after_start.actions += [
    ["when", [{"name": "dice_equals", "opts": [4, 7, 10]}], [["as", "east", [["set_status", "wareme"]]]]],
    ["when", [{"name": "dice_equals", "opts": [2, 5, 8, 11]}], [["as", "south", [["set_status", "wareme"]]]]],
    ["when", [{"name": "dice_equals", "opts": [3, 6, 9, 12]}], [["as", "west", [["set_status", "wareme"]]]]]
  ]
else . end
|
if .num_players == 4 then
  .after_start.actions += [
    ["when", [{"name": "dice_equals", "opts": [5, 9]}], [["as", "east", [["set_status", "wareme"]]]]],
    ["when", [{"name": "dice_equals", "opts": [2, 6, 10]}], [["as", "south", [["set_status", "wareme"]]]]],
    ["when", [{"name": "dice_equals", "opts": [3, 7, 11]}], [["as", "west", [["set_status", "wareme"]]]]],
    ["when", [{"name": "dice_equals", "opts": [4, 8, 12]}], [["as", "north", [["set_status", "wareme"]]]]]
  ]
else . end
|
.shown_statuses_public += ["wareme"]
