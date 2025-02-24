.after_initialization.actions += [["add_rule", "Local Yaku (Yakuman)", "(Ryuuiisourin) \"All Black\". Like ryuuiisou, except you have a pair of 5s (5 bamboo).", 113]]
|
.yakuman += [
  {
    "display_name": "Ryuuiisourin",
    "value": 1,
    "when": [
      {"name": "winning_hand_consists_of", "opts": ["2s","3s","4s","5s","6s","8s","6z"]},
      {"name": "match", "opts": [["hand", "calls", "winning_tile"], [[[["5s"], 2], [["5s"], -1]]]]}
    ]
  }
]
