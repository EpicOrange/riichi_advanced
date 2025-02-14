.wall += ["147j"]
|
.after_start.actions += [["set_tile_alias_all", ["147j"], ["1m", "4m", "7m", "1p", "4p", "7p", "1s", "4s", "7s"]]]
|
if any(.wall[]; . == "1t") then
  .after_start.actions += [["set_tile_alias_all", ["147j"], ["1t", "4t", "7t"]]]
end
