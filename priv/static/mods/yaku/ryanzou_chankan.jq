.ryanzou_chankan += [
  {
    "display_name": "Ryanzou Chankan",
    "value": 5,
    "when": [
      {"name": "not_has_points", "opts": [5]},
      "won_by_call",
      {"name": "match", "opts": [["winning_tile"], [[[["2s"], 1]]]]}
    ]
  }
]
|
.yaku_precedence += {
  "Ryanzou Chankan": [1, 2, 3, 4]
}
|
if .score_calculation.yaku_lists | any(index("ryanzou_chankan")) then . else
  .score_calculation.yaku_lists += ["ryanzou_chankan"]
end
