def make_galaxy:
  if type == "array" then
    .[0] |= make_galaxy
  elif . == "0z" then
    "15z"
  else "1" + . end;

def add_star_suit($enabled; $arr):
  $arr |
    if $enabled then
      . + map(select(type == "string" and endswith("m")) | sub("m$"; "t"))
    else . end;

any(.wall[]; . == "1t") as $star
|
.wall |= (to_entries | map(if (.key % 4 == 3) then .value |= make_galaxy else . end) | map(.value))
|
# add tenpai defs + win def + yakuman def for Milky Way yakuman
.tenpai_definition += [
  [ "nojoker", [add_star_suit($star; [
    "11m", "12m", "13m", "14m", "15m", "16m", "17m", "18m", "19m", "110m",
    "11p", "12p", "13p", "14p", "15p", "16p", "17p", "18p", "19p", "110p",
    "11s", "12s", "13s", "14s", "15s", "16s", "17s", "18s", "19s", "110s",
    "11z", "12z", "13z", "14z", "15z", "16z", "17z"
  ]), 13] ]
]
|
.tenpai_14_definition += [
  [ "nojoker", [add_star_suit($star; [
    "11m", "12m", "13m", "14m", "15m", "16m", "17m", "18m", "19m", "110m",
    "11p", "12p", "13p", "14p", "15p", "16p", "17p", "18p", "19p", "110p",
    "11s", "12s", "13s", "14s", "15s", "16s", "17s", "18s", "19s", "110s",
    "11z", "12z", "13z", "14z", "15z", "16z", "17z"
  ]), 13] ]
]
|
.win_definition += [
  [ "nojoker", [add_star_suit($star; [
    "11m", "12m", "13m", "14m", "15m", "16m", "17m", "18m", "19m", "110m",
    "11p", "12p", "13p", "14p", "15p", "16p", "17p", "18p", "19p", "110p",
    "11s", "12s", "13s", "14s", "15s", "16s", "17s", "18s", "19s", "110s",
    "11z", "12z", "13z", "14z", "15z", "16z", "17z"
  ]), 14] ]
]
|
.any_joker_definition += [
  [ "nojoker", [add_star_suit($star; [
    "11m", "12m", "13m", "14m", "15m", "16m", "17m", "18m", "19m", "110m",
    "11p", "12p", "13p", "14p", "15p", "16p", "17p", "18p", "19p", "110p",
    "11s", "12s", "13s", "14s", "15s", "16s", "17s", "18s", "19s", "110s",
    "11z", "12z", "13z", "14z", "15z", "16z", "17z"
  ]), 1] ]
]
|
.yakuman += [{
  "display_name": "Milky Way",
  "value": 1,
  "when": [{"name": "winning_hand_consists_of", "opts": add_star_suit($star; [
    "11m", "12m", "13m", "14m", "15m", "16m", "17m", "18m", "19m", "110m",
    "11p", "12p", "13p", "14p", "15p", "16p", "17p", "18p", "19p", "110p",
    "11s", "12s", "13s", "14s", "15s", "16s", "17s", "18s", "19s", "110s",
    "11z", "12z", "13z", "14z", "15z", "16z", "17z"
  ])}]
}]
|
# add joker rules
.after_start.actions += [
  ["set_tile_alias_all", ["11m"], add_star_suit($star; ["1m","1s","1p"])],
  ["set_tile_alias_all", ["12m"], add_star_suit($star; ["2m","2s","2p"])],
  ["set_tile_alias_all", ["13m"], add_star_suit($star; ["3m","3s","3p"])],
  ["set_tile_alias_all", ["14m"], add_star_suit($star; ["4m","4s","4p"])],
  ["set_tile_alias_all", ["15m"], add_star_suit($star; ["5m","5s","5p"])],
  ["set_tile_alias_all", ["16m"], add_star_suit($star; ["6m","6s","6p"])],
  ["set_tile_alias_all", ["17m"], add_star_suit($star; ["7m","7s","7p"])],
  ["set_tile_alias_all", ["18m"], add_star_suit($star; ["8m","8s","8p"])],
  ["set_tile_alias_all", ["19m"], add_star_suit($star; ["9m","9s","9p"])],
  ["set_tile_alias_all", ["11p"], add_star_suit($star; ["1m","1s","1p"])],
  ["set_tile_alias_all", ["12p"], add_star_suit($star; ["2m","2s","2p"])],
  ["set_tile_alias_all", ["13p"], add_star_suit($star; ["3m","3s","3p"])],
  ["set_tile_alias_all", ["14p"], add_star_suit($star; ["4m","4s","4p"])],
  ["set_tile_alias_all", ["15p"], add_star_suit($star; ["5m","5s","5p"])],
  ["set_tile_alias_all", ["16p"], add_star_suit($star; ["6m","6s","6p"])],
  ["set_tile_alias_all", ["17p"], add_star_suit($star; ["7m","7s","7p"])],
  ["set_tile_alias_all", ["18p"], add_star_suit($star; ["8m","8s","8p"])],
  ["set_tile_alias_all", ["19p"], add_star_suit($star; ["9m","9s","9p"])],
  ["set_tile_alias_all", ["11s"], add_star_suit($star; ["1m","1s","1p"])],
  ["set_tile_alias_all", ["12s"], add_star_suit($star; ["2m","2s","2p"])],
  ["set_tile_alias_all", ["13s"], add_star_suit($star; ["3m","3s","3p"])],
  ["set_tile_alias_all", ["14s"], add_star_suit($star; ["4m","4s","4p"])],
  ["set_tile_alias_all", ["15s"], add_star_suit($star; ["5m","5s","5p"])],
  ["set_tile_alias_all", ["16s"], add_star_suit($star; ["6m","6s","6p"])],
  ["set_tile_alias_all", ["17s"], add_star_suit($star; ["7m","7s","7p"])],
  ["set_tile_alias_all", ["18s"], add_star_suit($star; ["8m","8s","8p"])],
  ["set_tile_alias_all", ["19s"], add_star_suit($star; ["9m","9s","9p"])],
  ["set_tile_alias_all", ["11z"], ["1z","2z","3z","4z"]],
  ["set_tile_alias_all", ["12z"], ["1z","2z","3z","4z"]],
  ["set_tile_alias_all", ["13z"], ["1z","2z","3z","4z"]],
  ["set_tile_alias_all", ["14z"], ["1z","2z","3z","4z"]],
  ["set_tile_alias_all", ["15z"], ["5z","6z","7z","0z"]],
  ["set_tile_alias_all", ["16z"], ["5z","6z","7z","0z"]],
  ["set_tile_alias_all", ["17z"], ["5z","6z","7z","0z"]]
]
|
if $star then
  .after_start.actions += [
    ["set_tile_alias_all", ["11t"], ["1m","1s","1p","1t"]],
    ["set_tile_alias_all", ["12t"], ["2m","2s","2p","2t"]],
    ["set_tile_alias_all", ["13t"], ["3m","3s","3p","3t"]],
    ["set_tile_alias_all", ["14t"], ["4m","4s","4p","4t"]],
    ["set_tile_alias_all", ["15t"], ["5m","5s","5p","5t"]],
    ["set_tile_alias_all", ["16t"], ["6m","6s","6p","6t"]],
    ["set_tile_alias_all", ["17t"], ["7m","7s","7p","7t"]],
    ["set_tile_alias_all", ["18t"], ["8m","8s","8p","8t"]],
    ["set_tile_alias_all", ["19t"], ["9m","9s","9p","9t"]]
  ]
