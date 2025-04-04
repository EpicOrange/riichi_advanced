.after_initialization.actions += [["add_rule", "Rules", "Head Bump", "If multiple players win on the same tile, only the closest player in turn order gets the win."]]
|
if (.buttons | has("ron")) then
  .buttons.ron.precedence_over += ["ron"]
else . end
|
if (.buttons | has("chankan")) then
  .buttons.chankan.precedence_over += ["chankan"]
else . end
