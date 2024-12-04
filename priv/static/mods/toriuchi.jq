.before_win.actions += [
  ["when", [["won_by_discard", "won_by_call"]], [
    ["as", "last_discarder", ["reveal_hand"]],
    ["when", [[
      {"name": "not_match", "as": "last_discarder", "opts": [["hand", "calls", "winning_tile"], [[[["7p"], 1]]]]},
      {"name": "match", "opts": [["hand", "calls", "winning_tile"], [[[["8s"], 1]]]]}
    ]], [["add_counter", "toriuchi", "count_matches", ["hand", "calls", "winning_tile"], [[[["1s"], 1]]]]]]
  ]]
]
