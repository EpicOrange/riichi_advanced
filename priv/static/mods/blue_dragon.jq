.wall += ["0z", "0z", "0z", "0z"]
|
.set_definitions.baiban = ["0z", "0z", "0z"]
|
.set_definitions.baiban_pair = ["0z", "0z"]
|
.yaku |= map(
  if .display_name == "Chanta" then
    .when[-1].opts[1][0][0][0] += ["baiban"]
    |
    .when[-1].opts[1][0][1][0] += ["baiban_pair"]
  elif .display_name == "Shousangen" then
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
.yaku_precedence["Daisangen"] = ["Shousangen"]
|
.yaku_precedence["Daisuugen"] = ["Shousuugen"]
