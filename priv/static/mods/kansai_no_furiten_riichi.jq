if (.buttons | has("riichi")) then
  .buttons.riichi.show_when = [{"name": "status_missing", "opts": ["furiten"]}] + .buttons.riichi.show_when
else . end
|
if (.buttons | has("open_riichi")) then
  .buttons.open_riichi.show_when = [{"name": "status_missing", "opts": ["furiten"]}] + .buttons.open_riichi.show_when
else . end
