.["一色三連刻_definition"] = [
  [ "exhaustive", [[[[0,0,0],[1,1,1],[2,2,2]]], 1], [["shuntsu", "koutsu"], 1], [["pair"], 1] ]
]
|
.["一色四連刻_definition"] = [
  [ "exhaustive", [[[[0,0,0],[1,1,1],[2,2,2],[3,3,3]]], 1], [["pair"], 1] ]
]
|
.big_three_winds_definition = [
  [ "unique", [["ton", "nan", "shaa", "pei"], 3] ]
]
|
.yaku += [
  { "display_name": "Three Consecutive Triplets", "value": 2, "when": [{"name": "match", "opts": [["hand", "calls", "winning_tile"], ["一色三連刻"]]}] },
  { "display_name": "Big Three Winds", "value": 2, "when": [{"name": "match", "opts": [["hand", "calls", "winning_tile"], ["big_three_winds"]]}] }
]
|
.yakuman += [
  { "display_name": "Four Consecutive Triplets", "value": 1, "when": [{"name": "match", "opts": [["hand", "calls", "winning_tile"], ["一色四連刻"]]}] },
  { "display_name": "Manzu Chinitsu", "value": 1, "when": [{"name": "winning_hand_consists_of", "opts": ["1m","2m","3m","4m","5m","6m","7m","8m","9m"]}] }
]
|
.meta_yaku += [
  { "display_name": "Honitsu Chiitoitsu", "value": 6, "when": [{"name": "has_existing_yaku", "opts": ["Honitsu", "Chiitoitsu"]}] }
]
|
.meta_yakuman += [
  { "display_name": "Chinitsu Chiitoitsu", "value": 1, "when": [{"name": "has_existing_yaku", "opts": ["Chinitsu", "Chiitoitsu"]}] }
]
|
.yaku_precedence += {
  "Tsumo": ["Pinfu"], # tsumo fu invalidates pinfu
  "Manzu Chinitsu": ["Chinitsu"],
  "Honitsu Chiitoitsu": ["Honitsu", "Chiitoitsu"],
  "Chinitsu Chiitoitsu": ["Chinitsu", "Chiitoitsu"]
}
|
# furiten riichi not allowed
if (.buttons | has("riichi")) then
  .buttons.riichi.show_when += [{"name": "status_missing", "opts": ["furiten"]}]
else . end
