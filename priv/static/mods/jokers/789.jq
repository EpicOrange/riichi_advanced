.wall += ["789j"]
|
.after_start.actions += [["set_tile_alias_all", ["789j"], ["7m", "8m", "9m", "7p", "8p", "9p", "7s", "8s", "9s"]]]
|
if any(.wall[]; . == "7t") then
  .after_start.actions += [["set_tile_alias_all", ["789j"], ["7t", "8t", "9t"]]]
end
