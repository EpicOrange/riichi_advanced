.win_definition = [
    # 2025
    "FFFF 2025a 222b 222c", "FFFF 2025a 555b 555c",
    "222a 0000 222c 5555c",
    "2025a 222b 555b DDDDc",
    "FF 222a 000 222b 555c", # concealed
    # 2468
    "222a 4444a 666a 8888a", "222a 4444a 666b 8888b",
    "FF 2222a 4444b 6666c", "FF 2222a 6666b 8888c",
    "22a 444a 66a 888a DDDDa",
    "FFFF 2468a 222b 222c", "FFFF 2468a 444b 444c", "FFFF 2468a 666b 666c", "FFFF 2468a 888b 888c", 
    "FFF 22a 44a 666a 8888a",
    "222a 4444a 666a 88b 88c",
    "FF 2222a DDDDb 2222c", "FF 4444a DDDDb 4444c", "FF 6666a DDDDb 6666c", "FF 8888a DDDDb 8888c",
    "22a 44a 66a 88a 222b 222c", "22a 44a 66a 88a 444b 444c", "22a 44a 66a 88a 666b 666c", "22a 44a 66a 88a 888b 888c", # concealed
    # Any Like Numbers
    "FF XXXX0a Da XXXX0b Db XX0c",
    "FFFF XX0a XXX0b XXX0c XX0a",
    "FF XXX0a XXX0b XXX0c DDDa", # concealed
    # Quints
    "FF XXX0a XXXX1b XXXXX2c",
    "XXXXX0a ZZZZ XXXXX1a",
    "FF XXXXX0a XX0b XXXXX0c",
    # Consecutive Run
    "11a 222a 3333a 444a 55a", "55a 666a 7777a 888a 99a",
    "XXX0a XXXX1a XXX2a XXXX3a", "XXX0a XXXX1a XXX2b XXXX3b",
    "FFFF XXXX0a XX1a XXXX2a", "FFFF XXXX0a XX1b XXXX2c",
    "FFF X0a X1a X2a XXXX3b XXXX4c",
    "FF XX0a XXX1a XXXX2a DDDa",
    "XXX0a XXX1a XXXX2a DDb DDc",
    "XX0a X1a X2a X3a X4a XXXX0b XXXX0c", "X0a XX1a X2a X3a X4a XXXX1b XXXX1c", "X0a X1a XX2a X3a X4a XXXX2b XXXX2c", "X0a X1a X2a XX3a X4a XXXX3b XXXX3c", "X0a X1a X2a X3a XX4a XXXX4b XXXX4c",
    "FF X0a XX1a XXX2a X0b XX1b XXX2b", # concealed
    # 13579
    "11a 333a 5555a 777a 99a", "11a 333a 5555b 777c 99c",
    "111a 3333a 333b 5555b", "555a 7777a 777b 9999b",
    "1111a 333a 5555a DDDa", "5555a 777a 9999a DDDa",
    "FFFF 1111a 9999a 10b",
    "FFF 135a 7777a 9999a", "FFF 135a 7777b 9999b",
    "111a 333a 5555a DDb DDc", "555a 777a 9999a DDb DDc",
    "11a 333a NEWS 333b 55b", "55a 777a NEWS 777b 99b",
    "1111a 33b 55b 77b 9999a",
    "FF 11a 33a 111b 333b 55c", "FF 55a 77a 555b 777b 99c", # concealed
    # Winds and Dragons
    "NNNN EEE WWW SSSS", "NNN EEEE WWWW SSS",
    "FF X0a X1a X2a DDb DDDc DDDDa", "FF X0a X1a X2a DDa DDDb DDDDc", "FF X0a X1a X2a DDc DDDa DDDDb", # apparently the run here can match any of the dragons, not just the kong
    "FFF NN EE WWW SSSS",
    "FFFF DDDa NEWS DDDb",
    "NNNN 1a 11b 111c SSSS", "NNNN 3a 33b 333c SSSS", "NNNN 5a 55b 555c SSSS", "NNNN 7a 77b 777c SSSS", "NNNN 9a 99b 999c SSSS",
    "EEEE 2a 22b 222c WWWW", "EEEE 4a 44b 444c WWWW", "EEEE 6a 66b 666c WWWW", "EEEE 8a 88b 888c WWWW",
    "NN EEE WWW SS 2025a", "NNN EE WW SSS 2025a",
    "NN EE WWW SSS DDDDa", # concealed
    # 369
    "333a 6666a 666b 9999b", "333a 6666a 666b 9999c",
    "FF 3333a 6666a 9999a", "FF 3333a 6666b 9999c",
    "3333a DDDa 3333b DDDb", "6666a DDDa 6666b DDDb", "9999a DDDa 9999b DDDb", 
    "FFF 3333a 369b 9999a",
    "33a 66a 99a 3333b 3333c", "33a 66a 99a 6666b 6666c", "33a 66a 99a 9999b 9999c", 
    "FF 333a Da 666b Db 999c Dc", # concealed
    # Singles and Pairs
    "NN EW SS XX0a XX1a XX2a XX3a", # concealed
    "FF 2468a DDa 2468b DDb", # concealed
    "336699a 336699b 33c", "336699a 336699b 66c", "336699a 336699b 99c", # concealed
    "FF XX0a XX1a XX0b XX1b XX0c XX1c", # concealed
    "11a 33a 55a 77a 99a 11b 11c", "11a 33a 55a 77a 99a 33b 33c", "11a 33a 55a 77a 99a 55b 55c", "11a 33a 55a 77a 99a 77b 77c", "11a 33a 55a 77a 99a 99b 99c", # concealed
    "FF 2025a 2025b 2025c" # concealed
  ]
