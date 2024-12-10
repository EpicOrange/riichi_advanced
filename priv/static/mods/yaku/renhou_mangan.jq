.yaku_renhou += [
  {
    "display_name": "Renhou",
    "value": 5,
    "when": [
      {"name": "not_has_points", "opts": [5]},
      {"name": "status", "opts": ["discards_empty"]},
      "won_by_discard"
    ]
  }
]
|
.yaku_precedence += {
  "Renhou": [1, 2, 3, 4]
}
|
if .score_calculation.yaku_lists | any(index("yaku_renhou")) then . else
  .score_calculation.yaku_lists += ["yaku_renhou"]
end
