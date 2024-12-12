.buttons.chankan.actions = [["set_status", "chankan"]] + .buttons.chankan.actions
|
.buttons.chanfuun.actions = [["set_status", "chanfuun"]] + .buttons.chankan.actions
|
.yaku |= map(if .display_name == "Chankan" then .when += [{"name": "status", "opts": ["chankan"]}] else . end)
|
.yaku += [{ "display_name": "Chanfuun", "value": 1, "when": ["won_by_call", {"name": "status", "opts": ["chanfuun"]}] }]
