def add_yakuman_condition($check; $has_kazoe):
  if $has_kazoe then
    [
      [
        {"name": $check, "opts": [1, ["yaku"]]},
        {"name": $check, "opts": [13, ["yaku", "extra_yaku"]]}
      ],
      {"name": $check, "opts": [1, ["yakuman"]]}
    ]
  else
    {"name": $check, "opts": [1, ["yakuman"]]}
  end;

any(.score_calculation.limit_thresholds[]; .[0] >= 13) as $has_kazoe
|
.buttons.ron.show_when |= map(if . == {"name": "has_yaku_with_discard", "opts": [1, ["yaku", "yakuman"]]} then add_yakuman_condition("has_yaku_with_discard"; $has_kazoe) else . end)
|
.buttons.chankan.show_when += [add_yakuman_condition("has_yaku_with_call"; $has_kazoe)]
|
.buttons.tsumo.show_when |= map(if . == {"name": "has_yaku_with_hand", "opts": [1, ["yaku", "yakuman"]]} then add_yakuman_condition("has_yaku_with_hand"; $has_kazoe) else . end)
