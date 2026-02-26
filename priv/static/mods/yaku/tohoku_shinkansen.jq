.after_initialization.actions += [
  ["add_rule", "Yakuman", "Tohoku Shinkansen", "Your closed hand consists of an ittsuu and east/north winds.", 113],
  ["update_rule","Yakuman", "Tohoku Shinkansen", "%{example_hand}", {"example_hand": ["1s", "2s", "3s", "4s", "5s", "6s", "7s", "8s", "9s", "1z", "1z", "4z", "4z", "3x", "4z"]}]
]
|
.yakuman += [
  {
    "display_name": "Tohoku Shinkansen",
    "value": 1,
    "when": [{"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ "exhaustive", [["ittsuu"], 1], [["ton","pei"], 1], [["ton_pair","pei_pair"], 1] ]]]}]
  }
]
