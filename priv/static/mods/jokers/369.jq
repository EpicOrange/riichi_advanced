.wall += ["369j"]
|
.after_start.actions += [["set_tile_alias_all", ["369j"], ["3m", "6m", "9m", "3p", "6p", "9p", "3s", "6s", "9s"]]]
|
# TODO support ten mod
.dora_indicators["369j"] += ["4m", "7m", "1m", "4p", "7p", "1p", "4s", "7s", "1s"]
|
if any(.wall[]; . == "3t") then
  .after_start.actions += [["set_tile_alias_all", ["369j"], ["3t", "6t", "9t"]]]
  |
  .dora_indicators["369j"] += ["4t", "7t", "1t"]
end
