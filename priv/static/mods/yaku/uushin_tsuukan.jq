(if .set_definitions | has("kontsu") then ["shuntsu", "kontsu", "koutsu"] else ["shuntsu", "koutsu"] end) as $others
|
.yaku += [
  {
    "display_name": "Uushin Tsuukan",
    "value": 1,
    "when": [
      {"name": "match", "opts": [["hand", "calls"], [[ "exhaustive", [["pair"], 1], [$others, 3], "ignore_suit", [[["4m", "6m"]], 1] ]]]},
      {"name": "match", "opts": [["winning_tile"], [[ "ignore_suit", [["5m"], 1]]]]}
    ]
  }
]
