.after_initialization.actions += [["add_rule", "Mangan", "Dorahairi Chinroutou Chiitoitsu", "Mangan if you have chiitoitsu composed of each terminal tile with the seventh pair being dora.", 105]]
|
.yaku_dorahairi_chinroutou_chiitoitsu += [
  {
    "display_name": "Dorahairi Chinroutou Chiitoitsu",
    "value": 5,
    "when": [
      {"name": "not_has_points", "opts": [5]},
      {"name": "winning_hand_consists_of", "opts": ["1m","9m","1p","9p","1s","9s",{"tile": "any", "attrs": ["dorahairi_dora"]}]}
    ]
  }
]
|
.yaku_precedence += {
  "Dorahairi Chinroutou Chiitoitsu": [1, 2, 3, 4]
}
|
if .score_calculation.yaku_lists | any(index("yaku_dorahairi_chinroutou_chiitoitsu")) then . else
  .score_calculation.yaku_lists += ["yaku_dorahairi_chinroutou_chiitoitsu"]
end
|
# don't tag it "dora" since that enables shiny tiles
.before_win.actions += [
  ["add_attr_tagged", "dora", "dorahairi_dora"]
]
