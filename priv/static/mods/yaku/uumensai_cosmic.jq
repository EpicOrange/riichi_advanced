.yaku += [
  {
    "display_name": "Uumensai",
    "value": 2,
    "when": [[
      {"name": "match", "opts": [["hand", "calls", "winning_tile"], [[
        "exhaustive", [["pair"], 1], [["shuntsu"], 1], [["koutsu"], 1], [["kontsu"], 1], [["quad"], 1]
      ]]]},
      {"name": "match", "opts": [["hand", "calls", "winning_tile"], [[
        "exhaustive", [["pair"], 1], [["shuntsu"], 1], [["koutsu"], 1], [["kontsu"], 1], [["fuun"], 1]
      ]]]},
      {"name": "match", "opts": [["hand", "calls", "winning_tile"], [[
        "exhaustive", [["pair"], 1], [["shuntsu"], 1], [["koutsu"], 1], [["quad"], 1], [["fuun"], 1]
      ]]]},
      {"name": "match", "opts": [["hand", "calls", "winning_tile"], [[
        "exhaustive", [["pair"], 1], [["shuntsu"], 1], [["kontsu"], 1], [["quad"], 1], [["fuun"], 1]
      ]]]},
      {"name": "match", "opts": [["hand", "calls", "winning_tile"], [[
        "exhaustive", [["pair"], 1], [["koutsu"], 1], [["kontsu"], 1], [["quad"], 1], [["fuun"], 1]
      ]]]}
    ]]
  }
]
