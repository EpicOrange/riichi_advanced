.starting_tiles = 12
|
.tenpai_definition = [
  [ "exhaustive", [["pair"], 1], [["ryanmen/penchan", "kanchan", "pair"], 2], [["shuntsu", "koutsu"], 2] ],
  [ "exhaustive", [["ryanmen/penchan", "kanchan", "pair"], 1], [["shuntsu", "koutsu"], 3] ],
  [ [["quad"], -1], [["koutsu"], -2], [["pair"], 5] ]
]
|
.tenpai_14_definition = [
  [ "exhaustive", [["pair"], 1], [["ryanmen/penchan", "kanchan", "pair"], 2], [["shuntsu", "koutsu"], 2] ],
  [ "exhaustive", [["ryanmen/penchan", "kanchan", "pair"], 1], [["shuntsu", "koutsu"], 3] ],
  [ [["quad"], -1], [["koutsu"], -2], [["pair"], 5] ]
]
|
.kokushi_tenpai_definition = [
  [ "unique",
    [["1m","9m","1p","9p","1s","9s","1z","2z","3z","4z","5z","6z","7z"], 11],
    [["1m","9m","1p","9p","1s","9s","1z","2z","3z","4z","5z","6z","7z"], 1]
  ],
  [ "unique",
    [["1m","9m","1p","9p","1s","9s","1z","2z","3z","4z","5z","6z","7z"], 12]
  ]
]
|
.win_definition = [
  [ "exhaustive", [["pair"], 1], [["ryanmen/penchan", "kanchan", "pair"], 1], [["shuntsu", "koutsu"], 3] ],
  [ "exhaustive", [["shuntsu", "koutsu"], 4] ],
  [ [["koutsu"], -1], [["pair"], 6] ],
  [ "unique",
    [["1m","9m","1p","9p","1s","9s","1z","2z","3z","4z","5z","6z","7z"], 12],
    [["1m","9m","1p","9p","1s","9s","1z","2z","3z","4z","5z","6z","7z"], 1]
  ]
]
