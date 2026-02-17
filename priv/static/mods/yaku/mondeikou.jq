.after_initialization.actions += [
  ["add_rule", "2 Han", "Mondeikou", "You have four aka. This counts as a yaku.", 102],
  ["update_rule", "2 Han", "Mondeikou", "%{example_hand}", {"example_hand": ["3m", "4m", "0m", "0p", "3z", "3z", "3z", "3x", "7s", "7s", {"attrs": ["_sideways"], "tile": "7s"}, "3x", {"attrs": ["_sideways"], "tile": "0s"}, "4s", "6s", "3x", "0p"]}]
]
|
.yaku += [
  {
    "display_name": "Mondeikou",
    "value": 2,
    "when": [{"name": "counter_at_least", "opts": ["aka", 4]}]
  }
]
