.after_initialization.actions += [["add_rule", "1 Han", "Riichi", "If you can, you may discard into tenpai with riichi to lock your hand. If your discard passes, you bet 1000 points. If you win you are awarded riichi (1 han). If you declare riichi on your very first discard, then you are instead awarded double riichi (2 han). Calls invalidate double riichi."]]
|
.yaku |= [
  { "display_name": "Riichi", "value": 1, "when": [{"name": "status", "opts": ["riichi"]}] },
  { "display_name": "Double Riichi", "value": 2, "when": [{"name": "status", "opts": ["double_riichi"]}] }
] + .
|
.yaku_precedence["Double Riichi"] = ["Riichi"]
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
.score_calculation.riichi_value = $bet
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
    ["enable_auto_button", "_4_auto_discard"],
    ["when", [{"name": "status", "opts": ["discards_empty"]}, "no_calls_yet"], [["set_status", "double_riichi"]]]
  ]
}
|
if $drawless then
  .buttons.riichi.show_when |= map(select(. != "next_draw_possible"))
else . end
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
if (.buttons | has("ron")) then
  .buttons.ron.show_when += [{"name": "status_missing", "opts": ["just_reached"]}]
else . end
|
if (.buttons | has("chankan")) then
  .buttons.chankan.show_when += [{"name": "status_missing", "opts": ["just_reached"]}]
else . end
|
if (.buttons | has("tsumo")) then
  .buttons.tsumo.show_when += [{"name": "status_missing", "opts": ["just_reached"]}]
else . end
|
.functions.turn_cleanup |= map(if . == ["unset_status", "furiten"] then
  # unset furiten (unless in riichi)
  ["when", [{"name": "status_missing", "opts": ["riichi"]}], [["unset_status", "furiten"]]]
else . end)
|
.functions.discard_passed |= [["as", "others", [
  # if we just reached then place down a riichi stick
  ["when", [{"name": "status", "opts": ["just_reached"]}], [["run", "place_riichi_stick"]]],
  ["unset_status", "just_reached"]
]]] + .
|
.functions.place_riichi_stick = [
  ["when", [{"name": "status_missing", "opts": ["riichi_stick_placed"]}], [
    ["subtract_score", "riichi_value"], ["put_down_riichi_stick"], ["set_status", "riichi_stick_placed"]
  ]]
]
|
.play_restrictions += [
  [["any"], [{"name": "status", "opts": ["riichi"]}, {"name": "status_missing", "opts": ["just_reached"]}, "not_is_drawn_tile"]],
  [["any"], [{"name": "status", "opts": ["riichi", "just_reached"]}, {"name": "needed_for_hand", "opts": ["tenpai"]}]]
]
