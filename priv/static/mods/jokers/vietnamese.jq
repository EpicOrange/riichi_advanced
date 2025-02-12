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
