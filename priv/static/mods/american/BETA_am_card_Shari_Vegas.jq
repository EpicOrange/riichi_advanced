# Currently still in beta because I have no clue if "W1Na", "10SEb" etc. groupings work as intended.

.win_definition = [
    # Playing The Slots
    "W1Na W1Nb 7777a 7777b",
    "FF 777a 777b 777c DDDa",
    "FFF XXXX0a FF XXXX0b X0c",
    "777a DDa FFFF 777b DDb",
    "F 777a 10SEa 777b W1Nb", # concealed
    # Evens Not Odds
    "FF 222a 4a 6666a 8888a",
    "FF 2a 4444a 66a 8888a Da",
    "22a 444b 6666b 666c 88c",
    "2222a 44a 44b 666b 888b",
    "FF 2a 44a 666a 888a DDDa", # concealed
    # When The Dealing's Done
    "XXX0a XX1a DDa XXX0b XX1b DDb",
    "FF XXXX0a XXXX0b XXXX0c",
    "FFFF XX0a XX0b DDb XX0c DDc", # concealed
    # Jokers Are Wild
    "ZZZZZ DDDDa XXXXX0a|XXXXX0b",
    "FFFF 33333a 88888a|88888b", # NOTE: 3s and 8s in this hand must be as written, not Any Two Numbers.
    "3333a 88888a 88888b",
    "33333a 33333b 8888c",
    # Know When To Run
    "1111a 22a 3333a 4a 555a", "5555a 66a 7777a 8a 999a",
    "FFF X0a XX1a XXXX2b XXXX3b",
    "F XXXX0a XXXX1a XXXX2a Da",
    "FF XXXX0a XXXX1a X2b DDDb",
    "XX0a XXXX1a XXXX2a XXXX3a",
    "XXX0a XXX1a XXX2a XXX3a DDa", # concealed
    # Best Odds
    "F 33a 555a 7777a 9999a",
    "FF 11a 333a 555a 7777a",
    "FF 3333a 5555a 7777a", "FF 3333a 5555b 7777c",
    "FFF 1111a FFF 3333a", "FFF 7777a FFF 9999a",
    "FF 5555a 777a 99a DDDa",
    "FF 5555a DDa 777b DDDb",
    "F 111a 333a 555a 777a 9a", # concealed
    # To Air Is Human
    "FFFF W1Na 10SEa W1Nb",
    "WWWW 1111a NNNN DDa|DDb",
    "111a 000 SSSS EEEE",
    "10SEa W1Nb DDDDb DDDa",
    "SSSS 11a NNNN DDDDa",
    "FF DDDa DDDb DDDc SSS", # concealed
    # Three Card Monte
    "FFF 3333a 666a 9999a",
    "DDDa 333a 6666a 9999a",
    "DDDa 333a DDDDb 9999b",
    "FFFF 3333a 6666b 99c", "FFFF 33a 6666b 9999c",
    "3333a 66a 333b 66b 999b",
    "33a 666b 999b 666c 999c", # concealed
    # Blackjack
    "FF DDa|DDb|DDc 4a 5a 9a 2b 2b 6b 11b 21c", # concealed
    "123456a 123456b 21c", # concealed
    "FF DDa 489a DDb 489b DDc", # concealed
    "DDa|DDb|DDc 21a 21a 21b 21b 21c 21c", # concealed
    "FF DDa NN SS EE WW 21b" # concealed
  ]
