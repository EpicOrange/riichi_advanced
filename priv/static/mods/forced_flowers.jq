if (.buttons | has("flower")) then
  .buttons.flower.unskippable = true
else . end
|
if (.auto_buttons | has("3_auto_flower")) then
  .auto_buttons["3_auto_flower"].enabled_at_start = false
else . end
