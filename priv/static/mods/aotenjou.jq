.after_initialization.actions += [["add_rule", "Rules", "Aotenjou", "Limit hands are removed. Scores are calculated with the standard han-fu formula: a standard nondealer ron is worth 4 * fu * 2^(2+han), rounded up to the nearest \(.score_calculation.han_fu_rounding_factor // 100)."]]
|
.score_calculation.limit_thresholds = []
|
.score_e_notation = true
|
# copy of yakuman_13_han mod
.yakuman |= map(.value *= 13)
|
.yaku += .yakuman
|
.yakuman = []
|
.meta_yakuman |= map(.value *= 13)
|
.meta_yaku += .meta_yakuman
|
.meta_yakuman = []
