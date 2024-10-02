# Require no calls for tanyao
.yaku |= map(if .display_name == "Tanyao" then .when += [{"name": "has_no_call_named", "opts": ["chii", "pon", "daiminkan", "kakan"]}] else . end)