|
.open_win_definition = [
    # Playing The Slots
    "W1Na W1Nb 7777a 7777b",
    "FF 777a 777b 777c DDDa",
    "FFF XXXX0a FF XXXX0b X0c",
    "777a DDa FFFF 777b DDb",
    # Evens Not Odds
    "FF 222a 4a 6666a 8888a",
    "FF 2a 4444a 66a 8888a Da",
    "22a 444b 6666b 666c 88c",
    "2222a 44a 44b 666b 888b",
    # When The Dealing's Done
    "XXX0a XX1a DDa XXX0b XX1b DDb",
    "FF XXXX0a XXXX0b XXXX0c",
    # Jokers Are Wild
    "ZZZZZ DDDDa XXXXX0a|XXXXX0b",
    "FFFF 33333a 88888a|88888b",
    "3333a 88888a 88888b",
    "33333a 33333b 8888c",
    # Know When To Run
    "1111a 22a 3333a 4a 555a", "5555a 66a 7777a 8a 999a",
    "FFF X0a XX1a XXXX2b XXXX3b",
    "F XXXX0a XXXX1a XXXX2a Da",
    "FF XXXX0a XXXX1a X2b DDDb",
    "XX0a XXXX1a XXXX2a XXXX3a",
    # Best Odds
    "F 33a 555a 7777a 9999a",
    "FF 11a 333a 555a 7777a",
    "FF 3333a 5555a 7777a", "FF 3333a 5555b 7777c",
    "FFF 1111a FFF 3333a", "FFF 7777a FFF 9999a",
    "FF 5555a 777a 99a DDDa",
    "FF 5555a DDa 777b DDDb",
    # To Air Is Human
    "FFFF W1Na 10SEa W1Nb",
    "WWWW 1111a NNNN DDa|DDb",
    "111a 000 SSSS EEEE",
    "10SEa W1Nb DDDDb DDDa",
    "SSSS 11a NNNN DDDDa",
    # Three Card Monte
    "FFF 3333a 666a 9999a",
    "DDDa 333a 6666a 9999a",
    "DDDa 333a DDDDb 9999b",
    "FFFF 3333a 6666b 99c", "FFFF 33a 6666b 9999c",
    "3333a 66a 333b 66b 999b"
  ]
|
.singles_win_definition = [
    ### NOTE: These hands apparently ARE Singles and Pairs hands despite their category not being called "Singles and Pairs".
    # Blackjack
    "FF DDa|DDb|DDc 4a 5a 9a 2b 2b 6b 11b 21c", # concealed
    "123456a 123456b 21c", # concealed
    "FF DDa 489a DDb 489b DDc", # concealed
    "DDa|DDb|DDc 21a 21a 21b 21b 21c 21c", # concealed
    "FF DDa NN SS EE WW 21b" # concealed
  ]
