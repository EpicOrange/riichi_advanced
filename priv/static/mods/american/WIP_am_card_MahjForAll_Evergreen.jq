# TODO: Implement the following hands:
# * Special Years hands 1~4.
#    * We need some way to have each player choose a year before they're dealt any tiles. Do we want years to persist between rounds?
# * Blast from the Past #1.
#    * We need some way to indicate that an exposure CANNOT use jokers.
# * Blast from the Past #4.
#    * We need some way to allow flowers to be used as jokers in a grouping.

.win_definition = [
    
    # Special Years
        # <TODO: implement this section>
    # have each player choose a year beforehand; α, β, γ, and δ correspond to the four digits of that year
    # "FF αααa βββa γγγb δδδc", # x 25
    # "FF αααa βββa γγγb δδδc", # x 25
    # "FF αααa βββa γγγb δδδc", # x 25
    # "FF αααa βββa γγγb δδδc", # x 25
    # Any Like Number
    "FF XXXX0a XXXX0b XXXX0c",
    "XXX0a DDDDa XXX0b DDDDb",
    "XXX0a DDDa XX0b DDDc XXX0c",
    # 2468
    "222a 4444a 666a 8888a", "222a 4444a 666b 8888b",
    "FF 2222a 8888a DDDDa", "FF 2222a 8888b DDDDc",
    "FF 2222a DDb 6666a", "FFFF 4444a DDb 8888a",
    "222a 444a 666a 888a 22b|44b|66b|88b", # concealed
    # Sevens & Elevens
    "FFFFF 111a 666a 777a", "FFFFF 111a 666b 777c",
    "FFFFF 222a 555a 777a", "FFFFF 222a 555b 777c",
    "FFFFF 333a 444a 777a", "FFFFF 333a 444b 777c",
    "2222a 9999b 111c 111c", "3333a 8888b 111c 111c",
    "4444a 7777b 111c 111c", "5555a 6666b 111c 111c",
    # Consecutive Run
    "XX0a XXX1a XXXX2a XXX3a XX4a",
    "FF XXXX0a XXXX1a XXXX2a", "FF XXXX0a XXXX1b XXXX2c",
    "XXX0a XXX1a XXXX2b XXXX3b",
    "FF XXXX0a XXXX1a DDDDa",
    "XX0a X1a X2a X3a X4a XXXX0b XXXX0c", "X0a XX1a X2a X3a X4a XXXX1b XXXX1c", "X0a X1a XX2a X3a X4a XXXX2b XXXX2c", "X0a X1a X2a XX3a X4a XXXX3b XXXX3c", "X0a X1a X2a X3a XX4a XXXX4b XXXX4c",
    "111a 2345a 5678a 999a", "111a 2345b 5678b 999a",
    "FFF XXX0a XX1a XXX0b XX1b Dc", # concealed
    # Quints
    "22a 333a 4444a 55555a",
    "XXXXX0a XXXX1b XXXXX2c",
    "22222a 44a 66a 88888a", "22222a 44a 66b 88888b",
    "ZZZZZ DDDDa XXXXX0a|XXXXX0b",
    # 13579
    "11a 333a 5555a 777a 99a",
    "111a 333a 3333b 5555c", "555a 777a 7777b 9999c",
    "FF 1111a 9999a DDDDa",
    "11a 33a 55a 7777b 9999c",
    "111a 333a 555b 777b 99c", # concealed
    "111a 111b 999a 999b 10c", # concealed
    # Winds and Dragons
    "N EE WWW SSSS DDDDa",
    "NNNN EEE WWW SSSS", "NNN EEEE WWWW SSS",
    "FF DDDDa NEWS DDDDb",
    "NNN 111a RR 111b SSS", "NNN 333a RR 333b SSS", "NNN 555a RR 555b SSS", "NNN 777a RR 777b SSS", "NNN 999a RR 999b SSS", 
    "EEE 222a GG 222b WWW", "EEE 444a GG 444b WWW", "EEE 666a GG 666b WWW", "EEE 888a GG 888b WWW",
    "NNN 111a 11c 111b SSS", "NNN 333a 33c 333b SSS", "NNN 555a 55c 555b SSS", "NNN 777a 77c 777b SSS", "NNN 999a 99c 999b SSS", # concealed
    "EEE 222a 22c 222b WWW", "EEE 444a 44c 444b WWW", "EEE 666a 66c 666b WWW", "EEE 888a 88c 888b WWW", # concealed
    # 369
    "FF 3333a 6666a 9999a", "FF 3333a 6666b 9999c",
    "3333a 666a 666b 9999c",
    "3333a 33b 33a 33c 9999a", "3333a 66b 66a 66c 9999a", "3333a 99b 99a 99c 9999a",
    "333a 66a 999a DDDb DDDc", # concealed
    "FF 333a 666a 999a DDDa", # concealed
    # Blast from the Past
    # "FF 1111a 4444b 7777c", # any four numbered kongs, no jokers allowed
    "111a 999a 2222b 8888b", "1111a 9999a 222b 888b",
    "88a 555a 2222a 11111a", # concealed
    # "55555a 999999999b", # flowers may be used as jokers for this hand! # concealed
    "11a 444a 99b 222b DDDDc", "11a 777a 77b 666b DDDDc", # concealed
    "FF NN EE WW SS 1776a" # concealed
  ]
