def replace_group($from; $to):
  if type == "array" and .[0] == $from then .[0] = $to else . end;

def fix_match_definition:
  map(if type == "array" then
    map(
      replace_group(["ryanmen/penchan", "kanchan", "pair"]; ["ryanmen/penchan", "kanchan", "pair", "mixed_pair"])
      |
      replace_group(["shuntsu", "koutsu"]; ["shuntsu", "koutsu", "kontsu"])
      |
      replace_group(["shuntsu"]; ["shuntsu", "kontsu"])
      |
      if type == "array" and any(.[0][]; . == "junchan_1") then .[0] += ["junchan_kontsu_1", "junchan_kontsu_2"] else . end
    )
  else . end);

def fix_yaku:
  map(.when |= walk(
    if type == "object" and (.name == "match" or .name == "not_match") then .opts[1] |= fix_match_definition else . end
  ));

.set_definitions += {
  "mixed_pair": [0, 10],
  "kontsu": [0, 10, 20]
}
|
# update chanta and junchan
if any(.wall[]; . == "10m") then
  # ten mod
  .set_definitions += {
    "junchan_kontsu_1": ["1m","1p","1s"],
    "junchan_kontsu_2": ["10m","10p","10s"]
  }
else
  .set_definitions += {
    "junchan_kontsu_1": ["1m","1p","1s"],
    "junchan_kontsu_2": ["9m","9p","9s"]
  }
end
|
# add kontsu to fu calculation function
.functions.calculate_fu[0] |= map(
  if type == "array" and .[0] == "convert_calls" then
    .[1] += {
      "chon": 1,
      "kapon": 2,
      "kakakan": 8,
      "chon_honors": 1,
      "anfuun": 8,
      "daiminfuun": 4,
      "kafuun": 4
    }
  elif type == "array" and .[0] == "remove_winning_groups" then
    . += [{"group": [10, 20], "value": 1, "yaochuuhai_mult": 2, "tsumo_mult": 2}]
  elif type == "array" and .[0] == "remove_groups" and .[1].group == [0, 1, 2] then
    . += [
      {"group": [0, 10, 20], "value": 2, "yaochuuhai_mult": 2},
      {"group": [0, 1, 2], "value": 4, "suited_mult": 0}
    ]
  else . end
)
|
# ton calls should be put in hand before fu calculations
.functions.calculate_fu[0] |= .[:3] + [["put_calls_in_hand", "ton"]] + .[3:]
|
if has("tenpai_definition") then
  .tenpai_definition |= fix_match_definition
else . end
|
if has("tenpai_14_definition") then
  .tenpai_14_definition |= fix_match_definition
else . end
|
if has("win_definition") then
  .win_definition |= fix_match_definition
else . end
|
if has("standard_win_definition") then
  .standard_win_definition |= fix_match_definition
else . end
|
if has("yaku") then
  .yaku |= fix_yaku
else . end
|
if has("yakuman") then
  .yakuman |= fix_yaku
else . end
|
if has("meta_yaku") then
  .meta_yaku |= fix_yaku
else . end
|
if has("meta_yakuman") then
  .meta_yakuman |= fix_yaku
else . end
|
if has("sanankou_tsumo_definition") then
  .sanankou_tsumo_definition |= fix_match_definition
else . end
|
if has("sanankou_ron_definition") then
  .sanankou_ron_definition |= fix_match_definition
else . end
