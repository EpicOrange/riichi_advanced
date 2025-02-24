.wall += ["19j"]
|
.after_start.actions += [["set_tile_alias_all", ["19j"], ["1m", "9m", "1p", "9p", "1s", "9s"]]]
|
# TODO support ten mod
.dora_indicators["19j"] += ["2m", "1m", "2p", "1p", "2s", "1s"]
|
if any(.wall[]; . == "1t") then
  .after_start.actions += [["set_tile_alias_all", ["19j"], ["1t", "9t"]]]
  |
  .dora_indicators["19j"] += ["2t", "1t"]
end
