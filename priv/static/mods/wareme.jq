.after_start.actions += [
  ["when", [{"name": "dice_equals", "opts": [5, 9]}], [["set_status", "wareme"]]],
  ["when", [{"name": "dice_equals", "opts": [2, 6, 10]}], [["set_shimocha_status", "wareme"]]],
  ["when", [{"name": "dice_equals", "opts": [3, 7, 11]}], [["set_toimen_status", "wareme"]]],
  ["when", [{"name": "dice_equals", "opts": [4, 8, 12]}], [["set_kamicha_status", "wareme"]]]
]
|
.shown_statuses_public += ["wareme"]
