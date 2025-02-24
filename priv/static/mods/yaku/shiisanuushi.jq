.after_initialization.actions += [
  ["add_rule", "Local Yaku (Yakuman)", "(Shiisanuushi) \"Thirteen Independent\". Start with 14 disconnected tiles. Calls invalidate.", 113],
  ["add_rule", "Win Condition", "- (Shiisanuushi) Start with 14 disconnected tiles.", -100]
]
|
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
.buttons.shiisanuushi = {
  "display_name": "Tsumo",
  "show_when": [
    "our_turn",
    "has_draw",
    {"name": "status", "opts": ["discards_empty"]},
    {"name": "match", "opts": [["hand", "draw"], ["shiisanuushi"]]}
  ],
  "actions": [["set_counter", "fu", 30], ["big_text", "Tsumo"], ["pause", 1000], ["reveal_hand"], ["win_by_draw"]]
}
