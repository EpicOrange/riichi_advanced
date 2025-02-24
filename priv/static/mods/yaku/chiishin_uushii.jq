.after_initialization.actions += [
  ["add_rule", "Local Yaku (Mangan)", "(Chiishin Uushii) \"Seven Stars Disconnected\". Mangan if you have one of every honor tile, plus 7 of 9 tiles in different suji (e.g. 14m25p369s).", 105],
  ["add_rule", "Win Condition", "- (Chiishin Uushii) All seven honor tiles plus 7 of 9 tiles in different suji (e.g. 14m25p369s).", -100]
]
|
.chiishin_uushii += [
  {
    "display_name": "Chiishin Uushii",
    "value": 5,
    "when": [
      {"name": "not_has_points", "opts": [5]},
      {"name": "match", "opts": [["hand", "calls", "winning_tile"], ["chiishin_uushii"]]}
    ]
  }
]
|
.yaku_precedence += {
  "Chiishin Uushii": [1, 2, 3, 4]
}
|
if .score_calculation.yaku_lists | any(index("chiishin_uushii")) then . else
  .score_calculation.yaku_lists += ["chiishin_uushii"]
end
|
.chiishin_uushii_definition = [
  [ "unique", [["1z","2z","3z","4z","5z","6z","7z"], 7], [["1m","4m","7m","2p","5p","8p","3s","6s","9s"], 7] ],
  [ "unique", [["1z","2z","3z","4z","5z","6z","7z"], 7], [["1m","4m","7m","3p","6p","9p","2s","5s","8s"], 7] ],
  [ "unique", [["1z","2z","3z","4z","5z","6z","7z"], 7], [["2m","5m","8m","1p","4p","7p","3s","6s","9s"], 7] ],
  [ "unique", [["1z","2z","3z","4z","5z","6z","7z"], 7], [["2m","5m","8m","3p","6p","9p","1s","4s","7s"], 7] ],
  [ "unique", [["1z","2z","3z","4z","5z","6z","7z"], 7], [["3m","6m","9m","1p","4p","7p","2s","5s","8s"], 7] ],
  [ "unique", [["1z","2z","3z","4z","5z","6z","7z"], 7], [["3m","6m","9m","2p","5p","8p","1s","4s","7s"], 7] ]
]
|
.win_definition += .chiishin_uushii_definition
|
.tenpai_definition += [
  [ "unique", [["1m","4m","7m","2p","5p","8p","3s","6s","9s","1z","2z","3z","4z","5z","6z","7z"], 13] ],
  [ "unique", [["1m","4m","7m","3p","6p","9p","2s","5s","8s","1z","2z","3z","4z","5z","6z","7z"], 13] ],
  [ "unique", [["2m","5m","8m","1p","4p","7p","3s","6s","9s","1z","2z","3z","4z","5z","6z","7z"], 13] ],
  [ "unique", [["2m","5m","8m","3p","6p","9p","1s","4s","7s","1z","2z","3z","4z","5z","6z","7z"], 13] ],
  [ "unique", [["3m","6m","9m","1p","4p","7p","2s","5s","8s","1z","2z","3z","4z","5z","6z","7z"], 13] ],
  [ "unique", [["3m","6m","9m","2p","5p","8p","1s","4s","7s","1z","2z","3z","4z","5z","6z","7z"], 13] ]
]
