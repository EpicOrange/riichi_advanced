.after_initialization.actions += [
  ["add_rule", "Yakuman", "Junsei Ryuuiisou", "You have ryuuiisou without a green dragon.", 126],
  ["update_rule", "Yakuman", "Junsei Ryuuiisou", "%{example_hand}", {"example_hand": ["2s", "2s", "2s", "3s", "3s", "3s", "4s", "4s", "4s", "6s", "8s", "8s", "8s", "3x", "6s"]}]
]
|
.yakuman += [
  {
    "display_name": "Junsei Ryuuiisou",
    "value": 2,
    "when": [{"name": "winning_hand_consists_of", "opts": ["2s","3s","4s","6s","8s"]}]
  }
]
|
.yaku_precedence += {
  "Junsei Ryuuiisou": ["Ryuuiisou", "Chinitsu"]
}
