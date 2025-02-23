.after_initialization.actions += [["add_rule", "Uma", "At the end of the game, 1st/2nd/3rd/4th receive a bonus of \($_1st * 1000)/\($_2nd * 1000)/\($_3rd * 1000)/\($_4th * 1000) points."]]
|
.before_conclusion.actions += [
  ["push_system_message", "Applied uma of \($_1st)/\($_2nd)/\($_3rd)/\($_4th)"],
  ["when", [{"name": "placement", "opts": [1]}], [["add_score", $_1st * 1000]]],
  ["when", [{"name": "placement", "opts": [2]}], [["add_score", $_2nd * 1000]]],
  ["when", [{"name": "placement", "opts": [3]}], [["add_score", $_3rd * 1000]]],
  ["when", [{"name": "placement", "opts": [4]}], [["add_score", $_4th * 1000]]]
]
