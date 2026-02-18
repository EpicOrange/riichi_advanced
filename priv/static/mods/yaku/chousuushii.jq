.after_initialization.actions += [
  ["add_rule", "Yakuman", "Chousuushii", "You have kans of all four winds.", 152],
  ["update_rule", "Yakuman", "Chousuushii", "%{example_hand}", {"example_hand": ["5s", "3x", {"attrs": ["_sideways"], "tile": "1z"}, {"attrs": ["_sideways"], "tile": "1z"}, "1z", "1z", "3x", "2z", {"attrs": ["_sideways"], "tile": "2z"}, {"attrs": ["_sideways"], "tile": "2z"}, "2z", "3x", "1x", "3z", "3z", "1x", "3x", "4z", "4z", "4z", {"attrs": ["_sideways"], "tile": "4z"}, "3x", "5s"]}]
]
|
.yakuman += [
  {
    "display_name": "Chousuushii",
    "value": 4,
    "when": [{"name": "match", "opts": [["calls"], [[ [["1z","1z","1z","1z"], 1], [["2z","2z","2z","2z"], 1], [["3z","3z","3z","3z"], 1], [["4z","4z","4z","4z"], 1] ]]]}]
  }
]
|
.yaku_precedence += {
  "Chousuushii": ["Daisuushii", "Suukantsu"]
}

