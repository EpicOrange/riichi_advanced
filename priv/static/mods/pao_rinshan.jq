.after_initialization.actions += [["add_rule", "Rinshan Pao", "If someone kans your discard and tsumos off the replacement tile (rinshan), you pay the full amount."]]
|
.after_call.actions += [
  ["when", 
    [
      {"name": "status", "opts": ["rinshan_pao_possible"]},
      {"name": "last_call_is", "opts": ["daiminkan"]}
    ],
    [["as", "callee", [["set_status", "rinshan_pao_eligible"]]]]],
  ["unset_status_all", "rinshan_pao_possible"]
]
|
# If anyone has rinshan_pao_eligible and winner has just kan'd into a win, the player with rinshan_pao_eligible gets pao'd.
.before_win.actions += [
  ["when", [{"name": "status", "opts": ["kan"]}], [
    ["when_anyone", [{"name": "status", "opts": ["rinshan_pao_eligible"]}], [
      ["set_status", "pao"]
    ]]
  ]]
]
|
# Otherwise, remove rinshan_pao_eligible status from everyone.
.functions.turn_cleanup += [
  ["unset_status_all", "rinshan_pao_eligible"]
]
|
# Prepend this "rinshan_pao_possible" at the start of the daiminkan action, so that when the call happens, this is already set.
if (.buttons | has("daiminkan")) then
  .buttons.daiminkan.actions |= [["set_status", "rinshan_pao_possible"]] + .
else . end
|
.score_calculation.pao_eligible_yaku += ["Rinshan"]
|
.score_calculation.pao_pays_all_yaku = true
|
.score_calculation.win_with_pao_name = "Sekinin Barai"
