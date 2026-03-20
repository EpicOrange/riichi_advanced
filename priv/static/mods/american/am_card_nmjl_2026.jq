.win_definition = [
    # 2026
    "222a 000 2222b 6666b",
    "2026a DDDa 2222b|6666b DDDb",
    "FFF 2026a 222b 6666c",
    "22a 00 222b 666b NEWS", # (apparently this one is exposed, not concealed)
    # 2468
    "222a 444a 6666a 8888a", "222a 444a 6666b 8888b",
    "FF 2222a 44b 66b 8888a",
    "EE 22a 444a 666a 88a WW",
    "2222a DDDa 8888b DDDb",
    "FFF 22a 44a 666a 8888a",
    "2468a 2222b Db 2222c Dc", "2468a 4444b Db 4444c Dc", "2468a 6666b Db 6666c Dc", "2468a 8888b Db 8888c Dc",
    "FFF 2468a FFF 2222b|4444b|6666b|8888b",
    "FF 246a 888a 246b 888b",  # concealed
    # Any Like Numbers
    "XXXX0a FFFFFF XXXX0c",
    "XXXX0a Da XXX0b Db XXXX0c Dc",
    "FF XXXX0a XX0b XXXX0c DDa",
    # Quints
    "XXXXX0a XXXX0b XXXXX0c",
    "FF XXXXX0a XX1a XXXXX2a",
    "XXXXX0a XXXXX1a|XXXXX2a|XXXXX3a|XXXXX4a|XXXXX5a|XXXXX6a|XXXXX7a|XXXXX8a DDDDb",
    # Consecutive Run
    "11a 222a 33a 444a 5555a", "55a 666a 77a 888a 9999a",
    "FFF XXXX0a X1a X2a X3a XXXX4a", "FFF XXXX0a X1b X2b X3b XXXX4a",
    "XX0a XX1a XXX0b XXX1b XXXX2c",
    "XXX0a XXX1a XXXX2a XXXX3a", "XXX0a XXX1a XXXX2b XXXX3b",
    "FF XX0a XX1a XXX2a DDDDa", "FF XX0a XX1b XXX2a DDDDb",
    "XXXX0a FFFFFF XXXX1a",
    "FF XXXX0a XXXX1a XXXX2a", "FF XXXX0a XXXX1b XXXX2c",
    "X0a XX1a XXX2a X0b XX1b XXX2b XX3c", # concealed
    # 13579
    "11a 333a 55a 777a 9999a", "11a 333a 55b 777c 9999c",
    "111a 333a 3333b 5555b", "555a 777a 7777b 9999b",
    "NN 1111a 33a 5555a SS", "NN 5555a 77a 9999a SS",
    "113579a 1111b 1111c", "133579a 3333b 3333c", "135579a 5555b 5555c", "135779a 7777b 7777c", "135799a 9999b 9999c",
    "FFF 11a 33a 555a DDDDa", "FFF 55a 77a 999a DDDDa",
    "11a 33a 111b 333b 5555c", "55a 77a 555b 777b 9999c",
    "1111a 33a 55a 77a 9999a", "1111a 33b 55b 77b 9999a",
    "FF 11a 33a 55a 111b 111c", "FF 55a 77a 99a 555b 555c", # concealed
    "FF 135a 777a 999a DDDb", # concealed
    # Winds and Dragons
    "NNNN EEE WWW SSSS", "NNN EEEE WWWW SSS",
    "X0a X1a X2a X3a DDDb DDDc DDDDa", "X0a X1a X2a X3a DDDa DDDb DDDDc",
    "NNN 1111b 1111c SSS", "NNN 3333b 3333c SSS", "NNN 5555b 5555c SSS", "NNN 7777b 7777c SSS", "NNN 9999b 9999c SSS",
    "EEE 2222b 2222c WWW", "EEE 4444b 4444c WWW", "EEE 6666b 6666c WWW", "EEE 8888b 8888c WWW",
    "FFF ZZZZ FFF DDDD",
    "1a N 2a EE 3a WWW 4a SSSS",
    "FF NNNN SSSS DDa DDb", "FF EEEE WWWW DDa DDb", 
    "NN EEE 2026a WWW SS", # concealed
    # 369
    "333a 666a 6666b 9999b", "333a 666a 6666b 9999c",
    "33a 66a 333b 666b 9999c",
    "FFF 33a 666a 99a DDDDa", "FFF 33a 666a 99a DDDDb",
    "33a 66a 666b 999b NEWS",
    "FF 3369a 3333b 3333c", "FF 3669a 6666b 6666c", "FF 3699a 9999b 9999c",
    "FF 333a 666a 999a 369b", # concealed
    # Singles and Pairs
    "NN EE WW SS X0a Da X0b Db X0c Dc", # concealed
    "2a 4a 66a 88a 2a 4a 66b 88b 88c", # concealed
    "FF 3369a 3669b 3699c", # concealed
    "XX0a XX1a XX2a XX3a XX4a XX5a XX6a", # concealed
    "11a 357a 99a 11b 357b 99b", # concealed
    "FF 2026a 2026b 2026c" # concealed
  ]
