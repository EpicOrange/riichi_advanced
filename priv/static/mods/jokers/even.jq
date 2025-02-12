.wall += ["22j"]
|
.after_start.actions += [["set_tile_alias_all", ["22j"], ["2m", "4m", "6m", "8m", "2p", "4p", "6p", "8p", "2s", "4s", "6s", "8s"]]]
|
if any(.wall[]; . == "2t") then
  .after_start.actions += [["set_tile_alias_all", ["22j"], ["2t", "4t", "6t", "8t"]]]
end
|
if any(.wall[]; . == "10m") then
  .after_start.actions += [["set_tile_alias_all", ["22j"], ["10m", "10p", "10s"]]]
end
|
if any(.wall[]; . == "10t") then
  .after_start.actions += [["set_tile_alias_all", ["22j"], ["10t"]]]
end
