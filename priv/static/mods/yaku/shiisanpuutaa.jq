.yakuman += [
  {
    "display_name": "Shiisanpuutaa",
    "value": 1,
    "when": [{"name": "status", "opts": ["discards_empty"]}, {"name": "match", "opts": [["hand", "draw"], ["shiisanpuutaa"]]}]
  }
]
|
.yaku_precedence += {
  "Shiisanpuutaa": ["Tenhou", "Chiihou"]
}
|
.shiisanpuutaa_definition = [[ [["pair"], 1], [["pair", "ryanmen/penchan", "kanchan"], -1] ]]
|
.win_definition += .shiisanpuutaa_definition
|
.tenpai_definition += .shiisanpuutaa_definition
