.after_initialization.actions += [["add_rule", "Kyuushu Kyuuhai", "If a player starts with nine different kinds of terminals, they have the option to call an abortive draw. Any call (chii, pon, etc) invalidates this opportunity for all players."]]
|
# add kyuushu kyuuhai definition
.kyuushu_kyuuhai_definition = [
  [ "unique", [["1m","9m","1p","9p","1s","9s","1z","2z","3z","4z","5z","6z","7z"], 9] ]
]
|
# add kyuushu kyuuhai button
.buttons.kyuushu_kyuuhai = {
  "display_name": "Kyuushu Kyuuhai",
  "show_when": [
    "our_turn",
    "has_draw",
    {"name": "status", "opts": ["discards_empty"]},
    {"name": "status_missing", "opts": ["just_reached", "call_made"]},
    {"name": "match", "opts": [["hand", "draw"], ["kyuushu_kyuuhai"]]}
  ],
  "actions": [
    ["big_text", "Kyushuu Kyuuhai"],
    ["reveal_hand"],
    ["pause", 1000],
    ["abortive_draw", "Kyushuu Kyuuhai"]
  ]
}
