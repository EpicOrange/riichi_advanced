# my very shitty attempt at writing jQuery mod for zombie blanks --Soph.

# add four blanks to wall
.wall += ["5z", "5z", "5z", "5z"]
|

# make blanks undiscardable
.play_restrictions += [ [["5z"], []] ]
|

# keep track of when discards exist (blanks can't be used if there are no discards)
.after_turn_change.actions += [ ["unset_status_all", "discards_empty"] ]
|
.after_start.actions[0] += ["discards_empty"]
|

# make the blank a joker so that it can't be passed, or marked in discards
.after_start.actions += [ ["set_tile_alias_all", ["5z"], ["any"]] ]
|

# disallow Pung, Kong, Quint from having blanks
.buttons."1_am_pung".call_conditions[1].opts[0] += ["5z"]
|
.buttons."1_am_pung".call_conditions += [ {"name": "not_call_contains", "opts": [["5z"], 1]} ]
|
.buttons."2_am_kong".call_conditions[1].opts[0] += ["5z"]
|
.buttons."2_am_pung".call_conditions += [ {"name": "not_call_contains", "opts": [["5z"], 1]} ]
|
.buttons."3_am_quint".call_conditions[1].opts[0] += ["5z"]
|
.buttons."3_am_quint".call_conditions += [ {"name": "not_call_contains", "opts": [["5z"], 1]} ]
|

# WIP SECTION: Add blank swap button
#.buttons.after("am_joker_swap") += ["am_blank_swap": {
#      "display_name": "Swap blank for discard",
#      "show_when": [{"name": "status_missing", "opts": ["match_start", "dead_hand", "discards_empty"]}, "our_turn", "not_just_discarded", {"name": "match", "opts": [["hand"], [[[["5z"], 1]]]]}],
#      "actions": [
#        ["big_text", "Swap"],
#        ["mark", [["discard", 1, ["not_joker"]], ["hand", 1, ["5z"]] ]],
#        ["push_message", "swapped a discard with a blank from hand"],
#        ["swap_marked_hand_and_discard"],
#        ["recalculate_buttons"] // allow Mah-Jongg/joker swap to pop up
#      ]
#    }]
#|
.buttons.mahjong_draw.show_when += [ {"name": "not_match", "opts": [["hand"], [[[["5z"], 1]]]]} ]
|
.buttons.mahjong_discard.show_when += [ {"name": "not_match", "opts": [["hand"], [[[["5z"], 1]]]]} ]
