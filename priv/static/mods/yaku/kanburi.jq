.after_initialization.actions += [["add_rule", "Local Yaku (1 Han)", "(Kanburi) Win off the tile discarded by someone who just called kan.", 101]]
|
.yaku += [
  {
    "display_name": "Kanburi",
    "value": 1,
    "when": ["won_by_discard", {"name": "discarder_status", "opts": ["kan"]}]
  }
]
