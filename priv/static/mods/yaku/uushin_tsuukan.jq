.after_initialization.actions += [["add_rule", "1 Han", "Uushin Tsuukan", "\"Five-Heart Straight\". 1 han on top of ittsu if the winning tile is the five needed for ittsu.", 101]]
|
(if .set_definitions | has("kontsu") then ["shuntsu", "kontsu", "koutsu"] else ["shuntsu", "koutsu"] end) as $others
|
.yaku += [
  {
    "display_name": "Uushin Tsuukan",
    "value": 1,
    "when": [
      # TODO how do you know the 46 is part of that ittsu, what if it's another 46?
      {"name": "match", "opts": [["hand", "calls"], [[ "exhaustive", [["ittsu"], 1], [$others, 1], [["pair"], 1] ]]]},
      {"name": "match", "opts": [["hand", "calls"], [[ "exhaustive", [["pair"], 1], [$others, 3], "ignore_suit", [[["4m", "6m"]], 1] ]]]},
      {"name": "match", "opts": [["winning_tile"], [[ "ignore_suit", [["5m"], 1]]]]}
    ]
  }
]
