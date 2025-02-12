.wall += ["19j"]
|
.after_start.actions += [["set_tile_alias_all", ["19j"], ["1m", "9m", "1p", "9p", "1s", "9s"]]]
|
if any(.wall[]; . == "1t") then
  .after_start.actions += [["set_tile_alias_all", ["19j"], ["1t", "9t"]]]
end
