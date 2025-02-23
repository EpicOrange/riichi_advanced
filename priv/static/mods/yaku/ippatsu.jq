.after_initialization.actions += [
  ["update_rule", "Riichi", "(Ippatsu) If you win before or during your next draw after riichi, you are awarded ippatsu (1 han). Calls invalidate ippatsu."],
  ["update_rule", "Shuugi", "(Ippatsu) Ippatsu is worth 1 shuugi."]
]
|
# add ippatsu yaku after riichi
(.yaku | map(.display_name == "Riichi") | index(true)) as $ix
|
.yaku |= .[:$ix+1] + [
  {
    "display_name": "Ippatsu",
    "value": 1,
    "when": [{"name": "status", "opts": ["ippatsu"]}]
  }
] + .[$ix+1:]
|
# set ippatsu status on riichi
if .buttons.riichi then
  .buttons.riichi.actions |= map(if .[0] == "set_status" then (. + ["ippatsu"]) else . end)
else . end
|
# unset ippatsu status before turn changes (this is before discard_passed, which is when just_reached gets cleared)
.functions.turn_cleanup += [["when", [{"name": "status_missing", "opts": ["just_reached"]}], [["unset_status", "ippatsu"]]]]
|
# unset ippatsu status on call
.before_call.actions += [["unset_status_all", "ippatsu"]]

