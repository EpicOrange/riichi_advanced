.after_initialization.actions += [["add_rule", "Local Yaku (1 Han)", "(Ketsupaihou) \"Missing Tile\". Win with an edge or middle wait on a tile for which three copies are already publicly visible.", 101]]
|
.ketsupaihou_definition = [
  [ "exhaustive", [[["1m","2m"],["1p","2p"],["1s","2s"],["8m","9m"],["8p","9p"],["8s","9s"]], 1], [["shuntsu", "koutsu"], 3], [["pair"], 1] ],
  [ "exhaustive", [["shuntsu", "koutsu"], 3], [["pair"], 1], [["kanchan"], 1] ]
]
|
.yaku += [
  {
    "display_name": "Ketsupaihou",
    "value": 1,
    "when": [{"name": "match", "opts": [["hand", "calls"], ["ketsupaihou"]]}, {"name": "has_hell_wait", "opts": ["win"]}]
  }
]
