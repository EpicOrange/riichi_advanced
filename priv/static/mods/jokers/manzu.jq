.wall += ["18j"]
|
.after_start.actions += [["set_tile_alias_all", ["18j"], ["1m","2m","3m","4m","5m","6m","7m","8m","9m"]]]
|
if any(.wall[]; . == "10m") then
  .after_start.actions += [["set_tile_alias_all", ["18j"], ["10m"]]]
end
