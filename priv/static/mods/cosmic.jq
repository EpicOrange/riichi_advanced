.score_calculation += {
  "limit_thresholds": [
    [3, 70], [4, 40], [5, 0],
    [6, 0],
    [8, 0],
    [11, 0],
    [13, 0],
    [18, 0],
    [26, 0],
    [39, 0],
    [52, 0],
    [65, 0],
    [78, 0],
    [91, 0],
    [104, 0]
  ],
  "limit_scores": [
    8000, 8000, 8000,
    12000,
    16000,
    24000,
    32000,
    48000,
    64000,
    96000,
    128000,
    160000,
    192000,
    224000,
    256000
  ],
  "limit_names": [
    "Mangan", "Mangan", "Mangan",
    "Haneman",
    "Baiman",
    "Sanbaiman",
    "Yakuman",
    "Haneyakuman",
    "Double Yakuman",
    "Triple Yakuman",
    "Quadruple Yakuman",
    "Quintuple Yakuman",
    "Sextuple Yakuman",
    "Septuple Yakuman",
    "Octuple Yakuman"
  ]
}
|
.after_win.actions += [
  # tsubame gaeshi awards the riichi bet
  # set a status put_down_riichi_stick so this doesn't happen twice (in case of multiple ron)
  ["when", [{"name": "has_existing_yaku", "opts": ["Tsubame Gaeshi"]}], [
    ["as", "last_discarder", [["run", "put_down_riichi_stick"]]]
  ]]
]
|
.yaku |= map(
  if .display_name == "Rinshan" then .when = [{"name": "not_status_missing", "opts": ["kan", "fuun"]}] else . end
  |
  if .display_name == "Chiitoitsu" or .display_name == "Ryanpeikou" then
    .value = 1
  else . end
  |
  if .display_name == "Chankan" then
    .when += [{"name": "last_call_is", "opts": ["kakan", "kakapon"]}]
  else . end
)
|
.meta_yaku += [
  { "display_name": "Chiitoitsu", "value": 1, "when": [{"name": "has_no_call_named", "opts": ["ton", "chii", "chon", "chon_honors", "daiminfuun", "pon", "daiminkan", "kapon", "kakakan", "kafuun", "kakan"]}, {"name": "has_existing_yaku", "opts": ["Chiitoitsu"]}] },
  { "display_name": "Ryanpeikou", "value": 2, "when": [{"name": "has_no_call_named", "opts": ["ton", "chii", "chon", "chon_honors", "daiminfuun", "pon", "daiminkan", "kapon", "kakakan", "kafuun", "kakan"]}, {"name": "has_existing_yaku", "opts": ["Ryanpeikou"]}] }
]
