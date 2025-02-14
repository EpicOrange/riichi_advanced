def fix_chanta_match_definition($new_groups):
  map(if type == "array" then
    map(
      if type == "array" and any(.[0][]; . == "junchan_1") then .[0] += $new_groups else . end
    )
  else . end);

# add open kokushi
.kokushi_tenpai_definition += [
  [ "unique",
    [["1m","9m","1p","9p","1s","9s","4z","5z","6z","7z"], 9],
    [[["1z","2z","3z"]], 1],
    [["1m","9m","1p","9p","1s","9s","1z","2z","3z","4z","5z","6z","7z"], 1]
  ],
  [ "unique",
    [["1m","9m","1p","9p","1s","9s","3z","5z","6z","7z"], 9],
    [[["1z","2z","4z"]], 1],
    [["1m","9m","1p","9p","1s","9s","1z","2z","3z","4z","5z","6z","7z"], 1]
  ],
  [ "unique",
    [["1m","9m","1p","9p","1s","9s","2z","5z","6z","7z"], 9],
    [[["1z","3z","4z"]], 1],
    [["1m","9m","1p","9p","1s","9s","1z","2z","3z","4z","5z","6z","7z"], 1]
  ],
  [ "unique",
    [["1m","9m","1p","9p","1s","9s","1z","5z","6z","7z"], 9],
    [[["2z","3z","4z"]], 1],
    [["1m","9m","1p","9p","1s","9s","1z","2z","3z","4z","5z","6z","7z"], 1]
  ],
  [ "unique",
    [["1m","9m","1p","9p","1s","9s","1z","2z","3z","4z"], 9],
    [[["5z","6z","7z"]], 1],
    [["1m","9m","1p","9p","1s","9s","1z","2z","3z","4z","5z","6z","7z"], 1]
  ],
  [ "unique",
    [["1m","9m","1p","9p","1s","9s","4z"], 6],
    [[["1z","2z","3z"]], 1],
    [[["5z","6z","7z"]], 1],
    [["1m","9m","1p","9p","1s","9s","1z","2z","3z","4z","5z","6z","7z"], 1]
  ],
  [ "unique",
    [["1m","9m","1p","9p","1s","9s","3z"], 6],
    [[["1z","2z","4z"]], 1],
    [[["5z","6z","7z"]], 1],
    [["1m","9m","1p","9p","1s","9s","1z","2z","3z","4z","5z","6z","7z"], 1]
  ],
  [ "unique",
    [["1m","9m","1p","9p","1s","9s","2z"], 6],
    [[["1z","3z","4z"]], 1],
    [[["5z","6z","7z"]], 1],
    [["1m","9m","1p","9p","1s","9s","1z","2z","3z","4z","5z","6z","7z"], 1]
  ],
  [ "unique",
    [["1m","9m","1p","9p","1s","9s","1z"], 6],
    [[["2z","3z","4z"]], 1],
    [[["5z","6z","7z"]], 1],
    [["1m","9m","1p","9p","1s","9s","1z","2z","3z","4z","5z","6z","7z"], 1]
  ]
]
|
# add open kokushi
.win_definition += [
  [
    [[["1m","9m","1p","9p","1s","9s"]], 1],
    [[["5z","6z","7z"]], 1],
    [[["1z","2z","3z"]], 1],
    [["4z"], 1],
    [["1m","9m","1p","9p","1s","9s","1z","2z","3z","4z","5z","6z","7z"], 1]
  ],
  [
    [[["1m","9m","1p","9p","1s","9s"]], 1],
    [[["5z","6z","7z"]], 1],
    [[["1z","2z","4z"]], 1],
    [["3z"], 1],
    [["1m","9m","1p","9p","1s","9s","1z","2z","3z","4z","5z","6z","7z"], 1]
  ],
  [
    [[["1m","9m","1p","9p","1s","9s"]], 1],
    [[["5z","6z","7z"]], 1],
    [[["1z","3z","4z"]], 1],
    [["2z"], 1],
    [["1m","9m","1p","9p","1s","9s","1z","2z","3z","4z","5z","6z","7z"], 1]
  ],
  [
    [[["1m","9m","1p","9p","1s","9s"]], 1],
    [[["5z","6z","7z"]], 1],
    [[["2z","3z","4z"]], 1],
    [["1z"], 1],
    [["1m","9m","1p","9p","1s","9s","1z","2z","3z","4z","5z","6z","7z"], 1]
  ]
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
# sequences wrap (supports ten mod)
if any(.wall[]; . == "10m") then
  .after_start.actions += [
    ["set_tile_ordering_all", ["10m", "1m"]],
    ["set_tile_ordering_all", ["10p", "1p"]],
    ["set_tile_ordering_all", ["10s", "1s"]]
  ]
else
  .after_start.actions += [
    ["set_tile_ordering_all", ["9m", "1m"]],
    ["set_tile_ordering_all", ["9p", "1p"]],
    ["set_tile_ordering_all", ["9s", "1s"]]
  ]
end
|
# honors form wrapping sequences
.after_start.actions += [
  ["set_tile_ordering_all", ["1z", "2z", "3z", "4z", "1z"]],
  ["set_tile_ordering_all", ["5z", "6z", "7z", "5z"]]
]
|
# chii from anyone
.buttons |= if has("chii") then
  .chii.show_when |= map(if . == "kamicha_discarded" then "someone_else_just_discarded" else . end)
else . end
|
# update chanta and junchan
if any(.wall[]; . == "10m") then
  # ten mod
  .set_definitions += {
    "junchan_space_1": ["9m","10m","1m"],
    "junchan_space_2": ["10m","1m","2m"],
    "junchan_space_3": ["9p","10p","1p"],
    "junchan_space_4": ["10p","1p","2p"],
    "junchan_space_5": ["9s","10s","1s"],
    "junchan_space_6": ["10s","1s","2s"]
  }
else
  .set_definitions += {
    "junchan_space_1": ["8m","9m","1m"],
    "junchan_space_2": ["9m","1m","2m"],
    "junchan_space_3": ["8p","9p","1p"],
    "junchan_space_4": ["9p","1p","2p"],
    "junchan_space_5": ["8s","9s","1s"],
    "junchan_space_6": ["9s","1s","2s"]
  }
end
|
.set_definitions += {
  "chanta_space_1": ["1z","2z","3z"],
  "chanta_space_2": ["2z","3z","4z"],
  "chanta_space_3": ["3z","4z","1z"],
  "chanta_space_4": ["4z","1z","2z"],
  "chanta_space_5": ["5z","6z","7z"]
}
|
.yaku |= map(
  if .display_name == "Chanta" then
    .when |= walk(
      if type == "object" and (.name == "match" or .name == "not_match") then
        .opts[1] |= fix_chanta_match_definition(["junchan_space_1", "junchan_space_2", "junchan_space_3", "junchan_space_4", "junchan_space_5", "junchan_space_6", "chanta_space_1", "chanta_space_2", "chanta_space_3", "chanta_space_4", "chanta_space_5"])
      else . end
    )
  elif .display_name == "Junchan" then
    .when |= walk(
      if type == "object" and (.name == "match" or .name == "not_match") then
        .opts[1] |= fix_chanta_match_definition(["junchan_space_1", "junchan_space_2", "junchan_space_3", "junchan_space_4", "junchan_space_5", "junchan_space_6"])
      else . end
    )
  else . end
)
|
# this makes the win screen take shuntsu and koutsu out of the hand before displaying
.score_calculation.arrange_shuntsu = true
|
.score_calculation.arrange_koutsu = true
