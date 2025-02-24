.after_initialization.actions += [
  ["add_rule", "Local Yaku (Yakuman)", "(Shousharin) Your closed winning hand is 11223344556677 or 33445566778899 of circles.", 113],
  ["add_rule", "Local Yaku (Yakuman)", "(Shouchikurin) Your closed winning hand is 11223344556677 or 33445566778899 of bamboo.", 113],
  ["add_rule", "Local Yaku (Yakuman)", "(Shousuurin) Your closed winning hand is 11223344556677 or 33445566778899 of characters.", 113]
]
|
(if .buttons | has("ton") then ["ton", "chii", "chon", "chon_honors", "shouminfuun", "pon", "daiminkan", "kapon", "kakakan", "kafuun", "kakan"] else ["chii", "pon", "daiminkan", "kakan"] end) as $open_calls
|
.yakuman += [
  {
    "display_name": "Shousharin",
    "value": 1,
    "when": [{"name": "has_no_call_named", "opts": $open_calls}, {"name": "match", "opts": [["hand", "calls", "winning_tile"], ["shousharin"]]}]
  },
  {
    "display_name": "Shouchikurin",
    "value": 1,
    "when": [{"name": "has_no_call_named", "opts": $open_calls}, {"name": "match", "opts": [["hand", "calls", "winning_tile"], ["shouchikurin"]]}]
  },
  {
    "display_name": "Shousuurin",
    "value": 1,
    "when": [{"name": "has_no_call_named", "opts": $open_calls}, {"name": "match", "opts": [["hand", "calls", "winning_tile"], ["shousuurin"]]}]
  }
]
|
.shousharin_definition = [[ [[["1p","1p","2p","2p","3p","3p","4p","4p","5p","5p","6p","6p","7p","7p"], ["3p","3p","4p","4p","5p","5p","6p","6p","7p","7p","8p","8p","9p","9p"]], 1] ]]
|
.shouchikurin_definition = [[ [[["1s","1s","2s","2s","3s","3s","4s","4s","5s","5s","6s","6s","7s","7s"], ["3s","3s","4s","4s","5s","5s","6s","6s","7s","7s","8s","8s","9s","9s"]], 1] ]]
|
.shousuurin_definition = [[ [[["1m","1m","2m","2m","3m","3m","4m","4m","5m","5m","6m","6m","7m","7m"], ["3m","3m","4m","4m","5m","5m","6m","6m","7m","7m","8m","8m","9m","9m"]], 1] ]]
