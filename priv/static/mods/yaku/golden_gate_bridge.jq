.after_initialization.actions += [["add_rule", "Local Yaku (Yakuman)", "(Golden Gate Bridge) Your hand contains 123 345 567 789 all in one suit. No restrictions on your pair.", 113]]
|
.yakuman += [
  {
    "display_name": "Golden Gate Bridge",
    "value": 1,
    "when": [{"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ "exhaustive", [[[[0,1,2],[2,3,4],[4,5,6],[6,7,8]]], 1], [["pair"], 1] ]]]}]
  }
]
