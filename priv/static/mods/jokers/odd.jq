.wall += ["11j"]
|
.after_start.actions += [["set_tile_alias_all", ["11j"], ["1m", "3m", "5m", "7m", "9m", "1p", "3p", "5p", "7p", "9p", "1s", "3s", "5s", "7s", "9s"]]]
|
.custom_style.tile_indices += {"11j": "Odd"}
|
if any(.wall[]; . == "1t") then
  .after_start.actions += [["set_tile_alias_all", ["11j"], ["1t", "3t", "5t", "7t", "9t"]]]
end
