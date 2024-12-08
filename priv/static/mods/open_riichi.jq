# add open riichi button
.buttons.open_riichi = {
  "display_name": "Open Riichi",
  "show_when": [
    "our_turn",
    "has_draw",
    {"name": "status_missing", "opts": ["riichi"]},
    {"name": "has_score", "opts": [1000]},
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
# if suucha riichi exists, add it
if (.buttons.riichi.actions | any(.[]; .[0] == "when" and any(.[2][]; . == ["abortive_draw", "Suucha Riichi"]))) then
  .buttons.open_riichi.actions += [
    ["when", [{"name": "everyone_status", "opts": ["riichi"]}], [
      ["add_score", -1000],
      ["put_down_riichi_stick"],
      ["pause", 1000],
      ["abortive_draw", "Suucha Riichi"]
    ]]
  ]
else . end
|
# add open riichi yaku after riichi
(.yaku | map(.display_name == "Riichi") | index(true)) as $ix
|
.yaku |= .[:$ix+1] + [
  {
    "display_name": "Open Riichi",
    "value": 2,
    "when": [{"name": "status", "opts": ["open_riichi"]}]
  },
  {
    "display_name": "Open Double Riichi",
    "value": 3,
    "when": [{"name": "status", "opts": ["open_riichi", "double_riichi"]}]
  }
] + .[$ix+1:]
|
# have open riichi supercede regular riichi yaku
.yaku_precedence += {
  "Open Riichi": ["Riichi"],
  "Open Double Riichi": ["Open Riichi"]
}
