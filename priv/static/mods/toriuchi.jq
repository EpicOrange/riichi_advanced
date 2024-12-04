.before_win.actions += [
  ["when", [[
    {"name": "not_match", "opts": [["hand", "calls", "winning_tile"], [[[["7p"], 1]]]]},
    {"name": "match", "opts": [["hand", "calls", "winning_tile"], [[[["8s"], 1]]]]}
  ]], [["add_counter", "toriuchi", "count_matches", ["hand", "calls", "winning_tile"], [[[["1s"], 1]]]]]]
]
