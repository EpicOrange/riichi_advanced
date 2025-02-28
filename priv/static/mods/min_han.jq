(if $min == "Mangan" then
  "Your hand must score at least mangan to win"
elif $min == "Yakuman" then
  "Only yakuman hands can win"
else
  "Your hand must have at least \($min) han to win"
end
+
if has("dora_indicators") then
  if (.score_calculation.extra_yaku_lists | index("extra_yaku")) then
    " (dora does not count)."
  else
    " (dora counts)."
  end
else
  "."
end) as $min_han_description
|
.after_initialization.actions += [["add_rule", "Minimum Han", $min_han_description, -10]]
|
(if $min == "Mangan" then
  [
    {"name": "has_yaku_with_discard", "opts": [3, 60]},
    {"name": "has_yaku_with_discard", "opts": [4, 30]},
    {"name": "has_yaku_with_discard", "opts": [5]}
  ]
elif $min == "Yakuman" then
  # check for existence of kazoe
  if any(.score_calculation.limit_thresholds[]; .[0] >= 13) then
    [{"name": "has_yaku_with_discard", "opts": [13]}]
  else [] end
else
  [{"name": "has_yaku_with_discard", "opts": [$min]}]
end
+
[{"name": "has_yaku2_with_discard", "opts": [1]}]) as $checks
|
if (.buttons | has("ron")) then
  .buttons.ron.show_when += [$checks]
else . end
|
if $min != 1 and (.buttons | has("chankan")) then
  .buttons.chankan.show_when += [$checks | map(.name |= sub("discard"; "call"))]
else . end
|
if (.buttons | has("tsumo")) then
  .buttons.tsumo.show_when += [$checks | map(.name |= sub("discard"; "hand"))]
else . end
