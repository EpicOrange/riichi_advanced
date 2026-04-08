.wall += ["123j"]
|
.after_start.actions += [["set_tile_alias_all", ["123j"], ["1m", "2m", "3m", "1p", "2p", "3p", "1s", "2s", "3s"]]]
|
.custom_style.tile_indices += {"123j": "123"}
|
.dora_indicators["123j"] += ["2m", "3m", "4m", "2p", "3p", "4p", "2s", "3s", "4s"]
|
if any(.wall[]; . == "1t") then
  .after_start.actions += [["set_tile_alias_all", ["123j"], ["1t", "2t", "3t"]]]
  |
  .dora_indicators["123j"] += ["2t", "3t", "4t"]
end
|
.after_initialization.actions += [
  ["add_rule", "Tiles", "Jokers", "- One %{123j} joker is added to the wall. This joker acts as any tile numbered 1, 2, or 3.", {"123j": ["123j"]}, -99]
]
