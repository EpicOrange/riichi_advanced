def make_aka:
  if type == "array" then
    .[0] |= make_aka
  elif IN("1m","2m","3m","4m","5m","6m","7m","8m","9m","10m","1p","2p","3p","4p","5p","6p","7p","8p","9p","10p","1s","2s","3s","4s","5s","6s","7s","8s","9s","10s","1t","2t","3t","4t","5t","6t","7t","8t","9t","10t","1z","2z","3z","4z","5z","6z","7z","0z") then
    "0" + .
  elif . == "0m" then "05m"
  elif . == "0p" then "05p"
  elif . == "0s" then "05s"
  elif . == "0t" then "05t"
  else . end;

.after_initialization.actions += [["add_rule", "Rules", "Wall", "(It's All Aka?) Every standard tile is replaced with a red \"aka dora\" version worth 1 extra han each.", -99]]
|
# it's all aka now
.wall |= map(make_aka)
|
# set each aka dora as single value jokers
.after_start.actions += [
  ["set_tile_alias_all", ["01m"], ["1m"]],
  ["set_tile_alias_all", ["02m"], ["2m"]],
  ["set_tile_alias_all", ["03m"], ["3m"]],
  ["set_tile_alias_all", ["04m"], ["4m"]],
  ["set_tile_alias_all", ["05m"], ["5m"]],
  ["set_tile_alias_all", ["06m"], ["6m"]],
  ["set_tile_alias_all", ["07m"], ["7m"]],
  ["set_tile_alias_all", ["08m"], ["8m"]],
  ["set_tile_alias_all", ["09m"], ["9m"]],
  ["set_tile_alias_all", ["010m"], ["10m"]],
  ["set_tile_alias_all", ["01p"], ["1p"]],
  ["set_tile_alias_all", ["02p"], ["2p"]],
  ["set_tile_alias_all", ["03p"], ["3p"]],
  ["set_tile_alias_all", ["04p"], ["4p"]],
  ["set_tile_alias_all", ["05p"], ["5p"]],
  ["set_tile_alias_all", ["06p"], ["6p"]],
  ["set_tile_alias_all", ["07p"], ["7p"]],
  ["set_tile_alias_all", ["08p"], ["8p"]],
  ["set_tile_alias_all", ["09p"], ["9p"]],
  ["set_tile_alias_all", ["010p"], ["10p"]],
  ["set_tile_alias_all", ["01s"], ["1s"]],
  ["set_tile_alias_all", ["02s"], ["2s"]],
  ["set_tile_alias_all", ["03s"], ["3s"]],
  ["set_tile_alias_all", ["04s"], ["4s"]],
  ["set_tile_alias_all", ["05s"], ["5s"]],
  ["set_tile_alias_all", ["06s"], ["6s"]],
  ["set_tile_alias_all", ["07s"], ["7s"]],
  ["set_tile_alias_all", ["08s"], ["8s"]],
  ["set_tile_alias_all", ["09s"], ["9s"]],
  ["set_tile_alias_all", ["010s"], ["10s"]],
  ["set_tile_alias_all", ["01t"], ["1t"]],
  ["set_tile_alias_all", ["02t"], ["2t"]],
  ["set_tile_alias_all", ["03t"], ["3t"]],
  ["set_tile_alias_all", ["04t"], ["4t"]],
  ["set_tile_alias_all", ["05t"], ["5t"]],
  ["set_tile_alias_all", ["06t"], ["6t"]],
  ["set_tile_alias_all", ["07t"], ["7t"]],
  ["set_tile_alias_all", ["08t"], ["8t"]],
  ["set_tile_alias_all", ["09t"], ["9t"]],
  ["set_tile_alias_all", ["010t"], ["10t"]],
  ["set_tile_alias_all", ["01z"], ["1z"]],
  ["set_tile_alias_all", ["02z"], ["2z"]],
  ["set_tile_alias_all", ["03z"], ["3z"]],
  ["set_tile_alias_all", ["04z"], ["4z"]],
  ["set_tile_alias_all", ["05z"], ["5z"]],
  ["set_tile_alias_all", ["06z"], ["6z"]],
  ["set_tile_alias_all", ["07z"], ["7z"]],
  ["set_tile_alias_all", ["00z"], ["0z"]],
  ["tag_tiles", "dora", ["01m","02m","03m","04m","05m","06m","07m","08m","09m","010m","01p","02p","03p","04p","05p","06p","07p","08p","09p","010p","01s","02s","03s","04s","05s","06s","07s","08s","09s","010s","01t","02t","03t","04t","05t","06t","07t","08t","09t","010t","01z","02z","03z","04z","05z","06z","07z","00z"]]
]
|
# count aka
.before_win.actions += [
  ["set_counter", "aka", "count_matches", ["hand", "calls", "winning_tile"], [[ "nojoker", [["01m","02m","03m","04m","05m","06m","07m","08m","09m","010m","01p","02p","03p","04p","05p","06p","07p","08p","09p","010p","01s","02s","03s","04s","05s","06s","07s","08s","09s","010s","01t","02t","03t","04t","05t","06t","07t","08t","09t","010t","01z","02z","03z","04z","05z","06z","07z","00z"], 1] ]]]
]
|
# make sure they indicate dora
.dora_indicators += {
  "01m": ["2m"],
  "02m": ["3m"],
  "03m": ["4m"],
  "04m": ["5m"],
  "05m": ["6m"],
  "06m": ["7m"],
  "07m": ["8m"],
  "08m": ["9m"],
  "09m": ["1m"],
  "01p": ["2p"],
  "02p": ["3p"],
  "03p": ["4p"],
  "04p": ["5p"],
  "05p": ["6p"],
  "06p": ["7p"],
  "07p": ["8p"],
  "08p": ["9p"],
  "09p": ["1p"],
  "01s": ["2s"],
  "02s": ["3s"],
  "03s": ["4s"],
  "04s": ["5s"],
  "05s": ["6s"],
  "06s": ["7s"],
  "07s": ["8s"],
  "08s": ["9s"],
  "09s": ["1s"],
  "01z": ["2z"],
  "02z": ["3z"],
  "03z": ["4z"],
  "04z": ["1z"],
  "05z": ["6z"],
  "06z": ["7z"],
  "07z": ["5z"]
}
