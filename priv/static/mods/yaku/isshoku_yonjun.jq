.yakuman += [
  {
    "display_name": "Isshoku Yonjun",
    "value": 1,
    "when": [{"name": "match", "opts": [["hand", "calls", "winning_tile"], ["isshoku_yonjun"]]}]
  }
]
|
.isshoku_yonjun_definition = [[ [[[[0,1,2],[0,1,2],[0,1,2],[0,1,2]]], 1], [["pair"], 1] ]]
|
.after_call.actions += [
  ["when", [{"name": "match", "opts": [["hand", "calls"], ["isshoku_yonjun"]]}], [["as", "callee", [["set_status", "pao"]]]]]
]
|
.score_calculation.pao_eligible_yaku += ["Isshoku Yonjun"]
|
.score_calculation.win_with_pao_name = "Sekinin Barai"
