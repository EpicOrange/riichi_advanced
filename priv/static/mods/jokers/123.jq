.wall += ["123j"]
|
.after_start.actions += [["set_tile_alias_all", ["123j"], ["1m", "2m", "3m", "1p", "2p", "3p", "1s", "2s", "3s"]]]
|
.dora_indicators["123j"] += ["2m", "3m", "4m", "2p", "3p", "4p", "2s", "3s", "4s"]
|
if any(.wall[]; . == "1t") then
  .after_start.actions += [["set_tile_alias_all", ["123j"], ["1t", "2t", "3t"]]]
  |
  .dora_indicators["123j"] += ["2t", "3t", "4t"]
end
