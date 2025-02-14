.tenpai_definition += [[ [["koutsu"], -1], [["pair"], 6] ]]
|
.win_definition += [[ [["nojoker", "quad"], -1], [["pair"], 7] ]]
|
.yaku += [
  {
    "display_name": "Seven Pairs",
    "value": 4,
    "when": [{"name": "match", "opts": [["hand", "winning_tile"], [[[["nojoker", "quad"], -1], [["pair"], 7]]]]}]
  }
]
|
# since all honours can now be seven pairs, all triplets is no longer implied
.yaku_precedence."All Honours" |= map(select(. != "All Triplets"))
