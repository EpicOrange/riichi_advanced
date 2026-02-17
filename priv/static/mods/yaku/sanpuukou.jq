.after_initialization.actions += [
  ["add_rule", "2 Han", "Sanpuukou", "\"Three Wind Triplets\". You have three wind triplets.", 102],
  ["update_rule", "2 Han", "Sanpuukou", "%{example_hand}", {"example_hand": ["3m", "3m", "3m", "5p", "5p", "1z", "1z", "2z", "2z", "2z", "4z", "4z", "4z", "3x", "1z"]}]
]
|
(if .set_definitions | has("kontsu") then ["shuntsu", "kontsu", "koutsu"] else ["shuntsu", "koutsu"] end) as $others
|
.yaku += [
  {
    "display_name": "Sanpuukou",
    "value": 2,
    "when": [{"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ [["ton", "nan", "shaa", "pei"], 3], [$others, 1], [["pair"], 1] ]]]}]
  }
]
