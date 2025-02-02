.win_definition = [
    # 2468
    "FFFF 2a 44a 666a 8888a",
    "22a 4444a 666b 666c 88a",
    "222a 444a 6666b 8888b",
    "22a 44a 444b 666b 8888c",
    "FF 4444a 8888a DDDDa",
    "FF 4444a 8888b DDDDc",
    "FF 2222a 44b 66b 8888c",
    "222a 444a 666a 888a DDa", # concealed
    # Any Like Numbers
    "FFFF XXXX0a XX0b XXXX0c",
    "FF XXXX0a DDa XXXX0b DDb",
    "FFF XXXX0a DDDDb XXXX0c",
    "XX0a DDa XXX0b DDDb XXXX0c", # concealed
    # Math
    "FFFF 4444a 8888b 32c",
    "DDDDa 3333b 7777c 21a",
    "FF 3333a 4444a 7777a",
    "FF 3333a 4444b 7777c",
    "FFFF 5555a 6666a 11a",
    "FFFF 5555a 6666b 11c",
    "DDa 8888a 3333a 5555a",
    "DDa 8888b 3333c 5555a",
    "333a 444a 555a 222a 00", # concealed
    # Quints
    "XXXXX0a XXXX1a XXX2a XX3a",
    "FFFFF DDDDDa XXXX0a",
    "11111a 3333a 555a DDa",
    "55555a 7777a 999a DDa",
    "FFFFF 33a 666a 9999a",
    "FFFFF 33a 666b 9999c",
    # Consecutive Run
    "11a 22a 333a 444a 5555a",
    "55a 66a 777a 888a 9999a",
    "XX0a XXXX1a XXXX2a XXXX3a",
    "XXXX0a XXX1b XXXX2c DDDc",
    "FFF XXXX0a XXXX1b DDDc",
    "XXXX0a XX1b XX1a XX1c XXXX2a",
    "FF XX0a XXX1a XX2b XXX3b DDc",
    "XXX0a XX1a XXX2a DDDb DDDc", # concealed
    # 13579
    "11a 333a 5555a 777a 99a",
    "11a 333a 5555b 777c 99c",
    "1111a 3333a 333b 555b",
    "5555a 7777a 777b 999b",
    "1111a 333a 5555b DDDb",
    "5555a 777a 9999b DDDb",
    "11a 333a DDDDc 333b 55b",
    "55a 777a DDDDc 777b 99b",
    "11a 33a 55a 7777b 9999c",
    "111a 3333b 555c NEWS", # concealed
    "555a 7777b 999c NEWS", # concealed
    # Winds and Dragons
    "NNNN EEE WWW SSSS",
    "FF DDDDa NEWS DDDDb",
    "FF NNNN RR SSSS", # [TODO: Check whether "red dragon only" and "green dragon only" are implemented. If not, this line will throw up a parser error.]
    "FF EEEE GG WWWW", # [TODO: Check whether "red dragon only" and "green dragon only" are implemented. If not, this line will throw up a parser error.]
    "FFFF N EE WWW SSSS",
    "FF NN XXXX0a XXXX1b SS",
    "FF EE XXXX0a XXXX1b WW",
    "NNNN DDa DDb DDc SSSS",
    "EEEE DDa DDb DDc WWWW",
    "NN 111a 1111b 111c SS", "NN 333a 3333b 333c SS", "NN 555a 5555b 555c SS", "NN 777a 7777b 777c SS", "NN 999a 9999b 999c SS", # concealed
    "EE 222a 2222b 222c WW", "EE 444a 4444b 444c WW", "EE 666a 6666b 666c WW", "EE 888a 8888b 888c WW", # concealed
    # 369
    "33a 666a 333b 66b 9999c",
    "FFFF 33a 666a 99a DDDa",
    "3333a 66a 9999a DDDDa",
    "FF 3333a 6666a 9999a",
    "FF 3333a 6666b 9999c",
    "FF 33a 66a 99a DDDb DDDc",
    "FF 3a 66a 999a 3b 66b 999b", # concealed
    # Singles and Pairs
    "NN EE WW SS 11a 11b 11c", # concealed
    "FF 11a 33a 55a 77a 99a DDa", # concealed
    "XX0a XX1a XX2a XX3a XX4a XX5a DDa", # concealed
    "FF 2a 4a 66a 88a 22b 44b 6b 8b", # concealed
    "3a 66a 3b 66b 99b 33c 66c 99c", # concealed
    "FF XX0a XX1a XX2a DDb DDc DDa", # concealed
    "FF 0123a 0123b 0123c" #concealed
  ]
