.after_initialization.actions += [["add_rule", "Mangan", "Shanron Chonchu", "\"Two Dragons Fighting Over Pearls\". Mangan if you have kyandonhou (two mixed double sequences) in manzu and souzu, plus a pinzu pair. For the manzu and souzu suits, your two sequences in that suit should not overlap.", 105]]
|
.shanron_chonchu += [
  {
    "display_name": "Shanron Chonchu",
    "value": 5,
    "when": [
      {"name": "not_has_points", "opts": [5]},
      {"name": "match", "opts": [["hand", "calls", "winning_tile"], ["shanron_chonchu"]]}
    ]
  }
]
|
.shanron_chonchu_definition = [[
  "exhaustive",
  [[["1p","1p"],["2p","2p"],["3p","3p"],
    ["4p","4p"],["5p","5p"],["6p","6p"],
    ["7p","7p"],["8p","8p"],["9p","9p"]], 1],
  [["1p","2p","3p","4p","5p","6p","7p","8p","9p"], -1],
  [["pair"], -1],
  [[[[0,1,2],[10,11,12]]], 2]
]]
|
.yaku_precedence += {
  "Shanron Chonchu": [1, 2, 3, 4]
}
|
if .score_calculation.yaku_lists | any(index("shanron_chonchu")) then . else
  .score_calculation.yaku_lists += ["shanron_chonchu"]
end
