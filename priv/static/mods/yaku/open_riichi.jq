.after_initialization.actions += [["update_rule", "Riichi", "(Open Riichi) You may also declare open riichi, which reveals your hand but is worth 1 more han if you win."]]
|
# add open riichi button
.buttons.open_riichi = {
  "display_name": "Open Riichi",
  "show_when": [
    "our_turn",
    "has_draw",
    {"name": "status_missing", "opts": ["riichi"]},
    {"name": "has_score", "opts": ["riichi_value"]},
    "next_draw_possible",
    {"name": "has_no_call_named", "opts": ["chii", "pon", "daiminkan", "kakan"]},
    {"name": "match", "opts": [["hand", "calls", "draw"], ["tenpai_14", "kokushi_tenpai"]]}
  ],
  "actions": [
    ["big_text", "Open Riichi"],
    ["reveal_hand"],
    ["set_status", "riichi", "open_riichi", "just_reached"],
    ["push_message", "declared open riichi"],
    ["when", [{"name": "status", "opts": ["discards_empty"]}, "no_calls_yet"], [["set_status", "double_riichi"]]]
  ]
}
|
# add open riichi yaku after riichi
(.yaku | map(.display_name == "Riichi") | index(true)) as $ix
|
.yaku |= .[:$ix+1] + [
  { "display_name": "Open Riichi", "value": 2, "when": [{"name": "status", "opts": ["open_riichi"]}] },
  { "display_name": "Open Double Riichi", "value": 3, "when": [{"name": "status", "opts": ["open_riichi", "double_riichi"]}] }
] + .[$ix+1:]
|
# have open riichi supercede regular riichi yaku
.yaku_precedence += {
  "Open Riichi": ["Riichi"],
  "Open Double Riichi": ["Open Riichi", "Double Riichi"]
}
