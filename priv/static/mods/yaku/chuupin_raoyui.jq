.after_initialization.actions += [["add_rule", "Local Yaku (Mangan)", "(Chuupin Raoyui) \"Catching Fish from the Bottom of the River\". Mangan if you win with houtei (not haitei) on the 9p (9 circles).", 105]]
|
.chuupin_raoyui += [
  {
    "display_name": "Chuupin Raoyui",
    "value": 5,
    "when": [
      {"name": "not_has_points", "opts": [5]},
      "no_tiles_remaining",
      "not_won_by_draw",
      {"name": "match", "opts": [["winning_tile"], [[[["9p"], 1]]]]}
    ]
  }
]
|
.yaku_precedence += {
  "Chuupin Raoyui": [1, 2, 3, 4]
}
|
if .score_calculation.yaku_lists | any(index("chuupin_raoyui")) then . else
  .score_calculation.yaku_lists += ["chuupin_raoyui"]
end
