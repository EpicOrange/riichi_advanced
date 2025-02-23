.after_initialization.actions += [
  ["add_rule", "Local Yaku (Yakuman)", "(Shiisanpuutaa) \"Thirteen Unconnected\". Start with 13 disconnected tiles, plus one forming a pair. Calls invalidate.", 113],
  ["add_rule", "Win Condition", "- (Shiisanpuutaa) Start with 13 disconnected tiles, plus one forming a pair.", -100]
]
|
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
.buttons.shiisanpuutaa = {
  "display_name": "Tsumo",
  "show_when": [
    "our_turn",
    "has_draw",
    {"name": "status", "opts": ["discards_empty"]},
    {"name": "match", "opts": [["hand", "draw"], ["shiisanpuutaa"]]}
  ],
  "actions": [["set_counter", "fu", 30], ["big_text", "Tsumo"], ["pause", 1000], ["reveal_hand"], ["win_by_draw"]]
}
