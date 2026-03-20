.wall += ["18j"]
|
.after_start.actions += [["set_tile_alias_all", ["18j"], ["1m","2m","3m","4m","5m","6m","7m","8m","9m"]]]
|
.custom_style.tile_indices += {"18j": "Manzu"}
|
if any(.wall[]; . == "10m") then
  .after_start.actions += [["set_tile_alias_all", ["18j"], ["10m"]]]
end
|
.after_initialization.actions += [
  ["add_rule", "Tiles", "Jokers", "- One %{18j} joker is added to the wall. This joker acts as any manzu tile.", {"18j": ["18j"]}, -99]
]
