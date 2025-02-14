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
.score_calculation.enable_kontsu_fu = true
|
.tenpai_definition |= fix_match_definition
|
.tenpai_14_definition |= fix_match_definition
|
.win_definition |= fix_match_definition
|
.standard_win_definition |= fix_match_definition
|
.yaku |= fix_yaku
|
.yakuman |= fix_yaku
|
.meta_yaku |= fix_yaku
|
.meta_yakuman |= fix_yaku
|
.sanankou_tsumo_definition |= fix_match_definition
|
.sanankou_ron_definition |= fix_match_definition
|
# this makes the win screen take kontsu out of the hand before displaying
.score_calculation.arrange_kontsu = true
