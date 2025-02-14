.wall += ["369j"]
|
.after_start.actions += [["set_tile_alias_all", ["369j"], ["3m", "6m", "9m", "3p", "6p", "9p", "3s", "6s", "9s"]]]
|
if any(.wall[]; . == "3t") then
  .after_start.actions += [["set_tile_alias_all", ["369j"], ["3t", "6t", "9t"]]]
end
