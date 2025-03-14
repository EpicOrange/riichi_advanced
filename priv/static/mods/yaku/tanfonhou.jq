.after_initialization.actions += [
  ["add_rule", "2 Han", "Tanfonhou", "\"Win Without Red\". 2 han if your hand contains no red. This means you can have only 248p (2,4,8 circles), 23468s (2,3,4,6,8 bamboo), and any honors except red dragon. 3 han if closed.", 102],
  ["add_rule", "5 Han", "Chintanfon", "\"Purely Without Red\". 5 han if your hand contains no red or honor tiles. This means you can have only 248p (2,4,8 circles) and 23468s (2,3,4,6,8 bamboo). 6 han if closed.", 105]
]
|
(if .buttons | has("ton") then ["ton", "chii", "chon", "chon_honors", "daiminfuun", "pon", "daiminkan", "kapon", "kakakan", "kafuun", "kakan"] else ["chii", "pon", "daiminkan", "kakan"] end) as $open_calls
|
.yaku += [
  {
    "display_name": "Tanfonhou",
    "value": 2,
    "when": [{"name": "winning_hand_and_tile_consists_of", "opts": ["2p","4p","8p","2s","3s","4s","6s","8s","1z","2z","3z","4z","5z","6z"]}]
  },
  {
    "display_name": "Chintanfon",
    "value": 5,
    "when": [{"name": "winning_hand_and_tile_consists_of", "opts": ["2p","4p","8p","2s","3s","4s","6s","8s"]}]
  }
]
|
.meta_yaku += [
  { "display_name": "Tanfonhou", "value": 1, "when": [{"name": "has_no_call_named", "opts": $open_calls}, {"name": "has_existing_yaku", "opts": ["Tanfonhou"]}] },
  { "display_name": "Chintanfon", "value": 1, "when": [{"name": "has_no_call_named", "opts": $open_calls}, {"name": "has_existing_yaku", "opts": ["Chintanfon"]}] }
]
|
.yaku_precedence += {
  "Chintanfon": ["Tanfonhou"],
  "Ryuuiisou": ["Chintanfon"]
}
