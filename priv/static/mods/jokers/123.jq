.wall += ["123j"]
|
.after_start.actions += [["set_tile_alias_all", ["123j"], ["1m", "2m", "3m", "1p", "2p", "3p", "1s", "2s", "3s"]]]
|
if any(.wall[]; . == "1t") then
  .after_start.actions += [["set_tile_alias_all", ["123j"], ["1t", "2t", "3t"]]]
end
