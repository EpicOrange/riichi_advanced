.after_initialization.actions += [
  ["add_rule", "Tiles", "Washizu", "Each tile in the wall is transparent and visible to all (e.g. %{transparent_8m}), except for one copy. Unflipped dora indicators are not visible.", {"transparent_8m": [{"attrs": ["_transparent"], "tile": "8s"}]}],
  ["add_rule", "Rules", "Washizu", "Points are replaced with blood. So 1000 points are now 100 ccs of blood."]
]
|
if $transparents == 1 then
  .wall |= (to_entries | map(if (.key % 4 == 1) then .value = [.value, "_revealed", "_transparent"] else . end) | map(.value))
elif $transparents == 2 then
  .wall |= (to_entries | map(if (.key % 2 != 0) then .value = [.value, "_revealed", "_transparent"] else . end) | map(.value))
elif $transparents == 3 then
  .wall |= (to_entries | map(if (.key % 4 != 0) then .value = [.value, "_revealed", "_transparent"] else . end) | map(.value))
elif $transparents == 4 then
  .wall |= (to_entries | map(.value = [.value, "_revealed", "_transparent"]) | map(.value))
end
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
.initial_score /= 10
|
# modify tobi
.score_calculation.tobi |= if . == 1000 then 100 elif . == 1001 then 101 else . end
