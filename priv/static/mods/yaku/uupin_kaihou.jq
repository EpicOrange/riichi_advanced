.after_initialization.actions += [["add_rule", "Local Yaku (Mangan)", "(Uupin Kaihou) \"Gathering a Plum Blossom from the Roof\". Mangan if you win with rinshan on the 5p (5 circles).", 105]]
|
.yaku_uupin_kaihou += [
  {
    "display_name": "Uupin Kaihou",
    "value": 5,
    "when": [
      {"name": "not_has_points", "opts": [5]},
      {"name": "status", "opts": ["kan"]},
      {"name": "match", "opts": [["winning_tile"], [[[["5p"], 1]]]]}
    ]
  }
]
|
.yaku_precedence += {
  "Uupin Kaihou": [1, 2, 3, 4]
}
|
if .score_calculation.yaku_lists | any(index("yaku_uupin_kaihou")) then . else
  .score_calculation.yaku_lists += ["yaku_uupin_kaihou"]
end
