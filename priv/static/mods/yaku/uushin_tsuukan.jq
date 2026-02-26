.after_initialization.actions += [
  ["add_rule", "1 Han", "Uushin Tsuukan", "\"Five-Heart Straight\". 1 han on top of ittsuu if the winning tile is the five needed for ittsuu.", 101],
  ["update_rule", "1 Han", "Uushin Tsuukan", "%{example_hand}", {"example_hand": ["1m", "2m", "3m", "4m", "6m", "7m", "8m", "9m", "2p", "2p", "3z", "3z", "3z", "3x", "5m"]}]
]
|
(if .set_definitions | has("kontsu") then ["shuntsu", "kontsu", "koutsu"] else ["shuntsu", "koutsu"] end) as $others
|
.yaku += [
  {
    "display_name": "Uushin Tsuukan",
    "value": 1,
    "when": [
      # TODO how do you know the 46 is part of that ittsuu, what if it's another 46?
      {"name": "match", "opts": [["hand", "calls"], [[ "exhaustive", [["ittsuu"], 1], [$others, 1], [["pair"], 1] ]]]},
      {"name": "match", "opts": [["hand", "calls"], [[ "exhaustive", [["pair"], 1], [$others, 3], "ignore_suit", [[["4m", "6m"]], 1] ]]]},
      {"name": "match", "opts": [["winning_tile"], [[ "ignore_suit", [["5m"], 1]]]]}
    ]
  }
]
