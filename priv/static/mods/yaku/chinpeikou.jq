(if .buttons | has("ton") then ["ton", "chii", "chon", "chon_honors", "daiminfuun", "pon", "daiminkan", "kapon", "kakakan", "kafuun", "kakan"] else ["chii", "pon", "daiminkan", "kakan"] end) as $open_calls
|
.yaku += [
  {
    "display_name": "Chinpeikou",
    "value": 3,
    "when": [{"name": "has_no_call_named", "opts": $open_calls}, {"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ "exhaustive", [[[[0,1,2],[0,1,2],[10,11,12],[10,11,12]]], 1], [["pair"], 1] ]]]}]
  }
]
