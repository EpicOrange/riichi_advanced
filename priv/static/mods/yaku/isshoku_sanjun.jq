(if .set_definitions | has("kontsu") then ["shuntsu", "kontsu", "koutsu"] else ["shuntsu", "koutsu"] end) as $others
|
(if .buttons | has("ton") then ["ton", "chii", "chon", "chon_honors", "daiminfuun", "pon", "daiminkan", "kapon", "kakakan", "kafuun", "kakan"] else ["chii", "pon", "daiminkan", "kakan"] end) as $open_calls
|
.yaku += [
  {
    "display_name": "Isshoku Sanjun",
    "value": 2,
    "when": [{"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ "exhaustive", [[[[0,1,2],[0,1,2],[0,1,2]]], 1], [$others, 1], [["pair"], 1] ]]]}]
  }
]
|
.meta_yaku += [
  { "display_name": "Isshoku Sanjun", "value": 1, "when": [{"name": "has_no_call_named", "opts": $open_calls}, {"name": "has_existing_yaku", "opts": ["Isshoku Sanjun"]}] }
]
|
.yaku_precedence += {
  "Isshoku Sanjun": ["Iipeikou", "Sanrenkou"]
}
