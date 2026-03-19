if has("yakuman") then
  .yakuman |= map(if .value | type == "number" then .value *= 13 else .value = [.value[0] * 13, "Han"] end)
  |
  .yaku += .yakuman
  |
  .yakuman = []
else . end
|
if has("meta_yakuman") then
  .meta_yakuman |= map(if .value | type == "number" then .value *= 13 else .value = [.value[0] * 13, "Han"] end)
  |
  .meta_yaku += .meta_yakuman
  |
  .meta_yakuman = []
else . end
