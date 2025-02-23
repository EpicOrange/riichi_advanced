.after_initialization.actions += [["add_rule", "Local Yaku (2 Han)", "(Isshoku Sanjun) \"Pure Triple Sequences\". 2 han if you have three of the exact same sequence in one suit, like 123 123 123. Like iipeikou but three. 3 han if closed. Does not stack with iipeikou (123 123) or sanrenkou (111 222 333).", 102]]
|
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
  "Isshoku Sanjun": ["Iipeikou", "Sanankou", "Sanrenkou", "Choupaikou", "Sujipaikou", "Chousankou"]
}
|
.yaku_precedence["Suuankou"] += ["Isshoku Sanjun"]
