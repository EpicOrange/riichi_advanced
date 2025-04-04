.after_initialization.actions += [["add_rule", "Yakuman", "Fuukasetsugetsu", "\"Flower, Bird, Snow, Moon\". Your hand is 555p (5 circles) + 555z (white dragon) + triplet of round or seat wind + 111p (1 circles).", 113]]
|
.yakuman += [
  {
    "display_name": "Fuukasetsugetsu",
    "value": 1,
    "when": [
      {"name": "match", "opts": [["hand", "calls", "winning_tile"], ["fuukasetsugetsu"]]},
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
.fuukasetsugetsu_definition = [[
  [["5p","5p","5p"], 1],
  [["5z","5z","5z"], 1],
  [["ton","nan","shaa","pei"], 1],
  [["1p","1p","1p"], 1],
  [["pair"], 1]
]]
