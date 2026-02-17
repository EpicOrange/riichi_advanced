.after_initialization.actions += [
  ["add_rule", "Mangan", "Uupin Kaihou", "\"Gathering a Plum Blossom from the Roof\". Mangan if you win with rinshan on the 5p (5 circles).", 105],
  ["update_rule", "Mangan", "Uupin Kaihou", "%{example_hand}", {"example_hand": ["3p", "4p", "0p", "5p", "5p", "1s", "1s", "1s", "1z", "1z", "3x", "2z", "2z", "2z", {"attrs": ["_sideways"], "tile": "2z"}, "3x", "5p"]}]
]
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