|
.open_win_definition = [
    # 2468
    "FFFF 2a 44a 666a 8888a",
    "22a 4444a 666b 666c 88a",
    "222a 444a 6666b 8888b",
    "22a 44a 444b 666b 8888c",
    "FF 4444a 8888a DDDDa",
    "FF 4444a 8888b DDDDc",
    "FF 2222a 44b 66b 8888c",
    # Any Like Numbers
    "FFFF XXXX0a XX0b XXXX0c",
    "FF XXXX0a DDa XXXX0b DDb",
    "FFF XXXX0a DDDDb XXXX0c",
    # Math
    "FFFF 4444a 8888b 32c",
    "DDDDa 3333b 7777c 21a",
    "FF 3333a 4444a 7777a",
    "FF 3333a 4444b 7777c",
    "FFFF 5555a 6666a 11a",
    "FFFF 5555a 6666b 11c",
    "DDa 8888a 3333a 5555a",
    "DDa 8888b 3333c 5555a",
    # Quints
    "XXXXX0a XXXX1a XXX2a XX3a",
    "FFFFF DDDDDa XXXX0a",
    "11111a 3333a 555a DDa",
    "55555a 7777a 999a DDa",
    "FFFFF 33a 666a 9999a",
    "FFFFF 33a 666b 9999c",
    # Consecutive Run
    "11a 22a 333a 444a 5555a",
    "55a 66a 777a 888a 9999a",
    "XX0a XXXX1a XXXX2a XXXX3a",
    "XXXX0a XXX1b XXXX2c DDDc",
    "FFF XXXX0a XXXX1b DDDc",
    "XXXX0a XX1b XX1a XX1c XXXX2a",
    "FF XX0a XXX1a XX2b XXX3b DDc",
    # 13579
    "11a 333a 5555a 777a 99a",
    "11a 333a 5555b 777c 99c",
    "1111a 3333a 333b 555b",
    "5555a 7777a 777b 999b",
    "1111a 333a 5555b DDDb",
    "5555a 777a 9999b DDDb",
    "11a 333a DDDDc 333b 55b",
    "55a 777a DDDDc 777b 99b",
    "11a 33a 55a 7777b 9999c",
    # Winds and Dragons
    "NNNN EEE WWW SSSS",
    "FF DDDDa NEWS DDDDb",
    "FF NNNN RR SSSS", # [TODO: Check whether "red dragon only" and "green dragon only" are implemented. If not, this line will throw up a parser error.]
    "FF EEEE GG WWWW", # [TODO: Check whether "red dragon only" and "green dragon only" are implemented. If not, this line will throw up a parser error.]
    "FFFF N EE WWW SSSS",
    "FF NN XXXX0a XXXX1b SS",
    "FF EE XXXX0a XXXX1b WW",
    "NNNN DDa DDb DDc SSSS",
    "EEEE DDa DDb DDc WWWW",
    # 369
    "33a 666a 333b 66b 9999c",
    "FFFF 33a 666a 99a DDDa",
    "3333a 66a 9999a DDDDa",
    "FF 3333a 6666a 9999a",
    "FF 3333a 6666b 9999c",
    "FF 33a 66a 99a DDDb DDDc"
  ]
