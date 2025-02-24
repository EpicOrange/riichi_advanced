.wall += ["258j"]
|
.after_start.actions += [["set_tile_alias_all", ["258j"], ["2m", "5m", "8m", "2p", "5p", "8p", "2s", "5s", "8s"]]]
|
.dora_indicators["258j"] += ["3m", "6m", "9m", "3p", "6p", "9p", "3s", "6s", "9s"]
|
if any(.wall[]; . == "2t") then
  .after_start.actions += [["set_tile_alias_all", ["258j"], ["2t", "5t", "8t"]]]
  |
  .dora_indicators["258j"] += ["3t", "6t", "9t"]
end
