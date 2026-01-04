# Note: concealed hands get a +10 bonus, except for hands that are concealed on the Card.
# Note: the jokerless bonus applies to all hands except for those MADE OF singles and pairs. it applies after the +10 bonus for concealed hands.
# Note: the Consecutive Numbers category cannot be played descending rather than ascending.

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
    "FF 22a 44a 66a 88a 22b 22c", "FF 22a 44a 66a 88a 44b 44c", "FF 22a 44a 66a 88a 66b 66c", "FF 22a 44a 66a 88a 88b 88c", # concealed
    # Any Matching Numbers
    "NNN XXX0a XX0b XXX0c SSS", "EEE XXX0a XX0b XXX0c WWW",
    "XXXX0a XXXX0b XXXX0c DDa",
    "XXX0a XXX0b XXX0c DDDDDa",
    "FFF XXXX0a FFF XXXX0b",
    # Consecutive Numbers
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
    "FFF 111a 333b 55555c", "FFF 555a 777b 99999c",
    "11a 33a 55a 77a 99a 11b 11c", "11a 33a 55a 77a 99a 33b 33c", "11a 33a 55a 77a 99a 55b 55c", "11a 33a 55a 77a 99a 77b 77c", "11a 33a 55a 77a 99a 99b 99c", # concealed
    # Winds-Dragons
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
    "FF NEWS N0W WE W0N" # concealed
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
    # Any Matching Numbers
    "NNN XXX0a XX0b XXX0c SSS", "EEE XXX0a XX0b XXX0c WWW",
    "XXXX0a XXXX0b XXXX0c DDa",
    "XXX0a XXX0b XXX0c DDDDDa",
    "FFF XXXX0a FFF XXXX0b",
    # Consecutive Numbers
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
    "FFF 111a 333b 55555c", "FFF 555a 777b 99999c",
    # Winds-Dragons
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
    "FF 333a NN E W SS 888a", "FF 333a NN E W SS 888b"
  ]
|
.singles_win_definition = [
    # 2468
    "2468Da 2468Db 2468c", # concealed
    "FF 22a 44a 66a 88a 22b 22c", "FF 22a 44a 66a 88a 44b 44c", "FF 22a 44a 66a 88a 66b 66c", "FF 22a 44a 66a 88a 88b 88c", # concealed
    # Consecutive Numbers
    "FF 1233a 4566a 7899a", "FF 1233a 4566b 7899c", # concealed
    # 13579
    "11a 33a 55a 77a 99a 11b 11c", "11a 33a 55a 77a 99a 33b 33c", "11a 33a 55a 77a 99a 55b 55c", "11a 33a 55a 77a 99a 77b 77c", "11a 33a 55a 77a 99a 99b 99c", # concealed
    "FF 369Da 369Db 369Dc", # concealed
    # Mad Math
    "NEWS 2468a 3579a 44a", "NEWS 2468a 3579b 44c", # concealed
    # Big Brain
    "N EE 05a 10a 15a 20a WW S", # concealed
    "FF NEWS N0W WE W0N" # concealed
  ]
|
# Card-specific rule: concealed hands get a +10 bonus, except for hands that are concealed on the Card. this occurs before the jokerless bonus
# TODO: check whether this rule works as intended.
 
