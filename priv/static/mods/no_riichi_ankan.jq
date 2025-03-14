.after_initialization.actions += [["update_rule", "Rules", "Riichi", "You may not call concealed kan while in riichi."]]
|
if (.buttons | has("ankan")) then
  .buttons.ankan.call_conditions |= [{"name": "status_missing", "opts": ["riichi"]}] + .
else . end
