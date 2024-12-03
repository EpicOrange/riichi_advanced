.extra_yaku += [
  {
    "display_name": "Toriuchi",
    "value": "toriuchi",
    "when": [
      {"name": "counter_at_least", "opts": ["toriuchi", 1]},
      [
        {"name": "not_match", "opts": [["hand", "calls", "winning_tile"], [[[["7p"], 1]]]]},
        {"name": "match", "opts": [["hand", "calls", "winning_tile"], [[[["8s"], 1]]]]}
      ]
    ]
  }
]
|
.before_win.actions += [
  ["add_counter", "toriuchi", "count_matches", ["hand", "calls", "winning_tile"], [[[["1s"], 1]]]]
]
