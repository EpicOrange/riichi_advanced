.score_calculation.riichi_value = 5000
|
(.before_turn_change.actions[] | select((.[0] == "when") and (.[1][] | select(.name == "status" and .opts == ["just_reached"]))))[2][0][1] = -5000
|
(.before_call.actions[] | select((.[0] == "when") and (.[1][] | select(.name == "status" and .opts == ["just_reached"]))))[2][0][1] = -5000
|
(.buttons.riichi.actions[] | select((.[0] == "when") and (.[1][] | select(type == "object" and .name == "everyone_status" and .opts == ["riichi"]))))[2][0][1] = -5000
|
(.buttons.riichi.show_when[] | select(type == "object" and .name == "has_score")).opts = [5000]
