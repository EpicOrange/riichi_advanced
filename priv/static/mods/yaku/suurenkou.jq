.yakuman += [
  {
    "display_name": "Suurenkou",
    "value": 1,
    "when": [{"name": "match", "opts": [["hand", "calls", "winning_tile"], ["suurenkou"]]}]
  }
]
|
.suurenkou_definition = [[ [[[[0,0,0],[1,1,1],[2,2,2],[3,3,3]]], 1], [["pair"], 1] ]]
|
.after_call.actions += [
  ["when", [{"name": "match", "opts": ["hand", "calls"], ["suurenkou"]}], [["as", "callee", [["set_status", "pao"]]]]],
]
|
.score_calculation.pao_eligible_yaku += ["Suurenkou"]
|
.score_calculation.win_with_pao_name = "Sekinin Barai"
