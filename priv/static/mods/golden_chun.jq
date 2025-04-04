.after_initialization.actions += [
  ["add_rule", "Rules", "Wall", "(Golden Chun) One of the green dragons is red and acts as aka dora."],
  ["add_rule", "Rules", "Wall", "(Golden Chun) One of the red dragons is the golden chun, which can be used as a five of any suit, and grants 1 extra han when used as a five."],
  ["add_rule", "Rules", "Local Yaku (Yakuman)", "(Golden Chun) Completing a hand via shiro pocchi while using the golden chun as a five and having the aka green dragon scores yakuman."],
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
    ["set_tile_alias_all", ["37z"], ["5m", "5p", "5s", "5t", "7z"]]
  ]
else
  .after_start.actions += [
    ["set_tile_alias_all", ["37z"], ["5m", "5p", "5s", "7z"]]
  ]
end
# add golden chun definition for when it's used as a five
|
.golden_chun_77z_win_definition = [
  [ "exhaustive", [["chun_pair"], 1], [["shuntsu", "koutsu"], 4] ],
  [ [["chun_pair"], 1], [["pair"], 6] ]
]
|
.golden_chun_777z_win_definition = [
  [ "debug", "exhaustive", [["chun"], 1], [["pair"], 1], [["shuntsu", "koutsu"], 3] ]
]
|
# add aka and golden chun yaku
.extra_yaku += [
  {"display_name": "Kin", "value": 1, "when": [
    {"name": "status", "opts": ["golden_chun"]},
    [
      {"name": "status_missing", "opts": ["7z"]},
      [
        {"name": "status", "opts": ["77z"]},
        {"name": "match", "opts": [["hand", "calls", "winning_tile"], ["golden_chun_77z_win"]]}
      ],
      [
        {"name": "status", "opts": ["777z"]},
        {"name": "match", "opts": [["hand", "calls", "winning_tile"], ["golden_chun_777z_win"]]}
      ]
    ]
  ]}
]
|
# count aka and add golden chun statuses
.before_win.actions += [
  ["when", [{"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ "nojoker", [["06z"], 1] ]]]}], [["add_counter", "aka", 1]]],
  ["when", [{"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ "nojoker", [["37z"], 1] ]]]}], [["set_status", "golden_chun"]]],
  ["when", [{"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ "nojoker", [["37z"], 1], [["7z"], 1] ]]]}], [["set_status", "7z"]]],
  ["when", [{"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ "nojoker", [["37z"], 1], [["chun_pair"], 1] ]]]}], [["set_status", "77z"]]],
  ["when", [{"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ "nojoker", [["37z"], 1], [["chun"], 1] ]]]}], [["set_status", "777z"]]]
]
|
.after_win.actions += [
  ["when", [
    {"name": "status", "opts": ["golden_chun"]},
    [
      {"name": "status_missing", "opts": ["7z"]},
      [
        {"name": "status", "opts": ["77z"]},
        {"name": "match", "opts": [["assigned_hand", "assigned_calls", "winning_tile"], ["golden_chun_77z_win"]]}
      ],
      [
        {"name": "status", "opts": ["777z"]},
        {"name": "match", "opts": [["assigned_hand", "assigned_calls", "winning_tile"], ["golden_chun_777z_win"]]}
      ]
    ]
  ], [["set_status", "kindora"]]]
]
|
# add golden chun yakuman
.yakuman += [
  {"display_name": "Sangen Pocchi", "value": 1, "when": [{"name": "status", "opts": ["shiro_pocchi", "aka_h", "kindora"]}]}
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
