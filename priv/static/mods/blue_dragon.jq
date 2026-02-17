.after_initialization.actions += [
  ["add_rule", "Rules", "Wall", "(Blue Dragon) Four blue dragons (framed tiles) are added to the wall.", -99],
  # should the Blue Dragon yaku be integrated into the Yakuhai yaku?
  ["add_rule", "1 Han", "Blue Dragon", "A triplet of blue dragons is yakuhai."],
  ["update_rule", "1 Han", "Blue Dragon", "%{example_hand}", {"example_hand": ["2m", "3m", "4m", "3p", "3p", "7p", "7p", "7p", "4s", "5s", "0z", "0z", "0z", "3x", "6s"]}],
  ["delete_rule", "2 Han", "Shousangen"],
  ["delete_rule", "Yakuman", "Daisangen"],
  ["add_rule", "1 Han", "Shousangen", "(Blue Dragon) Shousangen is now 1 han (+2 from dragons)."],
  ["update_rule", "1 Han", "Shousangen", "%{example_hand}", {"example_hand": ["2m", "3m", "4m", "5z", "5z", "5z", "6z", "6z", "4s", "5s", "0z", "0z", "0z", "3x", "6s"]}],
  ["add_rule", "2 Han", "Daisangen", "(Blue Dragon) Daisangen is now 2 han (+3 from dragons)."],
  ["update_rule", "2 Han", "Daisangen", "%{example_hand}", {"example_hand": ["2m", "3m", "4m", "5z", "5z", "5z", "6z", "6z", "4s", "4s", "0z", "0z", "0z", "3x", "6z"]}],
  ["add_rule", "Yakuman", "Shousuugen", "(Blue Dragon) Having three dragon triplets and a dragon pair awards the Shousuugen yakuman."],
  ["update_rule", "Yakuman", "Shousuugen", "%{example_hand}", {"example_hand": ["2m", "3m", "4m", "5z", "5z", "5z", "6z", "6z", "7z", "7z", "0z", "0z", "0z", "3x", "6z"]}],
  ["add_rule", "Yakuman", "Daisuugen", "(Blue Dragon) Having four dragon triplets awards the Daisuugen double yakuman."],
  ["update_rule", "Yakuman", "Daisuugen", "%{example_hand}", {"example_hand": ["2m", "2m", "5z", "5z", "5z", "6z", "6z", "7z", "7z", "7z", "0z", "0z", "0z", "3x", "6z"]}],
  ["add_rule", "Rules", "Dora", "(Blue Dragon) For dragons, the sequence for dora indicators is White, Green, Red, Blue."]
]
|
.wall += ["0z", "0z", "0z", "0z"]
|
.set_definitions.baiban = ["0z", "0z", "0z"]
|
.set_definitions.baiban_pair = ["0z", "0z"]
|
.yaku |= map(
  if .display_name == "Shousangen" then
    .value = 1
    |
    .when[0].opts[1] = [[[["haku", "hatsu", "chun", "baiban"], 2], [["haku_pair", "hatsu_pair", "chun_pair", "baiban_pair"], 1]]]
  elif .display_name == "Honroutou" then
    .when[].opts += ["0z"]
  elif .display_name == "Honitsu" then
    .when[-1][].opts += ["0z"]
  else . end
)
|
.yaku += [
  {
    "display_name": "Hakuban",
    "value": 1,
    "when": [{"name": "match", "opts": [["hand", "calls", "winning_tile"], [[[["baiban"], 1]]]]}]
  },
  {
    "display_name": "Daisangen",
    "value": 2,
    "when": [{"name": "match", "opts": [["hand", "calls", "winning_tile"], [[[["haku", "hatsu", "chun", "baiban"], 3]]]]}]
  }
]
|
.yakuman |= map(
  if .display_name == "Daisangen" then
    .display_name = "Shousuugen"
    |
    .when[0].opts[1] = [[[["haku", "hatsu", "chun", "baiban"], 3], [["haku_pair", "hatsu_pair", "chun_pair", "baiban_pair"], 1]]]
  else . end
)
|
.yakuman += [
  {
    "display_name": "Daisuugen",
    "value": 2,
    "when": [{"name": "match", "opts": [["hand", "calls", "winning_tile"], [[[["haku", "hatsu", "chun", "baiban"], 4]]]]}]
  }
]
|
.yaku_precedence += {
  "Daisangen": ["Shousangen"],
  "Daisuugen": ["Shousuugen"]
}
|
# add dora indicators
.dora_indicators += {
  "0z": ["5z"],
  "7z": ["0z"],
  "07z": ["0z"],
  "17z": ["0z"],
  "27z": ["0z"],
  "37z": ["0z"]
}
