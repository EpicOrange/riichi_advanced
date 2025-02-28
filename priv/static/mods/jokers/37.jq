.wall += ["37j"]
|
.after_start.actions += [["set_tile_alias_all", ["37j"], ["3m", "7m", "3p", "7p", "3s", "7s"]]]
|
.dora_indicators["37j"] += ["4m", "8m", "4p", "8p", "4s", "8s"]
|
if any(.wall[]; . == "3t") then
  .after_start.actions += [["set_tile_alias_all", ["37j"], ["3t", "7t"]]]
  |
  .dora_indicators["37j"] += ["4t", "8t"]
end
