.after_initialization.actions += [
  ["add_rule", "1 Han", "Sanshoku Choupaikou", "Your hand has the pattern 111333555 in different suits (doesn't have to start at 1).", 101],
  ["add_rule", "1 Han", "Sanshoku Sujipaikou", "Your hand has the pattern 111444777 in different suits (doesn't have to start at 1).", 101],
  ["add_rule", "1 Han", "Sanshoku Chousankou", "Your hand has the pattern 111555999 in different suits.", 101],
  ["add_rule", "2 Han", "Choupaikou", "Your hand has the pattern 111333555 in the same suit (doesn't have to start at 1).", 102],
  ["add_rule", "2 Han", "Sujipaikou", "Your hand has the pattern 111444777 in the same suit (doesn't have to start at 1).", 102],
  ["add_rule", "2 Han", "Chousankou", "Your hand has the pattern 111555999 in the same suit.", 102]
]
|
(if .set_definitions | has("kontsu") then ["shuntsu", "kontsu", "koutsu"] else ["shuntsu", "koutsu"] end) as $others
|
.yaku += [
  {
    "display_name": "Choupaikou",
    "value": 2,
    "when": [{"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ "exhaustive", [[[[0,0,0],[2,2,2],[4,4,4]]], 1], [$others, 1], [["pair"], 1] ]]]}]
  },
  {
    "display_name": "Sujipaikou",
    "value": 2,
    "when": [{"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ "exhaustive", [[[[0,0,0],[3,3,3],[6,6,6]]], 1], [$others, 1], [["pair"], 1] ]]]}]
  },
  {
    "display_name": "Chousankou",
    "value": 2,
    "when": [{"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ "exhaustive", [[[[0,0,0],[4,4,4],[8,8,8]]], 1], [$others, 1], [["pair"], 1] ]]]}]
  },
  {
    "display_name": "Sanshoku Choupaikou",
    "value": 2,
    "when": [{"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ "exhaustive", [[[[0,0,0],[12,12,12],[24,24,24]], [[0,0,0],[22,22,22],[14,14,14]]], 1], [$others, 1], [["pair"], 1] ]]]}]
  },
  {
    "display_name": "Sanshoku Sujipaikou",
    "value": 2,
    "when": [{"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ "exhaustive", [[[[0,0,0],[13,13,13],[26,26,26]], [[0,0,0],[23,23,23],[16,16,16]]], 1], [$others, 1], [["pair"], 1] ]]]}]
  },
  {
    "display_name": "Sanshoku Chousankou",
    "value": 2,
    "when": [{"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ "exhaustive", [[[[0,0,0],[14,14,14],[28,28,28]], [[0,0,0],[24,24,24],[18,18,18]]], 1], [$others, 1], [["pair"], 1] ]]]}]
  }
]
