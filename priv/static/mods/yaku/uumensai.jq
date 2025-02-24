.after_initialization.actions += [["add_rule", "Local Yaku (2 Han)", "(Uumensai) \"Five Suits Collected\". Your hand includes all five suits (character, circle, bamboo, wind, dragon).", 102]]
|
.yaku += [
  {
    "display_name": "Uumensai",
    "value": 2,
    "when": [
      {"name": "match", "opts": [["hand", "calls", "winning_tile"], [[
        [["1m","2m","3m","4m","5m","6m","7m","8m","9m"], 1],
        [["1p","2p","3p","4p","5p","6p","7p","8p","9p"], 1],
        [["1s","2s","3s","4s","5s","6s","7s","8s","9s"], 1],
        [["1z","2z","3z","4z"], 1],
        [["5z","6z","7z"], 1]
      ]]]}
    ]
  }
]
|
.yaku_precedence.Chiitoitsu += ["Uumensai"]
