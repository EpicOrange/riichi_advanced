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
    ["push_message", "pays everyone 4000 points for not winning any round"],
    ["subtract_score", 4000], ["add_score", 4000, "shimocha"],
    ["subtract_score", 4000], ["add_score", 4000, "toimen"],
    ["subtract_score", 4000], ["add_score", 4000, "kamicha"]
  ]]
]
