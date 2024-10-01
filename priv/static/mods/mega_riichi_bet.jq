(.before_turn_change.actions[] | select((.[0] == "when") and (.[1][] | select(.name == "status" and .opts == ["just_reached"]))))[2][0][1] = -5000
