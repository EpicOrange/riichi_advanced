def add_yakuman_condition($check; $check_yakuman; $has_kazoe):
  if $has_kazoe then
    [
      {"name": $check, "opts": [13]},
      {"name": $check_yakuman, "opts": [1]}
    ]
  else
    {"name": $check_yakuman, "opts": [1]}
  end;

any(.score_calculation.limit_thresholds[]; .[0] >= 13) as $has_kazoe
|
[{"name": "has_yaku_with_discard", "opts": [3, 60]}, {"name": "has_yaku_with_discard", "opts": [4, 30]}, {"name": "has_yaku_with_discard", "opts": [5]}, {"name": "has_yaku2_with_discard", "opts": [1]}] as $minefield_condition
|
if (.buttons | has("ron")) then
  .buttons.ron.show_when |= map(if . == {"name": "has_yaku_with_discard", "opts": [1]} then add_yakuman_condition("has_yaku_with_discard"; "has_yaku2_with_discard"; $has_kazoe) else . end)
  |
  .buttons.ron.show_when |= map(if . == $minefield_condition then add_yakuman_condition("has_yaku_with_discard"; "has_yaku2_with_discard"; $has_kazoe) else . end)
else . end
|
if (.buttons | has("chankan")) then
  .buttons.chankan.show_when += [add_yakuman_condition("has_yaku_with_call"; "has_yaku2_with_call"; $has_kazoe)]
else . end
|
if (.buttons | has("tsumo")) then
  .buttons.tsumo.show_when |= map(if . == {"name": "has_yaku_with_hand", "opts": [1]} then add_yakuman_condition("has_yaku_with_hand"; "has_yaku2_with_hand"; $has_kazoe) else . end)
else . end
