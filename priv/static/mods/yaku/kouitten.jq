.after_initialization.actions += [
  ["add_rule", "Yakuman", "Kouitten", "\"A Little Red\". Like ryuuiisou, except instead of green dragon, it's red dragon (you must include red dragons).", 113],
  ["update_rule", "Yakuman", "Kouitten", "%{example_hand}", {"example_hand": ["2s", "2s", "3s", "4s", "4s", "6s", "6s", "8s", "8s", "8s", "7z", "7z", "7z", "3x", "3s"]}]
]
|
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
