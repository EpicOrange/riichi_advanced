.after_initialization.actions += [
  ["add_rule", "Mangan", "Ryanzou Chankan", "\"Scratching a Carrying Pole\". Mangan if you win with chankan on the 2s (2 bamboo).", 105],
  ["update_rule", "Mangan", "Ryanzou Chankan", "%{example_hand}", {"example_hand": ["4m", "5m", "6m", "3p", "4p", "0p", "1s", "3s", "6s", "7s", "8s", "9s", "9s", "3x", "2s"]}]
]
|
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
