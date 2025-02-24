.win_definition = [
    # 2016
    "NNN EE WW SSS 2016a",
    "FFFF 2016a 111b 111c",
    # 2468
    "FF 22a 4444b 6666b 88a",
    "FFFF 444a 666a DDDDa",
    # Ten Hands
    "FFFF 2222a 8888a 10a", "FFFF 2222a 8888b 10c", 
    "FFFF 3333a 7777a 10a", "FFFF 3333a 7777b 10c", 
    "FFFF 1111a 9999a 10a", "FFFF 1111a 9999b 10c", 
    # Quints
    "XXXX0a XXXXX1a XXXXX2a",
    "FF XXX0a XXXX1b DDDDDc",
    # Consecutive Run
    "11a 22a 333a 444a 5555a", "55a 66a 777a 888a 9999a",
    "XXXX0a XXX1a XXX2b XXXX3b",
    "XXX0a XXXX1a XXX2a DDb DDc",
    # 13579
    "11a 33a 555a 777a 9999a",
    "FF 11a 333a 55b 777c 99c",
    "111a 33a 55a 77a 999a DDb",
    # Winds and Dragons
    "NEWS FFFF DDDa DDDb",
    "FF NNN EEE WWW SSS",
    "NN 111a 1111b 111c SS", "NN 333a 3333b 333c SS", "NN 555a 5555b 555c SS", "NN 777a 7777b 777c SS", "NN 999a 9999b 999c SS", # concealed
    "EE 222a 2222b 222c WW", "EE 444a 4444b 444c WW", "EE 666a 6666b 666c WW", "EE 888a 8888b 888c WW", # concealed
    # 369
    "FF 3333a 66a 9999a DDa",
    "333a 6666a 333b 9999b", # concealed
    # Singles and Pairs
    "NEWS 1234567890a", # concealed
    "112a 334a 556b 778b DDc" #concealed
  ]
|
.open_win_definition = [
    # 2016
    "NNN EE WW SSS 2016a",
    "FFFF 2016a 111b 111c",
    # 2468
    "FF 22a 4444b 6666b 88a",
    "FFFF 444a 666a DDDDa",
    # Ten Hands
    "FFFF 2222a 8888a 10a", "FFFF 2222a 8888b 10c", 
    "FFFF 3333a 7777a 10a", "FFFF 3333a 7777b 10c", 
    "FFFF 1111a 9999a 10a", "FFFF 1111a 9999b 10c", 
    # Quints
    "XXXX0a XXXXX1a XXXXX2a",
    "FF XXX0a XXXX1b DDDDDc",
    # Consecutive Run
    "11a 22a 333a 444a 5555a", "55a 66a 777a 888a 9999a",
    "XXXX0a XXX1a XXX2b XXXX3b",
    "XXX0a XXXX1a XXX2a DDb DDc",
    # 13579
    "11a 33a 555a 777a 9999a",
    "FF 11a 333a 55b 777c 99c",
    "111a 33a 55a 77a 999a DDb",
    # Winds and Dragons
    "NEWS FFFF DDDa DDDb",
    "FF NNN EEE WWW SSS",
    # 369
    "FF 3333a 66a 9999a DDa",
    "333a 6666a 333b 9999b"
  ]
|
.singles_win_definition = [
    "NEWS 1234567890a",
    "112a 334a 556b 778b DDc"
  ]
|
.yaku = [
    { "display_name": "2016 #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NNN EE WW SSS 2016a"]]}] },
    { "display_name": "2016 #2", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF 2016a 111b 111c"]]}] },
    { "display_name": "2468 #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 22a 4444b 6666b 88a"]]}] },
    { "display_name": "2468 #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF 444a 666a DDDDa"]]}] },
    { "display_name": "Ten Hands #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF 2222a 8888a 10a", "FFFF 2222a 8888b 10c"]]}] },
    { "display_name": "Ten Hands #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF 3333a 7777a 10a", "FFFF 3333a 7777b 10c"]]}] },
    { "display_name": "Ten Hands #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF 1111a 9999a 10a", "FFFF 1111a 9999b 10c"]]}] },
    { "display_name": "Quints #1", "value": 40, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXXX0a XXXXX1a XXXXX2a"]]}] },
    { "display_name": "Quints #2", "value": 45, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF XXX0a XXXX1b DDDDDc"]]}] },
    { "display_name": "Consecutive Run #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["11a 22a 333a 444a 5555a", "55a 66a 777a 888a 9999a"]]}] },
    { "display_name": "Consecutive Run #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXXX0a XXX1a XXX2b XXXX3b"]]}] },
    { "display_name": "Consecutive Run #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXX0a XXXX1a XXX2a DDb DDc"]]}] },
    { "display_name": "13579 #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["11a 33a 555a 777a 9999a"]]}] },
    { "display_name": "13579 #2", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 11a 333a 55b 777c 99c"]]}] },
    { "display_name": "13579 #3", "value": 35, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["111a 33a 55a 77a 999a DDb"]]}] },
    { "display_name": "Winds and Dragons #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NEWS FFFF DDDa DDDb"]]}] },
    { "display_name": "Winds and Dragons #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF NNN EEE WWW SSS"]]}] },
    { "display_name": "Winds and Dragons #3", "value": 35, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NN 111a 1111b 111c SS", "NN 333a 3333b 333c SS", "NN 555a 5555b 555c SS", "NN 777a 7777b 777c SS", "NN 999a 9999b 999c SS"]]} ] },
    { "display_name": "Winds and Dragons #4", "value": 35, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["EE 222a 2222b 222c WW", "EE 444a 4444b 444c WW", "EE 666a 6666b 666c WW", "EE 888a 8888b 888c WW"]]} ] },
    { "display_name": "369 #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 3333a 66a 9999a DDa"]]}] },
    { "display_name": "369 #2", "value": 30, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["333a 6666a 333b 9999b"]]}] },
    { "display_name": "Singles and Pairs #1", "value": 75, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NEWS 1234567890a"]]} ] },
    { "display_name": "Singles and Pairs #2", "value": 50, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["112a 334a 556b 778b DDc"]]} ] }
  ]
