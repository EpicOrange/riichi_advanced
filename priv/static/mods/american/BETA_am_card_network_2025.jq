.win_definition = [
    # Number Hands
    "XXXX0a XXX1a XX2a XXX3a XX4a",
    "XXX0a XXXX1a XXX2a DDDDa",
    "FF 11a 222a 333b DDDDc",
    "FFF 333a 666a 999b DDc",
    # Like Hands
    "FF XXXX0a NEWS XXXX0b", # TODO: confirm that this hand is correct; it says "3 suits" on the Card, but there are only two suited groups
    "FFF XXX0a XXXX0b XXXX0c",
    "XX0a DDDa XX0b DDDb XXXX0c", # TODO: confirm that this hand is correct; it says "2 suits" on the Card, but there are three suited groups
    "XXXX0a XXXX0b XXXX0c DDc",
    # Even Hands
    "FF 222a 444a 666b 888b",
    "2222a 444a 666a DDDDa",
    "222a 444a 666b 888c 10c",
    "FFFF 2222a 8888a 16a",
    # Odd Hands
    "1111a 3333a 5555a DDa",
    "FF 3333a 5555b 7777b",
    "FF 1111a 7777a DDDDa",
    "FFF 333a 555a 777a 99a",
    # Quint Hands
    "FFFF 22222a 55555a",
    "NNNNN EEE W SSSSS",
    "XXXXX0a XXXXX1a DDDDa",
    "77777a 22222b 5555c",
    # Yearly Hands
    "FF 222a 000 222b 555c",
    "2222a 0000 222b 555c",
    "NNN EEE WW SS 2025a",
    "222a NEWS 2025b DDDb",
    # Wind Hands
    "EEEE WWWW XXX0a XXX1a",
    "FF NEWS DDDDa DDDDb",
    "NN EEEE WWWW SSSS",
    "FFFF NN EEEE WW SS",
    # Closed Hands
    "FF 11a 22a 33a 44a 55a 66a", # concealed
    "FF NN EE WW SS DDa DDb", # concealed
    "FF XX0a DDa XX0b DDb XX0c DDc", # concealed
    "FF 2025a DDa 2025b DDb" # concealed
  ]
|
.open_win_definition = [
    # Number Hands
    "XXXX0a XXX1a XX2a XXX3a XX4a",
    "XXX0a XXXX1a XXX2a DDDDa",
    "FF 11a 222a 333b DDDDc",
    "FFF 333a 666a 999b DDc",
    # Like Hands
    "FF XXXX0a NEWS XXXX0b", # TODO: confirm that this hand is correct; it says "3 suits" on the Card, but there are only two suited groups
    "FFF XXX0a XXXX0b XXXX0c",
    "XX0a DDDa XX0b DDDb XXXX0c", # TODO: confirm that this hand is correct; it says "2 suits" on the Card, but there are three suited groups
    "XXXX0a XXXX0b XXXX0c DDc",
    # Even Hands
    "FF 222a 444a 666b 888b",
    "2222a 444a 666a DDDDa",
    "222a 444a 666b 888c 10c",
    "FFFF 2222a 8888a 16a",
    # Odd Hands
    "1111a 3333a 5555a DDa",
    "FF 3333a 5555b 7777b",
    "FF 1111a 7777a DDDDa",
    "FFF 333a 555a 777a 99a",
    # Quint Hands
    "FFFF 22222a 55555a",
    "NNNNN EEE W SSSSS",
    "XXXXX0a XXXXX1a DDDDa",
    "77777a 22222b 5555c",
    # Yearly Hands
    "FF 222a 000 222b 555c",
    "2222a 0000 222b 555c",
    "NNN EEE WW SS 2025a",
    "222a NEWS 2025b DDDb",
    # Wind Hands
    "EEEE WWWW XXX0a XXX1a",
    "FF NEWS DDDDa DDDDb",
    "NN EEEE WWWW SSSS",
    "FFFF NN EEEE WW SS"
  ]
