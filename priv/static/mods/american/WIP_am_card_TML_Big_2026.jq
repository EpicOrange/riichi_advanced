# TODO: add a rule that concealed hands get a +10 bonus, except for hands that are concealed on the Card. 

.win_definition = [
    # 2026
    "222a 0000 222b 6666c",
    "DDDa Db 222a 222b 2026c", "DDDa Db 666a 666b 2026c", 
    "FFF NEWS DDDa 2026a",
    "FF 2026a 2222b 2222c", "FF 2026a 6666b 6666c", 
    "NNN EE 2026a WW SSS",
    # 2468
    "F 222a 444a 666a 8888a", "F 222a 444a 666b 8888c",
    "222a NNNN 222b SSSS", "444a NNNN 444b SSSS", "666a NNNN 666b SSSS", "888a NNNN 888b SSSS", "222a EEEE 222b WWWW", "444a EEEE 444b WWWW", "666a EEEE 666b WWWW", "888a EEEE 888b WWWW",
    "FF ZZZ 222a 4444a 66a",
    "FF 2a 4a 666a 8888a DDDa", "FF 2a 4a 666b 8888c DDDa",
    "FF 2222a 4444a|6666a|8888a DDDDa", "FF 4444a 6666a|8888a DDDDa", "FF 6666a 8888a DDDDa", "FF 2222a 4444b|6666b|8888b DDDDc", "FF 4444a 6666b|8888b DDDDc", "FF 6666a 8888b DDDDc",
    "222a 444a 666a 88888a", "222a 444a 666b 88888c",
    "2468Da 2468Db 2468c", # concealed
    "FF 22a 44a 66a 88a 22b 22c", "FF 22a 44a 66a 88a 44b 44c", "FF 22a 44a 66a 88a 66b 66c", "FF 22a 44a 66a 88a 88b 88c",
    # Any Matching Numbers
    "NNN XXX0a XX0b XXX0c SSS", "EEE XXX0a XX0b XXX0c WWW",
    "XXXX0a XXXX0b XXXX0c DDa",
    "XXX0a XXX0b XXX0c DDDDDa",
    "FFF XXXX0a FFF XXXX0b",
    # Consecutive Numbers
        ## TODO: check whether these "runs" can be played descending rather than ascending.
    "FF XXX0a XXX1a XXX2a XXX3a", "FF XXX0a XXX1a XXX2b XXX3b", 
    "XXX0a XXXX1a XXX0b XXXX1b",
    "FFFF ZZ XXX0a XXX1a DDa",
    "XXX0a XX1a XXXX2a XX3a XXX4a",
    "XXX0a XX1a NEWS XX2b XXX3b",
    "FF XX2a XXX1a XXXX0a DDDa", "FF XX2a XXX1b XXXX0c DDDb", 
    "XX0a XXX1a XXXX2a XXXXX3a", "XX0a XXX1a XXXX2a XXXXX3b",
    "FF 1233a 4566a 7899a", "FF 1233a 4566b 7899c", # concealed
    # 13579
    "NNN 111a 33a 555a SSS", "NNN 111a 33b 555c SSS",
    "EEE 555a 77a 999a WWW", "EEE 555a 77b 999c WWW",
    "111a 5555a 999a DDDDa", "111a 5555b 999a DDDDb",
    "FF ZZZ 333a 5555a 77a", "FF ZZZ 333a 5555b 77c",
    "111a 33a 5555a 77a 999a",
    "FF 1111a 3333a|5555a|7777a|9999a DDDDa", "FF 3333a 5555a|7777a|9999a DDDDa", "FF 5555a 7777a|9999a DDDDa", "FF 7777a 9999a DDDDa", "FF 1111a 3333b|5555b|7777b|9999b DDDDc", "FF 3333a 5555b|7777b|9999b DDDDc", "FF 5555a 7777b|9999b DDDDc", "FF 7777a 9999b DDDDc",
    "11a 33a 55a 77a 99a 11b 11c", "11a 33a 55a 77a 99a 33b 33c", "11a 33a 55a 77a 99a 55b 55c", "11a 33a 55a 77a 99a 77b 77c", "11a 33a 55a 77a 99a 99b 99c", # concealed
    # Winds and Dragons
    "NNN EEE WWW SSS DDa",
    "FFF DDDa DDDDDb DDDc",
    "DDDa NN EE WW SS DDDb",
    # 369
    "FF 333a 666a 999a DDDa", "FF 333a 666b 999c DDDb",
    "333a 6666a 999a NEWS", "333a 6666b 999c NEWS",
    "333a 666a 999a 33333b",
    "FF 3a 66a 999a 333b 66b 9b",
    "FF 369Da 369Db 369Dc", # concealed
    # Mad Math
    "333a 777a 10a DDDb DDDc",
    "FFFF 3333a 9999a 27a", "FFFF 3333a 9999b 27c",
    "FFFF 5555a 2222a 10a", "FFFF 5555a 2222b 10c",
    "NEWS 2468a 3579a 44a", "NEWS 2468a 3579b 44c", # concealed
    # Big Brain
    "FFF 2222a 7777a DDDa", "FFF 2222a 7777b DDDc",
    "FF 1111a NEWS 6666a", "FF 1111a NEWS 6666b",
    "FF 333a NN E W SS 888a", "FF 333a NN E W SS 888b",
    "N EE 05a 10a 15a 20a WW S", # concealed
    "FF NEWS N0W WE W0N", # concealed
  ]
