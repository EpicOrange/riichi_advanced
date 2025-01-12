.after_call.actions += [
  ["when", 
    [
      {"name": "status", "opts": ["rinshan_pao_possible"]},
      {"name": "match", "opts": [["last_call"], [[[["quad"], 1]]]]}
    ],
    [["as", "callee", [["set_status", "pao_possible"]]]]],
  ["unset_status_all", "rinshan_pao_possible"]
]
|
# If anyone has pao_possible and anyone has just kan'd into a win, the player with pao_possible gets pao'd.
.before_win.actions += [
  ["when_anyone", [{"name": "status", "opts": ["pao_possible"]}, {"name": "anyone_status", "opts": ["kan"]}], ["set_status", "pao"]]
]
|
# Otherwise, remove pao_possible and kan stati from everyone.
.before_turn_change.actions += [
  ["unset_status_all", "kan", "pao_possible"]
]
|
# Prepend this "rinshan_pao_possible" at the start of the daiminkan action, so that when the call happens, this is already set.
.buttons.daiminkan.actions |= [["set_status", "rinshan_pao_possible"]] + .
|
.score_calculation.pao_eligible_yaku += ["Rinshan"]
|
.score_calculation.win_with_pao_name = "Sekinin Barai"
