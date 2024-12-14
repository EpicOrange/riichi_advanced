# add suukantsu flag on 4th kan
[["when", [{"name": "match", "opts": [["calls"], [[[["daiminkan", "ankan", "kakan"], 4]]]]}], [["set_status", "suukantsu"]]]] as $add_suukantsu
|
if .buttons | has("daiminkan") then
  .buttons.daiminkan.actions += $add_suukantsu
else . end
|
if .buttons | has("ankan") then
  .buttons.ankan.actions += $add_suukantsu
else . end
|
if .buttons | has("kakan") then
  .buttons.kakan.actions += $add_suukantsu
else . end
|
# trigger on fourth kan if not suukantsu
.before_turn_change.actions += [
  ["when", [{"name": "match", "opts": [["all_calls"], [[[["daiminkan", "ankan", "kakan"], 4]]]]}, {"name": "not_anyone_status", "opts": ["suukantsu"]}], [["pause", 1000], ["abortive_draw", "Suukaikan"]]]
]
