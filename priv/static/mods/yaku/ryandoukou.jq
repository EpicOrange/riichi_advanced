.after_initialization.actions += [["add_rule", "Local Yaku (2 Han)", "(Ryandoukou) \"Twice Double Triplets\". Your hand has two double triplets, like 11444m444666p666s. A double triplet is when you have two triplets of the same number in different suits, like 333m 333p.", 102]]
|
(if .set_definitions | has("kontsu") then ["shuntsu", "kontsu", "koutsu"] else ["shuntsu", "koutsu"] end) as $others
|
.yaku += [
  {
    "display_name": "Ryandoukou",
    "value": 2,
    "when": [{"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ "exhaustive", [[[[0,0,0],[10,10,10]], [[0,0,0],[20,20,20]]], 1], [$others, 2], [["pair"], 1] ]]]}]
  }
]
