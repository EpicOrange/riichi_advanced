.after_start.actions += [
  ["when", ["not_all_saki_cards_drafted"], [["unset_status_all", "drafting"], ["set_status_all", "drafting_2"]]]
]
|
.buttons += {
  "draft_2": {
    "display_name": "Draft Character Card",
    "show_when": [{"name": "status", "opts": ["drafting_2"]}],
    "actions": [["unset_status", "drafting_2"], ["set_status", "drafting"], ["draft_saki_card", 4]],
    "unskippable": true
  }
}
