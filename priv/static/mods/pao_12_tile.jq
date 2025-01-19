.after_call.actions += [
  ["when", [{"name": "match", "opts": [["calls"], [[[["chii", "pon", "daiminkan", "kakan", "ankan"], 4]]]]}], [["as", "callee", [["set_status", "pao"]]]]],
  ["unset_status_all", "pao_12_possible"]
]
|
.buttons.chii.actions |= [["set_status", "pao_12_possible"]] + .
|
.buttons.pon.actions |= [["set_status", "pao_12_possible"]] + .
|
.buttons.daiminkan.actions |= [["set_status", "pao_12_possible"]] + .
|
# need to figure out what `pao_eligible_yaku` actually does?
.score_calculation.pao_eligible_yaku += []
|
.score_calculation.win_with_pao_name = "Pao"
