.available_presets |= map(if .display_name == "Mahjong Soul" then
  .enabled_mods |= map(if type == "object" and .name == "aka" then
    .config.man = 0
  elif type == "object" and .name == "uma" then
    .config = {"_1st": 15, "_2nd": 0, "_3rd": -15, "_4th": 0}
  elif type == "object" and .name == "sudden_death" then
    .config.goal = 40000
  else . end)
elif .display_name == "tenhou.net" then
  .enabled_mods |= map(if type == "object" and .name == "aka" then
    .config.man = 0
  elif type == "object" and .name == "uma" then
    .config = {"_1st": 20, "_2nd": 0, "_3rd": -20, "_4th": 0}
  elif type == "object" and .name == "sudden_death" then
    .config.goal = 40000
  else . end)
elif .display_name == "Riichi City" then
  .enabled_mods |= map(if type == "object" and .name == "aka" then
    .config.man = 0
  elif type == "object" and .name == "uma" then
    .config = {"_1st": 20, "_2nd": 0, "_3rd": -20, "_4th": 0}
  elif type == "object" and .name == "sudden_death" then
    .config.goal = 40000
  else . end)
else . end)
