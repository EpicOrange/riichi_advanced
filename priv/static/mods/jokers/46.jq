.wall += ["46j"]
|
.after_start.actions += [["set_tile_alias_all", ["46j"], ["4m", "6m", "4p", "6p", "4s", "6s"]]]
|
.custom_style.tile_indices += {"46j": "46"}
|
.dora_indicators["46j"] += ["5m", "7m", "5p", "7p", "5s", "7s"]
|
if any(.wall[]; . == "4t") then
  .after_start.actions += [["set_tile_alias_all", ["46j"], ["4t", "6t"]]]
  |
  .dora_indicators["46j"] += ["5t", "7t"]
end
|
.after_initialization.actions += [
  ["add_rule", "Tiles", "Jokers", "- One %{46j} joker is added to the wall. This joker acts as any tile numbered 4 or 6.", {"46j": ["46j"]}, -99]
]