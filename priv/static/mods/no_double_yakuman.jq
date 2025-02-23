.after_initialization.actions += [["add_rule", "No Double Yakuman", "Although yakuman can still stack, all yakuman are worth single yakuman each. For example, daisangen tsuuiisou is still double yakuman, but suuankou tanki is only worth a single yakuman."]]
|
if has("yakuman") then .yakuman |= map(.value |= 1) else . end
|
if has("meta_yakuman") then .meta_yakuman |= map(.value |= 1) else . end
