.after_initialization.actions += [["add_rule", "Local Yaku (2 Han)", "(Mondeikou) You have four aka. This counts as a yaku.", 102]]
|
.yaku += [
  {
    "display_name": "Mondeikou",
    "value": 2,
    "when": [{"name": "counter_at_least", "opts": ["aka", 4]}]
  }
]
