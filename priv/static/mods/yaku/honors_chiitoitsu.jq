.after_initialization.actions += [
  ["add_rule", "Local Yaku (1 Han)", "(Sangen Chiitoitsu) Win with a seven pairs hand that includes all three dragons.", 101],
  ["add_rule", "Local Yaku (1 Han)", "(Suushi Chiitoitsu) Win with a seven pairs hand that includes all four winds.", 101],
  ["add_rule", "Local Yaku (Double Yakuman)", "(Daichishin) \"Big Seven Stars\". Win with a seven pairs hand consisting of all seven honor tiles.", 126]
]
|
.yaku += [
  {
    "display_name": "Sangen Chiitoitsu",
    "value": 1,
    "when": [{"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ [["haku_pair"], 1], [["hatsu_pair"], 1], [["chun_pair"], 1], [["pair"], 4] ]]]}]
  },
  {
    "display_name": "Suushi Chiitoitsu",
    "value": 1,
    "when": [{"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ [["ton_pair"], 1], [["non_pair"], 1], [["shaa_pair"], 1], [["pei_pair"], 1], [["pair"], 3] ]]]}]
  }
]
|
if has("yakuman") then
  .yakuman += [
    {
      "display_name": "Daichishin",
      "value": 2,
      "when": [{"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ [["ton_pair"], 1], [["non_pair"], 1], [["shaa_pair"], 1], [["pei_pair"], 1], [["haku_pair"], 1], [["hatsu_pair"], 1], [["chun_pair"], 1] ]]]}]
    }
  ]
else
  .yaku += [
    {
      "display_name": "Daichishin",
      "value": 26,
      "when": [{"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ [["ton_pair"], 1], [["non_pair"], 1], [["shaa_pair"], 1], [["pei_pair"], 1], [["haku_pair"], 1], [["hatsu_pair"], 1], [["chun_pair"], 1] ]]]}]
    }
  ]
  |
  .yaku_precedence += {
    "Daichishin": ["Sangen Chiitoitsu", "Suushi Chiitoitsu"]
  }
end
