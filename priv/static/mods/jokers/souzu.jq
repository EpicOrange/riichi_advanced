.wall += ["17j"]
|
.after_start.actions += [["set_tile_alias_all", ["17j"], ["1s","2s","3s","4s","5s","6s","7s","8s","9s"]]]
|
if any(.wall[]; . == "10s") then
  .after_start.actions += [["set_tile_alias_all", ["17j"], ["10s"]]]
end
