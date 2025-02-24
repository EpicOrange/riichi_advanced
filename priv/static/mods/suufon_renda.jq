.after_initialization.actions += [["add_rule", "Suufon Renda", "If all four players discard the same wind tile as their first discard, the game ends in an abortive draw."]]
|
.play_effects = [
  ["1z", [["when", [{"name": "status", "opts": ["discards_empty"]}], [
    ["set_status", "suufonrenda_1z"],
    ["when", [{"name": "everyone_status", "opts": ["suufonrenda_1z"]}], [["pause", 1000], ["abortive_draw", "Suufon Renda"]]]
  ]]]],
  ["2z", [["when", [{"name": "status", "opts": ["discards_empty"]}], [
    ["set_status", "suufonrenda_2z"],
    ["when", [{"name": "everyone_status", "opts": ["suufonrenda_2z"]}], [["pause", 1000], ["abortive_draw", "Suufon Renda"]]]
  ]]]],
  ["3z", [["when", [{"name": "status", "opts": ["discards_empty"]}], [
    ["set_status", "suufonrenda_3z"],
    ["when", [{"name": "everyone_status", "opts": ["suufonrenda_3z"]}], [["pause", 1000], ["abortive_draw", "Suufon Renda"]]]
  ]]]],
  ["4z", [["when", [{"name": "status", "opts": ["discards_empty"]}], [
    ["set_status", "suufonrenda_4z"],
    ["when", [{"name": "everyone_status", "opts": ["suufonrenda_4z"]}], [["pause", 1000], ["abortive_draw", "Suufon Renda"]]]
  ]]]]
] + .play_effects
