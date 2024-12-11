.yaku += [
  {
    "display_name": "Sanankon",
    "value": 2,
    "when": [[
      # 0-1 open kontsu, hand must be 4 kontsu and a pair
      {"name": "match", "opts": [["hand", "calls"], [[ [["chon", "chon_honors", "daiminfuun", "kafuun"], -2], [["kontsu", "kontsu_123", "kontsu_124", "kontsu_134", "kontsu_234", "kontsu_dragons"], 4], [["pair"], 1] ]]]},
      # 0 open kontsu, hand must be 3 kontsu and a pair
      {"name": "match", "opts": [["hand", "calls"], [[ [["chon", "chon_honors", "daiminfuun", "kafuun"], -1], [["kontsu", "kontsu_123", "kontsu_124", "kontsu_134", "kontsu_234", "kontsu_dragons"], 3], [["shuntsu", "koutsu"], 1], [["pair"], 1] ]]]},
      [
        "won_by_draw",
        {"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ [["chon", "chon_honors", "daiminfuun", "kafuun"], -1], [["kontsu", "kontsu_123", "kontsu_124", "kontsu_134", "kontsu_234", "kontsu_dragons"], 3], [["shuntsu", "koutsu", "kontsu"], 1], [["pair"], 1] ]]]}
      ]
    ]]
  },
  {
    "display_name": "Suuankon",
    "value": 6,
    "when": [
      "won_by_draw",
      {"name": "has_no_call_named", "opts": ["chon", "chon_honors", "daiminfuun", "kafuun"]},
      {"name": "match", "opts": [["hand", "calls"], [[[["kontsu"], 3], [["pair"], 2]]]]}
    ]
  },
  {
    "display_name": "Suuankon Tanki",
    "value": 13,
    "when": [
      {"name": "has_no_call_named", "opts": ["chon", "chon_honors", "daiminfuun", "kafuun"]},
      {"name": "match", "opts": [["hand", "calls"], [[[["kontsu"], 4]]]]}
    ]
  }
]