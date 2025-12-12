.after_initialization.actions += [["add_rule", "Yakuman", "Chousangen", "You have kans of all three dragons.", 126]]
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
