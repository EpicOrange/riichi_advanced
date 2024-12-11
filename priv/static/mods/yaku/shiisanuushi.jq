.yakuman += [
  {
    "display_name": "Shiisanuushi",
    "value": 1,
    "when": [{"name": "status", "opts": ["discards_empty"]}, {"name": "match", "opts": [["hand", "draw"], ["shiisanuushi"]]}]
  }
]
|
.yaku_precedence += {
  "Shiisanuushi": ["Tenhou", "Chiihou"]
}
|
.shiisanuushi_definition = [[ [["pair", "ryanmen/penchan", "kanchan"], -1] ]]
|
.win_definition += .shiisanuushi_definition
|
.tenpai_definition += .shiisanuushi_definition