|
.singles_win_definition = [
    "NN EE WW SS 11a 11b 11c",
    "FF 11a 33a 55a 77a 99a DDa",
    "XX0a XX1a XX2a XX3a XX4a XX5a DDa",
    "FF 2a 4a 66a 88a 22b 44b 6b 8b",
    "3a 66a 3b 66b 99b 33c 66c 99c",
    "FF XX0a XX1a XX2a DDb DDc DDa",
    "FF 0123a 0123b 0123c"
  ]
|
.yaku = [
    { "display_name": "2468 #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF 2a 44a 666a 8888a"]]}] },
    { "display_name": "2468 #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["22a 4444a 666b 666c 88a"]]}] },
    { "display_name": "2468 #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["222a 444a 6666b 8888b"]]}] },
    { "display_name": "2468 #4", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["22a 44a 444b 666b 8888c"]]}] },
    { "display_name": "2468 #5", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 4444a 8888a DDDDa"]]}] },
    { "display_name": "2468 #6", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 4444a 8888b DDDDc"]]}] },
    { "display_name": "2468 #7", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 2222a 44b 66b 8888c"]]}] },
    { "display_name": "2468 #8", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["222a 444a 666a 888a DDa"]]}] },
    { "display_name": "Any Like Numbers #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF XXXX0a XX0b XXXX0c"]]}] },
    { "display_name": "Any Like Numbers #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF XXXX0a DDa XXXX0b DDb"]]}] },
    { "display_name": "Any Like Numbers #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF XXXX0a DDDDb XXXX0c"]]}] },
    { "display_name": "Any Like Numbers #4", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XX0a DDa XXX0b DDDb XXXX0c"]]}] },
    { "display_name": "Math #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF 4444a 8888b 32c"]]}] },
    { "display_name": "Math #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["DDDDa 3333b 7777c 21a"]]}] },
    { "display_name": "Math #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 3333a 4444a 7777a"]]}] },
    { "display_name": "Math #4", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 3333a 4444b 7777c"]]}] },
    { "display_name": "Math #5", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF 5555a 6666a 11a"]]}] },
    { "display_name": "Math #6", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF 5555a 6666b 11c"]]}] },
    { "display_name": "Math #7", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["DDa 8888a 3333a 5555a"]]}] },
    { "display_name": "Math #8", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["DDa 8888b 3333c 5555a"]]}] },
    { "display_name": "Math #9", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["333a 444a 555a 222a 00"]]}] },
    { "display_name": "Quints #1", "value": 40, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXXXX0a XXXX1a XXX2a XX3a"]]}] },
    { "display_name": "Quints #2", "value": 45, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFFF DDDDDa XXXX0a"]]}] },
    { "display_name": "Quints #3", "value": 40, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["11111a 3333a 555a DDa"]]}] },
    { "display_name": "Quints #4", "value": 40, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["55555a 7777a 999a DDa"]]}] },
    { "display_name": "Quints #5", "value": 35, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFFF 33a 666a 9999a"]]}] },
    { "display_name": "Quints #6", "value": 35, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFFF 33a 666b 9999c"]]}] },
    { "display_name": "Consecutive Run #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["11a 22a 333a 444a 5555a"]]}] },
    { "display_name": "Consecutive Run #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["55a 66a 777a 888a 9999a"]]}] },
    { "display_name": "Consecutive Run #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XX0a XXXX1a XXXX2a XXXX3a"]]}] },
    { "display_name": "Consecutive Run #4", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXXX0a XXX1b XXXX2c DDDc"]]}] },
    { "display_name": "Consecutive Run #5", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF XXXX0a XXXX1b DDDc"]]}] },
    { "display_name": "Consecutive Run #6", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXXX0a XX1b XX1a XX1c XXXX2a"]]}] },
    { "display_name": "Consecutive Run #7", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF XX0a XXX1a XX2b XXX3b DDc"]]}] },
    { "display_name": "Consecutive Run #8", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXX0a XX1a XXX2a DDDb DDDc"]]} ] },
    { "display_name": "13579 #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["11a 333a 5555a 777a 99a"]]}] },
    { "display_name": "13579 #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["11a 333a 5555b 777c 99c"]]}] },
    { "display_name": "13579 #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["1111a 3333a 333b 555b"]]}] },
    { "display_name": "13579 #4", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["5555a 7777a 777b 999b"]]}] },
    { "display_name": "13579 #5", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["1111a 333a 5555b DDDb"]]}] },
    { "display_name": "13579 #6", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["5555a 777a 9999b DDDb"]]}] },
    { "display_name": "13579 #7", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["11a 333a DDDDc 333b 55b"]]}] },
    { "display_name": "13579 #8", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["55a 777a DDDDc 777b 99b"]]}] },
    { "display_name": "13579 #9", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["11a 33a 55a 7777b 9999c"]]}] },
    { "display_name": "13579 #10", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["111a 3333b 555c NEWS"]]} ] },
    { "display_name": "13579 #11", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["555a 7777b 999c NEWS"]]} ] },
    { "display_name": "Winds and Dragons #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NNNN EEE WWW SSSS"]]}] },
    { "display_name": "Winds and Dragons #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF DDDDa NEWS DDDDb"]]}] },
    { "display_name": "Winds and Dragons #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF NNNN RR SSSS"]]}] },
    { "display_name": "Winds and Dragons #4", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF EEEE GG WWWW"]]}] },
    { "display_name": "Winds and Dragons #5", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF N EE WWW SSSS"]]}] },
    { "display_name": "Winds and Dragons #6", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF NN XXXX0a XXXX1b SS"]]}] },
    { "display_name": "Winds and Dragons #7", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF EE XXXX0a XXXX1b WW"]]}] },
    { "display_name": "Winds and Dragons #8", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NNNN DDa DDb DDc SSSS"]]}] },
    { "display_name": "Winds and Dragons #9", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["EEEE DDa DDb DDc WWWW"]]}] },
    { "display_name": "Winds and Dragons #10", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NN 111a 1111b 111c SS", "NN 333a 3333b 333c SS", "NN 555a 5555b 555c SS", "NN 777a 7777b 777c SS", "NN 999a 9999b 999c SS"]]} ] },
    { "display_name": "Winds and Dragons #11", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["EE 222a 2222b 222c WW", "EE 444a 4444b 444c WW", "EE 666a 6666b 666c WW", "EE 888a 8888b 888c WW"]]} ] },
    { "display_name": "369 #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["33a 666a 333b 66b 9999c"]]}] },
    { "display_name": "369 #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF 33a 666a 99a DDDa"]]}] },
    { "display_name": "369 #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["3333a 66a 9999a DDDDa"]]}] },
    { "display_name": "369 #4", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 3333a 6666a 9999a"]]}] },
    { "display_name": "369 #5", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 3333a 6666b 9999c"]]}] },
    { "display_name": "369 #6", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 33a 66a 99a DDDb DDDc"]]}] },
    { "display_name": "369 #7", "value": 35, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 3a 66a 999a 3b 66b 999b"]]}] },
    { "display_name": "Singles and Pairs #1", "value": 50, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NN EE WW SS 11a 11b 11c"]]} ] },
    { "display_name": "Singles and Pairs #2", "value": 50, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 11a 33a 55a 77a 99a DDa"]]} ] },
    { "display_name": "Singles and Pairs #3", "value": 50, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XX0a XX1a XX2a XX3a XX4a XX5a DDa"]]} ] },
    { "display_name": "Singles and Pairs #4", "value": 50, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 2a 4a 66a 88a 22b 44b 6b 8b"]]} ] },
    { "display_name": "Singles and Pairs #5", "value": 50, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["3a 66a 3b 66b 99b 33c 66c 99c"]]} ] },
    { "display_name": "Singles and Pairs #6", "value": 60, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF XX0a XX1a XX2a DDb DDc DDa"]]} ] },
    { "display_name": "Singles and Pairs #7", "value": 75, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 0123a 0123b 0123c"]]} ] }
  ]
