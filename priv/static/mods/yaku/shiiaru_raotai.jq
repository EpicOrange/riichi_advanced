.after_initialization.actions += [
  ["add_rule", "1 Han", "Shiiaru Raotai", "\"Twelve Tiles Down\". Win with four calls (so your hand is just one tile waiting for a pair). Ankans are allowed.", 101],
  ["update_rule", "1 Han", "Shiiaru Raotai", "%{example_hand}", {"example_hand": ["6z", "3x", "9s", {"attrs": ["_sideways"], "tile": "9s"}, "9s", "3x", "2p", {"attrs": ["_sideways"], "tile": "2p"}, "2p", "3x", {"attrs": ["_sideways"], "tile": "4p"}, "0p", "6p", "3x", {"attrs": ["_sideways"], "tile": "1p"}, "2p", "3p", "3x", "6z"]}]
]
|
(if .buttons | has("ton") then ["ton", "chii", "chon", "chon_honors", "daiminfuun", "pon", "daiminkan", "kapon", "kakakan", "kafuun", "kakan", "anfuun", "ankan"] else ["chii", "pon", "daiminkan", "kakan", "ankan"] end) as $all_calls
|
.yaku += [
  {
    "display_name": "Shiiaru Raotai",
    "value": 1,
    "when": [{"name": "match", "opts": [["calls"], [[[$all_calls, 4]]]]}]
  }
]
