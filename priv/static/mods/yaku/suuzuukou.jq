.after_initialization.actions += [["add_rule", "2 Han", "Suuzuukou", "\"Four Honor Triplets\". Your hand has four honor triplets.", 102]]
|
.yaku += [
  {
    "display_name": "Suuzuukou",
    "value": 2,
    "when": [{"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ [["ton", "nan", "shaa", "pei", "haku", "hatsu", "chun"], 4], [["pair"], 1] ]]]}]
  }
]
