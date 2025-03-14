.after_initialization.actions += [
  ["add_rule", "Rules", "Wall", "(Shiro Pocchi) One of the white dragons is replaced with shiro pocchi, which looks like a compass. Shiro pocchi acts a joker tile when drawn while in riichi.", -99],
  ["update_rule", "Rules", "Shuugi", "(Shiro Pocchi) Winning in riichi via shiro pocchi is worth 1 shuugi."]
]
|
# replace a 5z with shiro pocchi
(.wall | index("5z")) as $idx | if $idx then .wall[$idx] = "9z" else . end
|
# treat shiro pocchi as 5z
.after_start.actions += [
  ["set_tile_alias_all", ["9z"], ["5z"]]
]
|
[
  "1m", "2m", "3m", "4m", "5m", "6m", "7m", "8m", "9m",
  "1p", "2p", "3p", "4p", "5p", "6p", "7p", "8p", "9p",
  "1s", "2s", "3s", "4s", "5s", "6s", "7s", "8s", "9s",
  "1z", "2z", "3z", "4z", "5z", "6z", "7z"
] as $tiles
|
# support ten
(if any(.wall[]; . == "10m") then $tiles + ["10m", "10p", "10s"] else $tiles end) as $all_tiles
|
# when drawing shiro pocchi in riichi, it becomes a wildcard
.after_turn_change.actions += [
  ["when", [
    {"name": "status", "opts": ["riichi"]},
    {"name": "match", "opts": [["draw"], [[[["9z"], 1]]]]}
  ], [["set_status", "shiro_pocchi"], ["set_tile_alias", ["9z"], $all_tiles]]]
]
|
# remove shiro pocchi status on turn change
.before_turn_change.actions += [
  ["unset_status", "shiro_pocchi"]
]
|
# add dora indicators
.dora_indicators += {
  "9z": ["6z"]
}
