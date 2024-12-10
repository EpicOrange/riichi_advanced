(if .set_definitions | has("kontsu") then ["shuntsu", "kontsu", "koutsu"] else ["shuntsu", "koutsu"] end) as $others
|
.yaku += [
  {
    "display_name": "Shoutate",
    "value": 2,
    "when": [{"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ "exhaustive", [[[[0,0,0],[10,10,10],[20,20]], [[0,0,0],[20,20,20],[10,10]], [[0,0,0],[10,10],[20,20,20]], [[0,0,0],[20,20],[10,10,10]], [[0,0],[10,10,10],[20,20,20]], [[0,0],[20,20,20],[10,10,10]]], 1], [$others, 2] ]]]}]
  }
]
