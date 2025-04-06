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

.after_initialization.actions += [["add_rule", "Rules", "Wall", "(Ten) Every suit runs from 1 to 10.", -99]]
|
.wall |= nine_to_ten
|
# re-add the same number of nine tiles as there are two tiles
# (this is to accommodate sanma)
.wall |= . + map(select(. == "2m") | "9m")
|
.wall |= . + map(select(. == "2p") | "9p")
|
.wall |= . + map(select(. == "2s") | "9s")
|
# add ten ordering
.after_start.actions += [
  # check for space mahjong to see if we need to connect 10 to 1
  ["when", [{"name": "match", "opts": [["1m", "9m"], [[[[[0, 1]], 1]]]]}], [
    ["set_tile_ordering_all", ["10m", "1m"]],
    ["set_tile_ordering_all", ["10p", "1p"]],
    ["set_tile_ordering_all", ["10s", "1s"]]
  ]],
  # after that we can replace 9 to connect to 10
  ["set_tile_ordering_all", ["9m", "10m"]],
  ["set_tile_ordering_all", ["9p", "10p"]],
  ["set_tile_ordering_all", ["9s", "10s"]]
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
  |
  .dora_indicators |= if .["1m"] == ["9m"] then
    .["1m"] = ["10m"]
  else . end
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
  elif .display_name == "Honitsu" or .display_name == "Chinitsu" or .display_name == "Half Flush" or .display_name == "Full Flush" then
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
# for sichuan, need to add ten to voided definition
|
if has("manzu_definition") then
  .manzu_definition = [[[["1m","2m","3m","4m","5m","6m","7m","8m","9m","10m"], 1]]]
end
|
if has("pinzu_definition") then
  .pinzu_definition = [[[["1p","2p","3p","4p","5p","6p","7p","8p","9p","10p"], 1]]]
end
|
if has("souzu_definition") then
  .souzu_definition = [[[["1s","2s","3s","4s","5s","6s","7s","8s","9s","10s"], 1]]]
end
