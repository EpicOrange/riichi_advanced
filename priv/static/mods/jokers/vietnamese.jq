(if any(.wall[]; . == "0z") then "0z" else "5z" end) as $white
|
.wall += ["0j", "2j", "3j", "4j", "5j", "6j", "7j", "8j"]
|
.after_start.actions += [
  ["set_tile_alias_all", ["0j"], ["any"]],
  ["set_tile_alias_all", ["2j"], ["1m","2m","3m","4m","5m","6m","7m","8m","9m","1p","2p","3p","4p","5p","6p","7p","8p","9p","1s","2s","3s","4s","5s","6s","7s","8s","9s"]],
  ["set_tile_alias_all", ["3j"], ["1z","2z","3z","4z",$white,"6z","7z"]],
  ["set_tile_alias_all", ["4j"], [$white,"6z","7z"]],
  ["set_tile_alias_all", ["5j"], ["1z","2z","3z","4z"]],
  ["set_tile_alias_all", ["6j"], ["1p","2p","3p","4p","5p","6p","7p","8p","9p"]],
  ["set_tile_alias_all", ["7j"], ["1s","2s","3s","4s","5s","6s","7s","8s","9s"]],
  ["set_tile_alias_all", ["8j"], ["1m","2m","3m","4m","5m","6m","7m","8m","9m"]]
]
|
# ten mod
if any(.wall[]; . == "10m") then
  .after_start.actions += [
    ["set_tile_alias_all", ["2j"], ["10m", "10p", "10s"]],
    ["set_tile_alias_all", ["6j"], ["10p"]],
    ["set_tile_alias_all", ["7j"], ["10s"]],
    ["set_tile_alias_all", ["8j"], ["10m"]]
  ]
end
|
# star suit
if any(.wall[]; . == "1t") then
  .after_start.actions += [
    ["set_tile_alias_all", ["2j"], ["1t","2t","3t","4t","5t","6t","7t","8t","9t"]]
  ]
end
|
# star suit + ten mod
if any(.wall[]; . == "10t") then
  .after_start.actions += [
    ["set_tile_alias_all", ["2j"], ["10t"]]
  ]
end
|
# blue dragon mod
if (any(.wall[]; . == "0z") and any(.wall[]; . == "5z")) then
  .after_start.actions += [
    ["set_tile_alias_all", ["3j"], ["1z","2z","3z","4z","0z","5z","6z","7z"]],
    ["set_tile_alias_all", ["4j"], ["0z","5z","6z","7z"]]
  ]
end
|
.custom_style.tile_indices += {
  "0j": "Any",
  "2j": "Number",
  "3j": "Honour",
  "4j": "Dragon",
  "5j": "Wind",
  "6j": "Pinzu",
  "7j": "Souzu",
  "8j": "Manzu"
}
|
.after_initialization.actions += [
  ["add_rule", "Tiles", "Jokers", "- One %{0j} joker is added to the wall. This joker acts as any tile.", {"0j": ["0j"]}, -99],
  ["add_rule", "Tiles", "Jokers", "- One %{2j} joker is added to the wall. This joker acts as any numbered tile.", {"2j": ["2j"]}, -99],
  ["add_rule", "Tiles", "Jokers", "- One %{3j} joker is added to the wall. This joker acts as any honour tile.", {"3j": ["3j"]}, -99],
  ["add_rule", "Tiles", "Jokers", "- One %{4j} joker is added to the wall. This joker acts as any dragon tile.", {"4j": ["4j"]}, -99],
  ["add_rule", "Tiles", "Jokers", "- One %{5j} joker is added to the wall. This joker acts as any wind tile.", {"5j": ["5j"]}, -99],
  ["add_rule", "Tiles", "Jokers", "- One %{6j} joker is added to the wall. This joker acts as any pinzu tile.", {"6j": ["6j"]}, -99],
  ["add_rule", "Tiles", "Jokers", "- One %{7j} joker is added to the wall. This joker acts as any souzu tile.", {"7j": ["7j"]}, -99],
  ["add_rule", "Tiles", "Jokers", "- One %{8j} joker is added to the wall. This joker acts as any manzu tile.", {"8j": ["8j"]}, -99]
]


