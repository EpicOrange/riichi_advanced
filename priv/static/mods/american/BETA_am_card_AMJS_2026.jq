    ## TODO: confirm that `.singles_win_definition` is correct

.win_definition = [
    # Honor The Legacy
    "DDDDa DDDDb DDDDc ZZ",
    "ZZZ 2222a 8888b DDDc",
    "DDDa DDDb DDDc NNN EE|WW|SS", "DDDa DDDb DDDc EEE NN|WW|SS", "DDDa DDDb DDDc WWW NN|EE|SS", "DDDa DDDb DDDc SSS NN|EE|WW",
    "XXX0a XXX0b XXX0c DDDc DDb",
    "NNN EEE WWW SSS DDa",
    "2026a 2026b 2026c DDa",
    "FF 111a 999a 111b 999b",
    "123a 456a 789a RRR EE", # concealed
    # Palindrome
    "222a 444b DDc 444b 222a",
    "DDa XXX0a XXXX1b XXX0c DDc",
    "NN XXX0a FFFF XXX0a NN", "EE XXX0a FFFF XXX0a EE", "WW XXX0a FFFF XXX0a WW", "SS XXX0a FFFF XXX0a SS",
    "XXX0a XXX1a XX2a XXX1a XXX0a",
    "FF DDb XXX0a XXX0b DDb FF",
    "XX0a XXX1a XXXX2a XXX1b XX0b",
    "33a 55b 77c 55b 33a DDa|DDb|DDc ZZ", # concealed
    "345a 678b DDb 876b 543a", # concealed
    "NEWS Da XXXX0b Dc NEWS",
    # A Little Odd
    "FFF 333a 555b 77c ZZZ",
    "111a 333a 555a 777a 99a", "111a 333a 555b 777b 99b",
    "333a 555a 777a 999a ZZ",
    "FF 111a 33a 55a 77a 999a",
    "1111a 333a 5555b DDDb",
    "111a 333b 555c 777a 99c", # concealed
    "7777a 7777b 7777c DDa",
    # Evens
    "222a 444b 666c DDDb 88b",
    "FF 222a 444b 666c 888c",
    "222a 444a 666a 888a 22a", "222a 444a 666b 888b 22b", 
    "FFFF 2222a 4444b DDb",
    "FF 4444a 4444b 4444c",
    "222a 222b 2222c NEWS", "444a 444b 4444c NEWS", "666a 666b 6666c NEWS", "888a 888b 8888c NEWS", 
    "FFFF 22a 44a 66a 8888a",
    # Prime Numbers
    "222a 333b 555c 77a ZZZ",
    "222a 333a 55a 77a DDDDb",
    "222a 333b 555c 777a 22c",
    # Linear Logic
    "XXX0a XXXX1b XXXXX2c ZZ",
    "FF XXX0a XX1a XXXX2a XXX3a",
    "XXX0a XXX1a XX2a XXX3a XXX4a",
    "FF XXX0a XXXX1b XXX2c DDa",
    "FF XX0a XXXX1a XXXX2a XX3a", # concealed
    "F X0a XXX1a XXXX2a XXXXX3a",
    # Repeating
    "FF XXX0a XXX0b XXX0c DDDa",
    "FFF XXX0a XXX0b DDDa ZZ",
    "FFF XXXX0a XXX0b XX0c DDa",
    "XXX0a XXX1a ZZ XXX0b XXX1b",
    "FF 123a 789a 123b 789b", # concealed
    "XX0a XX0b XX0c DDc ZZ XX0b XX0a", # concealed
    # Pop Culture
    "13a 13b 13c 87a NEWS DDa", # concealed
    "ZZZZ FFFF 1234a 22a",
    "6666a 7777a 6b 7b NEWS"
  ]
