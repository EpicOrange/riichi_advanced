.after_initialization.actions += [["add_rule", "2 Han", "Ittsu Chanta", "Ittsu becomes 2 han if the rest of your hand is chanta (or junchan, in which case it's 3 han). +1 han if closed.", 102]]
|
(if .set_definitions | has("kontsu") then ["shuntsu", "kontsu", "koutsu"] else ["shuntsu", "koutsu"] end) as $others
|
(if .buttons | has("ton") then ["ton", "chii", "chon", "chon_honors", "daiminfuun", "pon", "daiminkan", "kapon", "kakakan", "kafuun", "kakan"] else ["chii", "pon", "daiminkan", "kakan"] end) as $open_calls
|
.yaku += [
  {
    "display_name": "Ittsu Chanta",
    "value": 2,
    "when": [
      {"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ "exhaustive", [["ittsu"], 1], [["junchan_1", "junchan_2", "junchan_3", "junchan_4", "junchan_5", "junchan_6", "junchan_7", "junchan_8", "junchan_9", "junchan_10", "junchan_11", "junchan_12", "ton", "nan", "shaa", "pei", "haku", "hatsu", "chun"], 1], [["junchan_pair_1", "junchan_pair_2", "junchan_pair_3", "junchan_pair_4", "junchan_pair_5", "junchan_pair_6", "ton_pair", "nan_pair", "shaa_pair", "pei_pair", "haku_pair", "hatsu_pair", "chun_pair"], 1] ]]]}
    ]
  },
  {
    "display_name": "Ittsu Junchan",
    "value": 3,
    "when": [
      {"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ "exhaustive", [["ittsu"], 1], [["junchan_1", "junchan_2", "junchan_3", "junchan_4", "junchan_5", "junchan_6", "junchan_7", "junchan_8", "junchan_9", "junchan_10", "junchan_11", "junchan_12"], 1], [["junchan_pair_1", "junchan_pair_2", "junchan_pair_3", "junchan_pair_4", "junchan_pair_5", "junchan_pair_6"], 1] ]]]}
    ]
  }
]
|
.meta_yaku += [
  { "display_name": "Ittsu Chanta", "value": 1, "when": [{"name": "has_no_call_named", "opts": $open_calls}, {"name": "has_existing_yaku", "opts": ["Ittsu Chanta"]}] },
  { "display_name": "Ittsu Junchan", "value": 1, "when": [{"name": "has_no_call_named", "opts": $open_calls}, {"name": "has_existing_yaku", "opts": ["Ittsu Junchan"]}] }
]
|
.yaku_precedence += {
  "Ittsu Chanta": ["Ittsu"],
  "Ittsu Junchan": ["Ittsu Chanta"]
}
