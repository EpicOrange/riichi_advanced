.after_initialization.actions += [
  ["add_rule", "Yakuman", "Golden Gate Bridge", "Your hand contains 123 345 567 789 all in one suit. No restrictions on your pair.", 113],
  ["update_rule", "Yakuman", "Golden Gate Bridge", "%{example_hand}", {"example_hand": ["1m", "2m", "3m", "3m", "4m", "5m", "5m", "6m", "7m", "7m", "8m", "9m", "2s", "3x", "2s"]}]
  
]
|
.yakuman += [
  {
    "display_name": "Golden Gate Bridge",
    "value": 1,
    "when": [{"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ "exhaustive", [[[[0,1,2],[2,3,4],[4,5,6],[6,7,8]]], 1], [["pair"], 1] ]]]}]
  }
]