|
.open_win_definition = [
    # Special Years
        # <TODO: implement this section>
    # have each player choose a year beforehand; α, β, γ, and δ correspond to the four digits of that year
    # "FF αααa βββa γγγb δδδc", # x 25
    # "FF αααa βββa γγγb δδδc", # x 25
    # "FF αααa βββa γγγb δδδc", # x 25
    # "FF αααa βββa γγγb δδδc", # x 25
    # Any Like Number
    "FF XXXX0a XXXX0b XXXX0c",
    "XXX0a DDDDa XXX0b DDDDb",
    "XXX0a DDDa XX0b DDDc XXX0c",
    # 2468
    "222a 4444a 666a 8888a", "222a 4444a 666b 8888b",
    "FF 2222a 8888a DDDDa", "FF 2222a 8888b DDDDc",
    "FF 2222a DDb 6666a", "FFFF 4444a DDb 8888a",
    # Sevens & Elevens
    "FFFFF 111a 666a 777a", "FFFFF 111a 666b 777c",
    "FFFFF 222a 555a 777a", "FFFFF 222a 555b 777c",
    "FFFFF 333a 444a 777a", "FFFFF 333a 444b 777c",
    "2222a 9999b 111c 111c", "3333a 8888b 111c 111c",
    "4444a 7777b 111c 111c", "5555a 6666b 111c 111c",
    # Consecutive Run
    "XX0a XXX1a XXXX2a XXX3a XX4a",
    "FF XXXX0a XXXX1a XXXX2a", "FF XXXX0a XXXX1b XXXX2c",
    "XXX0a XXX1a XXXX2b XXXX3b",
    "FF XXXX0a XXXX1a DDDDa",
    "XX0a X1a X2a X3a X4a XXXX0b XXXX0c", "X0a XX1a X2a X3a X4a XXXX1b XXXX1c", "X0a X1a XX2a X3a X4a XXXX2b XXXX2c", "X0a X1a X2a XX3a X4a XXXX3b XXXX3c", "X0a X1a X2a X3a XX4a XXXX4b XXXX4c",
    "111a 2345a 5678a 999a", "111a 2345b 5678b 999a",
    # Quints
    "22a 333a 4444a 55555a",
    "XXXXX0a XXXX1b XXXXX2c",
    "22222a 44a 66a 88888a", "22222a 44a 66b 88888b",
    "ZZZZZ DDDDa XXXXX0a|XXXXX0b",
    # 13579
    "11a 333a 5555a 777a 99a",
    "111a 333a 3333b 5555c", "555a 777a 7777b 9999c",
    "FF 1111a 9999a DDDDa",
    "11a 33a 55a 7777b 9999c",
    # Winds and Dragons
    "N EE WWW SSSS DDDDa",
    "NNNN EEE WWW SSSS", "NNN EEEE WWWW SSS",
    "FF DDDDa NEWS DDDDb",
    "NNN 111a RR 111b SSS", "NNN 333a RR 333b SSS", "NNN 555a RR 555b SSS", "NNN 777a RR 777b SSS", "NNN 999a RR 999b SSS", 
    "EEE 222a GG 222b WWW", "EEE 444a GG 444b WWW", "EEE 666a GG 666b WWW", "EEE 888a GG 888b WWW",
    "NNN 111a 11c 111b SSS", "NNN 333a 33c 333b SSS", "NNN 555a 55c 555b SSS", "NNN 777a 77c 777b SSS", "NNN 999a 99c 999b SSS", # concealed
    "EEE 222a 22c 222b WWW", "EEE 444a 44c 444b WWW", "EEE 666a 66c 666b WWW", "EEE 888a 88c 888b WWW", # concealed
    # 369
    "FF 3333a 6666a 9999a", "FF 3333a 6666b 9999c",
    "3333a 666a 666b 9999c",
    "3333a 33b 33a 33c 9999a", "3333a 66b 66a 66c 9999a", "3333a 99b 99a 99c 9999a",
    # Blast from the Past
    # "FF 1111a 4444b 7777c", # any four numbered kongs, no jokers allowed
    "111a 999a 2222b 8888b", "1111a 9999a 222b 888b",
  ]
