.after_initialization.actions += [["add_rule", "Rules", "Aotenjou", "Limit hands are removed. Scores are calculated with the standard han-fu formula: a standard nondealer ron is worth 4 * fu * 2^(2+han), rounded up to the nearest \(.score_calculation.han_fu_rounding_factor // 100)."]]
|
.score_calculation.limit_thresholds = []
|
.score_e_notation = true
|
# copy of yakuman_13_han mod
if has("yakuman") then
  .yakuman |= map(if .value | type == "number" then .value *= 13 else .value = [.value[0] * 13, "Han"] end)
  |
  .yaku += .yakuman
  |
  .yakuman = []
else . end
|
if has("meta_yakuman") then
  .meta_yakuman |= map(if .value | type == "number" then .value *= 13 else .value = [.value[0] * 13, "Han"] end)
  |
  .meta_yaku += .meta_yakuman
  |
  .meta_yakuman = []
else . end
