.wall += ["456j"]
|
.after_start.actions += [["set_tile_alias_all", ["456j"], ["4m", "5m", "6m", "4p", "5p", "6p", "4s", "5s", "6s"]]]
|
.custom_style.tile_indices += {"456j": "456"}
|
.dora_indicators["456j"] += ["5m", "6m", "7m", "5p", "6p", "7p", "5s", "6s", "7s"]
|
if any(.wall[]; . == "4t") then
  .after_start.actions += [["set_tile_alias_all", ["456j"], ["4t", "5t", "6t"]]]
  |
  .dora_indicators["456j"] += ["5t", "6t", "7t"]
end
|
.after_initialization.actions += [
  ["add_rule", "Tiles", "Jokers", "- One %{456j} joker is added to the wall. This joker acts as any tile numbered 4, 5, or 6.", {"456j": ["456j"]}, -99]
]
