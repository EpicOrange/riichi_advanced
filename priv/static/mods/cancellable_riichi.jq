.buttons.riichi.actions = [
  ["mark", [["hand", 1, ["self", "can_discard"]]], [
    ["set_status", "riichi", "just_reached"],
    ["recalculate_playables"]
  ], [], [
    ["unset_status", "riichi", "just_reached"],
    ["recalculate_playables"]
  ]],
  ["move_tiles", {"hand": ["marked"]}, "discard"],
  ["move_tiles", "draw", "hand"],
  ["clear_marking"],
  ["big_text", "Riichi"],
  ["push_message", "declared riichi"],
  ["when", [{"name": "status", "opts": ["discards_empty"]}, "no_calls_yet"], [["set_status", "double_riichi"]]],
  ["enable_auto_button", "_4_auto_discard"],
  ["advance_turn"]
]
|
if (.buttons | has("open_riichi")) then
  .buttons.open_riichi.actions = [
    ["mark", [["hand", 1, ["self", "can_discard"]]], [
      ["set_status", "riichi", "just_reached"],
      ["recalculate_playables"]
    ], [], [
      ["unset_status", "riichi", "just_reached"],
      ["recalculate_playables"]
    ]],
    ["move_tiles", {"hand": ["marked"]}, "discard"],
    ["move_tiles", "draw", "hand"],
    ["clear_marking"],
    ["reveal_hand"],
    ["big_text", "Open Riichi"],
    ["push_message", "declared open riichi"],
    ["when", [{"name": "status", "opts": ["discards_empty"]}, "no_calls_yet"], [["set_status", "double_riichi"]]],
    ["enable_auto_button", "_4_auto_discard"],
    ["advance_turn"]
  ]
else . end
