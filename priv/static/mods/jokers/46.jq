.wall += ["46j"]
|
.after_start.actions += [["set_tile_alias_all", ["46j"], ["4m", "6m", "4p", "6p", "4s", "6s"]]]
|
.dora_indicators["46j"] += ["5m", "7m", "5p", "7p", "5s", "7s"]
|
if any(.wall[]; . == "4t") then
  .after_start.actions += [["set_tile_alias_all", ["46j"], ["4t", "6t"]]]
  |
  .dora_indicators["46j"] += ["5t", "7t"]
end
