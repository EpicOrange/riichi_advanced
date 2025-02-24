.after_initialization.actions += [
  ["add_rule", "Local Yaku (Yakuman)", "(Isshoku Yonjun) \"Pure Quadruple Sequences\". You have four of the exact same sequence in one suit, like 123m 123m 123m 123m. Like iipeikou but four.", 113],
  ["add_rule", "Sekinin Barai (Pao)", "(Isshoku Yonjun) If you win with isshoku yonjun (123123123123 of the same suit) and called the fourth sequence from a player, that player is responsible for the yakuman payment if you tsumo, or half of the payment if you ron off someone else."]
]
|
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
|
.yaku_precedence += {
  "Isshoku Yonjun": ["Isshoku Sanjun", "Ryanpeikou"]
}
