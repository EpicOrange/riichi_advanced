.wall += ["147j"]
|
.after_start.actions += [["set_tile_alias_all", ["147j"], ["1m", "4m", "7m", "1p", "4p", "7p", "1s", "4s", "7s"]]]
|
.dora_indicators["147j"] += ["2m", "5m", "8m", "2p", "5p", "8p", "2s", "5s", "8s"]
|
if any(.wall[]; . == "1t") then
  .after_start.actions += [["set_tile_alias_all", ["147j"], ["1t", "4t", "7t"]]]
  |
  .dora_indicators["147j"] += ["2t", "5t", "8t"]
end
