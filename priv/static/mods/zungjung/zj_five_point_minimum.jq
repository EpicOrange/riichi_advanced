([{"name": "has_yaku_with_discard", "opts": [5]}, {"name": "has_yaku2_with_discard", "opts": [1]}]) as $checks
|
if (.buttons | has("ron")) then
  .buttons.ron.show_when += [$checks]
else . end
|
if (.buttons | has("chankan")) then
  .buttons.chankan.show_when += [$checks | map(.name |= sub("discard"; "call"))]
else . end
|
if (.buttons | has("tsumo")) then
  .buttons.tsumo.show_when += [$checks | map(.name |= sub("discard"; "hand"))]
else . end
