.win_definition = [
    # Number Hands
    "XXX0a XXX1a XXXX2a XXXX3a",
    "XXXX0a XXX1a XXXX2b XXX3b",
    "FFFF XXXX0a XXXX1a DDa",
    "FFFF 333a 666b 9999b",
    "FF 333a 666a 9999b DDb",
    # Like Hands
    "FFFF XXX0a XXX0b XXXX0c",
    "FFF DDDa DDDDb DDDDc",
    "FF XXXX0a XXXX0b XXXX0c",
    "FFFF XXXX0a XXXX0b XX0c",
    # Even Hands
    "FF 4444a 4444b 6666b",
    "222a 4444a 6666a 888a",
    "222a 6666a 222b 6666b",
    "222a 444a 2222b 4444b",
    "2222a 4444b 8888b DDb",
    # Odd Hands
    "FFF 5555a 777a 99a DDa",
    "FF 555a 777a 999a DDDa",
    "111a 333a 555a 777a 99a",
    "FF 5555a 7777b 9999d",
    "11a 33a 333b 555b 7777c",
    # Yearly Hands
    "222a 0000 222b 5555c",
    "FF 22a 000 2222b 555b",
    "FF 222a 00 222b 555c",
    "2222a 000 2222b 555c",
    # Wind Hands
    "NNNN EEEE WWWW SS",
    "NNN EEE WWWW SSSS",
    "FF EEEE XX0a WWWW XX0b",
    "FFF NNNN XXX0a SSSS",
    "FFF NNN EEE WWW SS",
    # Closed Hands
    "FF 11a 22a 33a 44a 55a 66a", # concealed
    "FF 22a 44a 66a 88a DDa DDb", # concealed
    "FF XX0a XX1a XX0b XX1b XX0c XX1c", # concealed
    "NN EE WW SS XX0a XX0b XX0c" # concealed
  ]
|
.open_win_definition = [
    # Number Hands
    "XXX0a XXX1a XXXX2a XXXX3a",
    "XXXX0a XXX1a XXXX2b XXX3b",
    "FFFF XXXX0a XXXX1a DDa",
    "FFFF 333a 666b 9999b",
    "FF 333a 666a 9999b DDb",
    # Like Hands
    "FFFF XXX0a XXX0b XXXX0c",
    "FFF DDDa DDDDb DDDDc",
    "FF XXXX0a XXXX0b XXXX0c",
    "FFFF XXXX0a XXXX0b XX0c",
    # Even Hands
    "FF 4444a 4444b 6666b",
    "222a 4444a 6666a 888a",
    "222a 6666a 222b 6666b",
    "222a 444a 2222b 4444b",
    "2222a 4444b 8888b DDb",
    # Odd Hands
    "FFF 5555a 777a 99a DDa",
    "FF 555a 777a 999a DDDa",
    "111a 333a 555a 777a 99a",
    "FF 5555a 7777b 9999d",
    "11a 33a 333b 555b 7777c",
    # Yearly Hands
    "222a 0000 222b 5555c",
    "FF 22a 000 2222b 555b",
    "FF 222a 00 222b 555c",
    "2222a 000 2222b 555c",
    # Wind Hands
    "NNNN EEEE WWWW SS",
    "NNN EEE WWWW SSSS",
    "FF EEEE XX0a WWWW XX0b",
    "FFF NNNN XXX0a SSSS",
    "FFF NNN EEE WWW SS"
  ]
|
.singles_win_definition = [
    # TODO: pretty sure there is no jokerless bonus in Network Junior, so every hand needs to go here. or maybe no hand should go here. hmmm. latter is simpler to type for now.
  ]
|
.yaku = [
    { "display_name": "Number Hand #1", "value": 5, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXX0a XXX1a XXXX2a XXXX3a"]]}] },
    { "display_name": "Number Hand #2", "value": 5, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXXX0a XXX1a XXXX2b XXX3b"]]}] },
    { "display_name": "Number Hand #3", "value": 5, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF XXXX0a XXXX1a DDa"]]}] },
    { "display_name": "Number Hand #4", "value": 10, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF 333a 666b 9999b"]]}] },
    { "display_name": "Number Hand #5", "value": 10, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 333a 666a 9999b DDb"]]}] },
    { "display_name": "Like Hand #1", "value": 5, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF XXX0a XXX0b XXXX0c"]]}] },
    { "display_name": "Like Hand #2", "value": 5, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF DDDa DDDDb DDDDc"]]}] },
    { "display_name": "Like Hand #3", "value": 10, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF XXXX0a XXXX0b XXXX0c"]]}] },
    { "display_name": "Like Hand #4", "value": 10, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF XXXX0a XXXX0b XX0c"]]}] },
    { "display_name": "Even Hand #1", "value": 5, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 4444a 4444b 6666b"]]}] },
    { "display_name": "Even Hand #2", "value": 5, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["222a 4444a 6666a 888a"]]}] },
    { "display_name": "Even Hand #3", "value": 5, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["222a 6666a 222b 6666b"]]}] },
    { "display_name": "Even Hand #4", "value": 10, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["222a 444a 2222b 4444b"]]}] },
    { "display_name": "Even Hand #5", "value": 10, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["2222a 4444b 8888b DDb"]]}] },
    { "display_name": "Odd Hand #1", "value": 5, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF 5555a 777a 99a DDa"]]}] },
    { "display_name": "Odd Hand #2", "value": 5, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 555a 777a 999a DDDa"]]}] },
    { "display_name": "Odd Hand #3", "value": 5, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["111a 333a 555a 777a 99a"]]}] },
    { "display_name": "Odd Hand #4", "value": 10, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 5555a 7777b 9999d"]]}] },
    { "display_name": "Odd Hand #5", "value": 10, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["11a 33a 333b 555b 7777c"]]}] },
    { "display_name": "Yearly Hand #1", "value": 5, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["222a 0000 222b 5555c"]]}] },
    { "display_name": "Yearly Hand #2", "value": 5, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 22a 000 2222b 555b"]]}] },
    { "display_name": "Yearly Hand #3", "value": 10, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 222a 00 222b 555c"]]}] },
    { "display_name": "Yearly Hand #4", "value": 10, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["2222a 000 2222b 555c"]]}] },
    { "display_name": "Wind Hand #1", "value": 5, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NNNN EEEE WWWW SS"]]}] },
    { "display_name": "Wind Hand #2", "value": 5, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NNN EEE WWWW SSSS"]]}] },
    { "display_name": "Wind Hand #3", "value": 5, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF EEEE XX0a WWWW XX0b"]]}] },
    { "display_name": "Wind Hand #4", "value": 10, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF NNNN XXX0a SSSS"]]}] },
    { "display_name": "Wind Hand #5", "value": 10, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF NNN EEE WWW SS"]]}] },
    { "display_name": "Closed Hand #1", "value": 25, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 11a 22a 33a 44a 55a 66a"]]} ] },
    { "display_name": "Closed Hand #2", "value": 25, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 22a 44a 66a 88a DDa DDb"]]} ] },
    { "display_name": "Closed Hand #3", "value": 25, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF XX0a XX1a XX0b XX1b XX0c XX1c"]]} ] },
    { "display_name": "Closed Hand #4", "value": 25, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NN EE WW SS XX0a XX0b XX0c"]]} ] }
  ]
### TODO: check rules differences between Network Junior and NMJL
