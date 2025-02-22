if (.buttons | has("ankan")) then
  .buttons.ankan.call_conditions |= [{"name": "status_missing", "opts": ["riichi"]}] + .
else . end
