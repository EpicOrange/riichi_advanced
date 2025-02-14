.yaku |= [
  { "display_name": "Riichi", "value": 1, "when": [{"name": "status", "opts": ["riichi"]}] },
  { "display_name": "Double Riichi", "value": 2, "when": [{"name": "status", "opts": ["double_riichi"]}] }
] + .
|
# used to check for riichi eligibility
.tenpai_14_definition = [
  [ "exhaustive", [["shuntsu", "koutsu"], 3], [["ryanmen/penchan", "kanchan", "pair"], 1], [["pair"], 1] ],
  [ "exhaustive", [["shuntsu", "koutsu"], 4] ],
  [ [["nojoker", "quad"], -1], [["koutsu"], -2], [["pair"], 6] ],
  [ "unique",
    [["1m","9m","1p","9p","1s","9s","1z","2z","3z","4z","5z","6z","7z"], 12],
    [["1m","9m","1p","9p","1s","9s","1z","2z","3z","4z","5z","6z","7z"], 1]
  ]
]
|
.display_riichi_sticks = true
|
.score_calculation.riichi_value = 1000
|
.buttons.riichi = {
  "display_name": "Riichi",
  "show_when": [
    "our_turn",
    "has_draw",
    {"name": "status_missing", "opts": ["riichi"]},
    {"name": "has_score", "opts": ["riichi_value"]},
    "next_draw_possible",
    {"name": "has_no_call_named", "opts": ["chii", "pon", "daiminkan", "kakan"]},
    {"name": "match", "opts": [["hand", "calls", "draw"], ["tenpai_14"]]}
  ],
  "actions": [
    ["big_text", "Riichi"],
    ["set_status", "riichi", "just_reached"],
    ["push_message", "declared riichi"],
    ["when", [{"name": "status", "opts": ["discards_empty"]}, "no_calls_yet"], [["set_status", "double_riichi"]]]
  ]
}
|
if (.buttons | has("chii")) then
  .buttons.chii.show_when += [{"name": "status_missing", "opts": ["riichi"]}]
else . end
|
if (.buttons | has("pon")) then
  .buttons.pon.show_when += [{"name": "status_missing", "opts": ["riichi"]}]
else . end
|
if (.buttons | has("daiminkan")) then
  .buttons.daiminkan.show_when += [{"name": "status_missing", "opts": ["riichi"]}]
else . end
|
if (.buttons | has("kakan")) then
  .buttons.kakan.call_conditions += [[
    {"name": "status_missing", "opts": ["riichi"]},
    {"name": "not_call_changes_waits", "opts": ["win"]}
  ]]
else . end
|
if (.buttons | has("ankan")) then
  .buttons.ankan.call_conditions += [[
    {"name": "status_missing", "opts": ["riichi"]},
    {"name": "not_call_changes_waits", "opts": ["win"]}
  ]]
else . end
|
.functions.turn_cleanup |= [
  # if we just reached then place down a riichi stick
  ["when", [{"name": "status", "opts": ["just_reached"]}], [["as", "last_discarder", [["run", "put_down_riichi_stick"]]]]]
] + map(if . == ["unset_status", "furiten"] then
  # unset furiten (unless in riichi)
  ["when", [{"name": "status_missing", "opts": ["riichi"]}], [["unset_status", "furiten"]]]
else . end)
|
.functions.discard_passed |= [["as", "others", [["unset_status", "just_reached"]]]] + .
|
.functions.put_down_riichi_stick = [
  ["when", [{"name": "status_missing", "opts": ["put_down_riichi_stick"]}], [
    ["subtract_score", "riichi_value"], ["put_down_riichi_stick"], ["set_status", "put_down_riichi_stick"]
  ]]
]
|
.play_restrictions += [
  [["any"], [{"name": "status", "opts": ["riichi"]}, {"name": "status_missing", "opts": ["just_reached"]}, "not_is_drawn_tile"]],
  [["any"], [{"name": "status", "opts": ["riichi", "just_reached"]}, {"name": "needed_for_hand", "opts": ["tenpai"]}]]
]
