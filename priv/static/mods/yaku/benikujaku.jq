.after_initialization.actions += [["add_rule", "Yakuman", "Benikujaku", "\"Red Peacock\". Like ryuuiisou but red bamboo only: you can only have 1579s and red dragon.", 113]]
|
.yakuman += [
  {
    "display_name": "Benikujaku",
    "value": 1,
    "when": [{"name": "winning_hand_consists_of", "opts": ["1s","5s","7s","9s","7z"]}]
  }
]
