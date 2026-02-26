.after_initialization.actions += [
  ["add_rule", "Rules", "Wall", "(Golden Chun) One of the green dragons is red and acts as aka dora."],
  ["add_rule", "Rules", "Wall", "(Golden Chun) One of the red dragons is the golden chun, which can be used as a five of any suit, and grants 1 extra han when used as a five."],
  ["add_rule", "Yakuman", "Unnamed Golden Chun Yakuman", "(Golden Chun) Completing a hand via shiro pocchi while using the golden chun as a five and having the aka green dragon scores yakuman."],
  ["update_rule", "Yakuman", "Unnamed Golden Chun Yakuman", "%{example_hand}", {"example_hand": ["6m", "7m", "8m", "2p", "2p", "2p", "3s", "4s", "37z", "5s", "6s", "6z", "06z", "3x", "9z"]}],
  ["update_rule", "Rules", "Shuugi", "(Golden Chun) Each golden chun used as a five is worth 1 shuugi."]
]
|
# replace a 6z with red hatsu
(.wall | index("6z")) as $idx | if $idx then .wall[$idx] = "06z" else . end
|
# replace a 7z with golden chun
(.wall | index("7z")) as $idx | if $idx then .wall[$idx] = "37z" else . end
|
# treat red hatsu as 6z
.after_start.actions += [
  ["set_tile_alias_all", ["06z"], ["6z"]]
]
|
# treat golden chun as 5 wildcard or chun
# support for star suit mod
if any(.wall[]; . == "1t") then
  .after_start.actions += [
      # we can use the "_golden" attribute to keep track of when the golden chun is used as a five
    ["set_tile_alias_all", ["37z"], [["5m", "_golden"], ["5p", "_golden"], ["5s", "_golden"], ["5t", "_golden"], "7z"]]
  ]
else
  .after_start.actions += [
    ["set_tile_alias_all", ["37z"], [["5m", "_golden"], ["5p", "_golden"], ["5s", "_golden"], "7z"]]
  ]
end
|
# add aka and golden chun yaku
.extra_yaku += [
  {"display_name": "Kin", "value": "golden_chuns", "when": [{"name": "counter_at_least", "opts": ["golden_chuns", 1]}]}
]
|
# add akahatsu to counter. add aka_h status
.before_win.actions += [
  ["add_counter", "aka", "count_matches", ["hand", "calls", "winning_tile"], [["nojoker", [["06z"], 1] ]]],
  ["when", [{"name": "match", "opts": [["hand", "calls", "winning_tile"], [["nojoker", [["06z"], 1] ]]]}], [["set_status", "aka_h"]]]      
]
|
# add golden chun status
.before_scoring.actions += [
  ["add_counter", "golden_chuns", "count_matches", ["hand", "calls", "winning_tile"], [[[[{"tile": "any", "attrs": ["golden"]}], 1]]]],
  ["when", [{"name": "match", "opts": [["hand", "calls", "winning_tile"], [[[[{"tile": "any", "attrs": ["golden"]}], 1]]]]}], [["set_status", "golden_chun"]]]
]
|
# add sangen pocchi yakuman
.yakuman += [
  {"display_name": "Sangen Pocchi", "value": 1, "when": [{"name": "status", "opts": ["shiro_pocchi", "aka_h", "golden_chun"]}]}
]
|
# can't call golden chun unless as a chun
if (.buttons | has("chii")) then
  .buttons.chii.call_conditions += [[
    {"name": "not_call_contains", "opts": [["37z"], 1]},
    {"name": "call_contains", "opts": [["7z"], 1]}
  ]]
else . end
|
if (.buttons | has("pon")) then
  .buttons.pon.call_conditions += [[
    {"name": "not_call_contains", "opts": [["37z"], 1]},
    {"name": "call_contains", "opts": [["7z"], 1]}
  ]]
else . end
|
if (.buttons | has("daiminkan")) then
  .buttons.daiminkan.call_conditions += [[
    {"name": "not_call_contains", "opts": [["37z"], 1]},
    {"name": "call_contains", "opts": [["7z"], 1]}
  ]]
else . end
|
if (.buttons | has("kakan")) then
  .buttons.kakan.call_conditions += [[
    {"name": "not_call_contains", "opts": [["37z"], 1]},
    {"name": "call_contains", "opts": [["7z"], 1]}
  ]]
else . end
|
if (.buttons | has("ankan")) then
  .buttons.ankan.call_conditions += [[
    {"name": "not_call_contains", "opts": [["37z"], 1]},
    {"name": "call_contains", "opts": [["7z"], 1]}
  ]]
else . end
|
# add dora indicators
.dora_indicators += {
  "06z": ["7z"],
  "37z": ["5z"]
}