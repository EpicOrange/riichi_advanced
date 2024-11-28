.buttons.joker_swap = {
  "display_name": "Swap fly joker",
  "show_when": ["our_turn", "not_just_discarded", {"name": "match", "opts": [["hand_draw_nonjoker_any", "joker_call_tile"], [[[["pair"], 1]]]]}],
  "actions": [
    ["big_text", "Swap"],
    ["mark", [["call", 1, ["call_has_joker", "match_call_to_marked_hand"]], ["hand", 1, ["self", "not_joker", "match_hand_to_marked_call"]]]],
    ["swap_out_fly_joker", "2y"]
  ]
}
