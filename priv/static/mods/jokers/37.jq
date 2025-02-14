.wall += ["37j"]
|
.after_start.actions += [["set_tile_alias_all", ["37j"], ["3m", "7m", "3p", "7p", "3s", "7s"]]]
|
if any(.wall[]; . == "3t") then
  .after_start.actions += [["set_tile_alias_all", ["37j"], ["3t", "7t"]]]
end
