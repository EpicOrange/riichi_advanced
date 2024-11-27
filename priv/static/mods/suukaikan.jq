# add suukantsu flag on 4th kan
[["when", [{"name": "match", "opts": [["calls"], [[[["daiminkan", "ankan", "kakan"], 4]]]]}], [["set_status", "suukantsu"]]]] as $add_suukantsu
|
.buttons.daiminkan.actions += $add_suukantsu
|
.buttons.ankan.actions += $add_suukantsu
|
.buttons.kakan.actions += $add_suukantsu
|
# trigger on fourth kan if not suukantsu
.before_turn_change.actions += [
  ["when", [{"name": "match", "opts": [["all_calls"], [[[["daiminkan", "ankan", "kakan"], 4]]]]}, {"name": "not_anyone_status", "opts": ["suukantsu"]}], [["pause", 1000], ["abortive_draw", "Suukaikan"]]]
]
