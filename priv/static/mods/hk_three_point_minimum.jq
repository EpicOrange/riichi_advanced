def add_3_condition($type):
  {"name": $type, "opts": [3, ["yaku"]]};

.buttons.ron.show_when += [add_3_condition("has_yaku_with_discard")]
|
.buttons.chankan.show_when += [add_3_condition("has_yaku_with_call")]
|
.buttons.tsumo.show_when += [add_3_condition("has_yaku_with_hand")]
