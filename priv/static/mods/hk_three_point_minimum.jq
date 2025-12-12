
def add_3_condition($check):
  {"name": $check, "opts": [3]};

.after_initialization.actions += [["add_rule", "Rules", "Minimum Fan", "Your hand must score a minimum of 3 Fan.", -10]]
|
.buttons.ron.show_when += [add_3_condition("has_yaku_with_discard")]
|
.buttons.chankan.show_when += [add_3_condition("has_yaku_with_call")]
|
.buttons.tsumo.show_when += [add_3_condition("has_yaku_with_hand")]
