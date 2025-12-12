if has("yakuman") then
  .yakuman |= map(.value *= 13)
  |
  .yaku += .yakuman
  |
  .yakuman = []
else . end
|
if has("meta_yakuman") then
  .meta_yakuman |= map(.value *= 13)
  |
  .meta_yaku += .meta_yakuman
  |
  .meta_yakuman = []
else . end
