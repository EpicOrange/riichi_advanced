.after_initialization.actions += [["add_rule", "1 Han", "Sanshoku Ittsu", "1 han for having a three-color straight, like 123m 456p 789s. 2 han if closed.", 101]]
|
(if .set_definitions | has("kontsu") then ["shuntsu", "kontsu", "koutsu"] else ["shuntsu", "koutsu"] end) as $others
|
(if .buttons | has("ton") then ["ton", "chii", "chon", "chon_honors", "daiminfuun", "pon", "daiminkan", "kapon", "kakakan", "kafuun", "kakan"] else ["chii", "pon", "daiminkan", "kakan"] end) as $open_calls
|
.yaku += [
  {
    "display_name": "Sanshoku Ittsu",
    "value": 1,
    "when": [{"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ "exhaustive", [[[[0,1,2],[13,14,15],[26,27,28]], [[0,1,2],[23,24,25],[16,17,18]]], 1], [$others, 1], [["pair"], 1] ]]]}]
  }
]
|
.meta_yaku += [
  { "display_name": "Sanshoku Ittsu", "value": 1, "when": [{"name": "has_no_call_named", "opts": $open_calls}, {"name": "has_existing_yaku", "opts": ["Sanshoku Ittsu"]}] }
]
