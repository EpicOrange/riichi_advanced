.wall += ["456j"]
|
.after_start.actions += [["set_tile_alias_all", ["456j"], ["4m", "5m", "6m", "4p", "5p", "6p", "4s", "5s", "6s"]]]
|
if any(.wall[]; . == "4t") then
  .after_start.actions += [["set_tile_alias_all", ["456j"], ["4t", "5t", "6t"]]]
end
