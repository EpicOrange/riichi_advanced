.after_initialization.actions += [["add_rule", "Local Yaku (2 Han)", "(Kyandonhou) \"Twice Mixed Double Sequence\". Your hand has two mixed double sequences, like 11678m345678p345s. A mixed double sequence is two sequences of the same number but in different suits, like 345m 345p.", 102]]
|
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
