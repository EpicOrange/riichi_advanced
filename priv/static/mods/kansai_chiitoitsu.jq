def replace($from; $to):
  if . == $from then $to else . end;

.after_initialization.actions += [["add_rule", "Win Condition", "- (Kansai Chiitoitsu) Seven pairs (repeats allowed).", -100]]
|
.tenpai_definition |= map(replace([ [["nojoker", "koutsu"], -1], [["pair"], 6] ]; [ [["pair"], 6] ]))
|
if has("tenpai_14_definition") then
  .tenpai_14_definition |= map(replace([ [["nojoker", "quad"], -1], [["koutsu"], -2], [["pair"], 6] ]; [ [["pair"], 6] ]))
else . end
|
.win_definition |= map(replace([ [["nojoker", "quad"], -1], [["pair"], 7] ]; [ [["pair"], 7] ]))
