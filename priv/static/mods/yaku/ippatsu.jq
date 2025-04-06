.after_initialization.actions += [
  ["update_rule", "Rules", "Riichi", "(Ippatsu) If you win before or during your next draw after riichi, you are awarded ippatsu (1 han). Calls invalidate ippatsu."],
  ["update_rule", "Rules", "Shuugi", "(Ippatsu) Ippatsu is worth 1 shuugi."]
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
if (.buttons | has("riichi")) then
  .buttons.riichi.actions += [["set_status", "ippatsu"]]
else . end
|
# set ippatsu status on open riichi
if (.buttons | has("open_riichi")) then
  .buttons.open_riichi.actions += [["set_status", "ippatsu"]]
else . end
|
.functions.discard_passed |= [
  # unset ippatsu status if your own discard passes
  ["as", "last_discarder", [["when", [{"name": "status_missing", "opts": ["just_reached"]}], [["unset_status", "ippatsu"]]]]],
  # unset everyone's ippatsu status after any call
  ["when", ["just_called"], [["unset_status_all", "ippatsu"]]]
] + .
|
# unset everyone's ippatsu status after any call (except for chankan-able calls)
.after_call.actions |= [
  ["unless", [{"name": "status", "opts": ["can_chankan"]}], [
    ["unset_status_all", "ippatsu"]
  ]]
] + .
