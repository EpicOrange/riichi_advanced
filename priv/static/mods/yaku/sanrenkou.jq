.after_initialization.actions += [
  ["add_rule", "2 Han", "Sanrenkou", "\"Three Consecutive Triplets\". Your hand has three triplets of the same suit in sequence, like 222 333 444.", 102],
  ["update_rule", "2 Han", "Sanrenkou", "%{example_hand}", {"example_hand": ["3p", "3p", "3p", "4p", "4p", "4p", "0p", "5p", "5p", "1s", "7z", "7z", "7z", "3x", "1s"]}]
]
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
