def add_aka_status($actions; $check):
  [
    ["when", [{"name": "match", "opts": [["hand", "calls", $check], [[[["0t"], 1]]]]}], [["set_status", "aka_t"]]]
  ] + $actions;

.after_initialization.actions += [["add_rule", "Wall", "(Star Suit) There is a fourth star suit.", -99]]
|
.wall += [
  "1t", "1t", "1t", "1t",
  "2t", "2t", "2t", "2t",
  "3t", "3t", "3t", "3t",
  "4t", "4t", "4t", "4t",
  "5t", "5t", "5t", "5t",
  "6t", "6t", "6t", "6t",
  "7t", "7t", "7t", "7t",
  "8t", "8t", "8t", "8t",
  "9t", "9t", "9t", "9t"
]
|
.after_start.actions += [
  ["set_tile_ordering", ["1t", "2t", "3t", "4t", "5t", "6t", "7t", "8t", "9t"]]
]
|
# expand dora indicator map, if it exists
if .dora_indicators then
  .dora_indicators += {
    "1t": ["2t"],
    "2t": ["3t"],
    "3t": ["4t"],
    "4t": ["5t"],
    "5t": ["6t"],
    "6t": ["7t"],
    "7t": ["8t"],
    "8t": ["9t"]
  }
else . end
|
# ten support
if any(.wall[]; . == "10m") then
  .wall += ["10t", "10t", "10t", "10t"]
else . end
|
# add definitions to accommodate star suit
.set_definitions.junchan_13 = ["1t", "1t", "1t"]
|
.set_definitions.junchan_14 = ["1t", "2t", "3t"]
|
.set_definitions.junchan_15 = ["7t", "8t", "9t"]
|
.set_definitions.junchan_16 = ["9t", "9t", "9t"]
|
.set_definitions.junchan_pair_7 = ["1t", "1t"]
|
.set_definitions.junchan_pair_8 = ["9t", "9t"]
|
# .set_definitions.orphans_all = [????]
|
# change tenpai_definition, kokushi_tenpai_definition, win_definition, and kokushi_definition to accommodate for 1t and 9t, allowing a 15-way wait
.tenpai_definition -= [
    [ "unique",
      [["1m","9m","1p","9p","1s","9s","1z","2z","3z","4z","5z","6z","7z"], 12],
      [["1m","9m","1p","9p","1s","9s","1z","2z","3z","4z","5z","6z","7z"], 1]
    ]
]
|
.tenpai_definition += [
    [ "unique",
      [["1m","9m","1p","9p","1s","9s","1t","9t","1z","2z","3z","4z","5z","6z","7z"], 12],
      [["1m","9m","1p","9p","1s","9s","1t","9t","1z","2z","3z","4z","5z","6z","7z"], 1]
    ]
]
|
.kokushi_tenpai_definition -= [
    [ "unique",
      [["1m","9m","1p","9p","1s","9s","1z","2z","3z","4z","5z","6z","7z"], 12],
      [["1m","9m","1p","9p","1s","9s","1z","2z","3z","4z","5z","6z","7z"], 1]
    ]
]
|
.kokushi_tenpai_definition += [
    [ "unique",
      [["1m","9m","1p","9p","1s","9s","1t","9t","1z","2z","3z","4z","5z","6z","7z"], 12],
      [["1m","9m","1p","9p","1s","9s","1t","9t","1z","2z","3z","4z","5z","6z","7z"], 1]
    ]
]
|
.win_definition -= [
    [ "unique",
      [["1m","9m","1p","9p","1s","9s","1z","2z","3z","4z","5z","6z","7z"], 13],
      [["1m","9m","1p","9p","1s","9s","1z","2z","3z","4z","5z","6z","7z"], 1]
    ]
]
|
.win_definition += [
    [ "unique",
      [["1m","9m","1p","9p","1s","9s","1t","9t","1z","2z","3z","4z","5z","6z","7z"], 13],
      [["1m","9m","1p","9p","1s","9s","1t","9t","1z","2z","3z","4z","5z","6z","7z"], 1]
    ]
]
|
.kokushi_definition -= [
    [ "unique",
      [["1m","9m","1p","9p","1s","9s","1z","2z","3z","4z","5z","6z","7z"], 13],
      [["1m","9m","1p","9p","1s","9s","1z","2z","3z","4z","5z","6z","7z"], 1]
    ]
]
|
.kokushi_definition += [
    [ "unique",
      [["1m","9m","1p","9p","1s","9s","1t","9t","1z","2z","3z","4z","5z","6z","7z"], 13],
      [["1m","9m","1p","9p","1s","9s","1t","9t","1z","2z","3z","4z","5z","6z","7z"], 1]
    ]
]
|
# change yaku to accommodate star suit
# need to change the following yaku:
# * ✅ tanyao (now 2~8m, 2~8s, 2~8p, and 2~8t)
# * ✅ honrou/chinrou (add 1t, 9t)
# * chanta/junchan (add junchan_13~16 and junchan_pair_7~8)  // code is currently copied from Ten Mod so it makes no sense
# * honitsu/chinitsu (add 1t~9t as an option)                // code is currently copied from Ten Mod so it makes no sense

# change tanyao, honroutou, honitsu, chinitsu
.yaku |= map(
  if .display_name == "Tanyao" then
    .when[0].opts += ["2t", "3t", "4t", "5t", "6t", "7t", "8t"]
  elif .display_name == "Honroutou" then
    .when[0].opts += ["1t", "9t"]
#  elif .display_name == "Chanta" then
#    .when[0].opts += ["1t", "9t"]
#  elif .display_name == "Junchan" then
#    .when[0].opts += ["1t", "9t"]
#  elif .display_name == "Honitsu" or .display_name == "Chinitsu" or .display_name == "Half Flush" or .display_name == "Full Flush" then
#    .when[-1][0].opts += ["10m"] | .when[-1][1].opts += ["10p"] | .when[-1][2].opts += ["10s"]
  else . end
)
|
# change chinroutou
.yakuman |= map(
  if .display_name == "Chinroutou" then
    .when[0].opts += ["1t", "9t"]
  else . end
)
|
# add the following yaku:
# * yonshoku doujun (4/3 han open)
# * yonshoku doukou (5 han)