|
.singles_win_definition = [
  ]
|
.yaku = [
    # { "display_name": "Special Years #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["222a 000 2222b 5555b", "222a 000 2222b 2222c"]]}] },
    # { "display_name": "Special Years #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["2025a 222b 555c ZZZZ"]]}] },
    # { "display_name": "Special Years #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF 22a 0000 22a 555a"]]}] },
    # { "display_name": "Special Years #4", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF 22a 0000 22a 555a"]]}] },
    { "display_name": "Any Like Number #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF XXXX0a XXXX0b XXXX0c"]]}] },
    { "display_name": "Any Like Number #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXX0a DDDDa XXX0b DDDDb"]]}] },
    { "display_name": "Any Like Number #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXX0a DDDa XX0b DDDc XXX0c"]]}] },
    { "display_name": "2468 #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["222a 4444a 666a 8888a", "222a 4444a 666b 8888b"]]}] },
    { "display_name": "2468 #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 2222a 8888a DDDDa", "FF 2222a 8888b DDDDc"]]}] },
    { "display_name": "2468 #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 2222a DDb 6666a", "FFFF 4444a DDb 8888a"]]}] },
    { "display_name": "2468 #4", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["222a 444a 666a 888a 22b|44b|66b|88b"]]} ] },
    { "display_name": "Sevens & Elevens #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFFF 111a 666a 777a", "FFFFF 111a 666b 777c"]]}] },
    { "display_name": "Sevens & Elevens #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFFF 222a 555a 777a", "FFFFF 222a 555b 777c"]]}] },
    { "display_name": "Sevens & Elevens #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFFF 333a 444a 777a", "FFFFF 333a 444b 777c"]]}] },
    { "display_name": "Sevens & Elevens #4", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["2222a 9999b 111c 111c", "3333a 8888b 111c 111c"]]}] },
    { "display_name": "Sevens & Elevens #5", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["4444a 7777b 111c 111c", "5555a 6666b 111c 111c"]]}] },
    { "display_name": "Consecutive Run #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XX0a XXX1a XXXX2a XXX3a XX4a"]]}] },
    { "display_name": "Consecutive Run #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF XXXX0a XXXX1a XXXX2a", "FF XXXX0a XXXX1b XXXX2c"]]}] },
    { "display_name": "Consecutive Run #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXX0a XXX1a XXXX2b XXXX3b"]]}] },
    { "display_name": "Consecutive Run #4", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF XXXX0a XXXX1a DDDDa"]]}] },
    { "display_name": "Consecutive Run #5", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XX0a X1a X2a X3a X4a XXXX0b XXXX0c", "X0a XX1a X2a X3a X4a XXXX1b XXXX1c", "X0a X1a XX2a X3a X4a XXXX2b XXXX2c", "X0a X1a X2a XX3a X4a XXXX3b XXXX3c", "X0a X1a X2a X3a XX4a XXXX4b XXXX4c"]]}] },
    { "display_name": "Consecutive Run #6", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["111a 2345a 5678a 999a", "111a 2345b 5678b 999a"]]}] },
    { "display_name": "Consecutive Run #7", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF XXX0a XX1a XXX0b XX1b Dc"]]} ] },
    { "display_name": "Quints #1", "value": 40, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["22a 333a 4444a 55555a"]]}] },
    { "display_name": "Quints #2", "value": 45, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXXXX0a XXXX1b XXXXX2c"]]}] },
    { "display_name": "Quints #3", "value": 45, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["22222a 44a 66a 88888a", "22222a 44a 66b 88888b"]]}] },
    { "display_name": "Quints #4", "value": 40, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["ZZZZZ DDDDa XXXXX0a|XXXXX0b"]]}] },
    { "display_name": "13579 #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["11a 333a 5555a 777a 99a"]]}] },
    { "display_name": "13579 #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["111a 333a 3333b 5555c", "555a 777a 7777b 9999c"]]}] },
    { "display_name": "13579 #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 1111a 9999a DDDDa"]]}] },
    { "display_name": "13579 #4", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["11a 33a 55a 7777b 9999c"]]}] },
    { "display_name": "13579 #5", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["111a 333a 555b 777b 99c"]]} ] },
    { "display_name": "13579 #6", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["111a 111b 999a 999b 10c"]]} ] },
    { "display_name": "Winds and Dragons #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["N EE WWW SSSS DDDDa"]]}] },
    { "display_name": "Winds and Dragons #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NNNN EEE WWW SSSS", "NNN EEEE WWWW SSS"]]}] },
    { "display_name": "Winds and Dragons #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF DDDDa NEWS DDDDb"]]}] },
    { "display_name": "Winds and Dragons #4", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NNN 111a RR 111b SSS", "NNN 333a RR 333b SSS", "NNN 555a RR 555b SSS", "NNN 777a RR 777b SSS", "NNN 999a RR 999b SSS"]]}] },
    { "display_name": "Winds and Dragons #5", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["EEE 222a GG 222b WWW", "EEE 444a GG 444b WWW", "EEE 666a GG 666b WWW", "EEE 888a GG 888b WWW"]]}] },
    { "display_name": "Winds and Dragons #6", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NNN 111a 11c 111b SSS", "NNN 333a 33c 333b SSS", "NNN 555a 55c 555b SSS", "NNN 777a 77c 777b SSS", "NNN 999a 99c 999b SSS"]]} ] },
    { "display_name": "Winds and Dragons #7", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["EEE 222a 22c 222b WWW", "EEE 444a 44c 444b WWW", "EEE 666a 66c 666b WWW", "EEE 888a 88c 888b WWW"]]} ] },
    { "display_name": "369 #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 3333a 6666a 9999a", "FF 3333a 6666b 9999c"]]}] },
    { "display_name": "369 #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["3333a 666a 666b 9999c"]]}] },
    { "display_name": "369 #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["3333a 33b 33a 33c 9999a", "3333a 66b 66a 66c 9999a", "3333a 99b 99a 99c 9999a"]]}] },
    { "display_name": "369 #4", "value": 25, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["333a 66a 999a DDDb DDDc"]]}] },
    { "display_name": "369 #5", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 333a 666a 999a DDDa"]]}] },
    # { "display_name": "Blast from the Past #1", "value": 35, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["3333a Da 666b DDb 9c DDDc", "3333a Da 999b DDb 6c DDDc", "6666a Da 333b DDb 9c DDDc", "6666a Da 999b DDb 3c DDDc", "9999a Da 333b DDb 6c DDDc", "9999a Da 666b DDb 3c DDDc"]]}] },
    { "display_name": "Blast from the Past #2", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["111a 999a 2222b 8888b", "1111a 9999a 222b 888b"]]}] },
    { "display_name": "Blast from the Past #3", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["88a 555a 2222a 11111a"]]} ] },
    # { "display_name": "Blast from the Past #4", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["00 22a 44a 66a 88a NN SS", "00 22a 44a 66a 88a EE WW"]]} ] },
    { "display_name": "Blast from the Past #5", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["11a 444a 99b 222b DDDDc", "11a 777a 77b 666b DDDDc"]]} ] },
    { "display_name": "Blast from the Past #6", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF NN EE WW SS 1776a"]]} ] }
  ]