else . end
|
# expand dora indicator map, if it exists
if .dora_indicators then
  .dora_indicators += {
    "11m": add_star_suit($star; ["2m", "2p", "2s"]),
    "12m": add_star_suit($star; ["3m", "3p", "3s"]),
    "13m": add_star_suit($star; ["4m", "4p", "4s"]),
    "14m": add_star_suit($star; ["5m", "5p", "5s"]),
    "15m": add_star_suit($star; ["6m", "6p", "6s"]),
    "16m": add_star_suit($star; ["7m", "7p", "7s"]),
    "17m": add_star_suit($star; ["8m", "8p", "8s"]),
    "18m": add_star_suit($star; ["9m", "9p", "9s"]),
    "19m": add_star_suit($star; ["1m", "1p", "1s"]),
    "11p": add_star_suit($star; ["2m", "2p", "2s"]),
    "12p": add_star_suit($star; ["3m", "3p", "3s"]),
    "13p": add_star_suit($star; ["4m", "4p", "4s"]),
    "14p": add_star_suit($star; ["5m", "5p", "5s"]),
    "15p": add_star_suit($star; ["6m", "6p", "6s"]),
    "16p": add_star_suit($star; ["7m", "7p", "7s"]),
    "17p": add_star_suit($star; ["8m", "8p", "8s"]),
    "18p": add_star_suit($star; ["9m", "9p", "9s"]),
    "19p": add_star_suit($star; ["1m", "1p", "1s"]),
    "11s": add_star_suit($star; ["2m", "2p", "2s"]),
    "12s": add_star_suit($star; ["3m", "3p", "3s"]),
    "13s": add_star_suit($star; ["4m", "4p", "4s"]),
    "14s": add_star_suit($star; ["5m", "5p", "5s"]),
    "15s": add_star_suit($star; ["6m", "6p", "6s"]),
    "16s": add_star_suit($star; ["7m", "7p", "7s"]),
    "17s": add_star_suit($star; ["8m", "8p", "8s"]),
    "18s": add_star_suit($star; ["9m", "9p", "9s"]),
    "19s": add_star_suit($star; ["1m", "1p", "1s"]),
    "11z": ["1z", "2z", "3z", "4z"],
    "12z": ["1z", "2z", "3z", "4z"],
    "13z": ["1z", "2z", "3z", "4z"],
    "14z": ["1z", "2z", "3z", "4z"],
    "15z": ["5z", "6z", "7z", "0z"],
    "16z": ["5z", "6z", "7z", "0z"],
    "17z": ["5z", "6z", "7z", "0z"]
  }
  |
  if $star then
    .dora_indicators += {
      "11t": ["2m", "2p", "2s", "2t"],
      "12t": ["3m", "3p", "3s", "3t"],
      "13t": ["4m", "4p", "4s", "4t"],
      "14t": ["5m", "5p", "5s", "5t"],
      "15t": ["6m", "6p", "6s", "6t"],
      "16t": ["7m", "7p", "7s", "7t"],
      "17t": ["8m", "8p", "8s", "8t"],
      "18t": ["9m", "9p", "9s", "9t"],
      "19t": ["1m", "1p", "1s", "1t"]
    }
  else . end
