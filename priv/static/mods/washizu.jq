def change_riichi_cost($cost):
  map(
    if .[0] == "when" and any(.[1][]; .name == "status" and .opts == ["just_reached"]) then
      .[2] |= map(if .[0] == "add_score" then .[1] = $cost else . end)
    else . end
  );

.wall |= (to_entries | map(if (.key % 4 != 0) then .value = [.value, "revealed", "transparent"] else . end) | map(.value))
|
# divide all scores by 10 (1000 pts -> 100 ccs)
.score_calculation += {
  "score_denomination": "🩸",
  "score_multiplier": 3200,
  "han_fu_rounding_factor": 10,
  "han_fu_multiplier": 0.1,
  "limit_scores": [
    800, 800, 800,
    1200,
    1600,
    2400,
    3200
  ],
  "draw_tenpai_payments": [100, 150, 300],
  "draw_nagashi_payments": [200, 400],
  "riichi_value": 100,
  "honba_value": 10
}
|
.initial_score = 2500
|
.before_turn_change.actions |= change_riichi_cost(-100)
|
.before_call.actions |= change_riichi_cost(-100)

