# my somewhat shitty attempt at writing jQuery mod for zombie blanks in NMJL. might become an actual mod applicable to other variants too if it gets worked on more. --Soph.

# TODO: Figure out how to make this mod work with "Show Nearest Hands".
# UPDATE: I have no clue how to do that, the "Show Nearest Hands" mod just toggles on the option called `.show_nearest_american_hand`, and I don't know where this option is defined. This is a job for Dani lol
# UPDATE: Apparently the `.show_nearest_american_hand` just breaks in the Custom variant loader. So, probably not a problem with this mod.

# define function for adding n copies of a tile to the wall
def add_n_tiles($tile; $num):
  if $num > 0 then
      . += [$tile]
      |
      add_n_tiles($tile; $num - 1)
  else . end;

# add $count number of blanks to the wall
.wall |= add_n_tiles("5z"; $count)
|

# make blanks undiscardable
.play_restrictions += [ [["5z"], []] ]
|

# make the blank a joker so that it can't be passed, or marked in discards
.after_start.actions += [ ["set_tile_alias_all", ["5z"], ["5z"]] ]
|

# disallow Pung, Kong, Quint from having blanks
.buttons."1_am_pung".call_conditions[1].opts[0] += ["5z"]
|
.buttons."1_am_pung".call_conditions += [ {"name": "not_call_contains", "opts": [["5z"], 1]} ]
|
.buttons."2_am_kong".call_conditions[1].opts[0] += ["5z"]
|
.buttons."2_am_kong".call_conditions += [ {"name": "not_call_contains", "opts": [["5z"], 1]} ]
|
.buttons."3_am_quint".call_conditions[1].opts[0] += ["5z"]
|
.buttons."3_am_quint".call_conditions += [ {"name": "not_call_contains", "opts": [["5z"], 1]} ]
|

# add blank swap button. i'm reasonably confident this works...?
.buttons += {"am_blank_swap": {
      "display_name": "Swap blank for discard",
      "show_when": [
            # TODO: figure out how to only show the blank swap button if there exists at least one non-blank-non-joker in the discards
                  # hopefully that worked
            {"name": "status_missing", "opts": ["match_start", "dead_hand"]},
            "our_turn",
            "not_just_discarded",
            {"name": "match", "opts": [["hand"], [["nojoker", [["5z"], 1]]]]},
            {"name": "match", "opts": [["all_ponds"], [["not_joker"], 1]]}
      ],
      "actions": [
        ["big_text", "Swap"],
        ["mark", [["discard", 1, ["not_joker"]], ["hand", 1, ["5z"]] ]],
        ["push_message", "swapped a discard with a blank from hand"],
        ["swap_tiles", {"hand": ["marked"]}, {"discard": ["marked"]}],
        ["clear_marking"],
        ["recalculate_buttons"] #allow Mah-Jongg/joker swap to pop up
      ]
    }}
|

# can't win when you have a blank in hand
.buttons.mahjong_draw.show_when += [ {"name": "not_match", "opts": [["hand"], [[[["5z"], 1]]]]} ]
|
.buttons.mahjong_discard.show_when += [ {"name": "not_match", "opts": [["hand"], [[[["5z"], 1]]]]} ]