|
.open_win_definition = [
    # 2025
    "FFFF 2025a 222b 222c", "FFFF 2025a 555b 555c",
    "222a 0000 222c 5555c",
    "2025a 222b 555b DDDDc",
    # 2468
    "222a 4444a 666a 8888a", "222a 4444a 666b 8888b",
    "FF 2222a 4444b 6666c", "FF 2222a 6666b 8888c",
    "22a 444a 66a 888a DDDDa",
    "FFFF 2468a 222b 222c", "FFFF 2468a 444b 444c", "FFFF 2468a 666b 666c", "FFFF 2468a 888b 888c", 
    "FFF 22a 44a 666a 8888a",
    "222a 4444a 666a 88b 88c",
    "FF 2222a DDDDb 2222c", "FF 4444a DDDDb 4444c", "FF 6666a DDDDb 6666c", "FF 8888a DDDDb 8888c",
    # Any Like Numbers
    "FF XXXX0a Da XXXX0b Db XX0c",
    "FFFF XX0a XXX0b XXX0c XX0a",
    # Quints
    "FF XXX0a XXXX1b XXXXX2c",
    "XXXXX0a ZZZZ XXXXX1a",
    "FF XXXXX0a XX0b XXXXX0c",
    # Consecutive Run
    "11a 222a 3333a 444a 55a", "55a 666a 7777a 888a 99a",
    "XXX0a XXXX1a XXX2a XXXX3a", "XXX0a XXXX1a XXX2b XXXX3b",
    "FFFF XXXX0a XX1a XXXX2a", "FFFF XXXX0a XX1b XXXX2c",
    "FFF X0a X1a X2a XXXX3b XXXX4c",
    "FF XX0a XXX1a XXXX2a DDDa",
    "XXX0a XXX1a XXXX2a DDb DDc",
    "XX0a X1a X2a X3a X4a XXXX0b XXXX0c", "X0a XX1a X2a X3a X4a XXXX1b XXXX1c", "X0a X1a XX2a X3a X4a XXXX2b XXXX2c", "X0a X1a X2a XX3a X4a XXXX3b XXXX3c", "X0a X1a X2a X3a XX4a XXXX4b XXXX4c",
    # 13579
    "11a 333a 5555a 777a 99a", "11a 333a 5555b 777c 99c",
    "111a 3333a 333b 5555b", "555a 7777a 777b 9999b",
    "1111a 333a 5555a DDDa", "5555a 777a 9999a DDDa",
    "FFFF 1111a 9999a 10b",
    "FFF 135a 7777a 9999a", "FFF 135a 7777b 9999b",
    "111a 333a 5555a DDb DDc", "555a 777a 9999a DDb DDc",
    "11a 333a NEWS 333b 55b", "55a 777a NEWS 777b 99b",
    "1111a 33b 55b 77b 9999a",
    # Winds and Dragons
    "NNNN EEE WWW SSSS", "NNN EEEE WWWW SSS",
    "FF X0a X1a X2a DDb DDDc DDDDa", "FF X0a X1a X2a DDa DDDb DDDDc", "FF X0a X1a X2a DDc DDDa DDDDb",
    "FFF NN EE WWW SSSS",
    "FFFF DDDa NEWS DDDb",
    "NNNN 1a 11b 111c SSSS", "NNNN 3a 33b 333c SSSS", "NNNN 5a 55b 555c SSSS", "NNNN 7a 77b 777c SSSS", "NNNN 9a 99b 999c SSSS",
    "EEEE 2a 22b 222c WWWW", "EEEE 4a 44b 444c WWWW", "EEEE 6a 66b 666c WWWW", "EEEE 8a 88b 888c WWWW",
    "NN EEE WWW SS 2025a", "NNN EE WW SSS 2025a",
    # 369
    "333a 6666a 666b 9999b", "333a 6666a 666b 9999c",
    "FF 3333a 6666a 9999a", "FF 3333a 6666b 9999c",
    "3333a DDDa 3333b DDDb", "6666a DDDa 6666b DDDb", "9999a DDDa 9999b DDDb", 
    "FFF 3333a 369b 9999a",
    "33a 66a 99a 3333b 3333c", "33a 66a 99a 6666b 6666c", "33a 66a 99a 9999b 9999c"
  ]
