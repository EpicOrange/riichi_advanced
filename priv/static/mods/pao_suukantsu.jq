# Wait, what happens if both standard pao and suukantsu pao are in play, and Player A discards a hatsu into daisangen pao, but then player B discards a different tile into suukantsu pao? Which pao takes precedence?
# Guess we find out the hard way.
.after_call.actions += [
  ["when", 
    [
      {"name": "status", "opts": ["daiminkan_pao_possible"]},
      {"name": "match", "opts": [["last_call"], [[[["daiminkan"], 1]]]]},
      {"name": "match", "opts": [["calls"], [[[["daiminkan", "ankan", "kakan"], 4]]]]}
    ],
    [["as", "callee", [["set_status", "pao"]]]]],
  ["unset_status_all", "daiminkan_pao_possible"]
]
|
# Prepend this "daiminkan_pao_possible" at the start of the daiminkan action, so that when the call happens, this is already set.
.buttons.daiminkan.actions |= [["set_status", "daiminkan_pao_possible"]] + .
|
.score_calculation.pao_eligible_yaku += ["Suukantsu"]
|
.score_calculation.win_with_pao_name = "Sekinin Barai"
