# update base riichi value used in scoring
.score_calculation.riichi_value = 5000
|
# update riichi stick placement bet triggered by turn change
(.before_turn_change.actions[] | select((.[0] == "when") and (.[1][] | select(.name == "status" and .opts == ["just_reached"]))))[2][0][1] = -5000
|
# update riichi stick placement bet triggered by call
(.before_call.actions[] | select((.[0] == "when") and (.[1][] | select(.name == "status" and .opts == ["just_reached"]))))[2][0][1] = -5000
|
# update riichi button score requirement
(.buttons.riichi.show_when[] | select(type == "object" and .name == "has_score")).opts = [5000]
|
# update riichi bet triggered by suucha riichi
.buttons.riichi.actions |= map(if .[0] == "when" and (.[1][] | select(type == "object" and .name == "everyone_status" and .opts == ["riichi"]))? then .[2][0][1] = -5000 else . end)
|
# do the same for open riichi, if it exists
if (.buttons | has("open_riichi")) then
  # update riichi button score requirement
  (.buttons.open_riichi.show_when[] | select(type == "object" and .name == "has_score")).opts = [5000]
  |
  # update riichi bet triggered by suucha riichi
  .buttons.open_riichi.actions |= map(if .[0] == "when" and (.[1][] | select(type == "object" and .name == "everyone_status" and .opts == ["riichi"]))? then .[2][0][1] = -5000 else . end)
else . end
