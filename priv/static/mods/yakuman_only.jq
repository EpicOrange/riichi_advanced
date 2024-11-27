def add_yakuman_condition($type):
  [
    [
      {"name": $type, "opts": [1, ["yaku"]]},
      {"name": $type, "opts": [13, ["yaku", "extra_yaku"]]}
    ],
    {"name": $type, "opts": [1, ["yakuman"]]}
  ];

.buttons.ron.show_when |= map(if . == {"name": "has_yaku_with_discard", "opts": [1, ["yaku", "yakuman"]]} then add_yakuman_condition("has_yaku_with_discard") else . end)
|
.buttons.chankan.show_when += [add_yakuman_condition("has_yaku_with_call")]
|
.buttons.tsumo.show_when |= map(if . == {"name": "has_yaku_with_hand", "opts": [1, ["yaku", "yakuman"]]} then add_yakuman_condition("has_yaku_with_hand") else . end)
