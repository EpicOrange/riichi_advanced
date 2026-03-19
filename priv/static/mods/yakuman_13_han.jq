if has("yakuman") then
  .yakuman |= map(if .value | type == "number" then .value *= 13 else .value[0] *= 13 end)
  |
  .yaku += .yakuman
  |
  .yakuman = []
else . end
|
if has("meta_yakuman") then
  .meta_yakuman |= map(if .value | type == "number" then .value *= 13 else .value[0] *= 13 end)
  |
  .meta_yaku += .meta_yakuman
  |
  .meta_yakuman = []
else . end
