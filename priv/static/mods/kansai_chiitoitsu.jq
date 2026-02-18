def replace($from; $to):
  if . == $from then $to else . end;

.after_initialization.actions += [
  ["add_rule", "Rules", "Win Condition", "- (Kansai Chiitoitsu) Seven pairs (repeats allowed).", -100],
  ["delete_rule", "2 Han", "Chiitoitsu"],
  ["add_rule", "2 Han", "Chiitoitsu", "Your hand consists of seven pairs. Repeats allowed.", 100],
  ["update_rule", "2 Han", "Chiitoitsu", "%{example_hand}", {"example_hand": ["2m", "2m", "6m", "6m", "9p", "9p", "9p", "4s", "4s", "7s", "7s", "3z", "3z", "3x", "9p"]}]
]
|
.tenpai_definition |= map(replace([ [["nojoker", "koutsu"], -1], [["pair"], 6], [["any"], 1] ]; [ [["pair"], 6], [["any"], 1] ]))
|
if has("tenpai_14_definition") then
  .tenpai_14_definition |= map(replace([ [["nojoker", "quad"], -1], [["nojoker", "koutsu"], -2], [["pair"], 6], [["any"], 1] ]; [ [["pair"], 6], [["any"], 1] ]))
else . end
|
.win_definition |= map(replace([ [["nojoker", "quad"], -1], [["pair"], 7] ]; [ [["pair"], 7] ]))
|
.yaku |= walk(replace([ [["nojoker", "quad"], -1], [["pair"], 7] ]; [ [["pair"], 7] ]))
