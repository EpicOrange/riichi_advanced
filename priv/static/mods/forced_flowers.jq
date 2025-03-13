if (.buttons | has("flower")) then
  .buttons.flower.unskippable = true
else . end
|
if (.auto_buttons | has("_3_auto_flower")) then
  .auto_buttons["_3_auto_flower"].enabled_at_start = false
else . end