|
.open_win_definition = [
    # 2026
    "222a 000 2222b 6666b",
    "2026a DDDa 2222b|6666b DDDb",
    "FFF 2026a 222b 6666c",
    "22a 00 222b 666b NEWS", # (apparently this one is exposed, not concealed)
    # 2468
    "222a 444a 6666a 8888a", "222a 444a 6666b 8888b",
    "FF 2222a 44b 66b 8888a",
    "EE 22a 444a 666a 88a WW",
    "2222a DDDa 8888b DDDb",
    "FFF 22a 44a 666a 8888a",
    "2468a 2222b Db 2222c Dc", "2468a 4444b Db 4444c Dc", "2468a 6666b Db 6666c Dc", "2468a 8888b Db 8888c Dc",
    "FFF 2468a FFF 2222b|4444b|6666b|8888b",
    # Any Like Numbers
    "XXXX0a FFFFFF XXXX0c",
    "XXXX0a Da XXX0b Db XXXX0c Dc",
    "FF XXXX0a XX0b XXXX0c DDa",
    # Quints
    "XXXXX0a XXXX0b XXXXX0c",
    "FF XXXXX0a XX1a XXXXX2a",
    "XXXXX0a XXXXX1a|XXXXX2a|XXXXX3a|XXXXX4a|XXXXX5a|XXXXX6a|XXXXX7a|XXXXX8a DDDDb",
    # Consecutive Run
    "11a 222a 33a 444a 5555a", "55a 666a 77a 888a 9999a",
    "FFF XXXX0a X1a X2a X3a XXXX4a", "FFF XXXX0a X1b X2b X3b XXXX4a",
    "XX0a XX1a XXX0b XXX1b XXXX2c",
    "XXX0a XXX1a XXXX2a XXXX3a", "XXX0a XXX1a XXXX2b XXXX3b",
    "FF XX0a XX1a XXX2a DDDDa", "FF XX0a XX1b XXX2a DDDDb",
    "XXXX0a FFFFFF XXXX1a",
    "FF XXXX0a XXXX1a XXXX2a", "FF XXXX0a XXXX1b XXXX2c",
    # 13579
    "11a 333a 55a 777a 9999a", "11a 333a 55b 777c 9999c",
    "111a 333a 3333b 5555b", "555a 777a 7777b 9999b",
    "NN 1111a 33a 5555a SS", "NN 5555a 77a 9999a SS",
    "113579a 1111b 1111c", "133579a 3333b 3333c", "135579a 5555b 5555c", "135779a 7777b 7777c", "135799a 9999b 9999c",
    "FFF 11a 33a 555a DDDDa", "FFF 55a 77a 999a DDDDa",
    "11a 33a 111b 333b 5555c", "55a 77a 555b 777b 9999c",
    "1111a 33a 55a 77a 9999a", "1111a 33b 55b 77b 9999a",
    # Winds and Dragons
    "NNNN EEE WWW SSSS", "NNN EEEE WWWW SSS",
    "X0a X1a X2a X3a DDDb DDDc DDDDa", "X0a X1a X2a X3a DDDa DDDb DDDDc",
    "NNN 1111b 1111c SSS", "NNN 3333b 3333c SSS", "NNN 5555b 5555c SSS", "NNN 7777b 7777c SSS", "NNN 9999b 9999c SSS",
    "EEE 2222b 2222c WWW", "EEE 4444b 4444c WWW", "EEE 6666b 6666c WWW", "EEE 8888b 8888c WWW",
    "FFF ZZZZ FFF DDDD",
    "1a N 2a EE 3a WWW 4a SSSS",
    "FF NNNN SSSS DDa DDb", "FF EEEE WWWW DDa DDb", 
    # 369
    "333a 666a 6666b 9999b", "333a 666a 6666b 9999c",
    "33a 66a 333b 666b 9999c",
    "FFF 33a 666a 99a DDDDa", "FFF 33a 666a 99a DDDDb",
    "33a 66a 666b 999b NEWS",
    "FF 3369a 3333b 3333c", "FF 3669a 6666b 6666c", "FF 3699a 9999b 9999c"
  ]
