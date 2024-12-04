def nine_to_ten:
  if type == "array" then
    map(nine_to_ten)
  elif type == "string" then
    if . == "9m" then "10m"
    elif . == "9p" then "10p"
    elif . == "9s" then "10s"
    else . end
  else
    .
  end;

# add the ten tiles
.wall += [
  "10m", "10m", "10m", "10m",
  "10p", "10p", "10p", "10p",
  "10s", "10s", "10s", "10s"
]
|
# add ten
.after_start.actions += [
  ["set_tile_ordering", ["9m", "10m"]],
  ["set_tile_ordering", ["9p", "10p"]],
  ["set_tile_ordering", ["9s", "10s"]]
]
|
# expand dora indicator map, if it exists
if .dora_indicators then
  .dora_indicators += {
    "9m": ["10m"],
    "9p": ["10p"],
    "9s": ["10s"],
    "10m": ["1m"],
    "10p": ["1p"],
    "10s": ["1s"]
  }
else . end
|
# change chanta and junchan requirements
.set_definitions += {
  "junchan_7": ["8m","9m","10m"],
  "junchan_8": ["8p","9p","10p"],
  "junchan_9": ["8s","9s","10s"],
  "junchan_10": ["10m","10m","10m"],
  "junchan_11": ["10p","10p","10p"],
  "junchan_12": ["10s","10s","10s"],
  "junchan_pair_1": ["1m","1m"],
  "junchan_pair_2": ["1p","1p"],
  "junchan_pair_3": ["1s","1s"],
  "junchan_pair_4": ["10m","10m"],
  "junchan_pair_5": ["10p","10p"],
  "junchan_pair_6": ["10s","10s"]
}
|
# change tanyao, honroutou, honitsu, chinitsu
.yaku |= map(
  if .display_name == "Tanyao" then
    .when[0].opts += ["9m","9p","9s"]
  elif .display_name == "Honroutou" then
    .when[0].opts |= nine_to_ten
  elif .display_name == "Honitsu" or .display_name == "Chinitsu" then
    .when[-1][0].opts += ["10m"] | .when[-1][1].opts += ["10p"] | .when[-1][2].opts += ["10s"]
  else . end
)
|
# change chinroutou
if has("yakuman") then
  .yakuman |= map(
    if .display_name == "Chinroutou" then
      .when[0].opts |= nine_to_ten
    else . end
  )
else . end
|
# change 13 orphans to require the ten tiles
.set_definitions.orphans_all |= nine_to_ten
|
.kokushi_tenpai_definition |= nine_to_ten
|
.win_definition |= nine_to_ten
