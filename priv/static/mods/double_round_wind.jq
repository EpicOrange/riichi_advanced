.after_initialization.actions += [["add_rule", "Rules", "Double Round Wind", "Opposing winds are also round winds. So in East round, West is also a round wind."]]
|
.yaku += [{
  "display_name": "Round Wind",
  "value": 1,
  "when": [[
    [{"name": "round_wind_is", "opts": ["east"]}, {"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ [["shaa"], 1], [["shuntsu", "koutsu"], 3], [["pair"], 1] ]]]}],
    [{"name": "round_wind_is", "opts": ["south"]}, {"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ [["pei"], 1], [["shuntsu", "koutsu"], 3], [["pair"], 1] ]]]}],
    [{"name": "round_wind_is", "opts": ["west"]}, {"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ [["ton"], 1], [["shuntsu", "koutsu"], 3], [["pair"], 1] ]]]}],
    [{"name": "round_wind_is", "opts": ["north"]}, {"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ [["nan"], 1], [["shuntsu", "koutsu"], 3], [["pair"], 1] ]]]}]
  ]]
}]
