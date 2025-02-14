.wall += ["16j"]
|
.after_start.actions += [["set_tile_alias_all", ["16j"], ["1p","2p","3p","4p","5p","6p","7p","8p","9p"]]]
|
if any(.wall[]; . == "10p") then
  .after_start.actions += [["set_tile_alias_all", ["16j"], ["10p"]]]
end
