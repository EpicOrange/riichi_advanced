# Add han argument to has_han_with_discard
.buttons.ron.show_when |= map(if . == ["has_han_with_discard", "has_yakuman_with_discard"] then [{"name": "has_extra_han_with_discard", "opts": [13]}, "has_yakuman_with_discard"] else . end)
|
# Add han argument to has_han_with_hand
.buttons.tsumo.show_when |= map(if . == ["has_han_with_hand", "has_yakuman_with_hand"] then [{"name": "has_extra_han_with_hand", "opts": [13]}, "has_yakuman_with_hand"] else . end)

