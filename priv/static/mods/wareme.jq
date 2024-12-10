.after_start.actions += [
  ["when", [{"name": "dice_equals", "opts": [5, 9]}], [["set_status", "wareme"]]],
  ["when", [{"name": "dice_equals", "opts": [2, 6, 10]}], [["as", "shimocha", [["set_status", "wareme"]]]]],
  ["when", [{"name": "dice_equals", "opts": [3, 7, 11]}], [["as", "toimen", [["set_status", "wareme"]]]]],
  ["when", [{"name": "dice_equals", "opts": [4, 8, 12]}], [["as", "kamicha", [["set_status", "wareme"]]]]]
]
|
.shown_statuses_public += ["wareme"]
