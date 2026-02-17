.after_initialization.actions += [
  ["add_rule", "Yakuman", "Chousangen", "You have kans of all three dragons.", 126],
  ["update_rule", "Yakuman", "Chousangen", "%{example_hand}", {"example_hand": ["2m", "3m", "4m", "5s", "3x", "5z", {"attrs": ["_sideways"], "tile": "5z"}, {"attrs": ["_sideways"], "tile": "5z"}, "5z", "3x", "1x", "6z", "6z", "1x", "3x", "7z", "7z", "7z", {"attrs": ["_sideways"], "tile": "7z"}, "3x", "5s"]}]
]
|
.yakuman += [
  {
    "display_name": "Chousangen",
    "value": 2,
    "when": [{"name": "match", "opts": [["calls"], [[ [["5z","5z","5z","5z"], 1], [["6z","6z","6z","6z"], 1], [["7z","7z","7z","7z"], 1] ]]]}]
  }
]
|
.yaku_precedence += {
  "Chousangen": ["Daisangen", "Sankantsu"]
}
