.after_initialization.actions += [["add_rule", "Mangan", "Iipin Mouyue", "\"Plucking the Moon from the Bottom of the Sea\". Mangan if you win with haitei (not houtei) on the 1p (1 circles).", 105]]
|
.iipin_mouyue += [
  {
    "display_name": "Iipin Mouyue",
    "value": 5,
    "when": [
      {"name": "not_has_points", "opts": [5]},
      "no_tiles_remaining",
      "won_by_draw",
      {"name": "match", "opts": [["winning_tile"], [[[["1p"], 1]]]]}
    ]
  }
]
|
.yaku_precedence += {
  "Iipin Mouyue": [1, 2, 3, 4]
}
|
if .score_calculation.yaku_lists | any(index("iipin_mouyue")) then . else
  .score_calculation.yaku_lists += ["iipin_mouyue"]
end