|
.singles_win_definition = [
    "NN EW SS XX0a XX1a XX2a XX3a", # concealed
    "FF 2468a DDa 2468b DDb", # concealed
    "336699a 336699b 33c", "336699a 336699b 66c", "336699a 336699b 99c", # concealed
    "FF XX0a XX1a XX0b XX1b XX0c XX1c", # concealed
    "11a 33a 55a 77a 99a 11b 11c", "11a 33a 55a 77a 99a 33b 33c", "11a 33a 55a 77a 99a 55b 55c", "11a 33a 55a 77a 99a 77b 77c", "11a 33a 55a 77a 99a 99b 99c", # concealed
    "FF 2025a 2025b 2025c" # concealed
  ]
|
.yaku = [
    { "display_name": "2025 #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF 2025a 222b 222c", "FFFF 2025a 555b 555c"]]}] },
    { "display_name": "2025 #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["222a 0000 222c 5555c"]]}] },
    { "display_name": "2025 #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["2025a 222b 555b DDDDc"]]}] },
    { "display_name": "2025 #4", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 222a 000 222b 555c"]]} ] },
    { "display_name": "2468 #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["222a 4444a 666a 8888a", "222a 4444a 666b 8888b"]]}] },
    { "display_name": "2468 #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 2222a 4444b 6666c", "FF 2222a 6666b 8888c"]]}] },
    { "display_name": "2468 #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["22a 444a 66a 888a DDDDa"]]}] },
    { "display_name": "2468 #4", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF 2468a 222b 222c", "FFFF 2468a 444b 444c", "FFFF 2468a 666b 666c", "FFFF 2468a 888b 888c"]]}] },
    { "display_name": "2468 #5", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF 22a 44a 666a 8888a"]]}] },
    { "display_name": "2468 #6", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["222a 4444a 666a 88b 88c"]]}] },
    { "display_name": "2468 #7", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 2222a DDDDb 2222c", "FF 4444a DDDDb 4444c", "FF 6666a DDDDb 6666c", "FF 8888a DDDDb 8888c"]]}] },
    { "display_name": "2468 #8", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["22a 44a 66a 88a 222b 222c", "22a 44a 66a 88a 444b 444c", "22a 44a 66a 88a 666b 666c", "22a 44a 66a 88a 888b 888c"]]} ] },
    { "display_name": "Any Like Numbers #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF XXXX0a Da XXXX0b Db XX0c"]]}] },
    { "display_name": "Any Like Numbers #2", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF XX0a XXX0b XXX0c XX0a"]]}] },
    { "display_name": "Any Like Numbers #3", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF XXX0a XXX0b XXX0c DDDa"]]} ] },
    { "display_name": "Quints #1", "value": 40, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF XXX0a XXXX1b XXXXX2c"]]}] },
    { "display_name": "Quints #2", "value": 45, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXXXX0a ZZZZ XXXXX1a"]]}] },
    { "display_name": "Quints #3", "value": 45, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF XXXXX0a XX0b XXXXX0c"]]}] },
    { "display_name": "Consecutive Run #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["11a 222a 3333a 444a 55a", "55a 666a 7777a 888a 99a"]]}] },
    { "display_name": "Consecutive Run #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXX0a XXXX1a XXX2a XXXX3a", "XXX0a XXXX1a XXX2b XXXX3b"]]}] },
    { "display_name": "Consecutive Run #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF XXXX0a XX1a XXXX2a", "FFFF XXXX0a XX1b XXXX2c"]]}] },
    { "display_name": "Consecutive Run #4", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF X0a X1a X2a XXXX3b XXXX4c"]]}] },
    { "display_name": "Consecutive Run #5", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF XX0a XXX1a XXXX2a DDDa"]]}] },
    { "display_name": "Consecutive Run #6", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXX0a XXX1a XXXX2a DDb DDc"]]}] },
    { "display_name": "Consecutive Run #7", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XX0a X1a X2a X3a X4a XXXX0b XXXX0c", "X0a XX1a X2a X3a X4a XXXX1b XXXX1c", "X0a X1a XX2a X3a X4a XXXX2b XXXX2c", "X0a X1a X2a XX3a X4a XXXX3b XXXX3c", "X0a X1a X2a X3a XX4a XXXX4b XXXX4c"]]}] },
    { "display_name": "Consecutive Run #8", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF X0a XX1a XXX2a X0b XX1b XXX2b"]]} ] },
    { "display_name": "13579 #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["11a 333a 5555a 777a 99a", "11a 333a 5555b 777c 99c"]]}] },
    { "display_name": "13579 #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["111a 3333a 333b 5555b", "555a 7777a 777b 9999b"]]}] },
    { "display_name": "13579 #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["1111a 333a 5555a DDDa", "5555a 777a 9999a DDDa"]]}] },
    { "display_name": "13579 #4", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF 1111a 9999a 10b"]]}] },
    { "display_name": "13579 #5", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF 135a 7777a 9999a", "FFF 135a 7777b 9999b"]]}] },
    { "display_name": "13579 #6", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["111a 333a 5555a DDb DDc", "555a 777a 9999a DDb DDc"]]}] },
    { "display_name": "13579 #7", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["11a 333a NEWS 333b 55b", "55a 777a NEWS 777b 99b"]]}] },
    { "display_name": "13579 #8", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["1111a 33b 55b 77b 9999a"]]}] },
    { "display_name": "13579 #9", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 11a 33a 111b 333b 55c", "FF 55a 77a 555b 777b 99c"]]} ] },
    { "display_name": "Winds and Dragons #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NNNN EEE WWW SSSS", "NNN EEEE WWWW SSS"]]}] },
    { "display_name": "Winds and Dragons #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF X0a X1a X2a DDb DDDc DDDDa", "FF X0a X1a X2a DDa DDDb DDDDc", "FF X0a X1a X2a DDc DDDa DDDDb"]]}] },
    { "display_name": "Winds and Dragons #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF NN EE WWW SSSS"]]}] },
    { "display_name": "Winds and Dragons #4", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF DDDa NEWS DDDb"]]}] },
    { "display_name": "Winds and Dragons #5", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NNNN 1a 11b 111c SSSS", "NNNN 3a 33b 333c SSSS", "NNNN 5a 55b 555c SSSS", "NNNN 7a 77b 777c SSSS", "NNNN 9a 99b 999c SSSS"]]}] },
    { "display_name": "Winds and Dragons #6", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["EEEE 2a 22b 222c WWWW", "EEEE 4a 44b 444c WWWW", "EEEE 6a 66b 666c WWWW", "EEEE 8a 88b 888c WWWW"]]}] },
    { "display_name": "Winds and Dragons #7", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NN EEE WWW SS 2025a", "NNN EE WW SSS 2025a"]]}] },
    { "display_name": "Winds and Dragons #8", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NN EE WWW SSS DDDDa"]]} ] },
    { "display_name": "369 #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["333a 6666a 666b 9999b", "333a 6666a 666b 9999c"]]}] },
    { "display_name": "369 #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 3333a 6666a 9999a", "FF 3333a 6666b 9999c"]]}] },
    { "display_name": "369 #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["3333a DDDa 3333b DDDb", "6666a DDDa 6666b DDDb", "9999a DDDa 9999b DDDb"]]}] },
    { "display_name": "369 #4", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF 3333a 369b 9999a"]]}] },
    { "display_name": "369 #5", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["33a 66a 99a 3333b 3333c", "33a 66a 99a 6666b 6666c", "33a 66a 99a 9999b 9999c"]]}] },
    { "display_name": "369 #6", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 333a Da 666b Db 999c Dc"]]}] },
    { "display_name": "Singles and Pairs #1", "value": 50, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NN EW SS XX0a XX1a XX2a XX3a"]]} ] },
    { "display_name": "Singles and Pairs #2", "value": 50, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 2468a DDa 2468b DDb"]]} ] },
    { "display_name": "Singles and Pairs #3", "value": 50, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["336699a 336699b 33c", "336699a 336699b 66c", "336699a 336699b 99c"]]} ] },
    { "display_name": "Singles and Pairs #4", "value": 50, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF XX0a XX1a XX0b XX1b XX0c XX1c"]]} ] },
    { "display_name": "Singles and Pairs #5", "value": 50, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["11a 33a 55a 77a 99a 11b 11c", "11a 33a 55a 77a 99a 33b 33c", "11a 33a 55a 77a 99a 55b 55c", "11a 33a 55a 77a 99a 77b 77c", "11a 33a 55a 77a 99a 99b 99c"]]} ] },
    { "display_name": "Singles and Pairs #6", "value": 75, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 2025a 2025b 2025c"]]} ] }
  ]
