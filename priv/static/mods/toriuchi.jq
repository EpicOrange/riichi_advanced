.after_initialization.actions += [["update_rule", "Rules", "Shuugi", "(Toriuchi) On ron, each 1s (bird) tile is worth 1 shuugi, unless the discarder's hand contains 7p (pistol) which would shoot the birds dead. That is, unless the winner's hand contains 8s (birdcage) which would protect the birds from gunfire."]]
|
.before_win.actions += [
  ["when", [["won_by_discard", "won_by_call"]], [
    ["as", "last_discarder", ["reveal_hand"]],
    ["when", [[
      {"name": "not_match", "as": "last_discarder", "opts": [["hand", "calls", "winning_tile"], [[[["7p"], 1]]]]},
      {"name": "match", "opts": [["hand", "calls", "winning_tile"], [[[["8s"], 1]]]]}
    ]], [["add_counter", "toriuchi", "count_matches", ["hand", "calls", "winning_tile"], [[[["1s"], 1]]]]]]
  ]]
]
