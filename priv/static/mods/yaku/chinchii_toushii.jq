.after_initialization.actions += [["add_rule", "Local Yaku (4 Han)", "(Chinchii Toushii) \"Golden Rooster Steals Food\". 4 han instead of the usual 2 han if you win ketsupaihou by chankan -- that is, you robbed a kan with an edge or middle wait.", 104]]
|
.meta_yaku += [
  {
    "display_name": "Chinchii Toushii",
    "value": 4,
    "when": [{"name": "has_existing_yaku", "opts": ["Chankan", "Ketsupaihou"]}]
  }
]
|
.yaku_precedence["Chinchii Toushii"] = ["Chankan", "Ketsupaihou"]
