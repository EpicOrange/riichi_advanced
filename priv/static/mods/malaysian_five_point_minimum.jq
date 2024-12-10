def add_5_condition($check):
  {"name": $check, "opts": [5, ["yaku"]]};

.buttons.ron.show_when += [add_5_condition("has_yaku_with_discard")]
|
.buttons.chankan.show_when += [add_5_condition("has_yaku_with_call")]
|
.buttons.tsumo.show_when += [add_5_condition("has_yaku_with_hand")]
