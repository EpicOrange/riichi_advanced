.wall += ["17j"]
|
.after_start.actions += [["set_tile_alias_all", ["17j"], ["1s","2s","3s","4s","5s","6s","7s","8s","9s"]]]
|
.custom_style.tile_indices += {"17j": "Souzu"}
|
if any(.wall[]; . == "10s") then
  .after_start.actions += [["set_tile_alias_all", ["17j"], ["10s"]]]
end
|
.after_initialization.actions += [
  ["add_rule", "Tiles", "Jokers", "- One %{17j} joker is added to the wall. This joker acts as any souzu tile.", {"17j": ["17j"]}, -99]
]
