(if .buttons | has("ton") then ["ton", "chii", "chon", "chon_honors", "daiminfuun", "pon", "daiminkan", "kapon", "kakakan", "kafuun", "kakan"] else ["chii", "pon", "daiminkan", "kakan"] end) as $open_calls
|
.yaku += [
  {
    "display_name": "Kyandonhou",
    "value": 2,
    "when": [
      {"name": "has_no_call_named", "opts": $open_calls},
      {"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ "exhaustive", [[[[0,1,2],[10,11,12]]], 2], [["pair"], 1] ]]]}
    ]
  }
]