|
.open_win_definition = [
    # Honor The Legacy
    "DDDDa DDDDb DDDDc ZZ",
    "ZZZ 2222a 8888b DDDc",
    "DDDa DDDb DDDc NNN EE|WW|SS", "DDDa DDDb DDDc EEE NN|WW|SS", "DDDa DDDb DDDc WWW NN|EE|SS", "DDDa DDDb DDDc SSS NN|EE|WW",
    "XXX0a XXX0b XXX0c DDDc DDb",
    "NNN EEE WWW SSS DDa",
    "2026a 2026b 2026c DDa",
    "FF 111a 999a 111b 999b",
    # Palindrome
    "222a 444b DDc 444b 222a",
    "DDa XXX0a XXXX1b XXX0c DDc",
    "NN XXX0a FFFF XXX0a NN", "EE XXX0a FFFF XXX0a EE", "WW XXX0a FFFF XXX0a WW", "SS XXX0a FFFF XXX0a SS",
    "XXX0a XXX1a XX2a XXX1a XXX0a",
    "FF DDb XXX0a XXX0b DDb FF",
    "XX0a XXX1a XXXX2a XXX1b XX0b",
    "NEWS Da XXXX0b Dc NEWS",
    # A Little Odd
    "FFF 333a 555b 77c ZZZ",
    "111a 333a 555a 777a 99a", "111a 333a 555b 777b 99b",
    "333a 555a 777a 999a ZZ",
    "FF 111a 33a 55a 77a 999a",
    "1111a 333a 5555b DDDb",
    "7777a 7777b 7777c DDa",
    # Evens
    "222a 444b 666c DDDb 88b",
    "FF 222a 444b 666c 888c",
    "222a 444a 666a 888a 22a", "222a 444a 666b 888b 22b", 
    "FFFF 2222a 4444b DDb",
    "FF 4444a 4444b 4444c",
    "222a 222b 2222c NEWS", "444a 444b 4444c NEWS", "666a 666b 6666c NEWS", "888a 888b 8888c NEWS", 
    "FFFF 22a 44a 66a 8888a",
    # Prime Numbers
    "222a 333b 555c 77a ZZZ",
    "222a 333a 55a 77a DDDDb",
    "222a 333b 555c 777a 22c",
    # Linear Logic
    "XXX0a XXXX1b XXXXX2c ZZ",
    "FF XXX0a XX1a XXXX2a XXX3a",
    "XXX0a XXX1a XX2a XXX3a XXX4a",
    "FF XXX0a XXXX1b XXX2c DDa",
    "F X0a XXX1a XXXX2a XXXXX3a",
    # Repeating
    "FF XXX0a XXX0b XXX0c DDDa",
    "FFF XXX0a XXX0b DDDa ZZ",
    "FFF XXXX0a XXX0b XX0c DDa",
    "XXX0a XXX1a ZZ XXX0b XXX1b",
    # Pop Culture
    "ZZZZ FFFF 1234a 22a",
    "6666a 7777a 6b 7b NEWS"
  ]
|
.singles_win_definition = [
        ## TODO: confirm that this is correct
    # Honor The Legacy
    "123a 456a 789a RRR EE", # concealed
    # Palindrome
    "33a 55b 77c 55b 33a DDa|DDb|DDc ZZ", # concealed
    "345a 678b DDb 876b 543a", # concealed
    # A Little Odd
    "111a 333b 555c 777a 99c", # concealed
    # Linear Logic
    "FF XX0a XXXX1a XXXX2a XX3a", # concealed
    # Repeating
    "FF 123a 789a 123b 789b", # concealed
    "XX0a XX0b XX0c DDc ZZ XX0b XX0a", # concealed
    # Pop Culture
    "13a 13b 13c 87a NEWS DDa" # concealed
  ]
