.after_initialization.actions += [
  ["add_rule", "2 Han", "Suuzuukou", "\"Four Honor Triplets\". Your hand has four honor triplets.", 102],
  ["update_rule", "2 Han", "Suuzuukou", "%{example_hand}", {"example_hand": ["8m", "2z", "2z", "2z", "4z", "4z", "4z", "6z", "6z", "6z", "7z", "7z", "7z", "3x", "8m"]}]
]
|
.yaku += [
  {
    "display_name": "Suuzuukou",
    "value": 2,
    "when": [{"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ [["ton", "nan", "shaa", "pei", "haku", "hatsu", "chun"], 4], [["pair"], 1] ]]]}]
  }
]
