.after_initialization.actions += [["add_rule", "Local Yaku (Yakuman)", "(Hyakuman Goku) \"One Million Stones\". Your hand is purely character tiles whose numbers sum up to at least 100.", 113]]
|
.yakuman += [
  {
    "display_name": "Hyakuman Goku",
    "value": 1,
    "when": [{"name": "winning_hand_consists_of", "opts": ["1m","2m","3m","4m","5m","6m","7m","8m","9m"]}, {"name": "counter_at_least", "opts": ["hyakuman_goku", 100]}]
  }
]
|
.before_win.actions += [
  ["add_counter", "hyakuman_goku", "count_matches", ["hand", "calls", "winning_tile"], [[[["1m"], 1]]]],
  ["add_counter", "hyakuman_goku_2", "count_matches", ["hand", "calls", "winning_tile"], [[[["2m"], 1]]]],
  ["multiply_counter", "hyakuman_goku_2", 2],
  ["add_counter", "hyakuman_goku_3", "count_matches", ["hand", "calls", "winning_tile"], [[[["3m"], 1]]]],
  ["multiply_counter", "hyakuman_goku_3", 3],
  ["add_counter", "hyakuman_goku_4", "count_matches", ["hand", "calls", "winning_tile"], [[[["4m"], 1]]]],
  ["multiply_counter", "hyakuman_goku_4", 4],
  ["add_counter", "hyakuman_goku_5", "count_matches", ["hand", "calls", "winning_tile"], [[[["5m"], 1]]]],
  ["multiply_counter", "hyakuman_goku_5", 5],
  ["add_counter", "hyakuman_goku_6", "count_matches", ["hand", "calls", "winning_tile"], [[[["6m"], 1]]]],
  ["multiply_counter", "hyakuman_goku_6", 6],
  ["add_counter", "hyakuman_goku_7", "count_matches", ["hand", "calls", "winning_tile"], [[[["7m"], 1]]]],
  ["multiply_counter", "hyakuman_goku_7", 7],
  ["add_counter", "hyakuman_goku_8", "count_matches", ["hand", "calls", "winning_tile"], [[[["8m"], 1]]]],
  ["multiply_counter", "hyakuman_goku_8", 8],
  ["add_counter", "hyakuman_goku_9", "count_matches", ["hand", "calls", "winning_tile"], [[[["9m"], 1]]]],
  ["multiply_counter", "hyakuman_goku_9", 9],
  ["add_counter", "hyakuman_goku", "hyakuman_goku_2"],
  ["add_counter", "hyakuman_goku", "hyakuman_goku_3"],
  ["add_counter", "hyakuman_goku", "hyakuman_goku_4"],
  ["add_counter", "hyakuman_goku", "hyakuman_goku_5"],
  ["add_counter", "hyakuman_goku", "hyakuman_goku_6"],
  ["add_counter", "hyakuman_goku", "hyakuman_goku_7"],
  ["add_counter", "hyakuman_goku", "hyakuman_goku_8"],
  ["add_counter", "hyakuman_goku", "hyakuman_goku_9"]
]