|
.yaku = [

    { "display_name": "Playing The Slots #1", "value": 35, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["W1Na W1Nb 7777a 7777b"]]}] },
    { "display_name": "Playing The Slots #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 777a 777b 777c DDDa"]]}] },
    { "display_name": "Playing The Slots #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF XXXX0a FF XXXX0b X0c"]]}] },
    { "display_name": "Playing The Slots #4", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["777a DDa FFFF 777b DDb"]]}] },
    { "display_name": "Playing The Slots #5", "value": 55, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["F 777a 10SEa 777b W1Nb"]]} ] },
    { "display_name": "Evens Not Odds #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 222a 4a 6666a 8888a"]]}] },
    { "display_name": "Evens Not Odds #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 2a 4444a 66a 8888a Da"]]}] },
    { "display_name": "Evens Not Odds #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["22a 444b 6666b 666c 88c"]]}] },
    { "display_name": "Evens Not Odds #4", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["2222a 44a 44b 666b 888b"]]}] },
    { "display_name": "Evens Not Odds #5", "value": 35, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 2a 44a 666a 888a DDDa"]]} ] },
    { "display_name": "When The Dealing's Done #1", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXX0a XX1a DDa XXX0b XX1b DDb"]]}] },
    { "display_name": "When The Dealing's Done #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF XXXX0a XXXX0b XXXX0c"]]}] },
    { "display_name": "When The Dealing's Done #3", "value": 40, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF XX0a XX0b DDb XX0c DDc"]]} ] },
    { "display_name": "Jokers Are Wild #1", "value": 40, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["ZZZZZ DDDDa XXXXX0a|XXXXX0b"]]}] },
    { "display_name": "Jokers Are Wild #2", "value": 40, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF 33333a 88888a|88888b"]]}] },
    { "display_name": "Jokers Are Wild #3", "value": 40, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["3333a 88888a 88888b"]]}] },
    { "display_name": "Jokers Are Wild #4", "value": 40, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["33333a 33333b 8888c"]]}] },
    { "display_name": "Know When To Run #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["1111a 22a 3333a 4a 555a", "5555a 66a 7777a 8a 999a"]]}] },
    { "display_name": "Know When To Run #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF X0a XX1a XXXX2b XXXX3b"]]}] },
    { "display_name": "Know When To Run #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["F XXXX0a XXXX1a XXXX2a Da"]]}] },
    { "display_name": "Know When To Run #4", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF XXXX0a XXXX1a X2b DDDb"]]}] },
    { "display_name": "Know When To Run #5", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XX0a XXXX1a XXXX2a XXXX3a"]]}] },
    { "display_name": "Know When To Run #6", "value": 40, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXX0a XXX1a XXX2a XXX3a DDa"]]} ] },
    { "display_name": "Best Odds #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["F 33a 555a 7777a 9999a"]]}] },
    { "display_name": "Best Odds #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 11a 333a 555a 7777a"]]}] },
    { "display_name": "Best Odds #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 3333a 5555a 7777a", "FF 3333a 5555b 7777c"]]}] },
    { "display_name": "Best Odds #4", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF 1111a FFF 3333a", "FFF 7777a FFF 9999a"]]}] },
    { "display_name": "Best Odds #5", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 5555a DDa 777b DDDb"]]}] },
    { "display_name": "Best Odds #6", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["111a 333a 5555a DDb DDc", "555a 777a 9999a DDb DDc"]]}] },
    { "display_name": "Best Odds #7", "value": 40, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["F 111a 333a 555a 777a 9a"]]} ] },
    { "display_name": "To Air Is Human #1", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF W1Na 10SEa W1Nb"]]}] },
    { "display_name": "To Air Is Human #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["WWWW 1111a NNNN DDa|DDb"]]}] },
    { "display_name": "To Air Is Human #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["111a 000 SSSS EEEE"]]}] },
    { "display_name": "To Air Is Human #4", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["10SEa W1Nb DDDDb DDDa"]]}] },
    { "display_name": "To Air Is Human #5", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["SSSS 11a NNNN DDDDa"]]}] },
    { "display_name": "To Air Is Human #6", "value": 35, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF DDDa DDDb DDDc SSS"]]} ] },
    { "display_name": "Three Card Monte #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF 3333a 666a 9999a"]]}] },
    { "display_name": "Three Card Monte #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["DDDa 333a 6666a 9999a"]]}] },
    { "display_name": "Three Card Monte #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["DDDa 333a DDDDb 9999b"]]}] },
    { "display_name": "Three Card Monte #4", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF 3333a 6666b 99c", "FFFF 33a 6666b 9999c"]]}] },
    { "display_name": "Three Card Monte #5", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["3333a 66a 333b 66b 999b"]]}] },
    { "display_name": "Three Card Monte #6", "value": 35, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["33a 666b 999b 666c 999c"]]}] },
    { "display_name": "Blackjack #1", "value": 55, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF DDa|DDb|DDc 4a 5a 9a 2b 2b 6b 11b 21c"]]} ] },
    { "display_name": "Blackjack #2", "value": 55, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["123456a 123456b 21c"]]} ] },
    { "display_name": "Blackjack #3", "value": 55, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF DDa 489a DDb 489b DDc"]]} ] },
    { "display_name": "Blackjack #4", "value": 55, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["DDa|DDb|DDc 21a 21a 21b 21b 21c 21c"]]} ] },
    { "display_name": "Blackjack #5", "value": 55, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF DDa NN SS EE WW 21b"]]} ] }
  ]
