# add flowers
.wall += ["1f", "2f", "3f", "4f", "1g", "2g", "3g", "4g"]
|
(2 * $flower_value) as $proper_value
|
(5 * $flower_value) as $all_value
|
# add flower yaku
.yaku += [	
	 {
       "display_name": "Improper Flower",
       "value": $flower_value,
       "when": [{"name": "seat_is", "opts": ["east"]}, {"name": "match", "opts": [["flowers"], [[[["2f","3f","4f"], 1]]]]}]
     },
	 {
       "display_name": "Improper Flower",
       "value": $flower_value,
       "when": [{"name": "seat_is", "opts": ["south"]}, {"name": "match", "opts": [["flowers"], [[[["1f","3f","4f"], 1]]]]}]
     },
	 {
       "display_name": "Improper Flower",
       "value": $flower_value,
       "when": [{"name": "seat_is", "opts": ["west"]}, {"name": "match", "opts": [["flowers"], [[[["1f","2f","4f"], 1]]]]}]
     },
	 {
       "display_name": "Improper Flower",
       "value": $flower_value,
       "when": [{"name": "seat_is", "opts": ["north"]}, {"name": "match", "opts": [["flowers"], [[[["1f","2f","3f"], 1]]]]}]
     },
	
	 {
       "display_name": "Improper Season",
       "value": $flower_value,
       "when": [{"name": "seat_is", "opts": ["east"]}, {"name": "match", "opts": [["flowers"], [[[["2g","3g","4g"], 1]]]]}]
     },
	 {
       "display_name": "Improper Season",
       "value": $flower_value,
       "when": [{"name": "seat_is", "opts": ["south"]}, {"name": "match", "opts": [["flowers"], [[[["1g","3g","4g"], 1]]]]}]
     },
	 {
       "display_name": "Improper Season",
       "value": $flower_value,
       "when": [{"name": "seat_is", "opts": ["west"]}, {"name": "match", "opts": [["flowers"], [[[["1g","2g","4g"], 1]]]]}]
     },
	 {
       "display_name": "Improper Season",
       "value": $flower_value,
       "when": [{"name": "seat_is", "opts": ["north"]}, {"name": "match", "opts": [["flowers"], [[[["1g","2g","3g"], 1]]]]}]
     },
	
     {
       "display_name": "Proper Flower",
       "value": $proper_value,
       "when": [{"name": "seat_is", "opts": ["east"]}, {"name": "match", "opts": [["flowers"], [[[["1f"], 1]]]]}]
     },
     {
       "display_name": "Proper Flower",
       "value": $proper_value,
       "when": [{"name": "seat_is", "opts": ["south"]}, {"name": "match", "opts": [["flowers"], [[[["2f"], 1]]]]}]
     },
     {
       "display_name": "Proper Flower",
       "value": $proper_value,
       "when": [{"name": "seat_is", "opts": ["west"]}, {"name": "match", "opts": [["flowers"], [[[["3f"], 1]]]]}]
     },
     {
       "display_name": "Proper Flower",
       "value": $proper_value,
       "when": [{"name": "seat_is", "opts": ["north"]}, {"name": "match", "opts": [["flowers"], [[[["4f"], 1]]]]}]
     },
     {
       "display_name": "Proper Season",
       "value": $proper_value,
       "when": [{"name": "seat_is", "opts": ["east"]}, {"name": "match", "opts": [["flowers"], [[[["1g"], 1]]]]}]
     },
     {
       "display_name": "Proper Season",
       "value": $proper_value,
       "when": [{"name": "seat_is", "opts": ["south"]}, {"name": "match", "opts": [["flowers"], [[[["2g"], 1]]]]}]
     },
     {
       "display_name": "Proper Season",
       "value": $proper_value,
       "when": [{"name": "seat_is", "opts": ["west"]}, {"name": "match", "opts": [["flowers"], [[[["3g"], 1]]]]}]
     },
     {
       "display_name": "Proper Season",
       "value": $proper_value,
       "when": [{"name": "seat_is", "opts": ["north"]}, {"name": "match", "opts": [["flowers"], [[[["4g"], 1]]]]}]
     },
     {
       "display_name": "Four Flowers",
       "value": $all_value,
       "when": [{"name": "match", "opts": [["flowers"], ["all_flowers"]]}]
     },
     {
       "display_name": "Four Seasons",
       "value": $all_value,
       "when": [{"name": "match", "opts": [["flowers"], ["all_seasons"]]}]
     }
]
|
# add start_flower call
.after_start.actions += [["set_status_all", "match_start"]]
|
# start match once everyone has the no_flowers status
.after_turn_change.actions += [
  ["when", [{"name": "everyone_status", "opts": ["no_flowers"]}], [
    ["unset_status_all", "no_flowers", "match_start"],
    ["change_turn", "east"]
  ]]
]
|
# add start_flower call
.buttons.start_flower = {
  "display_name": "Reveal flower",
  "show_when": [{"name": "status", "opts": ["match_start"]}, "our_turn", {"name": "match", "opts": [["hand", "draw"], [[ "nojoker", [["1f", "2f", "3f", "4f", "1g", "2g", "3g", "4g"], 1] ]]]}],
  "actions": [["big_text", "Flower"], ["flower", "1f", "2f", "3f", "4f", "1g", "2g", "3g", "4g"], ["draw", 1, "opposite_end"]],
  "unskippable": true
}
|
# add start_no_flower call
.buttons.start_no_flower = {
  "display_name": "No flowers",
  "show_when": [{"name": "status", "opts": ["match_start"]}, "our_turn", {"name": "not_match", "opts": [["hand", "draw"], [[ "nojoker", [["1f", "2f", "3f", "4f", "1g", "2g", "3g", "4g"], 1] ]]]}],
  "actions": [["big_text", "No flowers"], ["set_status", "no_flowers"], ["advance_turn"], ["recalculate_buttons"]],
  "unskippable": true
}
|
# add flower call
.buttons.flower = {
  "display_name": "Flower",
  "show_when": ["our_turn", "has_draw", {"name": "status_missing", "opts": ["match_start"]}, "not_just_discarded", {"name": "match", "opts": [["hand", "draw"], [[ "nojoker", [["1f", "2f", "3f", "4f", "1g", "2g", "3g", "4g"], 1]]]]}],
  "actions": [
    ["big_text", "Flower"],
    ["flower", "1f", "2f", "3f", "4f", "1g", "2g", "3g", "4g"],
    ["ite", ["no_tiles_remaining"], [["advance_turn"]], [["draw", 1, "opposite_end"]]]
  ],
  "unskippable": true
}
|
# add flower autobutton
.auto_buttons["5_auto_flower"] = {
  "display_name": "F",
  "desc": "Automatically declare all flowers.",
  "actions": [
    ["when", [{"name": "buttons_include", "opts": ["start_flower"]}], [["press_button", "start_flower"], ["press_first_call_button", "start_flower"]]],
    ["when", [{"name": "buttons_include", "opts": ["start_no_flower"]}], [["press_button", "start_no_flower"]]],
    ["when", [{"name": "buttons_include", "opts": ["flower"]}], [["press_button", "flower"], ["press_first_call_button", "flower"]]]
  ],
  "enabled_at_start": false
}
