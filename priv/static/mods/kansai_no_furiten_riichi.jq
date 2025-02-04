if (.buttons | has("riichi")) then
  .buttons.riichi.show_when += [{"name": "not_match", "opts": [["hand", "calls", "any_discard"], ["win"]]}]
else . end
|
if (.buttons | has("open_riichi")) then
  .buttons.open_riichi.show_when += [{"name": "not_match", "opts": [["hand", "calls", "any_discard"], ["win"]]}]
else . end
