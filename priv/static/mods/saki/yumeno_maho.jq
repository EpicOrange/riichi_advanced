# draft ability
.buttons.yumeno_maho = {
  "display_name": "Draft Character Card",
  "show_when": ["our_turn", {"name": "status_missing", "opts": ["match_start", "yumeno-maho_exhausted"]}, {"name": "status", "opts": ["yumeno-maho"]}, "has_draw"],
  "actions": [["set_status", "yumeno-maho_exhausted"], ["draft_saki_card", 2]],
  "unskippable": true
}
|
# don't show beginning-of-game self-calls before drafting your second card
[[
  {"name": "not_status", "opts": ["yumeno-maho"]},
  {"name": "status", "opts": ["yumeno-maho_exhausted"]}
]] as $maho_restriction
|
.buttons.ankan.show_when += $maho_restriction
|
.buttons.riichi.show_when += $maho_restriction
|
.buttons.tsumo.show_when += $maho_restriction
|
# unset other characters' status at the start of the round
.after_start.actions += [
  ["when", [{"name": "status", "opts": ["yumeno-maho"]}], [["unset_status"] + .saki_deck]]
]
|
# add to saki deck after the above, so we don't unset our own status
.saki_deck += ["yumeno-maho"]
