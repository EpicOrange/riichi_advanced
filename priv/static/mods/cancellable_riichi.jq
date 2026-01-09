if (.buttons | has("riichi")) then
  .buttons.riichi.actions = [
    ["mark", [["hand", 1, ["self", "can_discard"]]], [
      ["set_status", "riichi", "just_reached"],
      ["recalculate_playables"]
    ], [], [
      ["unset_status", "riichi", "just_reached"],
      ["recalculate_playables"]
    ]],
    # TODO: this is wrong because it doesn't count as discarding the marked tile, so it doesn't trigger buttons that would allow the riichi tile to be called. figure out how to fix.
    ["move_tiles", {"hand": ["marked"]}, "discard"],
    ["move_tiles", "draw", "hand"],
    # internally draws are marked with "_draw" attr, until moved into hand
    # since we're manually using move_tiles instead, we need to remove "_draw" manually
    # TODO remove the need for this
    ["remove_attr_hand", "_draw"],
    ["clear_marking"],
    ["big_text", "Riichi"],
    ["push_message", "declared riichi"],
    ["when", [{"name": "status", "opts": ["discards_empty"]}, "no_calls_yet"], [["set_status", "double_riichi"]]],
    ["enable_auto_button", "_4_auto_discard"],
    ["advance_turn"]
  ]
else . end
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
    # internally draws are marked with "_draw" attr, until moved into hand
    # since we're manually using move_tiles instead, we need to remove "_draw" manually
    # TODO remove the need for this
    ["remove_attr_hand", "_draw"],
    ["clear_marking"],
    ["reveal_hand"],
    ["big_text", "Open Riichi"],
    ["push_message", "declared open riichi"],
    ["when", [{"name": "status", "opts": ["discards_empty"]}, "no_calls_yet"], [["set_status", "double_riichi"]]],
    ["enable_auto_button", "_4_auto_discard"],
    ["advance_turn"]
  ]
else . end
