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
    "XX0aX1aX2aX3aX4a XXXX0b XXXX0c", "X0aXX1aX2aX3aX4a XXXX1b XXXX1c", "X0aX1aXX2aX3aX4a XXXX2b XXXX2c", "X0aX1aX2aXX3aX4a XXXX3b XXXX3c", "X0aX1aX2aX3aXX4a XXXX4b XXXX4c",
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
    "XX0aX1aX2aX3aX4a XXXX0b XXXX0c", "X0aXX1aX2aX3aX4a XXXX1b XXXX1c", "X0aX1aXX2aX3aX4a XXXX2b XXXX2c", "X0aX1aX2aXX3aX4a XXXX3b XXXX3c", "X0aX1aX2aX3aXX4a XXXX4b XXXX4c",
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
    { "display_name": "2025 #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["222a 000 2222b 5555b", "222a 000 2222b 2222c"]]}] },
    { "display_name": "2025 #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["2025a 222b 555c ZZZZ"]]}] },
    { "display_name": "2025 #3", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF 22a 0000 22a 555a"]]}] },
    { "display_name": "2025 #4", "value": 35, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["222a 000 222b 555c DDa|DDb|DDc"]]} ] },
    { "display_name": "2468 #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["222a 444a 6666a 8888a", "222a 444b 6666c 8888a"]]}] },
    { "display_name": "2468 #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF 2222a 2222b 44c", "FFFF 2222a 4444b 88c"]]}] },
    { "display_name": "2468 #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["2222a 444a 66a 8a DDDDa"]]}] },
    { "display_name": "2468 #4", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF 22468a 222b 222c", "FFF 24468a 444b 444c", "FFF 24668a 666b 666c", "FFF 24688a 888b 888c"]]}] },
    { "display_name": "2468 #5", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF 222a 222b NEWS", "FFFF 444a 444b NEWS", "FFFF 666a 666b NEWS", "FFFF 888a 888b NEWS"]]}] },
    { "display_name": "2468 #6", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 222a 444a 666b 888b"]]} ] },
    { "display_name": "Any Like Numbers #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXXX0a XXXX0b XXXX0c DDc"]]}] },
    { "display_name": "Any Like Numbers #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF XXXX0a XXX0b XXX0c"]]}] },
    { "display_name": "Any Like Numbers #3", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF XX0a XX0b NEWS DDDc"]]}] },
    { "display_name": "Any Like Numbers #4", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXX0a DDDa XXX0b DDDb XX0c"]]} ] },
    { "display_name": "Quints #1", "value": 45, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFFF XXXXX0a XXX0b X0c"]]}] },
    { "display_name": "Quints #2", "value": 45, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXXXX0a XX1a XX2a XXXXX3a"]]}] },
    { "display_name": "Quints #3", "value": 45, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXXXX0a X1a X2a X0b X1b XXXXX2b"]]}] },
    { "display_name": "Quints #4", "value": 40, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["ZZZZZ XX0a XX1b|XX2b|XX3b|XX4b|XX5b|XX6b|XX7b|XX8b DDDDDc"]]}] },
    { "display_name": "Consecutive Run #1", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["1111a 22a 33a 44a 5555a", "5555a 66a 77a 88a 9999a"]]}] },
    { "display_name": "Consecutive Run #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXX0a XXX1a XXXX1b XXXX2b"]]}] },
    { "display_name": "Consecutive Run #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXXX0a XXXX1a XXX1b XXX2b"]]}] },
    { "display_name": "Consecutive Run #4", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF XXXX0a XXXX1b DDDc"]]}] },
    { "display_name": "Consecutive Run #5", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXXX0a XXXX1a XXXX2a DDa"]]}] },
    { "display_name": "Consecutive Run #6", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXXX0a XXXX1b XXXX2c DDa|DDb|DDc"]]}] },
    { "display_name": "Consecutive Run #7", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXX0a X1b DDDb XXX2c ZZZZ"]]}] },
    { "display_name": "Consecutive Run #8", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF XXX0a DDa XXXX1b XXX2b"]]}] },
    { "display_name": "Consecutive Run #9", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFFF XXXX0a XXX1a XX2a", "FFFFF XXXX0a XXX1b XX2c"]]}] },
    { "display_name": "Consecutive Run #10", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF XXX0a XX1b XXX2c DDDb"]]} ] },
    { "display_name": "13579 #1", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["1111a 33a 55a 77a 9999a", "1111a 33a 55b 77c 9999c"]]}] },
    { "display_name": "13579 #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["111a 333a 5555b 7777b", "333a 555a 7777b 9999b"]]}] },
    { "display_name": "13579 #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF 1a 33a 555a 7777a", "FFFF 3a 55a 777a 9999a"]]}] },
    { "display_name": "13579 #4", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["1111a 7777a 3333b 51c", "1111a 3333a 7777b 91c"]]}] },
    { "display_name": "13579 #5", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["111a 99a 11b 999b DDDDc"]]}] },
    { "display_name": "13579 #6", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF 1111a 333b 555c", "FFFF 3333a 555b 777c", "FFFF 5555a 777b 999c"]]}] },
    { "display_name": "13579 #7", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF 13579a 111b 111c", "FFF 13579a 333b 333c", "FFF 13579a 555b 555c", "FFF 13579a 777b 777c", "FFF 13579a 999b 999c"]]} ] },
    { "display_name": "Winds and Dragons #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NNN EEE WWWW SSSS", "NNNN EEEE WWW SSS"]]}] },
    { "display_name": "Winds and Dragons #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF N EE WWW SSSS", "FFFF NNNN EEE WW S"]]}] },
    { "display_name": "Winds and Dragons #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NNN 111a|333a|555a|777a|999a RRRR SSSS"]]}] },
    { "display_name": "Winds and Dragons #4", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["EEE 222a|444a|666a|888a GGGG WWWW"]]}] },
    { "display_name": "Winds and Dragons #5", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["X0a XX1a XXX2a DDDDb DDDDc"]]}] },
    { "display_name": "Winds and Dragons #6", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["X0a DDDDa XX1b DDDDb XXX2c"]]}] },
    { "display_name": "Winds and Dragons #7", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["Da DDb DDDc NNNN SSSS", "Da DDb DDDc EEEE WWWW"]]}] },
    { "display_name": "Winds and Dragons #8", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF XXX0a DDb DDc NEWS"]]} ] },
    { "display_name": "369 #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["333a 666a 9999b 9999c", "333a 666b 9999b 9999c"]]}] },
    { "display_name": "369 #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 3333a 3333b 66c", "FFFF 3333a 6666b 99c"]]}] },
    { "display_name": "369 #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["3333a Da 666b DDb 9c DDDc", "3333a Da 999b DDb 6c DDDc", "6666a Da 333b DDb 9c DDDc", "6666a Da 999b DDb 3c DDDc", "9999a Da 333b DDb 6c DDDc", "9999a Da 666b DDb 3c DDDc"]]}] },
    { "display_name": "369 #4", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 3333a 3333b NEWS", "FF 6666a 6666b NEWS", "FF 9999a 9999b NEWS"]]}] },
    { "display_name": "369 #5", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NN SS 333a 666a DDDDa", "NN SS 333a 999a DDDDa", "NN SS 666a 999a DDDDa", "EE WW 333a 666a DDDDa", "EE WW 333a 999a DDDDa", "EE WW 666a 999a DDDDa"]]}] },
    { "display_name": "369 #6", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFFF 3333a 666a 99a", "FFFFF 3333a 666b 99c"]]}] },
    { "display_name": "369 #7", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF 369a DDa 333b 333c", "FFF 369a DDa 666b 666c", "FFF 369a DDa 999b 999c"]]}] },
    { "display_name": "Singles and Pairs #1", "value": 50, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["00 22a 44a 66a 88a NN SS", "00 22a 44a 66a 88a EE WW"]]} ] },
    { "display_name": "Singles and Pairs #2", "value": 50, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["11a 33a 55a 77a 99a DDb DDc"]]} ] },
    { "display_name": "Singles and Pairs #3", "value": 50, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 33a 33b 66c 99c NEWS", "FF 66a 66b 33c 99c NEWS", "FF 99a 99b 33c 66c NEWS"]]} ] },
    { "display_name": "Singles and Pairs #4", "value": 50, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 1a Da 112b Db 11223c Dc", "FF 9a Da 998b Db 99887c Dc"]]} ] },
    { "display_name": "Singles and Pairs #5", "value": 50, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 123a 345b 567a 789b"]]} ] },
    { "display_name": "Singles and Pairs #6", "value": 50, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 2025a NN EE WW SS"]]} ] },
    { "display_name": "Singles and Pairs #7", "value": 50, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["F 19a Da 19b Db 19c Dc NEWS"]]} ] },
    { "display_name": "Singles and Pairs #8", "value": 100, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["0FFEREDa F0R FREE", "0FFSRSDa F0R FRSS", "0FFWRWDa F0R FRWW", "0FFNRNDa F0R FRNN"]]} ] }
  ]