|
.singles_win_definition = [
    # TODO: check whether "Closed Hands" category should belong here
  ]
|
.yaku = [
    { "display_name": "Number Hand #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXXX0a XXX1a XX2a XXX3a XX4a"]]}] },
    { "display_name": "Number Hand #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXX0a XXXX1a XXX2a DDDDa"]]}] },
    { "display_name": "Number Hand #3", "value": 35, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 11a 222a 333b DDDDc"]]}] },
    { "display_name": "Number Hand #4", "value": 40, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF 333a 666a 999b DDc"]]}] },
    { "display_name": "Like Hand #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF XXXX0a NEWS XXXX0b"]]}] }, # TODO: confirm that this hand is correct; it says "3 suits" on the Card, but there are only two suited groups
    { "display_name": "Like Hand #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF XXX0a XXXX0b XXXX0c"]]}] },
    { "display_name": "Like Hand #3", "value": 35, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XX0a DDDa XX0b DDDb XXXX0c"]]}] }, # TODO: confirm that this hand is correct; it says "2 suits" on the Card, but there are three suited groups
    { "display_name": "Like Hand #4", "value": 40, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXXX0a XXXX0b XXXX0c DDc"]]}] },
    { "display_name": "Even Hand #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 222a 444a 666b 888b"]]}] },
    { "display_name": "Even Hand #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["2222a 444a 666a DDDDa"]]}] },
    { "display_name": "Even Hand #3", "value": 35, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["222a 444a 666b 888c 10c"]]}] },
    { "display_name": "Even Hand #4", "value": 40, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF 2222a 8888a 16a"]]}] },
    { "display_name": "Odd Hand #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["1111a 3333a 5555a DDa"]]}] },
    { "display_name": "Odd Hand #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 3333a 5555b 7777b"]]}] },
    { "display_name": "Odd Hand #3", "value": 35, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 1111a 7777a DDDDa"]]}] },
    { "display_name": "Odd Hand #4", "value": 40, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF 333a 555a 777a 99a"]]}] },
    { "display_name": "Quint Hand #1", "value": 40, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF 22222a 55555a"]]}] },
    { "display_name": "Quint Hand #2", "value": 40, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NNNNN EEE W SSSSS"]]}] },
    { "display_name": "Quint Hand #3", "value": 40, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXXXX0a XXXXX1a DDDDa"]]}] },
    { "display_name": "Quint Hand #4", "value": 40, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["77777a 22222b 5555c"]]}] },
    { "display_name": "Yearly Hand #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 222a 000 222b 555c"]]}] },
    { "display_name": "Yearly Hand #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["2222a 0000 222b 555c"]]}] },
    { "display_name": "Yearly Hand #3", "value": 35, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NNN EEE WW SS 2025a"]]}] },
    { "display_name": "Yearly Hand #4", "value": 40, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["222a NEWS 2025b DDDb"]]}] },
    { "display_name": "Wind Hand #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["EEEE WWWW XXX0a XXX1a"]]}] },
    { "display_name": "Wind Hand #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF NEWS DDDDa DDDDb"]]}] },
    { "display_name": "Wind Hand #3", "value": 35, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NN EEEE WWWW SSSS"]]}] },
    { "display_name": "Wind Hand #4", "value": 40, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF NN EEEE WW SS"]]}] },
    { "display_name": "Closed Hand #1", "value": 50, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 11a 22a 33a 44a 55a 66a"]]} ] },
    { "display_name": "Closed Hand #2", "value": 50, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF NN EE WW SS DDa DDb"]]} ] },
    { "display_name": "Closed Hand #3", "value": 75, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF XX0a DDa XX0b DDb XX0c DDc"]]} ] },
    { "display_name": "Closed Hand #4", "value": 100, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 2025a DDa 2025b DDb"]]} ] }
  ]
### TODO: check scoring rules differences between Network and NMJL; if there are any, please add these as extra instructions at the bottom of this mod.
