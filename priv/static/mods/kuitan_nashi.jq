.after_initialization.actions += [["add_rule", "Rules", "Kuitan Nashi", "Open calls invalidate tanyao. (You can only get tanyao with a closed hand.)"]]
|
# Require no open calls for tanyao
.yaku |= map(if .display_name == "Tanyao" then .when += [{"name": "has_no_call_named", "opts": ["chii", "pon", "daiminkan", "kakan"]}] else . end)
