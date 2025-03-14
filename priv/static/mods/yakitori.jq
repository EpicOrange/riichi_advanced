.after_initialization.actions += [["add_rule", "Rules", "Yakitori", "Every player starts with a yakitori token that is flipped after their first win. If the game ends, every player with an unflipped yakitori token pays each player \($penalty) points."]]
|
.persistent_statuses += ["yakitori_unflipped", "yakitori_flipped"]
|
.shown_statuses_public += ["yakitori_unflipped", "yakitori_flipped"]
|
.after_start.actions += [
  ["when_anyone", [{"name": "status_missing", "opts": ["yakitori_unflipped", "yakitori_flipped"]}], [["set_status", "yakitori_unflipped"]]]
]
|
.before_win.actions += [
  ["when", [{"name": "status", "opts": ["yakitori_unflipped"]}], [["unset_status", "yakitori_unflipped"], ["set_status", "yakitori_flipped"]]]
]
|
.before_conclusion.actions += [
  ["when_anyone", [{"name": "status", "opts": ["yakitori_unflipped"]}], [
    ["push_message", "pays everyone \($penalty) points for not winning any round"],
    ["subtract_score", $penalty], ["add_score", $penalty, "shimocha"],
    ["subtract_score", $penalty], ["add_score", $penalty, "toimen"],
    ["subtract_score", $penalty], ["add_score", $penalty, "kamicha"]
  ]]
]
