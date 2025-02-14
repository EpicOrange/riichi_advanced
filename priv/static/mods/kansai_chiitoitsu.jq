def replace($from; $to):
  if . == $from then $to else . end;

.tenpai_definition |= map(replace([ [["nojoker", "koutsu"], -1], [["pair"], 6] ]; [ [["pair"], 6] ]))
|
.tenpai_14_definition |= map(replace([ [["nojoker", "quad"], -1], [["koutsu"], -2], [["pair"], 6] ]; [ [["pair"], 6] ]))
|
.win_definition |= map(replace([ [["nojoker", "quad"], -1], [["pair"], 7] ]; [ [["pair"], 7] ]))
