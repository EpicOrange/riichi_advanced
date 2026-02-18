.after_initialization.actions += [
  ["add_rule", "1 Han", "Sanshoku Choupaikou", "Your hand has the pattern 111333555 in different suits (doesn't have to start at 1).", 101],
  ["update_rule", "1 Han", "Sanshoku Choupaikou", "%{example_hand}", {"example_hand": ["2m", "2m", "2m", "4p", "4p", "4p", "6s", "6s", "6s", "4z", "4z", "4z", "5z", "3x", "5z"]}],
  ["add_rule", "1 Han", "Sanshoku Sujipaikou", "Your hand has the pattern 111444777 in different suits (doesn't have to start at 1).", 101],
  ["update_rule", "1 Han", "Sanshoku Sujipaikou", "%{example_hand}", {"example_hand": ["2m", "2m", "2m", "5p", "5p", "5p", "8s", "8s", "8s", "4z", "4z", "4z", "5z", "3x", "5z"]}],
  ["add_rule", "1 Han", "Sanshoku Chousankou", "Your hand has the pattern 111555999 in different suits.", 101],
  ["update_rule", "1 Han", "Sanshoku Chousankou", "%{example_hand}", {"example_hand": ["1m", "1m", "1m", "5p", "5p", "5p", "9s", "9s", "9s", "4z", "4z", "4z", "5z", "3x", "5z"]}],
  ["add_rule", "2 Han", "Choupaikou", "Your hand has the pattern 111333555 in the same suit (doesn't have to start at 1).", 102],
  ["update_rule", "2 Han", "Choupaikou", "%{example_hand}", {"example_hand": ["2m", "2m", "2m", "4m", "4m", "4m", "6m", "6m", "6m", "4s", "5s", "6s", "9s", "3x", "9s"]}],
  ["add_rule", "2 Han", "Sujipaikou", "Your hand has the pattern 111444777 in the same suit (doesn't have to start at 1).", 102],
  ["update_rule", "2 Han", "Sujipaikou", "%{example_hand}", {"example_hand": ["2m", "2m", "2m", "5m", "5m", "5m", "8m", "8m", "8m", "4s", "5s", "6s", "9s", "3x", "9s"]}],
  ["add_rule", "2 Han", "Chousankou", "Your hand has the pattern 111555999 in the same suit.", 102],
  ["update_rule", "2 Han", "Chousankou", "%{example_hand}", {"example_hand": ["1m", "1m", "1m", "5m", "5m", "5m", "9m", "9m", "9m", "4s", "5s", "6s", "9s", "3x", "9s"]}]
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