else . end
|
# support for ten mod
if any(.wall[]; . == "10m") then
  .after_start.actions += [
    ["set_tile_alias_all", ["110m"], add_star_suit($star; ["10m","10s","10p"])],
    ["set_tile_alias_all", ["110p"], add_star_suit($star; ["10m","10s","10p"])],
    ["set_tile_alias_all", ["110s"], add_star_suit($star; ["10m","10s","10p"])]
  ]
  |
  if .dora_indicators then
    .dora_indicators += {
      "19m": add_star_suit($star; ["10m", "10p", "10s"]),
      "19p": add_star_suit($star; ["10m", "10p", "10s"]),
      "19s": add_star_suit($star; ["10m", "10p", "10s"]),
      "110m": add_star_suit($star; ["1m", "1p", "1s"]),
      "110p": add_star_suit($star; ["1m", "1p", "1s"]),
      "110s": add_star_suit($star; ["1m", "1p", "1s"])
    }
  else . end
  |
  if $star then
    .after_start.actions += [
      ["set_tile_alias_all", ["110t"], ["10m","10s","10p","10t"]]
    ]
    |
    if .dora_indicators then
      .dora_indicators += {
        "19t": ["10m", "10p", "10s", "10t"],
        "110t": ["1m", "1p", "1s", "1t"]
      }
    else . end
  else . end
else . end
|
# ankans are displayed all-face-up
.buttons.ankan.call_style = {"self": [0, 1, 2, 3]}
|
.before_win.actions += [
  ["add_counter", "galaxy_jokers", "count_matches", ["hand", "calls", "draw", "winning_tile"], ["any_joker"]],
  ["set_counter", "non_galaxy_jokers", "count_tiles"],
  ["subtract_counter", "non_galaxy_jokers", "galaxy_jokers"],
  ["when", [{"name": "counter_at_most", "opts": ["non_galaxy_jokers", 0]}], [
    ["clear_tile_aliases"], # disable jokers
    ["set_counter", "fu", 30]
  ]]
]
|
.win_timer = 20

# there is a rule that you gain shuugi equal to the number of galaxy tiles used as their own value,
# but our current joker solver does not try to maximize galaxy tiles used as their own value
# so this is not possible to implement