|
.singles_win_definition = [
    "NN EE WW SS X0a Da X0b Db X0c Dc",
    "2a 4a 66a 88a 2a 4a 66b 88b 88c",
    "FF 3369a 3669b 3699c",
    "XX0a XX1a XX2a XX3a XX4a XX5a XX6a",
    "11a 357a 99a 11b 357b 99b",
    "FF 2026a 2026b 2026c"
  ]
|
.yaku = [
    { "display_name": "2026 #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["222a 000 2222b 6666b"]]}] },
    { "display_name": "2026 #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["2026a DDDa 2222b|6666b DDDb"]]}] },
    { "display_name": "2026 #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF 2026a 222b 6666c"]]}] },
    { "display_name": "2026 #4", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["22a 00 222b 666b NEWS"]]}] },
    { "display_name": "2468 #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["222a 444a 6666a 8888a", "222a 444a 6666b 8888b"]]}] },
    { "display_name": "2468 #2", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 2222a 44b 66b 8888a"]]}] },
    { "display_name": "2468 #3", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["EE 22a 444a 666a 88a WW"]]}] },
    { "display_name": "2468 #4", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["2222a DDDa 8888b DDDb"]]}] },
    { "display_name": "2468 #5", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF 22a 44a 666a 8888a"]]}] },
    { "display_name": "2468 #6", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["2468a 2222b Db 2222c Dc", "2468a 4444b Db 4444c Dc", "2468a 6666b Db 6666c Dc", "2468a 8888b Db 8888c Dc"]]}] },
    { "display_name": "2468 #7", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF 2468a FFF 2222b|4444b|6666b|8888b"]]}] },
    { "display_name": "2468 #8", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 246a 888a 246b 888b"]]}] },
    { "display_name": "Any Like Numbers #1", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXXX0a FFFFFF XXXX0c"]]}] },
    { "display_name": "Any Like Numbers #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXXX0a Da XXX0b Db XXXX0c Dc"]]}] },
    { "display_name": "Any Like Numbers #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF XXXX0a XX0b XXXX0c DDa"]]}] },
    { "display_name": "Quints #1", "value": 40, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXXXX0a XXXX0b XXXXX0c"]]}] },
    { "display_name": "Quints #2", "value": 45, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF XXXXX0a XX1a XXXXX2a"]]}] },
    { "display_name": "Quints #3", "value": 40, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXXXX0a XXXXX1a|XXXXX2a|XXXXX3a|XXXXX4a|XXXXX5a|XXXXX6a|XXXXX7a|XXXXX8a DDDDb"]]}] },
    { "display_name": "Consecutive Run #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["11a 222a 33a 444a 5555a", "55a 666a 77a 888a 9999a"]]}] },
    { "display_name": "Consecutive Run #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF XXXX0a X1a X2a X3a XXXX4a", "FFF XXXX0a X1b X2b X3b XXXX4a"]]}] },
    { "display_name": "Consecutive Run #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XX0a XX1a XXX0b XXX1b XXXX2c"]]}] },
    { "display_name": "Consecutive Run #4", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXX0a XXX1a XXXX2a XXXX3a", "XXX0a XXX1a XXXX2b XXXX3b"]]}] },
    { "display_name": "Consecutive Run #5", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF XX0a XX1a XXX2a DDDDa", "FF XX0a XX1b XXX2a DDDDb"]]}] },
    { "display_name": "Consecutive Run #6", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXXX0a FFFFFF XXXX1a"]]}] },
    { "display_name": "Consecutive Run #7", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF XXXX0a XXXX1a XXXX2a", "FF XXXX0a XXXX1b XXXX2c"]]}] },
    { "display_name": "Consecutive Run #8", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["X0a XX1a XXX2a X0b XX1b XXX2b XX3c"]]} ] },
    { "display_name": "13579 #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["11a 333a 55a 777a 9999a", "11a 333a 55b 777c 9999c"]]}] },
    { "display_name": "13579 #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["111a 333a 3333b 5555b", "555a 777a 7777b 9999b"]]}] },
    { "display_name": "13579 #3", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NN 1111a 33a 5555a SS", "NN 5555a 77a 9999a SS"]]}] },
    { "display_name": "13579 #4", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["113579a 1111b 1111c", "133579a 3333b 3333c", "135579a 5555b 5555c", "135779a 7777b 7777c", "135799a 9999b 9999c"]]}] },
    { "display_name": "13579 #5", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF 11a 33a 555a DDDDa", "FFF 55a 77a 999a DDDDa"]]}] },
    { "display_name": "13579 #6", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["11a 33a 111b 333b 5555c", "55a 77a 555b 777b 9999c"]]}] },
    { "display_name": "13579 #7", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["1111a 33a 55a 77a 9999a", "1111a 33b 55b 77b 9999a"]]}] },
    { "display_name": "13579 #8", "value": 35, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 11a 33a 55a 111b 111c", "FF 55a 77a 99a 555b 555c"]]} ] },
    { "display_name": "13579 #9", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], [ "FF 135a 777a 999a DDDb"]]} ] },
    { "display_name": "Winds and Dragons #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NNNN EEE WWW SSSS", "NNN EEEE WWWW SSS"]]}] },
    { "display_name": "Winds and Dragons #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["X0a X1a X2a X3a DDDb DDDc DDDDa", "X0a X1a X2a X3a DDDa DDDb DDDDc"]]}] },
    { "display_name": "Winds and Dragons #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NNN 1111b 1111c SSS", "NNN 3333b 3333c SSS", "NNN 5555b 5555c SSS", "NNN 7777b 7777c SSS", "NNN 9999b 9999c SSS"]]}] },
    { "display_name": "Winds and Dragons #4", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["EEE 2222b 2222c WWW", "EEE 4444b 4444c WWW", "EEE 6666b 6666c WWW", "EEE 8888b 8888c WWW"]]}] },
    { "display_name": "Winds and Dragons #5", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF ZZZZ FFF DDDD"]]}] },
    { "display_name": "Winds and Dragons #6", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["1a N 2a EE 3a WWW 4a SSSS"]]}] },
    { "display_name": "Winds and Dragons #7", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF NNNN SSSS DDa DDb", "FF EEEE WWWW DDa DDb"]]}] },
    { "display_name": "Winds and Dragons #8", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NN EEE 2026a WWW SS"]]} ] },
    { "display_name": "369 #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["333a 666a 6666b 9999b", "333a 666a 6666b 9999c"]]}] },
    { "display_name": "369 #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["33a 66a 333b 666b 9999c"]]}] },
    { "display_name": "369 #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF 33a 666a 99a DDDDa", "FFF 33a 666a 99a DDDDb"]]}] },
    { "display_name": "369 #4", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["33a 66a 666b 999b NEWS"]]}] },
    { "display_name": "369 #5", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 3369a 3333b 3333c", "FF 3669a 6666b 6666c", "FF 3699a 9999b 9999c"]]}] },
    { "display_name": "369 #6", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 333a 666a 999a 369b"]]}] },
    { "display_name": "Singles and Pairs #1", "value": 50, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NN EE WW SS X0a Da X0b Db X0c Dc"]]} ] },
    { "display_name": "Singles and Pairs #2", "value": 50, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["2a 4a 66a 88a 2a 4a 66b 88b 88c"]]} ] },
    { "display_name": "Singles and Pairs #3", "value": 50, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 3369a 3669b 3699c"]]} ] },
    { "display_name": "Singles and Pairs #4", "value": 50, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XX0a XX1a XX2a XX3a XX4a XX5a XX6a"]]} ] },
    { "display_name": "Singles and Pairs #5", "value": 50, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["11a 357a 99a 11b 357b 99b"]]} ] },
    { "display_name": "Singles and Pairs #6", "value": 75, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 2026a 2026b 2026c"]]} ] }
  ]
