.after_initialization.actions += [
  ["add_rule", "Yakuman", "Benikujaku", "\"Red Peacock\". Like ryuuiisou but red bamboo only: you can only have 1579s and red dragon.", 113],
  ["update_rule", "Yakuman", "Benikujaku", "%{example_hand}", {"example_hand": ["1s", "1s", "1s", "5s", "5s", "5s", "7s", "7s", "7s", "9s", "9s", "9s", "7z", "3x", "7z"]}]
]
|
.yakuman += [
  {
    "display_name": "Benikujaku",
    "value": 1,
    "when": [{"name": "winning_hand_consists_of", "opts": ["1s","5s","7s","9s","7z"]}]
  }
]
