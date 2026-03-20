.wall += ["16j"]
|
.after_start.actions += [["set_tile_alias_all", ["16j"], ["1p","2p","3p","4p","5p","6p","7p","8p","9p"]]]
|
.custom_style.tile_indices += {"16j": "Pinzu"}
|
if any(.wall[]; . == "10p") then
  .after_start.actions += [["set_tile_alias_all", ["16j"], ["10p"]]]
end
|
.after_initialization.actions += [
  ["add_rule", "Tiles", "Jokers", "- One %{16j} joker is added to the wall. This joker acts as any pinzu tile.", {"16j": ["16j"]}, -99]
]
