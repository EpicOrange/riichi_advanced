.after_initialization.actions += [["add_rule", "Mangan", "Maneman", "\"Imitation Mangan\". If you copy any opponent's first five discards exactly, they will pay mangan if you win with less than mangan. Calls invalidate.", 105]]
|
.maneman += [
  {
    "display_name": "Maneman",
    "value": 5,
    "when": [
      {"name": "not_has_points", "opts": [5]},
      {"name": "not_status_missing", "opts": ["maneman_kamicha", "maneman_toimen", "maneman_shimocha"]}
    ]
  }
]
|
.after_start.actions += [
  ["set_counter_all", "maneman_kamicha", 0],
  ["set_counter_all", "maneman_toimen", 0],
  ["set_counter_all", "maneman_shimocha", 0]
]
|
.after_call.actions += [
  ["set_counter_all", "maneman_kamicha", -1],
  ["set_counter_all", "maneman_toimen", -1],
  ["set_counter_all", "maneman_shimocha", -1]
]
|
.play_effects += [
  ["any", [
    # check and increment counters
    ["when", ["kamicha_exists", {"name": "counter_at_least", "opts": ["maneman_kamicha", 0]}, {"name": "match", "opts": [["kamicha_last_discard"], [[[["any"], 1]]]]}], [
      ["ite", [{"name": "match", "opts": [["tile", "kamicha_last_discard"], [[[["pair"], 1]]]]}], [["add_counter", "maneman_kamicha", 1]], [["set_counter", "maneman_kamicha", -1]]]
    ]],
    ["when", ["toimen_exists", {"name": "counter_at_least", "opts": ["maneman_toimen", 0]}, {"name": "match", "opts": [["toimen_last_discard"], [[[["any"], 1]]]]}], [
      ["ite", [{"name": "match", "opts": [["tile", "toimen_last_discard"], [[[["pair"], 1]]]]}], [["add_counter", "maneman_toimen", 1]], [["set_counter", "maneman_toimen", -1]]]
    ]],
    ["when", ["shimocha_exists", {"name": "counter_at_least", "opts": ["maneman_shimocha", 0]}, {"name": "match", "opts": [["shimocha_last_discard"], [[[["any"], 1]]]]}], [
      ["ite", [{"name": "match", "opts": [["tile", "shimocha_last_discard"], [[[["pair"], 1]]]]}], [["add_counter", "maneman_shimocha", 1]], [["set_counter", "maneman_shimocha", -1]]]
    ]],
    # once counters reach 5, set maneman status
    ["when", [{"name": "counter_at_least", "opts": ["maneman_kamicha", 5]}], [["set_status", "maneman_kamicha"]]],
    ["when", [{"name": "counter_at_least", "opts": ["maneman_toimen", 5]}], [["set_status", "maneman_toimen"]]],
    ["when", [{"name": "counter_at_least", "opts": ["maneman_shimocha", 5]}], [["set_status", "maneman_shimocha"]]]
  ]]
]
|
# if maneman made it to the yaku list, set pao on the maneman player
.after_win.actions += [
  ["when", [{"name": "has_existing_yaku", "opts": [["Maneman", 5]]}], [
    ["when", [{"name": "status", "opts": ["maneman_kamicha"]}], [["as", "kamicha", [["make_responsible_for", "prev_seat", "all"]]]]],
    ["when", [{"name": "status", "opts": ["maneman_toimen"]}], [["as", "toimen", [["make_responsible_for", "prev_seat", "all"]]]]],
    ["when", [{"name": "status", "opts": ["maneman_shimocha"]}], [["as", "shimocha", [["make_responsible_for", "prev_seat", "all"]]]]]
  ]]
]
|
.yaku_precedence += {
  "Maneman": [1, 2, 3, 4]
}
|
if .score_calculation.yaku_lists | any(index("maneman")) then . else
  .score_calculation.yaku_lists += ["maneman"]
end
|
.score_calculation.pao_eligible_yaku += ["Maneman"]
|
# technically this mod conflicts with any pao mod because of this key
.score_calculation.win_with_pao_name = "Maneshi Mangan"