|
.yaku = [
    { "display_name": "Honor The Legacy #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["DDDDa DDDDb DDDDc ZZ"]]}] },
    { "display_name": "Honor The Legacy #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["ZZZ 2222a 8888b DDDc"]]}] },
    { "display_name": "Honor The Legacy #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["DDDa DDDb DDDc NNN EE|WW|SS", "DDDa DDDb DDDc EEE NN|WW|SS", "DDDa DDDb DDDc WWW NN|EE|SS", "DDDa DDDb DDDc SSS NN|EE|WW"]]}] },
    { "display_name": "Honor The Legacy #4", "value": 35, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXX0a XXX0b XXX0c DDDc DDb"]]}] },
    { "display_name": "Honor The Legacy #5", "value": 35, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NNN EEE WWW SSS DDa"]]}] },
    { "display_name": "Honor The Legacy #6", "value": 40, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["2026a 2026b 2026c DDa"]]}] },
    { "display_name": "Honor The Legacy #7", "value": 45, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 111a 999a 111b 999b"]]}] },
    { "display_name": "Honor The Legacy #8", "value": 45, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["123a 456a 789a RRR EE"]]} ] },
    { "display_name": "Palindrome #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["222a 444b DDc 444b 222a"]]}] },
    { "display_name": "Palindrome #2", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["DDa XXX0a XXXX1b XXX0c DDc"]]}] },
    { "display_name": "Palindrome #3", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NN XXX0a FFFF XXX0a NN", "EE XXX0a FFFF XXX0a EE", "WW XXX0a FFFF XXX0a WW", "SS XXX0a FFFF XXX0a SS"]]}] },
    { "display_name": "Palindrome #4", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXX0a XXX1a XX2a XXX1a XXX0a"]]}] },
    { "display_name": "Palindrome #5", "value": 35, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF DDb XXX0a XXX0b DDb FF"]]}] },
    { "display_name": "Palindrome #6", "value": 40, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XX0a XXX1a XXXX2a XXX1b XX0b"]]}] },
    { "display_name": "Palindrome #7", "value": 40, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["33a 55b 77c 55b 33a DDa|DDb|DDc ZZ"]]}] },
    { "display_name": "Palindrome #8", "value": 50, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["345a 678b DDb 876b 543a"]]}] },
    { "display_name": "Palindrome #9", "value": 50, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NEWS Da XXXX0b Dc NEWS"]]}] },
    { "display_name": "A Little Odd #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF 333a 555b 77c ZZZ"]]}] },
    { "display_name": "A Little Odd #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["111a 333a 555a 777a 99a", "111a 333a 555b 777b 99b"]]}] },
    { "display_name": "A Little Odd #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["333a 555a 777a 999a ZZ"]]}] },
    { "display_name": "A Little Odd #4", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 111a 33a 55a 77a 999a"]]}] },
    { "display_name": "A Little Odd #5", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["1111a 333a 5555b DDDb"]]}] },
    { "display_name": "A Little Odd #6", "value": 35, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["111a 333b 555c 777a 99c"]]} ] },
    { "display_name": "A Little Odd #7", "value": 35, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["7777a 7777b 7777c DDa"]]}] },
    { "display_name": "Evens #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["222a 444b 666c DDDb 88b"]]}] },
    { "display_name": "Evens #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 222a 444b 666c 888c"]]}] },
    { "display_name": "Evens #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["222a 444a 666a 888a 22a", "222a 444a 666b 888b 22b"]]}] },
    { "display_name": "Evens #4", "value": 35, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF 2222a 4444b DDb"]]}] },
    { "display_name": "Evens #5", "value": 35, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 4444a 4444b 4444c"]]}] },
    { "display_name": "Evens #6", "value": 40, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["222a 222b 2222c NEWS", "444a 444b 4444c NEWS", "666a 666b 6666c NEWS", "888a 888b 8888c NEWS"]]}] },
    { "display_name": "Evens #7", "value": 45, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF 22a 44a 66a 8888a"]]}] },
    { "display_name": "Prime Numbers #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["222a 333b 555c 77a ZZZ"]]}] },
    { "display_name": "Prime Numbers #2", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["222a 333a 55a 77a DDDDb"]]}] },
    { "display_name": "Prime Numbers #3", "value": 40, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["222a 333b 555c 777a 22c"]]}] },
    { "display_name": "Linear Logic #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXX0a XXXX1b XXXXX2c ZZ"]]}] },
    { "display_name": "Linear Logic #2", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF XXX0a XX1a XXXX2a XXX3a"]]}] },
    { "display_name": "Linear Logic #3", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXX0a XXX1a XX2a XXX3a XXX4a"]]}] },
    { "display_name": "Linear Logic #4", "value": 35, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF XXX0a XXXX1b XXX2c DDa"]]}] },
    { "display_name": "Linear Logic #5", "value": 40, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF XX0a XXXX1a XXXX2a XX3a"]]} ] },
    { "display_name": "Linear Logic #6", "value": 45, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["F X0a XXX1a XXXX2a XXXXX3a"]]}] },
    { "display_name": "Repeating #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF XXX0a XXX0b XXX0c DDDa"]]}] },
    { "display_name": "Repeating #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF XXX0a XXX0b DDDa ZZ"]]}] },
    { "display_name": "Repeating #3", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF XXXX0a XXX0b XX0c DDa"]]}] },
    { "display_name": "Repeating #4", "value": 35, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXX0a XXX1a ZZ XXX0b XXX1b"]]}] },
    { "display_name": "Repeating #5", "value": 40, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 123a 789a 123b 789b"]]} ] },
    { "display_name": "Repeating #5", "value": 50, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XX0a XX0b XX0c DDc ZZ XX0b XX0a"]]} ] },
    { "display_name": "Pop Culture #1: TS - Eras", "value": 45, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["13a 13b 13c 87a NEWS DDa"]]} ] },
    { "display_name": "Pop Culture #2: Queen Bey", "value": 45, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["ZZZZ FFFF 1234a 22a"]]}] },
    { "display_name": "Pop Culture #3: Slang", "value": 45, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["6666a 7777a 6b 7b NEWS"]]}] }
  ]
