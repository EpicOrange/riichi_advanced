.after_initialization.actions += [["add_rule", "Local Yaku (2 Han)", "(Sanpuukou) \"Three Wind Triplets\". You have three wind triplets.", 102]]
|
# sanma calls it pei_triplet
(if .set_definitions | has("pei_triplet") then "pei_triplet" else "pei" end) as $pei
|
(if .set_definitions | has("kontsu") then ["shuntsu", "kontsu", "koutsu"] else ["shuntsu", "koutsu"] end) as $others
|
.yaku += [
  {
    "display_name": "Sanpuukou",
    "value": 2,
    "when": [{"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ [["ton", "nan", "shaa", $pei], 3], [$others, 1], [["pair"], 1] ]]]}]
  }
]
