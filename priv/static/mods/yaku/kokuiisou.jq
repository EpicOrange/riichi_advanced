.after_initialization.actions += [["add_rule", "Yakuman", "Kokuiisou", "\"All Black\". Like ryuuiisou but black: you can only have 248p and winds.", 113]]
|
.yakuman += [
  {
    "display_name": "Kokuiisou",
    "value": 1,
    "when": [{"name": "winning_hand_consists_of", "opts": ["2p","4p","8p","1z","2z","3z","4z"]}]
  }
]
