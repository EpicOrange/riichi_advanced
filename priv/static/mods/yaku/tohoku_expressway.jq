.after_initialization.actions += [["add_rule", "Yakuman", "Tohoku Expressway", "Your hand consists of only 246p (2,4,6 circles) and east/north winds.", 113]]
|
.yakuman += [
  {
    "display_name": "Tohoku Expressway",
    "value": 1,
    "when": [{"name": "winning_hand_consists_of", "opts": ["2p","4p","6p","1z","4z"]}]
  }
]
