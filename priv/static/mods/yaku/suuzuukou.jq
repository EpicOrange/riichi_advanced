# sanma calls it pei_triplet
(if .set_definitions | has("pei_triplet") then "pei_triplet" else "pei" end) as $pei
|
.yaku += [
  {
    "display_name": "Suuzuukou",
    "value": 2,
    "when": [{"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ [["ton", "nan", "shaa", $pei, "haku", "hatsu", "chun"], 4], [["pair"], 1] ]]]}]
  }
]