# add suukantsu flag on 4th kan
[["when", [{"name": "match", "opts": [["calls"], [[[["daiminkan", "ankan", "kakan"], 4]]]]}], [["set_status", "suukantsu"]]]] as $add_suukantsu
|
.buttons.daiminkan.actions |= map(if .[0] == "when" and any(.[2][]; . == ["draw", 1, "kandraw_4"]) then .[2] += $add_suukantsu else . end)
|
# trigger on fourth kan if not suukantsu
.before_turn_change.actions += [
  ["when", [{"name": "tile_drawn", "opts": ["kandraw_4"]}, {"name": "not_anyone_status", "opts": ["suukantsu"]}], [["pause", 1000], ["abortive_draw", "Suukaikan"]]]
]