|
# The 2026 Card includes hands with a Sextet, so we have to implement that here:
.buttons."4_am_sextet" = {
    "display_name": "Sextet",
    "call": [[0, 0, 0, 0, 0]],
    "call_name": "am_sextet",
    "call_conditions": [
      {"name": "hand_length_at_least", "opts": [6]},
      {"name": "not_called_tile_contains", "opts": [["1j"], 1]},
      {"name": "call_contains", "opts": [["1m","2m","3m","4m","5m","6m","7m","8m","9m","1p","2p","3p","4p","5p","6p","7p","8p","9p","1s","2s","3s","4s","5s","6s","7s","8s","9s","1z","2z","3z","4z","0z","6z","7z","1f","2f","3f","4f","1g","2g","3g","4g"], 1]}
    ],
    "show_when": [{"name": "status_missing", "opts": ["match_start", "dead_hand"]}, "not_our_turn", "not_no_tiles_remaining", "someone_else_just_discarded", "call_available"],
    "actions": [["big_text", "Sextet"], ["call"], ["change_turn", "self"]],
    "precedence_over": ["am_pung", "am_kong", "am_quint", "am_sextet"]
}
|
# Other calls still have precedence over Sextets
.buttons."1_am_pung"."precedence_over" += ["am_sextet"]
|
.buttons."2_am_kong"."precedence_over" += ["am_sextet"]
|
.buttons."3_am_quint"."precedence_over" += ["am_sextet"]
|
.buttons."mahjong_heavenly"."precedence_over" += ["am_sextet"]
|
.buttons."mahjong_draw"."precedence_over" += ["am_sextet"]
|
.buttons."mahjong_discard"."precedence_over" += ["am_sextet"]