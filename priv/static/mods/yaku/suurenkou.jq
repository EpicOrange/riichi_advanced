.after_initialization.actions += [
  ["add_rule", "Local Yaku (Yakuman)", "(Suurenkou) \"Four Consecutive Triplets\". You have four triplets of the same suit of increasing number, like 111 222 333 444.", 113],
  ["add_rule", "Sekinin Barai (Pao)", "(Suurenkou) If you win with suurenkou (111 222 333 444 of the same suit) and called the fourth triplet or kan from a player, that player is responsible for the yakuman payment if you tsumo, or half of the payment if you ron off someone else."]
]
|
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
  ["when", [{"name": "match", "opts": [["hand", "calls"], ["suurenkou"]]}], [["as", "callee", [["set_status", "pao"]]]]]
]
|
.score_calculation.pao_eligible_yaku += ["Suurenkou"]
|
.score_calculation.win_with_pao_name = "Sekinin Barai"
