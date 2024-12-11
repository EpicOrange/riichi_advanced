.yakuman += [
  {
    "display_name": "Suuchoupaikou",
    "value": 1,
    "when": [{"name": "match", "opts": [["hand", "calls", "winning_tile"], ["suuchoupaikou"]]}]
  }
]
|
.suuchoupaikou_definition = [[ [[[[0,0,0],[2,2,2],[4,4,4],[6,6,6]]], 1], [["pair"], 1] ]]
|
.after_call.actions += [
  ["when", [{"name": "match", "opts": ["hand", "calls"], ["suuchoupaikou"]}], [["as", "callee", [["set_status", "pao"]]]]],
]
|
.score_calculation.pao_eligible_yaku += ["Suuchoupaikou"]
|
.score_calculation.win_with_pao_name = "Sekinin Barai"