.after_scoring = [
    # concealed bonus
  ["when", [
      {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["open_win"]]},
      {"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}
    ], [
      ["push_message", "gets +10 points for a concealed hand"],
      ["modify_payout", "others", -10], ["modify_payout", "self", 30]
  ]],

    # jokerless bonus
  ["when", [
      {"name": "not_match", "opts": [["hand", "call_tiles", "winning_tile"], [[[["1j"], 1]]]]},
      {"name": "not_match", "opts": [["hand", "call_tiles", "winning_tile"], ["singles_win"]]}
    ], [
      ["push_message", "gets double score for a jokerless hand"],
      ["modify_payout", "all", 2, "multiply"]
  ]],

    # on wins by discard, engine splits score evenly across all 3 players,
    # this undoes that
  ["when", ["won_by_discard"], [
      ["modify_payout", "everyone", 3, "multiply"]
  ]]
]
|
.yaku = [
    { "display_name": "2026 #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["222a 0000 222b 6666c"]]}] },
    { "display_name": "2026 #2", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["DDDa Db 222a 222b 2026c", "DDDa Db 666a 666b 2026c"]]}] },
    { "display_name": "2026 #3", "value": 40, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF NEWS DDDa 2026a"]]}] },
    { "display_name": "2026 #4", "value": 40, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 2026a 2222b 2222c", "FF 2026a 6666b 6666c"]]}] },
    { "display_name": "2026 #5", "value": 55, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NNN EE 2026a WW SSS"]]}] },
    { "display_name": "2468 #1", "value": 15, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["F 222a 444a 666a 8888a", "F 222a 444a 666b 8888c"]]}] },
    { "display_name": "2468 #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["222a NNNN 222b SSSS", "444a NNNN 444b SSSS", "666a NNNN 666b SSSS", "888a NNNN 888b SSSS", "222a EEEE 222b WWWW", "444a EEEE 444b WWWW", "666a EEEE 666b WWWW", "888a EEEE 888b WWWW"]]}] },
    { "display_name": "2468 #3", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF ZZZ 222a 4444a 66a"]]}] },
    { "display_name": "2468 #4", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 2a 4a 666a 8888a DDDa", "FF 2a 4a 666b 8888c DDDa"]]}] },
    { "display_name": "2468 #5", "value": 35, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 2222a 4444a|6666a|8888a DDDDa", "FF 4444a 6666a|8888a DDDDa", "FF 6666a 8888a DDDDa", "FF 2222a 4444b|6666b|8888b DDDDc", "FF 4444a 6666b|8888b DDDDc", "FF 6666a 8888b DDDDc"]]}] },
    { "display_name": "2468 #6", "value": 40, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["222a 444a 666a 88888a", "222a 444a 666b 88888c"]]}] },
    { "display_name": "2468 #7", "value": 50, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["2468Da 2468Db 2468c"]]} ] },
    { "display_name": "2468 #8", "value": 70, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 22a 44a 66a 88a 22b 22c", "FF 22a 44a 66a 88a 44b 44c", "FF 22a 44a 66a 88a 66b 66c", "FF 22a 44a 66a 88a 88b 88c"]]} ] },
    { "display_name": "Any Matching Numbers #1", "value": 15, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NNN XXX0a XX0b XXX0c SSS", "EEE XXX0a XX0b XXX0c WWW"]]}] },
    { "display_name": "Any Matching Numbers #2", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXXX0a XXXX0b XXXX0c DDa"]]}] },
    { "display_name": "Any Matching Numbers #3", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXX0a XXX0b XXX0c DDDDDa"]]}] },
    { "display_name": "Any Matching Numbers #4", "value": 40, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF XXXX0a FFF XXXX0b"]]}] },
    { "display_name": "Consecutive Numbers #1", "value": 10, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF XXX0a XXX1a XXX2a XXX3a", "FF XXX0a XXX1a XXX2b XXX3b"]]}] },
    { "display_name": "Consecutive Numbers #2", "value": 15, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXX0a XXXX1a XXX0b XXXX1b"]]}] },
    { "display_name": "Consecutive Numbers #3", "value": 20, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF ZZ XXX0a XXX1a DDa"]]}] },
    { "display_name": "Consecutive Numbers #4", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXX0a XX1a XXXX2a XX3a XXX4a"]]}] },
    { "display_name": "Consecutive Numbers #5", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XXX0a XX1a NEWS XX2b XXX3b"]]}] },
    { "display_name": "Consecutive Numbers #6", "value": 35, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF XX2a XXX1a XXXX0a DDDa", "FF XX2a XXX1b XXXX0c DDDb"]]}] },
    { "display_name": "Consecutive Numbers #7", "value": 55, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["XX0a XXX1a XXXX2a XXXXX3a", "XX0a XXX1a XXXX2a XXXXX3b"]]}] },
    { "display_name": "Consecutive Numbers #8", "value": 70, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 1233a 4566a 7899a", "FF 1233a 4566b 7899c"]]} ] },
    { "display_name": "13579 #1", "value": 20, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NNN 111a 33a 555a SSS", "NNN 111a 33b 555c SSS"]]}] },
    { "display_name": "13579 #2", "value": 20, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["EEE 555a 77a 999a WWW", "EEE 555a 77b 999c WWW"]]}] },
    { "display_name": "13579 #3", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["111a 5555a 999a DDDDa", "111a 5555b 999a DDDDb"]]}] },
    { "display_name": "13579 #4", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF ZZZ 333a 5555a 77a", "FF ZZZ 333a 5555b 77c"]]}] },
    { "display_name": "13579 #5", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["111a 33a 5555a 77a 999a"]]}] },
    { "display_name": "13579 #6", "value": 35, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 1111a 3333a|5555a|7777a|9999a DDDDa", "FF 3333a 5555a|7777a|9999a DDDDa", "FF 5555a 7777a|9999a DDDDa", "FF 7777a 9999a DDDDa", "FF 1111a 3333b|5555b|7777b|9999b DDDDc", "FF 3333a 5555b|7777b|9999b DDDDc", "FF 5555a 7777b|9999b DDDDc", "FF 7777a 9999b DDDDc"]]}] },
    { "display_name": "13579 #7", "value": 40, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF 111a 333b 55555c", "FFF 555a 777b 99999c"]]}] },
    { "display_name": "13579 #8", "value": 70, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["11a 33a 55a 77a 99a 11b 11c", "11a 33a 55a 77a 99a 33b 33c", "11a 33a 55a 77a 99a 55b 55c", "11a 33a 55a 77a 99a 77b 77c", "11a 33a 55a 77a 99a 99b 99c"]]} ] },
    { "display_name": "Winds-Dragons #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NNN EEE WWW SSS DDa"]]}] },
    { "display_name": "Winds-Dragons #2", "value": 50, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF DDDa DDDDDb DDDc"]]}] },
    { "display_name": "Winds-Dragons #3", "value": 55, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["DDDa NN EE WW SS DDDb"]]}] },
    { "display_name": "369 #1", "value": 25, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 333a 666a 999a DDDa", "FF 333a 666b 999c DDDb"]]}] },
    { "display_name": "369 #2", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["333a 6666a 999a NEWS", "333a 6666b 999c NEWS"]]}] },
    { "display_name": "369 #3", "value": 35, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["333a 666a 999a 33333b"]]}] },
    { "display_name": "369 #4", "value": 45, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 3a 66a 999a 333b 66b 9b"]]}] },
    { "display_name": "369 #5", "value": 70, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 369Da 369Db 369Dc"]]}] },
    { "display_name": "Mad Math #1", "value": 20, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["333a 777a 10a DDDb DDDc"]]}] },
    { "display_name": "Mad Math #2", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF 3333a 9999a 27a", "FFFF 3333a 9999b 27c"]]}] },
    { "display_name": "Mad Math #3", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFFF 5555a 2222a 10a", "FFFF 5555a 2222b 10c"]]}] },
    { "display_name": "Mad Math #4", "value": 70, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["NEWS 2468a 3579a 44a", "NEWS 2468a 3579b 44c"]]}] },
    { "display_name": "Big Brain #1", "value": 30, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FFF 2222a 7777a DDDa", "FFF 2222a 7777b DDDc"]]}] },
    { "display_name": "Big Brain #2", "value": 40, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 1111a NEWS 6666a", "FF 1111a NEWS 6666b"]]}] },
    { "display_name": "Big Brain #3", "value": 50, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF 333a NN E W SS 888a", "FF 333a NN E W SS 888b"]]}] },
    { "display_name": "Big Brain #4", "value": 70, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["N EE 05a 10a 15a 20a WW S"]]}] },
    { "display_name": "Big Brain #5", "value": 85, "when": [{"name": "has_no_call_named", "opts": ["am_pung", "am_kong", "am_quint"]}, {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], ["FF NEWS N0W WE W0N"]]}] }
  ]
