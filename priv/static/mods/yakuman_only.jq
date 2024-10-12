# Add han argument to has_han_with_discard
.buttons.ron.show_when |= map(if . == {"name": "has_yaku_with_discard", "opts": [1, ["yaku", "yakuman"]]} then [
  [
    {"name": "has_yaku_with_discard", "opts": [1, ["yaku"]]},
    {"name": "has_yaku_with_discard", "opts": [13, ["yaku", "extra_yaku"]]}
  ],
  {"name": "has_yaku_with_discard", "opts": [1, ["yakuman"]]}
] else . end)
|
# Add han argument to has_han_with_hand
.buttons.tsumo.show_when |= map(if . == {"name": "has_yaku_with_hand", "opts": [1, ["yaku", "yakuman"]]} then [
  [
    {"name": "has_yaku_with_hand", "opts": [1, ["yaku"]]},
    {"name": "has_yaku_with_hand", "opts": [13, ["yaku", "extra_yaku"]]}
  ],
  {"name": "has_yaku_with_hand", "opts": [1, ["yakuman"]]}
] else . end)

