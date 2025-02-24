.wall += ["789j"]
|
.after_start.actions += [["set_tile_alias_all", ["789j"], ["7m", "8m", "9m", "7p", "8p", "9p", "7s", "8s", "9s"]]]
|
# TODO support ten mod
.dora_indicators["789j"] += ["8m", "9m", "1m", "8p", "9p", "1p", "8s", "9s", "1s"]
|
if any(.wall[]; . == "7t") then
  .after_start.actions += [["set_tile_alias_all", ["789j"], ["7t", "8t", "9t"]]]
  |
  .dora_indicators["789j"] += ["8t", "9t", "1t"]
end
