.after_initialization.actions += [
  ["add_rule", "Yakuman", "Blue Tunnel", "Your hand consists of only 248p (2,4,8 circles), green dragon, and one type of wind.", 113],
  ["update_rule", "Yakuman", "Blue Tunnel", "%{example_hand}", {"example_hand": ["2p", "2p", "2p", "4p", "4p", "4p", "8p", "8p", "8p", "6z", "6z", "6z", "1z", "3x", "1z"]}]
]
|
.yakuman += [
  {
    "display_name": "Blue Tunnel",
    "value": 1,
    "when": [[
      {"name": "winning_hand_consists_of", "opts": ["2p","4p","8p","6z","1z"]},
      {"name": "winning_hand_consists_of", "opts": ["2p","4p","8p","6z","2z"]},
      {"name": "winning_hand_consists_of", "opts": ["2p","4p","8p","6z","3z"]},
      {"name": "winning_hand_consists_of", "opts": ["2p","4p","8p","6z","4z"]}
    ]]
  }
]
