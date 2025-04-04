.after_initialization.actions += [["add_rule", "1 Han", "Shiiaru Raotai", "\"Twelve Tiles Down\". Win with four calls (so your hand is just one tile waiting for a pair).", 101]]
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
