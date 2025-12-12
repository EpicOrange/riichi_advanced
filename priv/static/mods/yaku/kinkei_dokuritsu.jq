.after_initialization.actions += [["add_rule", "Mangan", "Kinkei Dokuritsu", "\"Golden Rooster Standing Alone\". Mangan if you are waiting on 1s (1 bamboo, the bird tile) with four calls. Can be open or closed.", 105]]
|
(if .buttons | has("ton") then ["ton", "chii", "chon", "chon_honors", "daiminfuun", "pon", "daiminkan", "kapon", "kakakan", "kafuun", "kakan", "anfuun", "ankan"] else ["chii", "pon", "daiminkan", "kakan", "ankan"] end) as $all_calls
|
.yaku_kinkei_dokuritsu += [
  {
    "display_name": "Kinkei Dokuritsu",
    "value": 5,
    "when": [
      {"name": "not_has_points", "opts": [5]},
      {"name": "match", "opts": [["calls"], [[[$all_calls, 4]]]]},
      {"name": "match", "opts": [["hand"], [[[["1s"], 1]]]]}
    ]
  }
]
|
.yaku_precedence += {
  "Kinkei Dokuritsu": [1, 2, 3, 4]
}
|
if .score_calculation.yaku_lists | any(index("yaku_kinkei_dokuritsu")) then . else
  .score_calculation.yaku_lists += ["yaku_kinkei_dokuritsu"]
end
