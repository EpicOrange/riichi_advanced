.after_initialization.actions += [["add_rule", "Yakuman", "Tohoku Shinkansen", "Your closed hand consists of an ittsu and east/north winds.", 113]]
|
.yakuman += [
  {
    "display_name": "Tohoku Shinkansen",
    "value": 1,
    "when": [{"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ "exhaustive", [["ittsu"], 1], [["ton","pei"], 1], [["ton_pair","pei_pair"], 1] ]]]}]
  }
]
