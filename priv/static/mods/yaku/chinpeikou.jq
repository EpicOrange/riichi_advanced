.after_initialization.actions += [
  ["add_rule", "3 Han", "Chinpeikou", "3 han on top of ryanpeikou if your ryanpeikou sequences are all the same numbers (may be different suits), like 112233m 112233p. No restriction on the pair, so you can have an honor pair (despite 'chin' being in the name).", 103],
  ["update_rule", "3 Han", "Chinpeikou", "%{example_hand}", {"example_hand": ["2m", "2m", "3m", "3m", "4m", "4m", "2s", "2s", "3s", "3s", "4s", "4s", "9p", "3x", "9p"]}]
]
|
(if .buttons | has("ton") then ["ton", "chii", "chon", "chon_honors", "daiminfuun", "pon", "daiminkan", "kapon", "kakakan", "kafuun", "kakan"] else ["chii", "pon", "daiminkan", "kakan"] end) as $open_calls
|
.yaku += [
  {
    "display_name": "Chinpeikou",
    "value": 3,
    "when": [{"name": "has_no_call_named", "opts": $open_calls}, {"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ "exhaustive", [[[[0,1,2],[0,1,2],[10,11,12],[10,11,12]]], 1], [["pair"], 1] ]]]}]
  }
]
