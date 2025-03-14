.after_initialization.actions += [["add_rule", "Yakuman", "Chousuushii", "You have kans of all four winds.", 152]]
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

