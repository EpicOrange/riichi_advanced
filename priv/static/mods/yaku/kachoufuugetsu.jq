.after_initialization.actions += [["add_rule", "Yakuman", "Kachoufuugetsu", "\"Flower, Bird, Wind, Moon\". Your hand is 555p (5 circles) + 111s (birds) + triplet of round or seat wind + 111p (1 circles).", 113]]
|
.yakuman += [
  {
    "display_name": "Kachoufuugetsu",
    "value": 1,
    "when": [
      {"name": "match", "opts": [["hand", "calls", "winning_tile"], ["kachoufuugetsu"]]},
      [
        [[{"name": "round_wind_is", "opts": ["east"]}, {"name": "seat_is", "opts": ["east"]}], {"name": "match", "opts": [["hand", "calls", "winning_tile"], [[[["ton"], 1]]]]}],
        [[{"name": "round_wind_is", "opts": ["south"]}, {"name": "seat_is", "opts": ["south"]}], {"name": "match", "opts": [["hand", "calls", "winning_tile"], [[[["nan"], 1]]]]}],
        [[{"name": "round_wind_is", "opts": ["west"]}, {"name": "seat_is", "opts": ["west"]}], {"name": "match", "opts": [["hand", "calls", "winning_tile"], [[[["shaa"], 1]]]]}],
        [[{"name": "round_wind_is", "opts": ["north"]}, {"name": "seat_is", "opts": ["north"]}], {"name": "match", "opts": [["hand", "calls", "winning_tile"], [[[["pei"], 1]]]]}]
      ]
    ]
  }
]
|
.kachoufuugetsu_definition = [[
  [["5p","5p","5p"], 1],
  [["1s","1s","1s"], 1],
  [["ton","nan","shaa","pei"], 1],
  [["1p","1p","1p"], 1],
  [["pair"], 1]
]]
