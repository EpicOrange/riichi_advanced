.after_initialization.actions += [["add_rule", "Rules", "Oka", "At the end of the game, 1st/2nd/3rd/4th receive a bonus of \($ante * 3000)/\($ante * -1000)/\($ante * -1000)/\($ante * -1000) points."]]
|
.before_conclusion.actions += [
  ["push_system_message", "Applied oka of \($ante)"],
  ["when", [{"name": "placement", "opts": [1]}], [["add_score", $ante * 3000]]],
  ["when", [{"name": "placement", "opts": [2]}], [["add_score", $ante * -1000]]],
  ["when", [{"name": "placement", "opts": [3]}], [["add_score", $ante * -1000]]],
  ["when", [{"name": "placement", "opts": [4]}], [["add_score", $ante * -1000]]]
]
