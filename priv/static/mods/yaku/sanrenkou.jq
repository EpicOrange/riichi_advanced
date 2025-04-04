.after_initialization.actions += [["add_rule", "2 Han", "Sanrenkou", "\"Three Consecutive Triplets\". Your hand has three triplets of the same suit in sequence, like 222 333 444.", 102]]
|
(if .set_definitions | has("kontsu") then ["shuntsu", "kontsu", "koutsu"] else ["shuntsu", "koutsu"] end) as $others
|
.yaku += [
  {
    "display_name": "Sanrenkou",
    "value": 2,
    "when": [{"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ "exhaustive", [[[[0,0,0],[1,1,1],[2,2,2]]], 1], [$others, 1], [["pair"], 1] ]]]}]
  }
]
