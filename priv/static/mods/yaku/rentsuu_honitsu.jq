.after_initialization.actions += [["add_rule", "Local Yaku (Mangan)", "(Rentsuu Honitsu) Mangan if you have honitsu with dragon yakuhai matching the suit: manzu with chun, pinzu with hatsu (not a typo), or souzu with haku (also not a typo)."]]
|
.rentsuu_honitsu_definition = [
  [ "exhaustive", [[["1m","2m"],["1p","2p"],["1s","2s"],["8m","9m"],["8p","9p"],["8s","9s"]], 1], [["shuntsu", "koutsu"], 3], [["pair"], 1] ],
  [ "exhaustive", [["shuntsu", "koutsu"], 3], [["pair"], 1], [["kanchan"], 1] ]
]
|
.yaku_rentsuu_honitsu += [
  {
    "display_name": "Rentsuu Honitsu",
    "value": 5,
    "when": [
      {"name": "not_has_points", "opts": [5]},
      {"name": "has_existing_yaku", "opts": ["Honitsu"]},
      [
        [{"name": "winning_hand_consists_of", "opts": ["1m","2m","3m","4m","5m","6m","7m","8m","9m","1z","2z","3z","4z","5z","6z","7z"]}, {"name": "has_existing_yaku", "opts": ["Chun"]}],
        [{"name": "winning_hand_consists_of", "opts": ["1p","2p","3p","4p","5p","6p","7p","8p","9p","1z","2z","3z","4z","5z","6z","7z"]}, {"name": "has_existing_yaku", "opts": ["Hatsu"]}],
        [{"name": "winning_hand_consists_of", "opts": ["1s","2s","3s","4s","5s","6s","7s","8s","9s","1z","2z","3z","4z","5z","6z","7z"]}, {"name": "has_existing_yaku", "opts": ["Haku"]}]
      ]
    ]
  }
]
|
.yaku_precedence += {
  "Rentsuu Honitsu": [1, 2, 3, 4]
}
|
if .score_calculation.yaku_lists | any(index("yaku_rentsuu_honitsu")) then . else
  .score_calculation.yaku_lists += ["yaku_rentsuu_honitsu"]
end
