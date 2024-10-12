# add ippatsu yaku after riichi
(.yaku | map(.display_name == "Riichi") | index(true)) as $ix
|
.yaku |= .[:$ix+1] + [
  {
    "display_name": "Ippatsu",
    "value": 1,
    "when": [{"name": "status", "opts": ["ippatsu"]}, {"name": "status_missing", "opts": ["call_made"]}]
  }
] + .[$ix+1:]
|
# set ippatsu status on riichi
.buttons.riichi.actions |= map(if .[0] == "set_status" then (. + ["ippatsu"]) else . end)
|
# unset own ippatsu status before next turn change after riichi, and before unsetting just_reached
(.before_turn_change.actions | map(type == "array" and .[0] == "unset_status" and (. | index("just_reached"))) | index(true)) as $ix
|
.before_turn_change.actions |=
(
  .[:$ix] + [
    ["when", [{"name": "status_missing", "opts": ["just_reached"]}], [["unset_status", "ippatsu"]]]
  ] + .[$ix:]
)
|
# unset ippatsu status on call
.before_call.actions += [["unset_status", "ippatsu"]]

