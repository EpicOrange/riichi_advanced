def add_yaku_statuses($actions; $type):
  [
    ["when", [{"name": "match", "opts": [["hand", "calls", $type], [[[["26z"], 1]]]]}], [["set_status", "aka_h"]]],
    ["when", [{"name": "match", "opts": [["hand", "calls", $type], [[[["27z"], 1]]]]}], [["set_status", "golden_chun"]]],
    ["when", [{"name": "match", "opts": [["hand", "calls", $type], [[[["27z"], 1], [["7z"], 1]]]]}], [["set_status", "7z"]]],
    ["when", [{"name": "match", "opts": [["hand", "calls", $type], [[[["27z"], 1], [["chun_pair"], 1]]]]}], [["set_status", "77z"]]],
    ["when", [{"name": "match", "opts": [["hand", "calls", $type], [[[["27z"], 1], [["chun_pair"], -1], [["chun"], 1]]]]}], [["set_status", "777z"]]]
  ] + $actions;

# replace a 6z with red hatsu
(.wall | index("6z")) as $idx | if $idx then .wall[$idx] = "26z" else . end
|
# replace a 7z with golden chun
(.wall | index("7z")) as $idx | if $idx then .wall[$idx] = "27z" else . end
|
# treat red hatsu as 6z
.after_start.actions += [
  ["set_tile_alias_all", ["26z"], ["6z"]]
]
|
# treat golden chun as 5 wildcard or chun
# support for star suit mod
if any(.wall[]; . == "1t") then
  .after_start.actions += [
    ["set_tile_alias_all", ["27z"], ["5m", "5p", "5s", "5t", "7z"]]
  ]
else
  .after_start.actions += [
    ["set_tile_alias_all", ["27z"], ["5m", "5p", "5s", "7z"]]
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
  [ "exhaustive", [["chun"], 1], [["pair"], 1], [["shuntsu", "koutsu"], 3] ]
]
|
# add aka and golden chun yaku
.extra_yaku += [
  {"display_name": "Aka", "value": 1, "when": [{"name": "status", "opts": ["aka_h"]}]},
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
# set yaku statuses for red hatsu and golden chun
.buttons.ron.actions |= add_yaku_statuses(.; "last_discard")
|
.buttons.chankan.actions |= add_yaku_statuses(.; "last_called_tile")
|
.buttons.tsumo.actions |= add_yaku_statuses(.; "draw")
|
# add golden chun yakuman
.yakuman += [
  {"display_name": "Sangen Pocchi", "value": 1, "when": [
    {"name": "status", "opts": ["shiro_pocchi", "aka_h", "golden_chun"]},
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
# can't call golden chun
.buttons.chii.call_conditions += [
  {"name": "not_call_contains", "opts": [["27z"], 1]}
]
|
.buttons.pon.call_conditions += [
  {"name": "not_call_contains", "opts": [["27z"], 1]}
]
|
.buttons.daiminkan.call_conditions += [
  {"name": "not_call_contains", "opts": [["27z"], 1]}
]
|
.buttons.kakan.call_conditions += [
  {"name": "not_call_contains", "opts": [["27z"], 1]}
]
|
.buttons.ankan.call_conditions += [
  {"name": "not_call_contains", "opts": [["27z"], 1]}
]