|
.open_win_definition = [
    # 2026
    "222a 0000 222b 6666c",
    "DDDa Db 222a 222b 2026c", "DDDa Db 666a 666b 2026c", 
    "FFF NEWS DDDa 2026a",
    "FF 2026a 2222b 2222c", "FF 2026a 6666b 6666c", 
    "NNN EE 2026a WW SSS",
    # 2468
    "F 222a 444a 666a 8888a", "F 222a 444a 666b 8888c",
    "222a NNNN 222b SSSS", "444a NNNN 444b SSSS", "666a NNNN 666b SSSS", "888a NNNN 888b SSSS", "222a EEEE 222b WWWW", "444a EEEE 444b WWWW", "666a EEEE 666b WWWW", "888a EEEE 888b WWWW",
    "FF ZZZ 222a 4444a 66a",
    "FF 2a 4a 666a 8888a DDDa", "FF 2a 4a 666b 8888c DDDa",
    "FF 2222a 4444a|6666a|8888a DDDDa", "FF 4444a 6666a|8888a DDDDa", "FF 6666a 8888a DDDDa", "FF 2222a 4444b|6666b|8888b DDDDc", "FF 4444a 6666b|8888b DDDDc", "FF 6666a 8888b DDDDc",
    "222a 444a 666a 88888a", "222a 444a 666b 88888c",
    "FF 22a 44a 66a 88a 22b 22c", "FF 22a 44a 66a 88a 44b 44c", "FF 22a 44a 66a 88a 66b 66c", "FF 22a 44a 66a 88a 88b 88c",
    # Any Matching Numbers
    "NNN XXX0a XX0b XXX0c SSS", "EEE XXX0a XX0b XXX0c WWW",
    "XXXX0a XXXX0b XXXX0c DDa",
    "XXX0a XXX0b XXX0c DDDDDa",
    "FFF XXXX0a FFF XXXX0b",
    # Consecutive Numbers
        ## TODO: check whether these "runs" can be played descending rather than ascending.
    "FF XXX0a XXX1a XXX2a XXX3a", "FF XXX0a XXX1a XXX2b XXX3b", 
    "XXX0a XXXX1a XXX0b XXXX1b",
    "FFFF ZZ XXX0a XXX1a DDa",
    "XXX0a XX1a XXXX2a XX3a XXX4a",
    "XXX0a XX1a NEWS XX2b XXX3b",
    "FF XX2a XXX1a XXXX0a DDDa", "FF XX2a XXX1b XXXX0c DDDb", 
    "XX0a XXX1a XXXX2a XXXXX3a", "XX0a XXX1a XXXX2a XXXXX3b",
    # 13579
    "NNN 111a 33a 555a SSS", "NNN 111a 33b 555c SSS",
    "EEE 555a 77a 999a WWW", "EEE 555a 77b 999c WWW",
    "111a 5555a 999a DDDDa", "111a 5555b 999a DDDDb",
    "FF ZZZ 333a 5555a 77a", "FF ZZZ 333a 5555b 77c",
    "111a 33a 5555a 77a 999a",
    "FF 1111a 3333a|5555a|7777a|9999a DDDDa", "FF 3333a 5555a|7777a|9999a DDDDa", "FF 5555a 7777a|9999a DDDDa", "FF 7777a 9999a DDDDa", "FF 1111a 3333b|5555b|7777b|9999b DDDDc", "FF 3333a 5555b|7777b|9999b DDDDc", "FF 5555a 7777b|9999b DDDDc", "FF 7777a 9999b DDDDc",
    # Winds and Dragons
    "NNN EEE WWW SSS DDa",
    "FFF DDDa DDDDDb DDDc",
    "DDDa NN EE WW SS DDDb",
    # 369
    "FF 333a 666a 999a DDDa", "FF 333a 666b 999c DDDb",
    "333a 6666a 999a NEWS", "333a 6666b 999c NEWS",
    "333a 666a 999a 33333b",
    "FF 3a 66a 999a 333b 66b 9b",
    # Mad Math
    "333a 777a 10a DDDb DDDc",
    "FFFF 3333a 9999a 27a", "FFFF 3333a 9999b 27c",
    "FFFF 5555a 2222a 10a", "FFFF 5555a 2222b 10c",
    # Big Brain
    "FFF 2222a 7777a DDDa", "FFF 2222a 7777b DDDc",
    "FF 1111a NEWS 6666a", "FF 1111a NEWS 6666b",
    "FF 333a NN E W SS 888a", "FF 333a NN E W SS 888b",
  ]
