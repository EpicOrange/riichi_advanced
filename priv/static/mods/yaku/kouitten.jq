.yakuman += [
  {
    "display_name": "Kouitten",
    "value": 1,
    "when": [
      {"name": "winning_hand_consists_of", "opts": ["2s","3s","4s","6s","8s","7z"]},
      {"name": "match", "opts": [["hand", "calls", "winning_tile"], [[[["7z"], 1]]]]}
    ]
  }
]
