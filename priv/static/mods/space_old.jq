.after_initialization.actions += [
  ["add_rule", "Rules", "Space Mahjong", "Sequences can wrap (891, 912). Winds and dragons can make sequences. You can chii from any direction."],
  ["add_rule", "Rules", "Win Condition", "- (Space Mahjong) Seven Pairs is no longer a winning hand.", -100],
  ["add_rule", "3 Han", "Open Kokushi Musou", "(Space Mahjong) Open kokushi musou is worth 3 han."]
]
|
# add open kokushi
.yaku += [
  {
    "display_name": "Open Kokushi Musou",
    "value": 3,
    "when": [
      {"name": "winning_hand_consists_of", "opts": ["1m","9m","1p","9p","1s","9s","1z","2z","3z","4z","5z","6z","7z"]},
      {"name": "not_match", "opts": [["hand", "calls", "winning_tile"], [[[["ton_pair", "nan_pair", "shaa_pair", "pei_pair", "haku_pair", "hatsu_pair", "chun_pair"], 2]]]]},
      {"name": "not_match", "opts": [["hand", "calls", "winning_tile"], [[[["ton", "nan", "shaa", "pei", "haku", "hatsu", "chun"], 1]]]]}
    ]
  }
]
|
# remove chiitoitsu
.yaku |= map(select(.display_name != "Chiitoitsu"))
|
.tenpai_definition |= map(select(type != "array" or all(.[]; . != [["pair"], 6])))
|
.win_definition |= map(select(type != "array" or all(.[]; . != [["pair"], 7])))
|
# sequences wrap, and honors form wrapping sequences
.after_start.actions += [
  ["set_tile_ordering_all", ["9m", "1m"]],
  ["set_tile_ordering_all", ["9p", "1p"]],
  ["set_tile_ordering_all", ["9s", "1s"]],
  ["set_tile_ordering_all", ["1z", "2z", "3z", "4z", "1z"]],
  ["set_tile_ordering_all", ["5z", "6z", "7z", "5z"]]
]
|
# chii from anyone
.buttons |= if has("chii") then
  .chii.show_when |= map(if . == "kamicha_discarded" then "someone_else_just_discarded" else . end)
else . end