|
  # TODO: add a rule that concealed hands get a +10 bonus, except for hands that are concealed on the Card. probably do it here, as it appears to replace the jokerless bonus rule?
.singles_win_definition = [
  ]
|
.yaku = [
    { "display_name": "2020 #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 2020a 2222b 2222c"]]}] },
    { "display_name": "2020 #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF RRRR 2020a GGGG"]]}] },
    { "display_name": "2020 #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFFF 22a 222b 2020c"]]}] },
    { "display_name": "2020 #4", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NN EEE 2020a WWW SS"]]}] },
    { "display_name": "2468 #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF 2a 44a 666a 8888a"]]}] },
    { "display_name": "2468 #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["22a 44a 666b 888b DDDDc"]]}] },
    { "display_name": "2468 #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["2222a 4444a 6666a 88a"]]}] },
    { "display_name": "2468 #4", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["222a 444a 6666a 8888a", "222a 444a 6666b 8888b"]]}] },
    { "display_name": "2468 #5", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF 4444a 6666b 24c", "FFFF 6666a 8888b 48c"]]}] },
    { "display_name": "2468 #6", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["22a 444a 44b 666b 8888c"]]}] },
    { "display_name": "2468 #7", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["22a 444a DDDDa 666a 88a"]]}] },
    { "display_name": "2468 #8", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 222a 444b 666b 888a"]]}] },
    { "display_name": "Any Like Numbers #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF XXXX0a XXXX0b XXXX0c"]]}] },
    { "display_name": "Any Like Numbers #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF XXXX0a DDa XXXX0b DDb"]]}] },
    { "display_name": "Any Like Numbers #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFFF XX0a XXX0b XXXX0c"]]}] },
    { "display_name": "Quints #1", "value": 40, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFFF DDDDa XXXXX0a|XXXXX0b|XXXXX0c"]]}] },
    { "display_name": "Quints #2", "value": 45, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XX0a XX1a XXXXX2b XXXXX2c"]]}] },
    { "display_name": "Quints #3", "value": 45, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["11111a 3333a 55555a", "55555a 7777a 99999a"]]}] },
    { "display_name": "Quints #4", "value": 45, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXXXX0a XX1a XX2a XXXXX3a"]]}] },
    { "display_name": "Consecutive Run #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["11a 22a 333a 444a 55555a", "55a 66a 777a 888a 9999a"]]}] },
    { "display_name": "Consecutive Run #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF XXXX0a XX1a XXXX2a", "FFFF XXXX0a XX1b XXXX2c"]]}] },
    { "display_name": "Consecutive Run #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXX0a XXX1a XXXX2b XXXX3b"]]}] },
    { "display_name": "Consecutive Run #4", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXX0a XXXX1a XXX2a DDDDa"]]}] },
    { "display_name": "Consecutive Run #5", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XX0a XX1a XX2a XXXX3b XXXX4c"]]}] },
    { "display_name": "Consecutive Run #6", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF X0a XX1a XXX2a XXXX3a"]]}] },
    { "display_name": "Consecutive Run #7", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXX0a XX1a XXX2a DDDb DDDc"]]} ] },
    { "display_name": "Consecutive Run #8", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXX0a XXX1a XXX0b XXX1b XX2c"]]} ] },
    { "display_name": "13579 #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["11a 33a 555a 777a 9999a", "11a 33a 555b 777b 9999c"]]}] },
    { "display_name": "13579 #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF 3333a 5555b 15c", "FFFF 5555a 7777b 35c"]]}] },
    { "display_name": "13579 #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["111a 333a 3333b 5555b", "555a 777a 7777b 9999b"]]}] },
    { "display_name": "13579 #4", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["1111a 33b 33a 33c 5555a"]]}] },
    { "display_name": "13579 #5", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["5555a 77b 77a 77c 9999a"]]}] },
    { "display_name": "13579 #6", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["111a 3333a 555a DDDDa", "555a 7777a 999a DDDDa"]]}] },
    { "display_name": "13579 #7", "value": 35, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 1a 33a 555a 5b 77b 999b"]]} ] },
    { "display_name": "Winds and Dragons #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NNNN EEE WWW SSSS"]]}] },
    { "display_name": "Winds and Dragons #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF DDDDa NEWS DDDDb"]]}] },
    { "display_name": "Winds and Dragons #3", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NNNN 11a 11b 11c SSSS", "NNNN 33a 33b 33c SSSS", "NNNN 55a 55b 55c SSSS", "NNNN 77a 77b 77c SSSS", "NNNN 99a 99b 99c SSSS"]]}] },
    { "display_name": "Winds and Dragons #4", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["EEEE 22a 22b 22c WWWW", "EEEE 44a 44b 44c WWWW", "EEEE 66a 66b 66c WWWW", "EEEE 88a 88b 88c WWWW"]]}] },
    { "display_name": "Winds and Dragons #5", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NN EEE DDDDa WWW SS"]]}] },
    { "display_name": "Winds and Dragons #6", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF NNNN 2020a SSSS", "FF EEEE 2020a WWWW"]]}] },
    { "display_name": "Winds and Dragons #7", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF NNN EEE WWW SSS"]]} ] },
    { "display_name": "369 #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["333a 666a 6666b 9999b"]]}] },
    { "display_name": "369 #2", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["33a 66a 99a 3333b 3333c", "33a 66a 99a 6666b 6666c", "33a 66a 99a 9999b 9999c"]]}] },
    { "display_name": "369 #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["333a 6666a 999a DDDDa"]]}] },
    { "display_name": "369 #4", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["33a 666a 33b 666b 9999c"]]}] },
    { "display_name": "369 #5", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 3333a 6666a 9999a", "FF 3333a 6666b 9999c"]]}] },
    { "display_name": "369 #6", "value": 35, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 3a 66a 999a 3b 66b 999b"]]}] },
    { "display_name": "Singles and Pairs #1", "value": 50, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NN EE WW SS XX0a XX1a XX2a"]]} ] },
    { "display_name": "Singles and Pairs #2", "value": 50, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF XX0a XX1a XX2a XX3a XX4a DDa"]]} ] },
    { "display_name": "Singles and Pairs #3", "value": 50, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF XX0a XX1a XX0b XX1b XX0c XX1c"]]} ] },
    { "display_name": "Singles and Pairs #4", "value": 50, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 2468a DDa 2468b DDb"]]} ] },
    { "display_name": "Singles and Pairs #5", "value": 50, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["336a 33669b 336699c"]]} ] },
    { "display_name": "Singles and Pairs #6", "value": 50, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["11a 357a 99a 11b 357b 99b"]]} ] },
    { "display_name": "Singles and Pairs #7", "value": 85, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 2020a NEWS 2020b"]]} ] }
  ]
