.after_initialization.actions += [
  ["add_rule", "Local Yaku (Yakuman)", "(Daisharin) \"Big Wheels\". Your closed winning hand is 22334455667788 of circles.", 113],
  ["add_rule", "Local Yaku (Yakuman)", "(Daichikurin) \"Bamboo Forest\". Your closed winning hand is 22334455667788 of bamboo.", 113],
  ["add_rule", "Local Yaku (Yakuman)", "(Daisuurin) \"Numerous Numbers\". Your closed winning hand is 22334455667788 of characters.", 113]
]
|
(if .buttons | has("ton") then ["ton", "chii", "chon", "chon_honors", "daiminfuun", "pon", "daiminkan", "kapon", "kakakan", "kafuun", "kakan"] else ["chii", "pon", "daiminkan", "kakan"] end) as $open_calls
|
.yakuman += [
  {
    "display_name": "Daisharin",
    "value": 1,
    "when": [{"name": "has_no_call_named", "opts": $open_calls}, {"name": "match", "opts": [["hand", "calls", "winning_tile"], ["daisharin"]]}]
  },
  {
    "display_name": "Daichikurin",
    "value": 1,
    "when": [{"name": "has_no_call_named", "opts": $open_calls}, {"name": "match", "opts": [["hand", "calls", "winning_tile"], ["daichikurin"]]}]
  },
  {
    "display_name": "Daisuurin",
    "value": 1,
    "when": [{"name": "has_no_call_named", "opts": $open_calls}, {"name": "match", "opts": [["hand", "calls", "winning_tile"], ["daisuurin"]]}]
  }
]
|
.daisharin_definition = [[ [[["2p","2p","3p","3p","4p","4p","5p","5p","6p","6p","7p","7p","8p","8p"]], 1] ]]
|
.daichikurin_definition = [[ [[["2s","2s","3s","3s","4s","4s","5s","5s","6s","6s","7s","7s","8s","8s"]], 1] ]]
|
.daisuurin_definition = [[ [[["2m","2m","3m","3m","4m","4m","5m","5m","6m","6m","7m","7m","8m","8m"]], 1] ]]
