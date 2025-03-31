.after_initialization.actions += [
  ["add_rule", "Yakuman", "Suuchoupaikou", "\"Four Consecutive Triplets\". You have four triplets of the same suit whose numbers step by 2, like 111 333 555 777.", 113],
  ["add_rule", "1 Han", "Sekinin Barai (Pao)", "(Suuchoupaikou) If you win with suuchoupaikou (111 333 555 777 of the same suit) and called the fourth triplet or kan from a player, that player is responsible for the yakuman payment if you tsumo, or half of the payment if you ron off someone else."]
]
|
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
  ["when", [{"name": "match", "opts": [["hand", "calls"], ["suuchoupaikou"]]}], [["as", "callee", [["make_responsible_for", "prev_seat", "all"]]]]]
]
|
.score_calculation.pao_eligible_yaku += ["Suuchoupaikou"]
|
.score_calculation.win_with_pao_name = "Sekinin Barai"
