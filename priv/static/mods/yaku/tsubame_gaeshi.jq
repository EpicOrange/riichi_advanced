.after_initialization.actions += [["add_rule", "Local Yaku (1 Han)", "(Tsubame Gaeshi) Win off a riichi discard.", 101]]
|
.yaku += [
  {
    "display_name": "Tsubame Gaeshi",
    "value": 1,
    "when": ["won_by_discard", {"name": "discarder_status", "opts": ["just_reached"]}]
  }
]
