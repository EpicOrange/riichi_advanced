.after_initialization.actions += [["add_rule", "Mangan", "Touchao Hanchanshue", "\"Fishing Alone in the Cold River Snow\". Mangan if you are waiting on 5z (white dragon) with four calls (open or closed).", 105]]
|
(if .buttons | has("ton") then ["ton", "chii", "chon", "chon_honors", "daiminfuun", "pon", "daiminkan", "kapon", "kakakan", "kafuun", "kakan", "anfuun", "ankan"] else ["chii", "pon", "daiminkan", "kakan", "ankan"] end) as $all_calls
|
.yaku_touchao_hanchanshue += [
  {
    "display_name": "Touchao Hanchanshue",
    "value": 5,
    "when": [
      {"name": "not_has_points", "opts": [5]},
      {"name": "match", "opts": [["calls"], [[[$all_calls, 4]]]]},
      {"name": "match", "opts": [["hand"], [[[["5z"], 1]]]]}
    ]
  }
]
|
.yaku_precedence += {
  "Touchao Hanchanshue": [1, 2, 3, 4]
}
|
if .score_calculation.yaku_lists | any(index("yaku_touchao_hanchanshue")) then . else
  .score_calculation.yaku_lists += ["yaku_touchao_hanchanshue"]
end
